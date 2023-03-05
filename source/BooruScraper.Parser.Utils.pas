unit BooruScraper.Parser.Utils;

interface
uses
  Classes, Types, SysUtils, System.Generics.Collections,
  HtmlParserEx, BooruScraper.Interfaces;

  function FindXFirst(AElement: IHtmlElement; const AXPath: WideString): IHtmlElement;
  function FindXByClass(AElement: IHtmlElement; AClass: string): IHtmlElement;
  function FindXById(AElement: IHtmlElement; AId: string): IHtmlElement;
  function FindAllByClass(AElement: IHtmlElement; AClass: string): IHtmlElementList;
  function FindByText(AElement: IHtmlElement; AText: string; ATrim: boolean = True; AIgnoreCase: boolean = False): IHtmlElement;

  /// <summary>Returns string between two sub strings.</summaru>
  function GetBetween(const ASource: string; ALeft, ARight: string): string;
  function GetAfter(const ASource: string; ASub: string): string;

  function GetTagTypeByClass(AClass: string): TBooruTagType;
  function NormalizeTag(ATag: string): string;
  function NormalizeTags(ATags: TArray<String>): TArray<String>;

  function NormalizeUrl(AUrlStr: string): string;

const

  BOORU_TIME_FORMAT: TFormatSettings = (
    DateSeparator: '-';
    TimeSeparator: ':';
    ShortDateFormat: 'YYYY-MM-DD';
    ShortTimeFormat: 'HH:MM:SS';
  );

implementation

function GetTagTypeByClass(AClass: string): TBooruTagType;
begin
  if AClass.Contains('tag-type-general') then
    Result := TagGeneral
  else if AClass.Contains('tag-type-copyright') then
    Result := TagCopyright
  else if AClass.Contains('tag-type-character') then
    Result := TagCharacter
  else if AClass.Contains('tag-type-metadata') then
    Result := TagMetadata
  else if AClass.Contains('tag-type-artist') then
    Result := TagArtist
  else
    Result := TagGeneral;
end;

function NormalizeTag(ATag: string): string;
begin
  Result := Trim(ATag).Replace(' ', '_', [rfReplaceAll]);
end;

function FindXFirst(AElement: IHtmlElement; const AXPath: WideString): IHtmlElement;
var
  LElements: IHtmlElementList;
begin
  LElements := AElement.FindX(AXPath);
  if (LElements.Count > 0) then
    Result := LElements.Items[0]
  else
    Result := Nil;
end;

function NormalizeTags(ATags: TArray<String>): TArray<String>;
var
  I: integer;
begin
  SetLength(Result, Length(ATags));
  for i := Low(ATags) to High(ATags) do begin
    Result[I] := NormalizeTag(ATags[I]);
  end;
end;

function FindXByClass(AElement: IHtmlElement; AClass: string): IHtmlElement;
begin
  Result := FindXFirst(AElement, '//*[@class="' + AClass + '"]');
end;

function FindXById(AElement: IHtmlElement; AId: string): IHtmlElement;
begin
  Result := FindXFirst(AElement, '//*[@id="' + AId + '"]')
end;

function FindAllByClass(AElement: IHtmlElement; AClass: string): IHtmlElementList;
begin
  Result := AElement.FindX('//*[@class="' + AClass + '"]');
end;

function FindByText(AElement: IHtmlElement; AText: string; ATrim, AIgnoreCase: boolean): IHtmlElement;
var
  I: integer;
  LText: string;
  LRes: IHtmlElement;
  LengthEq: boolean;
begin
  Result := nil;
  for I := 0 to AElement.ChildrenCount - 1 do begin
    var LElement := AElement.Children[I];
    if (LElement.TagName = '#TEXT') then
      Continue;

    if ATrim then
      LText := Trim(LElement.Text)
    else
      LText := LElement.Text;

    LengthEq := (LText.Length = AText.Length);

    if AIgnoreCase and LengthEq
    and (UpperCase(AText) = UpperCase(LText)) then begin
      Result := LElement;
    end else if LengthEq and (AText = LText) then begin
      Result := LElement;
    end else begin
      Result := FindByText(LElement, AText, ATrim, AIgnoreCase);
    end;

    if Assigned(Result) then begin
      LRes := Result;
      Result := FindByText(LElement, AText, ATrim, AIgnoreCase);
      if Assigned(Result) and (Result.TagName <> '#TEXT') then
        Exit(Result)
      else
        Exit(LRes);
    end;
  end;
end;

function GetAfter(const ASource: string; ASub: string): string;
var
  LPos, LLen: integer;
begin
  Result := '';
  LLen := ASource.Length;
  LPos := ASource.IndexOf(ASub);
  if (LPos <> -1) then begin
    LPos := LPos + ASub.Length;
    Result := ASource.Substring(LPos, LLen);
  end;
end;

function GetBetween(const ASource: string; ALeft, ARight: string): string;
var
  LPosL, LPosR, LLen: integer;
begin
  Result := '';
  LLen := ASource.Length;
  LPosL := ASource.IndexOf(ALeft);
  if (LPosL <> -1) then begin
    LPosL := LPosL + Length(ALeft);
    LPosR := ASource.IndexOf(ARight, LPosL, LLen);
    if (LPosR <> -1) then
      Result := ASource.Substring(LPosL, (LLen - LPosL) - (LLen - LPosR));
  end;
end;

function NormalizeUrl(AUrlStr: string): string;
begin
  { for tbib.org }
  if AUrlStr.StartsWith('//') then
    Result := AUrlStr.Remove(0, 2)
  else
    Result := AUrlStr;
end;

end.
