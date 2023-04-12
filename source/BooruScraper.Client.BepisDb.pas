unit BooruScraper.Client.BepisDb;

interface
uses
  Classes, Types, SysUtils, System.Generics.Collections,
  System.Net.URLClient, System.Net.HttpClientComponent, System.Net.HttpClient,
  BooruScraper.Interfaces, BooruScraper.ClientBase, BooruScraper.Urls,
  BooruScraper.Parser.BepisDb;

type

  TBepisDbSearchOpt = Record
    public type
      TSubject = (KoikatsuCards, KoikatsuScenes, KoikatsuClothing,
        AA2Cards, AA2Scenes, HoneySelectCards, PlayHomeCards,
        AIHS2Cards, AIHS2Scenes, COM3D2Cards, SummerHeatCards);
    public type
      TGender = (GendUnspecified, GendFemale, GendMale);
      { on site - PersSexy = 0 .. PersPerfectionist = 38  }
      TKoikatsuPersonality = (PersUnspecified, PersSexy, PersOjousama, PersSnobby,
        PersKouhai, PersMysterious, PersWeirdo, PersYamatoNadeshiko,
        PersTomboy, PersPure, PersSimple, PersDelusional, PersMotherly,
        PersBigSisterly, PersGyaru, PersDelinquent, PersWild,
        PersWannabe, PersReluctant, PersJinxed, PersBookish,
        PersTimid, PersTypicalSchoolgirl, PersTrendy, PersOtaku,
        PersYandere, PersLazy, PersQuiet, PersStubborn, PersOldFashioned,
        PersHumble, PersFriendly, PersWillful, PersHonest, PersGlamorous,
        PersReturnee, PersSlangy, PersSadistic, PersEmotionless,
        PersPerfectionist);
      TKoikatsuGameType = (GameUnspecified, GameBase, GameSteam, GameSteam18,
        GameEmotionCreators, GameSunshine);
      THoneySelectGameType = (HSGameUnspecified, HSGameNeo, HSGameClassic);
      TOrderBy = (OrderDateDescending, OrderDateAscending, OrderPopularity);
    public type
      TCharacterCountRange = record
        Min: integer;
        Max: integer;
        function AsString: string;
        class function Create(AMin: integer = 0; AMax: integer = 0): TCharacterCountRange; static;
      end;
    private
      function Build(const AHost: string): TURI;
    public
      Subject: TSubject;
      Name: string;
      Tags: string;
      OrderBy: TOrderBy;
      Gender: TGender;
      KoikatsuPersonality: TKoikatsuPersonality;
      KoikatsuGameType: TKoikatsuGameType;
      HoneySelectGameType: THoneySelectGameType;
      DoesNotContainModdedContent: boolean;
      ShowHidden: boolean;
      ShowOnlyFeatured: boolean;
      FemaleCharacterCount: TCharacterCountRange; { KoikatsuScenes, AIHS2Scenes }
      MaleCharacterCount: TCharacterCountRange; { KoikatsuScenes, AIHS2Scenes }
      function SubjectAsString: string;
      function GenderAsString: string;
      function PersonalityAsInt: byte;
      function OrderByAsString: string;
      function GameTypeAsString: string;
      function BuildUrl(const AHost: string): string;
      class function Create(ASubject: TSubject = KoikatsuCards): TBepisDbSearchOpt; static;
  end;

  IBepisDbClient = Interface(IBooruClient)
    ['{A5BA1AD8-EAEF-452F-AEC6-566B2D25E2C4}']
    { private / protected }
    procedure SetSearchOptions(const value: TBepisDbSearchOpt);
    function GetSearchOptions: TBepisDbSearchOpt;
    { public }
    property SearchOptions: TBepisDbSearchOpt read GetSearchOptions write SetSearchOptions;
  End;

  TBepisDbClient = Class(TBooruClientBase, IBepisDbClient)
    protected
      FSearchOpt: TBepisDbSearchOpt;
      procedure SetSearchOptions(const value: TBepisDbSearchOpt);
      function GetSearchOptions: TBepisDbSearchOpt;
    public
      function GetPost(AId: TBooruId): IBooruPost; override;
      function GetPosts(ARequest: string; APage: integer = BOORU_FIRSTPAGE; ALimit: integer = BOORU_NOTSET): TBooruThumbAr; override;
      function GetPostComments(APostId: TBooruId; APage: integer = BOORU_FIRSTPAGE; ALimit: integer = BOORU_NOTSET): TBooruCommentAr; override;
      constructor Create; overload; override;
  End;

implementation

{ TBepisDbClient }

constructor TBepisDbClient.Create;
begin
  inherited;
  FHost := DBBEPISMOE_URL;
  FSearchOpt := TBepisDbSearchOpt.Create;
  FBooruParser := TBepisDbParser;
end;

function TBepisDbClient.GetPost(AId: TBooruId): IBooruPost;
var
  LContent: string;
begin
  LContent := Client.Get(FHost + '/' + FSearchOpt.SubjectAsString
    + '/view/' + AId.ToString).ContentAsString;
  Result := BooruParser.ParsePostFromPage(LContent);
end;

function TBepisDbClient.GetPostComments(APostId: TBooruId; APage,
  ALimit: integer): TBooruCommentAr;
begin

end;

function TBepisDbClient.GetPosts(ARequest: string; APage,
  ALimit: integer): TBooruThumbAr;
var
  LContent: string;
  LUrl: TURI;
begin
  LUrl := FSearchOpt.Build(FHost);
  if APage > 0 then
    LUrl.AddParameter('page', (APage + 1).ToString);
  LContent := Client.Get(LUrl.ToString).ContentAsString;
  Result := BooruParser.ParsePostsFromPage(LContent);
end;

function TBepisDbClient.GetSearchOptions: TBepisDbSearchOpt;
begin
  Result := FSearchOpt;
end;

procedure TBepisDbClient.SetSearchOptions(const value: TBepisDbSearchOpt);
begin
  FSearchOpt := value;
end;

{ TBepisDbSearchOpt }

function TBepisDbSearchOpt.Build(const AHost: string): TURI;
var
  LUrl: TUri;
  LTmp: string;
begin
  LUrl := TUri.Create(AHost + '/' + SubjectAsString);
  if not Name.IsEmpty then LUrl.AddParameter('name', Name);
  if not Tags.IsEmpty then LUrl.AddParameter('tag', Tags);

  if (Subject in [KoikatsuScenes, AIHS2Scenes, AA2Scenes]) then
  begin
    LTmp := FemaleCharacterCount.AsString;
    if not LTmp.IsEmpty then
      LUrl.AddParameter('femalecount', LTmp);
  end else if (Subject in [KoikatsuScenes, AIHS2Scenes]) then
  begin
    LTmp := MaleCharacterCount.AsString;
    if not LTmp.IsEmpty then
      LUrl.AddParameter('malecount', LTmp);
  end;

  if (Subject in [KoikatsuCards, AA2Cards, HoneySelectCards])
  and (not GenderAsString.IsEmpty) then
    LUrl.AddParameter('gender', GenderAsString);

  if (not PersonalityAsInt = Byte.MaxValue) then
    LUrl.AddParameter('personality', PersonalityAsInt.ToString);

  if (Subject in [KoikatsuCards, HoneySelectCards])
  and (not GameTypeAsString.IsEmpty) then
    LUrl.AddParameter('type', GameTypeAsString);

  if (Subject in [KoikatsuCards, KoikatsuScenes])
  and DoesNotContainModdedContent then
    LUrl.AddParameter('vanilla', 'true');

  if not OrderByAsString.IsEmpty then
    LUrl.AddParameter('orderby', OrderByAsString);

  if ShowHidden then
    LUrl.AddParameter('hidden', 'true');

  if ShowOnlyFeatured then
    LUrl.AddParameter('featured', 'true');

  Result := LUrl;
end;

function TBepisDbSearchOpt.BuildUrl(const AHost: string): string;
begin
  Result := Build(AHost).ToString;
end;

class function TBepisDbSearchOpt.Create(ASubject: TSubject): TBepisDbSearchOpt;
begin
  With Result do begin
    Subject := ASubject;
    Name := '';
    Tags := '';
    OrderBy := TOrderBy.OrderDateDescending;
    Gender := TGender.GendUnspecified;
    KoikatsuPersonality := TKoikatsuPersonality.PersUnspecified;
    DoesNotContainModdedContent := False;
    ShowHidden := False;
    ShowOnlyFeatured := False;
    FemaleCharacterCount := TCharacterCountRange.Create(0, 0);
    MaleCharacterCount := TCharacterCountRange.Create(0, 0);
  end;
  
end;

function TBepisDbSearchOpt.GameTypeAsString: string;
begin
  case Subject of
    KoikatsuCards:
    begin
      case KoikatsuGameType of
        GameUnspecified:     Result := '';
        GameBase:            Result := 'base';
        GameSteam:           Result := 'steam';
        GameSteam18:         Result := 'steampatch';
        GameEmotionCreators: Result := 'ec';
        GameSunshine:        Result := 'sunshine';
      end;
    end;

    HoneySelectCards:
    begin
      case HoneySelectGameType of
        HSGameUnspecified: Result := '';
        HSGameNeo:         Result := 'neo';
        HSGameClassic:     Result := 'classic';
      end;
    end;

    else Result := '';
  end;
end;

function TBepisDbSearchOpt.GenderAsString: string;
begin
  case Gender of
    GendUnspecified: Result := '';
    GendFemale:      Result := 'female';
    GendMale:        Result := 'male';
  end;
end;

function TBepisDbSearchOpt.OrderByAsString: string;
begin
  case OrderBy of
    OrderDateDescending: Result := '';
    OrderDateAscending:  Result := 'dateasc';
    OrderPopularity:     Result := 'popularity';
  end;
end;

function TBepisDbSearchOpt.PersonalityAsInt: byte;
begin
  case Subject of
    KoikatsuCards:
    begin
      case KoikatsuPersonality of
        PersUnspecified: Result := Byte.MaxValue;
        else Result := Ord(KoikatsuPersonality) - 1;
      end;
    end;

    else Result := Byte.MaxValue;
  end;
end;

function TBepisDbSearchOpt.SubjectAsString: string;
begin
  case Subject of
    KoikatsuCards: Result    := 'koikatsu';
    KoikatsuScenes: Result   := 'kkscenes';
    KoikatsuClothing: Result := 'kkclothing';
    AA2Cards: Result         := 'aa2';
    AA2Scenes: Result        := 'aa2scenes';
    HoneySelectCards: Result := 'honeyselect';
    PlayHomeCards: Result    := 'playhome';
    AIHS2Cards: Result       := 'aishoujo';
    AIHS2Scenes: Result      := 'aiscenes';
    COM3D2Cards: Result      := 'com3d2';
    SummerHeatCards: Result  := 'summerheat';
  end;
end;

{ TBepisDbSearchOpt.TCharacterCountRange }

function TBepisDbSearchOpt.TCharacterCountRange.AsString: string;
begin
  if Min > 0 then begin
    Result := Min.ToString + ',';
    if Max > 0 then
      Result := Result + Max.ToString;
  end else if Max > 0 then
    Result := ',' + Max.ToString
  else
    Result := '';
end;

class function TBepisDbSearchOpt.TCharacterCountRange.Create(AMin,
  AMax: integer): TCharacterCountRange;
begin
  Result.Min := AMin;
  Result.Max := AMax;
end;

end.
