unit _files;

interface

uses SysUtils, WinTypes, WinProcs, Classes, Consts, System.IOUtils, M_Global, vcl.Dialogs;

type
  EInvalidDest = class(EStreamError);
  EFCantMove = class(EStreamError);

procedure CopyFile(const FileName, DestName: TFileName);
procedure MoveFile(const FileName, DestName: TFileName);
function  GetFileSize(const FileName: string): LongInt;
function  FileDateTime(const FileName: string): TDateTime;
function  HasAttr(const FileName: string; Attr: Word): Boolean;
function  ExecuteFile(const FileName, Params, DefaultDir: string;
  ShowCmd: Integer): THandle;

implementation

uses Forms, ShellAPI;

const
  SInvalidDest = 'Destination %s does not exist';
  SFCantMove = 'Cannot move file %s';
  SFOpenError = 'Cannot open File %s';
  SFCreateError = 'Cannot create File %s';



procedure CopyFile(const FileName, DestName: TFileName);
begin
 try
   TFile.Copy(FileName, DestName, True);
 except on E: Exception do
   begin
     Log.error('Failed to Copy File from ' + FileName + ' to ' + DestName + ' with error ' + E.ClassName +
     ' error raised, with message : '+E.Message, LogName);
     showmessage('Failed to Copy File from ' + FileName + ' to ' + DestName + ' with error ' + E.ClassName +
     ' error raised, with message : '+E.Message);
    end;
 end;
end;

{       Good God... 1995 go away!
procedure CopyFile(const FileName, DestName: TFileName);
var
  CopyBuffer: Pointer;
   BytesCopied: Longint;
  Source, Dest: Integer;
  ErrString : String;
  Destination: TFileName;
const
  ChunkSize: Longint = 8192;
begin
  Destination := ExpandFileName(DestName);
  GetMem(CopyBuffer, ChunkSize);
  try
    Source := FileOpen(FileName, fmShareDenyWrite);
    if Source < 0 then raise EFOpenError.CreateFmt(SFOpenError, [Source]);
    try
      Dest := FileCreate(Destination);
      if Dest < 0 then raise EFCreateError.CreateFmt(SFCreateError,[Dest]);
      try
        repeat
          BytesCopied := FileRead(Source, CopyBuffer^, ChunkSize);
          if BytesCopied > 0 then
            FileWrite(Dest, CopyBuffer^, BytesCopied);
        until BytesCopied < ChunkSize;
      finally
        FileClose(Dest);
      end;
    finally
      FileClose(Source);
    end;
  finally
    FreeMem(CopyBuffer, ChunkSize);
  end;
end;
   }

{ MoveFile procedure }
{
  Moves the file passed in FileName to the directory specified in DestDir.
  Tries to just rename the file.  If that fails, try to copy the file and
  delete the original.

  Raises an exception if the source file is read-only, and therefore cannot
  be deleted/moved.
}

procedure MoveFile(const FileName, DestName: TFileName);
var
  Destination: TFileName;
begin
  Destination := ExpandFileName(DestName); { expand the destination path }
  if not RenameFile(FileName, Destination) then { try just renaming }
  begin
    if HasAttr(FileName, faReadOnly) then  { if it's read-only... }
      raise EFCantMove.Create(Format(SFCantMove, [FileName])); { we wouldn't be able to delete it }
      CopyFile(FileName, Destination); { copy it over to destination...}
      SysUtils.DeleteFile(FileName); { ...and delete the original }
  end;
end;

{ GetFileSize function }
{
  Returns the size of the named file without opening the file.  If the file
  doesn't exist, returns -1.
}

function GetFileSize(const FileName: string): LongInt;
var
  SearchRec: TSearchRec;
begin
  if FindFirst(ExpandFileName(FileName), faAnyFile, SearchRec) = 0 then
    Result := SearchRec.Size
  else Result := -1;
end;

function FileDateTime(const FileName: string): System.TDateTime;
begin
  Result := FileDateToDateTime(FileAge(FileName));
end;

function HasAttr(const FileName: string; Attr: Word): Boolean;
begin
  Result := (FileGetAttr(FileName) and Attr) = Attr;
end;

function ExecuteFile(const FileName, Params, DefaultDir: string;
  ShowCmd: Integer): THandle;
var
  zFileName, zParams, zDir: array[0..79] of Char;
begin
  Result := ShellExecute(Application.MainForm.Handle, nil,
    StrPCopy(zFileName, FileName), StrPCopy(zParams, Params),
    StrPCopy(zDir, DefaultDir), ShowCmd);
end;

end.
