unit BooruScraper.Client.Rule34us;

interface
uses
  Classes, Types, SysUtils, System.Generics.Collections,
  System.Net.URLClient, System.Net.HttpClientComponent, System.Net.HttpClient,
  BooruScraper.Interfaces, BooruScraper.ClientBase;

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
  LContent: string;
  LUrl: TURI;
begin
  LUrl := TURI.Create(Self.Host + '/index.php?r=posts/view');
  LUrl.AddParameter('id', AId.ToString);

  LContent := Client.Get(LUrl.ToString).ContentAsString;
  Result := BooruParser.ParsePostFromPage(LContent);
end;

function TRule34usClient.GetPostComments(APostId: TBooruId;
  APage: integer): TBooruCommentAr;
var
  LContent: string;
  LUrl: TURI;
begin
  LUrl := TURI.Create(Self.Host + '/index.php?r=posts/view');
  LUrl.AddParameter('id', APostId.ToString);
  LUrl.AddParameter('page', APage.ToString);

  LContent := Client.Get(LUrl.ToString).ContentAsString;
  Result := BooruParser.ParseCommentsFromPostPage(LContent);
end;

function TRule34usClient.GetPosts(ARequest: string;
  APage: integer): TBooruThumbAr;
var
  LContent: string;
  LUrl: TURI;
begin
  LUrl := TURI.Create(Self.Host + '/index.php?r=posts/index');
  LUrl.AddParameter('q', ARequest);
  LUrl.AddParameter('page', APage.ToString);

  LContent := Client.Get(LUrl.ToString).ContentAsString;
  Result := BooruParser.ParsePostsFromPage(LContent);
end;

end.
