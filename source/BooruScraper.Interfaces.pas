unit BooruScraper.Interfaces;

interface
uses
  Classes, Types, SysUtils, System.Generics.Collections;

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
    TagArtist
  );

  IAssignAndClone = Interface
    ['{3846D50D-A6DE-450D-A463-A6A54D898250}']
    { private / protected }
    procedure DoAssign(const ASource: IAssignAndClone);
    function GetClone: IAssignAndClone;
  End;

  TAssignAndCloneAr = TArray<IAssignAndClone>;

  IBooruThumb = Interface(IAssignAndClone)
    ['{074580BF-F36E-4DC4-BFF8-E02EA2EDE4E5}']
    { private }
    procedure SetId(const value: TBooruId);
    function GetId: TBooruId;
    procedure SetThumbnail(const value: string);
    function GetThumbnail: string;
    procedure SetTagsValues(const value: TArray<string>);
    function GetTagsValues: TArray<string>;
    { public }
    procedure Assign(const ASource: IBooruThumb);
    function Clone: IBooruThumb;
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
    procedure SetCount(const value: cardinal);
    function GetCount: cardinal;
    { public }
    procedure Assign(const Asource: IBooruTag);
    function Clone: IBooruTag;
    { public properties }
    /// <summary>Tag name that can be used for search.</summary>
    property Value: string read GetValue write SetValue;
    property Kind: TBooruTagType read GetKind write SetKind;
    /// <summary>Total posts count tagged with current tag.</summary>
    property Count: Cardinal read GetCount write SetCount;
  End;

  TBooruTagAr = TArray<IBooruTag>;
  TBooruTagList = TList<IBooruTag>;

  IBooruComment = Interface(IAssignAndClone)
    ['{9E91CCA0-CBF9-4F6D-B34A-85B586DFB2DC}']
    { private }
    procedure SetId(const value: TBooruId);
    function GetId: TBooruId;
    procedure SetUsername(const value: string);
    function GetUsername: string;
//    procedure SetUserUrl(const value: string);
//    function GetUserUrl: string;
    procedure SetTimestamp(const value: TDatetime);
    function GetTimestamp: TDatetime;
    procedure SetText(const value: string);
    function GetText: string;
    procedure SetScore(const value: TBooruScore);
    function GetScore: TBooruScore;
    { public }
    procedure Assign(const Asource: IBooruComment);
    function Clone: IBooruComment;
    { public properties }
    property Id: TBooruId read GetId write SetId;
    property Username: string read GetUsername write SetUsername;
//    property UserUrl: string read GetUserUrl write SetUserUrl;
    property Timestamp: TDatetime read GetTimestamp write SetTimestamp;
    property Text: string read GetText write SetText;
    property Score: TBooruScore read GetScore write SetScore;
  End;

  TBooruCommentAr = TArray<IBooruComment>;
  TBooruCommentList = TList<IBooruComment>;

  IBooruPost = Interface(IAssignAndClone)
    ['{F1F1BED9-9A91-49C2-A58B-CE4194945D57}']
    { private }
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
    procedure SetTags(const value: TBooruTagList);
    function GetTags: TBooruTagList;
    procedure SetComments(const value: TBooruCommentList);
    function GetComments: TBooruCommentList;
    { public }
    procedure Assign(const Asource: IBooruPost);
    function Clone: IBooruPost;
    function HasTag(AValue: string): boolean;
    function GetTagsByType(ATagType: TBooruTagType): TBooruTagAr;
    { public properties }
    property Id: TBooruId read GetId write SetId;
    /// <summary>Sample image.</summary>
    property Thumbnail: string read GetThumbnail write SetThumbnail;
    property TagsValues: TArray<string> read GetTagsValues;
    /// <summary>Link on full sized image (or video).</summary>
    property ContentUrl: string read GetContentUrl write SetContentUrl;
    property Score: TBooruScore read GetScore write SetScore;
//    property Timestamp: TDatetime read GetTimestamp write SetTimestamp;
    /// <summary>Uploader username.</summary>
    property Uploader: string read GetUploader write SetUploader;
    property Tags: TBooruTagList read GetTags write SetTags;
    property Comments: TBooruCommentList read GetComments write SetComments;
  End;

  TBooruPostAr = TArray<IBooruPost>;
  TBooruPostList = TList<IBooruPost>;

  /// <summary>Interface for all compatible parsers.</summary>
  TBooruParser = Class
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
    function GetPosts(ARequest: string; APage: integer = 0): TBooruThumbAr;
    /// <param name="APage">Page number (0 is a first page by default).</param>
    function GetPostComments(APostId: TBooruId; APage: integer = 0): TBooruCommentAr; overload;
    /// <param name="APage">Page number (0 is a first page by default).</param>
    function GetPostComments(AThumb: IBooruThumb; APage: integer = 0): TBooruCommentAr; overload;
    { public properties }
    /// <summary>Static class that being used for parse content from HTML pages.</summary>
    property BooruParser: TBooruParserClass read GetBooruParser write SetBooruParser;
    /// <summary>Base URL.</summary>
    property Host: string read GetHost write SetHost;
  End;

  TCloneMachine = Class
    public
      class function CloneAr<T: IAssignAndClone>(ASource: TArray<T>): TArray<T>; static;
  End;

const
  DEFAULT_BOORUID = -1;

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
      Result[I] := T(LRes.GetClone);
    end;
  end;
end;

end.
