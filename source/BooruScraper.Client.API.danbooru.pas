unit BooruScraper.Client.API.danbooru;

interface
uses
  Classes, Types, SysUtils, System.Generics.Collections,
  System.Net.URLClient, System.Net.HttpClientComponent, System.Net.HttpClient,
  BooruScraper.Interfaces, BooruScraper.ClientBase, BooruScraper.Urls,
  BooruScraper.Parser.API.danbooru;

type

  { https://danbooru.donmai.us/wiki_pages/help:api }
  TDanbooruAPIClient = Class(TBooruClientBase, IBooruClient)
    public
      function GetPost(AId: TBooruId): IBooruPost; override;
      function GetPosts(ARequest: string; APage: integer = BOORU_FIRSTPAGE; ALimit: integer = BOORU_NOTSET): TBooruThumbAr; override;
      function GetPostComments(APostId: TBooruId; APage: integer = BOORU_FIRSTPAGE; ALimit: integer = BOORU_NOTSET): TBooruCommentAr; override;
      constructor Create; override;
  End;

implementation

{ TDanbooruAPIClient }

constructor TDanbooruAPIClient.Create;
begin
  inherited;
  Host := DANBOORUDONMAIUS_URL;
  BooruParser := TDanbooruAPIParser;
end;

function TDanbooruAPIClient.GetPost(AId: TBooruId): IBooruPost;
var
  LUrl: TURI;
  LContent: string;
begin
  LUrl := TURI.Create(Host + '/posts/' + AId.ToString + '.json');

  LContent := Client.Get(LUrl.ToString).ContentAsString;
  Result := BooruParser.ParsePostFromPage(LContent);
end;

function TDanbooruAPIClient.GetPostComments(APostId: TBooruId;
  APage: integer; ALimit: integer): TBooruCommentAr;
var
  LUrl: TURI;
  LContent: string;
begin
  LUrl := TURI.Create(Host + '/comments.json');
  LUrl.AddParameter('search[post_id]', APostId.ToString);
  LUrl.AddParameter('page', (APage + 1).ToString);

  if (ALimit <> BOORU_NOTSET) then
    LUrl.AddParameter('limit', ALimit.ToString);

  LContent := Client.Get(LUrl.ToString).ContentAsString;
  Result := BooruParser.ParseCommentsFromPostPage(LContent);
end;

function TDanbooruAPIClient.GetPosts(ARequest: string; APage,
  ALimit: integer): TBooruThumbAr;
var
  LUrl: TURI;
  LContent: string;
begin
  LUrl := TURI.Create(Host + '/posts.json');
  LUrl.AddParameter('page', (APage + 1).ToString);

  if not ARequest.IsEmpty then
    LUrl.AddParameter('tags', ARequest);

  if (ALimit <> BOORU_NOTSET) then
    LUrl.AddParameter('limit', ALimit.ToString);

  LContent := Client.Get(LUrl.ToString).ContentAsString;
  Result := BooruParser.ParsePostsFromPage(LContent);
end;

end.
