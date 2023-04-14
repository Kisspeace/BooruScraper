unit BooruScraper.Serialize.XSuperObject;

interface
uses
  System.SysUtils, Classes, Types, XSuperObject, System.Generics.Collections,
  BooruScraper.Interfaces, BooruScraper.BaseTypes;

type
  TJsonMom = Class
    public
      class function ToJsonAuto(AVal: IAssignAndClone): ISuperObject; overload;
      class function ToJson(AVal: IBooruThumb): ISuperObject; overload;
      class function ToJson(AVal: IBooruTag): ISuperObject; overload;
      class function ToJson(AVal: IBooruComment): ISuperObject; overload;
      class function ToJson(AVal: IBooruPost): ISuperObject; overload;
      { ------------------------------- }
      class function ToJson(AVal: TBooruTagAr): ISuperArray; overload;
      class function ToJson(AVal: TBooruCommentAr): ISuperArray; overload;
      class function ToJson(AVal: TBooruPostAr): ISuperArray; overload;
      { ------------------------------- }
      class function FromJsonIBooruThumb(A: ISuperObject): IBooruThumb;
      class function FromJsonIBooruTag(A: ISuperObject): IBooruTag;
      class function FromJsonIBooruComment(A: ISuperObject): IBooruComment;
      class function FromJsonIBooruPost(A: ISuperObject): IBooruPost;
      { ------------------------------- }
      class function FromJsonIBooruThumbAr(A: ISuperArray): TBooruThumbAr;
      class function FromJsonIBooruTagAr(A: ISuperArray): TBooruTagAr;
      class function FromJsonIBooruCommentAr(A: ISuperArray): TBooruCommentAr;
      class function FromJsonIBooruPostAr(A: ISuperArray): TBooruPostAr;
  End;

implementation

class function TJsonMom.ToJson(AVal: IBooruThumb): ISuperObject;
var
  LIdStr: IIdString;
begin
  Result := SO();
  with Result do begin
    I['Id'] := AVal.Id;
    S['Thumbnail'] := AVal.Thumbnail;
    A['TagsValues'] := TJSON.SuperObject<TArray<string>>(AVal.TagsValues).AsArray;

    { v0.2.0 }
    if Supports(AVal, IIdString, LIdStr) then
      S['IdStr'] := LIdStr.Id;
  end;
end;

class function TJsonMom.ToJson(AVal: IBooruTag): ISuperObject;
begin
  Result := SO();
  with Result do begin
    S['Value'] := AVal.Value;
    I['Kind'] := Ord(AVal.Kind);
    I['Count'] := AVal.Count;
  end;
end;

class function TJsonMom.ToJson(AVal: IBooruComment): ISuperObject;
begin
  Result := SO();
  with Result do begin
    I['Id'] := AVal.Id;
    S['Username'] := AVal.Username;
    D['Timestamp'] := AVal.Timestamp;
    S['Text'] := AVal.Text;
    I['Score'] := AVal.Score;

    I['PostId'] := AVal.PostId;
    I['CreatorId'] := AVal.CreatorId;
    B['IsDeleted'] := AVal.IsDeleted;
  end;
end;

class function TJsonMom.ToJson(AVal: IBooruPost): ISuperObject;
var
  LIdStr: IIdString;
begin
  Result := SO();
  with Result do begin
    I['Id'] := AVal.Id;
    S['Thumbnail'] := AVal.Thumbnail;
    S['ContentUrl'] := AVal.ContentUrl;
    S['SampleUrl'] := AVal.SampleUrl;
    I['Score'] := AVal.Score;
    S['Uploader'] := AVal.Uploader;
    A['Tags'] := TJsonMom.ToJson(AVal.Tags.ToArray);
    A['Comments'] := TJsonMom.ToJson(AVal.Comments.ToArray);

    I['UploaderId'] := AVal.UploaderId;
    S['Md5'] := AVal.Md5;
    I['Height'] := AVal.Height;
    I['Width'] := AVal.Width;
    S['SourceUrl'] := AVal.SourceUrl;
    S['Rating'] := AVal.Rating;
    I['SampleHeight'] := AVal.SampleHeight;
    I['SampleWidth'] := AVal.SampleWidth;
    I['PreviewHeight'] := AVal.PreviewHeight;
    I['PreviewWidth'] := AVal.PreviewWidth;
    B['HasChildren'] := AVal.HasChildren;
    B['IsPending'] := AVal.IsPending;
    B['IsDeleted'] := AVal.IsDeleted;
    B['IsBanned'] := AVal.IsBanned;
    B['IsFlagged'] := AVal.IsFlagged;
    B['HasComments'] := AVal.HasComments;
    B['HasNotes'] := AVal.HasNotes;
    D['CreatedAt'] := AVal.CreatedAt;
    I['FileSize'] := AVal.FileSize;
    S['FileExt'] := AVal.FileExt;
    I['ParentId'] := AVal.ParentId;
    I['FavCount'] := AVal.FavCount;
    D['LastCommentBumpedAt'] := AVal.LastCommentBumpedAt;
    D['LastNotedAt'] := AVal.LastNotedAt;
    I['ApproverId'] := AVal.ApproverId;
    I['UpScore'] := AVal.UpScore;
    I['DownScore'] := AVal.DownScore;

    { v0.2.0 }
    if Supports(AVal, IIdString, LIdStr) then
      S['IdStr'] := LIdStr.Id;
  end;
end;

class function TJsonMom.ToJson(AVal: TBooruTagAr): ISuperArray;
var
  I: integer;
begin
  Result := SA();
  for I := 0 to High(AVal) do
    Result.Add(Self.ToJson(AVal[I]));
end;

class function TJsonMom.FromJsonIBooruComment(A: ISuperObject): IBooruComment;
begin
  Result := TJSON.Parse<TBooruCommentBase>(A);
end;

class function TJsonMom.FromJsonIBooruCommentAr(A: ISuperArray): TBooruCommentAr;
var
  I: integer;
begin
  for I := 0 to A.Length - 1 do
    Result := Result + [Self.FromJsonIBooruComment(A.O[I])];
end;

class function TJsonMom.FromJsonIBooruPost(A: ISuperObject): IBooruPost;
var
  LIdStr: IIdString;
begin
  if A.Null['IdStr'] = TMemberStatus.jAssigned then
    Result := TBooruPostWithStrId.Create
  else
    Result := TBooruPostBase.Create;

  with Result do begin
    Id := A.I['Id'];
    Thumbnail := A.S['Thumbnail'];
    ContentUrl := A.S['ContentUrl'];
    SampleUrl := A.S['SampleUrl'];
    Score := A.I['Score'];
    Uploader := A.S['Uploader'];

    if A.Null['Md5'] = TMemberStatus.jAssigned then
    begin
      UploaderId := A.I['UploaderId'];
      Md5 := A.S['Md5'];
      Height := A.I['Height'];
      Width := A.I['Width'];
      SourceUrl := A.S['SourceUrl'];
      Rating := A.S['Rating'];
      SampleHeight := A.I['SampleHeight'];
      SampleWidth := A.I['SampleWidth'];
      PreviewHeight := A.I['PreviewHeight'];
      PreviewWidth := A.I['PreviewWidth'];
      HasChildren := A.B['HasChildren'];
      IsPending := A.B['IsPending'];
      IsFlagged := A.B['IsFlagged'];
      IsBanned := A.B['IsBanned'];
      IsDeleted := A.B['IsDeleted'];
      HasComments := A.B['HasComments'];
      HasNotes := A.B['HasNotes'];
      CreatedAt := A.D['CreatedAt'];
      FileSize := A.I['FileSize'];
      FileExt := A.S['FileExt'];
      ParentId := A.I['ParentId'];
      FavCount := A.I['FavCount'];
      LastCommentBumpedAt := A.D['LastCommentBumpedAt'];
      LastNotedAt := A.D['LastNotedAt'];
      ApproverId := A.I['ApproverId'];
      UpScore := A.I['UpScore'];
      DownScore := A.I['DownScore'];
    end;

    if A.Null['Tags'] = TMemberStatus.jAssigned then
      Tags.AddRange(TJsonMom.FromJsonIBooruTagAr(A.A['Tags']));

    if A.Null['Comments'] = TMemberStatus.jAssigned then
      Comments.AddRange(TJsonMom.FromJsonIBooruCommentAr(A.A['Comments']));

    { v0.2.0 }
    if Supports(Result, IIdString, LIdStr) then
      LIdStr.Id := A.S['IdStr'];
  end;
end;

class function TJsonMom.FromJsonIBooruPostAr(A: ISuperArray): TBooruPostAr;
var
  I: integer;
begin
  for I := 0 to A.Length - 1 do
    Result := Result + [Self.FromJsonIBooruPost(A.O[I])];
end;

class function TJsonMom.FromJsonIBooruTag(A: ISuperObject): IBooruTag;
begin
  Result := TJSON.Parse<TBooruTagBase>(A);
end;

class function TJsonMom.FromJsonIBooruTagAr(A: ISuperArray): TBooruTagAr;
var
  I: integer;
begin
  for I := 0 to A.Length - 1 do
    Result := Result + [Self.FromJsonIBooruTag(A.O[I])];
end;

class function TJsonMom.FromJsonIBooruThumb(A: ISuperObject): IBooruThumb;
var
  LAr: ISuperArray;
  LIdStr: IIdString;
begin
  if A.Null['IdStr'] = TMemberStatus.jAssigned then
    Result := TBooruThumbWithStrId.Create
  else
    Result := TBooruThumbBase.Create;

  with Result do begin
    Id := A.I['Id'];
    Thumbnail := A.S['Thumbnail'];

    if A.Null['TagsValues'] = TMemberStatus.jAssigned then
    begin
      LAr := A.A['TagsValues'];
      TagsValues := TJson.Parse<TArray<string>>(LAr);
    end;

    { v0.2.0 }
    if Supports(Result, IIdString, LIdStr) then
      LIdStr.Id := A.S['IdStr'];
  end;
end;

class function TJsonMom.FromJsonIBooruThumbAr(A: ISuperArray): TBooruThumbAr;
var
  I: integer;
begin
  for I := 0 to A.Length - 1 do
    Result := Result + [Self.FromJsonIBooruThumb(A.O[I])];
end;

class function TJsonMom.ToJson(AVal: TBooruPostAr): ISuperArray;
var
  I: integer;
begin
  Result := SA();
  for I := 0 to High(AVal) do
    Result.Add(Self.ToJson(AVal[I]));
end;

class function TJsonMom.ToJsonAuto(AVal: IAssignAndClone): ISuperObject;
var
  LPost: IBooruPost;
  LThumb: IBooruThumb;
  LTag: IBooruTag;
  LComment: IBooruComment;
begin
  if Supports(AVal, IBooruPost, LPost) then
    Result := Self.ToJson(LPost)
  else if Supports(AVal, IBooruThumb, LThumb) then
    Result := Self.ToJson(LThumb)
  else if Supports(AVal, IBooruTag, LTag) then
    Result := Self.ToJson(LTag)
  else if Supports(AVal, IBooruComment, LComment) then
    Result := Self.ToJson(LComment);
end;

class function TJsonMom.ToJson(AVal: TBooruCommentAr): ISuperArray;
var
  I: integer;
begin
  Result := SA();
  for I := 0 to High(AVal) do
    Result.Add(Self.ToJson(AVal[I]));
end;

end.
