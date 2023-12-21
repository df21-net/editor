unit L_util;

interface
uses SysUtils, WinTypes, WinProcs, Messages, Classes,
     StdCtrls, Gauges, FileCtrl, Forms, _Strings, System.Strutils;

CONST
 ERRLFD_NOERROR   =  0;
 ERRLFD_NOTEXISTS = -1;
 ERRLFD_NOTLFD    = -2;
 ERRLFD_BADLFD    = -3;

TYPE
 LFD_INDEX = record
   MAGIC  : array[1..4] of AnsiChar;
   NAME   : array[1..8] of AnsiChar;
   LEN    : LongInt;
 end;

LFD_BEGIN = LFD_INDEX;

function FilePosition(Handle: Integer) : Longint;
function FileSizing(Handle: Integer) : Longint; {FileSize already exists !}

function IsLFD(LFDname : TFileName) : Boolean;
function IsResourceInLFD(LFDname, RESName : TFileName; VAR IX, LEN : LongInt) : Boolean;
function LFD_GetDirList(LFDname : TFileName; VAR DirList : TListBox) : Integer;
function LFD_GetDetailedDirList(LFDname : TFileName; VAR DirList : TMemo) : Integer;
function LFD_CreateEmpty(LFDname : TFileName) : Integer;
function LFD_ExtractResource(OutputDir : String ; LFDname : TFileName; ResName : String) : Integer;
function LFD_ExtractFiles(OutputDir : String ; LFDname : TFileName; DirList : TListBox; ProgressBar : TGauge) : Integer;
function LFD_AddFiles(InputDir : String ; LFDname : TFileName; DirList : TFileListBox; ProgressBar : TGauge) : Integer;
function LFD_RemoveFiles(LFDname : TFileName; DirList : TListBox; ProgressBar : TGauge) : Integer;
function LFD_MagicConvert(LFDAsset : String) : String;

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

function IsLFD(LFDname : TFileName) : Boolean;
var gs : LFD_BEGIN;
    gf : Integer;
begin
  gf := FileOpen(LFDName, fmOpenRead);
  FileRead(gf, gs, SizeOf(gs));
  FileClose(gf);
  with gs do
   if (MAGIC[1] = 'R') and
      (MAGIC[2] = 'M') and
      (MAGIC[3] = 'A') and
      (MAGIC[4] = 'P')
    then
     IsLFD := TRUE
    else
     IsLFD := FALSE;
end;

function ArrayToString(const a: array of Char): string;
begin
  if Length(a)>0 then
    SetString(Result, PChar(@a[0]), Length(a))
  else
    Result := '';
end;

function IsResourceInLFD(LFDname, RESName : TFileName; VAR IX, LEN : LongInt) : Boolean;
var i       : LongInt;
    MASTERN : LongInt;
    cur_idx : LongInt;
    gs      : LFD_BEGIN;
    gx      : LFD_INDEX;
    gf      : Integer;
    found   : Boolean;
begin
  found := FALSE;
  gf := FileOpen(LFDName, fmOpenRead);
  FileRead(gf, gs, SizeOf(gs));

  MASTERN := gs.LEN div 16;
  cur_idx := gs.LEN + 16 + 16;
  for i := 1 to MASTERN do
    begin
      FileRead(gf, gx, SizeOf(gx));
      if AnsiString(gx.MAGIC) + AnsiString(gx.NAME) = RESName then
        begin
          IX    := cur_idx;
          LEN   := gx.LEN;
          Found := TRUE;
          break;
        end;
      cur_idx   := cur_idx + gx.LEN + 16;
     end;
  FileClose(gf);
  IsResourceInLFD := Found;
end;

function LFD_GetDirList(LFDname : TFileName; VAR DirList : TListBox) : Integer;
var i       : LongInt;
    j,k     : Integer;
    MASTERN : LongInt;
    gs      : LFD_BEGIN;
    gx      : LFD_INDEX;
    gf      : Integer;
    OldCursor : HCursor;
begin
  OldCursor := SetCursor(LoadCursor(0, IDC_WAIT));
  if FileExists(LFDName)
   then
    if IsLFD(LFDName)
     then
      begin
       gf := FileOpen(LFDName, fmOpenRead);
       FileRead(gf, gs, SizeOf(gs));
       MASTERN := gs.LEN div 16;
       DirList.Clear;
       for i := 1 to MASTERN do
        begin
         FileRead(gf, gx, SizeOf(gx));
         for j := 1 to 8 do if (gx.NAME[j] = #0) then for k := j to 8 do gx.NAME[k] := ' ';
         DirList.Items.Add(RTrim(gx.NAME) + '.' + gx.MAGIC);
        end;
       FileClose(gf);
       LFD_GetDirList := ERRLFD_NOERROR;
      end
     else
      LFD_GetDirList := ERRLFD_NOTLFD
   else
    LFD_GetDirList := ERRLFD_NOTEXISTS;
  SetCursor(OldCursor);
end;


function LFD_GetDetailedDirList(LFDname : TFileName; VAR DirList : TMemo) : Integer;
var i       : LongInt;
    j,k     : Integer;
    MASTERN : LongInt;
    cur_idx : LongInt;
    gs      : LFD_BEGIN;
    gx      : LFD_INDEX;
    gf      : Integer;
    S_NAME,
    S_IX,
    S_LEN   : String;
    OldCursor : HCursor;
begin
  OldCursor := SetCursor(LoadCursor(0, IDC_WAIT));
  if FileExists(LFDName)
   then
    if IsLFD(LFDName)
     then
      begin
       gf := FileOpen(LFDName, fmOpenRead);
       FileRead(gf, gs, SizeOf(gs));
       MASTERN := gs.LEN div 16;
       cur_idx := gs.LEN + 16;

       DirList.Clear;
       DirList.Lines.BeginUpdate;
       for i := 1 to MASTERN do
        begin
         FileRead(gf, gx, SizeOf(gx));
         for j := 1 to 8 do if gx.NAME[j] = #0 then for k := j to 8 do gx.NAME[k] := ' ';
         {!! BUG !! TMemo.Lines.Add n'accepte PAS une null terminated !!}
         Str(cur_idx :8, S_IX);
         Str(gx.LEN :8, S_LEN);
         S_NAME := Copy(gx.MAGIC + RTrim(gx.NAME) + '            ',1,12);
         DirList.Lines.Add(S_NAME + '    ' + S_IX + '    ' + S_LEN);
         cur_idx   := cur_idx + gx.LEN + 16;
        end;
       DirList.Lines.EndUpdate;
       FileClose(gf);
       LFD_GetDetailedDirList := ERRLFD_NOERROR;
      end
     else
      LFD_GetDetailedDirList := ERRLFD_NOTLFD
   else
    LFD_GetDetailedDirList := ERRLFD_NOTEXISTS;
  SetCursor(OldCursor);
end;

function LFD_CreateEmpty(LFDname : TFileName) : Integer;
var gs      : LFD_BEGIN;
    gf      : Integer;
begin
  gf := FileCreate(LFDName);
  with gs do
    begin
      MAGIC := 'RMAP';
      NAME  := 'resource';
      LEN   := 0;
    end;
  FileWrite(gf, gs, SizeOf(gs));
  FileClose(gf);
  LFD_CreateEmpty := 0;
end;

function LFD_ExtractResource(OutputDir : String ; LFDname : TFileName; ResName : String) : Integer;
var i       : LongInt;
    j,k     : Integer;
    sav_len : LongInt;
    cur_idx : LongInt;
    MASTERN : LongInt;
    gs      : LFD_BEGIN;
    gx      : LFD_INDEX;
    gf      : Integer;
    fsf     : Integer;
    fs_NAME : String;
    S_NAME  : String;
    position  : LongInt;
    OldCursor : HCursor;
    Buffer  : array[0..65535] of AnsiChar;
begin
 OldCursor := SetCursor(LoadCursor(0, IDC_WAIT));
 gf := FileOpen(LFDName, fmOpenRead);
 FileRead(gf, gs, SizeOf(gs));

 MASTERN := gs.LEN div 16;
 cur_idx := gs.LEN + 16 + 16;

 for i := 1 to MASTERN do
   begin
     FileRead(gf, gx, SizeOf(gx));
     sav_len := gx.LEN;
     for j := 1 to 8 do if (gx.NAME[j] = #0) or (gx.NAME[j] = ' ') then for k := j to 8 do gx.NAME[k] := #0;
     S_NAME := gx.MAGIC + RTrim(gx.NAME);
     if S_NAME = ResName then
       begin
         position := FilePosition(gf);
         fs_NAME  := OutputDir;
         if Length(OutputDir) <> 3 then fs_NAME := fs_NAME + '\';
         fs_NAME := fs_NAME + RTrim(gx.NAME);
         if gx.MAGIC = 'PLTT' then fs_NAME := fs_NAME + '.PLT';
         if gx.MAGIC = 'FONT' then fs_NAME := fs_NAME + '.FON';
         if gx.MAGIC = 'ANIM' then fs_NAME := fs_NAME + '.ANM';
         if gx.MAGIC = 'DELT' then fs_NAME := fs_NAME + '.DLT';
         if gx.MAGIC = 'VOIC' then fs_NAME := fs_NAME + '.VOC';
         if gx.MAGIC = 'GMID' then fs_NAME := fs_NAME + '.GMD';
         if gx.MAGIC = 'TEXT' then fs_NAME := fs_NAME + '.TXT';
         if gx.MAGIC = 'FILM' then fs_NAME := fs_NAME + '.FLM';
         if gx.MAGIC[4] = '?' then fs_NAME := fs_NAME + '.' + Copy(gx.MAGIC,1,3);

         if TRUE then
           begin
             fsf := FileCreate(fs_NAME);
             FileSeek(gf, cur_idx, 0);
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
     cur_idx   := cur_idx + sav_len  + 16;
   end;
 FileClose(gf);
 SetCursor(OldCursor);
 LFD_ExtractResource := ERRLFD_NOERROR;
end;




function LFD_ExtractFiles(OutputDir   : String;
                          LFDname     : TFileName;
                          DirList     : TListBox;
                          ProgressBar : TGauge) : Integer;
var i       : LongInt;
    j,k     : Integer;
    sav_len : LongInt;
    NSel    : LongInt;
    index   : LongInt;
    cur_idx : LongInt;
    MASTERN : LongInt;
    gs      : LFD_BEGIN;
    gx      : LFD_INDEX;
    gf      : Integer;
    fsf     : Integer;
    fs_NAME : String;
    S_NAME  : String;
    position  : LongInt;
    tmp,tmp2  : array[0..255] of Char;
    go        : Boolean;
    OldCursor : HCursor;
    Buffer  : array[0..65535] of AnsiChar;
    XList   : TStrings;
begin

 OldCursor := SetCursor(LoadCursor(0, IDC_WAIT));
 { XList stores the selected items in the ListBox
   This accelerates the processing a LOT on big LFDS
   because the searches are much shorter }

 XList := TStringList.Create;
 NSel := 0;
 for i := 0 to DirList.Items.Count - 1 do
   if DirList.Selected[i] then
    begin
      Inc(NSel);
      XList.Add(LFD_MagicConvert(DirList.Items[i]));
    end;

 if XList.Count = 0 then
  begin
   XList.Free;
   LFD_ExtractFiles := ERRLFD_NOERROR;
   exit;
  end;

 if(ProgressBar <> NIL) then
  begin
   ProgressBar.MaxValue := NSel;
   ProgressBar.Progress := 0;
  end;

 gf := FileOpen(LFDName, fmOpenRead);
 FileRead(gf, gs, SizeOf(gs));

 MASTERN := gs.LEN div 16;
 cur_idx := gs.LEN + 16 + 16;

 for i := 1 to MASTERN do
   begin
     FileRead(gf, gx, SizeOf(gx));
     sav_len := gx.LEN;
     for j := 1 to 8 do if gx.NAME[j] = #0 then for k := j to 8 do gx.NAME[k] := ' ';
     S_NAME := gx.MAGIC + RTrim(gx.NAME);
     index := XList.IndexOf(S_NAME);
     if index <> -1 then
         begin
           position := FilePosition(gf);
           fs_NAME  := OutputDir;
           if Length(OutputDir) <> 3 then fs_NAME := fs_NAME + '\';
           fs_NAME := fs_NAME + RTrim(gx.NAME);
           if gx.MAGIC = 'PLTT' then fs_NAME := fs_NAME + '.PLT';
           if gx.MAGIC = 'FONT' then fs_NAME := fs_NAME + '.FON';
           if gx.MAGIC = 'ANIM' then fs_NAME := fs_NAME + '.ANM';
           if gx.MAGIC = 'DELT' then fs_NAME := fs_NAME + '.DLT';
           if gx.MAGIC = 'VOIC' then fs_NAME := fs_NAME + '.VOC';
           if gx.MAGIC = 'GMID' then fs_NAME := fs_NAME + '.GMD';
           if gx.MAGIC = 'TEXT' then fs_NAME := fs_NAME + '.TXT';
           if gx.MAGIC = 'FILM' then fs_NAME := fs_NAME + '.FLM';
           if gx.MAGIC[4] = '?' then fs_NAME := fs_NAME + '.' + Copy(gx.MAGIC,1,3);
           go := TRUE;
           {!!!!! Test d'existence !!!!!}
           if FileExists(fs_NAME) then
             begin
               strcopy(tmp, 'Overwrite ');
               strcat(tmp, strPcopy(tmp2, fs_NAME));
               if Application.MessageBox(tmp, 'LFD File Manager', mb_YesNo or mb_IconQuestion) =  IDNo
                then go := FALSE;
             end;
           if go then
             begin
               fsf := FileCreate(fs_NAME);
               FileSeek(gf, cur_idx, 0);
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
     cur_idx := cur_idx + sav_len + 16;
   end;
 XList.Free;
 FileClose(gf);
 if(ProgressBar <> NIL) then
   ProgressBar.Progress := 0;
 SetCursor(OldCursor);

 LFD_ExtractFiles := ERRLFD_NOERROR;
end;

function LFD_AddFiles(InputDir    : String;
                      LFDname     : TFileName;
                      DirList     : TFileListBox;
                      ProgressBar : TGauge) : Integer;
var i       : LongInt;
    j,k     : Integer;
    cur_idx : LongInt;
    sav_len : LongInt;
    tmpstr  : String;
    NSel    : LongInt;
    index   : LongInt;
    MASTERN : LongInt;
    gs      : LFD_BEGIN;
    gx      : LFD_INDEX;
    gf      : Integer;
    gbf     : Integer;
    gdf     : Integer;
    fsf     : Integer;
    fs_NAME : String;
    S_NAME  : String;
    T_NAME  : String;
    LFDBAKName  : TFileName;   {original LFD }
    LFDDATName  : TFileName;   {dynamic DATA }
    position  : LongInt;
    tmp,tmp2  : array[0..255] of Char;
    go        : Boolean;
    OldCursor : HCursor;
    Buffer    : array[0..65535] of AnsiChar;
    Counter   : LongInt;
begin
{
  The algorithm is different for LFDs, as the index is BEFORE the datas
  so use the algorithm in the other way :
  1) Create a backup file named xxxxxxxx.~B~
  2) in the final file, construct the index part by part, while
     creating the data part in a temp file named xxxxxxxx.~D~

  DON'T forget the translation XXXXxxxxx <-> xxxxxxxx.XXX !!!
}

 OldCursor := SetCursor(LoadCursor(0, IDC_WAIT));
 NSel := 0;
 for i := 0 to DirList.Items.Count - 1 do
   if DirList.Selected[i] then Inc(NSel);

 if NSel = 0 then
  begin
   LFD_AddFiles := ERRLFD_NOERROR;
   exit;
  end;

 FileSetAttr(LFDName, 0);

 LFDBAKName := ChangeFileExt(LFDName, '.~B~');
 LFDDATName := ChangeFileExt(LFDName, '.~D~');
 RenameFile(LFDName, LFDBAKName);

 gbf := FileOpen(LFDBAKName, fmOpenRead);
 gf  := FileCreate(LFDName);
 gdf := FileCreate(LFDDATName);

 FileRead(gbf, gs, SizeOf(gs));
 FileWrite(gf, gs, SizeOf(gs));

 MASTERN := gs.LEN div 16;
 cur_idx := gs.LEN + 16 + 16;

 if(ProgressBar <> NIL) then
  begin
   ProgressBar.MaxValue := NSel + MASTERN;
   ProgressBar.Progress := 0;
  end;

 Counter := 0;

 for i := 1 to MASTERN do
   begin
     FileRead(gbf, gx, SizeOf(gx));
     for j := 1 to 8 do if (gx.NAME[j] = #0) or (gx.NAME[j] = ' ') then for k := j to 8 do gx.NAME[k] := #0;
     S_NAME := gx.MAGIC + RTrim(gx.NAME);

     {test name}
     T_NAME := RTrim(gx.NAME);
     if gx.MAGIC = 'PLTT' then T_NAME := T_NAME + '.PLT';
     if gx.MAGIC = 'FONT' then T_NAME := T_NAME + '.FON';
     if gx.MAGIC = 'ANIM' then T_NAME := T_NAME + '.ANM';
     if gx.MAGIC = 'DELT' then T_NAME := T_NAME + '.DLT';
     if gx.MAGIC = 'VOIC' then T_NAME := T_NAME + '.VOC';
     if gx.MAGIC = 'GMID' then T_NAME := T_NAME + '.GMD';
     if gx.MAGIC = 'TEXT' then T_NAME := T_NAME + '.TXT';
     if gx.MAGIC = 'FILM' then T_NAME := T_NAME + '.FLM';
     if gx.MAGIC[4] = '?' then fs_NAME := fs_NAME + '.' + Copy(gx.MAGIC,1,3);

     index := DirList.Items.IndexOf(T_NAME);
     go := TRUE;
     if index <> -1 then
       if DirList.Selected[index] then
         begin
           strcopy(tmp, 'Replace ');
           strcat(tmp, strPcopy(tmp2, S_NAME));
           if Application.MessageBox(tmp, 'LFD File Manager', mb_YesNo or mb_IconQuestion) =  IDYes
             then
               go := FALSE
             else
               DirList.Selected[index] := FALSE;
         end;

     sav_len := gx.LEN;

     if go then
       begin
         position := FilePosition(gbf);
         FileWrite(gdf, gx, SizeOf(gx));
         FileWrite(gf, gx, SizeOf(gx));
         FileSeek(gbf, cur_idx, 0);
         while gx.LEN >= SizeOf(Buffer) do
           begin
             FileRead(gbf, Buffer, SizeOf(Buffer));
             FileWrite(gdf, Buffer, SizeOf(Buffer));
             gx.LEN := gx.LEN - SizeOf(Buffer);
           end;
         FileRead(gbf, Buffer, gx.LEN);
         FileWrite(gdf, Buffer, gx.LEN);
         if(ProgressBar <> NIL) then
           ProgressBar.Progress := ProgressBar.Progress + 1;
         Inc(Counter);
         FileSeek(gbf, position, 0);
       end;
     cur_idx := cur_idx + sav_len + 16;
   end;

 FileClose(gbf);
 {3}
 for i := 0 to DirList.Items.Count - 1 do
   if DirList.Selected[i] then
     begin
       fs_NAME  := InputDir;
       if Length(InputDir) <> 3 then fs_NAME := fs_NAME + '\';
       fs_NAME := fs_NAME + LowerCase(DirList.Items[i]);
       fsf := FileOpen(fs_NAME, fmOpenRead);

       gx.LEN  := FileSizing(fsf);
       T_NAME  := ExtractFileName(fs_NAME) + '        ';
       for j := 1 to 8 do gx.NAME[j] := AnsiChar(T_NAME[j]);
       for j := 1 to 8 do if gx.NAME[j] = '.' then for k := j to 8 do gx.NAME[k] := ' ';
       for j := 1 to 8 do if gx.NAME[j] = ' ' then for k := j to 8 do gx.NAME[k] := AnsiChar(0);
       T_NAME   := UpperCase(ExtractFileExt(fs_NAME));
       tmpstr   := Copy(Copy(T_NAME,2,3) + '????', 1,4);
       gx.MAGIC[1] := AnsiChar(tmpstr[1]);
       gx.MAGIC[2] := AnsiChar(tmpstr[2]);
       gx.MAGIC[3] := AnsiChar(tmpstr[3]);
       gx.MAGIC[4] := AnsiChar(tmpstr[4]);
       if (T_NAME = '.PLT') or (T_NAME = '.PLTT') then gx.MAGIC := 'PLTT';
       if (T_NAME = '.FON') or (T_NAME = '.FONT') then gx.MAGIC := 'FONT';
       if (T_NAME = '.ANM') or (T_NAME = '.ANIM') then gx.MAGIC := 'ANIM';
       if (T_NAME = '.DLT') or (T_NAME = '.DELT') then gx.MAGIC := 'DELT';
       if (T_NAME = '.VOC') or (T_NAME = '.VOIC') then gx.MAGIC := 'VOIC';
       if (T_NAME = '.GMD') or (T_NAME = '.GMID') then gx.MAGIC := 'GMID';
       if (T_NAME = '.TXT') or (T_NAME = '.TEXT') then gx.MAGIC := 'TEXT';
       if (T_NAME = '.FLM') or (T_NAME = '.FILM') then gx.MAGIC := 'FILM';

       FileWrite(gdf, gx, SizeOf(gx));
       FileWrite(gf, gx, SizeOf(gx));
       while gx.LEN >= SizeOf(Buffer) do
         begin
           FileRead(fsf, Buffer, SizeOf(Buffer));
           FileWrite(gdf, Buffer, SizeOf(Buffer));
           gx.LEN := gx.LEN - SizeOf(Buffer);
         end;
       FileRead(fsf, Buffer, gx.LEN);
       FileWrite(gdf, Buffer, gx.LEN);
       FileClose(fsf);
       if(ProgressBar <> NIL) then
        ProgressBar.Progress := ProgressBar.Progress + 1;
       Inc(Counter);
     end;

  FileClose(gdf);

 gdf := FileOpen(LFDDATName, fmOpenRead);
 gx.LEN := FileSizing(gdf);
 while gx.LEN >= SizeOf(Buffer) do
   begin
     FileRead(gdf, Buffer, SizeOf(Buffer));
     FileWrite(gf, Buffer, SizeOf(Buffer));
     gx.LEN := gx.LEN - SizeOf(Buffer);
   end;
 FileRead(gdf, Buffer, gx.LEN);
 FileWrite(gf, Buffer, gx.LEN);

 FileSeek(gf, 12, 0);
 Counter := Counter * 16;
 FileWrite(gf, Counter, SizeOf(Counter));

 FileClose(gdf);
 FileClose(gf);

 SysUtils.DeleteFile(LFDDATName);
 SysUtils.DeleteFile(LFDBAKName);

 if(ProgressBar <> NIL) then
   ProgressBar.Progress := 0;
 SetCursor(OldCursor);

 LFD_AddFiles := ERRLFD_NOERROR;
end;

function LFD_RemoveFiles(LFDname : TFileName; DirList : TListBox; ProgressBar : TGauge) : Integer;
var i       : LongInt;
    j,k     : Integer;
    cur_idx : LongInt;
    sav_len : LongInt;
    MASTERN : LongInt;
    gs      : LFD_BEGIN;
    gx      : LFD_INDEX;
    gf      : Integer;
    gbf     : Integer;
    gdf     : Integer;
    S_NAME  : String;
    LFDBAKName  : TFileName;   {original LFD }
    LFDDATName  : TFileName;   {dynamic LFD DAT }
    position  : LongInt;
    go        : Boolean;
    OldCursor : HCursor;
    Buffer    : array[0..65535] of AnsiChar;
    Counter   : LongInt;
    XList     : TStrings;
    assetstr  : string;
    lendiff   : integer;
begin
 OldCursor  := SetCursor(LoadCursor(0, IDC_WAIT));

  XList := TStringList.Create;
  for i := 0 to DirList.Items.Count - 1 do
   if DirList.Selected[i] then
    begin
      assetstr := LFD_MagicConvert(DirList.Items[i]);
      lendiff := 12 -length(assetstr);

      for j :=  13 - lendiff to 12 do
        assetstr := assetstr + #0;
      XList.Add(assetstr);
    end;

if XList.Count = 0 then
 begin
  XList.Free;
  LFD_RemoveFiles := ERRLFD_NOERROR;
  exit;
 end;

 FileSetAttr(LFDName, 0);

 LFDBAKName := ChangeFileExt(LFDName, '.~B~');
 LFDDATName := ChangeFileExt(LFDName, '.~D~');
 RenameFile(LFDName, LFDBAKName);

 gbf := FileOpen(LFDBAKName, fmOpenRead);
 gf  := FileCreate(LFDName);
 gdf := FileCreate(LFDDATName);

 FileRead(gbf, gs, SizeOf(gs));
 FileWrite(gf, gs, SizeOf(gs));

 MASTERN := gs.LEN div 16;
 cur_idx := gs.LEN + 16 + 16;

 if(ProgressBar <> NIL) then
  begin
   ProgressBar.MaxValue := MASTERN;
   ProgressBar.Progress := 0;
  end;

 Counter := 0;

 for i := 1 to MASTERN do
   begin
     FileRead(gbf, gx, SizeOf(gx));
     for j := 1 to 8 do if (gx.NAME[j] = #0) or (gx.NAME[j] = ' ') then for k := j to 8 do gx.NAME[k] := #0;
     S_NAME := gx.MAGIC + RTrim(gx.NAME);

     sav_len := gx.LEN;

     go := XList.IndexOf(S_NAME) = - 1;
     if go then
       begin
         position := FilePosition(gbf);
         FileWrite(gdf, gx, SizeOf(gx));
         FileWrite(gf, gx, SizeOf(gx));
         FileSeek(gbf, cur_idx, 0);
         while gx.LEN >= SizeOf(Buffer) do
           begin
             FileRead(gbf, Buffer, SizeOf(Buffer));
             FileWrite(gdf, Buffer, SizeOf(Buffer));
             gx.LEN := gx.LEN - SizeOf(Buffer);
           end;
         FileRead(gbf, Buffer, gx.LEN);
         FileWrite(gdf, Buffer, gx.LEN);
         if(ProgressBar <> NIL) then
           ProgressBar.Progress := ProgressBar.Progress + 1;
         Inc(Counter);
         FileSeek(gbf, position, 0);
       end;
     cur_idx := cur_idx + sav_len + 16;
   end;

 XList.Free;
 FileClose(gbf);
 FileClose(gdf);

 gdf := FileOpen(LFDDATName, fmOpenRead);
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
 FileSeek(gf, 12, 0);
 Counter := Counter * 16;
 FileWrite(gf, Counter, SizeOf(Counter));
 FileClose(gf);

 SysUtils.DeleteFile(LFDDATName);
 {This could be a user option}
 SysUtils.DeleteFile(LFDBAKName);

 if(ProgressBar <> NIL) then
   ProgressBar.Progress := 0;
 SetCursor(OldCursor);

 LFD_RemoveFiles := ERRLFD_NOERROR;
end;

function LFD_MagicConvert(LFDAsset : String) : String;
var LFD_FILE, LFD_TYPE : String;
begin
  LFD_FILE := LeftStr(LFDAsset,length(LFDAsset) - 5);
  LFD_TYPE := RightStr(LFDAsset,4);
  Result := LFD_TYPE + LFD_FILE;
end;

end.
