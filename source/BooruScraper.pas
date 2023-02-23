﻿unit BooruScraper;

interface
uses
  Classes, System.SysUtils, System.Generics.Collections,
  BooruScraper.Interfaces,
  BooruScraper.ClientBase,
  BooruScraper.BaseTypes,
  BooruScraper.Client.CompatibleGelbooru,
  BooruScraper.Client.Rule34us,
  BooruScraper.Client.rule34PahealNet,
  BooruScraper.Parser.rule34xxx,
  BooruScraper.Parser.gelbooru,
  BooruScraper.Parser.Realbooru,
  BooruScraper.Parser.Rule34us,
  BooruScraper.Parser.rule34PahealNet;

  function NewClient(AClientClass: TBooruClientBaseClass; AParser: TBooruParserClass; AHost: string): IBooruClient;

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



implementation

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

end.
