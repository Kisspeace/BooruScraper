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
  BooruScraper.Client.Rule34us in '..\source\BooruScraper.Client.Rule34us.pas';

var
  Client: IBooruClient;

procedure SetWebClient(AClient: TNetHttpClient);
begin
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
begin
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
begin
  if Assigned(A) then begin
    var X := TJsonMom.ToJson(A);
    var LPost := TJsonMom.FromJsonIBooruPost(X);
    X := TJsonMom.ToJson(LPost);
    Writeln(X.AsJSON(True));
  end else
    Writeln('PrintPost --->> Post is NIL!');
end;

procedure PrintPost(AId: TBooruId); overload;
begin
  var LPost := Client.GetPost(AId);
  PrintPost(LPost);
end;

procedure TestClient(AClient: IBooruClient; ARequest: string = '');
var
  LThumbs: TBooruThumbAr;
  LPost: IBooruPost;
begin
  LThumbs := AClient.GetPosts(ARequest, 0);
  PrintThumbs(LThumbs);
  writeln('');

  if Length(LThumbs) > 0 then begin
    LPost := AClient.GetPost(LThumbs[0]);
    PrintPost(LPost);
    writeln('');
  end;

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
begin
  Writeln('PARSER TEST --------------------');

  LThumbs := AParser.ParsePostsFromPage(FileContent('../../' + AFilePrefix + '_list.html'));
  PrintThumbs(LThumbs);

  LPost := AParser.ParsePostFromPage(FileContent('../../' + AFilePrefix + '_post.html'));
  PrintPost(LPost);

  Writeln('PARSER TEST END ----------------');
end;

var
  LPost: IBooruPost;
  LPosts: TBooruPostAr;
  LThumbs: TBooruThumbAr;
begin
  try
    Client := BooruScraper.NewClientRule34us;
    SetWebClient(TBooruClientBase(Client).Client);
    TestClient(Client);
//    TestParser(LClient.BooruParser, 'rule34us');

    Readln;
  except
    on E: Exception do begin
      Writeln(E.ClassName, ': ', E.Message);
      Readln;
    end;
  end;
end.
