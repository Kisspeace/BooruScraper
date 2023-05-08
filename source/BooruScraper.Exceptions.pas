unit BooruScraper.Exceptions;

interface
uses
  Classes, System.SysUtils;

type
  EBooruScraperException = Class(Exception);
  EBooruScraperParsingException = Class(EBooruScraperException);

implementation

end.