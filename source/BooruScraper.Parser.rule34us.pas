unit BooruScraper.Parser.rule34us;

interface
uses
  Classes, Types, SysUtils, System.Generics.Collections,
  BooruScraper.Interfaces, BooruScraper.BaseTypes, BooruScraper.Parser.Utils,
  HtmlParserEx, NetEncoding;

type

  TRule34usParser = Class(TBooruParser)
    protected
      class function DoParsePostsFromPage(const ASource: string): TBooruThumbAr; override;
      class function DoParsePostFromPage(const ASource: string): IBooruPost; override;
      class function ParseCommentsFromElement(AElement: IHtmlElement): TBooruCommentAr;
      class function DoParseCommentsFromPostPage(const ASource: string): TBooruCommentAr; overload; override;
      class function ParseCommentsFromPostPage(ASource: IHtmlElement): TBooruCommentAr; overload;
      class function GetTagTypeByClass(const AClass: string): TBooruTagType;
  End;

implementation

{ TRule34usParser }

class function TRule34usParser.DoParseCommentsFromPostPage(
  const ASource: string): TBooruCommentAr;
var
  LDoc: IHtmlElement;
begin
  LDoc := ParserHtml(ASource);
  Result := ParseCommentsFromPostPage(LDoc);
end;

class function TRule34usParser.GetTagTypeByClass(const AClass: string): TBooruTagType;
begin
  if AClass.Contains('general-tag') then
    Result := TagGeneral
  else if AClass.Contains('copyright-tag') then
    Result := TagCopyright
  else if AClass.Contains('character-tag') then
    Result := TagCharacter
  else if AClass.Contains('metadata-tag') then
    Result := TagMetadata
  else if AClass.Contains('artist-tag') then
    Result := TagArtist
  else
    Result := TagGeneral;
end;

class function TRule34usParser.ParseCommentsFromElement(
  AElement: IHtmlElement): TBooruCommentAr;
var
  I: integer;
  LComments: IHtmlElementList;
  LComment: IHtmlElement;
  LTmp: IHtmlElement;
  LStr, LText: string;
const
  BORDER = '   ';
begin
  LComments := FindAllByClass(AElement, 'commentBox');
  for I := 0 to LComments.Count - 1 do begin
    LComment := LComments[I];
    var LNewComment: IBooruComment := TBooruCommentBase.Create;

    { Comment Id }
    LStr := LComments[I].Attributes['id'];
    LStr := Copy(LStr, Low(LStr) + 1, Length(LStr)); { like c12015340 }
    LNewComment.Id := StrToInt64(LStr);

    LText := THTMLEncoding.HTML.Decode(Trim(LComment.Text));

    { Comment Author username }
    LStr := Trim(GetBetween(LText, '#' + LNewComment.Id.ToString, 'Posted on'));
    LNewComment.Username := LStr;

    { Comment Timestamp }
    try
      LStr := GetBetween(LText, 'Posted on', BORDER);
      LNewComment.Timestamp := StrToDatetime(LStr, BOORU_TIME_FORMAT);
    except

    end;

    { Comment Text }
    LNewComment.Text := Trim(GetAfter(LText, BORDER));

    Result := Result + [LNewComment];
  end;
end;

class function TRule34usParser.ParseCommentsFromPostPage(
  ASource: IHtmlElement): TBooruCommentAr;
var
  LContentPush: IHtmlElement;
begin
  try
    LContentPush := FindXByClass(ASource, 'content_push');
    if Assigned(LContentPush) then
      Result := Self.ParseCommentsFromElement(LContentPush);
  except
    On E: Exception do
      if not HandleExcept(E, 'ParseCommentsFromPostPage') then raise;
  end;
end;

class function TRule34usParser.DoParsePostFromPage(
  const ASource: string): IBooruPost;
var
  LDoc: IHtmlElement;
  I: integer;
  LTmps: IHtmlElementList;
  LTmp: IHtmlElement;
  LStr: string;
begin
  Result := TBooruPostBase.Create;
  LDoc := ParserHtml(ASource);

  var LContentPush := FindXByClass(LDoc, 'content_push');
  if Assigned(LContentPush) then begin

    var LVideo := FindXFirst(LContentPush, '//video');
    if Assigned(LVideo) then begin

      var LSource := LVideo.FindX('//source');
      if LSource.Count > 0 then
        Result.ContentUrl := LSource[0].Attributes['src'];

    end else begin

      LTmp := FindXFirst(LContentPush, '//img');
      if Assigned(LTmp) then
        Result.SampleUrl := LTmp.Attrs['src'];

    end;

    Result.Comments.AddRange(Self.ParseCommentsFromElement(LContentPush));
  end;

  { Tags }
  var LTagBar := FindXByClass(LDoc, 'tag-list-left');
  if Assigned(LTagBar) then begin

    LTmps := LTagBar.Find('li');
    for I := 0 to LTmps.Count - 1 do begin
      LTmp := LTmps.Items[I];
      var LCounter := FindXFirst(LTmp, '//small');

      if not Assigned(LCounter) then continue;

      var LNewTag: IBooruTag := TBooruTagBase.Create;

      { Tag type }
      LNewTag.Kind := TRule34usParser.GetTagTypeByClass(LTmp.Attrs['class']);

      { Tag value (name) }
      var LA := FindXFirst(LTmp, '//a');
      if Assigned(LA) then
        LNewTag.Value := NormalizeTag(LA.InnerText);

      { Tag counter }
      LNewTag.Count := StrToInt(LCounter.InnerText);;

      Result.Tags.Add(LNewTag);

    end;

    { Content URL }
    LTmps := LTagBar.FindX('/a');
    for I := LTmps.Count - 1 downto 0 do begin
      LTmp := LTmps[I];
      var LOriginal := FindXFirst(LTmp, '//li');

      if Assigned(LOriginal)
      and (LOriginal.Text = 'Original') then
        Result.ContentUrl := LTmp.Attrs['href'];
    end;

    var LStats: IHtmlElement := nil;
    LTmps := LTagBar.Find('div');
    for I := LTmps.Count - 1 downto 0 do begin
      LTmp := LTmps[I];
      if String.StartsText('font-size: .8em; word-wrap: break-word;', LTmp.Attrs['style']) then begin
        LStats := LTmp;
        Break;
      end;
    end;

    if Assigned(LStats) and (LStats.ChildrenCount > 0) then begin

      { Id }
      LTmp := LStats.Children[1];
      LStr := LTmp.InnerText;
      LStr := Trim(LStr.Remove(0, 4));
      Result.Id := StrToInt64(LStr);

      { Posted by }
      try
        Result.Uploader := Trim(LStats.Children[3].Find('a')[0].Text);
      except

      end;

      { Score }
      try
        Result.Score := StrToInt(FindXById(LStats, 'psc' + Result.id.ToString).InnerText);
      except

      end;
    end;
  end;
end;

class function TRule34usParser.DoParsePostsFromPage(
  const ASource: string): TBooruThumbAr;
var
  LDoc: IHtmlElement;
  LImgList: IHtmlElement;
  LImages: IHtmlElementList;
  LImg: IHtmlElement;
  I, N: integer;
begin
  Result := [];
  LDoc := ParserHtml(ASource);

  LImgList := FindXByClass(LDoc, 'thumbail-container');
  if Assigned(LImgList) then begin
    LImages := LImgList.FindX('//div');

    for I := 0 to LImages.Count - 1 do begin
      var LThumb: IHtmlElement := LImages.Items[I];
      var LRes: IBooruThumb := TBooruThumbBase.Create;
      LThumb := FindXFirst(LThumb, '//a');

      if not Assigned(LThumb) then continue;

      LImg := FindXFirst(LThumb, '//img');
      if not Assigned(LImg) then continue;

      { Id }
      var LTmp: string := Trim(LThumb.Attributes['id']);
      LRes.Id := StrToInt64(LTmp);

      { Thumbnail URL }
      LRes.Thumbnail := LImg.Attributes['src'];

      { Tags }
      LTmp := Trim(LImg.Attributes['title']);
      LRes.TagsValues := NormalizeTags(LTmp.Split([', '], TStringSplitOptions.ExcludeEmpty));

      Result := Result + [LRes];
    end;
  end;
end;

end.
