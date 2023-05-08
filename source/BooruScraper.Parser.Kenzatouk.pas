unit BooruScraper.Parser.Kenzatouk;

interface
uses
  Classes, Types, SysUtils, System.Generics.Collections,
  BooruScraper.Interfaces, BooruScraper.BaseTypes, BooruScraper.Parser.Utils,
  HtmlParserEx, NetEncoding, BooruScraper.Exceptions;

type

  TKenzatoUkParser = Class(TBooruParser)
    public
      class function ParsePostsFromPage(const ASource: string): TBooruThumbAr; override;
      class function ParsePostFromPage(const ASource: string): IBooruPost; override;
      class function ParseCommentsFromPostPage(const ASource: string): TBooruCommentAr; overload; override;
      class function ParseCommentsFromPostPage(ASource: IHtmlElement): TBooruCommentAr; overload;
  End;

implementation

{ TKenzatoUkParser }

class function TKenzatoUkParser.ParseCommentsFromPostPage(
  const ASource: string): TBooruCommentAr;
begin

end;

class function TKenzatoUkParser.ParseCommentsFromPostPage(
  ASource: IHtmlElement): TBooruCommentAr;
begin

end;

class function TKenzatoUkParser.ParsePostFromPage(
  const ASource: string): IBooruPost;
var
  LDoc: IHtmlElement;
  LImageCont: IHtmlElement;
  LImg: IHtmlElement;
  LHead: IHtmlElement;
  LStr: string;
begin
  try
    LDoc := ParserHtml(ASource);
    LImageCont := FindXById(LDoc, 'image-viewer-container');

    if Assigned(LImageCont) then
    begin
      Result := TBooruPostWithStrId.Create;
      LImg := FindXFirst(LImageCont, '//img');
      if not Assigned(LImg) then Exit;

      { Content URL }
      Result.Thumbnail := LImg.Attrs['src'];
      Result.ContentUrl := Result.Thumbnail;

      { Post Id }
      LHead := FindXFirst(LDoc, '//head');
      if Assigned(LHead) then begin
        var LUrlProp := FindMetaProperty(LHead, 'og:url');
        if Assigned(LUrlProp) then begin
          LStr := LUrlProp.Attrs['content'];
          LStr := Trim(GetAfter(LStr, 'image/'));
          (Result as IIdString).Id := LStr;
        end;
      end;
    end;
  except
    On E: Exception do
      if not HandleExcept(E, 'ParsePostFromPage') then raise;
  end;
end;

class function TKenzatoUkParser.ParsePostsFromPage(
  const ASource: string): TBooruThumbAr;
var
  LDoc: IHtmlElement;
  LThumbContainer: IHtmlElement;
  LThumb: IHtmlElement;
  LThumbs: IHtmlElementList;
  LTmp: IHtmlElement;
  LStr: string;
  I: integer;
begin
  try
    LDoc := ParserHtml(ASource);
    LThumbContainer := FindXById(LDoc, 'tabbed-content-group');

    if Assigned(LThumbContainer) then
    begin
      LThumbs := FindAllByClass(LThumbContainer, 'list-item');
      for I := 0 to LThumbs.Count - 1 do
      begin
        LThumb := LThumbs[I];

        { Id (string) }
        LStr := LThumb.Attrs['data-id'];
        if LStr.IsEmpty then continue;
        var LNewItem: IBooruPost := TBooruPostWithStrId.Create;
        (LNewItem as IIdString).Id := LStr;

        { Thumbnail (also Content URL) }
        LTmp := FindXByClass(LThumb, 'image-container');
        if Assigned(LTmp) then begin
          LTmp := FindXFirst(LTmp, '//img');
          if Assigned(LTmp) then
            LNewItem.Thumbnail := LTmp.Attrs['src'];
            LNewItem.ContentUrl := LNewItem.Thumbnail;
        end;

        Result := Result + [LNewItem];
      end;
    end;
  except
    On E: Exception do
      if not HandleExcept(E, 'ParsePostsFromPage') then raise;
  end;
end;

end.
