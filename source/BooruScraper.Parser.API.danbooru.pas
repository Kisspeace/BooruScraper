unit BooruScraper.Parser.API.danbooru;

interface
uses
  Classes, Types, SysUtils, System.Generics.Collections,
  BooruScraper.Interfaces, BooruScraper.BaseTypes,
  BooruScraper.Parser.Utils, XSuperObject;

type

  TDanbooruAPIParser = Class(TBooruParser)
    protected
      class function DoParsePostsFromPage(const ASource: string): TBooruThumbAr; override;
      class function DoParsePostFromPage(const ASource: string): IBooruPost; override;
      class function ParsePostFromObject(A: ISuperObject): IBooruPost;
      class function DoParseCommentsFromPostPage(const ASource: string): TBooruCommentAr; override;
      class function ParseCommentFromObject(A: ISuperObject): IBooruComment;
      { -------------------- }
      class function ParseDate(AObj: ISuperObject; AKey: string): TDateTime;
  end;

implementation

{ TDanbooruAPIParser }

class function TDanbooruAPIParser.ParseCommentFromObject(
  A: ISuperObject): IBooruComment;
begin
  Result := TBooruCommentBase.Create;
  with Result do begin
    Id := A.I['id'];
    PostId := A.I['post_id'];
    CreatorId := A.I['creator_id'];
    Timestamp := ParseDate(A, 'created_at');
    Score := A.I['score'];
    Text := A.S['body'];
    IsDeleted := A.B['is_deleted'];
  end;
end;

class function TDanbooruAPIParser.DoParseCommentsFromPostPage(
  const ASource: string): TBooruCommentAr;
var
  LArray: ISuperArray;
  I: integer;
begin
  LArray := SA(ASource);
  SetLength(Result, LArray.Length);
  for I := 0 to LArray.Length - 1 do
    Result[I] := Self.ParseCommentFromObject(LArray.O[I]);
end;

class function TDanbooruAPIParser.ParseDate(AObj: ISuperObject;
  AKey: string): TDateTime;
var
  LTmp: string;
begin
  if (AObj.Null[AKey] = TMemberStatus.jAssigned) then begin
    LTmp := AObj.S[AKey];
    Result := StrToDatetime(LTmp, BOORU_TIME_FORMAT);
  end else Result := BOORU_NOTSET;
end;

class function TDanbooruAPIParser.ParsePostFromObject(
  A: ISuperObject): IBooruPost;

  function StrArToTags(const AAr: TArray<string>; ATagType: TBooruTagType): TBooruTagAr;
  var
    N: integer;
  begin
    SetLength(Result, Length(AAr));
    for N := 0 to High(AAr) do begin
      var LNewTag: IBooruTag := TBooruTagBase.Create;
      LNewTag.Value := AAr[N];
      LNewTag.Kind := ATagType;
      Result[N] := LNewTag;
    end;
  end;

  procedure AddTags(AKey: string; ATagType: TBooruTagType);
  var
    LTmp: string;
    LAr: TArray<string>;
  begin
    if (A.Null[AKey] = TMemberStatus.jAssigned) then begin
      LTmp := A.S[AKey];
      LAr := LTmp.Split([' '], TStringSplitOptions.ExcludeEmpty);
      Result.Tags.AddRange(StrArToTags(LAr, ATagType));
    end;
  end;

begin
  Result := TBooruPostBase.Create;
  with Result do begin
    Id := A.I['id'];
    CreatedAt := ParseDate(A, 'created_at');
    UploaderId := A.I['uploader_id'];
    Score := A.I['score'];
    SourceUrl := A.S['source'];
    Md5 := A.S['md5'];
    LastCommentBumpedAt := ParseDate(A, 'last_comment_bumped_at');
    Rating := A.S['rating'];
    Width := A.I['image_width'];
    Height := A.I['image_height'];
    FavCount := A.I['fav_count'];
    FileExt := A.S['file_ext'];
    LastNotedAt := ParseDate(A, 'last_noted_at');

    if (A.Null['parent_id'] = TMemberStatus.jAssigned) then
      ParentId := A.I['parent_id'];

    HasChildren := A.B['has_children'];

    if (A.Null['approver_id'] = TMemberStatus.jAssigned) then
      ApproverId := A.I['approver_id'];

    FileSize := A.I['file_size'];
    UpScore := A.I['up_score'];
    DownScore := A.I['down_score'];
    IsPending := A.B['is_pending'];
    IsDeleted := A.B['is_deleted'];
    IsFlagged := A.B['is_flagged'];
//    UpdatedAt :=
    IsBanned := A.B['is_banned'];
//    PixivId :=

//    if (A.Null['last_commented_at'] = TMemberStatus.jAssigned) then
//      LastCommentedAt := A.D['last_commented_at'];

//    HasActiveChildren :=
//    BitFlags :=
//    HasLarge :=
//    HasVisibleChildren :=
    AddTags('tag_string_character', TBooruTagType.TagCharacter);
    AddTags('tag_string_copyright', TBooruTagType.TagCopyright);
    AddTags('tag_string_artist', TBooruTagType.TagArtist);
    AddTags('tag_string_meta', TBooruTagType.TagMetadata);
    AddTags('tag_string_general', TBooruTagType.TagGeneral);

    ContentUrl := A.S['file_url'];
    SampleUrl := A.S['large_file_url'];
    Thumbnail := A.S['preview_file_url'];

  end;
end;

class function TDanbooruAPIParser.DoParsePostFromPage(
  const ASource: string): IBooruPost;
var
  LObj: ISuperObject;
begin
  LObj := SO(Asource);
  Result := Self.ParsePostFromObject(LObj);
end;

class function TDanbooruAPIParser.DoParsePostsFromPage(
  const ASource: string): TBooruThumbAr;
var
  LArray: ISuperArray;
  I: integer;
begin
  LArray := SA(ASource);
  SetLength(Result, LArray.Length);
  for I := 0 to LArray.Length - 1 do
    Result[I] := Self.ParsePostFromObject(LArray.O[I]);
end;

end.
