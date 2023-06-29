unit BooruScraper.Parser.API.TbibOrg;

interface
uses
  Classes, Types, SysUtils, System.Generics.Collections,
  BooruScraper.Interfaces, BooruScraper.BaseTypes, BooruScraper.Parser.Utils,
  HtmlParserEx, NetEncoding;

type

  TTbibOrgAPIParser = Class(TBooruParser)
    protected
      class function DoParsePostsFromPage(const ASource: string): TBooruThumbAr; override;
      class function DoParsePostFromNode(ANode: IHtmlElement): IBooruPost;
      class function DoParsePostFromPage(const ASource: string): IBooruPost; override;
      class function DoParseCommentsFromPostPage(const ASource: string): TBooruCommentAr; overload; override;
      class function DoParseCommentsFromPostPage(ASource: IHtmlElement): TBooruCommentAr; overload;
  End;

implementation

{ TTbibOrgAPIParser }

class function TTbibOrgAPIParser.DoParseCommentsFromPostPage(
  const ASource: string): TBooruCommentAr;
begin

end;

class function TTbibOrgAPIParser.DoParseCommentsFromPostPage(
  ASource: IHtmlElement): TBooruCommentAr;
begin

end;

class function TTbibOrgAPIParser.DoParsePostFromNode(
  ANode: IHtmlElement): IBooruPost;
var
  LTmp: string;
  LTags: TArray<string>;
  I: integer;
begin
  Result := TBooruPostBase.Create;
  with Result do begin
    Id := StrToInt(ANode.Attrs['id']);
    ContentUrl := ANode.Attrs['file_url'];
    SampleUrl := ANode.Attrs['sample_url'];
    Thumbnail := ANode.Attrs['preview_url'];
    Rating := ANode.Attrs['rating'];
//    Change := ANode.Attrs['change'];
    Md5 := ANode.Attrs['md5'];
    HasChildren := StrToBool(ANode.Attrs['has_children']);
    HasComments:= StrToBool(ANode.Attrs['has_comments']);
//    HasNotes := StrToBool(ANode.Attrs['has_notes']);
//    CreatedAt := StrToDateTime(ANode.Attrs['created_at']); { problems }
//    Status := ANode.Attrs['status'];
    SourceUrl := ANode.Attrs['source'];

    LTmp := Trim(ANode.Attrs['tags']);
    LTags := NormalizeTags(LTmp.Split([' '], TStringSplitOptions.ExcludeEmpty));
    for I := 0 to High(LTags) do begin
      var LNewTag: IBooruTag := TBooruTagBase.Create;
      LNewTag.Value := LTags[I];
      Result.Tags.Add(LNewTag);
    end;

    try
      UploaderId := StrToInt(ANode.Attrs['creator_id']);
    except

    end;

    try
      Score := StrToInt(ANode.Attrs['score']);
    except

    end;

    try
      ParentId := StrToInt(ANode.Attrs['parent_id']);
    except

    end;

    try
      Width := StrToInt(ANode.Attrs['width']);
      Height := StrToInt(ANode.Attrs['height']);
    except

    end;

    try
      SampleWidth := StrToInt(ANode.Attrs['sample_width']);
      SampleHeight := StrToInt(ANode.Attrs['sample_height']);
    except

    end;

    try
      PreviewWidth := StrToInt(ANode.Attrs['preview_width']);
      PreviewHeight := StrToInt(ANode.Attrs['preview_height']);
    except

    end;

  end;
end;

class function TTbibOrgAPIParser.DoParsePostFromPage(
  const ASource: string): IBooruPost;
var
  LItems: TBooruThumbAr;
begin
  LItems := Self.ParsePostsFromPage(ASource);
  if (Length(LItems) > 0) then
    Supports(Litems[0], IBooruPost, Result);
end;

class function TTbibOrgAPIParser.DoParsePostsFromPage(
  const ASource: string): TBooruThumbAr;
var
  LDoc: IHtmlElement;
  LPostsEl: IHtmlElement;
  LElement: IHtmlElement;
  I: integer;
begin
  Result := [];
  LDoc := ParserHtml(ASource);
  LPostsEl := FindXFirst(LDoc, '//posts');

  if Assigned(LPostsEl) then
  begin
    for I := 0 to LPostsEl.ChildrenCount - 1 do begin
      LElement := LPostsEl.Children[I];
      if (LElement.TagName = 'POST') then
        Result := Result + [Self.DoParsePostFromNode(LElement)];
    end;
  end;
end;

end.
