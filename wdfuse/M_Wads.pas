unit M_wads;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, FileCtrl, ExtCtrls, Dialogs, SysUtils, IniFiles,
  M_Global, _files, _strings, M_Util, M_MapUt, G_Util, W_Util, M_WadMap,
  M_Progrs, M_Multi, M_mapfun, M_Editor, M_WadsUt, M_IO;

TYPE {linedef action description}
 TLDA_DESC = record
    act    : Char;     {action type}
    elev   : String;   {elevator type}
    master : Boolean;  {master at start}
    event  : Char;     {event mask}
    rep    : Char;     {repeatability}
    trig   : Char;     {trigger action}
    stops  : String;   {nb of stop / Variable}
    first  : string;   {first stop}
    next   : string;   {next stop}
    speed  : Integer;  {speed REFERENCE}
    hold   : Integer;  {-1 for hold, or hold time}
    spec   : String;   {specials e.g. keys, crush bits, ...}
    desc   : String;   {textual description}
 end;

TYPE {things description}
 TTH_DESC  = record
    debug  : String;   {Y/N}
    dfclas : String;
    dfdata : String;
    logic  : String;
    duplic : Integer;
    spec   : String;   {specials e.g. keys, crush bits, ...}
    dmclas : String;
    dmroot : String;
    desc   : String;   {textual description}
 end;

procedure DO_LoadWAD(TheWAD : TFileName);
procedure DO_LoadWADMap(TheWAD : TFileName; TheMAP : String);

procedure DO_ReadWADSectors(wf : Integer;  numsectors  : LongInt);
procedure DO_ReadWADVertexes(wf : Integer; numvertexes : LongInt);
procedure DO_ReadWADLinedefs(wf : Integer; numlinedefs : LongInt);
procedure DO_ReadWADSidedefs(wf : Integer; numsidedefs : LongInt);
procedure DO_ReadWADThings(wf : Integer;   numthings   : LongInt);

procedure DO_ConvertSectors;
procedure DO_RecreateDiscarded;
procedure DO_CorrectSectors;
procedure DO_ConvertSectorFlags(TheMAP : String);
procedure DO_ConvertWallFlags;
procedure DO_NameSectors;

procedure DO_AllAdjoins;
procedure DO_Texturing;
procedure DO_FlagDoors;
procedure DO_ConvertLinedefActions;
procedure DO_ConvertLinedefSpecialActions;

procedure DO_CreateTrueSectorLights;
procedure DO_CreateSectorLights;
procedure DO_Create_30_300_Specials;
procedure DO_CreateSectorFloorAnims;
procedure DO_CreateSectorCeilingAnims;

procedure Do_ConvertThings;
procedure DO_CreateListForAlex;

procedure DO_InitWadINF;
procedure WI_CR;
procedure WI_COMMENT(s : String);
procedure WI_ITEMSECTOR(s : String);
procedure WI_ITEMLINE(s : String; num : Integer);
procedure WI_SEQ;
procedure WI_CLASS(s : String);
procedure WI_MASTEROFF;
procedure WI_EVENTMASK(s : String);
procedure WI_MESSAGE(s : String);
procedure WI_ENTITYMASK(s : String);
procedure WI_STOP(s : String);
procedure WI_SPEED(s : String);
procedure WI_OTHER(s : String);
procedure WI_KEY(s : String);
procedure WI_CLIENT(s : String);
procedure WI_SLAVE(s : String);
procedure WI_SEQEND;
procedure DO_WriteWadINF;

procedure DO_CreateDummySector(name : String);
function  GetLineActionData(num : Integer; VAR lda : TLDA_DESC) : Boolean;
function  GetThingData(num : Integer; VAR thd : TTH_DESC) : Boolean;

function  DOOM_GetOBColor(thing : String) : LongInt;
procedure DOOM_FillLogic(thing : String);

VAR
    WAD_CNVRTLOG  : TStringList;
    WAD_VERTEXES  : TStringList;
    WAD_LINEDEFS  : TStringList;
    WAD_SIDEDEFS  : TStringList;
    WAD_THINGS    : TStringList;
    WAD_INF       : TStringList;
    ElevMade      : TStringList;
    DiscardedLD   : TStringList;
    WAD_INF_ITEMS : Integer;
    WAD_INF_ADDS  : Integer;
    WAD_INF_TRGS  : Integer;
    WAD_INF_ADJS  : Integer;
    WAD_INF_DONS  : Integer;
    TheSky        : String;
    TmpSeqs       : TStringList;
    IWAD          : String;
    W2GSWITCHES   : String;

implementation
uses Mapper;


procedure DO_LoadWAD(TheWAD : TFileName);
var SelMap : String;
begin
 SelMap := '';

 {get data from ini}
 MapSelectWindow.ED_Doom.Text  := Ini.ReadString('WAD CONVERSION', 'Doom', '');
 MapSelectWindow.ED_Doom2.Text := Ini.ReadString('WAD CONVERSION', 'Doom2', '');
 MapSelectWindow.ED_W2GSwitches.Text := Ini.ReadString('WAD CONVERSION', 'W2Gsw', '');

 GetWADMaps(TheWAD, MapSelectWindow.WadDirList.Items);

 if MapSelectWindow.WadDirList.Items.Count <> 0 then
  if Copy(MapSelectWindow.WadDirList.Items[0],1,3) = 'MAP' then
   MapSelectWindow.RGIwad.ItemIndex := 1
  else
   MapSelectWindow.RGIwad.ItemIndex := 0;

 MapSelectWindow.ShowModal;
 if MapSelectWindow.ModalResult = mrOk then
  begin
   {save data to ini}
   Ini.WriteString('WAD CONVERSION', 'Doom', MapSelectWindow.ED_Doom.Text);
   Ini.WriteString('WAD CONVERSION', 'Doom2', MapSelectWindow.ED_Doom2.Text);
   Ini.WriteString('WAD CONVERSION', 'W2Gsw', MapSelectWindow.ED_W2GSwitches.Text);
   if MapSelectWindow.RGIwad.ItemIndex = 0 then
    IWAD := MapSelectWindow.ED_Doom.Text
   else
    IWAD := MapSelectWindow.ED_Doom2.Text;
   W2GSWITCHES := MapSelectWindow.ED_W2GSwitches.Text;
   SelMap := MapSelectWindow.WadDirList.Items[MapSelectWindow.WadDirList.ItemIndex];
   if SelMap <> '' then DO_LoadWADMap(TheWAD, SelMap);
  end;
end;

function ArrayToString(const a: array of Char): string;
begin
  if Length(a)>0 then
    SetString(Result, PChar(@a[0]), Length(a))
  else
    Result := '';
end;

procedure DO_LoadWADMap(TheWAD : TFileName; TheMAP : String);
var numSECTORS,
    numVERTEXES,
    numLINEDEFS,
    numSIDEDEFS,
    numTHINGS     : Integer;
    wf            : Integer;
    sectors_ix    : LongInt;
    sectors_len   : LongInt;
    vertexes_ix   : LongInt;
    vertexes_len  : LongInt;
    linedefs_ix   : LongInt;
    linedefs_len  : LongInt;
    sidedefs_ix   : LongInt;
    sidedefs_len  : LongInt;
    things_ix     : LongInt;
    things_len    : LongInt;
    OldCursor     : HCursor;
    tmp           : array[0..127] of char;
begin
{first do some checks / initializations with the WAD file}
 if not GetWADEntryInfo(TheWAD, TheMAP, 'SECTORS', sectors_ix, sectors_len) then
  begin
   Application.MessageBox('Invalid WAD file (cannot find SECTORS entry)', 'WDFUSE Mapper - NEW Project',
                           mb_Ok or mb_IconExclamation);
   exit;
  end;

 if not GetWADEntryInfo(TheWAD, TheMAP, 'VERTEXES', vertexes_ix, vertexes_len) then
  begin
   Application.MessageBox('Invalid WAD file (cannot find VERTEXES entry)', 'WDFUSE Mapper - NEW Project',
                           mb_Ok or mb_IconExclamation);
   exit;
  end;

 if not GetWADEntryInfo(TheWAD, TheMAP, 'LINEDEFS', linedefs_ix, linedefs_len) then
  begin
   Application.MessageBox('Invalid WAD file (cannot find LINEDEFS entry)', 'WDFUSE Mapper - NEW Project',
                           mb_Ok or mb_IconExclamation);
   exit;
  end;

 if not GetWADEntryInfo(TheWAD, TheMAP, 'SIDEDEFS', sidedefs_ix, sidedefs_len) then
  begin
   Application.MessageBox('Invalid WAD file (cannot find SIDEDEFS entry)', 'WDFUSE Mapper - NEW Project',
                           mb_Ok or mb_IconExclamation);
   exit;
  end;

 if not GetWADEntryInfo(TheWAD, TheMAP, 'THINGS', things_ix, things_len) then
  begin
   Application.MessageBox('Invalid WAD file (cannot find THINGS entry)', 'WDFUSE Mapper - NEW Project',
                           mb_Ok or mb_IconExclamation);
   exit;
  end;

 WAD_CNVRTLOG := TStringList.Create;
 WAD_CNVRTLOG.Add('Converting ' + TheWad + ' ' + TheMap);

 OldCursor  := SetCursor(LoadCursor(0, IDC_WAIT));
 ProgressWindow.Progress1.Caption := 'Converting WAD File';
 ProgressWindow.Gauge.Progress    := 0;
 ProgressWindow.Gauge.MinValue    := 0;
 ProgressWindow.Gauge.MaxValue    := 0;
 ProgressWindow.Show;
 ProgressWindow.Update;

{! To initializations done in IO_ReadLEV O and INF }
 LAYER_MIN  :=  0;
 LAYER_MAX  :=  0;

 MAP_SEC      := TStringList.Create;
 WAD_VERTEXES := TStringList.Create;
 WAD_LINEDEFS := TStringList.Create;
 WAD_SIDEDEFS := TStringList.Create;
 WAD_THINGS   := TStringList.Create;
 TX_LIST      := TStringList.Create;
 MAP_OBJ      := TStringList.Create;
 POD_LIST     := TStringList.Create;
 SPR_LIST     := TStringList.Create;
 FME_LIST     := TStringList.Create;
 SND_LIST     := TStringList.Create;

 DiscardedLD  := TStringList.Create;

 wf := FileOpen(TheWAD, fmOpenRead);

 numSECTORS  := sectors_len div WAD_SIZE_SECTOR;
 FileSeek(wf, sectors_ix, 0);
 DO_ReadWADSectors(wf, numSECTORS);
 WAD_CNVRTLOG.Add('');
 WAD_CNVRTLOG.Add('SECTORS   : ' + IntToStr(numSECTORS));

 numVERTEXES := vertexes_len div WAD_SIZE_VERTEX;
 FileSeek(wf, vertexes_ix, 0);
 DO_ReadWADVertexes(wf, numVERTEXES);
 WAD_CNVRTLOG.Add('VERTEXES  : ' + IntToStr(numVERTEXES));

 numLINEDEFS := linedefs_len div WAD_SIZE_LINEDEF;
 FileSeek(wf, linedefs_ix, 0);
 DO_ReadWADLinedefs(wf, numLINEDEFS);
 WAD_CNVRTLOG.Add('LINEDEFS  : ' + IntToStr(numLINEDEFS));

 numSIDEDEFS := sidedefs_len div WAD_SIZE_SIDEDEF;
 FileSeek(wf, sidedefs_ix, 0);
 DO_ReadWADSidedefs(wf, numSIDEDEFS);
 WAD_CNVRTLOG.Add('SIDEDEFS  : ' + IntToStr(numSIDEDEFS));

 numTHINGS := things_len div WAD_SIZE_THING;
 FileSeek(wf, things_ix, 0);
 DO_ReadWADThings(wf, numTHINGS);
 WAD_CNVRTLOG.Add('THINGS    : ' + IntToStr(numTHINGS));
 WAD_CNVRTLOG.Add('');

 WAD_CNVRTLOG.Add('*** Convert Sectors');
 DO_ConvertSectors;

 {create the "bad" linedefs as new sectors, then free them}
 WAD_CNVRTLOG.Add('*** Recreate discarded linedefs as "thin sectors"');
 DO_RecreateDiscarded;
 DiscardedLD.Free;

 WAD_CNVRTLOG.Add('*** Delete Unreferenced Sectors');
 DO_CorrectSectors; {this will delete sectors without walls or vertices}
 WAD_CNVRTLOG.Add('*** Convert Sector Flags');
 DO_ConvertSectorFlags(TheMAP);
 WAD_CNVRTLOG.Add('*** Convert Linedef Flags');
 DO_ConvertWallFlags;
 DO_CreateDummySector('complete');
 DO_NameSectors;


 DOOM             := TRUE;
 SetDOOMEditors;
 OFILELoaded      := TRUE;
 MODIFIED         := TRUE; {different here 'cause the conversion IS a modif :-)}
 BACKUPED         := FALSE;
 LEV_LEVELNAME    := 'SECBASE';
 LEV_PALETTE      := 'SECBASE.PAL';
 LEV_MUSIC        := 'NOTUSED.GMD';
 LEV_PARALLAX1    := 1024;
 LEV_PARALLAX2    := 1024;
 LEV_VERSION      := '2.1';
 O_LEVELNAME      := 'SECBASE';
 O_VERSION        := '1.1';

 Xoffset          := 0;
 Zoffset          := 0;
 Scale            := 1;
 ScreenX          := MapWindow.Map.Width;
 ScreenZ          := MapWindow.Map.Height;
 ScreenCenterX    := MapWindow.Map.Width div 2;
 ScreenCenterZ    := MapWindow.Map.Height div 2;
 MAP_RECT.Left    := 0;
 MAP_RECT.Right   := MapWindow.Map.Width;
 MAP_RECT.Top     := 0;
 MAP_RECT.Bottom  := MapWindow.Map.Height;
 MapWindow.PanelLevelName.Caption := LEVELName;

 LEVELLoaded      := TRUE;
 DO_SetMapButtonsState;
 DO_Center_Map;
 MAP_MODE := MM_VX;
 DO_Switch_To_SC_Mode;

 WAD_CNVRTLOG.Add('*** Create Adjoins');
 DO_AllAdjoins;

 WAD_CNVRTLOG.Add('*** Convert Texturing');
 DO_Texturing;

 {DO_FlagDoors;}
 DO_InitWadINF;

 {handle Doom actions}
 WAD_CNVRTLOG.Add('*** Convert Linedef Actions');
 DO_ConvertLinedefActions;
 WAD_CNVRTLOG.Add('*** Convert Linedef Special Actions');
 DO_ConvertLinedefSpecialActions;

 {create light elevators}
 WAD_CNVRTLOG.Add('*** Create True Sector Lights');
 DO_CreateTrueSectorLights;
 WAD_CNVRTLOG.Add('*** Approximate Other Sector Lights');
 DO_CreateSectorLights;
 {create close after 30 sec and open after 300 sec specials}
 WAD_CNVRTLOG.Add('*** Create close 30 sec and open 300 sec Sector Types');
 DO_Create_30_300_Specials;
 {create floor animations}
 WAD_CNVRTLOG.Add('*** Create Sector Floor Animations');
 DO_CreateSectorFloorAnims;
 {create ceiling animations}
 WAD_CNVRTLOG.Add('*** Create Sector Ceiling Animations');
 DO_CreateSectorCeilingAnims;

 {create ceiling animations}
 WAD_CNVRTLOG.Add('*** Create Flats & Textures List');

 {!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}
 WAD_CNVRTLOG.Add('*** Convert Things');
 DO_ConvertThings;

 WAD_CNVRTLOG.Add('*** Write INF file');
 DO_WriteWadINF;

 WAD_CNVRTLOG.Add('*** Create Doom Resources List (doom_res.lst)');
 DO_CreateListForAlex;

 {clean up wad stuff}
 FileClose(wf);
 WAD_VERTEXES.Free;
 WAD_LINEDEFS.Free;
 WAD_SIDEDEFS.Free;
 WAD_THINGS.Free;
 WAD_INF.Free;
 ProgressWindow.Hide;

 {reread the INF for the display colors to be correct}
 IO_ReadINF(LEVELPath + '\SECBASE.INF');

 SC_HILITE := 0;
 WL_HILITE := 0;
 VX_HILITE := 0;
 OB_HILITE := 0;
 MAP_MODE := MM_VX;
 DO_Switch_To_SC_Mode;
 MapWindow.Map.Invalidate;
 MapWindow.Map.Update;
 MapWindow.SetFocus;

 SetCursor(OldCursor);

 {write and display the log file}
 WAD_CNVRTLOG.SaveToFile(ChangeFileExt(ProjectFile, '.LOG'));
 WAD_CNVRTLOG.Free;

 if MapSelectWindow.CBExecWad2Gob.Checked then
  begin
   ChDir(LEVELPath);
   strPcopy(tmp, WDFUSEdir + '\wad2gob ' +
                 MapSelectWindow.ED_W2GSwitches.Text +
                 'doom_res.lst ' +
                 IWAD);
   WinExec(PAnsiChar(AnsiString(tmp)), SW_SHOWNORMAL);
  end;

 if MapSelectWindow.CBShowLog.Checked then
  begin
   strPcopy(tmp, 'notepad ' + ChangeFileExt(ProjectFile, '.LOG'));
   WinExec(PAnsiChar(AnsiString(tmp)), SW_SHOWMAXIMIZED);
  end;

 MapWindow.Caption := 'WDFUSE ' +  WDFUSE_VERSION + ' - ' + LowerCase(PROJECTFile) + ' : SECTORS';
end;

procedure DO_ReadWADSectors(wf : Integer; numsectors : LongInt);
var WADSector : TWAD_Sector;
    TheSector : TSector;
    i         : LongInt;
begin
 if numsectors = 0 then exit;
 ProgressWindow.Gauge.MaxValue     := numsectors - 1;
 ProgressWindow.Gauge.Progress     := 0;
 ProgressWindow.Progress2.Caption  := 'Loading SECTORS...';
 ProgressWindow.Progress2.Update;

 for i := 0 to numsectors - 1 do
  begin
   WADSector := TWAD_Sector.Create;

   FileRead(wf, WADSector.H_FLOOR, 4);
   FileRead(wf, WADSector.TX_FLOOR, 8);
   WADSector.TX_FLOOR[8] := #0;
   FileRead(wf, WADSector.TX_CEILI, 8);
   WADSector.TX_CEILI[8] := #0;
   FileRead(wf, WADSector.LIGHT, 6);

   TheSector := TSector.Create;

   { Notes
    Floor.i stores the sector original TAG
    Ceili.i stores the sector original TYPE
   }

   with TheSector do
    begin
     Mark          := 0;
     Reserved      := 0;
     Name          := '';
     Layer         := 0;
     Floor_alt     := WADSector.H_FLOOR / 8;
     Ceili_alt     := WADSector.H_CEILI / 8;
     Second_alt    := 0;
     Ambient       := WADSector.LIGHT div 8;
     Flag1         := 0;
     Flag2         := 0;
     Flag3         := 0;
     {there are lowercase tx in some wads, this is a sure way to kill DF!}
     Floor.Name    := UpperCase(StrPas(WADSector.TX_FLOOR))+'.BM';
     Floor.f1      := 0.0; {flat offsets don't exist in Doom}
     Floor.f2      := 0.0;
     Floor.i       := WADSector.TAG;
     Ceili.Name    := UpperCase(StrPas(WADSector.TX_CEILI))+'.BM';
     Ceili.f1      := 0.0;
     Ceili.f2      := 0.0;
     Ceili.i       := WADSector.STYPE;
     Elevator      := FALSE;
     Trigger       := FALSE;
     Secret        := FALSE;
    end;

   MAP_SEC.AddObject('SC', TheSector);
   WADSector.Free;
   if i mod 20 = 19 then
   ProgressWindow.Gauge.Progress := ProgressWindow.Gauge.Progress + 20;
  end;

end;

procedure DO_ReadWADVertexes(wf : Integer; numvertexes : LongInt);
var WADVertex : TWAD_vertex;
    TheVertex : TVertex;
    i         : LongInt;
begin
 if numvertexes = 0 then exit;
 ProgressWindow.Gauge.MaxValue     := numvertexes - 1;
 ProgressWindow.Gauge.Progress     := 0;
 ProgressWindow.Progress2.Caption  := 'Loading VERTEXES...';
 ProgressWindow.Progress2.Update;

 for i := 0 to numvertexes - 1 do
  begin
   WADVertex := TWAD_Vertex.Create;
   FileRead(wf, WADVertex.X, 4);
   TheVertex := TVertex.Create;

   with TheVertex do
    begin
     Mark          := i;               {may be useful to keep original vx num}
     X             := WADVertex.X / 8;
     Z             := WADVertex.Y / 8;
    end;

   WAD_VERTEXES.AddObject('VX', TheVertex);
   WADVertex.Free;

   if i mod 100 = 99 then
   ProgressWindow.Gauge.Progress := ProgressWindow.Gauge.Progress + 100;
  end;

end;


procedure DO_ReadWADLinedefs(wf : Integer; numlinedefs : LongInt);
var WADLinedef : TWAD_Linedef;
    i          : LongInt;
begin
 if numlinedefs = 0 then exit;
 ProgressWindow.Gauge.MaxValue     := numlinedefs - 1;
 ProgressWindow.Gauge.Progress     := 0;
 ProgressWindow.Progress2.Caption  := 'Loading LINEDEFS...';
 ProgressWindow.Progress2.Update;

 for i := 0 to numlinedefs - 1 do
  begin
   WADLinedef := TWAD_Linedef.Create;
   FileRead(wf, WADLinedef.VERTEX1, WAD_SIZE_LINEDEF);

   WAD_LINEDEFS.AddObject('LD', WADLinedef);
   if i mod 50 = 49 then
   ProgressWindow.Gauge.Progress := ProgressWindow.Gauge.Progress + 50;
  end;
end;


procedure DO_ReadWADSidedefs(wf : Integer; numsidedefs : LongInt);
var WADSidedef : TWAD_Sidedef;
    i          : LongInt;
begin
 if numsidedefs = 0 then exit;
 ProgressWindow.Gauge.MaxValue     := numsidedefs - 1;
 ProgressWindow.Gauge.Progress     := 0;
 ProgressWindow.Progress2.Caption  := 'Loading SIDEDEFS...';
 ProgressWindow.Progress2.Update;

 for i := 0 to numsidedefs - 1 do
  begin
   WADSidedef := TWAD_Sidedef.Create;

   FileRead(wf, WADSidedef.X_OFFSET, 4);
   FileRead(wf, WADSidedef.TX_UPPER, 8);
   WADSidedef.TX_UPPER[8] := #0;
   FileRead(wf, WADSidedef.TX_LOWER, 8);
   WADSidedef.TX_LOWER[8] := #0;
   FileRead(wf, WADSidedef.TX_MAIN, 8);
   WADSidedef.TX_MAIN[8] := #0;
   FileRead(wf, WADSidedef.SECTOR, 2);

   WAD_SIDEDEFS.AddObject('SD', WADSidedef);
   if i mod 100 = 99 then
   ProgressWindow.Gauge.Progress := ProgressWindow.Gauge.Progress + 100;
  end;
end;


procedure DO_ReadWADThings(wf : Integer;   numthings   : LongInt);
var WADThing   : TWAD_Thing;
    i          : LongInt;
begin
 if numthings = 0 then exit;
 ProgressWindow.Gauge.MaxValue     := numthings - 1;
 ProgressWindow.Gauge.Progress     := 0;
 ProgressWindow.Progress2.Caption  := 'Loading THINGS...';
 ProgressWindow.Progress2.Update;

 for i := 0 to numthings - 1 do
  begin
   WADThing := TWAD_Thing.Create;
   FileRead(wf, WADThing.X, WAD_SIZE_THING);

   WAD_THINGS.AddObject('TH', WADThing);
   if i mod 50 = 49 then
   ProgressWindow.Gauge.Progress := ProgressWindow.Gauge.Progress + 50;
  end;
end;

procedure DO_ConvertSectors;
var sc, ld, sd  : Integer;
    TheSector   : TSector;
    TheVertex   : TVertex;
    TheVertex2  : TVertex;
    TheWall     : TWall;
    TheWall2    : TWall;
    WADLinedef  : TWAD_Linedef;
    WADSidedef1 : TWAD_Sidedef;
    WADSidedef2 : TWAD_Sidedef;
    conv        : Integer;
    i, j        : Integer;
    onesided    : Integer;
    v1          : Integer;
    curvx       : Integer;
    endvx       : Integer;
    thecycle    : Integer;
    endofcycle  : Boolean;
    vertexnum   : Integer;
    vxcycle     : Integer;
    counter     : Integer;
    tmp         : array[0..127] of Char;
    str         : string;
begin
 if MAP_SEC.Count = 0 then exit;
 ProgressWindow.Gauge.MaxValue     := MAP_SEC.Count - 1;
 ProgressWindow.Gauge.Progress     := 0;
 ProgressWindow.Progress2.Caption  := 'Converting GEOMETRY...';
 ProgressWindow.Progress2.Update;

 for sc := 0 to MAP_SEC.Count - 1 do
  begin
   TheSector := TSector(MAP_SEC.Objects[sc]);
   tmpWalls  := TStringList.Create;
   for ld := 0 to WAD_LINEDEFS.Count - 1 do
    begin
     WADLinedef  := TWAD_Linedef(WAD_LINEDEFS.Objects[ld]);

     { Drop the linedefs that have the same sector reference on both
       sides. This is a bad Doom habit that cannot be converted easily!}
     if WADLinedef.SIDEDEF2 <> -1 then
      begin
       WADSidedef1 := TWAD_Sidedef(WAD_SIDEDEFS.Objects[WADLinedef.SIDEDEF1]);
       WADSidedef2 := TWAD_Sidedef(WAD_SIDEDEFS.Objects[WADLinedef.SIDEDEF2]);
       if WADSidedef1.SECTOR = WADSidedef2.SECTOR then
        BEGIN
         if sc = 0 then {only do it at first pass!}
          begin
           if WADLinedef.TAG = 0 then {let's make it more visual if linedef is tagged}
            begin
             str := Format('Linedef %d will be DISCARDED because both sides refer to sector (%d)',
                                  [ld, WADSidedef1.SECTOR]);
             WAD_CNVRTLOG.Add('    ' + str);
            end
           else
            begin
             str := Format('Linedef %d (TAG=%d) will be DISCARDED because both sides refer to sector (%d)',
                                  [ld, WADLinedef.TAG, WADSidedef1.SECTOR]);
             WAD_CNVRTLOG.Add('    ' + str);
            end;
           {store the discarded LDs}
           DiscardedLD.Add(Format('%4.4d%4.4d', [ld, WADSidedef1.SECTOR]));
          end;
        continue;
       END;
      end;

     { Notes
       Flag2 stores the linedef original FLAGS
       Mid.i stores the linedef original TAG
       Top.i stores the linedef original ACTION
       Bot.i stores 1 if 1S or 2 for 2S
     }
     WADSidedef1 := TWAD_Sidedef(WAD_SIDEDEFS.Objects[WADLinedef.SIDEDEF1]);
     if WADSidedef1.SECTOR = sc then
      begin
       TheWall := TWall.Create;
       with TheWall do
        begin
          Mark          := 0;
          Reserved      := 0;
          Left_vx       := WADLinedef.VERTEX1;
          Right_vx      := WADLinedef.VERTEX2;
          Adjoin        := -1;
          Mirror        := -1;
          Walk          := -1;
          Light         := 0;
          Flag1         := 0;
          Flag2         := WADLinedef.FLAGS; {it is unused in DF anyway}
          Flag3         := 0;
          if StrPas(WadSidedef1.TX_MAIN) <> '-' then
           Mid.Name      := UpperCase(StrPas(WadSidedef1.TX_MAIN))+'.BM'
          else
           Mid.Name      := '-';
          Mid.f1        := WadSidedef1.X_OFFSET / 8.0;
          Mid.f2        := WadSidedef1.Y_OFFSET / 8.0;
          Mid.i         := WADLinedef.TAG;
          if StrPas(WadSidedef1.TX_UPPER) <> '-' then
           Top.Name      := UpperCase(StrPas(WadSidedef1.TX_UPPER))+'.BM'
          else
           Top.Name      := '-';
          Top.f1        := WadSidedef1.X_OFFSET / 8.0;
          Top.f2        := WadSidedef1.Y_OFFSET / 8.0;
          Top.i         := WADLinedef.ACTION;
          if StrPas(WadSidedef1.TX_LOWER) <> '-' then
           Bot.Name      := UpperCase(StrPas(WadSidedef1.TX_LOWER))+'.BM'
          else
           Bot.Name      := '-';
          Bot.f1        := WadSidedef1.X_OFFSET / 8.0;
          Bot.f2        := WadSidedef1.Y_OFFSET / 8.0;
          Bot.i         := 1; {use this to say: was a 1st SD}
          Sign.Name     := '';
          if Copy(Top.Name,1,2) = 'SW' then Sign.Name := Top.Name;
          if Copy(Bot.Name,1,2) = 'SW' then Sign.Name := Bot.Name;
          if Copy(Mid.Name,1,2) = 'SW' then Sign.Name := Mid.Name;
          Sign.f1       := 0;
          Sign.f2       := 0;
          Sign.i        := 0;
          Elevator      := FALSE;
          Trigger       := FALSE;
          Cycle         := -1;
        end;
       tmpWalls.AddObject('WL', TheWall);
      end;

     if WADLinedef.SIDEDEF2 <> -1 then
      begin
       WADSidedef2 := TWAD_Sidedef(WAD_SIDEDEFS.Objects[WADLinedef.SIDEDEF2]);
       if WADSidedef2.SECTOR = sc then
        begin
         TheWall := TWall.Create;
         with TheWall do
          begin
           Mark          := 0;
           Reserved      := 0;
           Left_vx       := WADLinedef.VERTEX2;
           Right_vx      := WADLinedef.VERTEX1;
           Adjoin        := -1;
           Mirror        := -1;
           Walk          := -1;
           Light         := 0;
           Flag1         := 0;
           Flag2         := WADLinedef.FLAGS; {it is unused in DF anyway}
           Flag3         := 0;
           if StrPas(WadSidedef2.TX_MAIN) <> '-' then
            Mid.Name      := UpperCase(StrPas(WadSidedef2.TX_MAIN))+'.BM'
           else
            Mid.Name      := '-';
           Mid.f1        := WadSidedef2.X_OFFSET / 8.0;
           Mid.f2        := WadSidedef2.Y_OFFSET / 8.0;
           Mid.i         := WADLinedef.TAG;
           if StrPas(WadSidedef2.TX_UPPER) <> '-' then
            Top.Name      := UpperCase(StrPas(WadSidedef2.TX_UPPER))+'.BM'
           else
            Top.Name      := '-';
           Top.f1        := WadSidedef2.X_OFFSET / 8.0;
           Top.f2        := WadSidedef2.Y_OFFSET / 8.0;
           Top.i         := WADLinedef.ACTION;
           if StrPas(WadSidedef2.TX_LOWER) <> '-' then
            Bot.Name      := UpperCase(StrPas(WadSidedef2.TX_LOWER))+'.BM'
           else
            Bot.Name      := '-';
           Bot.f1        := WadSidedef2.X_OFFSET / 8.0;
           Bot.f2        := WadSidedef2.Y_OFFSET / 8.0;
           Bot.i         := 2; {use this to say: was a 2nd SD}
           Sign.Name     := '';
           if Copy(Top.Name,1,2) = 'SW' then Sign.Name := Top.Name;
           if Copy(Bot.Name,1,2) = 'SW' then Sign.Name := Bot.Name;
           if Copy(Mid.Name,1,2) = 'SW' then Sign.Name := Mid.Name;
           Sign.f1       := 0;
           Sign.f2       := 0;
           Sign.i        := 0;
           Elevator      := FALSE;
           Trigger       := FALSE;
           Cycle         := -1;
          end;
         tmpWalls.AddObject('WL', TheWall);
        end;
      end;
    end;

   {tmpWalls contains all the walls for this sector. We must now SORT them by cycles
    WDFUSE must have them ordered by cycles, even if the primary cycle isn't first}

   {we'll use the Cycle attribute to set the walls in order "in place"
    then we'll copy them at their final place, with the vertices}

   endofcycle := TRUE;
   thecycle := 0;
   i := GetFirstUncheckedWall;
   while i <> -1 do {while there are still walls to handle}
    begin
     TheWall       := TWall(tmpWalls.Objects[i]);
     TheWall.Cycle := theCycle;
     Inc(theCycle);

     if theCycle > tmpWalls.Count - 1 then
      begin
       {sector is too complicated OR trivial, PROBLEM !!!}
       {should log this somewhere}
       if tmpWalls.Count < 3 then
        begin
         Str := Format('sc# %3.3d has only %d wall(s)', [sc, tmpWalls.Count]);
        end
       else
        begin
         str := Format('sc# %3.3d could not be converted to cycles correctly (%d walls)', [sc, tmpWalls.Count]);
        end;
       WAD_CNVRTLOG.Add('    ' + str);
       i := -1;
       break;
      end;

     if endofcycle then
      begin
       endvx         := TheWall.Left_vx;
       endofcycle    := FALSE;
      end;
     curvx         := TheWall.Right_vx;
     j             := GetWallBeginningWith(curvx);
     if j = -1 then
      begin
       Str:= Format('sc# %3.3d is not closed (%d walls)', [sc, tmpWalls.Count]);
       WAD_CNVRTLOG.Add('    ' + str);
       i := -1;
       break;
      end
     else
      begin
       TheWall2 := TWall(tmpWalls.Objects[j]);
       if TheWall2.Right_vx = endvx then
        begin
         endofcycle := TRUE;
         TheWall2.Sign.i := 1;
         TheWall2.Cycle := theCycle;
         Inc(theCycle);
         i := GetFirstUncheckedWall;
        end
       else
        i := j;
      end;
    end;

   {now, transfer the walls by order of cycle, but keeping in mind the vertices
    must now be created also. We have to remember the first vertex each time}

   vertexnum := -1;
   vxcycle   := -1;
   for i := 0 to tmpWalls.Count - 1 do
    begin
     j := GetWallWithCycle(i);
     if j <> -1 then
      begin
       TheWall2 := TWall(tmpWalls.Objects[j]);

       TheWall              := TWall.Create;
       TheWall.Adjoin       := TheWall2.Adjoin;
       TheWall.Mirror       := TheWall2.Mirror;
       TheWall.Walk         := TheWall2.Walk;
       TheWall.Light        := TheWall2.Light;
       TheWall.Flag1        := TheWall2.Flag1;
       TheWall.Flag2        := TheWall2.Flag2;
       TheWall.Flag3        := TheWall2.Flag3;
       TheWall.Mid.Name     := TheWall2.Mid.Name;
       TheWall.Mid.f1       := TheWall2.Mid.f1;
       TheWall.Mid.f2       := TheWall2.Mid.f2;
       TheWall.Mid.i        := TheWall2.Mid.i;
       TheWall.Top.Name     := TheWall2.Top.Name;
       TheWall.Top.f1       := TheWall2.Top.f1;
       TheWall.Top.f2       := TheWall2.Top.f2;
       TheWall.Top.i        := TheWall2.Top.i;
       TheWall.Bot.Name     := TheWall2.Bot.Name;
       TheWall.Bot.f1       := TheWall2.Bot.f1;
       TheWall.Bot.f2       := TheWall2.Bot.f2;
       TheWall.Bot.i        := TheWall2.Bot.i;
       TheWall.Sign.Name    := TheWall2.Sign.Name;
       TheWall.Sign.f1      := TheWall2.Sign.f1;
       TheWall.Sign.f2      := TheWall2.Sign.f2;
       TheWall.Sign.i       := TheWall2.Sign.i;

       if vxcycle = -1 then
        begin
         Inc(vertexnum);
         vxcycle         := vertexnum;
         TheVertex       := TVertex.Create;
         TheVertex2      := TVertex(WAD_VERTEXES.Objects[TheWall2.Left_vx]);
         TheVertex.Mark  := 0;
         TheVertex.X     := TheVertex2.X;
         TheVertex.Z     := TheVertex2.Z;
         TheSector.Vx.AddObject('VX', TheVertex);
        end;
       TheWall.Left_vx := vertexnum;
       if TheWall.Sign.i <> 1 then
        begin
         TheVertex        := TVertex.Create;
         TheVertex2       := TVertex(WAD_VERTEXES.Objects[TheWall2.Right_vx]);
         TheVertex.Mark   := 0;
         TheVertex.X      := TheVertex2.X;
         TheVertex.Z      := TheVertex2.Z;
         TheSector.Vx.AddObject('VX', TheVertex);
         Inc(vertexnum);
         TheWall.Right_vx := vertexnum;
        end
       else
        begin
         {don't create a new vertex here, cycle back to vxcycle}
         TheWall.Right_vx     := vxcycle;
         TheWall.Sign.i       := 0;
         vxcycle := -1;
        end;

       TheSector.Wl.AddObject('WL', TheWall);
      end
     else
      begin
       {invalid wall, don't write it}
       {WARNING, if there are NO walls, MUST delete the sector !!!!!}
      end;
    end;

   tmpwalls.Free;
   if sc mod 20 = 19 then
    ProgressWindow.Gauge.Progress := ProgressWindow.Gauge.Progress + 20;
  end;

end;

procedure DO_CorrectSectors;
var sc          : Integer;
    TheSector   : TSector;
    num         : Integer;
    str         : string;
begin
 if MAP_SEC.Count = 0 then exit;
 ProgressWindow.Gauge.MaxValue     := MAP_SEC.Count - 1;
 ProgressWindow.Gauge.Progress     := 0;
 ProgressWindow.Progress2.Caption  := 'Deleting Unreferenced SECTORS...';
 ProgressWindow.Progress2.Update;

 {make a first pass just for the log!}
 for sc := 0 to MAP_SEC.Count - 1 do
  begin
   TheSector := TSector(MAP_SEC.Objects[sc]);
   if (TheSector.Wl.Count = 0) or (TheSector.Vx.Count = 0) then
     WAD_CNVRTLOG.Add('    ' + 'Deleted WAD Sector # ' + IntToStr(sc));
  end;

 num := 0;
 sc  := 0;
 while sc < MAP_SEC.Count do
  begin
   TheSector := TSector(MAP_SEC.Objects[sc]);
   if (TheSector.Wl.Count = 0) or (TheSector.Vx.Count = 0) then
    begin
     Inc(num);
     MAP_SEC.Delete(sc);
     ProgressWindow.Gauge.MaxValue     := MAP_SEC.Count - 1;
    end
   else
    Inc(sc);

   if sc mod 20 = 19 then
   ProgressWindow.Gauge.Progress := ProgressWindow.Gauge.Progress + 20;
  end;

 if num <> 0 then
  begin
   str := Format('Deleted %d unreferenced sectors', [num]);
   WAD_CNVRTLOG.Add('    ' + str);
  end;
end;

procedure DO_ConvertSectorFlags(TheMAP : String);
var sc          : Integer;
    TheSector   : TSector;
    num         : Integer;
    str         : string;
    code,
    mapnum      : Integer;
begin
 if MAP_SEC.Count = 0 then exit;
 ProgressWindow.Gauge.MaxValue     := MAP_SEC.Count - 1;
 ProgressWindow.Gauge.Progress     := 0;
 ProgressWindow.Progress2.Caption  := 'Converting SECTOR types to DF Flags...';
 ProgressWindow.Progress2.Update;

 TheSky := 'SKY1';
 if Copy(TheMAP,1,2) = 'E2' then TheSky := 'SKY2' else
 if Copy(TheMAP,1,2) = 'E3' then TheSky := 'SKY3' else
 if Copy(TheMAP,1,2) = 'E4' then TheSky := 'SKY4' else
 if Copy(TheMAP,1,3) = 'MAP' then
  begin
   Val(Copy(TheMAP,4,2), mapnum, code);
   if code = 0 then
    if mapnum > 20 then TheSky := 'SKY3' else
     if mapnum > 10 then TheSky := 'SKY2';
  end;


 num := 0;
 for sc := 0 to MAP_SEC.Count - 1 do
  begin
   TheSector := TSector(MAP_SEC.Objects[sc]);
   {WAD sector types are stored in Ceili.i}
   CASE TheSector.Ceili.i OF
     0,1,2,3,8,10,12,13,14,17
        : ;{nothing to do here}
           {all damages converted to GAS, to be able to use the gas mask
            to emulate the RADSUIT. Doesn't change things too much anyway! }
     4  : TheSector.Flag1 := 6144;   {10-20%}
     5  : TheSector.Flag1 := 6144;   {5-10%}
     7  : TheSector.Flag1 := 6144;   {2-5%}
     9  : TheSector.Flag1 := 524288; {secret}
     11 : TheSector.Flag1 := 6144;   {10-20%}
     16 : TheSector.Flag1 := 6144;   {10-20%}
     ELSE begin
           Inc(num);
           TheSector.Ceili.i := 0;
          end;
   END;

   {handle skys: both the exterior AND exterior adjoin bits}
   if Copy(TheSector.Ceili.Name, 1, 5) = 'F_SKY' then
    begin
     TheSector.Ceili.Name := TheSky + '.BM';
     TheSector.Flag1 := TheSector.Flag1 + 9;
    end;

   {handle floor skys: both the exterior AND exterior adjoin bits}
   if Copy(TheSector.Floor.Name, 1, 5) = 'F_SKY' then
    begin
     TheSector.Floor.Name := TheSky + '.BM';
     TheSector.Flag1 := TheSector.Flag1 + 384;
     {add this second altitude so the player doesn't fall down,
      as this isn't the Doom behavior. It doesn't work with -0.01
      which would have ensured the player came in from above...
      ...anyway, floor skys are nearly always recessed}
     TheSector.Second_alt := 0.01;
    end;

   if sc mod 20 = 19 then
   ProgressWindow.Gauge.Progress := ProgressWindow.Gauge.Progress + 20;
  end;

 if num <> 0 then
  begin
   Str := Format('Found %d invalid sector types (corrected)', [num]);
   WAD_CNVRTLOG.Add('    ' + str);
  end;

end;

procedure DO_ConvertWallFlags;
var sc, wl      : Integer;
    TheSector   : TSector;
    TheWall     : TWall;
begin
 if MAP_SEC.Count = 0 then exit;
 ProgressWindow.Gauge.MaxValue     := MAP_SEC.Count - 1;
 ProgressWindow.Gauge.Progress     := 0;
 ProgressWindow.Progress2.Caption  := 'Converting LINEDEF Flags to DF Flags...';
 ProgressWindow.Progress2.Update;

 for sc := 0 to MAP_SEC.Count - 1 do
  begin
   TheSector := TSector(MAP_SEC.Objects[sc]);
   for wl := 0 to TheSector.Wl.Count - 1 do
    begin
     TheWall := TWall(TheSector.Wl.Objects[wl]);
     {WAD linedef flags are stored in Flag2}
     if IsBitSet(TheWall.Flag2, 0) then {impassable}
      begin
       Inc(TheWall.Flag3, 2); {cannot walk}
      end;
     if IsBitSet(TheWall.Flag2, 1) then {block monsters}
      begin
       Inc(TheWall.Flag3, 4); {fence}
      end;
     if IsBitSet(TheWall.Flag2, 2) then {two sided}
      begin
       if TheWall.Mid.Name <> '-' then
        Inc(TheWall.Flag1, 1); {adjoining Mid Tx}
      end;
     if IsBitSet(TheWall.Flag2, 3) then {upper tx not pegged}
      begin
      end;
     if not IsBitSet(TheWall.Flag2, 4) then { NOT lower tx not pegged !}
      begin
       {elevators look good this way ! but it is far from being the answer}
        TheWall.Flag1 := TheWall.Flag1 or 16; {wall tx anchored}
      end;
     if IsBitSet(TheWall.Flag2, 5) then {secret}
      begin
       Inc(TheWall.Flag1, 2048); {show as normal on map}
      end;
     if IsBitSet(TheWall.Flag2, 6) then {block sound}
      begin
       {not in DF}
      end;
     if IsBitSet(TheWall.Flag2, 7) then {Never on map}
      begin
       Inc(TheWall.Flag1, 1024); {Hide on map}
      end;
     if IsBitSet(TheWall.Flag2, 8) then {Always on map}
      begin
       {does not exists ?}
      end;
    end;


   if sc mod 20 = 19 then
   ProgressWindow.Gauge.Progress := ProgressWindow.Gauge.Progress + 20;
  end;

end;

procedure DO_AllAdjoins;
var sc          : Integer;
    num         : Integer;
    str         : string;
begin
 if MAP_SEC.Count = 0 then exit;
 ProgressWindow.Gauge.MaxValue     := MAP_SEC.Count - 1;
 ProgressWindow.Gauge.Progress     := 0;
 ProgressWindow.Progress2.Caption  := 'Preparing to Adjoin...';
 ProgressWindow.Progress2.Update;

 for sc := 0 to MAP_SEC.Count -1 do
  begin
   DO_MultiSel_SC(sc);
   if sc mod 50 = 49 then
   ProgressWindow.Gauge.Progress := ProgressWindow.Gauge.Progress + 50;
  end;

 ProgressWindow.Progress2.Caption  := 'Adjoining...';
 ProgressWindow.Progress2.Update;

 DO_Switch_To_WL_Mode;
 if MakeAdjoin(SC_HILITE, WL_HILITE) then
  num := 1
 else
  num := 0;
 num := num + MultiMakeAdjoin;
 DO_Fill_WallEditor;

 if num <> 0 then
  begin
   Str :=  Format('Made %d adjoins', [num]);
   WAD_CNVRTLOG.Add('    ' + str);
  end;

 DO_Switch_To_SC_Mode;
 DO_Clear_MultiSel;
end;

procedure DO_FlagDoors;
var sc, wl      : Integer;
    TheSector   : TSector;
    TheSector2  : TSector;
    TheWall     : TWall;
    tmpAlt      : Real;
begin
 if MAP_SEC.Count = 0 then exit;
 ProgressWindow.Gauge.MaxValue     := MAP_SEC.Count - 1;
 ProgressWindow.Gauge.Progress     := 0;
 ProgressWindow.Progress2.Caption  := 'Converting Local Doors to Flag Doors...';
 ProgressWindow.Progress2.Update;

 for sc := 0 to MAP_SEC.Count - 1 do
  begin
   TheSector := TSector(MAP_SEC.Objects[sc]);
   for wl := 0 to TheSector.Wl.Count - 1 do
    begin
     TheWall := TWall(TheSector.Wl.Objects[wl]);
     {WAD linedef action are stored in Top.i}
     if (TheWall.Bot.i = 1) and (TheWall.Top.i = 1) then {first side and local door}
      begin
       if (TheWall.Adjoin <> -1) then
        begin
         TheSector2 := TSector(MAP_SEC.Objects[TheWall.Adjoin]);
         if (TheSector2.Flag1 and 2) = 0  then
          begin
           TheSector2.Flag1 := TheSector2.Flag1 or 2;
           {set the ceiling altitude correctly, because Doom uses the
            ceiling = floor trick, DF not}
           tmpAlt := GetNearAltitude(TheWall.Adjoin, 'LHC');
           if tmpAlt <> 999999 then
            TheSector2.Ceili_Alt := tmpAlt;
          end;
        end;
      end;
    end;

   if sc mod 20 = 19 then
   ProgressWindow.Gauge.Progress := ProgressWindow.Gauge.Progress + 20;
  end;
end;


procedure DO_CreateDummySector(name : String);
var TheSector        : TSector;
    minX, minY, minZ,
    maxX, maxY, maxZ : Real;
begin
  DO_GetMapLimits(minX, minY, minZ, maxX, maxY, maxZ);
  CreatePolygonSector(4, 4, minX + 4, minZ - 15 , 0);
  TheSector := TSector(MAP_SEC.Objects[MAP_SEC.Count-1]);
  TheSector.Name    := name;
  {set it back to a normal untagged sector in case sector 0 was special}
  TheSector.Floor.i := 0;
  TheSector.Ceili.i := 0;
end;


procedure DO_NameSectors;
var sc, t       : Integer;
    TheSector   : TSector;
    tag         : Integer;
    tags        : array[1..999] of Integer;
begin
 if MAP_SEC.Count = 0 then exit;
 ProgressWindow.Gauge.MaxValue     := MAP_SEC.Count - 1;
 ProgressWindow.Gauge.Progress     := 0;
 ProgressWindow.Progress2.Caption  := 'Naming Tagged Sectors...';
 ProgressWindow.Progress2.Update;

 for t := 1 to 999 do tags[t] := 0;

 for sc := 0 to MAP_SEC.Count - 1 do
  begin
   TheSector := TSector(MAP_SEC.Objects[sc]);
   tag       := TheSector.Floor.i;

   if (tag = 666) or (tag = 667) then
    WAD_CNVRTLOG.Add('    WARNING! Sector #' + Format('%3.3d ', [sc]) +
                     ' has tag ' + Format('%3.3d',[tag]));

   if tag <> 0 then {if it has a tag}
    begin
     if tags[tag] = 0 then
      begin
       TheSector.Name := Format('tag%3.3d', [tag]);
       Inc(tags[tag]);
      end
     else
      begin
       TheSector.Name := Format('tag%3.3d_slave%3.3d', [tag, tags[tag]]);
       Inc(tags[tag]);
      end;
    end;

   if sc mod 20 = 19 then
   ProgressWindow.Gauge.Progress := ProgressWindow.Gauge.Progress + 20;
  end;
end;

{WAD_INF helper functions}
procedure DO_InitWadINF;
begin
 WAD_INF := TStringList.Create;
 WAD_INF_ITEMS := 0;
 WAD_INF_ADDS  := 0;
 WAD_INF_TRGS  := 0;
 WAD_INF_ADJS  := 0;
 WAD_INF_DONS  := 0;

 WAD_INF.Add('INF 1.0');
 WAD_INF.Add('');
 WAD_INF.Add('LEVELNAME SECBASE');
 WAD_INF.Add('');
 WAD_INF.Add('items 1'); {line 4 of WAD_INF is the items value}
 WAD_INF.Add('');
 WI_ITEMSECTOR('complete');
 WI_CLASS('elevator move_floor');
 WI_SPEED('0');
 WI_STOP('1 hold');
 WI_STOP('2 complete');
 WI_SEQEND;
 WI_CR;
end;


procedure WI_CR;
begin
 WAD_INF.Add('');
end;

procedure WI_COMMENT(s : String);
begin
 WAD_INF.Add('/* ' + s + ' */');
end;

procedure WI_ITEMSECTOR(s : String);
begin
 WAD_INF.Add('item: sector name: ' + s);
 WAD_INF.Add(' seq');
 Inc(WAD_INF_ITEMS);
end;

procedure WI_ITEMLINE(s : String; num : Integer);
begin
 WAD_INF.Add('item: line name: ' + s + ' num: ' + IntToStr(num));
 WAD_INF.Add(' seq');
 Inc(WAD_INF_ITEMS);
end;

procedure WI_SEQ;
begin
 {moved in ITEMSECTOR and ITEMLINE}
end;

procedure WI_CLASS(s : String);
begin
 WAD_INF.Add('  class: ' + s);
end;

procedure WI_MASTEROFF;
begin
 WAD_INF.Add('   master: off');
end;

procedure WI_STOP(s : String);
begin
 WAD_INF.Add('   stop: ' + s);
end;

procedure WI_EVENTMASK(s : String);
begin
 WAD_INF.Add('   event_mask: ' + s);
end;

procedure WI_ENTITYMASK(s : String);
begin
 if s <> '' then
  WAD_INF.Add('   entity_mask: ' + s);
end;

procedure WI_MESSAGE(s : String);
begin
  WAD_INF.Add('     message: ' + s);
end;

procedure WI_SPEED(s : String);
begin
 WAD_INF.Add('   speed: ' + s);
end;

procedure WI_OTHER(s : String);
begin
 WAD_INF.Add('   ' + s);
end;

procedure WI_KEY(s : String);
begin
 WAD_INF.Add('   key: ' + s);
end;

procedure WI_CLIENT(s : String);
begin
 WAD_INF.Add('    client: ' + s);
end;

procedure WI_SLAVE(s : String);
begin
 WAD_INF.Add('    slave: ' + s);
end;

procedure WI_SEQEND;
begin
 WAD_INF.Add(' seqend');
end;

procedure DO_WriteWadINF;
begin
 WAD_INF[4] := 'items ' + IntToStr(WAD_INF_ITEMS);
 WAD_INF.SaveToFile(LEVELPath + '\SECBASE.INF');
end;

function GetLineActionData(num : Integer; VAR lda : TLDA_DESC) : Boolean;
var doomdata : TIniFile;
    datastr  : String;
    pars     : TStringParserWithColon;
    tmp      : array[0..127] of char;
    str      : string;
    i        : Integer;
begin
 doomdata := TIniFile.Create(WDFUSEdir + '\WDFDATA\DOOMDATA.WDF');

 datastr  :=doomdata.ReadString('LineDef_Actions', Format('%3.3d', [num]), '***');
 if datastr = '***' then
  begin
   Result := FALSE;
   Str := Format('ERROR!!!! Invalid Linedef action %d',[num]);
   WAD_CNVRTLOG.Add('    ' + str);
   StrPcopy(tmp, str);
   Application.MessageBox(tmp, 'WDFUSE Mapper - WAD Convert',
                             mb_Ok or mb_IconInformation);
  end
 else
  begin
   {split the data in the different parts}
   pars := TStringParserWithColon.Create(datastr);
   if pars.Count < 14 then
    begin
     Result := FALSE;
     Str := Format('ERROR!!!! in DOOMDATA.WDF [Linedef_Actions] item %d',[num]);
     WAD_CNVRTLOG.Add('    ' + str);
     StrPcopy(tmp, str);
     Application.MessageBox(tmp, 'WDFUSE Mapper - WAD Convert',
                             mb_Ok or mb_IconInformation);
    end
   else
    begin
     Result     := TRUE;
     lda.act    := pars[1][1];
     lda.elev   := pars[2];
     lda.master := (pars[3] = '1');
     lda.event  := pars[4][1];
     lda.rep    := pars[5][1];
     lda.trig   := pars[6][1];
     lda.stops  := pars[7];
     lda.first  := pars[8];
     lda.next   := pars[9];
     if pars[10] = '-' then
      lda.speed := -1
     else
      lda.speed := StrToInt(pars[10]);
     lda.speed  := doomdata.ReadInteger('LineDef_Speeds', IntToStr(lda.speed), -1);
     if pars[11] = '-' then
      lda.hold  := -32000
     else
      lda.hold  := StrToInt(pars[11]);
     lda.spec   := pars[12];
     lda.desc   := '';
     for i := 13 to pars.Count - 1 do
      lda.desc   := lda.desc + ' ' + pars[i];
     lda.desc := LTrim(lda.desc);
    end;
   pars.Free;
  end;
 doomdata.Free;
end;

procedure DO_ConvertLinedefActions;
var   sc, wl, i, j  : Integer;
      TheSector     : TSector;
      TheSector2    : TSector;
      TheSectorTag  : TSector;
      TheWall       : TWall;
      lda           : TLDA_DESC;
      TheClass      : string;
      TheTriggerCls : string;
      TheEventMask  : string;
      TheEntityMask : string;
      TheStop1      : String;
      TheStop2      : String;
      TheSectorName : String;
      TheTrSecName  : String;
      TheMessage    : string;
      ConstructElevator : Boolean;
      ConstructTrigger  : Boolean;
      reference     : Integer;
      dummy         : Integer;
      secnum        : Integer;
      tmp1          : string;
      tmpfloor      : Real;
      tmpceili      : Real;
      tmpstop       : Real;
      tmpinc        : Real;
      curstop       : Integer;
      tmp           : array[0..127] of char;
      str           : string;
      mustdone      : Boolean;
      donename      : String;
begin
 if MAP_SEC.Count = 0 then exit;
 ElevMade := TStringList.Create;

 ProgressWindow.Gauge.MaxValue     := MAP_SEC.Count - 1;
 ProgressWindow.Gauge.Progress     := 0;
 ProgressWindow.Progress2.Caption  := 'Converting Linedef Actions...';
 ProgressWindow.Progress2.Update;

 for sc := 0 to MAP_SEC.Count - 1 do
  begin
   TheSector := TSector(MAP_SEC.Objects[sc]);
   for wl := 0 to TheSector.Wl.Count - 1 do
    begin
     TheWall := TWall(TheSector.Wl.Objects[wl]);
     {WAD linedef action are stored in Top.i}
     if (TheWall.Top.i > 0) then {don't include 0 (no action)}
     if TheWall.Bot.i = 1 then {only take first sides}
      if GetLineActionData(TheWall.Top.i, lda) then
       begin
        ConstructElevator := TRUE;
        ConstructTrigger  := TRUE;
        IF lda.Act = 'X' then
         BEGIN
          {special handling handled afterwards !}
         END
        ELSE
         BEGIN
          {what elevator}
          if lda.elev = 'MC' then TheClass     := 'elevator move_ceiling';
          if lda.elev = 'MF' then TheClass     := 'elevator move_floor';
          if lda.elev = 'CL' then TheClass     := 'elevator change_light';
          if lda.elev = '--' then ConstructElevator := FALSE;

          {event_mask and entity_mask}
          case lda.event of
           'W' : begin
                  TheEventMask := '3';
                  TheEntityMask := '';
                 end;
           'S' : begin
                  TheEventMask := '16';
                  TheEntityMask := '';
                 end;
           'G' : begin
                  TheEventMask := '256';
                  TheEntityMask := '8';
                 end;
           'e' : begin
                  TheEventMask := '4';
                  TheEntityMask := '';
                  ConstructTrigger := FALSE; {?}
                 end;
           'n' : begin
                  TheEventMask := '32';
                  TheEntityMask := '';
                  ConstructTrigger := FALSE; {?}
                 end;
          end;

          {!! to the switches !!}
          mustdone := FALSE;
          if lda.rep = 'R' then
           if TheWall.Sign.Name = '' then
            TheTriggerCls := 'trigger standard'
           else
            begin
             TheTriggerCls := 'trigger switch1';
             mustdone      := TRUE;
             if TheSector.Name = '' then {precalculate the trigger name, not cute :-)}
              doneName := Format('trg%3.3d', [WAD_INF_TRGS])
             else
              doneName := TheSector.Name;

             donename := donename + '(' + IntToStr(wl) + ')';
            end
          else
           TheTriggerCls := 'trigger single';

          {on what to act ?}
          Case lda.Act Of
           'T' : begin
                  TheSectorName := Format('tag%3.3d', [TheWall.Mid.i]);
                  secnum        := GetTaggedSector(TheWall.Mid.i);
                  if secnum = -1 then
                   begin
                    Str := Format('ERROR!!!! Invalid TAG sc# %3.3d wl# %2.2d',[sc, wl]);
                    WAD_CNVRTLOG.Add('    ' + str);
                    continue;
                   end;
                 end;
           'A' : begin
                  if TheWall.Adjoin <> -1 then
                   begin
                    secnum      := TheWall.Adjoin;
                    TheSector2  := TSector(MAP_SEC.Objects[secnum]);
                    if TheSector2.Name = '' then
                     begin
                      TheSector2.Name := Format('adj%3.3d', [WAD_INF_ADJS]);
                      TheSectorName := Format('adj%3.3d', [WAD_INF_ADJS]);
                      Inc(WAD_INF_ADJS);
                     end
                    else
                     begin
                      {sector is already named, probably by another linedef,
                       ignore the elevator, but still construct the trigger !}
                      {we have to make an exception: if the (bad?) wad maker
                       did put a tag on a 'A' elevator, the sector will be named !
                       so use ElevMade !!!}
                      TheSectorName := TheSector2.Name;
                      if ElevMade.IndexOf(TheSectorName) <> -1 then
                       ConstructElevator := FALSE;
                     end;
                   end
                  else
                   begin
                    {error, 'A' action on unadjoined wall}
                    Str := Format('ERROR!!!! "A" action on unadjoined wall sc# %3.3d wl# %2.2d',[sc, wl]);
                    WAD_CNVRTLOG.Add('    ' + str);
                    continue;
                   end;
                 end;
           'C' : begin
                  TheSectorName := 'complete';
                  ConstructElevator := FALSE;
                 end;
          End;

          if ConstructElevator then
           {if the elevator doesn't exist yet}
           if ElevMade.IndexOf(TheSectorName) = -1 then
            begin
             WI_CR;
             WI_ITEMSECTOR(TheSectorName);
             ElevMade.Add(TheSectorName);
             WI_CLASS(TheClass);
             if not lda.master then WI_MASTEROFF;
             if not ConstructTrigger then
              WI_EVENTMASK(TheEventMask);
             if lda.Spec = 'R' then WI_KEY('red');
             if lda.Spec = 'B' then WI_KEY('blue');
             if lda.Spec = 'Y' then WI_KEY('yellow');
             if lda.Speed <> -1 then WI_SPEED(IntToStr(lda.Speed));
             {the stops}
             if lda.stops = '2' then
              begin
               {classic 2 stops elevator}
               if lda.first <> 'LIG' then
                {with altitudes}
                begin
                 tmp1 := Format('%5.2f', [GetNearAltitude(secnum, lda.first)]) + ' ';
                 if lda.hold = -32000 then
                  tmp1 := tmp1 + 'hold'
                 else
                  if lda.hold < 0 then
                   tmp1 := tmp1 + IntToStr(abs(lda.hold))
                  else
                   tmp1 := tmp1 + 'hold';
                 WI_STOP(tmp1);
                 if MustDone then
                  WI_MESSAGE('0 ' + donename + ' done');
                 tmp1 := Format('%5.2f', [GetNearAltitude(secnum, lda.next)]) + ' ';
                 if lda.hold = -32000 then
                  tmp1 := tmp1 + 'hold'
                 else
                  tmp1 := tmp1 + IntToStr(abs(lda.hold));
                 WI_STOP(tmp1);
                end
               else
                {with lights}
                begin
                 tmp1 := Format('%d', [GetNearAmbient(secnum, lda.first)]) + ' ';
                 if lda.hold = -32000 then
                  tmp1 := tmp1 + 'hold'
                 else
                  if lda.hold < 0 then
                   tmp1 := tmp1 + IntToStr(abs(lda.hold))
                  else
                   tmp1 := tmp1 + 'hold';
                 WI_STOP(tmp1);
                 if MustDone then
                  WI_MESSAGE('0 ' + donename + ' done');
                 tmp1 := Format('%d', [GetNearAmbient(secnum, lda.next)]) + ' ';
                 if lda.hold = -32000 then
                  tmp1 := tmp1 + 'hold'
                 else
                  tmp1 := tmp1 + IntToStr(abs(lda.hold));
                 WI_STOP(tmp1);
                end;
              end
             else
              begin
               {variable generate more than two stops, all with 'hold'}
               tmp1 := Format('%5.2f', [GetNearAltitude(secnum, lda.first)]) + ' hold';
               WI_STOP(tmp1);
               tmpfloor := GetNearAltitude(secnum, 'FLO');
               tmpceili := GetNearAltitude(secnum, 'CEI');
               tmpinc   := GetNearAltitude(secnum, lda.next);
               tmpstop  := tmpfloor + tmpinc;
               curstop  := 0;
               repeat
                tmp1 := Format('%5.2f', [tmpstop]) + ' hold';
                WI_STOP(tmp1);
                if MustDone then
                  WI_MESSAGE(IntToStr(curstop) + ' ' + donename + ' done');
                tmpstop := tmpstop + tmpinc;
                Inc(curstop);
               until tmpstop > tmpceili;
              end;
             {the slaves}
             if lda.Act = 'T' then {'A' actions cannot have slaves}
              begin
               j := -1;
               for i := 0 to MAP_SEC.Count - 1 do
                begin
                 TheSectorTag := TSector(MAP_SEC.Objects[i]);
                 if (TheSectorTag.Floor.i = TheWall.Mid.i) then
                  begin
                   Inc(j);
                   if j > 0 then
                    WI_SLAVE(Format('tag%3.3d_slave%3.3d', [TheWall.Mid.i, j]));
                  end;
                end;
              end;
             WI_SEQEND;
            end
          else
           begin
            Str := Format('Elevator was already created at sc# %3.3d wl# %2.2d',[sc, wl]);
            WAD_CNVRTLOG.Add('    ' + str);
           end;

          if ConstructTrigger then
           begin
            {if the sector in which the current line is not named, we'll
             have to do it !}
            if TheSector.Name = '' then
             begin
              TheSector.Name := Format('trg%3.3d', [WAD_INF_TRGS]);
              Inc(WAD_INF_TRGS);
             end;
            WI_CR;
            WI_ITEMLINE(TheSector.Name, wl);
            WI_CLASS(TheTriggerCls);
            WI_EVENTMASK(TheEventMask);
            WI_ENTITYMASK(TheEntityMask);
            WI_CLIENT(TheSectorName);
            {which message do we send ?}
            case lda.trig of
             'Z' : WI_MESSAGE('goto_stop 0');
             'O' : WI_MESSAGE('goto_stop 1');
             'N' : WI_MESSAGE('next_stop');
             '0' : WI_MESSAGE('master_off');
             '1' : WI_MESSAGE('master_on');
            end;
            WI_SEQEND;
           end;

           {is there a special handling ?
            i.e. the 'C' set crush bit
                 and 'S' set smart object reaction bit}
          TheSector2  := TSector(MAP_SEC.Objects[secnum]);
          if lda.spec = 'C' then
           TheSector2.Flag1 := TheSector2.Flag1 or 512;
          if lda.spec = 'S' then
           TheSector2.Flag1 := TheSector2.Flag1 or 16384;
         END;
       end;
    end;


   if sc mod 20 = 19 then
   ProgressWindow.Gauge.Progress := ProgressWindow.Gauge.Progress + 20;
  end;
end;

procedure DO_ConvertLinedefSpecialActions;
var   sc, wl        : Integer;
      TheSector     : TSector;
      TheWall       : TWall;
      lda           : TLDA_DESC;
      str           : string;
begin
 if MAP_SEC.Count = 0 then exit;
 ProgressWindow.Gauge.MaxValue     := MAP_SEC.Count - 1;
 ProgressWindow.Gauge.Progress     := 0;
 ProgressWindow.Progress2.Caption  := 'Converting Linedef Special Actions...';
 ProgressWindow.Progress2.Update;

 for sc := 0 to MAP_SEC.Count - 1 do
  begin
   TheSector := TSector(MAP_SEC.Objects[sc]);
   for wl := 0 to TheSector.Wl.Count - 1 do
    begin
     TheWall := TWall(TheSector.Wl.Objects[wl]);
     {WAD linedef action are stored in Top.i}
     if (TheWall.Top.i > 0) then {don't include 0 (no action)}
     if TheWall.Bot.i = 1 then {only take first sides}
      if GetLineActionData(TheWall.Top.i, lda) then
       begin
        IF lda.Act = 'X' then
         BEGIN
          {special handling here for :
           048=X -- -    - - -    - --- ---   - -    -    scrolling wall (left)
           008=X -- -    W 1 1    2 --- ---   1 -    -    stairs (8)
           007=X -- -    S 1 1    2 --- ---   1 -    -    stairs (8)
           100=X -- -    W 1 1    2 --- ---   4 -    C    stairs (16) + crush
           127=X -- -    S 1 1    2 --- ---   4 -    C    stairs (16) + crush
           039=X -- -    W 1 -    - --- ---   - -    S    teleport
           097=X -- -    W R -    - --- ---   - -    S    teleport
           125=X -- -    W 1 -    - --- ---   - -    S    teleport monsters only
           126=X -- -    W R -    - --- ---   - -    S    teleport monsters only
           }
          case TheWall.Top.i of
            48: begin
                 {allow all textures to scroll, whatever the rest
                  if more than one wall scrolls, everything will be ok this way}
                 TheWall.Flag1 := TheWall.Flag1 or 348;
                 {if this room is already an elevator, warn the user and don't
                  create the scrolling wall. He'll have to do a multiclass manually}
                 if ElevMade.IndexOf(TheSector.Name) <> -1 then
                  begin
                   Str := Format('Scrolling wall sc# %3.3d wl# %2.2d is already an elevator. Not created!',[sc, wl]);
                   WAD_CNVRTLOG.Add('    ' + str);
                  end
                 else
                  begin
                   {if the sector hasn't got a name, set it!}
                   if TheSector.Name = '' then
                    begin
                     TheSector.Name := Format('swl%3.3d', [WAD_INF_ADDS]);
                     Inc(WAD_INF_ADDS);
                    end;
                   WI_ITEMSECTOR(TheSector.Name);
                   ElevMade.Add(TheSector.Name);
                   WI_CLASS('elevator scroll_wall');
                   WI_OTHER('angle: 90');
                   WI_SPEED('20');
                   WI_SEQEND;
                  end;
                end;
             39, 97, 125, 126:
                begin
                 Str := Format('WARNING! Wall sc# %3.3d wl# %2.2d is a teleporter',[sc, wl]);
                 WAD_CNVRTLOG.Add('    ' + str);
                end;
             7, 8, 100, 127:
                begin
                 Str := Format('WARNING! Wall sc# %3.3d wl# %2.2d starts rising stairs',[sc, wl]);
                 WAD_CNVRTLOG.Add('    ' + str);
                end;
            else ;{case}
          end; {case}
         END;
       end;
    end;


   if sc mod 20 = 19 then
   ProgressWindow.Gauge.Progress := ProgressWindow.Gauge.Progress + 20;
  end;
 ElevMade.Free;
end;

procedure DO_Texturing;
var sc, wl      : Integer;
    TheSector   : TSector;
    TheSector2  : TSector;
    TheWall     : TWall;
    offset      : Real;
    offset2     : Real;
begin
 if MAP_SEC.Count = 0 then exit;
 ProgressWindow.Gauge.MaxValue     := MAP_SEC.Count - 1;
 ProgressWindow.Gauge.Progress     := 0;
 ProgressWindow.Progress2.Caption  := 'Converting Texturing...';
 ProgressWindow.Progress2.Update;

 for sc := 0 to MAP_SEC.Count - 1 do
  begin
   TheSector := TSector(MAP_SEC.Objects[sc]);
   for wl := 0 to TheSector.Wl.Count - 1 do
    begin
     TheWall := TWall(TheSector.Wl.Objects[wl]);
     {WAD linedef flags are stored in Flag2}
     if TheWall.Adjoin <> -1 then {two sided}
      begin
       TheSector2 := TSector(MAP_SEC.Objects[TheWall.Adjoin]);
       if IsBitSet(TheWall.Flag2, 4) then  {lower not pegged}
        begin
          TheWall.Mid.f2 := -TheWall.Mid.f2;
          TheWall.Bot.f2 := -TheWall.Bot.f2;
        end
       else
        begin
         offset := TheSector.Ceili_alt - TheSector.Floor_alt;
         offset2 := TheSector2.Floor_alt - TheSector.Floor_alt;
         TheWall.Mid.f2 := -TheWall.Mid.f2 - offset;
         TheWall.Bot.f2 := -TheWall.Bot.f2 - offset2;
        end;
       if IsBitSet(TheWall.Flag2, 3) then {upper not pegged}
        begin
         offset2 := TheSector.Ceili_alt - TheSector2.Ceili_alt;
         TheWall.Top.f2 := -TheWall.Top.f2 -offset2;
        end
       else
        begin
         TheWall.Top.f2 := -TheWall.Top.f2; {normal upper same as DF}
        end;
      end
     else
      begin
       {The line is 1S, so there can only be a Mid Tx}
       if IsBitSet(TheWall.Flag2, 4) then
        begin
         {as lower tx is not pegged, texturing goes from bottom to top
          which is identical to DF => nothing to do, but still reverse
          the sign of the offset, because DF y axis goes down
          It still isn't good, because Doom handles this case very
          very strangely...}
          TheWall.Mid.f2 := -TheWall.Mid.f2;
        end
       else
        begin
         {the offsets are computed for a texture going top to bottom here
          we have to reverse that!
          So compute the offset that will put the top of the texture
          at the top of the wall. Or said in another way, we could also put
          the top of the 'next' texture at the top of the wall, or yet again
          the bottom of the texture ! => simply add the height of the sector
          don't forget DF y axis goes down}
         offset := TheSector.Ceili_alt - TheSector.Floor_alt;
         TheWall.Mid.f2 := -TheWall.Mid.f2 - offset;
        end;
      end;
     (*if IsBitSet(TheWall.Flag2, 3) then {upper tx not pegged}*)
     (*if IsBitSet(TheWall.Flag2, 4) then {lower tx not pegged} *)
    end;


   if sc mod 20 = 19 then
   ProgressWindow.Gauge.Progress := ProgressWindow.Gauge.Progress + 20;
  end;

end;

   {
   01=Blink (random)
   02=Blink (1/2 second)
   03=Blink (1 second)
   04=-10/20% health, blink (1/2 second)
   05=-5/10% health
   06=Invalid Sector Type
   07=-2/5% health
   08=Light oscillates
   09=Secret
   10=Ceiling drops (after 30 seconds)
   11=-10/20% health, end level/game
   12=Blink (1/2 second sync.)
   13=Blink (1 second sync.)
   14=Ceiling rises (after 300 seconds)
   15=Invalid Sector Type
   16=-10/20% health
   17=Flicker on and off (1.666+)
   }

procedure DO_CreateTrueSectorLights;
var TheSector        : TSector;
    sc, num          : Integer;
    minl, maxl       : Integer;
begin
  if MAP_SEC.Count = 0 then exit;
  ProgressWindow.Gauge.MaxValue     := 5 * (MAP_SEC.Count - 1);
  ProgressWindow.Gauge.Progress     := 0;
  ProgressWindow.Progress2.Caption  := 'Converting True Sector Lights...';
  ProgressWindow.Progress2.Update;

{begin random blink}
  num := 0;
  for sc := 0 to MAP_SEC.Count - 1 do
   begin
    TheSector := TSector(MAP_SEC.Objects[sc]);
    if (TheSector.Ceili.i = 1) then
     begin
      if TheSector.Name = '' then
       begin
        TheSector.Name := Format('li_random_%3.3d', [num]);
        maxl := TheSector.Ambient;
        minl := GetNearAmbient(sc, 'DIM');
        WI_CR;
        WI_ITEMSECTOR(TheSector.Name);
        WI_CLASS('elevator change_light');
        WI_SPEED('0');
        WI_STOP(IntToStr(maxl) + ' 1.1');
        WI_STOP(IntToStr(minl) + ' 0.3');
        WI_STOP(IntToStr(maxl) + ' 1.1');
        WI_STOP(IntToStr(minl) + ' 0.2');
        WI_STOP(IntToStr(maxl) + ' 0.1');
        WI_STOP(IntToStr(minl) + ' 0.7');
        WI_STOP(IntToStr(maxl) + ' 1.1');
        WI_STOP(IntToStr(minl) + ' 0.3');
        WI_STOP(IntToStr(maxl) + ' 0.1');
        WI_STOP(IntToStr(minl) + ' 0.1');
        WI_STOP(IntToStr(maxl) + ' 0.7');
        WI_STOP(IntToStr(minl) + ' 0.1');
        WI_STOP(IntToStr(maxl) + ' 0.1');
        WI_STOP(IntToStr(minl) + ' 0.3');
        WI_STOP(IntToStr(maxl) + ' 1.2');
        WI_STOP(IntToStr(minl) + ' 0.3');
        WI_SEQEND;
        {we'll have to change that back afterwards}
        TheSector.Ceili.i := -TheSector.Ceili.i;
        Inc(num);
       end;
     end;

    if sc mod 50 = 49 then
     ProgressWindow.Gauge.Progress := ProgressWindow.Gauge.Progress + 50;
   end;
  if num <> 0 then
   WAD_CNVRTLOG.Add(Format('    ' + 'Made %d li_random elevator(s)', [num]));
{end random blink}

{begin blink 0.5}
  num := 0;
  for sc := 0 to MAP_SEC.Count - 1 do
   begin
    TheSector := TSector(MAP_SEC.Objects[sc]);
    if (TheSector.Ceili.i = 2) or (TheSector.Ceili.i = 4) or (TheSector.Ceili.i = 12) then
     begin
      if TheSector.Name = '' then
       begin
        TheSector.Name := Format('li_blk0.5_%3.3d', [num]);
        maxl := TheSector.Ambient;
        minl := GetNearAmbient(sc, 'DIM');
        WI_CR;
        WI_ITEMSECTOR(TheSector.Name);
        WI_CLASS('elevator change_light');
        WI_SPEED('0');
        WI_STOP(IntToStr(maxl) + ' 0.1');
        WI_STOP(IntToStr(minl) + ' 0.4');
        WI_SEQEND;
        {we'll have to change that back afterwards}
        TheSector.Ceili.i := -TheSector.Ceili.i;
        Inc(num);
       end;
     end;

    if sc mod 50 = 49 then
     ProgressWindow.Gauge.Progress := ProgressWindow.Gauge.Progress + 50;
   end;
  if num <> 0 then
   WAD_CNVRTLOG.Add(Format('    ' + 'Made %d li_blk0.5_ elevator(s)', [num]));
{end blink 0.5}

{begin blink 1.0}
  num := 0;
  for sc := 0 to MAP_SEC.Count - 1 do
   begin
    TheSector := TSector(MAP_SEC.Objects[sc]);
    if (TheSector.Ceili.i = 3) or (TheSector.Ceili.i = 13) then
     begin
      if TheSector.Name = '' then
       begin
        TheSector.Name := Format('li_blk1.0_%3.3d', [num]);
        maxl := TheSector.Ambient;
        minl := GetNearAmbient(sc, 'DIM');
        WI_CR;
        WI_ITEMSECTOR(TheSector.Name);
        WI_CLASS('elevator change_light');
        WI_SPEED('0');
        WI_STOP(IntToStr(maxl) + ' 0.1');
        WI_STOP(IntToStr(minl) + ' 0.9');
        WI_SEQEND;
        {we'll have to change that back afterwards}
        TheSector.Ceili.i := -TheSector.Ceili.i;
        Inc(num);
       end;
     end;

    if sc mod 50 = 49 then
     ProgressWindow.Gauge.Progress := ProgressWindow.Gauge.Progress + 50;
   end;
  if num <> 0 then
   WAD_CNVRTLOG.Add(Format('    ' + 'Made %d li_blk1.0_ elevator(s)', [num]));
{end blink 1.0}

{begin flicker}
  num := 0;
  for sc := 0 to MAP_SEC.Count - 1 do
   begin
    TheSector := TSector(MAP_SEC.Objects[sc]);
    if (TheSector.Ceili.i = 17) then
     begin
      if TheSector.Name = '' then
       begin
        TheSector.Name := Format('li_flicker_%3.3d', [num]);
        maxl := TheSector.Ambient;
        minl := GetNearAmbient(sc, 'DIM');
        WI_CR;
        WI_ITEMSECTOR(TheSector.Name);
        WI_CLASS('elevator change_light');
        WI_SPEED('0');
        WI_STOP(IntToStr(maxl) + ' 0.95');
        WI_STOP(IntToStr(minl) + ' 0.05');
        WI_STOP(IntToStr(maxl) + ' 0.03');
        WI_STOP(IntToStr(minl) + ' 0.02');
        WI_STOP(IntToStr(maxl) + ' 0.01');
        WI_STOP(IntToStr(minl) + ' 0.05');
        WI_SEQEND;
        {we'll have to change that back afterwards}
        TheSector.Ceili.i := -TheSector.Ceili.i;
        Inc(num);
       end;
     end;

    if sc mod 50 = 49 then
     ProgressWindow.Gauge.Progress := ProgressWindow.Gauge.Progress + 50;
   end;
  if num <> 0 then
   WAD_CNVRTLOG.Add(Format('    ' + 'Made %d li_flicker_ elevator(s)', [num]));
{end flicker}

{begin oscillate}
  num := 0;
  for sc := 0 to MAP_SEC.Count - 1 do
   begin
    TheSector := TSector(MAP_SEC.Objects[sc]);
    if (TheSector.Ceili.i = 8) then
     begin
      if TheSector.Name = '' then
       begin
        TheSector.Name := Format('li_oscill_%3.3d', [num]);
        maxl := TheSector.Ambient;
        minl := GetNearAmbient(sc, 'DIM');
        WI_CR;
        WI_ITEMSECTOR(TheSector.Name);
        WI_CLASS('elevator change_light');
        WI_SPEED('80');
        WI_STOP(IntToStr(maxl) + ' 0.05');
        WI_STOP(IntToStr(minl) + ' 0.05');
        WI_SEQEND;
        {we'll have to change that back afterwards}
        TheSector.Ceili.i := -TheSector.Ceili.i;
        Inc(num);
       end;
     end;

    if sc mod 50 = 49 then
     ProgressWindow.Gauge.Progress := ProgressWindow.Gauge.Progress + 50;
   end;
  if num <> 0 then
   WAD_CNVRTLOG.Add(Format('    ' + 'Made %d li_oscill_ elevator(s)', [num]));
{end oscillate}
end;


procedure DO_CreateSectorLights;
var TheSector        : TSector;
    minX, minY, minZ,
    maxX, maxY, maxZ : Real;
    i, sc, num       : Integer;
begin
  if MAP_SEC.Count = 0 then exit;
  ProgressWindow.Gauge.MaxValue     := 5 * (MAP_SEC.Count - 1);
  ProgressWindow.Gauge.Progress     := 0;
  ProgressWindow.Progress2.Caption  := 'Approximating Other Sector Lights...';
  ProgressWindow.Progress2.Update;

  {create the 5 needed "master" sectors in a row, below the complete elevator}
  DO_GetMapLimits(minX, minY, minZ, maxX, maxY, maxZ);
  for i := 0 to 4 do
   begin
    CreatePolygonSector(4, 4, minX + 15 * i + 4, minZ - 15 , 0);
    TheSector := TSector(MAP_SEC.Objects[MAP_SEC.Count-1]);
    Case i of
     0: TheSector.Name    := 'light_random';
     1: TheSector.Name    := 'light_blk0.5';
     2: TheSector.Name    := 'light_blk1.0';
     3: TheSector.Name    := 'light_flickr';
     4: TheSector.Name    := 'light_oscill';
    end;
    {set it back to a normal untagged sector in case sector 0 was special}
    TheSector.Floor.i := 0;
    TheSector.Ceili.i := 0;
   end;
  {they are now numbered MAP_SEC.Count-5 to MAP_SEC.Count-1}

{begin random blink}
  WI_CR;
  WI_COMMENT('Handles the blink random special sector type');
  WI_ITEMSECTOR('light_random');
  WI_CLASS('elevator change_light');
  WI_SPEED('0');
  WI_STOP('20 0.3');
  WI_STOP('31 1.1');
  WI_STOP('20 0.2');
  WI_STOP('31 0.1');
  WI_STOP('20 0.7');
  WI_STOP('31 1.1');
  WI_STOP('20 0.3');
  WI_STOP('31 0.1');
  WI_STOP('20 0.1');
  WI_STOP('31 0.7');
  WI_STOP('20 0.1');
  WI_STOP('31 0.1');
  WI_STOP('20 0.3');
  WI_STOP('31 1.2');
  WI_STOP('20 0.3');
  WI_STOP('31 1.2');

  num := 0;
  for sc := 0 to MAP_SEC.Count - 6 do
   begin
    TheSector := TSector(MAP_SEC.Objects[sc]);

    if (TheSector.Ceili.i = 1) then
     begin
      {if it hasn't got a name, create it}
      if TheSector.Name = '' then
       begin
        TheSector.Name := Format('slave_random_%3.3d', [num]);
       end;
      WI_SLAVE(TheSector.Name);
      Inc(num);
     end;

    if sc mod 50 = 49 then
     ProgressWindow.Gauge.Progress := ProgressWindow.Gauge.Progress + 50;
   end;
  if num <> 0 then
   WAD_CNVRTLOG.Add(Format('    ' + 'Made %d light_random slave(s)', [num]));
  WI_SEQEND;
{end random blink}

{begin blink 0.5}
  WI_CR;
  WI_COMMENT('Handles the blink 0.5 special sector type');
  WI_ITEMSECTOR('light_blk0.5');
  WI_CLASS('elevator change_light');
  WI_SPEED('0');
  WI_STOP('20 0.4');
  WI_STOP('31 0.1');

  num := 0;

  for sc := 0 to MAP_SEC.Count - 6 do
   begin
    TheSector := TSector(MAP_SEC.Objects[sc]);

    if (TheSector.Ceili.i = 2) or (TheSector.Ceili.i = 4) or (TheSector.Ceili.i = 12) then
     begin
      {if it hasn't got a name, create it}
      if TheSector.Name = '' then
       begin
        TheSector.Name := Format('slave_blk0.5_%3.3d', [num]);
       end;
      WI_SLAVE(TheSector.Name);
      Inc(num);
     end;

    if sc mod 20 = 19 then
     ProgressWindow.Gauge.Progress := ProgressWindow.Gauge.Progress + 20;
   end;
  if num <> 0 then
   WAD_CNVRTLOG.Add(Format('    ' + 'Made %d light_blk0.5 slave(s)', [num]));
  WI_SEQEND;
{end blink 0.5}

{begin blink 1.0}
  WI_CR;
  WI_COMMENT('Handles the blink 1.0 special sector type');
  WI_ITEMSECTOR('light_blk1.0');
  WI_CLASS('elevator change_light');
  WI_SPEED('0');
  WI_STOP('20 0.9');
  WI_STOP('31 0.1');

  num := 0;

  for sc := 0 to MAP_SEC.Count - 6 do
   begin
    TheSector := TSector(MAP_SEC.Objects[sc]);

    if (TheSector.Ceili.i = 3) or (TheSector.Ceili.i = 13) then
     begin
      {if it hasn't got a name, create it}
      if TheSector.Name = '' then
       begin
        TheSector.Name := Format('slave_blk1.0_%3.3d', [num]);
       end;
      WI_SLAVE(TheSector.Name);
      Inc(num);
     end;

    if sc mod 20 = 19 then
     ProgressWindow.Gauge.Progress := ProgressWindow.Gauge.Progress + 20;
   end;
  if num <> 0 then
   WAD_CNVRTLOG.Add(Format('    ' + 'Made %d light_blk1.0 slave(s)', [num]));
  WI_SEQEND;
{end blink 1.0}

{begin flicker}
  WI_CR;
  WI_COMMENT('Handles the flicker sector type');
  WI_ITEMSECTOR('light_flickr');
  WI_CLASS('elevator change_light');
  WI_SPEED('0');
  WI_STOP('20 0.1');
  WI_STOP('31 0.1');
  WI_STOP('20 0.1');
  WI_STOP('31 0.1');
  WI_STOP('20 0.1');
  WI_STOP('31 0.1');

  num := 0;

  for sc := 0 to MAP_SEC.Count - 6 do
   begin
    TheSector := TSector(MAP_SEC.Objects[sc]);

    if (TheSector.Ceili.i = 17) then
     begin
      {if it hasn't got a name, create it}
      if TheSector.Name = '' then
       begin
        TheSector.Name := Format('slave_flickr_%3.3d', [num]);
       end;
      WI_SLAVE(TheSector.Name);
      Inc(num);
     end;

    if sc mod 20 = 19 then
     ProgressWindow.Gauge.Progress := ProgressWindow.Gauge.Progress + 20;
   end;
  if num <> 0 then
   WAD_CNVRTLOG.Add(Format('    ' + 'Made %d light_flickr slave(s)', [num]));
  WI_SEQEND;
{end flicker}

{begin oscillate}
  WI_CR;
  WI_COMMENT('Handles the oscillate sector type');
  WI_ITEMSECTOR('light_oscill');
  WI_CLASS('elevator change_light');
  WI_SPEED('90');
  WI_STOP('20 0');
  WI_STOP('31 0');

  num := 0;

  for sc := 0 to MAP_SEC.Count - 6 do
   begin
    TheSector := TSector(MAP_SEC.Objects[sc]);

    if (TheSector.Ceili.i = 8) then
     begin
      {if it hasn't got a name, create it}
      if TheSector.Name = '' then
       begin
        TheSector.Name := Format('slave_oscill_%3.3d', [num]);
       end;
      WI_SLAVE(TheSector.Name);
      Inc(num);
     end;

    if sc mod 20 = 19 then
     ProgressWindow.Gauge.Progress := ProgressWindow.Gauge.Progress + 20;
   end;
  if num <> 0 then
   WAD_CNVRTLOG.Add(Format('    ' + 'Made %d light_oscill slave(s)', [num]));
  WI_SEQEND;
{end oscillate}

{restore the sector types we changed in TRUE lights}
for sc := 0 to MAP_SEC.Count - 6 do
 begin
  TheSector := TSector(MAP_SEC.Objects[sc]);
  if TheSector.Ceili.i < 0 then TheSector.Ceili.i := - TheSector.Ceili.i;
 end;

end;

{
10=Ceiling drops (after 30 seconds)
14=Ceiling rises (after 300 seconds)
}

procedure DO_Create_30_300_Specials;
var TheSector        : TSector;
    sc, num          : Integer;
    Str              : String;
begin
  if MAP_SEC.Count = 0 then exit;
  ProgressWindow.Gauge.MaxValue     := 2 * (MAP_SEC.Count - 1);
  ProgressWindow.Gauge.Progress     := 0;
  ProgressWindow.Progress2.Caption  := 'Converting Close 30s and Open 300s...';
  ProgressWindow.Progress2.Update;

{begin close after 30 sec}
  num := 0;
  for sc := 0 to MAP_SEC.Count - 1 do
   begin
    TheSector := TSector(MAP_SEC.Objects[sc]);
    if (TheSector.Ceili.i = 10) then
     begin
      if TheSector.Name = '' then
       begin
        TheSector.Name := Format('close_30sec_%3.3d', [num]);
        WI_CR;
        WI_ITEMSECTOR(TheSector.Name);
        WI_CLASS('elevator move_ceiling');
        WI_SPEED('30');
        WI_STOP(Format('%5.2f 30',[TheSector.Ceili_Alt]));
        WI_STOP(Format('%5.2f terminate',[TheSector.Floor_Alt]));
        WI_SEQEND;
        Inc(num);
       end
      else
       begin
        Str := Format('Close 30 sec : elevator already exists at sc# %3.3d',[sc]);
        WAD_CNVRTLOG.Add('    ' + str);
       end;
     end;

    if sc mod 50 = 49 then
     ProgressWindow.Gauge.Progress := ProgressWindow.Gauge.Progress + 50;
   end;
  if num <> 0 then
   WAD_CNVRTLOG.Add(Format('    ' + 'Made %d close_30sec_ elevator(s)', [num]));
{end close after 30 sec}

{begin open after 300 sec}
  num := 0;
  for sc := 0 to MAP_SEC.Count - 1 do
   begin
    TheSector := TSector(MAP_SEC.Objects[sc]);
    if (TheSector.Ceili.i = 14) then
     begin
      if TheSector.Name = '' then
       begin
        TheSector.Name := Format('open_300sec_%3.3d', [num]);
        WI_CR;
        WI_ITEMSECTOR(TheSector.Name);
        WI_CLASS('elevator move_ceiling');
        WI_SPEED('30');
        WI_STOP(Format('%5.2f 300',[TheSector.Floor_Alt]));
        WI_STOP(Format('%5.2f terminate',[GetNearAltitude(sc,'LHC')]));
        WI_SEQEND;
        Inc(num);
       end
      else
       begin
        Str := Format('Open 300 sec : elevator already exists at sc# %3.3d',[sc]);
        WAD_CNVRTLOG.Add('    ' + str);
       end;
     end;

    if sc mod 50 = 49 then
     ProgressWindow.Gauge.Progress := ProgressWindow.Gauge.Progress + 50;
   end;
  if num <> 0 then
   WAD_CNVRTLOG.Add(Format('    ' + 'Made %d open_300sec_ elevator(s)', [num]));
{end open after 300 sec}

end;

{
NUKAGE1     NUKAGE3      All    3
FWATER1     FWATER4       r     4
LAVA1       LAVA4         r     4
BLOOD1      BLOOD3        r     3

RROCK05     RROCK08       2     4
SLIME01     SLIME04       2     4
SLIME05     SLIME08       2     4
SLIME09     SLIME12       2     4

all must also have a second altitude when on the floor, except RROCK05
}

procedure DO_CreateSectorFloorAnims;
var TheSector        : TSector;
    minX, minY, minZ,
    maxX, maxY, maxZ : Real;
    i, sc, num       : Integer;
begin
  if MAP_SEC.Count = 0 then exit;
  ProgressWindow.Gauge.MaxValue     := MAP_SEC.Count - 1;
  ProgressWindow.Gauge.Progress     := 0;
  ProgressWindow.Progress2.Caption  := 'Creating Sector Floor Animations...';
  ProgressWindow.Progress2.Update;

  {create the 2 needed "master" sectors in a row, below the light elevators}
  {note that it also creates the one for ceilings}
  DO_GetMapLimits(minX, minY, minZ, maxX, maxY, maxZ);
  for i := 0 to 1 do
   begin
    CreatePolygonSector(4, 4, minX + 15 * i + 4, minZ - 15 , 0);
    TheSector := TSector(MAP_SEC.Objects[MAP_SEC.Count-1]);
    Case i of
     0: TheSector.Name    := 'anim_floor';
     1: TheSector.Name    := 'anim_ceili';
    end;
    {set it back to a normal untagged sector in case sector 0 was special}
    TheSector.Floor.i := 0;
    TheSector.Ceili.i := 0;
   end;
  {they are now numbered MAP_SEC.Count-2 to MAP_SEC.Count-1}

  WI_CR;
  WI_COMMENT('Handles the floor animated flats (not perfect...)');
  WI_ITEMSECTOR('anim_floor');
  WI_CLASS('elevator scroll_floor');
  WI_SPEED('0');
  WI_OTHER('angle: 90');
  WI_STOP('0 0.7');
  WI_STOP('2 0.7');
  WI_STOP('1.7 0.5');
  WI_STOP('2 0.7');

  num := 0;

  for sc := 0 to MAP_SEC.Count - 3 do
   begin
    TheSector := TSector(MAP_SEC.Objects[sc]);

    if (TheSector.Floor.name = 'NUKAGE1.BM') or
       (TheSector.Floor.name = 'FWATER1.BM') or
       (TheSector.Floor.name = 'LAVA1.BM') or
       (TheSector.Floor.name = 'BLOOD1.BM') or
       (TheSector.Floor.name = 'SLIME01.BM') or
       (TheSector.Floor.name = 'SLIME05.BM') or
       (TheSector.Floor.name = 'SLIME09.BM') or
       (TheSector.Floor.name = 'RROCK05.BM') then
     begin
      {if it hasn't got a name, create it}
      if TheSector.Name = '' then
       begin
        TheSector.Name := Format('slave_floor_%3.3d', [num]);
       end;
      WI_SLAVE(TheSector.Name);
      Inc(num);
      {if it is not RROCK05 give it a second altitude to make it watery}
      if (TheSector.Floor.name <> 'RROCK05.BM') then
       TheSector.Second_alt := -2;
     end;

    if sc mod 50 = 49 then
     ProgressWindow.Gauge.Progress := ProgressWindow.Gauge.Progress + 50;
   end;
  if num <> 0 then
   WAD_CNVRTLOG.Add(Format('    ' + 'Made %d anim_floor slave(s)', [num]));
  WI_SEQEND;
end;

procedure DO_CreateSectorCeilingAnims;
var TheSector        : TSector;
    i, sc, num       : Integer;
begin
  if MAP_SEC.Count = 0 then exit;
  ProgressWindow.Gauge.MaxValue     := MAP_SEC.Count - 1;
  ProgressWindow.Gauge.Progress     := 0;
  ProgressWindow.Progress2.Caption  := 'Creating Sector Ceiling Animations...';
  ProgressWindow.Progress2.Update;

  {...they are now numbered MAP_SEC.Count-2 to MAP_SEC.Count-1}

  WI_CR;
  WI_COMMENT('Handles the ceiling animated flats (not perfect...)');
  WI_ITEMSECTOR('anim_ceili');
  WI_CLASS('elevator scroll_ceiling');
  WI_SPEED('0');
  WI_OTHER('angle: 90');
  WI_STOP('0 0.7');
  WI_STOP('2 0.7');
  WI_STOP('1.7 0.5');
  WI_STOP('2 0.7');

  num := 0;

  for sc := 0 to MAP_SEC.Count - 3 do
   begin
    TheSector := TSector(MAP_SEC.Objects[sc]);

    if (TheSector.Ceili.name = 'NUKAGE1.BM') or
       (TheSector.Ceili.name = 'FWATER1.BM') or
       (TheSector.Ceili.name = 'LAVA1.BM') or
       (TheSector.Ceili.name = 'BLOOD1.BM') or
       (TheSector.Ceili.name = 'SLIME01.BM') or
       (TheSector.Ceili.name = 'SLIME05.BM') or
       (TheSector.Ceili.name = 'SLIME09.BM') or
       (TheSector.Ceili.name = 'RROCK05.BM') then
     begin
      {if it hasn't got a name, create it}
      if TheSector.Name = '' then
       begin
        TheSector.Name := Format('slave_ceili_%3.3d', [num]);
       end;
      WI_SLAVE(TheSector.Name);
      Inc(num);
     end;

    if sc mod 50 = 49 then
     ProgressWindow.Gauge.Progress := ProgressWindow.Gauge.Progress + 50;
   end;
  if num <> 0 then
   WAD_CNVRTLOG.Add(Format('    ' + 'Made %d anim_ceili slave(s)', [num]));
  WI_SEQEND;
end;

procedure DO_RecreateDiscarded;
var ld, sc, nsc, i, j : Integer;
    WADLinedef        : TWAD_Linedef;
    WADSidedef        : TWAD_Sidedef;
    TheSector         : TSector;
    TheWall           : TWall;
    NewSector         : TSector;
    vxld1, vxld2      : TVertex;
    vx0, vx1, vx2     : TVertex;
    vxa, vxb, vxc     : TVertex;
    vcount            : Integer;
begin
  if DiscardedLD.Count = 0 then exit;
  ProgressWindow.Gauge.MaxValue     := DiscardedLD.Count - 1;
  ProgressWindow.Gauge.Progress     := 0;
  ProgressWindow.Progress2.Caption  := 'Creating thin sectors for discarded linedefs...';
  ProgressWindow.Progress2.Update;

 for i := 0 to DiscardedLD.Count - 1 do
  begin
   sc := StrToInt(Copy(DiscardedLD[i],5,4));
   ld := StrToInt(Copy(DiscardedLD[i],1,4));

   {first create a new sector, identical to the surrounding sector}
   TheSector            := TSector(MAP_SEC.Objects[sc]);
   NewSector            := TSector.Create;

   NewSector.Mark       := 0;
   {yes or no ? this would possibly make a slave...}
   NewSector.Name       := TheSector.Name;
   NewSector.Ambient    := TheSector.Ambient;
   NewSector.Flag1      := TheSector.Flag1;
   NewSector.Flag2      := TheSector.Flag2;
   NewSector.Flag3      := TheSector.Flag3;
   NewSector.Floor_Alt  := TheSector.Floor_Alt;
   NewSector.Floor.Name := TheSector.Floor.Name;
   NewSector.Floor.f1   := TheSector.Floor.f1;
   NewSector.Floor.f2   := TheSector.Floor.f2;
   NewSector.Floor.i    := TheSector.Floor.i;
   NewSector.Ceili_Alt  := TheSector.Ceili_Alt;
   NewSector.Ceili.Name := TheSector.Ceili.Name;
   NewSector.Ceili.f1   := TheSector.Ceili.f1;
   NewSector.Ceili.f2   := TheSector.Ceili.f2;
   NewSector.Ceili.i    := TheSector.Ceili.i;
   NewSector.Second_Alt := TheSector.Second_Alt;
   NewSector.Layer      := TheSector.Layer;

   MAP_SEC.AddObject('SC', NewSector);
   nsc := MAP_SEC.Count - 1;

   {now, get the vertices positions}
   {new sector}
   vx0 := TVertex.Create;
   vx1 := TVertex.Create;
   vx2 := TVertex.Create;
   {old sector}
   vxa := TVertex.Create;
   vxb := TVertex.Create;
   vxc := TVertex.Create;

   WADLinedef  := TWAD_Linedef(WAD_LINEDEFS.Objects[ld]);
   vxld1       := TVertex(WAD_VERTEXES.Objects[WADLinedef.VERTEX1]);
   vxld2       := TVertex(WAD_VERTEXES.Objects[WADLinedef.VERTEX2]);

   vx0.X       := vxld1.X;
   vx0.Z       := vxld1.Z;
   vx1.X       := vxld2.X;
   vx1.Z       := vxld2.Z;
   vx2.X       := (vxld1.X + vxld2.X)/2;
   vx2.Z       := (vxld1.Z + vxld2.Z)/2;

   NewSector.Vx.AddObject('VX', vx0);
   NewSector.Vx.AddObject('VX', vx1);
   NewSector.Vx.AddObject('VX', vx2);

   vxa.X       := vxld1.X;
   vxa.Z       := vxld1.Z;
   vxb.X       := vxld2.X;
   vxb.Z       := vxld2.Z;
   vxc.X       := (vxld1.X + vxld2.X)/2;
   vxc.Z       := (vxld1.Z + vxld2.Z)/2;

   {this is the number of the first new vx}
   vcount      := TheSector.Vx.Count;
   TheSector.Vx.AddObject('VX', vxa);
   TheSector.Vx.AddObject('VX', vxb);
   TheSector.Vx.AddObject('VX', vxc);

   {the new sector has walls 01 12 20;
    01 beeing the "bad" linedef}

   TheWall := TWall.Create;
   {arbitrarily take the first sidedef for the new sector}
   WADSidedef := TWAD_Sidedef(WAD_SIDEDEFS.Objects[WADLinedef.SIDEDEF1]);
   with TheWall do
    begin
      Mark          := 0;
      Reserved      := 0;
      Left_vx       := 1;
      Right_vx      := 0;
      Adjoin        := -1;
      Mirror        := -1;
      Walk          := -1;
      Light         := 0;
      Flag1         := 0;
      Flag2         := WADLinedef.FLAGS;
      Flag3         := 0;
      if StrPas(WadSidedef.TX_MAIN) <> '-' then
       Mid.Name      := UpperCase(StrPas(WadSidedef.TX_MAIN))+'.BM'
      else
       Mid.Name      := '-';
      Mid.f1        := WadSidedef.X_OFFSET / 8.0;
      Mid.f2        := WadSidedef.Y_OFFSET / 8.0;
      Mid.i         := WADLinedef.TAG;
      if StrPas(WadSidedef.TX_UPPER) <> '-' then
       Top.Name      := UpperCase(StrPas(WadSidedef.TX_UPPER))+'.BM'
      else
       Top.Name      := '-';
      Top.f1        := WadSidedef.X_OFFSET / 8.0;
      Top.f2        := WadSidedef.Y_OFFSET / 8.0;
      Top.i         := WADLinedef.ACTION;
      if StrPas(WadSidedef.TX_LOWER) <> '-' then
       Bot.Name      := UpperCase(StrPas(WadSidedef.TX_LOWER))+'.BM'
      else
       Bot.Name      := '-';
      Bot.f1        := WadSidedef.X_OFFSET / 8.0;
      Bot.f2        := WadSidedef.Y_OFFSET / 8.0;
      Bot.i         := 1; {use this to say: was a 1st SD}
      Sign.Name     := '';
      if Copy(Top.Name,1,2) = 'SW' then Sign.Name := Top.Name;
      if Copy(Bot.Name,1,2) = 'SW' then Sign.Name := Bot.Name;
      if Copy(Mid.Name,1,2) = 'SW' then Sign.Name := Mid.Name;
      Sign.f1       := 0;
      Sign.f2       := 0;
      Sign.i        := 0;
      Elevator      := FALSE;
      Trigger       := FALSE;
      Cycle         := -1;
    end;
   NewSector.Wl.AddObject('WL', TheWall);
   for j := 1 to 2 do
    begin
     TheWall := TWall.Create;
     with TheWall do
      begin
        Mark          := 0;
        Reserved      := 0;
        if j = 1 then
         begin
          Left_vx       := 0;
          Right_vx      := 2;
         end
        else
         begin
          Left_vx       := 2;
          Right_vx      := 1;
         end;
        Adjoin        := -1;
        Mirror        := -1;
        Walk          := -1;
        Light         := 0;
        Flag1         := 0;
        Flag2         := 0;
        Flag3         := 0;
        Mid.Name      := '-';
        Mid.f1        := 0;
        Mid.f2        := 0;
        Mid.i         := 0;
        Top.Name      := '-';
        Top.f1        := 0;
        Top.f2        := 0;
        Top.i         := 0;
        Bot.Name      := '-';
        Bot.f1        := 0;
        Bot.f2        := 0;
        Bot.i         := 3; {use this to say: was an added line}
        Sign.Name     := '';
        Sign.f1       := 0;
        Sign.f2       := 0;
        Sign.i        := 0;
        Elevator      := FALSE;
        Trigger       := FALSE;
        Cycle         := -1;
      end;
     NewSector.Wl.AddObject('WL', TheWall);
    end;

   {the old sector has new walls ac cb ba,
    ba beeing the "bad" linedef
    vx # begin after the last existing vx and forming a new cycle}
   for j := 1 to 2 do
    begin
     TheWall := TWall.Create;
     with TheWall do
      begin
        Mark          := 0;
        Reserved      := 0;
        if j = 1 then
         begin
          Left_vx       := vcount;
          Right_vx      := vcount+1;
         end
        else
         begin
          Left_vx       := vcount+1;
          Right_vx      := vcount+2;
         end;
        Adjoin        := -1;
        Mirror        := -1;
        Walk          := -1;
        Light         := 0;
        Flag1         := 0;
        Flag2         := 0;
        Flag3         := 0;
        Mid.Name      := '-';
        Mid.f1        := 0;
        Mid.f2        := 0;
        Mid.i         := 0;
        Top.Name      := '-';
        Top.f1        := 0;
        Top.f2        := 0;
        Top.i         := 0;
        Bot.Name      := '-';
        Bot.f1        := 0;
        Bot.f2        := 0;
        Bot.i         := 3; {use this to say: was an added line}
        Sign.Name     := '';
        Sign.f1       := 0;
        Sign.f2       := 0;
        Sign.i        := 0;
        Elevator      := FALSE;
        Trigger       := FALSE;
        Cycle         := -1;
      end;
     TheSector.Wl.AddObject('WL', TheWall);
    end;
   TheWall := TWall.Create;
   {arbitrarily take the second sidedef for the old sector}
   WADSidedef := TWAD_Sidedef(WAD_SIDEDEFS.Objects[WADLinedef.SIDEDEF2]);
   with TheWall do
    begin
      Mark          := 0;
      Reserved      := 0;
      Left_vx       := vcount+2;
      Right_vx      := vcount;
      Adjoin        := -1;
      Mirror        := -1;
      Walk          := -1;
      Light         := 0;
      Flag1         := 0;
      Flag2         := WADLinedef.FLAGS;
      Flag3         := 0;
      if StrPas(WadSidedef.TX_MAIN) <> '-' then
       Mid.Name      := UpperCase(StrPas(WadSidedef.TX_MAIN))+'.BM'
      else
       Mid.Name      := '-';
      Mid.f1        := WadSidedef.X_OFFSET / 8.0;
      Mid.f2        := WadSidedef.Y_OFFSET / 8.0;
      Mid.i         := WADLinedef.TAG;
      if StrPas(WadSidedef.TX_UPPER) <> '-' then
       Top.Name      := UpperCase(StrPas(WadSidedef.TX_UPPER))+'.BM'
      else
       Top.Name      := '-';
      Top.f1        := WadSidedef.X_OFFSET / 8.0;
      Top.f2        := WadSidedef.Y_OFFSET / 8.0;
      Top.i         := WADLinedef.ACTION;
      if StrPas(WadSidedef.TX_LOWER) <> '-' then
       Bot.Name      := UpperCase(StrPas(WadSidedef.TX_LOWER))+'.BM'
      else
       Bot.Name      := '-';
      Bot.f1        := WadSidedef.X_OFFSET / 8.0;
      Bot.f2        := WadSidedef.Y_OFFSET / 8.0;
      Bot.i         := 2; {use this to say: was a 2nd SD}
      Sign.Name     := '';
      if Copy(Top.Name,1,2) = 'SW' then Sign.Name := Top.Name;
      if Copy(Bot.Name,1,2) = 'SW' then Sign.Name := Bot.Name;
      if Copy(Mid.Name,1,2) = 'SW' then Sign.Name := Mid.Name;
      Sign.f1       := 0;
      Sign.f2       := 0;
      Sign.i        := 0;
      Elevator      := FALSE;
      Trigger       := FALSE;
      Cycle         := -1;
    end;
   TheSector.Wl.AddObject('WL', TheWall);

   ProgressWindow.Gauge.Progress := ProgressWindow.Gauge.Progress + 1;
   WAD_CNVRTLOG.Add(Format('    ' + 'Recreated Linedef# %4.4d as sc# %3.3d', [ld, nsc]));
  end;

end;

procedure Do_ConvertThings;
var TheObject   : TOB;
    TheObject2  : TOB;
    TheSector   : TSector;
    WADThing    : TWAD_Thing;
    t           : Integer;
    thd         : TTH_DESC;
    dup         : Integer;
begin

 if WAD_THINGS.Count = 0 then exit;
 ProgressWindow.Gauge.MaxValue     := WAD_THINGS.Count - 1;
 ProgressWindow.Gauge.Progress     := 0;
 ProgressWindow.Progress2.Caption  := 'Converting Things...';
 ProgressWindow.Progress2.Update;

 SPR_LIST.Sorted     := TRUE;
 SPR_LIST.Duplicates := dupIgnore;
 FME_LIST.Sorted     := TRUE;
 FME_LIST.Duplicates := dupIgnore;

 for t := 0 to WAD_THINGS.Count - 1 do
  begin

   WADThing := TWAD_Thing(WAD_THINGS.Objects[t]);
   if GetThingData(WADThing.ID, thd) then
    if thd.debug = 'Y' then
     begin

      if thd.spec = '!' then
       begin
        WAD_CNVRTLOG.Add('    WARNING! Unconvertible Object (' +
                         thd.desc + ') at [' +
                         Format('%5.2f, %5.2f]', [WADThing.X / 8, WADThing.Y / 8]));
        continue;
       end;

      TheObject := TOB.Create;
       with TheObject do
        begin

         Mark      := 0;
         X         := WADThing.X / 8;
         Z         := WADThing.Y / 8;
         Sec       := -1;

         GetNearestSC(X, Z, Sec);
        
         if Sec <> -1 then
          begin
           TheSector := TSector(MAP_SEC.Objects[Sec]);
           Y         := TheSector.Floor_Alt;
          end;
         case WADThing.FACING of
            0 : Yaw :=  90.0;
           45 : Yaw :=  45.0;
           90 : Yaw :=   0.0;
          135 : Yaw := 315.0;
          180 : Yaw := 270.0;
          225 : Yaw := 225.0;
          270 : Yaw := 180.0;
          315 : Yaw := 135.0;
          else  Yaw :=   0.0;
         end;
         Pch       := 0.0;
         Rol       := 0.0;

         if (WADThing.FLAGS and 16) <> 0 then
          begin
           {thing is present in deathmatch only, don't convert it}
           TheObject.Free;
           continue;
          end;

         {clear the deaf bit (8) and any possible higher other bit}
         WADThing.FLAGS := WADThing.FLAGS and 7;

         CASE WADThing.FLAGS of
          0: Diff :=  0; {EMH not correct, but this shouldn't appear in WADs !}
          1: Diff := -1;
          2: Diff :=  2; {MH  not correct, should be M only (impossible)}
          3: Diff := -2;
          4: Diff :=  3;
          5: Diff :=  0; {EMH not correct, should be EH only (impossible)}
          6: Diff :=  2;
          7: Diff :=  1;
         END;

         Otype     := 0;
         Special   := 0;
        end;

      if thd.dfclas = 'FRAME' then
       begin
        TheObject.ClassName := thd.dfclas;
        TheObject.DataName  := thd.dfdata;
        FME_LIST.Add(thd.dfdata);
       end
      else
      if thd.dfclas = 'SPRITE' then
       begin
        TheObject.ClassName := thd.dfclas;
        TheObject.DataName  := thd.dfdata;
        SPR_LIST.Add(thd.dfdata);
       end
      else
      if thd.dfclas = 'SAFE' then
       begin
         TheObject.ClassName := thd.dfclas;
         TheObject.DataName  := thd.dfclas;
       end
      else
      if thd.dfclas = 'SPIRIT' then
       begin
        TheObject.ClassName := thd.dfclas;
        TheObject.DataName  := thd.dfclas;
       end;

      TheObject.Col := DOOM_GetOBColor(TheObject.DataName);

      if thd.logic[1] <> '*' then {general case}
       begin
        TmpSeqs       := TStringList.Create;
        DOOM_FillLogic(thd.Logic);
        if TmpSeqs.Count <> 0 then
         TheObject.Seq.AddStrings(TmpSeqs);
        TmpSeqs.Free;
       end
      else {special speed enhanced logics (no dm_seqs.wdf access)}
       begin
        {nothing to do for *N}
        {*A}
        if thd.Logic[2] = 'A' then
          TheObject.Seq.Add('LOGIC:     ANIM');
        {*a}
        if thd.Logic[2] = 'a' then
         begin
          TheObject.Seq.Add('LOGIC:     ANIM');
          TheObject.Seq.Add('RADIUS:    0');
         end;
        {*r}
        if thd.Logic[2] = 'r' then
          TheObject.Seq.Add('RADIUS:    0');
        {*S}
        if thd.Logic[2] = 'S' then
         begin
          TheObject.Seq.Add('LOGIC:     SCENERY');
          TheObject.Seq.Add('LOGIC:     ANIM');
         end;
       end;

      {handle duplicated objects ex boxes of ammo by storing the object
       more than once}
      if thd.duplic > 1 then
       for dup := 2 to thd.duplic do
        begin
         TheObject2            := TOB.Create;
         TheObject2.Mark       := 0;
         TheObject2.Sec        := TheObject.Sec;
         TheObject2.X          := TheObject.X;
         TheObject2.Y          := TheObject.Y;
         TheObject2.Z          := TheObject.Z;
         TheObject2.Yaw        := TheObject.Yaw;
         TheObject2.Pch        := TheObject.Pch;
         TheObject2.Rol        := TheObject.Rol;
         TheObject2.Diff       := TheObject.Diff;
         TheObject2.ClassName  := TheObject.ClassName;
         TheObject2.DataName   := TheObject.DataName;
         TheObject2.Seq.AddStrings(TheObject.Seq);
         TheObject2.Col        := TheObject.Col;
         TheObject2.Otype      := TheObject.OType;
         TheObject2.Special    := TheObject.Special;
         MAP_OBJ.AddObject('OB', TheObject2);
        end;

       MAP_OBJ.AddObject('OB', TheObject);
       if thd.spec = 'B' then
          begin
           WAD_CNVRTLOG.Add('    WARNING! Object #' +
                            Format('%3.3d (', [MAP_OBJ.Count - 1]) +
                            thd.desc + ') may be a tag 666/667 Boss');
          end;
       if thd.spec = 'L' then
          begin
           WAD_CNVRTLOG.Add('    MESSAGE: Object #' +
                            Format('%3.3d is a ', [MAP_OBJ.Count - 1]) +
                            thd.desc);
          end;
     end;

   if t mod 20 = 19 then
   ProgressWindow.Gauge.Progress := ProgressWindow.Gauge.Progress + 20;
  END;

 {to keep the list in the same state as if this came from opening a GOB not a WAD}
 SPR_LIST.Sorted     := FALSE;
 FME_LIST.Sorted     := FALSE;

 WAD_CNVRTLOG.Add('    Created ' + IntToStr(MAP_OBJ.Count) + ' object(s)');
end;


(*
TYPE {things description}
 TTH_DESC  = record
    debug  : String;   {Y/N}
    dfclas : String;
    dfdata : String;
    logic  : String;
    spec   : String;   {specials e.g. keys, crush bits, ...}
    dmclas : String;
    dmroot : String;
    desc   : String;   {textual description}
 end;
*)

function GetThingData(num : Integer; VAR thd : TTH_DESC) : Boolean;
var doomdata : TIniFile;
    datastr  : String;
    pars     : TStringParserWithColon;
    tmp      : array[0..127] of char;
    str      : string;
    i        : Integer;
begin
 doomdata := TIniFile.Create(WDFUSEdir + '\WDFDATA\DOOMDATA.WDF');

 datastr  :=doomdata.ReadString('Thing_Types', Format('0x%3.3x', [num]), '***');
 if datastr = '***' then
  begin
   Result := FALSE;
   Str := Format('ERROR!!!! Invalid Thing Type %d (0x%3.3x)',[num, num]);
   WAD_CNVRTLOG.Add('    ' + str);
   StrPcopy(tmp, str);
   Application.MessageBox(tmp, 'WDFUSE Mapper - WAD Convert',
                             mb_Ok or mb_IconInformation);
  end
 else
  begin
   {split the data in the different parts}
   pars := TStringParserWithColon.Create(datastr);
   if pars.Count < 9 then
    begin
     Result := FALSE;
     Str := Format('ERROR!!!! in DOOMDATA.WDF [Thing_Types] item %d (0x%3.3x)',[num, num]);
     WAD_CNVRTLOG.Add('    ' + str);
     StrPcopy(tmp, str);
     Application.MessageBox(tmp, 'WDFUSE Mapper - WAD Convert',
                             mb_Ok or mb_IconInformation);
    end
   else
    begin
     Result     := TRUE;
     thd.debug  := pars[1];
     thd.dfclas := pars[2];
     thd.dfdata := pars[3];
     thd.logic  := pars[4];
     if pars[5] <> '-' then
      thd.duplic := StrToInt(pars[5])
     else
      thd.duplic := 1;
     thd.spec   := pars[6];
     thd.dmclas := pars[7];
     thd.dmroot := pars[8];
     thd.desc   := '';
     for i := 9 to pars.Count - 1 do
      thd.desc   := thd.desc + ' ' + pars[i];
     thd.desc := LTrim(thd.desc);
    end;
   pars.Free;
  end;
 doomdata.Free;
end;

function DOOM_GetOBColor(thing : String) : LongInt;
var
 COLORini  : TIniFile;
begin
 COLORini := TIniFile.Create(WDFUSEdir + '\WDFDATA\DM_COLS.WDF');
 try
  Result := COLORini.ReadInteger(thing, 'COLOR', Ccol_shadow);
 finally
  COLORini.Free;
 end;
end;

procedure DOOM_FillLogic(thing : String);
var obs     : TIniFile;
    cnt     : Integer;
    lines   : Integer;
    i       : Integer;
    ALine   : String;
begin
 obs := TIniFile.Create(WDFUSEdir + '\WDFDATA\dm_seqs.wdf');
 try
  cnt := obs.ReadInteger(thing, 'CNT', 0);
  if cnt = 1 then
   begin
    lines := obs.ReadInteger(thing, '100', 0);
    for i := 1 to lines do
     begin
      ALine := obs.ReadString(thing, IntToStr(100+i), '');
      TmpSeqs.Add(ALine);
     end;
   end;
 finally
  obs.Free;
 end;
end;


procedure DO_CreateListForAlex;
var   s,w       : Integer;
      TheSector : TSector;
      TheWall   : TWall;
      FL_LIST   : TStringList;
      TE_LIST   : TStringList;
      ALEX_LIST : TStringList;
begin
 FL_LIST            := TStringList.Create;
 FL_LIST.Sorted     := TRUE;
 FL_LIST.Duplicates := dupIgnore;
 TE_LIST            := TStringList.Create;
 TE_LIST.Sorted     := TRUE;
 TE_LIST.Duplicates := dupIgnore;

 for s := 0 to MAP_SEC.Count - 1 do
  begin
   TheSector := TSector(MAP_SEC.Objects[s]);
   FL_LIST.Add(TheSector.Floor.Name);
   FL_LIST.Add(TheSector.Ceili.Name);
   for w := 0 to TheSector.Wl.Count - 1 do
    begin
      TheWall := TWall(TheSector.Wl.Objects[w]);
      TE_LIST.Add(TheWall.Mid.Name);
      TE_LIST.Add(TheWall.Top.Name);
      TE_LIST.Add(TheWall.Bot.Name);
{!!!!! we should handle switches for the new WAD2GOB !!!!!}
      if TheWall.Sign.Name <> '' then
       TE_LIST.Add(TheWall.Sign.Name);
    end;
  end;

 {construct my own TX_LIST now, as I have all the info}
 TX_LIST.Clear;
 TX_LIST.Sorted := TRUE;
 TX_LIST.Duplicates := dupIgnore;
 TX_LIST.AddStrings(FL_LIST);
 TX_LIST.AddStrings(TE_LIST);

 {Get rid of - in my list, replace it everywhere by DEFAULT.BM}
 TX_LIST.Sorted := FALSE;
 s := TX_LIST.IndexOf('-');
 if s <> -1 then TX_LIST.Delete(s);
 TX_List.Add('DEFAULT.BM');
 TX_LIST.Sorted := TRUE;

 for s := 0 to MAP_SEC.Count - 1 do
  begin
   TheSector := TSector(MAP_SEC.Objects[s]);
   if TheSector.Floor.Name = '-' then TheSector.Floor.Name := 'DEFAULT.BM';
   if TheSector.Ceili.Name = '-' then TheSector.Ceili.Name := 'DEFAULT.BM';
   for w := 0 to TheSector.Wl.Count - 1 do
    begin
      TheWall := TWall(TheSector.Wl.Objects[w]);
      if TheWall.Mid.Name = '-' then TheWall.Mid.name := 'DEFAULT.BM';
      if TheWall.Top.Name = '-' then TheWall.Top.name := 'DEFAULT.BM';
      if TheWall.Bot.Name = '-' then TheWall.Bot.name := 'DEFAULT.BM';
    end;
  end;

 {remove '-' and all the '.BM' from Alex' list}
 s := TE_LIST.IndexOf('-');
 if s <> -1 then TE_LIST.Delete(s);

 {mandatory to allow direct access in a sorted list}
 FL_LIST.Sorted     := FALSE;
 TE_LIST.Sorted     := FALSE;

 for s := 0 to FL_LIST.Count - 1 do
  begin
   FL_LIST[s] := Copy(FL_LIST[s], 1, Pos('.BM', FL_LIST[s])-1);
  end;

 {remove sky from the flats}
 s := FL_LIST.IndexOf(TheSky);
 if s <> -1 then FL_LIST.Delete(s);

 for s := 0 to TE_LIST.Count - 1 do
  begin
   TE_LIST[s] := Copy(TE_LIST[s], 1, Pos('.BM', TE_LIST[s])-1);
  end;

 ALEX_LIST := TStringList.Create;
 ALEX_LIST.Add('[FLATS]');
 ALEX_LIST.AddStrings(FL_LIST);
 ALEX_LIST.Add('');
 ALEX_LIST.Add('[TEXTURES]');
 ALEX_LIST.Add(TheSky);
 ALEX_LIST.AddStrings(TE_LIST);
 ALEX_LIST.Add('');

 ALEX_LIST.Add('[SPRITES]');
 for s := 0 to SPR_LIST.Count - 1 do
  begin
   ALEX_LIST.Add(Copy(SPR_LIST[s], 1, Pos('.WAX', SPR_LIST[s])-1));
  end;
 ALEX_LIST.Add('');
 ALEX_LIST.Add('[FRAMES]');
 for s := 0 to FME_LIST.Count - 1 do
  begin
   ALEX_LIST.Add(Copy(FME_LIST[s], 1, Pos('.FME', FME_LIST[s])-1));
  end;

 FL_LIST.Free;
 TE_LIST.Free;

 ALEX_LIST.SaveToFile(LEVELPath+'\doom_res.lst');
 WAD_CNVRTLOG.Add('');
 WAD_CNVRTLOG.Add('Contents of ' + LEVELPath+'\doom_res.lst');
 WAD_CNVRTLOG.Add('');
 WAD_CNVRTLOG.AddStrings(ALEX_LIST);

 ALEX_LIST.Free;
end;

end.
