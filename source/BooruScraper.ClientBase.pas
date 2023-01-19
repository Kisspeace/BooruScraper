unit BooruScraper.ClientBase;

interface
uses
  Classes, Types, SysUtils, System.Generics.Collections,
  System.Net.URLClient, System.Net.HttpClientComponent, System.Net.HttpClient,
  BooruScraper.Interfaces;

type

  TBooruClientBase = Class(TInterfacedObject, IBooruClient)
    private
      procedure SetHost(const value: string);
      function GetHost: string;
      procedure SetBooruParser(const value: TBooruParserClass);
      function GetBooruParser: TBooruParserClass;
    protected
      FHost: string;
      FBooruParser: TBooruParserClass;
    public
      Client: TNetHttpClient;
      function GetPost(const AThumb: IBooruThumb): IBooruPost; overload; virtual;
      function GetPosts(ARequest: string; APage: integer = 0): TBooruThumbAr; virtual; abstract;
      function GetPost(AId: TBooruId): IBooruPost; overload; virtual; abstract;
      function GetPostComments(APostId: TBooruId; APage: integer = 0): TBooruCommentAr; overload; virtual; abstract;
      function GetPostComments(AThumb: IBooruThumb; APage: integer = 0): TBooruCommentAr; overload; virtual;
      { --------------------- }
      property BooruParser: TBooruParserClass read GetBooruParser write SetBooruParser;
      property Host: string read GetHost write SetHost;
      constructor Create; overload; virtual;
      constructor Create(AParser: TBooruParserClass; AHost: string) overload; virtual;
      destructor Destroy; override;
  End;

  TBooruClientBaseClass = Class of TBooruClientBase;

implementation

{ TBooruClientBase }

constructor TBooruClientBase.Create;
begin
  Client := TNetHttpClient.Create(nil);
  Client.Asynchronous := False;
  Client.AutomaticDecompression := [THTTPCompressionMethod.Any];
end;

constructor TBooruClientBase.Create(AParser: TBooruParserClass; AHost: string);
begin
  Self.Create;
  Self.BooruParser := AParser;
  Self.Host := AHost;
end;

destructor TBooruClientBase.Destroy;
begin
  FreeAndNil(Client);
  inherited;
end;

function TBooruClientBase.GetBooruParser: TBooruParserClass;
begin
  Result := FBooruParser;
end;

function TBooruClientBase.GetHost: string;
begin
  Result := FHost;
end;

function TBooruClientBase.GetPost(const AThumb: IbooruThumb): IBooruPost;
begin
  Result := Self.GetPost(AThumb.Id);
end;

procedure TBooruClientBase.SetBooruParser(const value: TBooruParserClass);
begin
  FBooruParser := value;
end;

procedure TBooruClientBase.SetHost(const value: string);
begin
  FHost := value;
end;

function TBooruClientBase.GetPostComments(AThumb: IBooruThumb; APage: integer): TBooruCommentAr;
begin
  Result := Self.GetPostComments(AThumb.Id);
end;

end.
