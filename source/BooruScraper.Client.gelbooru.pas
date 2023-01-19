unit BooruScraper.Client.gelbooru;

interface
uses
  Classes, Types, SysUtils, System.Generics.Collections,
  System.Net.URLClient, System.Net.HttpClientComponent, System.Net.HttpClient,
  BooruScraper.Interfaces, BooruScraper.ClientBase;

const
  /// <summary>Base url for gelbooru.com.</summary>
  GELBOORU_URL = 'https://gelbooru.com';
  /// <summary>Max thumbnails count given by one request.</summary>
  POSTS_PER_PAGE = 42;
  /// <summary>Max comments count given by one request.</summary>
  COMMENTS_PER_POST_PAGE = 10;

type

  TGelbooruClient = Class(TBooruClientBase, IBooruClient)
    private
      function PageNumToPid(APage: integer): cardinal;
      function PageNumPostToPid(APage: integer): cardinal;
    public
      function GetPost(AId: TBooruId): IBooruPost; override;
      function GetPosts(ARequest: string; APage: integer = 0): TBooruThumbAr; override;
      function GetPostComments(APostId: TBooruId; APage: integer = 0): TBooruCommentAr; override;
      constructor Create; override;
  End;

implementation

{ TRule34xxxClient }

constructor TGelbooruClient.Create;
begin
  inherited;
  Self.Host := GELBOORU_URL;
end;

function TGelbooruClient.GetPost(AId: TBooruId): IBooruPost;
var
  LContent: string;
  LUrl: TURI;
begin
  LUrl := TURI.Create(Self.Host + '/index.php?page=post&s=view');
  LUrl.AddParameter('id', AId.ToString);

  LContent := Client.Get(LUrl.ToString).ContentAsString;
  Result := BooruParser.ParsePostFromPage(LContent);
end;

function TGelbooruClient.GetPostComments(APostId: TBooruId;
  APage: integer): TBooruCommentAr;
var
  LContent: string;
  LUrl: TURI;
begin
  LUrl := TURI.Create(Self.Host + '/index.php?page=post&s=view');
  LUrl.AddParameter('id', APostId.ToString);
  LUrl.AddParameter('pid', Self.PageNumPostToPid(APage).ToString);

  LContent := Client.Get(LUrl.ToString).ContentAsString;
  Result := BooruParser.ParseCommentsFromPostPage(LContent);
end;

function TGelbooruClient.GetPosts(ARequest: string;
  APage: integer): TBooruThumbAr;
var
  LContent: string;
  LUrl: TURI;
begin
  LUrl := TURI.Create(Self.Host + '/index.php?page=post&s=list');
  LUrl.AddParameter('tags', ARequest);
  LUrl.AddParameter('pid', PageNumToPid(APage).ToString);

  LContent := Client.Get(LUrl.ToString).ContentAsString;
  Result := BooruParser.ParsePostsFromPage(LContent);
end;

function TGelbooruClient.PageNumPostToPid(APage: integer): cardinal;
begin
  Result := COMMENTS_PER_POST_PAGE * APage;
end;

function TGelbooruClient.PageNumToPid(APage: integer): cardinal;
begin
  Result := POSTS_PER_PAGE * APage;
end;

end.
