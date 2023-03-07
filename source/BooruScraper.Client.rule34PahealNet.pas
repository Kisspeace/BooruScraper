unit BooruScraper.Client.rule34PahealNet;

interface
uses
  Classes, Types, SysUtils, System.Generics.Collections,
  System.Net.URLClient, System.Net.HttpClientComponent, System.Net.HttpClient,
  BooruScraper.Interfaces, BooruScraper.ClientBase, BooruScraper.Urls;

type

  TRule34PahealNetClient = Class(TBooruClientBase, IBooruClient)
    public
      function GetPost(AId: TBooruId): IBooruPost; override;
      function GetPosts(ARequest: string; APage: integer = BOORU_FIRSTPAGE; ALimit: integer = BOORU_NOTSET): TBooruThumbAr; override;
      function GetPostComments(APostId: TBooruId; APage: integer = BOORU_FIRSTPAGE; ALimit: integer = BOORU_NOTSET): TBooruCommentAr; override;
      constructor Create; overload; override;
  End;

implementation

{ TRule34PahealNetClient }

constructor TRule34PahealNetClient.Create;
begin
  inherited;
  Self.FHost := RULE34PAHEALNET_URL;
end;

function TRule34PahealNetClient.GetPost(AId: TBooruId): IBooruPost;
var
  LContent: string;
  LUrl: string;
begin
  LUrl := Self.Host + '/post/view/' + AId.ToString;
  LContent := Client.Get(LUrl).ContentAsString;
  Result := BooruParser.ParsePostFromPage(LContent);
end;

function TRule34PahealNetClient.GetPostComments(APostId: TBooruId;
  APage: integer; ALimit: integer): TBooruCommentAr;
var
  LContent: string;
  LUrl: string;
begin
  LUrl := Self.Host + '/post/view/' + APostId.ToString;
  LContent := Client.Get(LUrl).ContentAsString;
  Result := BooruParser.ParseCommentsFromPostPage(LContent);
end;

function TRule34PahealNetClient.GetPosts(ARequest: string;
  APage: integer; ALimit: integer): TBooruThumbAr;
var
  LContent: string;
  LUrl: string;
begin
  APage := APage + 1; { First page is 1 }
  LUrl := Self.Host + '/post/list/';

  if not ARequest.IsEmpty then
    LUrl := LUrl + ARequest + '/';

  LUrl := LUrl + APage.ToString;

  LContent := Client.Get(LUrl).ContentAsString;
  Result := BooruParser.ParsePostsFromPage(LContent);
end;

end.
