unit BooruScraper.Interfaces;

interface
uses
  Classes, Types, SysUtils, System.Generics.Collections,
  BooruScraper.Exceptions;

const
  BOORU_FIRSTPAGE = 0;
  BOORU_NOTSET = -1;

type

  TBooruId = Int64;
  TBooruScore = Integer;

  /// <summary>
  ///    TagGeneral - General tag about content.
  ///    TagCopyright - Tag about copyright owners.
  ///    TagMetadata - Meta data about content (file format for example).
  ///    TagCharacter - Character name.
  ///    TagArtist - Artist (content creator) name.
  /// </summary>
  TBooruTagType = (
    TagGeneral,
    TagCopyright,
    TagMetadata,
    TagCharacter,
    TagArtist,
    { new e621 types below }
    TagSpecies,
    TagInvalid,
    TagLore
  );

  IAssignAndClone = Interface
    ['{3846D50D-A6DE-450D-A463-A6A54D898250}']
    { public }
    procedure Assign(const ASource: IAssignAndClone);
    function Clone: IAssignAndClone;
  End;

  TAssignAndCloneAr = TArray<IAssignAndClone>;

  IIdString = Interface
    ['{B198E7A3-A001-4881-84B3-D1EE281375F4}']
    { private }
    procedure SetId(const value: string);
    function GetId: string;
    { public }
    property Id: string read GetId write SetId;
  End;

  IBooruThumb = Interface(IAssignAndClone)
    ['{074580BF-F36E-4DC4-BFF8-E02EA2EDE4E5}']
    { private }
    procedure SetId(const value: TBooruId);
    function GetId: TBooruId;
    procedure SetThumbnail(const value: string);
    function GetThumbnail: string;
    procedure SetTagsValues(const value: TArray<string>);
    function GetTagsValues: TArray<string>;
    { public properties }
    property Id: TBooruId read GetId write SetId;
    /// <summary>Link on thumbnail image.</summary>
    property Thumbnail: string read GetThumbnail write SetThumbnail;
    property TagsValues: TArray<string> read GetTagsValues write SetTagsValues;
  End;

  TBooruThumbAr = TArray<IBooruThumb>;
  TBooruThumbList = TList<IBooruThumb>;

  IBooruTag = Interface(IAssignAndClone)
    ['{94B2E413-8D15-484A-A385-A923CDEDC42E}']
    { private }
    procedure SetValue(const value: string);
    function GetValue: string;
    procedure SetKind(const value: TBooruTagType);
    function GetKind: TBooruTagType;
    procedure SetCount(const value: int64);
    function GetCount: int64;
    { public }
    procedure Assign(const Asource: IAssignAndClone);
    function Clone: IAssignAndClone;
    { public properties }
    /// <summary>Tag name that can be used for search.</summary>
    property Value: string read GetValue write SetValue;
    property Kind: TBooruTagType read GetKind write SetKind;
    /// <summary>Total posts count tagged with current tag.</summary>
    property Count: int64 read GetCount write SetCount;
  End;

  TBooruTagAr = TArray<IBooruTag>;
  TBooruTagList = TList<IBooruTag>;

  IBooruComment = Interface(IAssignAndClone)
    ['{9E91CCA0-CBF9-4F6D-B34A-85B586DFB2DC}']
    { private }
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
    { public }
    procedure Assign(const Asource: IAssignAndClone);
    function Clone: IAssignAndClone;
    { public properties }
    property Id: TBooruId read GetId write SetId;
    property PostId: TBooruId read GetPostId write SetPostId;
    property CreatorId: TBooruId read GetCreatorId write SetCreatorId;
    property Username: string read GetUsername write SetUsername;
    property Timestamp: TDatetime read GetTimestamp write SetTimestamp;
    property Text: string read GetText write SetText;
    property Score: TBooruScore read GetScore write SetScore;
    property IsDeleted: boolean read GetIsDeleted write SetIsDeleted;
  End;

  TBooruCommentAr = TArray<IBooruComment>;
  TBooruCommentList = TList<IBooruComment>;

  IBooruPost = Interface(IBooruThumb)
    ['{F1F1BED9-9A91-49C2-A58B-CE4194945D57}']
    { private \ protected }
    procedure SetId(const value: TBooruId);
    function GetId: TBooruId;
    procedure SetThumbnail(const value: string);
    function GetThumbnail: string;
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
    { public }
    procedure Assign(const Asource: IAssignAndClone);
    function Clone: IAssignAndClone;
    function HasTag(AValue: string): boolean;
    function GetTagsByType(ATagType: TBooruTagType): TBooruTagAr;
    { public properties }
    property Id: TBooruId read GetId write SetId;
    /// <summary>Preview image url (if available).</summary>
    property Thumbnail: string read GetThumbnail write SetThumbnail;
    property TagsValues: TArray<string> read GetTagsValues;
    /// <summary>Link on full sized image (or video).</summary>
    property ContentUrl: string read GetContentUrl write SetContentUrl;
    property SampleUrl: string read GetSampleUrl write SetSampleUrl;
    property Score: TBooruScore read GetScore write SetScore;
    /// <summary>Uploader username.</summary>
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
  End;

  TBooruPostAr = TArray<IBooruPost>;
  TBooruPostList = TList<IBooruPost>;

  /// <summary>Interface for all compatible parsers.</summary>
  TBooruParser = Class
    protected
      ///<summary>
      ///except
      ///  On E: Exception do
      ///   if not HandleExcept(E, 'MethodName') then raise;
      ///end;
      ///</summary>
      class function HandleExcept(E: Exception; AMethodName: string): boolean;
    public
      /// <summary>Parse thumbnail items from HTML page.</summary>
      class function ParsePostsFromPage(const ASource: string): TBooruThumbAr; virtual; abstract;
      /// <summary>Parse full post data from HTML page.</summary>
      class function ParsePostFromPage(const ASource: string): IBooruPost; virtual; abstract;
      /// <summary>Parse only comments from HTML page.</summary>
      class function ParseCommentsFromPostPage(const ASource: string): TBooruCommentAr; virtual; abstract;
  End;

  TBooruParserClass = Class of TBooruParser;

  IBooruClient = Interface
    ['{086EE7FB-21E2-4B37-8BB9-E7691B8D26C0}']
    { private }
    procedure SetHost(const value: string);
    function GetHost: string;
    procedure SetBooruParser(const value: TBooruParserClass);
    function GetBooruParser: TBooruParserClass;
    { public }
    function GetPost(const AThumb: IBooruThumb): IBooruPost; overload;
    function GetPost(AId: TBooruId): IBooruPost; overload;
    /// <summary>Returns info about post</summary>
    /// <param name="ARequest">Text request (tag names separated by whitespace).</param>
    /// <param name="APage">Page number (0 is a first page by default).</param>
    function GetPosts(ARequest: string; APage: integer = BOORU_FIRSTPAGE; ALimit: integer = BOORU_NOTSET): TBooruThumbAr;
    /// <param name="APage">Page number (0 is a first page by default).</param>
    function GetPostComments(APostId: TBooruId; APage: integer = BOORU_FIRSTPAGE; ALimit: integer = BOORU_NOTSET): TBooruCommentAr; overload;
    /// <param name="APage">Page number (0 is a first page by default).</param>
    function GetPostComments(AThumb: IBooruThumb; APage: integer = BOORU_FIRSTPAGE; ALimit: integer = BOORU_NOTSET): TBooruCommentAr; overload;
    { public properties }
    /// <summary>Static class that being used for parse content from HTML pages.</summary>
    property BooruParser: TBooruParserClass read GetBooruParser write SetBooruParser;
    /// <summary>Base URL.</summary>
    property Host: string read GetHost write SetHost;
  End;

  IEnableAllContent = Interface
    ['{3FE23949-71AC-4055-B579-6BF517B71EA2}']
    { private }
    procedure SetEnableAllContent(const value: boolean);
    function GetEnableAllContent: boolean;
    { public }
    /// <summary>Gelbooru: "This will enable access to more fringe results".</summary>
    property EnableAllContent: boolean read GetEnableAllContent write SetEnableAllContent;
  End;

  TCloneMachine = Class
    public
      class function CloneAr<T: IAssignAndClone>(ASource: TArray<T>): TArray<T>; static;
  End;

implementation

{ TCloneMachine }

class function TCloneMachine.CloneAr<T>(ASource: TArray<T>): TArray<T>;
var
  I: Integer;
  LRes: IAssignAndClone;
begin
  SetLength(Result, Length(ASource));
  for I := 0 to High(ASource) do begin
    if Supports(ASource[I], IAssignAndClone, LRes) then begin
      Result[I] := T(LRes.Clone);
    end;
  end;
end;

{ TBooruParser }

class function TBooruParser.HandleExcept(E: Exception; AMethodName: string): boolean;
begin
  if not (E is EBooruScraperException) then
  begin
    Result := True;
    Raise EBooruScraperParsingException.CreateFmt(
      '%s ~ %s ~ %s: %s',
      [E.ClassName, Self.ClassName, AMethodName, E.Message]
    );
  end else Result := False;
end;

end.
