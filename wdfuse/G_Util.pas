unit G_util;

interface
uses SysUtils, WinTypes, WinProcs, Messages, Classes,
     StdCtrls, Gauges, FileCtrl, Forms;

CONST
 ERRGOB_NOERROR   =  0;
 ERRGOB_NOTEXISTS = -1;
 ERRGOB_NOTGOB    = -2;
 ERRGOB_BADGOB    = -3;

TYPE
 GOB_BEGIN = record     {size 8}
   GOB_MAGIC : array[1..4] of char;
   MASTERX   : LongInt;
 end;

 GOB_INDEX = record     {size 21}
   IX        : LongInt;
   LEN       : LongInt;
   NAME      : array[0..12] of char;
 end;


function FilePosition(Handle: Integer) : Longint;
function FileSizing(Handle: Integer) : Longint; {FileSize already exists !}

function IsGOB(GOBname : TFileName) : Boolean;
function IsResourceInGOB(GOBname, RESName : TFileName; VAR IX, LEN : LongInt) : Boolean;
function GOB_GetDirList(GOBname : TFileName; VAR DirList : TListBox) : Integer;
function GOB_GetDetailedDirList(GOBname : TFileName; VAR DirList : TMemo) : Integer;
function GOB_CreateEmpty(GOBname : TFileName) : Integer;
function GOB_ExtractResource(OutputDir : String ; GOBname : TFileName; ResName : String) : Integer;
function GOB_ExtractFiles(OutputDir : String ; GOBname : TFileName; DirList : TListBox; ProgressBar : TGauge) : Integer;
function GOB_AddFiles(InputDir : String ; GOBname : TFileName; DirList : TFileListBox; ProgressBar : TGauge) : Integer;
function GOB_RemoveFiles(GOBname : TFileName; DirList : TListBox; ProgressBar : TGauge) : Integer;

implementation

function FilePosition(Handle: Integer) : Longint;
begin
  FilePosition := FileSeek(Handle, 0, 1);
end;

function FileSizing(Handle: Integer) : Longint;
var tmppos : LongInt;
begin
  tmppos := FilePosition(Handle);
  FileSizing := FileSeek(Handle, 0, 2);
  FileSeek(Handle, tmppos, 0);
end;

function IsGOB(GOBname : TFileName) : Boolean;
var gs : GOB_BEGIN;
    gf : Integer;
begin
  gf := FileOpen(GOBName, fmOpenRead);
  FileRead(gf, gs, SizeOf(gs));
  FileClose(gf);
  with gs do
   if (GOB_MAGIC[1] = 'G') and
      (GOB_MAGIC[2] = 'O') and
      (GOB_MAGIC[3] = 'B') and
      (GOB_MAGIC[4] = #10)
    then
     IsGOB := TRUE
    else
     IsGOB := FALSE;
end;


function IsResourceInGOB(GOBname, RESName : TFileName; VAR IX, LEN : LongInt) : Boolean;
var i       : LongInt;
    MASTERN : LongInt;
    gs      : GOB_BEGIN;
    gx      : GOB_INDEX;
    gf      : Integer;
    S_NAME  : String;
    found   : Boolean;
begin
  found := FALSE;
  gf := FileOpen(GOBName, fmOpenRead or fmShareDenyNone);
  FileRead(gf, gs, SizeOf(gs));
  FileSeek(gf, gs.MASTERX, 0);
  FileRead(gf, MASTERN, 4);
  for i := 1 to MASTERN do
    begin
      FileRead(gf, gx, SizeOf(gx));
      S_NAME := StrPas(gx.NAME);
      if S_Name = RESName then
        begin
          IX    := gx.IX;
          LEN   := gx.LEN;
          Found := TRUE;
        end;
     end;
  FileClose(gf);
  IsResourceInGOB := Found;
end;

function GOB_GetDirList(GOBname : TFileName; VAR DirList : TListBox) : Integer;
var i       : LongInt;
    MASTERN : LongInt;
    gs      : GOB_BEGIN;
    gx      : GOB_INDEX;
    gf      : Integer;
    OldCursor : HCursor;
begin
  OldCursor := SetCursor(LoadCursor(0, IDC_WAIT));
  if FileExists(GOBName)
   then
    if IsGOB(GOBName)
     then
      begin
       gf := FileOpen(GOBName, fmOpenRead);
       FileRead(gf, gs, SizeOf(gs));
       FileSeek(gf, gs.MASTERX, 0);
       FileRead(gf, MASTERN, 4);
       DirList.Clear;
       for i := 1 to MASTERN do
        begin
         FileRead(gf, gx, SizeOf(gx));
         DirList.Items.Add(gx.NAME);
        end;
       FileClose(gf);
       GOB_GetDirList := ERRGOB_NOERROR;
      end
     else
      GOB_GetDirList := ERRGOB_NOTGOB
   else
    GOB_GetDirList := ERRGOB_NOTEXISTS;
  SetCursor(OldCursor);
end;


function GOB_GetDetailedDirList(GOBname : TFileName; VAR DirList : TMemo) : Integer;
var i       : LongInt;
    MASTERN : LongInt;
    gs      : GOB_BEGIN;
    gx      : GOB_INDEX;
    gf      : Integer;
    S_NAME,
    S_IX,
    S_LEN   : String;
    OldCursor : HCursor;
begin
  OldCursor := SetCursor(LoadCursor(0, IDC_WAIT));
  if FileExists(GOBName)
   then
    if IsGOB(GOBName)
     then
      begin
       gf := FileOpen(GOBName, fmOpenRead);
       FileRead(gf, gs, SizeOf(gs));
       FileSeek(gf, gs.MASTERX, 0);
       FileRead(gf, MASTERN, 4);
       DirList.Clear;
       DirList.Lines.BeginUpdate;
       for i := 1 to MASTERN do
        begin
         FileRead(gf, gx, SizeOf(gx));
         {!! DELPHI BUG !! TMemo.Lines.Add doesn't accept null terminated !!}
         Str(gx.IX  :8, S_IX);
         Str(gx.LEN :8, S_LEN);
         S_NAME := Copy(StrPas(gx.NAME) + '            ',1,12);
         DirList.Lines.Add(S_NAME + '    ' + S_IX + '    ' + S_LEN);
        end;
       DirList.Lines.EndUpdate;
       FileClose(gf);
       GOB_GetDetailedDirList := ERRGOB_NOERROR;
      end
     else
      GOB_GetDetailedDirList := ERRGOB_NOTGOB
   else
    GOB_GetDetailedDirList := ERRGOB_NOTEXISTS;
  SetCursor(OldCursor);
end;

function GOB_CreateEmpty(GOBname : TFileName) : Integer;
var MASTERN : LongInt;
    gs      : GOB_BEGIN;
    gf      : Integer;
begin
  gf := FileCreate(GOBName);
  with gs do
    begin
      GOB_MAGIC[1] := 'G';
      GOB_MAGIC[2] := 'O';
      GOB_MAGIC[3] := 'B';
      GOB_MAGIC[4] := #10;
      MASTERX      := 8;
    end;
  FileWrite(gf, gs, SizeOf(gs));
  MASTERN := 0;
  FileWrite(gf, MASTERN, 4);
  FileClose(gf);
  GOB_CreateEmpty := 0;
end;

function GOB_ExtractResource(OutputDir : String ; GOBname : TFileName; ResName : String) : Integer;
var i       : LongInt;
    MASTERN : LongInt;
    gs      : GOB_BEGIN;
    gx      : GOB_INDEX;
    gf      : Integer;
    fsf     : Integer;
    fs_NAME : String;
    S_NAME  : String;
    position  : LongInt;
    OldCursor : HCursor;
    Buffer  : array[0..4095] of Char;
begin
 OldCursor := SetCursor(LoadCursor(0, IDC_WAIT));
 gf := FileOpen(GOBName, fmOpenRead);
 FileRead(gf, gs, SizeOf(gs));
 FileSeek(gf, gs.MASTERX, 0);
 FileRead(gf, MASTERN, 4);
 for i := 1 to MASTERN do
   begin
     FileRead(gf, gx, SizeOf(gx));
     S_NAME := StrPas(gx.NAME);
     if S_NAME = ResName then
       begin
         position := FilePosition(gf);
         fs_NAME  := OutputDir;
         if Length(OutputDir) <> 3 then fs_NAME := fs_NAME + '\';
         fs_NAME := fs_NAME + S_NAME;
         if TRUE then
           begin
             fsf := FileCreate(fs_NAME);
             FileSeek(gf, gx.IX, 0);
             while gx.LEN >= SizeOf(Buffer) do
               begin
                 FileRead(gf, Buffer, SizeOf(Buffer));
                 FileWrite(fsf, Buffer, SizeOf(Buffer));
                 gx.LEN := gx.LEN - SizeOf(Buffer);
               end;
             FileRead(gf, Buffer, gx.LEN);
             FileWrite(fsf, Buffer, gx.LEN);
             FileClose(fsf);
             FileSeek(gf, position, 0);
           end;
       end;
   end;
 FileClose(gf);
 SetCursor(OldCursor);
 GOB_ExtractResource := ERRGOB_NOERROR;
end;




function GOB_ExtractFiles(OutputDir   : String;
                          GOBname     : TFileName;
                          DirList     : TListBox;
                          ProgressBar : TGauge) : Integer;
var i       : LongInt;
    NSel    : LongInt;
    index   : LongInt;
    MASTERN : LongInt;
    gs      : GOB_BEGIN;
    gx      : GOB_INDEX;
    gf      : Integer;
    fsf     : Integer;
    fs_NAME : String;
    S_NAME  : String;
    position  : LongInt;
    tmp,tmp2  : array[0..127] of Char;
    go        : Boolean;
    OldCursor : HCursor;
    Buffer  : array[0..4095] of Char;
    XList   : TStrings;
begin
 OldCursor := SetCursor(LoadCursor(0, IDC_WAIT));
 { XList stores the selected items in the ListBox
   This accelerates the processing a LOT on big GOBS
   because the searches are much shorter }
 XList := TStringList.Create;
 NSel := 0;
 for i := 0 to DirList.Items.Count - 1 do
   if DirList.Selected[i] then
    begin
      Inc(NSel);
      XList.Add(DirList.Items[i]);
    end;

 if XList.Count = 0 then
  begin
   XList.Free;
   GOB_ExtractFiles := ERRGOB_NOERROR;
   exit;
  end;

 if(ProgressBar <> NIL) then
  begin
   ProgressBar.MaxValue := NSel;
   ProgressBar.Progress := 0;
  end;

 gf := FileOpen(GOBName, fmOpenRead);
 FileRead(gf, gs, SizeOf(gs));
 FileSeek(gf, gs.MASTERX, 0);
 FileRead(gf, MASTERN, 4);
 for i := 1 to MASTERN do
   begin
     FileRead(gf, gx, SizeOf(gx));
     S_NAME := StrPas(gx.NAME);
     index := XList.IndexOf(S_NAME);
     if index <> -1 then
         begin
           position := FilePosition(gf);
           fs_NAME  := OutputDir;
           if Length(OutputDir) <> 3 then fs_NAME := fs_NAME + '\';
           fs_NAME := fs_NAME + S_NAME;
           go := TRUE;
           {!!!!! Test d'existence !!!!!}
           if FileExists(fs_NAME) then
             begin
               strcopy(tmp, 'Overwrite ');
               strcat(tmp, strPcopy(tmp2, fs_NAME));
               if Application.MessageBox(tmp, 'GOB File Manager', mb_YesNo or mb_IconQuestion) =  IDNo
                then go := FALSE;
             end;
           if go then
             begin
               fsf := FileCreate(fs_NAME);
               FileSeek(gf, gx.IX, 0);
               while gx.LEN >= SizeOf(Buffer) do
                 begin
                   FileRead(gf, Buffer, SizeOf(Buffer));
                   FileWrite(fsf, Buffer, SizeOf(Buffer));
                   gx.LEN := gx.LEN - SizeOf(Buffer);
                 end;
               FileRead(gf, Buffer, gx.LEN);
               FileWrite(fsf, Buffer, gx.LEN);
               FileClose(fsf);
               if(ProgressBar <> NIL) then
                 ProgressBar.Progress := ProgressBar.Progress + 1;
               FileSeek(gf, position, 0);
             end;
         end;
   end;
 XList.Free;
 FileClose(gf);
 if(ProgressBar <> NIL) then
   ProgressBar.Progress := 0;
 SetCursor(OldCursor);
 GOB_ExtractFiles := ERRGOB_NOERROR;
end;

function GOB_AddFiles(InputDir    : String;
                      GOBname     : TFileName;
                      DirList     : TFileListBox;
                      ProgressBar : TGauge) : Integer;
var i           : LongInt;
    NSel        : LongInt;
    index       : LongInt;
    MASTERN     : LongInt;
    gs          : GOB_BEGIN;
    gx          : GOB_INDEX;
    gf          : Integer;
    gbf         : Integer;
    gdf         : Integer;
    fsf         : Integer;
    fs_NAME     : String;
    S_NAME      : String;
    GOBBAKName  : TFileName;   {original GOB }
    GOBDIRName  : TFileName;   {dynamic GOB dir }
    position    : LongInt;
    tmp,tmp2    : array[0..127] of Char;
    go          : Boolean;
    OldCursor   : HCursor;
    Buffer      : array[0..4095] of Char;
    Counter     : LongInt;
begin
{ ALGORITHM
  =========

  1) Create a backup file named xxxxxxxx.~B~
  2) Copy that backup element by element, creating an dir file
     named xxxxxxxx.~D~
     If the file is one of the files to add then
       ask confirmation for the REPLACE
       If confirmed then
         skip the old file
       else
         copy the old file AND DESELECT from the list box
         (else it will be added in 5) !!)
  3) Take the added files one by one, and continue the same
     method.
  4) Close the dir file, then append it to the new gob file
     update the MASTERX field in the new GOB file
  5) Remove the dir file
  6) Remove the backup file
}
 OldCursor := SetCursor(LoadCursor(0, IDC_WAIT));
 NSel := 0;
 for i := 0 to DirList.Items.Count - 1 do
   if DirList.Selected[i] then Inc(NSel);

 if NSel = 0 then
  begin
   GOB_AddFiles := ERRGOB_NOERROR;
   exit;
  end;

 FileSetAttr(GOBName, 0);

 GOBBAKName := ChangeFileExt(GOBName, '.~B~');
 GOBDIRName := ChangeFileExt(GOBName, '.~D~');
 RenameFile(GOBName, GOBBAKName);

 gbf := FileOpen(GOBBAKName, fmOpenRead);
 gf  := FileCreate(GOBName);
 gdf := FileCreate(GOBDIRName);

 FileRead(gbf, gs, SizeOf(gs));
 FileWrite(gf, gs, SizeOf(gs));
 FileSeek(gbf, gs.MASTERX, 0);
 FileRead(gbf, MASTERN, 4);

 if(ProgressBar <> NIL) then
  begin
   ProgressBar.MaxValue := NSel + MASTERN;
   ProgressBar.Progress := 0;
  end;

 Counter := 0;
 {2}
 for i := 1 to MASTERN do
   begin
     FileRead(gbf, gx, SizeOf(gx));
     S_NAME := StrPas(gx.NAME);
     go := TRUE;
     index := DirList.Items.IndexOf(S_NAME);
     if index <> -1 then
       if DirList.Selected[index] then
         begin
           strcopy(tmp, 'Replace ');
           strcat(tmp, strPcopy(tmp2, S_NAME));
           if Application.MessageBox(tmp, 'GOB File Manager', mb_YesNo or mb_IconQuestion) =  IDYes
             then
               go := FALSE
             else
               DirList.Selected[index] := FALSE;
         end;
     if go then
       begin
         position := FilePosition(gbf);
         FileSeek(gf, gx.IX, 0);
         gx.IX := FilePosition(gf);
         FileWrite(gdf, gx, SizeOf(gx));
         while gx.LEN >= SizeOf(Buffer) do
           begin
             FileRead(gbf, Buffer, SizeOf(Buffer));
             FileWrite(gf, Buffer, SizeOf(Buffer));
             gx.LEN := gx.LEN - SizeOf(Buffer);
           end;
         FileRead(gbf, Buffer, gx.LEN);
         FileWrite(gf, Buffer, gx.LEN);
         if(ProgressBar <> NIL) then
           ProgressBar.Progress := ProgressBar.Progress + 1;
         Inc(Counter);
         FileSeek(gbf, position, 0);
       end;
   end;

 FileClose(gbf);
 {3}
 for i := 0 to DirList.Items.Count - 1 do
   if DirList.Selected[i] then
     begin
       fs_NAME  := InputDir;
       if Length(InputDir) <> 3 then fs_NAME := fs_NAME + '\';
       fs_NAME := fs_NAME + UpperCase(DirList.Items[i]);
       fsf := FileOpen(fs_NAME, fmOpenRead);
       gx.IX   := FilePosition(gf);
       gx.LEN  := FileSizing(fsf);
       StrPcopy(gx.NAME, ExtractFileName(fs_NAME));
       FileWrite(gdf, gx, SizeOf(gx));
       while gx.LEN >= SizeOf(Buffer) do
         begin
           FileRead(fsf, Buffer, SizeOf(Buffer));
           FileWrite(gf, Buffer, SizeOf(Buffer));
           gx.LEN := gx.LEN - SizeOf(Buffer);
         end;
       FileRead(fsf, Buffer, gx.LEN);
       FileWrite(gf, Buffer, gx.LEN);
       FileClose(fsf);
       if(ProgressBar <> NIL) then
        ProgressBar.Progress := ProgressBar.Progress + 1;
       Inc(Counter);
     end;

  FileClose(gdf);

 {4}
 gs.MASTERX := FilePosition(gf);
 FileWrite(gf, Counter, SizeOf(Counter));
 gdf := FileOpen(GOBDIRName, fmOpenRead);
 gx.LEN := FileSizing(gdf);
 while gx.LEN >= SizeOf(Buffer) do
   begin
     FileRead(gdf, Buffer, SizeOf(Buffer));
     FileWrite(gf, Buffer, SizeOf(Buffer));
     gx.LEN := gx.LEN - SizeOf(Buffer);
   end;
 FileRead(gdf, Buffer, gx.LEN);
 FileWrite(gf, Buffer, gx.LEN);
 FileClose(gdf);

 {Update MASTERX field}
 FileSeek(gf, 4, 0);
 FileWrite(gf, gs.MASTERX, 4);
 FileClose(gf);

 SysUtils.DeleteFile(GOBDIRName);
 SysUtils.DeleteFile(GOBBAKName);

 if(ProgressBar <> NIL) then
   ProgressBar.Progress := 0;
 SetCursor(OldCursor);
 GOB_AddFiles := ERRGOB_NOERROR;
end;

function GOB_RemoveFiles(GOBname : TFileName; DirList : TListBox; ProgressBar : TGauge) : Integer;
var i       : LongInt;
    MASTERN : LongInt;
    gs      : GOB_BEGIN;
    gx      : GOB_INDEX;
    gf      : Integer;
    gbf     : Integer;
    gdf     : Integer;
    S_NAME  : String;
    GOBBAKName  : TFileName;   {original GOB }
    GOBDIRName  : TFileName;   {dynamic GOB dir }
    position  : LongInt;
    go        : Boolean;
    OldCursor : HCursor;
    Buffer    : array[0..4095] of Char;
    Counter   : LongInt;
    XList     : TStrings;
begin
{ ALGORITHM
  =========

  1) Create a backup file named xxxxxxxx.~B~
  2) Copy that backup element by element, creating an dir file
     named xxxxxxxx.~D~
     If the file is one of the files to delete then
       skip the old file
  4) Close the dir file, then append it to the new gob file
     update the MASTERX field in the new GOB file
  5) Remove the dir file
  6) Remove the backup file
}
 OldCursor  := SetCursor(LoadCursor(0, IDC_WAIT));

 XList := TStringList.Create;
 for i := 0 to DirList.Items.Count - 1 do
   if DirList.Selected[i] then
      XList.Add(DirList.Items[i]);

if XList.Count = 0 then
 begin
  XList.Free;
  GOB_RemoveFiles := ERRGOB_NOERROR;
  exit;
 end;

 {remove the read only status if the file came from the CD !}
 FileSetAttr(GOBName, 0);

 GOBBAKName := ChangeFileExt(GOBName, '.~B~');
 GOBDIRName := ChangeFileExt(GOBName, '.~D~');
 RenameFile(GOBName, GOBBAKName);

 gbf := FileOpen(GOBBAKName, fmOpenRead);
 gf  := FileCreate(GOBName);
 gdf := FileCreate(GOBDIRName);

 FileRead(gbf, gs, SizeOf(gs));
 FileWrite(gf, gs, SizeOf(gs));
 FileSeek(gbf, gs.MASTERX, 0);
 FileRead(gbf, MASTERN, 4);

 if(ProgressBar <> NIL) then
  begin
   ProgressBar.MaxValue := MASTERN;
   ProgressBar.Progress := 0;
  end;

 Counter := 0;
 {2}
 for i := 1 to MASTERN do
   begin
    FileRead(gbf, gx, SizeOf(gx));
    S_NAME  := StrPas(gx.NAME);
    go := XList.IndexOf(S_NAME) = -1;
    if go then
     begin
      position := FilePosition(gbf);
      FileSeek(gbf, gx.IX, 0);
      gx.IX := FilePosition(gf);
      FileWrite(gdf, gx, SizeOf(gx));
      Inc(Counter);

      while gx.LEN >= SizeOf(Buffer) do
       begin
        FileRead(gbf, Buffer, SizeOf(Buffer));
        FileWrite(gf, Buffer, SizeOf(Buffer));
        gx.LEN := gx.LEN - SizeOf(Buffer);
       end;
      FileRead(gbf, Buffer, gx.LEN);
      FileWrite(gf, Buffer, gx.LEN);

      if(ProgressBar <> NIL) then
        ProgressBar.Progress := ProgressBar.Progress + 1;
      FileSeek(gbf, position, 0);
     end;
   end;

 XList.Free;
 FileClose(gbf);
 FileClose(gdf);

 {4}
 gs.MASTERX := FilePosition(gf);
 FileWrite(gf, Counter, SizeOf(Counter));
 gdf := FileOpen(GOBDIRName, fmOpenRead);
 gx.LEN := FileSizing(gdf);
 while gx.LEN >= SizeOf(Buffer) do
  begin
   FileRead(gdf, Buffer, SizeOf(Buffer));
   FileWrite(gf, Buffer, SizeOf(Buffer));
   gx.LEN := gx.LEN - SizeOf(Buffer);
  end;
 FileRead(gdf, Buffer, gx.LEN);
 FileWrite(gf, Buffer, gx.LEN);
 FileClose(gdf);

 {Update MASTERX field}
 FileSeek(gf, 4, 0);
 FileWrite(gf, gs.MASTERX, 4);
 FileClose(gf);

 SysUtils.DeleteFile(GOBDIRName);
 SysUtils.DeleteFile(GOBBAKName);

 if(ProgressBar <> NIL) then ProgressBar.Progress := 0;
 SetCursor(OldCursor);
 GOB_RemoveFiles := ERRGOB_NOERROR;
end;


end.
