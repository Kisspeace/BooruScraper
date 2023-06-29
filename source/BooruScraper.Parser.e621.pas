unit BooruScraper.Parser.e621;

interface
uses
  Classes, Types, SysUtils, System.Generics.Collections,
  BooruScraper.Interfaces, BooruScraper.BaseTypes, BooruScraper.Parser.Utils,
  HtmlParserEx, NetEncoding;

type

  Te621Parser = Class(TBooruParser)
    protected
      class procedure ParseDefValues(ANode: IHtmlElement; const APost: IBooruPost);
      class function DoParsePostsFromPage(const ASource: string): TBooruThumbAr; override;
      class function DoParsePostFromPage(const ASource: string): IBooruPost; override;
      class function DoParseCommentsFromPostPage(const ASource: string): TBooruCommentAr; overload; override;
      class function DoParseCommentsFromPostPage(ASource: IHtmlElement): TBooruCommentAr; overload;
  End;

implementation

{ Te621Parser }

class function Te621Parser.DoParseCommentsFromPostPage(
  const ASource: string): TBooruCommentAr;
var
  LDoc: IHtmlElement;
  I: integer;
begin
  Result := [];
  LDoc := ParserHtml(ASource);
  Result := DoParseCommentsFromPostPage(LDoc);
end;

class function Te621Parser.DoParseCommentsFromPostPage(
  ASource: IHtmlElement): TBooruCommentAr;
var
  I: integer;
begin
  Result := [];
  try

  except
    On E: Exception do
      if not HandleExcept(E, 'ParseCommentsFromPostPage') then raise;
  end;
end;

class procedure Te621Parser.ParseDefValues(ANode: IHtmlElement;
  const APost: IBooruPost);
var
  LAttrs: TSAttrReader;
begin
  LAttrs := TSAttrReader.Create(ANode);
  { Id }
  APost.Id := LAttrs.Int64('data-id');

  { Uploader id }
  APost.UploaderId := LAttrs.Int64('data-uploader-id');

  { Uploader username }
  APost.Uploader := LAttrs.Str('data-uploader');

  { File extension }
  APost.FileExt := LAttrs.Str('data-file-ext');

  { Score }
  APost.Score := LAttrs.Int('data-score');

  { Favorite counter }
  APost.FavCount := LAttrs.Int('data-fav-count');

  { Full sized content url }
  APost.ContentUrl := LAttrs.Str('data-file-url');

  { Sample url }
  APost.SampleUrl := LAttrs.Str('data-large-file-url');

  { Thumbnail }
  APost.Thumbnail := LAttrs.Str('data-preview-file-url');

  { Content width and height }
  APost.Width := LAttrs.Int('data-width');
  APost.Height := LAttrs.Int('data-height');
end;

class function Te621Parser.DoParsePostFromPage(const ASource: string): IBooruPost;
var
  LDoc: IHtmlElement;
  LImg: IHtmlElement;
  LTagList: IHtmlElement;
  LTagsList: IHtmlElementList;

  procedure ParseTags(ACategoryNum: string; AType: TBooruTagType);
  var
    LTmp: IHtmlElement;
    I: integer;
  begin
    LTagsList := FindAllByClass(LTagList, 'category-' + ACategoryNum);
    for I := 0 to LTagsList.Count - 1 do
    begin
      var LTag: IBooruTag := TBooruTagBase.Create;
      LTag.Kind := AType;

      { Tag Value }
      LTmp := FindXByClass(LTagsList[I], 'search-tag');
      if Assigned(LTmp) then
        LTag.Value := NormalizeTag(LTmp.Text);

      { Tag counter }
      LTmp := FindXByClass(LTagsList[I], 'post-count');
      if Assigned(LTmp) then
        LTag.Count := StrToInt64(LTmp.Attributes['data-count']);

      Result.Tags.Add(LTag);
    end;
  end;

begin
  Result := TBooruPostBase.Create;
  LDoc := ParserHtml(ASource);
  LImg := FindXById(LDoc, 'image-container');

  if Assigned(LImg) then
    ParseDefValues(LImg, Result);

  LTagList := FindXById(LDoc, 'tag-list');
  if Assigned(LTagList) then
  begin
    ParseTags('0', TagGeneral);
    ParseTags('1', TagArtist);
    ParseTags('3', TagCopyright);
    ParseTags('4', TagCharacter);
    ParseTags('5', TagSpecies);
    ParseTags('6', TagInvalid);
    ParseTags('7', TagMetadata);
    ParseTags('8', TagLore);
  end;
end;

class function Te621Parser.DoParsePostsFromPage(
  const ASource: string): TBooruThumbAr;
var
  LDoc: IHtmlElement;
  LImgList: IHtmlElement;
  LImages: IHtmlElementList;
  LTags: TBooruTagAr;
  LTmp: string;
  I: integer;
begin
  Result := [];
  LDoc := ParserHtml(ASource);
  LImgList := FindXById(LDoc, 'posts-container');
  if Assigned(LImgList) then
  begin
    LImages := FindAllByClass(LImgList, 'post-preview');
    for I := 0 to LImages.Count - 1 do
    begin
      var LThumb: IBooruPost := TBooruPostBase.Create;
      ParseDefValues(LImages[I], LThumb);

      { Tags }
      LTags := ParseTagsT(LImages[I].Attributes['data-tags']);
      LThumb.Tags.AddRange(LTags);

      Result := Result + [LThumb];
    end;
  end;
end;

end.
