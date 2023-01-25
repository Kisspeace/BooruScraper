unit BooruScraper.ClientBase;

interface
uses
  Classes, Types, SysUtils, System.Generics.Collections,
  BooruScraper.Interfaces, RESTRequest4D;

type

  TRESTRequestEvent = Procedure (var ARequest: IRequest) of object;

  IRR4DClient = Interface
    ['{482F30C7-4CAF-489E-BB06-6565911833D8}']
    { private / protected }
    procedure SetBeforeRequest(const Value: TRESTRequestEvent);
    function GetBeforeRequest: TRESTRequestEvent;
    { public }
    property BeforeRequest: TRESTRequestEvent read GetBeforeRequest write SetBeforeRequest;
  End;

  TBooruClientBase = Class(TInterfacedObject, IBooruClient, IRR4DClient)
    private
      procedure SetHost(const value: string);
      function GetHost: string;
      procedure SetBooruParser(const value: TBooruParserClass);
      function GetBooruParser: TBooruParserClass;
      procedure SetBeforeRequest(const Value: TRESTRequestEvent);
      function GetBeforeRequest: TRESTRequestEvent;
    protected
      FHost: string;
      FBooruParser: TBooruParserClass;
      FBeforeRequest: TRESTRequestEvent;
      procedure BeforeDoingRequest(var ARequest: IRequest);
    public
      function GetPost(const AThumb: IBooruThumb): IBooruPost; overload; virtual;
      function GetPosts(ARequest: string; APage: integer = 0): TBooruThumbAr; virtual; abstract;
      function GetPost(AId: TBooruId): IBooruPost; overload; virtual; abstract;
      function GetPostComments(APostId: TBooruId; APage: integer = 0): TBooruCommentAr; overload; virtual; abstract;
      function GetPostComments(AThumb: IBooruThumb; APage: integer = 0): TBooruCommentAr; overload; virtual;
      { --------------------- }
      property BooruParser: TBooruParserClass read GetBooruParser write SetBooruParser;
      property Host: string read GetHost write SetHost;
      property BeforeRequest: TRESTRequestEvent read GetBeforeRequest write SetBeforeRequest;
      constructor Create; overload; virtual;
      constructor Create(AParser: TBooruParserClass; AHost: string) overload; virtual;
      destructor Destroy; override;
  End;

  TBooruClientBaseClass = Class of TBooruClientBase;

implementation

{ TBooruClientBase }

constructor TBooruClientBase.Create;
begin

end;

procedure TBooruClientBase.BeforeDoingRequest(var ARequest: IRequest);
begin
  If Assigned(BeforeRequest) then
    BeforeRequest(ARequest);
end;

constructor TBooruClientBase.Create(AParser: TBooruParserClass; AHost: string);
begin
  Self.Create;
  Self.BooruParser := AParser;
  Self.Host := AHost;
end;

destructor TBooruClientBase.Destroy;
begin
  inherited;
end;

function TBooruClientBase.GetBeforeRequest: TRESTRequestEvent;
begin
  Result := FBeforeRequest;
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

procedure TBooruClientBase.SetBeforeRequest(const Value: TRESTRequestEvent);
begin
  FBeforeRequest := Value;
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
