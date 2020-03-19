program AnsiToUtf8;
// Disable the "new" RTTI
{$WEAKLINKRTTI ON}
{$IF DECLARED(TVisibilityClasses)}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$IFEND}

{$APPTYPE CONSOLE}

{$R *.res}

uses
  SysUtils, Classes, Windows;

function LoadStringFromFile(const FileName: string): RawByteString;
var
  fs: TFileStream;
begin
  fs := TFileStream.Create(FileName, fmOpenRead);
  try
    SetLength(Result, fs.Size);
    if fs.Size > 0 then
      fs.Read(Result[1], Length(Result));
  finally
    fs.Free;
  end;
end;

procedure SaveStringToFile(const s: RawByteString; const FileName: string);
var
  fs: TFileStream;
begin
  if s = '' then
    Exit;
  fs := TFileStream.Create(FileName, fmCreate);
  try
    fs.Write(s[1], Length(s));
  finally
    fs.Free;
  end;
end;

var
  FileName, BackupFileName: string;
  AnsiStr: RawByteString;
  CodePage: Integer;
begin
  try
    if ParamCount = 0 then begin
      Writeln('ANSI to UTF-8 file converter.');
      Writeln('Usage: ', ExtractFileName(ParamStr(0)), ' source.pas [codepage]');
      Writeln('where source.pas - ANSI-encoded file to be converted,');
      Writeln('      codepage - ANSI codepage. 1251 by default.');
      Exit;
    end;
    if ParamCount > 1 then
      CodePage := ParamStr(2).ToInteger
    else
      CodePage := 1251;
    FileName := ParamStr(1);
    AnsiStr := LoadStringFromFile(FileName);
    SetCodePage(AnsiStr, CodePage, False);
    SetCodePage(AnsiStr, 65001, True);    
    BackupFileName := FileName + '.bak';
    if FileExists(BackupFileName) then
      SysUtils.DeleteFile(BackupFileName);
    RenameFile(FileName, BackupFileName);
    SaveStringToFile(AnsiStr, FileName);
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
