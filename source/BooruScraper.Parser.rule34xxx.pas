unit BooruScraper.Parser.rule34xxx;

interface
uses
  Classes, Types, SysUtils, System.Generics.Collections,
  BooruScraper.Interfaces, BooruScraper.BaseTypes, BooruScraper.Parser.Utils,
  HtmlParserEx, NetEncoding;

type

  TRule34xxxParser = Class(TBooruParser)
    public
      class function ParsePostsFromPage(const ASource: string): TBooruThumbAr; override;
      class function ParsePostFromPage(const ASource: string): IBooruPost; override;
      class function ParseCommentsFromPostPage(const ASource: string): TBooruCommentAr; overload; override;
      class function ParseCommentsFromPostPage(ASource: IHtmlElement): TBooruCommentAr; overload;
  End;

implementation

class function TRule34xxxParser.ParsePostsFromPage(const ASource: string): TBooruThumbAr;
var
  LDoc: IHtmlElement;
  LImgList: IHtmlElement;
  LImages: IHtmlElementList;
  I: integer;
begin
  Result := [];
  LDoc := ParserHtml(ASource);
//  LImgList := FindXByClass(LDoc, 'image-list');
//  if Assigned(LImgList) then begin
  LImages := FindAllByClass(LDoc, 'thumb');

  for I := 0 to LImages.Count - 1 do begin
    var LThumb: IHtmlElement := LImages.Items[I];
    var LRes: IBooruThumb := TBooruThumbBase.Create;

    { Id }
    var LTmp: string := LThumb.Attributes['id'];
    LTmp := Copy(LTmp, Low(LTmp) + 1, Length(LTmp)); { like s7193632 }
    LRes.Id := StrToInt64(LTmp);

    { Thumbnail }
    var LPrev := FindXByClass(LThumb, 'preview');
    if Assigned(LPrev) then begin

      { Thumbnail URL }
      LRes.Thumbnail := NormalizeUrl(LPrev.Attributes['src']);

      { Tags }
      LTmp := Trim(LPrev.Attributes['title']);
      LRes.TagsValues := NormalizeTags(LTmp.Split([' '], TStringSplitOptions.ExcludeEmpty));

    end;

    Result := Result + [LRes];
  end;

//  end;
end;

class function TRule34xxxParser.ParseCommentsFromPostPage(const ASource: string): TBooruCommentAr;
var
  LDoc: IHtmlElement;
begin
  LDoc := ParserHtml(ASource);
  Result := ParseCommentsFromPostPage(LDoc);
end;

class function TRule34xxxParser.ParseCommentsFromPostPage(ASource: IHtmlElement): TBooruCommentAr;
var
  LStr: string;
  I: integer;
begin
  var LComments := ASource.FindX('//*[@id="comment-list"]/div');
  for I := 0 to LComments.Count - 1 do begin
    var LNewComment: IBooruComment := TBooruCommentBase.Create;

    { Comment Id }
    LStr := LComments[I].Attributes['id'];
    LStr := Copy(LStr, Low(LStr) + 1, Length(LStr)); { like c12015340 }
    LNewComment.Id := StrToInt64(LStr);

    { Comment score }
    LStr := Trim(FindXById(LComments[I], 'sc' + LNewComment.Id.ToString).Text);
    LNewComment.Score := StrToInt(LStr);

    var LCol1 := FindXByClass(LComments[I], 'col1');
    var LCol2 := FindXByClass(LComments[I], 'col2');

    { Comment Author username }
    if Assigned(LCol2) then begin
      LNewComment.Username := Trim(LCol1.FindX('//a').Text);
      LNewComment.Text := Trim(THTMLEncoding.HTML.Decode(LCol2.Text));
    end;

    { Comment Timestamp }
    try
      if Assigned(LCol1) then begin
        LStr := Trim(GetBetween(LCol1.Text, 'Posted on', 'Score'));
        LNewComment.Timestamp := StrToDatetime(LStr, BOORU_TIME_FORMAT);
      end;
    except

    end;

    Result := Result + [LNewComment];
  end;
end;

class function TRule34xxxParser.ParsePostFromPage(const ASource: string): IBooruPost;
var
  LDoc: IHtmlElement;
  I: integer;
  LTmps: IHtmlElementList;
  LTmp: IHtmlElement;
  LStr: string;
begin
  Result := TBooruPostBase.Create;
  LDoc := ParserHtml(ASource);

  { Tags }
  var LTagBar := FindXById(LDoc, 'tag-sidebar');

  if Assigned(LTagBar) then begin
    var LTags := FindAllByClass(LTagBar, 'tag');
    for I := 0 to LTags.Count - 1 do begin
      var LTag := LTags.Items[I];
      var LNewTag: IBooruTag := TBooruTagBase.Create;

      { Tag type }
      LNewTag.Kind := GetTagTypeByClass(LTag.Attributes['class']);

      { Tag value (name) }
      LTmps := LTag.FindX('//a');
      if (LTmps.Count > 1) then
        LNewTag.Value := NormalizeTag(LTmps.Items[1].InnerHtml)
      else if (LTmps.Count > 0) then
        LNewTag.Value := NormalizeTag(LTmps.Items[0].InnerHtml);

      { Tag count }
      var TagCount := FindXByClass(LTag, 'tag-count');
      LNewTag.Count := StrToInt(TagCount.InnerText);

      Result.Tags.Add(LNewTag);
    end;

    { Image sapmple }
    var LImage := FindXById(LDoc, 'image');
    if Assigned(LImage) then
      Result.SampleUrl := NormalizeUrl(LImage.Attributes['src']);

  end;

  var LStats := FindXById(LDoc, 'stats');
  if Assigned(LStats) then begin
    LTmps := LStats.FindX('//li');

    { Id }
    LStr := LTmps.Items[0].InnerText;
    LStr := Trim(LStr.Remove(0, 4));
    Result.Id := StrToInt64(LStr);

    { Posted by }
    try
      Result.Uploader := Trim(LTmps[1].Find('a')[0].Text);
    except

    end;

    { Score }
    try
      Result.Score := StrToInt(FindXById(LStats, 'psc' + Result.id.ToString).InnerText);
    except

    end;

  end;

  var LLinks := FindXByClass(LDoc, 'sidebar');
  if Assigned(LLinks) then begin

    { ContentUrl }
    LTmp := FindByText(LLinks, 'Original image', True, True);
    Result.ContentUrl := NormalizeUrl(LTmp.Attributes['href']);

  end;

  { Comments }
  var LNewComments := ParseCommentsFromPostPage(LDoc);
  Result.Comments.AddRange(LNewComments);

end;

end.
