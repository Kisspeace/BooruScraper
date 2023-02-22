unit BooruScraper.Parser.rule34PahealNet;

interface
uses
  Classes, Types, SysUtils, System.Generics.Collections,
  BooruScraper.Interfaces, BooruScraper.BaseTypes, BooruScraper.Parser.Utils,
  HtmlParserEx, NetEncoding;

type

  TRule34pahealnetParser = Class(TBooruParser)
    public
      class function ParsePostsFromPage(const ASource: string): TBooruThumbAr; override;
      class function ParsePostFromPage(const ASource: string): IBooruPost; override;
      class function ParseCommentsFromPostPage(const ASource: string): TBooruCommentAr; overload; override;
      class function ParseCommentsFromPostPage(ASource: IHtmlElement): TBooruCommentAr; overload;
  End;

implementation

{ TRule34pahealnetParser }

class function TRule34pahealnetParser.ParseCommentsFromPostPage(
  const ASource: string): TBooruCommentAr;
var
  LDoc: IHtmlElement;
begin
  LDoc := ParserHtml(ASource);
  Result := ParseCommentsFromPostPage(LDoc);
end;

class function TRule34pahealnetParser.ParseCommentsFromPostPage(
  ASource: IHtmlElement): TBooruCommentAr;
var
  LTmp, LTmp2: IHtmlElement;
  LStr: string;
begin
  Result := [];
  var LCommentList := FindXById(ASource, 'comment-list-image');
  if Assigned(LCommentList) then begin

    var LComments := FindAllByClass(LCommentList, 'comment');
    for LTmp in LComments do begin
      var LNewComment: IBooruComment := TBooruCommentBase.Create;

      { Comment Id }
      try
        LStr := LTmp.Attributes['id'];
        LStr := Copy(LStr, Low(LStr) + 1, Length(LStr)); { like c6952706 }
        LNewComment.Id := StrToInt64(LStr);
      except

      end;

      { Comment timestamp }
      try
        LTmp2 := FindXFirst(LTmp, '//time');
        if Assigned(LTmp2) then
          LNewComment.Timestamp := StrToDatetime(LTmp2.Attrs['datetime'], BOORU_TIME_FORMAT);
      except

      end;

      { Comment author username }
      LTmp2 := FindXByClass(LTmp, 'username');
      if Assigned(LTmp2) then
        LNewComment.Username := Trim(LTmp2.Text);

      { Comment text }
      LStr := GetAfter(LTmp.Text, LNewComment.Username + ':');
      LNewComment.Text := Trim(LStr);

      if not ((LNewComment.Id = -1) or (LnewComment.Text.IsEmpty)) then
        Result := Result + [LNewComment];
    end;

  end;
end;

class function TRule34pahealnetParser.ParsePostFromPage(
  const ASource: string): IBooruPost;
var
  LDoc: IHtmlElement;
  I: integer;
  LTmps: IHtmlElementList;
  LTmp, LTmp2: IHtmlElement;
  LStr, LStr2: string;
begin
  Result := TBooruPostBase.Create;
  LDoc := ParserHtml(ASource);

  var LNav := FindXFirst(LDoc, '//nav');
  if Assigned(LNav) then begin

    { Post Id }
    LTmp := FindXByClass(LNav, 'shm-toggler');
    if Assigned(LTmp) then begin
      LStr := Trim(LTmp.Text);
      LStr := Trim(GetAfter(LStr, 'Post'));
      Result.Id := StrToInt64(LStr);
    end;

    { tags }
    var LTbody := FindXFirst(LNav, '//tbody');
    if Assigned(LTBody) then begin

      for I := 0 to LTbody.ChildrenCount - 1 do begin

        LTmp := LTbody.Children[I];

        var LNewTag: IBooruTag := TBooruTagBase.Create;
        LNewTag.Kind := TBooruTagType.TagGeneral; { UNKNOWN }

        { Tag name }
        LTmp2 := FindXByClass(LTmp, 'tag_name');
        if Assigned(LTmp2) then
          LNewTag.Value := Trim(LTmp2.Text);

        { Tag counter }
        LTmp2 := FindXByClass(LTmp, 'tag_count');
        if Assigned(LTmp2) then begin
          LStr := Trim(LTmp2.Text);
          LNewTag.Count := StrToInt(LStr);
        end;

        Result.Tags.Add(LNewTag);
      end;

    end;

  end;

  { Content Url }
  LTmp := FindXById(LDoc, 'main_image');
  if Assigned(LTmp) then
    Result.ContentUrl := LTmp.Attributes['src'];

  var LInfo := FindXByClass(LDoc, 'image_info');
  if Assigned(LInfo) then begin

    { Uploader username }
    LTmp := FindXByClass(LInfo, 'username');
    if Assigned(LTmp) then
      Result.Uploader := Trim(LTmp.Text);

  end;

  Result.Comments.AddRange(ParseCommentsFromPostPage(LDoc));
end;

class function TRule34pahealnetParser.ParsePostsFromPage(
  const ASource: string): TBooruThumbAr;
var
  LDoc: IHtmlElement;
  LThumb: IHtmlElement;
begin
  LDoc := ParserHtml(ASource);
  var LThumbContainer := FindXByClass(LDoc, 'shm-image-list');

  if Assigned(LThumbContainer) then begin

    var LThumbs := FindAllByClass(LThumbContainer, 'shm-thumb');
    for LThumb in LThumbs do begin
      var LRes: IBooruThumb := TBooruThumbBase.Create;

      { Id }
      var LTmp: string := LThumb.Attributes['data-post-id'];
      LRes.Id := StrToInt64(LTmp);

      { Tags }
      LTmp := Trim(LThumb.Attributes['data-tags']);
      LRes.TagsValues := NormalizeTags(LTmp.Split([' '], TStringSplitOptions.ExcludeEmpty));

      { Thumbnail }
      var LImgs := LThumb.FindX('//img');
      if (LImgs.Count > 0) then begin
        var LPrev := LImgs.Items[0];

        { Thumbnail URL }
        LRes.Thumbnail := LPrev.Attributes['src'];

      end;

      Result := Result + [LRes];

    end;

  end;
end;

end.
