unit BooruScraper.Client.CompatibleGelbooru;

interface
uses
  Classes, Types, SysUtils, System.Generics.Collections,
  BooruScraper.Interfaces, BooruScraper.ClientBase,
  RESTRequest4D;

const
  /// <summary>Base url for gelbooru.com.</summary>
  GELBOORU_URL = 'https://gelbooru.com';
  /// <summary>Base url for rule34.xxx.</summary>
  RULE34XXX_URL = 'https://rule34.xxx';
  /// <summary>Base url for rule34.xxx.</summary>
  REALBOORU_URL = 'https://rule34.us';

  /// <summary>Max thumbnails count given by one request.</summary>
  POSTS_PER_PAGE = 42;
  /// <summary>Max comments count given by one request.</summary>
  COMMENTS_PER_POST_PAGE = 10;

type

  TGelbooruLikeClient = Class(TBooruClientBase, IBooruClient)
    private
      function PageNumToPid(APage: integer): cardinal;
      function PageNumPostToPid(APage: integer): cardinal;
    public
      function GetPost(AId: TBooruId): IBooruPost; override;
      function GetPosts(ARequest: string; APage: integer = 0): TBooruThumbAr; override;
      function GetPostComments(APostId: TBooruId; APage: integer = 0): TBooruCommentAr; override;
      constructor Create; overload; override;
  End;

implementation

{ TRule34xxxClient }

constructor TGelbooruLikeClient.Create;
begin
  inherited;
  Self.Host := GELBOORU_URL;
end;

function TGelbooruLikeClient.GetPost(AId: TBooruId): IBooruPost;
var
  LRequest: IRequest;
  LResponse: IResponse;
  LContent: string;
begin
  LRequest := TRequest.New;
  LRequest.BaseURL(Self.Host + '/index.php?page=post&s=view')
    .AddParam('id', AId.ToString);

  BeforeDoingRequest(LRequest);
  LResponse := LRequest.Get;
  LContent := LResponse.Content;

  Result := BooruParser.ParsePostFromPage(LContent);
end;

function TGelbooruLikeClient.GetPostComments(APostId: TBooruId;
  APage: integer): TBooruCommentAr;
var
  LRequest: IRequest;
  LResponse: IResponse;
  LContent: string;
begin
  LRequest := TRequest.New;
  LRequest.BaseURL(Self.Host + '/index.php?page=post&s=view')
    .AddParam('id', APostId.ToString)
    .AddParam('pid', Self.PageNumPostToPid(APage).ToString);

  BeforeDoingRequest(LRequest);
  LResponse := LRequest.Get;
  LContent := LResponse.Content;

  Result := BooruParser.ParseCommentsFromPostPage(LContent);
end;

function TGelbooruLikeClient.GetPosts(ARequest: string;
  APage: integer): TBooruThumbAr;
var
  LRequest: IRequest;
  LResponse: IResponse;
  LContent: string;
begin
  LRequest := TRequest.New;
  LRequest.BaseURL(Self.Host + '/index.php?page=post&s=list')
    .AddParam('tags', ARequest)
    .AddParam('pid', Self.PageNumPostToPid(APage).ToString);

  BeforeDoingRequest(LRequest);
  LResponse := LRequest.Get;
  LContent := LResponse.Content;
//  Writeln(LResponse.ContentType + ' ' + LResponse.ContentEncoding + ' ' + lResponse.StatusCode.ToString + ' ' + LResponse.StatusText);
//  Writeln('Content Length: ' + LResponse.ContentLength.ToString);
//  Writeln(LResponse.Content);

  Result := BooruParser.ParsePostsFromPage(LContent);
end;

function TGelbooruLikeClient.PageNumPostToPid(APage: integer): cardinal;
begin
  Result := COMMENTS_PER_POST_PAGE * APage;
end;

function TGelbooruLikeClient.PageNumToPid(APage: integer): cardinal;
begin
  Result := POSTS_PER_PAGE * APage;
end;

end.
