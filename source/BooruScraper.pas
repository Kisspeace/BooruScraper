unit BooruScraper;

interface
uses
  Classes, System.SysUtils, System.Generics.Collections,
  BooruScraper.Interfaces,
  BooruScraper.ClientBase,
  BooruScraper.BaseTypes,
  BooruScraper.Urls,
  BooruScraper.Client.CompatibleGelbooru,
  BooruScraper.Client.Rule34us,
  BooruScraper.Client.rule34PahealNet,
  BooruScraper.Client.API.TbibOrg,
  BooruScraper.Client.API.danbooru,
  BooruScraper.Client.BepisDb,
  BooruScraper.Client.KenzatoUk,
  BooruScraper.Parser.rule34xxx,
  BooruScraper.Parser.gelbooru,
  BooruScraper.Parser.Realbooru,
  BooruScraper.Parser.Rule34us,
  BooruScraper.Parser.rule34PahealNet,
  BooruScraper.Parser.API.TbibOrg,
  BooruScraper.Parser.API.danbooru,
  BooruScraper.Parser.BepisDb,
  BooruScraper.Parser.Kenzatouk;

  /// <summary>Returns client for given URL, or returns Nil when site not supported.</summary>
  function NewClient(const AUrl: string): IBooruClient; overload;
  function NewClient(AClientClass: TBooruClientBaseClass; AParser: TBooruParserClass; AHost: string): IBooruClient; overload;

  /// <summary>Client for <a href="https://rule34.xxx">rule34.xxx</a></summary>
  function NewClientRule34xxx: IBooruClient;
  /// <summary>Client for <a href="https://gelbooru.com">gelbooru.com</a></summary>
  function NewClientGelbooru: IBooruClient;
  /// <summary>Client for <a href="https://realbooru.com">realbooru.com</a></summary>
  function NewClientRealbooru: IBooruClient;
  /// <summary>Client for <a href="https://rule34.us">rule34.us</a></summary>
  function NewClientRule34us: IBooruClient;
  /// <summary>Client for <a href="https://rule34.paheal.net">rule34.paheal.net</a></summary>
  function NewClientRule34PahealNet: IBooruClient;
  /// <summary>Client for <a href="https://xbooru.com">xbooru.com</a></summary>
  function NewClientXbooru: IBooruClient;
  /// <summary>Client for <a href="https://hypnohub.net">hypnohub.net</a></summary>
  function NewClientHypnohubnet: IBooruClient;
  /// <summary>Client for <a href="https://tbib.org">tbib.org</a></summary>
  function NewClientTbib(APreferAPI: boolean = True): IBooruClient;
  /// <summary>Client for <a href="https://danbooru.donmai.us">danbooru.donmai.us</a>
  /// With TNetHttpClient works only without custom headers. (JA3/JA3S i think)
  /// </summary>
  function NewClientDonmaiUs(APreferAPI: boolean = True): IBooruClient;
  /// <summary>Client for <a href="https://bleachbooru.org">bleachbooru.org</a></summary>
  function NewClientBleachbooru(APreferAPI: boolean = True): IBooruClient;
  /// <summary>Client for <a href="https://booru.allthefallen.moe">booru.allthefallen.moe</a></summary>
  function NewClientAllTheFallen(APreferAPI: boolean = True): IBooruClient;
  /// <summary>Client for <a href="illusioncards.booru.org">illusioncards.booru.org</a></summary>
  function NewClientIllusioncards: IBooruClient;
  /// <summary>Client for <a href="https://db.bepis.moe">db.bepis.moe</a></summary>
  function NewClientBepisDb: IBepisDbClient;
  /// <summary>Client for <a href="https://hgoon.booru.org">hgoon.booru.org</a></summary>
  function NewClientHgoon: IBooruClient;
  /// <summary>Client for <a href="https://kenzato.uk/booru">kenzato.uk/booru</a></summary>
  function NewClientKenzatoUk: IKenzatoUkClient;


implementation

function NewClient(const AUrl: string): IBooruClient;
begin
  if RULE34XXX_URL = AUrl then
    Result := NewClientRule34xxx
  else if GELBOORU_URL = AUrl then
    Result := NewClientGelbooru
  else if REALBOORU_URL = AUrl then
    Result := NewClientRealbooru
  else if RULE34US_URL = AUrl then
    Result := NewClientRule34us
  else if RULE34PAHEALNET_URL = AUrl then
    Result := NewClientRule34PahealNet
  else if XBOORU_URL = AUrl then
    Result := NewClientXbooru
  else if HYPNOHUBNET_URL = AUrl then
    Result := NewClientHypnohubnet
  else if TBIBORG_URL = AUrl then
    Result := NewClientTbib
  else if DANBOORUDONMAIUS_URL = AUrl then
    Result := NewClientDonmaiUs
  else if BLEACHBOORUORG_URL = AUrl then
    Result := NewClientBleachbooru
  else if BOORUALLTHEFALLENMOE_URL = AUrl then
    Result := NewClientAllTheFallen
  else if ILLUSIONCARDSBOORU_URL = AUrl then
    Result := NewClientIllusioncards
  else if DBBEPISMOE_URL = AUrl then
    Result := NewClientBepisDb
  else if HGOONBOORUORG_URL = AUrl then
    Result := NewClientHgoon
  else if KENZATOUKBOORU_URL = AUrl then
    Result := NewClientKenzatoUk
  else
    Result := Nil;
end;

function NewClient(AClientClass: TBooruClientBaseClass; AParser: TBooruParserClass; AHost: string): IBooruClient;
begin
  Result := AClientClass.Create(AParser, AHost);
end;

function NewClientRule34xxx: IBooruClient;
begin
  Result := NewClient(TGelbooruLikeClient, TRule34xxxparser, RULE34XXX_URL);
end;

function NewClientGelbooru: IBooruClient;
begin
  Result := NewClient(TGelbooruClient, TGelbooruParser, GELBOORU_URL);
end;

function NewClientRealbooru: IBooruClient;
begin
  Result := NewClient(TGelbooruLikeClient, TRealbooruParser, REALBOORU_URL);
end;

function NewClientRule34us: IBooruClient;
begin
  Result := NewClient(TRule34usClient, TRule34usParser, RULE34US_URL);
end;

function NewClientRule34PahealNet: IBooruClient;
begin
  Result := NewClient(TRule34PahealNetClient, TRule34pahealnetParser, RULE34PAHEALNET_URL)
end;

function NewClientXbooru: IBooruClient;
begin
  Result := NewClient(TGelbooruLikeClient, TRule34xxxparser, XBOORU_URL);
end;

function NewClientHypnohubnet: IBooruClient;
begin
  Result := NewClient(TGelbooruLikeClient, TRule34xxxparser, HYPNOHUBNET_URL);
end;

function NewClientTbib(APreferAPI: boolean): IBooruClient;
begin
  if APreferAPI then
    Result := NewClient(TTbibAPIClient, TTbibOrgAPIParser, TBIBORG_URL)
  else
    Result := NewClient(TGelbooruLikeClient, TRule34xxxparser, TBIBORG_URL);
end;

function NewClientDonmaiUs(APreferAPI: boolean = True): IBooruClient;
begin
  Result := NewClient(TDanbooruAPIClient, TDanbooruAPIParser, DANBOORUDONMAIUS_URL);
end;

function NewClientBleachbooru(APreferAPI: boolean = True): IBooruClient;
begin
  Result := NewClient(TDanbooruAPIClient, TDanbooruAPIParser, BLEACHBOORUORG_URL);
end;

function NewClientAllTheFallen(APreferAPI: boolean = True): IBooruClient;
begin
  Result := NewClient(TDanbooruAPIClient, TDanbooruAPIParser, BOORUALLTHEFALLENMOE_URL);
end;

function NewClientIllusioncards: IBooruClient;
begin
  Result := NewClient(TGelbooruClient, TGelbooruParser, ILLUSIONCARDSBOORU_URL);
end;

function NewClientBepisDb: IBepisDbClient;
begin
  Result := NewClient(TBepisDbClient, TBepisDbParser, DBBEPISMOE_URL)
    as IBepisDbClient;
end;

function NewClientHgoon: IBooruClient;
begin
  Result := NewClient(TGelbooruClient, TGelbooruParser, HGOONBOORUORG_URL);
end;

function NewClientKenzatoUk: IKenzatoUkClient;
begin
  Result := NewClient(TKenzatoUkClient, TKenzatoUkParser, KENZATOUKBOORU_URL)
    as IKenzatoUkClient;
end;

end.
