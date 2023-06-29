unit BooruScraper.Parser.rule34xxx;

interface
uses
  Classes, Types, SysUtils, System.Generics.Collections,
  BooruScraper.Interfaces, BooruScraper.BaseTypes, BooruScraper.Parser.Utils,
  HtmlParserEx, NetEncoding;

type

  TRule34xxxParser = Class(TBooruParser)
    protected
      class function DoParsePostsFromPage(const ASource: string): TBooruThumbAr; override;
      class function DoParsePostFromPage(const ASource: string): IBooruPost; override;
      class function DoParseCommentsFromPostPage(const ASource: string): TBooruCommentAr; overload; override;
      class function DoParseCommentsFromPostPage(ASource: IHtmlElement): TBooruCommentAr; overload;
  End;

implementation

class function TRule34xxxParser.DoParsePostsFromPage(const ASource: string): TBooruThumbAr;
var
  LDoc: IHtmlElement;
  LImgList: IHtmlElement;
  LImages: IHtmlElementList;
  I: integer;
begin
  Result := [];
  LDoc := ParserHtml(ASource);
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
end;

class function TRule34xxxParser.DoParseCommentsFromPostPage(const ASource: string): TBooruCommentAr;
var
  LDoc: IHtmlElement;
begin
  LDoc := ParserHtml(ASource);
  Result := DoParseCommentsFromPostPage(LDoc);
end;

class function TRule34xxxParser.DoParseCommentsFromPostPage(ASource: IHtmlElement): TBooruCommentAr;
var
  LStr: string;
  I: integer;
  LTmp: IHtmlElement;
begin
  try
    var LComments := ASource.FindX('//*[@id="comment-list"]/div');
    for I := 0 to LComments.Count - 1 do begin
      var LNewComment: IBooruComment := TBooruCommentBase.Create;

      { Comment Id }
      LStr := LComments[I].Attributes['id'];
      LStr := Copy(LStr, Low(LStr) + 1, Length(LStr)); { like c12015340 }
      LNewComment.Id := StrToInt64(LStr);

      { Comment score }
      try
        LTmp := FindXById(LComments[I], 'sc' + LNewComment.Id.ToString);
        if Assigned(LTmp) then begin
          LStr := Trim(LTmp.Text);
          LNewComment.Score := StrToInt(LStr);
        end;
      except

      end;

      var LCol1 := FindXByClass(LComments[I], 'col1');
      var LCol2 := FindXByClass(LComments[I], 'col2');

      { Comment Author username }
      if Assigned(LCol2) and Assigned(LCol1) then begin
        LTmp := FindXFirst(LCol1, '//a');
        if Assigned(LTmp) then
          LNewComment.Username := Trim(LTmp.Text);
        LNewComment.Text := Trim(THTMLEncoding.HTML.Decode(LCol2.Text));

        { Comment Timestamp }
        try
          LStr := Trim(GetBetween(LCol1.Text, 'Posted on', 'Score'));
          LNewComment.Timestamp := StrToDatetime(LStr, BOORU_TIME_FORMAT);
        except

        end;
      end;

      Result := Result + [LNewComment];
    end;
  except
    On E: Exception do
      if not HandleExcept(E, 'ParseCommentsFromPostPage') then raise;
  end;
end;

class function TRule34xxxParser.DoParsePostFromPage(const ASource: string): IBooruPost;
var
  LDoc: IHtmlElement;
  I: integer;
  LTmps: IHtmlElementList;
  LTmp: IHtmlElement;
  LStr: string;
begin
  Result := TBooruPostBase.Create;
  { Fix: https://github.com/Kisspeace/NsfwBox/issues/8 }
  var PROBLEM_SYMPTOM: string := '&amp;id=" ';
  if (ASource.IndexOf(PROBLEM_SYMPTOM) <> -1) then
  begin
    var LPatchedSource := ASource.Replace(
      PROBLEM_SYMPTOM, '&amp;id=',
      [rfReplaceAll, rfIgnoreCase]);
    LDoc := ParserHtml(LPatchedSource);
  end else
  { Fix end. }
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
      var LTagCount := FindXByClass(LTag, 'tag-count');
      if Assigned(LTagCount) then
        LNewTag.Count := StrToInt(LTagCount.InnerText);

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
    if LTmps.Count > 0 then
    begin
      { Id }
      LStr := LTmps.Items[0].InnerText;
      LStr := Trim(LStr.Remove(0, 4));
      Result.Id := StrToInt64(LStr);

      if LTmps.Count > 1 then begin
        { Posted by }
        try
          var LTmps2 := LTmps[1].Find('a');
          if LTmps2.Count > 0 then
            Result.Uploader := Trim(LTmps2[0].Text);
        except

        end;

        { Score }
        try
          var LScore := FindXById(LStats, 'psc' + Result.id.ToString);
          if Assigned(LScore) then
            Result.Score := StrToInt(LScore.InnerText);
        except

        end;
      end;
    end;
  end;

  var LLinks := FindXByClass(LDoc, 'sidebar');
  if Assigned(LLinks) then
  begin
    { ContentUrl }
    LTmp := FindByText(LLinks, 'Original image', True, True);
    if Assigned(LTmp) then
      Result.ContentUrl := NormalizeUrl(LTmp.Attributes['href']);
  end;

  { Comments }
  var LNewComments := DoParseCommentsFromPostPage(LDoc);
  Result.Comments.AddRange(LNewComments);
end;

end.
