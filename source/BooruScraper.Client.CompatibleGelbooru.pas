unit BooruScraper.Client.CompatibleGelbooru;

interface
uses
  Classes, Types, SysUtils, System.Generics.Collections,
  System.Net.URLClient, System.Net.HttpClientComponent, System.Net.HttpClient,
  BooruScraper.Interfaces, BooruScraper.ClientBase;

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
  LContent: string;
  LUrl: TURI;
begin
  LUrl := TURI.Create(Self.Host + '/index.php?page=post&s=view');
  LUrl.AddParameter('id', AId.ToString);

  LContent := Client.Get(LUrl.ToString).ContentAsString;
  Result := BooruParser.ParsePostFromPage(LContent);
end;

function TGelbooruLikeClient.GetPostComments(APostId: TBooruId;
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

function TGelbooruLikeClient.GetPosts(ARequest: string;
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

function TGelbooruLikeClient.PageNumPostToPid(APage: integer): cardinal;
begin
  Result := COMMENTS_PER_POST_PAGE * APage;
end;

function TGelbooruLikeClient.PageNumToPid(APage: integer): cardinal;
begin
  Result := POSTS_PER_PAGE * APage;
end;

end.
