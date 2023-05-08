program test;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  classes,
  Types,
  XSuperObject,
  System.Generics.Collections,
  Net.HttpClient,
  Net.HttpClientComponent,
  System.JSON,
  System.Diagnostics,
  DateUtils,
  BooruScraper.Interfaces in '..\source\BooruScraper.Interfaces.pas',
  BooruScraper.ClientBase in '..\source\BooruScraper.ClientBase.pas',
  BooruScraper.Client.CompatibleGelbooru in '..\source\BooruScraper.Client.CompatibleGelbooru.pas',
  BooruScraper.BaseTypes in '..\source\BooruScraper.BaseTypes.pas',
  BooruScraper.Parser.rule34xxx in '..\source\BooruScraper.Parser.rule34xxx.pas',
  BooruScraper.Parser.Utils in '..\source\BooruScraper.Parser.Utils.pas',
  BooruScraper.Parser.gelbooru in '..\source\BooruScraper.Parser.gelbooru.pas',
  BooruScraper in '..\source\BooruScraper.pas',
  BooruScraper.Serialize.XSuperObject in '..\source\BooruScraper.Serialize.XSuperObject.pas',
  BooruScraper.Parser.Realbooru in '..\source\BooruScraper.Parser.Realbooru.pas',
  BooruScraper.Parser.rule34us in '..\source\BooruScraper.Parser.rule34us.pas',
  BooruScraper.Client.Rule34us in '..\source\BooruScraper.Client.Rule34us.pas',
  BooruScraper.Parser.rule34PahealNet in '..\source\BooruScraper.Parser.rule34PahealNet.pas',
  BooruScraper.Client.rule34PahealNet in '..\source\BooruScraper.Client.rule34PahealNet.pas',
  BooruScraper.Client.API.TbibOrg in '..\source\BooruScraper.Client.API.TbibOrg.pas',
  BooruScraper.Urls in '..\source\BooruScraper.Urls.pas',
  BooruScraper.Parser.API.TbibOrg in '..\source\BooruScraper.Parser.API.TbibOrg.pas',
  BooruScraper.Client.API.danbooru in '..\source\BooruScraper.Client.API.danbooru.pas',
  BooruScraper.Parser.API.danbooru in '..\source\BooruScraper.Parser.API.danbooru.pas',
  BooruScraper.Serialize.Json in '..\source\BooruScraper.Serialize.Json.pas',
  BooruScraper.Parser.BepisDb in '..\source\BooruScraper.Parser.BepisDb.pas',
  BooruScraper.Client.BepisDb in '..\source\BooruScraper.Client.BepisDb.pas',
  BooruScraper.Parser.Kenzatouk in '..\source\BooruScraper.Parser.Kenzatouk.pas',
  BooruScraper.Client.KenzatoUk in '..\source\BooruScraper.Client.KenzatoUk.pas',
  BooruScraper.Exceptions in '..\source\BooruScraper.Exceptions.pas';

var
  Client: IBooruClient;

procedure SetWebClient(AClient: TNetHttpClient; AHost: string = ''; AKeepCompatibility: boolean = True);
var
  LProblemHost: boolean;
begin
  LProblemHost :=
       (AHost = DANBOORUDONMAIUS_URL)
    or (AHost = DBBEPISMOE_URL);

  if LProblemHost and AkeepCompatibility then exit;

  with AClient do begin
    AutomaticDecompression := [THttpCompressionMethod.Any];
    AllowCookies := false;
    Useragent                        := 'Mozilla/5.0 (Windows NT 10.0; rv:91.0) Gecko/20100101 Firefox/91.0';
    Customheaders['Accept']          := 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8';
    CustomHeaders['Accept-Language'] := 'en-US,en;q=0.5';
    CustomHeaders['Accept-Encoding'] := 'gzip, deflate';
    CustomHeaders['DNT']             := '1';
    CustomHeaders['Connection']      := 'keep-alive';
    CustomHeaders['Upgrade-Insecure-Requests'] := '1';
    CustomHeaders['Sec-Fetch-Dest']  := 'document';
    CustomHeaders['Sec-Fetch-Mode']  := 'navigate';
    CustomHeaders['Sec-Fetch-Site']  := 'same-origin';
    CustomHeaders['Pragma']          := 'no-cache';
    CustomHeaders['Cache-Control']   := 'no-cache';
  end;
end;

procedure TestGet(AUrl: string);
var
  LClient: TNetHttpClient;
  LResponse: IHttpResponse;
  I: integer;
  LTimer: TStopWatch;
begin
  LTimer := TStopWatch.Create;
  LClient := TNetHttpClient.Create(nil);
  try
    SetWebClient(LClient);
    LTimer.Start;
    LResponse := LCLient.Get(AUrl);
    LTimer.Stop;
    Writeln(LResponse.ContentAsString);
    Writeln('_____________________STATUS_________________________');
    Writeln(LResponse.StatusText + ': ' + LResponse.StatusCode.ToString);
    Writeln(LTimer.ElapsedMilliseconds.ToString + ' Ms.');
    Writeln('Headers (' + Length(LResponse.Headers).ToString + '):');
    For I := Low(LResponse.Headers) to High(LResponse.Headers) do
    begin
      Writeln(LResponse.Headers[I].Name + ': ' + LResponse.Headers[I].Value);
    end;
  finally
    LClient.Free;
  end;
end;

function createtag(AValue: string): IBooruTag;
begin
  Result := TBooruTagBase.Create;
  Result.Value := AValue;
end;

procedure PVal(AName, AValue: string); overload;
begin
  Writeln(AName + ': "' + AValue + '"');
end;

procedure pdelim();
begin
  Writeln('______________________________________________');
end;

procedure PrintThumb(A: IBooruThumb);
var
  LIdStr: IIdString;
begin
  if Supports(A, IIdString, LIdStr) then
    PVal('Id', LIdStr.Id)
  else
    PVal('Id', A.Id.ToString);

  PVal('Tags [' + Length(A.TagsValues).ToString + ']', String.Join(' ', A.TagsValues));
  PVal('Thumbnail', A.Thumbnail);
  pdelim;
end;

procedure PrintThumbs(A: TBooruThumbAr);
var
  I: integer;
begin
  PVal('Thumbs count', Length(A).ToString);
  for I := 0 to High(A) do
    PrintThumb(A[I]);
end;

procedure PrintComment(A: IBooruComment);
begin
  PVal('Id', A.Id.ToString);
  PVal('Username', A.Username);
  PVal('Timestamp', DateTimeTOStr(A.Timestamp));
  PVal('Score', A.Score.ToString);
  PVal('Text', A.Text);
  pdelim;
end;

procedure PrintComments(A: TBooruCommentAr);
var
  I: integer;
begin
  PVal('Comments count', Length(A).ToString);
  for I := 0 to High(A) do
    PrintComment(A[I]);
end;

function TagTypeToStr(ATagType: TBooruTagType): string;
begin
  case ATagType of
    TagGeneral:   Result := 'General';
    TagCopyright: Result := 'Copyright';
    TagMetadata:  Result := 'Metadata';
    TagCharacter: Result := 'Character';
    TagArtist:    Result := 'Artist';
  end;
end;

procedure PrintTag(A: IBooruTag);
begin
  Writeln('(' + TagTypeToStr(A.Kind) + ') ' + A.Value + ': ' + A.Count.ToString);
end;

procedure PrintTags(A: TBooruTagAr);
var
  I: integer;
begin
  PVal('Tags count', Length(A).ToString);
  for I := 0 to High(A) do
    PrintTag(A[I]);
end;

procedure PrintPost(A: IBooruPost); overload;
var
  X: TJsonObject;
begin
  if Assigned(A) then begin
    X := TJsonMom.ToJsonAuto(A);
    writeln('Before: ' + X.ToJSON);
    var LPost := TJsonMom.FromJsonIBooruPost(X);
    X.Free;
    X := TJsonMom.ToJsonAuto(LPost);
    Writeln(X.ToJSON);
    X.Free;
  end else
    Writeln('PrintPost --->> Post is NIL!');
end;

procedure PrintPost(AId: TBooruId); overload;
begin
  var LPost := Client.GetPost(AId);
  PrintPost(LPost);
end;

procedure TestClone(AObject: IAssignAndClone);
var
  LCopy: IAssignAndClone;
  LOJson: TJsonObject;
  LCJson: TJsonObject;
begin
  LOJson := TJsonMom.ToJsonAuto(AObject);
  Writeln('ORIGINAL ----------------------');
  Writeln(LOJson.ToJSON);
  Writeln('END ---------------------------');

  LCopy := AObject.Clone;
  LCJson := TJsonMom.ToJsonAuto(LCopy);
  Writeln('COPY --------------------------');
  Writeln(LCJson.ToJSON);
  Writeln('END ---------------------------');

  LOJson.Free;
  LCJson.Free;
end;

procedure GetPost(AClient: IBooruClient; AId: TBooruId);
var
  LPost: IBooruPost;
begin
  writeln('GET POST ' + AClient.Host + ': ' + AId.ToString + ';');
  LPost := AClient.GetPost(AId);
  PrintPost(LPost);
  Writeln('END ---------------------------');
end;

procedure GetComments(AClient: IBooruClient; AId: TBooruId);
var
  LComments: TBooruCommentAr;
begin
  writeln('GET COMMENTS ' + AClient.Host + ': ' + AId.ToString + ';');
  LComments := AClient.GetPostComments(AId);
  PrintComments(LComments);
  Writeln('END ---------------------------');
end;

procedure TestClient(AClient: IBooruClient; ARequest: string = ''; ATestClone: boolean = True; AFullOutput: boolean = True);
var
  LThumbs: TBooruThumbAr;
  LPost: IBooruPost;
begin
  LPost := Nil;
  LThumbs := AClient.GetPosts(ARequest, 0, 40);
  if AFullOutput then PrintThumbs(LThumbs);

  if ATestClone and (Length(LThumbs) > 0) then
    TestClone(LThumbs[0]);

  if AFullOutput then writeln('');

  if Length(LThumbs) > 0 then begin
    LPost := AClient.GetPost(LThumbs[0]);
    if AFullOutput then PrintPost(LPost);
    if Assigned(LPost) and ATestClone then
      TestClone(LPost);

    if AFullOutput then writeln('');
  end;

  if not AFullOutput then
  begin
    var LId: int64 := -1;
    if Assigned(LPost) then Lid := LPost.Id;
    writeln(Format(
      'got %d thumbs and post with id: %d',
      [Length(lThumbs), LId]
    ));
  end;
end;

procedure TestBeforeException(AClient: IBooruClient; AFetchPosts: boolean = True; ARequest: string = ''; AStartPage: integer = BOORU_FIRSTPAGE);
var
  LThumbs: TBooruThumbAr;
  LThumb: IBooruThumb;
  LPost: IBooruPost;
  LPage: integer;
  LCount: integer;
begin
  Writeln('TestBeforeException: ' + AClient.Host + ' ' + ARequest);
  LPage := AStartPage;
  while TRUE do
  begin
    try
      LThumbs := Nil;
      LThumbs := AClient.GetPosts(ARequest, LPage);
    except
      on E: Exception do begin
        Writeln('Get thumbs: ' + E.ClassName + ': ' + E.Message);
        break;
      end;
    end;

    LCount := Length(LThumbs);
    Writeln(Now.ToString + ': fetched ' + LCount.ToString + ' thumbs on Page: ' + LPage.ToString + '.');

    if AFetchPosts then
    begin
      for LThumb in LThumbs do
      begin
        Writeln(Now.ToString + ': Trying to get post: ' + LThumb.Id.ToString);
        try
          LPost := AClient.GetPost(LThumb);
        except
          on E: Exception do begin
            Writeln('Get post: ' + LThumb.Id.ToString + ' ~ ' + E.ClassName + ': ' + E.Message);
            break;
          end;
        end;
      end;
    end;

    if LCount < 1 then break;
  end;
  Writeln('Test fin.')
end;

function FileContent(AFilename: string): string;
var
  Lstrings: TStrings;
begin
  LStrings := TStringList.Create;
  try
    LStrings.LoadFromFile(AFilename);
    Result := LStrings.Text;
  finally
    LStrings.Free;
  end;
end;

procedure TestParser(AParser: TBooruParserClass; AFilePrefix: string);
var
  LPost: IBooruPost;
  LThumbs: TBooruThumbAr;
  LFilenameList, LFilenamePost: string;
begin
  Writeln('PARSER TEST --------------------');

  LFilenameList := '../../temp/' + AFilePrefix + '_list.html';
  LFilenamePost := '../../temp/' + AFilePrefix + '_post.html';

  if fileexists(LFilenameList) then
  begin
    LThumbs := AParser.ParsePostsFromPage(FileContent(LFilenameList));
    PrintThumbs(LThumbs);
  end;

  if fileexists(LFilenamePost) then
  begin
    LPost := AParser.ParsePostFromPage(FileContent(LFilenamePost));
    PrintPost(LPost);
  end;
end;

procedure TestAllClients;
var
  I: integer;
  LClients: TArray<IBooruClient>;
begin
  LClients := [
    BooruScraper.NewClientRule34xxx,
    BooruScraper.NewClientGelbooru,
    BooruScraper.NewClientRealbooru,
    BooruScraper.NewClientRule34us,
    BooruScraper.NewClientRule34PahealNet,
    BooruScraper.NewClientXbooru,
    BooruScraper.NewClientHypnohubnet,
    BooruScraper.NewClientTbib,
    BooruScraper.NewClientDonmaiUs,
    BooruScraper.NewClientBleachbooru,
    BooruScraper.NewClientAllTheFallen,
    BooruScraper.NewClientIllusioncards,
    BooruScraper.NewClientHgoon,
    BooruScraper.NewClientBepisDb,
    BooruScraper.NewClientKenzatoUk
  ];

  Writeln('Start test of ' + Length(LClients).ToString + ' clients:');
  for I := 0 to High(LClients) do
  begin
    var C := LClients[I];
    var LStr: string := C.Host;
    LStr := LStr.Substring(8); { trim https:// }
    Write(Format(
      '[%d] %s (%s, %s): ',
      [I, LStr, (C as TObject).ClassName, C.BooruParser.ClassName])
    );

    SetWebClient(TBooruClientBase(C).Client, C.Host);
    try
      TestClient(C, '', false, False);
    except
      On E: Exception do Writeln(E.ClassName + ': ' + E.Message);
    end;
//    Writeln('');
  end;
end;

var
  LPost: IBooruPost;
  LPosts: TBooruPostAr;
  LThumbs: TBooruThumbAr;
  LAllContentSwitch: IEnableAllContent;
  I: integer;

begin
  try
    { https://lolibooru.moe/help/api }
//    Client := BooruScraper.NewClient('');
    Client := BooruScraper.NewClientDonmaiUs;
//    Client.Host := '';
    SetWebClient(TBooruClientBase(Client).Client, Client.Host);

    if Supports(Client, IEnableAllContent, LAllContentSwitch) then
      LAllContentSwitch.EnableAllContent := True;

    TestAllClients;
//    TestBeforeException(Client, True, 'video');
//    TestClient(Client, '', True);
//    TestParser(Client.BooruParser, 'gelbooru');

    Readln;
  except
    on E: Exception do begin
      Writeln(E.ClassName, ': ', E.Message);
      Readln;
    end;
  end;
end.
