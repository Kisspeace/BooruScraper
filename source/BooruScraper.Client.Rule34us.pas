unit BooruScraper.Client.Rule34us;

interface
uses
  Classes, Types, SysUtils, System.Generics.Collections,
  BooruScraper.Interfaces, BooruScraper.ClientBase,
  RESTREquest4D;

const
  /// <summary>Base url for rule34.xxx.</summary>
  RULE34US_URL = 'https://rule34.us';

type

  TRule34usClient = Class(TBooruClientBase, IBooruClient)
    public
      function GetPost(AId: TBooruId): IBooruPost; override;
      function GetPosts(ARequest: string; APage: integer = 0): TBooruThumbAr; override;
      function GetPostComments(APostId: TBooruId; APage: integer = 0): TBooruCommentAr; override;
      constructor Create; overload; override;
  End;

implementation

{ TRule34usClient }

constructor TRule34usClient.Create;
begin
  inherited;
  Self.Host := RULE34US_URL;
end;

function TRule34usClient.GetPost(AId: TBooruId): IBooruPost;
var
  LRequest: IRequest;
  LResponse: IResponse;
  LContent: string;
begin
  LRequest := TRequest.New;
  LRequest.BaseURL(Self.Host + '/index.php?r=posts/view')
    .AddParam('id', AId.ToString);

  BeforeDoingRequest(LRequest);
  LResponse := LRequest.Get;
  LContent := LResponse.Content;

  Result := BooruParser.ParsePostFromPage(LContent);
end;

function TRule34usClient.GetPostComments(APostId: TBooruId;
  APage: integer): TBooruCommentAr;
var
  LRequest: IRequest;
  LResponse: IResponse;
  LContent: string;
begin
  LRequest := TRequest.New;
  LRequest.BaseURL(Self.Host + '/index.php?r=posts/view')
    .AddParam('id', APostId.ToString)
    .AddParam('page', APage.ToString);

  BeforeDoingRequest(LRequest);
  LResponse := LRequest.Get;
  LContent := LResponse.Content;

  Result := BooruParser.ParseCommentsFromPostPage(LContent);
end;

function TRule34usClient.GetPosts(ARequest: string;
  APage: integer): TBooruThumbAr;
var
  LRequest: IRequest;
  LResponse: IResponse;
  LContent: string;
begin
  LRequest := TRequest.New;
  LRequest.BaseURL(Self.Host + '/index.php?r=posts/index')
    .AddParam('q', ARequest)
    .AddParam('page', APage.ToString);

  BeforeDoingRequest(LRequest);
  LResponse := LRequest.Get;
  LContent := LResponse.Content;

  Result := BooruParser.ParsePostsFromPage(LContent);
end;

end.
