unit BooruScraper.BaseTypes;

interface
uses
  Classes, Types, SysUtils, DateUtils, System.Generics.Collections,
  BooruScraper.Interfaces;

type

  TBooruThumbBase = Class(TInterfacedObject, IBooruThumb, IAssignAndClone)
    public { IAssignAndClone }
      procedure Assign(const ASource: IAssignAndClone);
      function Clone: IAssignAndClone;
    protected
      FId: TBooruId;
      FThumbnail: string;
      FTagsValues: TArray<string>;
      { --------------------- }
      procedure SetId(const value: TBooruId);
      function GetId: TBooruId;
      procedure SetThumbnail(const value: string);
      function GetThumbnail: string;
      procedure SetTagsValues(const value: TArray<string>);
      function GetTagsValues: TArray<string>;
    public
      property Id: TBooruId read GetId write SetId;
      property Thumbnail: string read GetThumbnail write SetThumbnail;
      property TagsValues: TArray<string> read GetTagsValues write SetTagsValues;
      { --------------------- }
      constructor Create;
  End;

  TBooruTagBase = Class(TInterfacedObject, IBooruTag, IAssignAndClone)
    public { IAssignAndClone }
      procedure Assign(const ASource: IAssignAndClone);
      function Clone: IAssignAndClone;
    protected
      FValue: string;
      FKind: TBooruTagType;
      FCount: int64;
      { --------------------- }
      procedure SetValue(const value: string);
      function GetValue: string;
      procedure SetKind(const value: TBooruTagType);
      function GetKind: TBooruTagType;
      procedure SetCount(const value: int64);
      function GetCount: int64;
    public
      property Value: string read GetValue write SetValue;
      property Kind: TBooruTagType read GetKind write SetKind;
      property Count: int64 read GetCount write SetCount;
      { --------------------- }
      constructor Create;
  End;

  TBooruCommentBase = Class(TInterfacedObject, IBooruComment, IAssignAndClone)
    public { IAssignAndClone }
      procedure Assign(const ASource: IAssignAndClone);
      function Clone: IAssignAndClone;
    protected
      FId: TBooruId;
      FUsername: string;
      FUserUrl: string;
      FTimestamp: TDatetime;
      FText: string;
      FScore: Cardinal;
      FIsDeleted: boolean;
      FPostId: TBooruId;
      FCreatorId: TBooruId;
      { --------------------- }
      procedure SetId(const value: TBooruId);
      function GetId: TBooruId;
      procedure SetPostId(const value: TBooruId);
      function GetPostId: TBooruId;
      procedure SetCreatorId(const value: TBooruId);
      function GetCreatorId: TBooruId;
      procedure SetUsername(const value: string);
      function GetUsername: string;
      procedure SetTimestamp(const value: TDatetime);
      function GetTimestamp: TDatetime;
      procedure SetText(const value: string);
      function GetText: string;
      procedure SetScore(const value: TBooruScore);
      function GetScore: TBooruScore;
      procedure SetIsDeleted(const value: boolean);
      function GetIsDeleted: boolean;
    public
      property Id: TBooruId read GetId write SetId;
      property PostId: TBooruId read GetPostId write SetPostId;
      property CreatorId: TBooruId read GetCreatorId write SetCreatorId;
      property Username: string read GetUsername write SetUsername;
      property Timestamp: TDatetime read GetTimestamp write SetTimestamp;
      property Text: string read GetText write SetText;
      property Score: TBooruScore read GetScore write SetScore;
      property IsDeleted: boolean read GetIsDeleted write SetIsDeleted;
      { --------------------- }
      constructor Create;
  End;

  TBooruPostBase = Class(TInterfacedObject, IBooruPost, IBooruThumb, IAssignAndClone)
    public { IAssignAndClone }
      procedure Assign(const ASource: IAssignAndClone); virtual;
      function Clone: IAssignAndClone; virtual;
    protected
      FId: TBooruId;
      FThumbnail: string;
      FSampleUrl: string;
      FContentUrl: string;
      FScore: TBooruScore;
      FUploader: string;
      FTags: TBooruTagList;
      FComments: TBooruCommentList;
      FUploaderId: TBooruId;
      FMd5: string;
      FHeight: integer;
      FWidth: integer;
      FSourceUrl: string;
      FRating: string;
      FSampleHeight: integer;
      FSampleWidth: integer;
      FPreviewHeight: integer;
      FPreviewWidth: integer;
      FHasChildren: boolean;
      FIsPending: boolean;
      FIsDeleted: boolean;
      FIsBanned: boolean;
      FIsFlagged: boolean;
      FHasNotes: boolean;
      FHasComments: boolean;
      FCreatedAt: TDateTime;
      FFileSize: int64;
      FFileExt: string;
      FParentId: TBooruId;
      FFavCount: integer;
      FLastCommentBumpedAt: TDateTime;
      FLastNotedAt: TDateTime;
      FApproverId: TBooruId;
      FUpScore: integer;
      FDownScore: integer;
      { --------------------- }
      procedure SetId(const value: TBooruId);
      function GetId: TBooruId;
      procedure SetThumbnail(const value: string);
      function GetThumbnail: string;
      procedure SetTagsValues(const value: TArray<string>);
      function GetTagsValues: TArray<string>;
      procedure SetContentUrl(const value: string);
      function GetContentUrl: string;
      procedure SetSampleUrl(const value: string);
      function GetSampleUrl: string;
      procedure SetScore(const value: TBooruScore);
      function GetScore: TBooruScore;
      procedure SetUploader(const value: string);
      function GetUploader: string;
      procedure SetTags(const value: TBooruTagList);
      function GetTags: TBooruTagList;
      procedure SetComments(const value: TBooruCommentList);
      function GetComments: TBooruCommentList;
      procedure SetUploaderId(const value: TBooruId);
      function GetUploaderId: TBooruId;
      procedure SetMd5(const value: string);
      function GetMd5: string;
      procedure SetHeight(const value: integer);
      function GetHeight: integer;
      procedure SetWidth(const value: integer);
      function GetWidth: integer;
      procedure SetSourceUrl(const value: string);
      function GetSourceUrl: string;
      procedure SetRating(const value: string);
      function GetRating: string;
      procedure SetSampleWidth(const value: integer);
      function GetSampleWidth: integer;
      procedure SetSampleHeight(const value: integer);
      function GetSampleHeight: integer;
      procedure SetPreviewWidth(const value: integer);
      function GetPreviewWidth: integer;
      procedure SetPreviewHeight(const value: integer);
      function GetPreviewHeight: integer;
      procedure SetHasChildren(const value: boolean);
      function GetHasChildren: boolean;
      procedure SetHasNotes(const value: boolean);
      function GetHasNotes: boolean;
      procedure SetIsPending(const value: boolean);
      function GetIsPending: boolean;
      procedure SetIsBanned(const value: boolean);
      function GetIsBanned: boolean;
      procedure SetIsDeleted(const value: boolean);
      function GetIsDeleted: boolean;
      procedure SetIsFlagged(const value: boolean);
      function GetIsFlagged: boolean;
      procedure SetHasComments(const value: boolean);
      function GetHasComments: boolean;
      procedure SetCreatedAt(const value: TDateTime);
      function GetCreatedAt: TDateTime;
      procedure SetFileSize(const value: int64);
      function GetFileSize: int64;
      procedure SetParentId(const value: TBooruId);
      function GetParentId: TBooruId;
      procedure SetFavCount(const value: integer);
      function GetFavCount: integer;
      procedure SetFileExt(const value: string);
      function GetFileExt: string;
      procedure SetLastCommentBumpedAt(const value: TDateTime);
      function GetLastCommentBumpedAt: TDateTime;
      procedure SetLastNotedAt(const value: TDateTime);
      function GetLastNotedAt: TDateTime;
      procedure SetApproverId(const value: TBooruId);
      function GetApproverId: TBooruId;
      procedure SetUpScore(const value: integer);
      function GetUpScore: integer;
      procedure SetDownScore(const value: integer);
      function GetDownScore: integer;
    public
      function HasTag(AValue: string): boolean;
      function GetTagsByType(ATagType: TBooruTagType): TBooruTagAr;
      { --------------------- }
      property Id: TBooruId read GetId write SetId;
      property Thumbnail: string read GetThumbnail write SetThumbnail;
      property TagsValues: TArray<string> read GetTagsValues;
      property SampleUrl: string read GetSampleUrl write SetSampleUrl;
      property ContentUrl: string read GetContentUrl write SetContentUrl;
      property Score: TBooruScore read GetScore write SetScore;
      property Uploader: string read GetUploader write SetUploader;
      property Tags: TBooruTagList read GetTags write SetTags;
      property Comments: TBooruCommentList read GetComments write SetComments;
      property FavCount: integer read GetFavCount write SetFavCount;
      property UpScore: integer read GetUpScore write SetUpScore;
      property DownScore: integer read GetDownScore write SetDownScore;
      property ParentId: TBooruId read GetParentId write SetParentId;
      property FileSize: int64 read GetFileSize write SetFileSize;
      property FileExt: string read GetFileExt write SetFileExt;
      property SourceUrl: string read GetSourceUrl write SetSourceUrl;
      property Rating: string read GetRating write SetRating;
      property CreatedAt: TDateTime read GetCreatedAt write SetCreatedAt;
      property LastCommentBumpedAt: TDateTime read GetLastCommentBumpedAt write SetLastCommentBumpedAt;
      property LastNotedAt: TDateTime read GetLastNotedAt write SetLastNotedAt;
      property HasChildren: boolean read GetHasChildren write SetHasChildren;
      property HasComments: boolean read GetHasComments write SetHasComments;
      property HasNotes: boolean read GetHasNotes write SetHasNotes;
      property IsPending: boolean read GetIsPending write SetIsPending;
      property IsFlagged: boolean read GetIsFlagged write SetIsFlagged;
      property IsDeleted: boolean read GetIsDeleted write SetIsDeleted;
      property IsBanned: boolean read GetIsBanned write SetIsBanned;
      property ApproverId: TBooruId read GetApproverId write SetApproverId;
      property UploaderId: TBooruId read GetUploaderId write SetUploaderId;
      property Md5: string read GetMd5 write SetMd5;
      { full image size }
      property Height: integer read GetHeight write SetHeight;
      property Width: integer read GetWidth write SetWidth;
      { sample size }
      property SampleWidth: integer read GetSampleWidth write SetSampleWidth;
      property SampleHeight: integer read GetSampleHeight write SetSampleHeight;
      { preview size }
      property PreviewWidth: integer read GetPreviewWidth write SetPreviewWidth;
      property PreviewHeight: integer read GetPreviewHeight write SetPreviewHeight;
      { --------------------- }
      constructor Create; virtual;
      destructor Destroy; override;
  End;

implementation

{ TBooruThumbBase }

procedure TBooruThumbBase.Assign(const Asource: IAssignAndClone);
var
  LThumb: IBooruThumb;
begin
  if Supports(ASource, IBooruThumb, LThumb) then begin
    Self.Id := LThumb.Id;
    Self.Thumbnail := LThumb.Thumbnail;
    Self.TagsValues := LThumb.TagsValues;
  end;
end;

function TBooruThumbBase.Clone: IAssignAndClone;
begin
  Result := TBooruThumbBase.Create;
  Result.Assign(Self);
end;

constructor TBooruThumbBase.Create;
begin
  FId := BOORU_NOTSET;
  FThumbnail := '';
  FTagsValues := Nil;
end;

function TBooruThumbBase.GetId: TBooruId;
begin
  Result := FId;
end;

function TBooruThumbBase.GetTagsValues: TArray<string>;
begin
  Result := FTagsValues;
end;

function TBooruThumbBase.GetThumbnail: string;
begin
  Result := FThumbnail;
end;

procedure TBooruThumbBase.SetId(const value: TBooruId);
begin
  FId := value;
end;

procedure TBooruThumbBase.SetTagsValues(const value: TArray<string>);
var
  I: integer;
begin
  SetLength(FTagsValues, Length(value));
  for I := 0 to High(Value) do begin
    FTagsValues[I] := String.Copy(Value[I]);
  end;
end;

procedure TBooruThumbBase.SetThumbnail(const value: string);
begin
  FThumbnail := value;
end;

{ TBooruTagBase }

procedure TBooruTagBase.Assign(const Asource: IAssignAndClone);
var
  LTag: IBooruTag;
begin
  if Supports(ASource, IBooruTag, LTag) then begin
    Self.Value := LTag.Value;
    Self.Kind := LTag.Kind;
    Self.Count := LTag.Count;
  end;
end;

function TBooruTagBase.Clone: IAssignAndClone;
begin
  Result := TBooruTagBase.Create;
  Result.Assign(Self);
end;

constructor TBooruTagBase.Create;
begin
  FValue := '';
  FKind := TBooruTagType.TagGeneral;
  FCount := BOORU_NOTSET;
end;

function TBooruTagBase.GetCount: int64;
begin
  Result := FCount;
end;

function TBooruTagBase.GetKind: TBooruTagType;
begin
  Result := FKind;
end;

function TBooruTagBase.GetValue: string;
begin
  Result := FValue;
end;

procedure TBooruTagBase.SetCount(const value: int64);
begin
  FCount := value;
end;

procedure TBooruTagBase.SetKind(const value: TBooruTagType);
begin
  FKind := value;
end;

procedure TBooruTagBase.SetValue(const value: string);
begin
  FValue := value;
end;

{ TBooruCommentBase }

procedure TBooruCommentBase.Assign(const Asource: IAssignAndClone);
var
  LComment: IBooruComment;
begin
  if Supports(ASource, IBooruComment, LComment) then begin
    Self.Id := LComment.Id;
    Self.Username := LComment.Username;
    Self.Timestamp := LComment.Timestamp;
    Self.Text := LComment.Text;
    Self.CreatorId := LComment.CreatorId;
    Self.PostId := LComment.PostId;
    Self.IsDeleted := LComment.IsDeleted;
  end;
end;

function TBooruCommentBase.Clone: IAssignAndClone;
begin
  Result := TBooruCommentBase.Create;
  Result.Assign(Self);
end;

constructor TBooruCommentBase.Create;
begin
  FId := BOORU_NOTSET;
  FUsername := '';
  FUserUrl := '';
  FText := '';
  FScore := 0;
  FTimestamp := BOORU_NOTSET;
  FIsDeleted := False;
  FCreatorId := BOORU_NOTSET;
  FPostId := BOORU_NOTSET;
end;

function TBooruCommentBase.GetCreatorId: TBooruId;
begin
  Result := FCreatorId;
end;

function TBooruCommentBase.GetId: TBooruId;
begin
  Result := FId;
end;

function TBooruCommentBase.GetIsDeleted: boolean;
begin
  Result := FIsDeleted;
end;

function TBooruCommentBase.GetPostId: TBooruId;
begin
  Result := FPostId;
end;

function TBooruCommentBase.GetScore: TBooruScore;
begin
  Result := FScore;
end;

function TBooruCommentBase.GetText: string;
begin
  Result := FText;
end;

function TBooruCommentBase.GetTimestamp: TDatetime;
begin
  Result := FTimestamp;
end;

function TBooruCommentBase.GetUsername: string;
begin
  Result := FUsername;
end;

//function TBooruCommentBase.GetUserUrl: string;
//begin
//  Result := FUserUrl;
//end;

procedure TBooruCommentBase.SetCreatorId(const value: TBooruId);
begin
  FCreatorId := value;
end;

procedure TBooruCommentBase.SetId(const value: TBooruId);
begin
  FId := value;
end;

procedure TBooruCommentBase.SetIsDeleted(const value: boolean);
begin
  FIsDeleted := value;
end;

procedure TBooruCommentBase.SetPostId(const value: TBooruId);
begin
  FPostId := value;
end;

procedure TBooruCommentBase.SetScore(const value: TBooruScore);
begin
  FScore := value;
end;

procedure TBooruCommentBase.SetText(const value: string);
begin
  FText := value;
end;

procedure TBooruCommentBase.SetTimestamp(const value: TDatetime);
begin
  FTimestamp := value;
end;

procedure TBooruCommentBase.SetUsername(const value: string);
begin
  FUsername := value;
end;

//procedure TBooruCommentBase.SetUserUrl(const value: string);
//begin
//  FUserUrl := value;
//end;

{ TBooruPostBase }

procedure TBooruPostBase.Assign(const Asource: IAssignAndClone);
var
  LPost: IBooruPost;
  LThumb: IBooruThumb;
begin
  if Supports(ASource, IBooruPost, LPost) then begin
    Self.Id := LPost.Id;
    Self.Thumbnail := LPost.Thumbnail;
    Self.ContentUrl := LPost.ContentUrl;
    Self.SampleUrl := LPost.SampleUrl;
    Self.Score := LPost.Score;
    Self.Uploader := LPost.Uploader;
    Self.Tags := LPost.Tags;
    Self.Comments := LPost.Comments;
    FavCount := LPost.FavCount;
    UpScore := LPost.UpScore;
    DownScore := LPost.DownScore;
    ParentId := LPost.ParentId;
    FileSize := LPost.FileSize;
    FileExt := LPost.FileExt;
    SourceUrl := LPost.SourceUrl;
    Rating := LPost.Rating;
    CreatedAt := LPost.CreatedAt;
    LastCommentBumpedAt := LPost.LastCommentBumpedAt;
    LastNotedAt := LPost.LastNotedAt;
    HasChildren := LPost.HasChildren;
    HasComments := LPost.HasComments;
    IsPending := LPost.IsPending;
    IsFlagged := LPost.IsFlagged;
    IsDeleted := LPost.IsDeleted;
    IsBanned := LPost.IsBanned;
    ApproverId := LPost.ApproverId;
    UploaderId := LPost.UploaderId;
    Md5 := LPost.Md5;
    Height := LPost.Height;
    Width := LPost.Width;
    SampleWidth := LPost.SampleWidth;
    SampleHeight := LPost.SampleHeight;
    PreviewWidth := LPost.PreviewWidth;
    PreviewHeight := LPost.PreviewHeight;
  end else if Supports(ASource, IBooruThumb, LThumb) then begin
    Self.Id := LThumb.Id;
    Self.Thumbnail := LThumb.Thumbnail;
  end;
end;

function TBooruPostBase.Clone: IAssignAndClone;
begin
  Result := TBooruPostBase.Create;
  Result.Assign(Self);
end;

constructor TBooruPostBase.Create;
begin
  FId := BOORU_NOTSET;
  FThumbnail := '';
  FContentUrl := '';
  FScore := 0;
  FUploader := '';
  FTags := TBooruTagList.Create;
  FComments := TBooruCommentList.Create;
  FavCount := BOORU_NOTSET;
  UpScore := BOORU_NOTSET;
  DownScore := BOORU_NOTSET;
  ParentId := BOORU_NOTSET;
  FileSize := BOORU_NOTSET;
  FileExt := '';
  SourceUrl := '';
  Rating := '';
  HasNotes := False;
  HasChildren := False;
  HasComments := False;
  IsPending := False;
  IsFlagged := False;
  IsBanned := False;
  IsDeleted := False;
  ApproverId := BOORU_NOTSET;
  UploaderId := BOORU_NOTSET;
  Md5 := '';
  Height := BOORU_NOTSET;
  Width := BOORU_NOTSET;
  SampleWidth := BOORU_NOTSET;
  SampleHeight := BOORU_NOTSET;
  PreviewWidth := BOORU_NOTSET;
  PreviewHeight := BOORU_NOTSET;
end;

destructor TBooruPostBase.Destroy;
begin
  FreeAndNil(FTags);
  FreeAndNil(FComments);
//  writeln('TBooruPostBase.Destroy');
  inherited;
end;

function TBooruPostBase.GetComments: TBooruCommentList;
begin
  Result := FComments;
end;

function TBooruPostBase.GetContentUrl: string;
begin
  Result := FContentUrl;
end;

function TBooruPostBase.GetId: TBooruId;
begin
  Result := FId;
end;

function TBooruPostBase.GetSampleUrl: string;
begin
  Result := FSampleUrl;
end;

function TBooruPostBase.GetScore: TBooruScore;
begin
  Result := FScore;
end;

function TBooruPostBase.GetTags: TBooruTagList;
begin
  Result := FTags;
end;

function TBooruPostBase.GetTagsByType(ATagType: TBooruTagType): TBooruTagAr;
var
  I: integer;
begin
  Result := [];
  for I := 0 to Tags.Count - 1 do begin
    if Tags[I].Kind = ATagType then
      Result := Result + [Tags[I]];
  end;
end;

function TBooruPostBase.GetTagsValues: TArray<string>;
var
  I: integer;
begin
  SetLength(Result, Tags.Count);
  for I := 0 to Tags.Count - 1 do
    Result[I] := Tags[I].Value;
end;

function TBooruPostBase.GetThumbnail: string;
begin
  Result := FThumbnail;
end;

function TBooruPostBase.GetUploader: string;
begin
  Result := FUploader;
end;

function TBooruPostBase.HasTag(AValue: string): boolean;
var
  I: integer;
begin
  for I := 0 to Tags.Count - 1 do begin
    if (Tags[I].Value.ToUpper = AValue.ToUpper) then begin
      Result := True;
      exit;
    end;
  end;
  Result := False;
end;

procedure TBooruPostBase.SetComments(const value: TBooruCommentList);
begin
  FComments.Clear;
  FComments.AddRange(TCloneMachine.CloneAr<IBooruComment>(value.ToArray));
end;

procedure TBooruPostBase.SetContentUrl(const value: string);
begin
  FContentUrl := value;
end;

procedure TBooruPostBase.SetId(const value: TBooruId);
begin
  FId := value;
end;

procedure TBooruPostBase.SetSampleUrl(const value: string);
begin
  FSampleUrl := value;
end;

procedure TBooruPostBase.SetScore(const value: TBooruScore);
begin
  FScore := value;
end;

procedure TBooruPostBase.SetTags(const value: TBooruTagList);
begin
  FTags.Clear;
  FTags.AddRange(TCloneMachine.CloneAr<IBooruTag>(value.ToArray));
end;

procedure TBooruPostBase.SetTagsValues(const value: TArray<string>);
begin
  { There is nothing to do. }
end;

procedure TBooruPostBase.SetThumbnail(const value: string);
begin
  FThumbnail := value;
end;

procedure TBooruPostBase.SetUploader(const value: string);
begin
  FUploader := value;
end;

{ TBooruFullPostBase }

function TBooruPostBase.GetApproverId: TBooruId;
begin
  Result := FApproverId;
end;

function TBooruPostBase.GetCreatedAt: TDateTime;
begin
  Result := FCreatedAt;
end;

function TBooruPostBase.GetDownScore: integer;
begin
  Result := FDownScore;
end;

function TBooruPostBase.GetFavCount: integer;
begin
  Result := FFavCount;
end;

function TBooruPostBase.GetFileExt: string;
begin
  Result := FFileExt;
end;

function TBooruPostBase.GetFileSize: int64;
begin
  Result := FFileSize;
end;

function TBooruPostBase.GetHasChildren: boolean;
begin
  Result := FHasChildren;
end;

function TBooruPostBase.GetHasComments: boolean;
begin
  Result := FHasComments;
end;

function TBooruPostBase.GetHasNotes: boolean;
begin
  Result := FHasNotes;
end;

function TBooruPostBase.GetHeight: integer;
begin
  Result := FHeight;
end;

function TBooruPostBase.GetIsBanned: boolean;
begin
  Result := FIsBanned;
end;

function TBooruPostBase.GetIsDeleted: boolean;
begin
  Result := FIsDeleted;
end;

function TBooruPostBase.GetIsFlagged: boolean;
begin
  Result := FIsFlagged;
end;

function TBooruPostBase.GetIsPending: boolean;
begin
  Result := FIsPending;
end;

function TBooruPostBase.GetLastCommentBumpedAt: TDateTime;
begin
  Result := FLastCommentBumpedAt;
end;

function TBooruPostBase.GetLastNotedAt: TDateTime;
begin
  Result := FLastNotedAt;
end;

function TBooruPostBase.GetMd5: string;
begin
  Result := FMd5;
end;

function TBooruPostBase.GetParentId: TBooruId;
begin
  Result := FParentId;
end;

function TBooruPostBase.GetPreviewHeight: integer;
begin
  Result := FPreviewHeight;
end;

function TBooruPostBase.GetPreviewWidth: integer;
begin
  Result := FPreviewWidth;
end;

function TBooruPostBase.GetRating: string;
begin
  Result := FRating;
end;

function TBooruPostBase.GetSampleHeight: integer;
begin
  Result := FSampleHeight;
end;

function TBooruPostBase.GetSampleWidth: integer;
begin
  Result := FSampleWidth;
end;

function TBooruPostBase.GetSourceUrl: string;
begin
  Result := FSourceUrl;
end;

function TBooruPostBase.GetUploaderId: TBooruId;
begin
  Result := FUploaderId;
end;

function TBooruPostBase.GetUpScore: integer;
begin
  Result := FUpScore;
end;

function TBooruPostBase.GetWidth: integer;
begin
  Result := FWidth;
end;

procedure TBooruPostBase.SetApproverId(const value: TBooruId);
begin
  FApproverId := value;
end;

procedure TBooruPostBase.SetCreatedAt(const value: TDateTime);
begin
  FCreatedAt := value;
end;

procedure TBooruPostBase.SetDownScore(const value: integer);
begin
  FDownScore := value;
end;

procedure TBooruPostBase.SetFavCount(const value: integer);
begin
  FFavCount := value;
end;

procedure TBooruPostBase.SetFileExt(const value: string);
begin
  FFileExt := value;
end;

procedure TBooruPostBase.SetFileSize(const value: int64);
begin
  FFileSize := value;
end;

procedure TBooruPostBase.SetHasChildren(const value: boolean);
begin
  FHasChildren := value;
end;

procedure TBooruPostBase.SetHasComments(const value: boolean);
begin
  FHasComments := value;
end;

procedure TBooruPostBase.SetHasNotes(const value: boolean);
begin
  FHasNotes := value;
end;

procedure TBooruPostBase.SetHeight(const value: integer);
begin
  FHeight := value;
end;

procedure TBooruPostBase.SetIsBanned(const value: boolean);
begin
  FIsBanned := value;
end;

procedure TBooruPostBase.SetIsDeleted(const value: boolean);
begin
  FIsDeleted := value;
end;

procedure TBooruPostBase.SetIsFlagged(const value: boolean);
begin
  FIsFlagged := value;
end;

procedure TBooruPostBase.SetIsPending(const value: boolean);
begin
  FIsPending := value;
end;

procedure TBooruPostBase.SetLastCommentBumpedAt(const value: TDateTime);
begin
  FLastCommentBumpedAt := value;
end;

procedure TBooruPostBase.SetLastNotedAt(const value: TDateTime);
begin
  FLastNotedAt := value;
end;

procedure TBooruPostBase.SetMd5(const value: string);
begin
  FMd5 := value;
end;

procedure TBooruPostBase.SetParentId(const value: TBooruId);
begin
  FParentId := value;
end;

procedure TBooruPostBase.SetPreviewHeight(const value: integer);
begin
  FPreviewHeight := value;
end;

procedure TBooruPostBase.SetPreviewWidth(const value: integer);
begin
  FPreviewWidth := value;
end;

procedure TBooruPostBase.SetRating(const value: string);
begin
  FRating := value;
end;

procedure TBooruPostBase.SetSampleHeight(const value: integer);
begin
  FSampleHeight := value;
end;

procedure TBooruPostBase.SetSampleWidth(const value: integer);
begin
  FSampleWidth := value;
end;

procedure TBooruPostBase.SetSourceUrl(const value: string);
begin
  FSourceUrl := value;
end;

procedure TBooruPostBase.SetUploaderId(const value: TBooruId);
begin
  FUploaderId := value;
end;

procedure TBooruPostBase.SetUpScore(const value: integer);
begin
  FUpScore := value;
end;

procedure TBooruPostBase.SetWidth(const value: integer);
begin
  FWidth := value;
end;

end.

