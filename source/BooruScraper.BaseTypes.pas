unit BooruScraper.BaseTypes;

interface
uses
  Classes, Types, SysUtils, DateUtils, System.Generics.Collections,
  BooruScraper.Interfaces;

type

  TBooruThumbBase = Class(TInterfacedObject, IBooruThumb, IAssignAndClone)
    private
      procedure DoAssign(const ASource: IAssignAndClone);
      function GetClone: IAssignAndClone;
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
      procedure Assign(const Asource: IBooruThumb); virtual;
      function Clone: IBooruThumb; virtual;
      { --------------------- }
      property Id: TBooruId read GetId write SetId;
      property Thumbnail: string read GetThumbnail write SetThumbnail;
      property TagsValues: TArray<string> read GetTagsValues write SetTagsValues;
      { --------------------- }
      constructor Create;
  End;

  TBooruTagBase = Class(TInterfacedObject, IBooruTag, IAssignAndClone)
    private
      procedure DoAssign(const ASource: IAssignAndClone);
      function GetClone: IAssignAndClone;
    protected
      FValue: string;
      FKind: TBooruTagType;
      FCount: Cardinal;
      { --------------------- }
      procedure SetValue(const value: string);
      function GetValue: string;
      procedure SetKind(const value: TBooruTagType);
      function GetKind: TBooruTagType;
      procedure SetCount(const value: cardinal);
      function GetCount: cardinal;
    public
      procedure Assign(const Asource: IBooruTag); virtual;
      function Clone: IBooruTag; virtual;
      { --------------------- }
      property Value: string read GetValue write SetValue;
      property Kind: TBooruTagType read GetKind write SetKind;
      property Count: Cardinal read GetCount write SetCount;
      { --------------------- }
      constructor Create;
  End;

  TBooruCommentBase = Class(TInterfacedObject, IBooruComment, IAssignAndClone)
    private
      procedure DoAssign(const ASource: IAssignAndClone);
      function GetClone: IAssignAndClone;
    protected
      FId: TBooruId;
      FUsername: string;
      FUserUrl: string;
      FTimestamp: TDatetime;
      FText: string;
      FScore: Cardinal;
      { --------------------- }
      procedure SetId(const value: TBooruId);
      function GetId: TBooruId;
      procedure SetUsername(const value: string);
      function GetUsername: string;
//      procedure SetUserUrl(const value: string);
//      function GetUserUrl: string;
      procedure SetTimestamp(const value: TDatetime);
      function GetTimestamp: TDatetime;
      procedure SetText(const value: string);
      function GetText: string;
      procedure SetScore(const value: TBooruScore);
      function GetScore: TBooruScore;
    public
      procedure Assign(const Asource: IBooruComment);
      function Clone: IBooruComment;
      { --------------------- }
      property Id: TBooruId read GetId write SetId;
      property Username: string read GetUsername write SetUsername;
//      property UserUrl: string read GetUserUrl write SetUserUrl;
      property Timestamp: TDatetime read GetTimestamp write SetTimestamp;
      property Text: string read GetText write SetText;
      property Score: TBooruScore read GetScore write SetScore;
      { --------------------- }
      constructor Create;
  End;

  TBooruPostBase = Class(TInterfacedObject, IBooruPost, IAssignAndClone)
    private
      procedure DoAssign(const ASource: IAssignAndClone);
      function GetClone: IAssignAndClone;
    protected
      FId: TBooruId;
      FThumbnail: string;
      FContentUrl: string;
      FScore: TBooruScore;
      FUploader: string;
      FTags: TBooruTagList;
      FComments: TBooruCommentList;
      { --------------------- }
      procedure SetId(const value: TBooruId);
      function GetId: TBooruId;
      procedure SetThumbnail(const value: string);
      function GetThumbnail: string;
      function GetTagsValues: TArray<string>;
      procedure SetContentUrl(const value: string);
      function GetContentUrl: string;
      procedure SetScore(const value: TBooruScore);
      function GetScore: TBooruScore;
      procedure SetUploader(const value: string);
      function GetUploader: string;
      procedure SetTags(const value: TBooruTagList); // FIXME
      function GetTags: TBooruTagList;
      procedure SetComments(const value: TBooruCommentList); // FIXME
      function GetComments: TBooruCommentList;
    public
      procedure Assign(const Asource: IBooruPost);
      function Clone: IBooruPost;
      function HasTag(AValue: string): boolean;
      function GetTagsByType(ATagType: TBooruTagType): TBooruTagAr;
      { --------------------- }
      property Id: TBooruId read GetId write SetId;
      property Thumbnail: string read GetThumbnail write SetThumbnail;
      property TagsValues: TArray<string> read GetTagsValues;
      property ContentUrl: string read GetContentUrl write SetContentUrl;
      property Score: TBooruScore read GetScore write SetScore;
      property Uploader: string read GetUploader write SetUploader;
      property Tags: TBooruTagList read GetTags write SetTags;
      property Comments: TBooruCommentList read GetComments write SetComments;
      { --------------------- }
      constructor Create;
      destructor Destroy; override;
  End;

implementation

{ TBooruThumbBase }

procedure TBooruThumbBase.Assign(const Asource: IBooruThumb);
begin
  Self.Id := ASource.Id;
  Self.Thumbnail := ASource.Thumbnail;
  Self.TagsValues := ASource.TagsValues;
end;

function TBooruThumbBase.Clone: IBooruThumb;
begin
  Result := TBooruThumbBase.Create;
  Result.Assign(Self);
end;

constructor TBooruThumbBase.Create;
begin
  FId := -1;
  FThumbnail := '';
  FTagsValues := Nil;
end;

procedure TBooruThumbBase.DoAssign(const ASource: IAssignAndClone);
//var
//  LSource: IBooruThumb;
begin
//  if Supports(ASource, IBooruThumb, LSource) then
//    exit;
//    Self.Assign(LSource.Clone);
  Self.Assign(ASource as IBooruThumb);
end;

function TBooruThumbBase.GetClone: IAssignAndClone;
begin
  Result := Self.Clone;
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

procedure TBooruTagBase.Assign(const Asource: IBooruTag);
begin
  Self.Value := ASource.Value;
  Self.Kind := ASource.Kind;
  Self.Count := ASource.Count;
end;

function TBooruTagBase.Clone: IBooruTag;
begin
  Result := TBooruTagBase.Create;
  Result.Assign(Self);
end;

constructor TBooruTagBase.Create;
begin
  FValue := '';
  FKind := TBooruTagType.TagGeneral;
  FCount := 0;
end;

procedure TBooruTagBase.DoAssign(const ASource: IAssignAndClone);
begin
  Self.Assign(ASource as IBooruTag);
end;

function TBooruTagBase.GetClone: IAssignAndClone;
begin
  Result := Self.Clone;
end;

function TBooruTagBase.GetCount: cardinal;
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

procedure TBooruTagBase.SetCount(const value: cardinal);
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

procedure TBooruCommentBase.Assign(const Asource: IBooruComment);
begin
  Self.Id := ASource.Id;
  Self.Username := ASource.Username;
//  Self.UserUrl := ASource.UserUrl;
  Self.Timestamp := ASource.Timestamp;
  Self.Text := ASource.Text;
end;

function TBooruCommentBase.Clone: IBooruComment;
begin
  Result := TBooruCommentBase.Create;
  Result.Assign(Self);
end;

constructor TBooruCommentBase.Create;
begin
  FId := DEFAULT_BOORUID;
  FUsername := '';
  FUserUrl := '';
  FText := '';
  FScore := 0;
  FTimestamp := -1;
end;

procedure TBooruCommentBase.DoAssign(const ASource: IAssignAndClone);
begin
  Self.Assign(ASource as IBooruComment);
end;

function TBooruCommentBase.GetClone: IAssignAndClone;
begin
  Result := Self.Clone;
end;

function TBooruCommentBase.GetId: TBooruId;
begin
  Result := FId;
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

procedure TBooruCommentBase.SetId(const value: TBooruId);
begin
  FId := value;
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

procedure TBooruPostBase.Assign(const Asource: IBooruPost);
begin
  Self.Id := ASource.Id;
  Self.Thumbnail := ASource.Thumbnail;
  Self.ContentUrl := ASource.ContentUrl;
  Self.Score := ASource.Score;
  Self.Uploader := ASource.Uploader;
  Self.Tags := ASource.Tags;
  Self.Comments := ASource.Comments;
end;

function TBooruPostBase.Clone: IBooruPost;
begin
  Result := TBooruPostBase.Create;
  Result.Assign(Self);
end;

constructor TBooruPostBase.Create;
begin
  FId := DEFAULT_BOORUID;
  FThumbnail := '';
  FContentUrl := '';
  FScore := 0;
  FUploader := '';
  FTags := TBooruTagList.Create;
  FComments := TBooruCommentList.Create;
end;

destructor TBooruPostBase.Destroy;
begin
  FreeAndNil(FTags);
  FreeAndNil(FComments);
//  writeln('TBooruPostBase.Destroy');
  inherited;
end;

procedure TBooruPostBase.DoAssign(const ASource: IAssignAndClone);
begin
  Self.Assign(ASource as IBooruPost);
end;

function TBooruPostBase.GetClone: IAssignAndClone;
begin
  Result := Self.Clone;
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

procedure TBooruPostBase.SetScore(const value: TBooruScore);
begin
  FScore := value;
end;

procedure TBooruPostBase.SetTags(const value: TBooruTagList);
begin
  FTags.Clear;
  FTags.AddRange(TCloneMachine.CloneAr<IBooruTag>(value.ToArray));
end;

procedure TBooruPostBase.SetThumbnail(const value: string);
begin
  FThumbnail := value;
end;

procedure TBooruPostBase.SetUploader(const value: string);
begin
  FUploader := value;
end;

end.

