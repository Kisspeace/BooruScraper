unit BooruScraper.Serialize.XSuperObject;

interface
uses
  System.SysUtils, Classes, Types, XSuperObject, System.Generics.Collections,
  BooruScraper.Interfaces, BooruScraper.BaseTypes;

type
  TJsonMom = Class
    public
      class function ToJsonAuto(const AVal: IAssignAndClone): ISuperObject; overload;
      class function ToJson(const AVal: IBooruThumb): ISuperObject; overload;
      class function ToJson(const AVal: IBooruTag): ISuperObject; overload;
      class function ToJson(const AVal: IBooruComment): ISuperObject; overload;
      class function ToJson(const AVal: IBooruPost): ISuperObject; overload;
      { ------------------------------- }
      class function ToJson(AVal: TBooruTagAr): ISuperArray; overload;
      class function ToJson(AVal: TBooruCommentAr): ISuperArray; overload;
      class function ToJson(AVal: TBooruPostAr): ISuperArray; overload;
      { ------------------------------- }
      class function FromJsonIBooruThumb(const A: ISuperObject): IBooruThumb;
      class function FromJsonIBooruTag(const A: ISuperObject): IBooruTag;
      class function FromJsonIBooruComment(const A: ISuperObject): IBooruComment;
      class function FromJsonIBooruPost(const A: ISuperObject): IBooruPost;
      { ------------------------------- }
      class function FromJsonIBooruThumbAr(const A: ISuperArray): TBooruThumbAr;
      class function FromJsonIBooruTagAr(const A: ISuperArray): TBooruTagAr;
      class function FromJsonIBooruCommentAr(const A: ISuperArray): TBooruCommentAr;
      class function FromJsonIBooruPostAr(const A: ISuperArray): TBooruPostAr;
  End;

implementation

class function TJsonMom.ToJson(const AVal: IBooruThumb): ISuperObject;
begin
  Result := SO();
  with Result do begin
    I['Id'] := AVal.Id;
    S['Thumbnail'] := AVal.Thumbnail;
    A['TagsValues'] := TJSON.SuperObject<TArray<string>>(AVal.TagsValues).AsArray;
  end;
end;

class function TJsonMom.ToJson(const AVal: IBooruTag): ISuperObject;
begin
  Result := SO();
  with Result do begin
    S['Value'] := AVal.Value;
    I['Kind'] := Ord(AVal.Kind);
    I['Count'] := AVal.Count;
  end;
end;

class function TJsonMom.ToJson(const AVal: IBooruComment): ISuperObject;
begin
  Result := SO();
  with Result do begin
    I['Id'] := AVal.Id;
    S['Username'] := AVal.Username;
    D['Timestamp'] := AVal.Timestamp;
    S['Text'] := AVal.Text;
    I['Score'] := AVal.Score;
  end;
end;

class function TJsonMom.ToJson(const AVal: IBooruPost): ISuperObject;
begin
  Result := SO();
  with Result do begin
    I['Id'] := AVal.Id;
    S['Thumbnail'] := AVal.Thumbnail;
    S['ContentUrl'] := AVal.ContentUrl;
    I['Score'] := AVal.Score;
    S['Uploader'] := AVal.Uploader;
    A['Tags'] := TJsonMom.ToJson(AVal.Tags.ToArray);
    A['Comments'] := TJsonMom.ToJson(AVal.Comments.ToArray);
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

class function TJsonMom.FromJsonIBooruComment(const A: ISuperObject): IBooruComment;
begin
  Result := TJSON.Parse<TBooruCommentBase>(A);
end;

class function TJsonMom.FromJsonIBooruCommentAr(
 const A: ISuperArray): TBooruCommentAr;
var
  I: integer;
begin
  for I := 0 to A.Length - 1 do
    Result := Result + [Self.FromJsonIBooruComment(A.O[I])];
end;

class function TJsonMom.FromJsonIBooruPost(const A: ISuperObject): IBooruPost;
begin
  Result := TBooruPostBase.Create;
  with Result do begin
    Id := A.I['Id'];
    Thumbnail := A.S['Thumbnail'];
    ContentUrl := A.S['ContentUrl'];
    Score := A.I['Score'];
    Uploader := A.S['Uploader'];

    if A.Null['Tags'] = TMemberStatus.jAssigned then
      Tags.AddRange(TJsonMom.FromJsonIBooruTagAr(A.A['Tags']));

    if A.Null['Comments'] = TMemberStatus.jAssigned then
      Comments.AddRange(TJsonMom.FromJsonIBooruCommentAr(A.A['Comments']));
  end;
end;

class function TJsonMom.FromJsonIBooruPostAr(const A: ISuperArray): TBooruPostAr;
var
  I: integer;
begin
  for I := 0 to A.Length - 1 do
    Result := Result + [Self.FromJsonIBooruPost(A.O[I])];
end;

class function TJsonMom.FromJsonIBooruTag(const A: ISuperObject): IBooruTag;
begin
  Result := TJSON.Parse<TBooruTagBase>(A);
end;

class function TJsonMom.FromJsonIBooruTagAr(const A: ISuperArray): TBooruTagAr;
var
  I: integer;
begin
  for I := 0 to A.Length - 1 do
    Result := Result + [Self.FromJsonIBooruTag(A.O[I])];
end;

class function TJsonMom.FromJsonIBooruThumb(const A: ISuperObject): IBooruThumb;
begin
  Result := TBooruThumbBase.Create;
  with Result do begin
    Id := A.I['Id'];
    Thumbnail := A.S['Thumbnail'];
    TagsValues := TJson.Parse<TArray<string>>(A.A['TagsValues']);
  end;
//  Result := TJSON.Parse<TBooruThumbBase>(A);
end;

class function TJsonMom.FromJsonIBooruThumbAr(const A: ISuperArray): TBooruThumbAr;
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

class function TJsonMom.ToJsonAuto(const AVal: IAssignAndClone): ISuperObject;
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
