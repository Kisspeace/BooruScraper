unit BooruScraper.Client.rule34PahealNet;

interface
uses
  Classes, Types, SysUtils, System.Generics.Collections,
  System.Net.URLClient, System.Net.HttpClientComponent, System.Net.HttpClient,
  BooruScraper.Interfaces, BooruScraper.ClientBase;

const
  /// <summary>Base url for rule34.xxx.</summary>
  RULE34PAHEALNET_URL = 'https://rule34.paheal.net';

type

  TRule34PahealNetClient = Class(TBooruClientBase, IBooruClient)
    public
      function GetPost(AId: TBooruId): IBooruPost; override;
      function GetPosts(ARequest: string; APage: integer = 0): TBooruThumbAr; override;
      function GetPostComments(APostId: TBooruId; APage: integer = 0): TBooruCommentAr; override;
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
  APage: integer): TBooruCommentAr;
var
  LContent: string;
  LUrl: string;
begin
  LUrl := Self.Host + '/post/view/' + APostId.ToString;
  LContent := Client.Get(LUrl).ContentAsString;
  Result := BooruParser.ParseCommentsFromPostPage(LContent);
end;

function TRule34PahealNetClient.GetPosts(ARequest: string;
  APage: integer): TBooruThumbAr;
var
  LContent: string;
  LUrl: string;
begin
  APage := APage + 1; { First page is 1 }
  LUrl := Self.Host + '/post/list/' + ARequest + '/' + APage.ToString;

  LContent := Client.Get(LUrl).ContentAsString;
  Result := BooruParser.ParsePostsFromPage(LContent);
end;

end.
