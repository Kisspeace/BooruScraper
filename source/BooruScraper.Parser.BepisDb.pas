unit BooruScraper.Parser.BepisDb;

interface
uses
  Classes, Types, SysUtils, System.Generics.Collections,
  BooruScraper.Interfaces, BooruScraper.BaseTypes, BooruScraper.Parser.Utils,
  HtmlParserEx, NetEncoding, BooruScraper.Urls;

type

  TBepisDbParser = Class(TBooruParser)
    private
      const URL_FIX_HOST = DBBEPISMOE_URL;
      class procedure ParseTagsAndThumbnail(AElement: IHtmlElement; AItem: IBooruPost);
    public
      class function ParsePostsFromPage(const ASource: string): TBooruThumbAr; override;
      class function ParsePostFromPage(const ASource: string): IBooruPost; override;
      class function ParseCommentsFromPostPage(const ASource: string): TBooruCommentAr; overload; override;
      class function ParseCommentsFromPostPage(ASource: IHtmlElement): TBooruCommentAr; overload;
  End;

implementation

{ TBepisDbParser }

class function TBepisDbParser.ParseCommentsFromPostPage(
  const ASource: string): TBooruCommentAr;
begin

end;

class function TBepisDbParser.ParseCommentsFromPostPage(
  ASource: IHtmlElement): TBooruCommentAr;
begin

end;

class function TBepisDbParser.ParsePostFromPage(
  const ASource: string): IBooruPost;
var
  LDoc: IHtmlElement;
  LHead: IHtmlElement;
  LThumb: IHtmlElement;
  LStr: string;
begin
  LDoc := ParserHtml(ASource);
  LThumb := FindXById(LDoc, 'thumbnail-container');
  if Assigned(LThumb) then
  begin
    Result := TBooruPostBase.Create;
    ParseTagsAndThumbnail(LThumb, Result);

    { Post Id }
    LHead := FindXFirst(LDoc, '//head');
    if Assigned(LHead) then begin
      var LUrlProp := FindMetaProperty(LHead, 'og:url');
      if Assigned(LUrlProp) then begin
        LStr := LUrlProp.Attrs['content'];
        LStr := Trim(GetAfter(LStr, 'view/'));
        Result.Id := StrToInt64(LStr);
      end;
    end;

    { Content URL - Playcard }
    var LBtnDownload := FindXByClass(LDoc, 'btn-primary');
    if Assigned(LBtnDownload) then
      Result.ContentUrl := URL_FIX_HOST + LBtnDownload.Attrs['href'];
  end;
end;

class function TBepisDbParser.ParsePostsFromPage(
  const ASource: string): TBooruThumbAr;
var
  LDoc: IHtmlElement;
  LThumbContainer: IHtmlElement;
  LThumb: IHtmlElement;
  LThumbs: IHtmlElementList;
  LTmp: IHtmlElement;
  LStr: string;
  I, N: integer;
begin
  LDoc := ParserHtml(ASource);
  LThumbContainer := FindXById(LDoc, 'inner-card-body');

  if Assigned(LThumbContainer) then
  begin
    LThumbs := FindAllByClass(LDoc, 'card-block');
    for I := 0 to LThumbs.Count - 1 do
    begin
      LThumb := LThumbs[I];
      LTmp := FindXFirst(LThumb, '//a');

      if Assigned(LTmp) then begin
        var LItem: IBooruPost := TBooruPostBase.Create;

        { Item id }
        LStr := LTmp.Attrs['href'];
        LStr := Trim(GetAfter(LStr, 'view/'));
        LItem.Id := StrToInt64(LStr);

        ParseTagsAndThumbnail(LThumb, LItem);

        { Content URL - Playcard }
        var LBtnDownload := FindXByClass(LThumb, 'btn-primary');
        if Assigned(LBtnDownload) then
          LItem.ContentUrl := URL_FIX_HOST + LBtnDownload.Attrs['href'];

        Result := Result + [LItem];
      end;
    end;
  end;
end;

class procedure TBepisDbParser.ParseTagsAndThumbnail(AElement: IHtmlElement;
  AItem: IBooruPost);
var
  LStr: string;
  I: integer;
const
  TAGS_BOUND = char(#10) + char(#10);
begin
  var LPicture := FindXFirst(AElement, '//picture');
  if Assigned(LPicture) then begin

    { Tags }
    LStr := LPicture.Attrs['title'];
    LStr := GetBetween(LStr, TAGS_BOUND, TAGS_BOUND); //FIXME
//          Writeln(QuotedStr(LStr));
    var LTagS: TArray<String>;
    LTagS := NormalizeTags(LStr.Split([' '], TStringSplitOptions.ExcludeEmpty));

    for I := Low(LTagS) to High(LTagS) do
    begin
      var LNewTag: IBooruTag := TBooruTagBase.Create;
      LNewTag.Value := LTagS[I];
      LNewTag.Kind := TBooruTagType.TagGeneral;
      AItem.Tags.Add(LNewTag);
    end;

    { Thumbnail }
    var LImg := FindXFirst(LPicture, '//img');
    if Assigned(LImg) then
      AItem.Thumbnail := URL_FIX_HOST + LImg.Attrs['src'];
  end;
end;

end.
