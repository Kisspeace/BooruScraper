unit BooruScraper.Client.API.TbibOrg;

interface
uses
  Classes, Types, SysUtils, System.Generics.Collections,
  System.Net.URLClient, System.Net.HttpClientComponent, System.Net.HttpClient,
  BooruScraper.Interfaces, BooruScraper.ClientBase,
  BooruScraper.Urls, BooruScraper.Parser.API.TbibOrg;

type

  { https://tbib.org/index.php?page=help&topic=dapi }
  TTbibAPIClient = Class(TBooruClientBase, IBooruClient)
    public
      function GetPost(AId: TBooruId): IBooruPost; override;
      function GetPosts(ARequest: string; APage: integer = BOORU_FIRSTPAGE; ALimit: integer = BOORU_NOTSET): TBooruThumbAr; override;
      function GetPostComments(APostId: TBooruId; APage: integer = BOORU_FIRSTPAGE; ALimit: integer = BOORU_NOTSET): TBooruCommentAr; override;
      constructor Create; override;
  End;

implementation

{ TTbibAPIClient }

constructor TTbibAPIClient.Create;
begin
  inherited;
  FHost := TBIBORG_URL;
  FBooruParser := TTbibOrgAPIParser;
end;

function TTbibAPIClient.GetPost(AId: TBooruId): IBooruPost;
var
  LUrl: TURI;
  LContent: string;
begin
  LUrl := TURI.Create(Host + '/index.php?page=dapi&s=post&q=index');
  LUrl.AddParameter('id', AId.ToString);

  LContent := Client.Get(LUrl.ToString).ContentAsString;
  Result := BooruParser.ParsePostFromPage(LContent);
end;

function TTbibAPIClient.GetPostComments(APostId: TBooruId;
  APage: integer; ALimit: integer): TBooruCommentAr;
var
  LUrl: TURI;
  LContent: string;
begin
  LUrl := TURI.Create(Host + '/index.php?page=dapi&s=comment&q=index');
  LUrl.AddParameter('post_id', APostId.ToString);

  LContent := Client.Get(LUrl.ToString).ContentAsString;
  Result := BooruParser.ParseCommentsFromPostPage(LContent);
end;

function TTbibAPIClient.GetPosts(ARequest: string; APage,
  ALimit: integer): TBooruThumbAr;
var
  LUrl: TURI;
  LContent: string;
begin
  LUrl := TURI.Create(Host + '/index.php?page=dapi&s=post&q=index');
  LUrl.AddParameter('pid', APage.ToString);

  if ALimit <> BOORU_NOTSET then
    LUrl.AddParameter('limit', ALimit.ToString);

  LContent := Client.Get(LUrl.ToString).ContentAsString;
  Result := BooruParser.ParsePostsFromPage(LContent);
end;

end.
