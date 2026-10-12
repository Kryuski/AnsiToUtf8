program AnsiToUtf8;
// Disable the "new" RTTI
{$WEAKLINKRTTI ON}
{$IF DECLARED(TVisibilityClasses)}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$IFEND}

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Windows, SysUtils, Classes;

const
  UTF8_BOM: RawByteString = RawByteString(#$EF#$BB#$BF);

function LoadStringFromFile(const FileName: string): RawByteString;
var
  fs: TFileStream;
begin
  fs := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
  try
    SetLength(Result, fs.Size);
    if fs.Size > 0 then
      fs.ReadBuffer(Result[1], Length(Result));
  finally
    fs.Free;
  end;
end;

procedure SaveStringToFile(const s: RawByteString; const FileName: string);
var
  fs: TFileStream;
begin
  fs := TFileStream.Create(FileName, fmCreate);
  try
    if s <> '' then
      fs.WriteBuffer(s[1], Length(s));
  finally
    fs.Free;
  end;
end;

function HasUtf8BOM(const s: RawByteString): Boolean;
begin
  Result := (Length(s) >= 3)
    and (s[1] = UTF8_BOM[1])
    and (s[2] = UTF8_BOM[2])
    and (s[3] = UTF8_BOM[3]);
end;

procedure ConvertFile(const FileName: string; const CodePage: Integer);
var
  s: RawByteString;
  backupFileName: string;
begin
  s := LoadStringFromFile(FileName);

  if HasUtf8BOM(s) then begin
    Writeln('Skipped (already UTF-8): ', FileName);
    Exit;
  end;

  // Interpret the original bytes using the selected code page,
  // then convert them to UTF-8.
  SetCodePage(s, CodePage, False);
  SetCodePage(s, 65001, True);
  // Add the UTF-8 BOM.
  s := UTF8_BOM + s;

  backupFileName := FileName + '.bak';
  if FileExists(backupFileName) then
    SysUtils.DeleteFile(backupFileName);

  if not RenameFile(FileName, backupFileName) then
    raise Exception.CreateFmt('Cannot create backup file "%s".', [backupFileName]);

  try
    SaveStringToFile(s, FileName);
    Writeln('Converted: ', FileName);
  except
    // Restore the original file if writing the converted file fails.
    if FileExists(FileName) then
      SysUtils.DeleteFile(FileName);
    RenameFile(backupFileName, FileName);
    raise;
  end;
end;

procedure ProcessMask(const FileMask: string; const CodePage: Integer);
var
  searchRec: TSearchRec;
  searchPath, fileName: string;
  findResult: Integer;
  foundAny: Boolean;
begin
  searchPath := ExtractFilePath(FileMask);
  if searchPath = '' then
    searchPath := '';
  foundAny := False;
  findResult := FindFirst(FileMask, faAnyFile, searchRec);
  if findResult = 0 then begin
    try
      repeat
        if searchRec.Attr and faDirectory = 0 then begin
          foundAny := True;
          fileName := searchPath + searchRec.Name;
          try
            ConvertFile(fileName, CodePage);
          except
            on E: Exception do
              Writeln('Error: ', fileName, ': ', E.Message);
          end;
        end;
        findResult := FindNext(searchRec);
      until findResult <> 0;
    finally
      FindClose(searchRec);
    end;
  end;
  if not foundAny then
    Writeln('No files found: ', FileMask);
end;

var
  FileMask: string;
  CodePage: Integer;
begin
  try
    if ParamCount = 0 then begin
      Writeln('ANSI to UTF-8 file converter.');
      Writeln('Usage: ', ExtractFileName(ParamStr(0)), ' filemask [codepage]');
      Writeln('  filemask - file name or mask, e.g. *.pas');
      Writeln('  codepage - ANSI code page; 1251 by default.');
      Writeln('  Files already starting with the UTF-8 BOM are skipped.');
      Exit;
    end;
    FileMask := ParamStr(1);
    if ParamCount > 1 then
      CodePage := StrToInt(ParamStr(2))
    else
      CodePage := 1251;
    ProcessMask(FileMask, CodePage);
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
