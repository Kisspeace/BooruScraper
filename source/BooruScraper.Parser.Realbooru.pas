unit BooruScraper.Parser.Realbooru;

interface
uses
  Classes, Types, SysUtils, System.Generics.Collections,
  BooruScraper.Interfaces, BooruScraper.BaseTypes, BooruScraper.Parser.Utils,
  HtmlParserEx, NetEncoding;

type

  TRealbooruParser = Class(TBooruParser)
    public
      class function ParsePostsFromPage(const ASource: string): TBooruThumbAr; override;
      class function ParsePostFromPage(const ASource: string): IBooruPost; override;
      class function ParseCommentsFromPostPage(const ASource: string): TBooruCommentAr; overload; override;
      class function ParseCommentsFromPostPage(ASource: IHtmlElement): TBooruCommentAr; overload;
  End;

implementation

{ TRealbooruParser }

class function TRealbooruParser.ParseCommentsFromPostPage(
  const ASource: string): TBooruCommentAr;
begin

end;

class function TRealbooruParser.ParseCommentsFromPostPage(
  ASource: IHtmlElement): TBooruCommentAr;
begin

end;

class function TRealbooruParser.ParsePostFromPage(
  const ASource: string): IBooruPost;
var
  LDoc: IHtmlElement;
  LImageContainer: IHtmlElement;
  I: integer;

  function _GetTagTypeByClass(AClass: string): TBooruTagType;
  begin
    if AClass.Contains('tag-type-general') then
      Result := TagGeneral
    else if AClass.Contains('copyright') then
      Result := TagCopyright
    else if AClass.Contains('character') then
      Result := TagCharacter
    else if AClass.Contains('metadata') then
      Result := TagMetadata
    else if AClass.Contains('model') then
      Result := TagArtist
    else
      Result := TagGeneral;
  end;

begin
  Result := TBooruPostBase.Create;
  LDoc := ParserHtml(ASource);
  LImageContainer := FindXByClass(LDoc, 'imageContainer');
  if Assigned(LImageContainer) then begin

    { ContentUrl (image) }
    var LImage := FindXById(LImageContainer, 'image');
    if Assigned(LImage) then begin

      Result.ContentUrl := LImage.Attributes['src'];

    end else begin

      { ContentUrl (video) }
      var LVid := FindXById(LImageContainer, 'gelcomVideoPlayer');
      if Assigned(LVid) then begin
        var LSource := LVid.FindX('//source');
        if LSource.Count > 0 then
          Result.ContentUrl := LSource[0].Attributes['src'];
      end;

    end;

    { Tags }
    var LTagContainer := FindXById(LImageContainer, 'tagLink');
    if Assigned(LTagContainer) then begin

      var LTags := LTagContainer.FindX('//a');

      for I := 0 to LTags.Count - 1 do begin
        var LTag := LTags.Items[I];

        if (LTag.Attributes['class'] = '') then
          continue;

        var LNewTag: IBooruTag := TBooruTagBase.Create;

        LNewTag.Kind := _GetTagTypeByClass(LTag.Attributes['class']);
        LNewTag.Value := NormalizeTag(LTag.Text);
        Result.Tags.Add(LNewTag);

      end;

    end;

    { Comments }
    /// Maybe soon.

  end;
end;

class function TRealbooruParser.ParsePostsFromPage(
  const ASource: string): TBooruThumbAr;
var
  LDoc: IHtmlElement;
  I: integer;
begin
  LDoc := ParserHtml(ASource);
  var LThumbContainer := FindXByClass(LDoc, 'items');
  if Assigned(LThumbContainer) then begin

     var LThumbs := FindAllByClass(LThumbContainer, 'col thumb');
    for I := 0 to LThumbs.Count - 1 do begin
      var LThumb := LThumbs[I];
      var LRes: IBooruThumb := TBooruThumbBase.Create;

      { Id }
      var LTmp: string := LThumb.Attributes['id'];
      LTmp := Copy(LTmp, Low(LTmp) + 1, Length(LTmp)); { like p83455 }
      LRes.Id := StrToInt64(LTmp);

      { Thumbnail }
      var LPrev := LThumb.FindX('//img').Items[0];
      if Assigned(LPrev) then begin

        { Thumbnail URL }
        LRes.Thumbnail := LPrev.Attributes['src'];

        { Tags }
        LTmp := Trim(LPrev.Attributes['title']);
        LRes.TagsValues := NormalizeTags(LTmp.Split([', '], TStringSplitOptions.ExcludeEmpty));

      end;

      Result := Result + [LRes];

    end;

  end;
end;

end.
