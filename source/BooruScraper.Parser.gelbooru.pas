unit BooruScraper.Parser.gelbooru;

interface
uses
  Classes, Types, SysUtils, System.Generics.Collections,
  BooruScraper.Interfaces, BooruScraper.BaseTypes, BooruScraper.Parser.Utils,
  HtmlParserEx, NetEncoding;

type

  TGelbooruParser = Class(TBooruParser)
    public
      class function ParsePostsFromPage(const ASource: string): TBooruThumbAr; override;
      class function ParsePostFromPage(const ASource: string): IBooruPost; override;
      class function ParseCommentsFromPostPage(const ASource: string): TBooruCommentAr; overload; override;
      class function ParseCommentsFromPostPage(ASource: IHtmlElement): TBooruCommentAr; overload;
  End;

implementation

class function TGelbooruParser.ParsePostsFromPage(const ASource: string): TBooruThumbAr;
var
  LDoc: IHtmlElement;
  I: integer;
begin
  LDoc := ParserHtml(ASource);
  var LThumbContainer := FindXByClass(LDoc, 'thumbnail-container');
  if Assigned(LThumbContainer) then begin

    var LThumbs := FindAllByClass(LThumbContainer, 'thumbnail-preview');
    for I := 0 to LThumbs.Count - 1 do begin
      var LThumb := LThumbs[I];
      var LRes: IBooruThumb := TBooruThumbBase.Create;

      { Id }
      var LTmp: string := LThumb.FindX('//a')[0].Attributes['id'];
      LTmp := Copy(LTmp, Low(LTmp) + 1, Length(LTmp)); { like p4353455 }
      LRes.Id := StrToInt64(LTmp);

      { Thumbnail }
      var LPrev := LThumb.FindX('//img').Items[0];
      if Assigned(LPrev) then begin

        { Thumbnail URL }
        LRes.Thumbnail := LPrev.Attributes['src'];

        { Tags }
        LTmp := Trim(LPrev.Attributes['title']);
        LRes.TagsValues := NormalizeTags(LTmp.Split([' '], TStringSplitOptions.ExcludeEmpty));

      end;

      Result := Result + [LRes];

    end;

  end;
end;

class function TGelbooruParser.ParsePostFromPage(const ASource: string): IBooruPost;
var
  LDoc: IHtmlElement;
  I: integer;
  LTmps: IHtmlElementList;
  LTmp: IHtmlElement;
  LStr, LStr2: string;

  procedure ParseTags(AList: IHtmlElementList; ATagType: TBooruTagType);
  var
    N: integer;
  begin
    for N := 0 to AList.Count - 1 do begin
      var LTag := AList[N];
      var LNewTag: IBooruTag := TBooruTagBase.Create;
      LNewTag.Kind := ATagType;

      { Tag value (name) }
      LTmps := LTag.FindX('//a');
      LNewTag.Value := NormalizeTag(LTmps.Items[1].InnerHtml);

      { Tag count }
      var TagCount := LTag.FindX('//span').Items[1];
      LNewTag.Count := StrToInt(TagCount.InnerText);

      Result.Tags.Add(LNewTag);
    end;
  end;

begin
  Result := TBooruPostBase.Create;
  LDoc := ParserHtml(ASource);
  
  { Tags }
  var LTagList := FindXById(LDoc, 'tag-list');
  if Assigned(LTagList) then begin
    ParseTags(FindAllByClass(LTagList, 'tag-type-artist'), TagArtist);
    ParseTags(FindAllByClass(LTagList, 'tag-type-character'), TagCharacter);
    ParseTags(FindAllByClass(LTagList, 'tag-type-copyright'), TagCopyright);
    ParseTags(FindAllByClass(LTagList, 'tag-type-metadata'), TagMetadata);
    ParseTags(FindAllByClass(LTagList, 'tag-type-general'), TagGeneral);
  end;

  LStr :=  THTMLEncoding.HTML.Decode(LTagList.Text);

  { Id }
  LStr2 := Trim(GetBetween(LStr, 'Id:', 'Posted'));
  Result.Id := StrToInt64(LStr2);

  { Uploader username }
  LStr2 := Trim(GetBetween(LStr, 'Uploader:', 'Size:'));
  Result.Uploader := LStr2;

  { Score }
  try
    LStr2 := Trim(GetBetween(LStr, 'Score: ', ' '));
    Result.Score := StrToInt(LStr2);
  except

  end;

  { Image thumbnail (sapmple) }
  var LImage := FindXById(LDoc, 'image');
  if Assigned(LImage) then
    Result.Thumbnail := LImage.Attributes['src'];

  { ContentUrl }
  LTmp := FindByText(LTagList, 'Original image', True, True);
  Result.ContentUrl := LTmp.Attributes['href'];

  Result.Comments.AddRange(ParseCommentsFromPostPage(LDoc));
end;

class function TGelbooruParser.ParseCommentsFromPostPage(ASource: IHtmlElement): TBooruCommentAr;
var
  LAvas: IHtmlElementList;
  I, N: integer;
  LStr, LStr2: string;
  LIdPos: integer;
begin
  Result := [];
  LAvas := FindAllByClass(ASource, 'commentAvatar');
  for I := 0 to LAvas.Count - 1 do begin
    var LNewComment: IBooruComment := TBooruCommentBase.Create;
    var LComment := LAvas[I].Parent;
    var LAvatar := LAvas[I];
    var LBody := FindXByClass(LComment, 'commentBody');

//    for N := 0 to LBody.ChildrenCount - 1 do begin
//      writeln('Text[' + N.ToString + ']: ' + LBody.Children[N].Text);
//    end;

    { Comment Author username }
    try
      LStr := Trim(LBody.FindX('//a/b')[0].Text);
      LNewComment.Username := LStr;
    except

    end;

    LStr2 := LBody.Children[2].Text; // username commented at 2021-10-12 08:39:21 » #1111111

    { Comment Id } //FIXME
    try
      LStr := '';
      N := LStr2.IndexOf('#') + 2;

      for N := N to high(LStr2) do begin
        if LStr2[N] in ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'] then
          LStr := LStr + LStr2[N]
        else
          Break;
      end;

      LNewComment.Id := StrToInt64(LStr);
    except

    end;

    { Comment text }
    try
//      LStr := GetBetween(LStr2, '#' + LNewComment.Id.ToString, SLineBreak);
      LStr := LBody.Children[5].Text; // Comment text here
      LNewComment.Text := Trim(THTMLEncoding.HTML.Decode(LStr));
    except

    end;

    { Comment Timestamp }
    try
      LStr := Trim(GetBetween(LStr2, ' commented at', '&'));
      LNewComment.Timestamp := StrToDatetime(LStr, BOORU_TIME_FORMAT);
    except

    end;

    { Comment score }
    LStr := Trim(FindXById(LComment, 'sc' + LNewComment.Id.ToString).Text);
    LNewComment.Score := StrToInt(LStr);

    Result := Result + [LNewComment];
  end;
end;

class function TGelbooruParser.ParseCommentsFromPostPage(const ASource: string): TBooruCommentAr;
var
  LDoc: IHtmlElement;
begin
  LDoc := ParserHtml(ASource);
  Result := ParseCommentsFromPostPage(LDoc);
end;


end.
