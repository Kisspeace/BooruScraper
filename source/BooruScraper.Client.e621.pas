unit BooruScraper.Client.e621;

interface
uses
  Classes, Types, SysUtils, System.Generics.Collections,
  System.Net.URLClient, System.Net.HttpClientComponent, System.Net.HttpClient,
  BooruScraper.Interfaces, BooruScraper.ClientBase, BooruScraper.Urls,
  BooruScraper.Parser.Utils;

type

  Te621Client = Class(TBooruClientBase, IBooruClient)
    public
      function GetPost(AId: TBooruId): IBooruPost; override;
      function GetPosts(ARequest: string; APage: integer = BOORU_FIRSTPAGE; ALimit: integer = BOORU_NOTSET): TBooruThumbAr; override;
      function GetPostComments(APostId: TBooruId; APage: integer = BOORU_FIRSTPAGE; ALimit: integer = BOORU_NOTSET): TBooruCommentAr; override;
      constructor Create; override;
  End;

implementation

{ Te621Client }

constructor Te621Client.Create;
begin
  inherited;
  FHost := E621NET_URL;
end;

function Te621Client.GetPost(AId: TBooruId): IBooruPost;
var
  LContent: string;
  LUrl: TURI;
begin
  LUrl := TURI.Create(Self.Host + '/posts/' + AId.ToString);
  LContent := Self.Client.Get(LUrl.ToString).ContentAsString;
  Result := BooruParser.ParsePostFromPage(LContent);
end;

function Te621Client.GetPostComments(APostId: TBooruId; APage,
  ALimit: integer): TBooruCommentAr;
var
  LContent: string;
  LUrl: TURI;
begin
  LUrl := TURI.Create(Self.Host + '/posts/' + APostId.ToString);
  LContent := Self.Client.Get(LUrl.ToString).ContentAsString;
  Result := BooruParser.ParseCommentsFromPostPage(LContent);
end;

function Te621Client.GetPosts(ARequest: string; APage,
  ALimit: integer): TBooruThumbAr;
var
  LContent: string;
  LUrl: TURI;
begin
  LUrl := TURI.Create(Self.Host + '/posts');
  if APage > 0 then
    LUrl.AddParameter('page', (APage + 1).ToString);
  LUrl.AddParameter('tags', PrepareSearchReq(ARequest));
  LContent := Self.Client.Get(LUrl.ToString).ContentAsString;
  Result := BooruParser.ParsePostsFromPage(LContent);
end;

end.
