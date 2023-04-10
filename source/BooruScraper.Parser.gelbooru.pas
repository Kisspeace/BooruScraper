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
  LThumbContainer: IHtmlElement;
  LThumbs: IHtmlElementList;
  LOldStyle: Boolean;
  I: integer;
begin
  LOldStyle := False;
  LDoc := ParserHtml(ASource);
  LThumbContainer := FindXByClass(LDoc, 'thumbnail-container');
  if not Assigned(LThumbContainer) then begin
    LThumbContainer := FindXByClass(LDoc, 'content'); { Gelbooru Beta 0.1.11 }
    if Assigned(LThumbContainer) then
      LOldStyle := True;
  end;

  if Assigned(LThumbContainer) then begin

    if LOldStyle then
      LThumbs := FindAllByClass(LThumbContainer, 'thumb')
    else
      LThumbs := FindAllByClass(LThumbContainer, 'thumbnail-preview');

    for I := 0 to LThumbs.Count - 1 do begin
      var LThumb := LThumbs[I];
      var LRes: IBooruThumb := TBooruThumbBase.Create;

      { Id }
      var LTmp: string := LThumb.FindX('//a')[0].Attributes['id'];
      LTmp := OnlyDigits(LTmp); { like p4353455 }
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
  LTagList: IHtmlElement;
  LStr, LStr2: string;
  LOldStyle: Boolean;

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
      if LTmps.Count > 0 then begin
        if LTmps.Count > 1 then
          LTmp := LTmps[1]
        else
          LTmp := LTmps[0];

        if Assigned(LTmp) then begin
          LStr2 := LTmp.InnerText;
          LNewTag.Value := NormalizeTag(LStr2);

          { Tag count }
          LTmps := LTag.FindX('//span');
          if LTmps.Count > 0 then begin
            if LTmps.Count > 1 then
              LStr := LTmps[1].InnerText
            else begin
              LStr := LTmps[0].InnerText;
              LStr := Trim(Lstr);
              LStr := GetAfter(LStr, LStr2);
              LStr := OnlyDigits(LStr);
            end;

            LNewTag.Count := StrToInt(LStr);
          end;

          Result.Tags.Add(LNewTag);
        end;
      end;
    end;
  end;

begin
  Result := TBooruPostBase.Create;
  LDoc := ParserHtml(ASource);
  LOldStyle := False;
  
  { Tags }
  LTagList := FindXById(LDoc, 'tag-list');
  if Assigned(LTagList) then begin
    ParseTags(FindAllByClass(LTagList, 'tag-type-artist'), TagArtist);
    ParseTags(FindAllByClass(LTagList, 'tag-type-character'), TagCharacter);
    ParseTags(FindAllByClass(LTagList, 'tag-type-copyright'), TagCopyright);
    ParseTags(FindAllByClass(LTagList, 'tag-type-metadata'), TagMetadata);
    ParseTags(FindAllByClass(LTagList, 'tag-type-general'), TagGeneral);
  end else begin { Gelbooru Beta 0.1.11 }
    LTagList := FindXById(LDoc, 'tag_list');
    if Assigned(LTagList) then begin
      LOldStyle := True;
      ParseTags(LTagList.FindX('//li'), TagGeneral);
    end;
  end;

  if Assigned(LTagList) then begin
    LStr :=  THTMLEncoding.HTML.Decode(LTagList.Text);

    { Id }
    LStr2 := Trim(GetBetween(LStr, 'Id:', 'Posted'));
    Result.Id := StrToInt64(LStr2);

    { Uploader username }
    if LOldStyle then
      LStr2 := Trim(GetBetween(LStr, 'By:', 'Size:'))
    else
      LStr2 := Trim(GetBetween(LStr, 'Uploader:', 'Size:'));
    Result.Uploader := LStr2;

    { Score }
    try
      LStr2 := Trim(GetBetween(LStr, 'Score: ', ' '));
      LStr2 := OnlyDigits(LStr);
      Result.Score := StrToInt(LStr2);
    except

    end;

    { Image sapmple }
    var LImage := FindXById(LDoc, 'image');
    if Assigned(LImage) then
      Result.SampleUrl := LImage.Attributes['src'];

    { ContentUrl }
    LTmp := FindByText(LTagList, 'Original image', True, True);
    if Assigned(LTmp) then
      Result.ContentUrl := LTmp.Attributes['href'];
  end;

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

    { Comment Author username }
    try
      LStr := Trim(LBody.FindX('//a/b')[0].Text);
      LNewComment.Username := LStr;
    except

    end;

    LStr2 := LBody.Children[2].Text; // username commented at 2021-10-12 08:39:21 » #1111111

    { Comment Id }
    try
      N := LStr2.IndexOf('#') + 2;
      LStr := OnlyDigits(LStr2);
      LNewComment.Id := StrToInt64(LStr);
    except

    end;

    { Comment text }
    try
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
