unit BooruScraper.Client.KenzatoUk;

interface
uses
  Classes, Types, SysUtils, System.Generics.Collections,
  System.Net.URLClient, System.Net.HttpClientComponent, System.Net.HttpClient,
  BooruScraper.Interfaces, BooruScraper.ClientBase, BooruScraper.Urls,
  BooruScraper.Parser.KenzatoUk;

type

  TKenzatoUkSearchOpt = Record
    public type
      TCategory = (CatRecent, CatTrending, CatPopular, CatAnimated,
        CatAll, CatHS, CatHSScene, CatPH, CatPHScene,
        CatKK, CatKKScene, CatHSU, CatHSUScene, CatFrameBacks, CatAICARD,
        CatAIScenes, CatHS2, CatHS2Scene, CatRGC, CatRGScenes, CatRandom);
    private
      function Build(const AHost: string; APage: integer): TURI;
    public
      Query: string;
      EPQuery: string;
      EQuery: string;
      Category: TCategory;
      Seek: string;
      function CategoryAsString: string;
      function BuildUrl(const AHost: string; APage: integer): string;
      class function Create(ACategory: TCategory = CatRecent): TKenzatoUkSearchOpt; static;
  end;

  IKenzatoUkClient = Interface(IBooruClient)
    ['{A5BA1AD8-EAEF-452F-AEC6-566B2D25E2C4}']
    { private / protected }
    procedure SetSearchOptions(const value: TKenzatoUkSearchOpt);
    function GetSearchOptions: TKenzatoUkSearchOpt;
    { public }
    property SearchOptions: TKenzatoUkSearchOpt read GetSearchOptions write SetSearchOptions;
  End;

  TKenzatoUkClient = Class(TBooruClientBase, IKenzatoUkClient)
    protected
      FSearchOpt: TKenzatoUkSearchOpt;
      procedure SetSearchOptions(const value: TKenzatoUkSearchOpt);
      function GetSearchOptions: TKenzatoUkSearchOpt;
    public
      function GetPost(const AThumb: IBooruThumb): IBooruPost; override;
      function GetPosts(ARequest: string; APage: integer = BOORU_FIRSTPAGE; ALimit: integer = BOORU_NOTSET): TBooruThumbAr; override;
      function GetPostComments(APostId: TBooruId; APage: integer = BOORU_FIRSTPAGE; ALimit: integer = BOORU_NOTSET): TBooruCommentAr; override;
      constructor Create; overload; override;
  End;

implementation

{ TKenzatoUkSearchOpt }

function TKenzatoUkSearchOpt.Build(const AHost: string; APage: integer): TURI;
begin
  Result := TURI.Create(AHost);
  with Result do begin

    if Query.IsEmpty and EQuery.IsEmpty and EPQuery.IsEmpty then
    begin
      Result.Path := Result.Path +  CategoryAsString;
    end else begin
      Result.Path := Result.Path + '/search/images/';
      AddParameter('as_q', Query);
      AddParameter('as_epq', EPQuery);
      AddParameter('as_eq', EQuery);
      AddParameter('as_cat', CategoryAsString);
    end;

    if not Seek.IsEmpty then
    begin
      if APage > 1 then
        AddParameter('page', APage.ToString);
      AddParameter('seek', Seek);
    end;
  end;
end;

function TKenzatoUkSearchOpt.BuildUrl(const AHost: string; APage: integer): string;
begin
  Result := Build(AHost, APage).ToString;
end;

function TKenzatoUkSearchOpt.CategoryAsString: string;
begin
  case Category of
    CatRecent:     Result := '/explore/recent';
    CatTrending:   Result := '/explore/trending';
    CatPopular:    Result := '/explore/popular';
    CatAnimated:   Result := '/explore/animated';
    CatAll:        Result := '';
    CatHS:         Result := 'HS';
    CatHSScene:    Result := 'HSscene';
    CatPH:         Result := 'PH';
    CatPHScene:    Result := 'PHscene';
    CatKK:         Result := 'KK';
    CatKKScene:    Result := 'KKscene';
    CatHSU:        Result := 'HSU';
    CatHSUScene:   Result := 'HSUscene';
    CatFrameBacks: Result := 'frame-Backs';
    CatAICARD:     Result := 'AICARD';
    CatAIScenes:   Result := 'AISCENES';
    CatHS2:        Result := 'HS2';
    CatHS2Scene:   Result := 'HS2Scene';
    CatRGC:        Result := 'RGC';
    CatRGScenes:   Result := 'RGScenes';
    CatRandom:     Result := 'Random';
  end;
end;

class function TKenzatoUkSearchOpt.Create(
  ACategory: TCategory): TKenzatoUkSearchOpt;
begin
  with Result do begin
    Category := ACategory;
    Query := '';
    EPQuery := '';
    EQuery := '';
    Seek := '';
  end;
end;

{ TKenzatoUkClient }

constructor TKenzatoUkClient.Create;
begin
  inherited;
  FHost := KENZATOUKBOORU_URL;
  FBooruParser := TKenzatoUkParser;
  FSearchOpt := TKenzatoUkSearchOpt.Create;
end;

function TKenzatoUkClient.GetPost(const AThumb: IBooruThumb): IBooruPost;
var
  LIdStr: IIdString;
  LContent: String;
begin
  if not Supports(AThumb, IIdString, LIdStr) then Exit(Nil);
  LContent := Client.Get(FHost + '/image/' + LIdStr.Id).ContentAsString;
  Result := BooruParser.ParsePostFromPage(LContent);
end;

function TKenzatoUkClient.GetPostComments(APostId: TBooruId; APage,
  ALimit: integer): TBooruCommentAr;
begin
  { Nothing to do. }
end;

function TKenzatoUkClient.GetPosts(ARequest: string; APage,
  ALimit: integer): TBooruThumbAr;
var
  LContent: string;
  LUrl: TURI;
begin
  if APage < 1 then
    FSearchOpt.Seek := '';
  LUrl := FSearchOpt.Build(FHost, APage + 1);
  LContent := Client.Get(LUrl.ToString).ContentAsString;
  Result := BooruParser.ParsePostsFromPage(LContent);
end;

function TKenzatoUkClient.GetSearchOptions: TKenzatoUkSearchOpt;
begin
  Result := FSearchOpt;
end;

procedure TKenzatoUkClient.SetSearchOptions(const value: TKenzatoUkSearchOpt);
begin
  FSearchOpt := value;
end;

end.
