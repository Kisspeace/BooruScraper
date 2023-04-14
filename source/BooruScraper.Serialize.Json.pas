unit BooruScraper.Serialize.Json;

interface
uses
  Classes, SysUtils, System.JSON, System.Generics.Collections,
  BooruScraper.Interfaces, BooruScraper.BaseTypes, DateUtils;

type

  TJsonMom = Class
    public
      class function ToJsonAuto(AVal: IAssignAndClone): TJsonObject; overload;
      class function ToJson(AVal: IBooruThumb): TJsonObject; overload;
      class function ToJson(AVal: IBooruTag): TJsonObject; overload;
      class function ToJson(AVal: IBooruComment): TJsonObject; overload;
      class function ToJson(AVal: IBooruPost): TJsonObject; overload;
      { ------------------------------- }
      class function ToJson(AVal: TBooruTagAr): TJsonArray; overload;
      class function ToJson(AVal: TBooruCommentAr): TJsonArray; overload;
      class function ToJson(AVal: TBooruPostAr): TJsonArray; overload;
      { ------------------------------- }
      class function FromJsonIBooruThumb(A: TJsonObject): IBooruThumb;
      class function FromJsonIBooruTag(A: TJsonObject): IBooruTag;
      class function FromJsonIBooruComment(A: TJsonObject): IBooruComment;
      class function FromJsonIBooruPost(A: TJsonObject): IBooruPost;
      { ------------------------------- }
      class function FromJsonIBooruThumbAr(A: TJsonArray): TBooruThumbAr;
      class function FromJsonIBooruTagAr(A: TJsonArray): TBooruTagAr;
      class function FromJsonIBooruCommentAr(A: TJsonArray): TBooruCommentAr;
      class function FromJsonIBooruPostAr(A: TJsonArray): TBooruPostAr;
      { ------------------------------- }
      class function ToJsonAr(const Ar: TArray<string>): TJsonArray;
      class function FromJsonAr(A: TJsonArray): TArray<string>;
  End;

implementation

{ TJsonMom }

class function TJsonMom.FromJsonAr(A: TJsonArray): TArray<string>;
var
  I: integer;
begin
  SetLength(Result, A.Count);
  for I := 0 to A.Count - 1 do
    Result[I] := A.Get(I).Value;
end;

class function TJsonMom.FromJsonIBooruComment(A: TJsonObject): IBooruComment;
begin
  Result := TBooruCommentBase.Create;
  with Result do begin
    Id := A.GetValue<int64>('Id');
    Username := A.GetValue<String>('Username');
    Timestamp :=  ISO8601ToDate(A.GetValue<string>('Timestamp'));
    Text := A.GetValue<String>('Text');
    Score := A.GetValue<integer>('Score');

    if Assigned(A.Get('PostId')) then begin
      PostId := A.GetValue<int64>('PostId');
      CreatorId := A.GetValue<int64>('CreatorId');
      IsDeleted := A.GetValue<Boolean>('IsDeleted');
    end;
  end;
end;

class function TJsonMom.FromJsonIBooruCommentAr(A: TJsonArray): TBooruCommentAr;
var
  I: integer;
begin
  SetLength(Result, A.Count);
  for I := 0 to A.Count - 1 do
    Result[I] := TJsonMom.FromJsonIBooruComment(A.Get(I) as TJsonObject);
end;

class function TJsonMom.FromJsonIBooruPost(A: TJsonObject): IBooruPost;
var
  LIdStr: IIdString;
begin
  if Assigned(A.Get('IdStr')) then
    Result := TBooruPostWithStrId.Create
  else
    Result := TBooruPostBase.Create;

  Result := TBooruPostBase.Create;
  with Result do begin
    Id := A.GetValue<TBooruId>('Id');
    Thumbnail := A.GetValue<string>('Thumbnail');

    if Assigned(A.Get('SampleUrl')) then
      SampleUrl := A.GetValue<string>('SampleUrl');

    ContentUrl := A.GetValue<string>('ContentUrl');
    Score := A.GetValue<integer>('Score');
    Uploader := A.GetValue<string>('Uploader');
    Tags.AddRange(TJsonMom.FromJsonIBooruTagAr(A.GetValue('Tags') as TJsonArray));
    Comments.AddRange(TJsonMom.FromJsonIBooruCommentAr(A.GetValue('Comments') as TJsonArray));

    if Assigned(A.Get('Md5')) then begin
      UploaderId := A.GetValue<TBooruId>('UploaderId');
      Md5 := A.GetValue<string>('Md5');
      Height := A.GetValue<integer>('Height');
      Width := A.GetValue<integer>('Width');
      SourceUrl := A.GetValue<string>('SourceUrl');
      Rating := A.GetValue<string>('Rating');
      SampleHeight := A.GetValue<integer>('SampleHeight');
      SampleWidth := A.GetValue<integer>('SampleWidth');
      PreviewHeight :=  A.GetValue<integer>('PreviewHeight');
      PreviewWidth := A.GetValue<integer>('PreviewWidth');
      HasChildren := A.GetValue<Boolean>('HasChildren');
      IsPending := A.GetValue<Boolean>('IsPending');
      IsFlagged := A.GetValue<Boolean>('IsFlagged');
      IsBanned := A.GetValue<Boolean>('IsBanned');
      IsDeleted := A.GetValue<Boolean>('IsDeleted');
      HasComments := A.GetValue<Boolean>('HasComments');
      HasNotes := A.GetValue<Boolean>('HasNotes');
      CreatedAt := ISO8601ToDate(A.GetValue<string>('CreatedAt'));
      FileSize := A.GetValue<int64>('FileSize');
      FileExt := A.GetValue<string>('FileExt');
      ParentId := A.GetValue<int64>('ParentId');
      FavCount := A.GetValue<integer>('FavCount');
      LastCommentBumpedAt := ISO8601ToDate(A.GetValue<string>('LastCommentBumpedAt'));
      LastNotedAt := ISO8601ToDate(A.GetValue<string>('LastNotedAt'));
      ApproverId := A.GetValue<TBooruId>('ApproverId');
      UpScore := A.GetValue<integer>('UpScore');
      DownScore := A.GetValue<integer>('DownScore');
    end;

    { v0.2.0 }
    if Supports(Result, IIdString, LIdStr) then
      LIdStr.Id := A.GetValue<string>('IdStr');

  end;
end;

class function TJsonMom.FromJsonIBooruPostAr(A: TJsonArray): TBooruPostAr;
var
  I: integer;
begin
  SetLength(Result, A.Count);
  for I := 0 to A.Count - 1 do
    Result[I] := TJsonMom.FromJsonIBooruPost(A.Get(I) as TJsonObject);
end;

class function TJsonMom.FromJsonIBooruTag(A: TJsonObject): IBooruTag;
begin
  Result := TBooruTagBase.Create;
  with Result do begin
    Value := A.GetValue<string>('Value');
    Kind := TBooruTagType(A.GetValue<integer>('Kind'));
    Count := A.GetValue<int64>('Count');
  end;
end;

class function TJsonMom.FromJsonIBooruTagAr(A: TJsonArray): TBooruTagAr;
var
  I: integer;
begin
  SetLength(Result, A.Count);
  for I := 0 to A.Count - 1 do
    Result[I] := TJsonMom.FromJsonIBooruTag(A.Get(I) as TJsonObject);
end;

class function TJsonMom.FromJsonIBooruThumb(A: TJsonObject): IBooruThumb;
var
  LIdStr: IIdString;
begin
  if Assigned(A.Get('IdStr')) then
    Result := TBooruThumbWithStrId.Create
  else
    Result := TBooruThumbBase.Create;

  with Result do begin
    Id := A.GetValue<int64>('Id');
    Thumbnail := A.GetValue<string>('Thumbnail');
    TagsValues := TJsonMom.FromJsonAr(A.GetValue('TagsValues') as TJsonArray);

    { v0.2.0 }
    if Supports(Result, IIdString, LIdStr) then
      LIdStr.Id := A.GetValue<string>('IdStr');
  end;
end;

class function TJsonMom.FromJsonIBooruThumbAr(A: TJsonArray): TBooruThumbAr;
var
  I: integer;
begin
  SetLength(Result, A.Count);
  for I := 0 to A.Count - 1 do
    Result[I] := TJsonMom.FromJsonIBooruThumb(A.Get(I) as TJsonObject);
end;

class function TJsonMom.ToJson(AVal: IBooruPost): TJsonObject;
var
  LIdStr: IIdString;
begin
  Result := TJsonObject.Create;
  with Result do begin
    AddPair('Id', AVal.Id);
    AddPair('Thumbnail', AVal.Thumbnail);
    AddPair('SampleUrl', AVal.SampleUrl);
    AddPair('ContentUrl', AVal.ContentUrl);
    AddPair('Score', AVal.Score);
    AddPair('Uploader', AVal.Uploader);
    AddPair('Tags', TJsonMom.ToJson(AVal.Tags.ToArray));
    AddPair('Comments', TJsonMom.ToJson(AVal.Comments.ToArray));

    AddPair('UploaderId', AVal.UploaderId);
    AddPair('Md5', AVal.Md5);
    AddPair('Height', AVal.Height);
    AddPair('Width', AVal.Width);
    AddPair('SourceUrl', AVal.SourceUrl);
    AddPair('Rating', AVal.Rating);
    AddPair('SampleHeight', AVal.SampleHeight);
    AddPair('SampleWidth', AVal.SampleWidth);
    AddPair('PreviewHeight', AVal.PreviewHeight);
    AddPair('PreviewWidth', AVal.PreviewWidth);
    AddPair('HasChildren', AVal.HasChildren);
    AddPair('IsPending', AVal.IsPending);
    AddPair('IsDeleted', AVal.IsDeleted);
    AddPair('IsBanned', AVal.IsBanned);
    AddPair('IsFlagged', AVal.IsFlagged);
    AddPair('HasComments', AVal.HasComments);
    AddPair('HasNotes', AVal.HasNotes);
    AddPair('CreatedAt', DateToISO8601(AVal.CreatedAt));
    AddPair('FileSize', AVal.FileSize);
    AddPair('FileExt', AVal.FileExt);
    AddPair('ParentId', AVal.ParentId);
    AddPair('FavCount', AVal.FavCount);
    AddPair('LastCommentBumpedAt', DateToISO8601(AVal.LastCommentBumpedAt));
    AddPair('LastNotedAt', DateToISO8601(AVal.LastNotedAt));
    AddPair('ApproverId', AVal.ApproverId);
    AddPair('UpScore', AVal.UpScore);
    AddPair('DownScore', AVal.DownScore);

    { v0.2.0 }
    if Supports(AVal, IIdString, LIdStr) then
      AddPair('IdStr', LIdStr.Id);
  end;
end;

class function TJsonMom.ToJson(AVal: IBooruComment): TJsonObject;
begin
  Result := TJsonObject.Create;
  with Result do begin
    AddPair('Id', AVal.Id);
    AddPair('Username', AVal.Username);
    AddPair('Timestamp', DateToISO8601(AVal.Timestamp));
    AddPair('Text', AVal.Text);
    AddPair('Score', AVal.Score);
    AddPair('PostId', AVal.PostId);
    AddPair('CreatorId', AVal.CreatorId);
    AddPair('IsDeleted', AVal.IsDeleted);
  end;
end;

class function TJsonMom.ToJson(AVal: IBooruTag): TJsonObject;
begin
  Result := TJsonObject.Create;
  with Result do begin
    AddPair('Value', AVal.Value);
    AddPair('Kind', Ord(AVal.Kind));
    AddPair('Count', AVal.Count);
  end;
end;

class function TJsonMom.ToJson(AVal: IBooruThumb): TJsonObject;
var
  LIdStr: IIdString;
begin
  Result := TJsonObject.Create;
  with Result do begin
    AddPair('Id', AVal.Id);
    AddPair('Thumbnail', AVal.Thumbnail);
    AddPair('TagsValues', TJsonMom.ToJsonAr(AVal.TagsValues));

    { v0.2.0 }
    if Supports(AVal, IIdString, LIdStr) then
      AddPair('IdStr', LIdStr.Id);
  end;
end;

class function TJsonMom.ToJson(AVal: TBooruPostAr): TJsonArray;
var
  I: integer;
begin
  Result := TJsonArray.Create;
  for I := 0 to High(AVal) do
    Result.AddElement(TJsonMom.ToJson(AVal[I]));
end;

class function TJsonMom.ToJson(AVal: TBooruCommentAr): TJsonArray;
var
  I: integer;
begin
  Result := TJsonArray.Create;
  for I := 0 to High(AVal) do
    Result.AddElement(TJsonMom.ToJson(AVal[I]));
end;

class function TJsonMom.ToJson(AVal: TBooruTagAr): TJsonArray;
var
  I: integer;
begin
  Result := TJsonArray.Create;
  for I := 0 to High(AVal) do
    Result.AddElement(TJsonMom.ToJson(AVal[I]));
end;

class function TJsonMom.ToJsonAr(const Ar: TArray<string>): TJsonArray;
var
  I: integer;
begin
  Result := TJsonArray.Create;
  for I := Low(Ar) to High(Ar) do
    Result.Add(Ar[I]);
end;

class function TJsonMom.ToJsonAuto(AVal: IAssignAndClone): TJsonObject;
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

end.
