unit M_util;

interface
uses
  SysUtils, WinTypes, WinProcs, Classes, Graphics, IniFiles, Dialogs, Forms,
  _Math, _Strings, _Files,
  M_Global, M_io, M_Progrs, M_Find, M_Multi, M_Checks,
  M_Editor, M_SCedit, M_WLedit, M_VXedit, M_OBedit,
  V_Util, I_Util, G_Util, Generics.Collections, clipBrd,
  REST.JsonReflect, StrUtils, Jsons, JsonsUtilsEx, IOUTils, System.diagnostics,
  System.TimeSpan, REST.Client, REST.Types, System.JSON, System.Math;

procedure DO_Help;
function  DO_InitGOBS : Boolean;
procedure DO_LoadProjectWrapper(ProjectPath : String);
function  DO_GOB_Verify : Boolean;
procedure DO_LoadLevel(CustomProject : string='');
Procedure DO_OpenProject;
procedure DO_SaveProject;
procedure DO_SaveProjectAs(NewProjectWDFFile : String);
procedure SaveShowCaseData;

procedure DO_SetMapButtonsState;

function  GetSectorNumFromName(Name : String; VAR Num : Integer) : Boolean;
function  GetSectorNumFromNameNoCase(Name : String; VAR Num : Integer) : Boolean;

function  GetNearestSC(X, Z : Real; VAR ASector : Integer; ignore_layer : boolean = False) : Boolean;
function  GetNearestOB(X, Z : Real; VAR AObject : Integer) : Boolean;
function  GetNearestWL(X, Z : Real; VAR ASector : Integer; VAR AWall : Integer) : Boolean;
function  GetNearestVX(X, Z : Real; VAR ASector : Integer; VAR AVertex : Integer) : Boolean;
function  GetNextNearestVX(X, Z : Real; VAR ASector : Integer; VAR AVertex : Integer) : Boolean;

function  GetWLfromLeftVX(sector, leftvx : Integer; VAR AWallNum : Integer) : Boolean;
function  GetWLfromRightVX(sector, rightvx : Integer; VAR AWallNum : Integer) : Boolean;

function  GetNearestGridPoint(X, Z : Real; VAR GX, GZ : Real) : Boolean;

procedure LayerAllObjects;
procedure LayerAllObjectsNoProgress;
function  LayerObject(obnum : Integer) : Boolean;
function  GetObjectSC(obnum : Integer; VAR ASector : Integer) : Boolean;

function  ForceLayerObject(ob : Integer) : Boolean;
function  MultiForceLayerObject : Integer;
function  DO_SameVXPosition(left, right : TVertex) : Boolean;
procedure DO_MarkAdjacentVertices(sc, wl : integer; rootvx : TVertex);
procedure DO_TranslateVertex(sc,vx : Integer; x,z : Real);
procedure DO_ProcessMarkedVX(x,z : Real);
procedure DO_Translate_SelMultiSel(x, z : Real);
procedure DO_Select_In_Rect;

procedure DO_Find_SC_By_Name;
procedure DO_Find_WL_Adjoin;
function  DO_Find_PlayerStart(update_player : boolean = True) : Integer;
procedure DO_Find_VX_AtSameCoords;

function  GetWLLen(sc, wl : Integer) : Real;
function  GetWLHei(sc, wl : Integer) : Real;

function  DifficultyOk(diff : Integer) : Boolean;

procedure DO_ConsistencyChecks;

procedure DO_CloseSector(sc: Integer);

procedure DO_Init_Markers;
procedure DO_Set_Marker(n : Integer);
procedure DO_Goto_Marker(n : Integer);

procedure DO_RecomputeTexturesLists(usegauge : Boolean; maintitle : string);
procedure DO_RecomputeObjectsLists(usegauge : Boolean; maintitle : string);

procedure UpdateShowCase;
procedure DO_StoreUndo;
procedure DO_FreeUndo(UndoIndex : Integer = -1);
procedure DEBUG_UNDO;
procedure DO_ApplyUndo(reverse : Boolean = False);

procedure DO_FreeGeometryClip;
procedure DO_FreeObjectsClip;

function  SerializeSector(sc : Integer) : string;
function  SerializeObject(ob : Integer) : string;

procedure DO_CopyGeometry;
procedure DO_PasteGeometry(cursX, cursZ : Real; payload : TJson);

procedure DO_CopyObjects;
procedure DO_PasteObjects(cursX, cursZ : Real; payload : TJson);

procedure DO_PasteWrapper(cursX, cursZ : Real);
function IsPointInSector(sc : integer; x, z : real): Boolean;

procedure DO_UpdatePRJHistory;
{  **********  **********  **********  **********  **********  **********  }

implementation
uses Mapper, M_MapUt, M_MapFun, M_Option;


procedure DO_Help;
begin
  MapWindow.HelpTutorialClick(NIL);
end;

function  DO_InitGOBS : Boolean;
var header : array[0..40] of Char;
    line1P : String;
    line2P : String;
    lineP  : String;
    crlf   : String;
    lineC  : array[0..200] of Char;
begin

  strcopy(header, 'WDFUSE Mapper - Initializing');
  line1P  := 'WDFUSE cannot find ';
  line2P  := 'Set Installed Dir / CD-ROM in Options.';
  crlf    := '??';
  crlf[1] := #13;
  crlf[2] := #10;
  {Find DF Gobs whereever they are}
  {make a quick test on dark.exe also to check the installed dir}
  if not FileExists(DarkInst + '\DARK.EXE') then
   begin
    lineP := line1P + 'DARK.EXE!' + crlf + 'Set Installed Dir in Options.';
    StrPCopy(lineC, lineP);
    Application.MessageBox(lineC, header, mb_Ok or mb_IconExclamation);
    DO_InitGOBS := FALSE;
    exit;
   end;

  DARKgob := '';
  if FileExists(DarkInst + '\DARK.GOB') then
   DARKgob := DarkInst + '\DARK.GOB'
  else
   if FileExists(DarkCD + ':\DARK\DARK.GOB') then
    DARKgob := DarkCD + ':\DARK\DARK.GOB'
   else
    begin
     lineP := line1P + 'DARK.GOB!' + crlf + line2P;
     StrPCopy(lineC, lineP);
     Application.MessageBox(lineC, header, mb_Ok or mb_IconExclamation);
     DO_InitGOBS := FALSE;
     exit;
    end;

  if IsFileInUse(DarkInst + '\DARK.GOB') then
    begin
      showmessage('Error ! DARK.GOB is locked! Cannot extract data. Is Dark Forces Running? Turn it off first');
      exit;
    end;

  SPRITESgob := '';
  if FileExists(DarkInst + '\SPRITES.GOB') then
   SPRITESgob := DarkInst + '\SPRITES.GOB'
  else
   if FileExists(DarkCD + ':\DARK\SPRITES.GOB') then
    SPRITESgob := DarkCD + ':\DARK\SPRITES.GOB'
   else
    begin
     lineP := line1P + 'SPRITES.GOB!' + crlf + line2P;
     StrPCopy(lineC, lineP);
     Application.MessageBox(lineC, header, mb_Ok or mb_IconExclamation);
     DO_InitGOBS := FALSE;
     exit;
    end;

  TEXTURESgob := '';
  if FileExists(DarkInst + '\TEXTURES.GOB') then
   TEXTURESgob := DarkInst + '\TEXTURES.GOB'
  else
   if FileExists(DarkCD + ':\DARK\TEXTURES.GOB') then
    TEXTURESgob := DarkCD + ':\DARK\TEXTURES.GOB'
   else
    begin
     lineP := line1P + 'TEXTURES.GOB!' + crlf + line2P;
     StrPCopy(lineC, lineP);
     Application.MessageBox(lineC, header, mb_Ok or mb_IconExclamation);
     DO_InitGOBS := FALSE;
     exit;
    end;

  SOUNDSgob := '';
  if FileExists(DarkInst + '\SOUNDS.GOB') then
   SOUNDSgob := DarkInst + '\SOUNDS.GOB'
  else
   if FileExists(DarkCD + ':\DARK\SOUNDS.GOB') then
    SOUNDSgob := DarkCD + ':\DARK\SOUNDS.GOB'
   else
    begin
     lineP := line1P + 'SOUNDS.GOB!' + crlf + line2P;
     StrPCopy(lineC, lineP);
     Application.MessageBox(lineC, header, mb_Ok or mb_IconExclamation);
     DO_InitGOBS := FALSE;
     exit;
    end;


 if (ENGINE_TYPE = 'TFE') and not fileexists(TFE_EXE) then
   begin
     showmessage('Warning! Cannot find The Force Engine executable at ' + TFE_EXE);
     DO_InitGOBS := FALSE;
     exit;
   end;


 DO_InitGOBS := TRUE;
end;


procedure DO_LoadProjectWrapper(ProjectPath : String);
begin
  if fileexists(ProjectPath) then
     begin
      try
        MapWindow.Update;
        if LEVELLoaded then FreeLevel;
        DO_LoadLevel(ProjectPath);
      except on E: Exception do
        // So you don't go into a crash loop
        begin
          HandleException('Failed to load previous project. Disabling level auto-loading.', E);
          LOADPREVPRJ := False;
          Ini.WriteBool('DARK FORCES', 'LOADPREVPRJ', LOADPREVPRJ);
        end;
      end
  end;
end;

// Checks to make sure you didn't mess anything up.
function DO_GOB_Verify : boolean;
var
  TheObject           : TOB;
  i, j, o : integer;
  logic : TStringList;

begin
  Result := True;

  // Check for player start
  o := DO_Find_PlayerStart(False);
  if o = -1 then
     begin
       showmessage('Missing Player Start! The GOB will crash!');
       Result := False
     end
  else
    begin
      // Check that player is inside the sector
      TheObject := TOB(MAP_OBJ.Objects[o]);
      if not GetNearestSC(TheObject.X, TheObject.Z, j, True) then
        begin
           showmessage('Player start is not in a sector! The GOB will crash!');
           Result := False
        end;
    end;

  // Ensure all objects have classes and names

  for o := 0 to MAP_OBJ.Count - 1 do
    begin
     TheObject := TOB(MAP_OBJ.Objects[o]);
     if TheObject.ClassName = '' then
      begin
        showmessage('Object ' + inttostr(o) + ' does not have a valid class name! Dark Forces will crash!');
        Result := False;
        exit;
      end;

     if TheObject.DataName = '' then
      begin
        showmessage('Object ' + inttostr(o) + ' does not have a valid date name! Dark Forces will crash!');
        Result := False;
        exit;
      end;
    end;

end;



procedure DO_LoadLevel(CustomProject : string='');
var pjf  : TIniFile;
begin

 if CustomProject <> '' then
    PROJECTFile := CustomProject;

 try

  pjf := TIniFile.Create(PROJECTFile);
  LEVELPath := pjf.ReadString('WDFUSE Project', 'DIRECTORY', '');
  LEVELName := pjf.ReadString('WDFUSE Project', 'LEVELNAME', '');
  LEVELBNum := pjf.ReadInteger('WDFUSE Project', 'BACKUPNUM', -1);
  if (LEVELPath <> '') and (LEVELName <> '') then
   begin
    if IO_ReadLEV(LEVELPath + '\' + LEVELName + '.LEV') then
     begin
      if IO_ReadO(LEVELPath + '\' + LEVELName + '.O') then
       begin
        LayerAllObjects;
       end;
      IO_ReadINF(LEVELPath + '\' + LEVELName + '.INF');
      DOOM          := pjf.ReadBool('WDFUSE Project', 'DOOM', FALSE);
      SetDOOMEditors;
      MODIFIED      := FALSE;
      BACKUPED      := FALSE;
      Xoffset       := 0;
      Zoffset       := 0;
      {Scale         := 1;
      grid          := 8;
      grid_offset   := 4;} // Loaded via config now
      ScreenX       := MapWindow.Map.Width;
      ScreenZ       := MapWindow.Map.Height;
      ScreenCenterX := MapWindow.Map.Width div 2;
      ScreenCenterZ := MapWindow.Map.Height div 2;
      MAP_RECT.Left    := 0;
      MAP_RECT.Right   := MapWindow.Map.Width;
      MAP_RECT.Top     := 0;
      MAP_RECT.Bottom  := MapWindow.Map.Height;
      MapWindow.PanelLevelName.Caption := LEVELName;
      DO_SetMapButtonsState;
      DO_Center_Map;
      DO_Init_Markers;
      MAP_MODE := MM_VX;
      DO_Switch_To_SC_Mode;
      MapWindow.Caption := 'WDFUSE ' +  WDFUSE_VERSION + ' - ' + LowerCase(PROJECTFile) + ' : SECTORS';
      DO_FreeUndo;
      MapWindow.KeyPreview := True;
      DO_UpdatePRJHistory;
      MapWindow.UpdateRecent;

      // Handle previews
      if AutoStartShowCase then
        Preview_3D_Level
      else if ProcessRunning('Dark Forces Showcase.exe') OR SHOWCASE_DEBUG then
        MapWindow.ToolsResetShowCaseClick(NIL);

     end
  end
 else
  Application.MessageBox('Invalid WDFUSE Project File (.WDP)',
                         'WDFUSE Mapper - Open Project',
                         mb_Ok or mb_IconExclamation);
 finally
  pjf.Free;
 end;
end;

procedure DO_OpenProject;
var i : integer;
begin
 with MapWindow.OpenProjectDialog do
  begin
    InitialDir := WDFUSEdir;
    if Execute then
     if not (ofExtensionDifferent in Options) then
      begin
       Log.Info('Opened New Project ' + PROJECTFile, LogName);
       if LEVELLoaded then FreeLevel;
       MapWindow.Update;
       PROJECTFile := FileName;
       Ini.WriteString('DARK FORCES',  'PROJECTFile', PROJECTFile);
       DO_LoadLevel;
       BACKUPED := FALSE;

       if PRJ_History.count > 0 then
          // Delete any instances of the same file from history to remove dupes
         for i := 0 to PRJ_History.count -1 do
            begin
              if PRJ_History[i] = PROJECTFile then
                begin
                  PRJ_History.delete(i);
                  break;
                end
          end;

       PRJ_History.insert(0, PROJECTFile);

       // Clean up anything over limit
       if PRJ_History.count > MAX_RECENT then
          PRJ_History.Delete(MAX_RECENT);


       MapWindow.Map.Invalidate;
      end
     else
      Application.MessageBox('You must select a WDFUSE Project File (.WDP)',
                             'WDFUSE Mapper - Open Project',
                             mb_Ok or mb_IconExclamation);

  end;
{do an invalidate in any case, if only to clear an old screen}

end;

procedure DO_SaveProjectAs(NewProjectWDFFile : String);
var prj, targetPrj : TIniFile;
    OldPrjPath, NewLEVELPATH, NewPrjName  : String;
begin
 Log.Info('Saving Project As ' + NewProjectWDFFile, LogName);
 { Copy project file to new location }
 CopyFile(PROJECTFile, NewProjectWDFFile);
 NewPrjName := TPath.GetFileNameWithoutExtension(NewProjectWDFFile);
 NewLEVELPATH := ExtractFilePath(NewProjectWDFFile) + NewPrjName;

 prj := TIniFile.Create(PROJECTFile);
 try
   OldPrjPath := prj.ReadString('WDFUSE Project', 'DIRECTORY', '');
 finally
  prj.Free;
 end;

 TDirectory.Copy(OldPrjPath, NewLEVELPATH);

 if TDirectory.Exists(NewLEVELPATH + '\BACKUPS') then
   begin
     TDirectory.Delete(NewLEVELPATH + '\BACKUPS', True);
     TDirectory.CreateDirectory(NewLEVELPATH + '\BACKUPS');
     LEVELBNum := -1;
   end;

 CopyFile(ChangeFileExt(PROJECTFile, '.TXT'),
          ChangeFileExt(NewProjectWDFFile, '.TXT'));

 targetPrj := TIniFile.Create(NewProjectWDFFile);
 try
   targetPrj.WriteString('WDFUSE Project', 'DIRECTORY', NewLEVELPATH);
   targetPrj.WriteString('WDFUSE Project', 'LASTMODIF', DateTimeToStr(Now));
 finally
  targetPrj.Free;
 end;
 PROJECTFile := NewProjectWDFFile;
 LEVELPath := NewLEVELPATH;
 DO_SaveProject;
 DO_Switch_To_SC_Mode;
 MapWindow.Caption := 'WDFUSE ' +  WDFUSE_VERSION + ' - ' + LowerCase(PROJECTFile) + ' : SECTORS';
end;

procedure DO_SaveProject;
var drv,i  : Integer;
    path1,
    path2  : String;
    pjf  : TIniFile;
begin
 { BACKUPS are made in another directory, leaving the project directory
   containing only the files to gob
   Let's use a BACKUPS subdirectory for this
   Do check the free disk space however, and warn the user with a
   disk space < 10 Mb box, which will let him make room before going on
}
 Log.Info('Saving Project ' + PROJECTFile, LogName);

 DO_UpdatePRJHistory;

 drv    := Ord(LevelPATH[1]) - 96;
 if drv < 0 then drv := Ord(LevelPATH[1]) - 64;

 if (DiskFree(drv) div 1024) < 10240 then
  Application.MessageBox('WARNING : Less Than 10MB of Free Disk Space',
                         'WDFUSE Mapper - Save Project',
                         mb_Ok or mb_IconExclamation);

 path1 := LEVELPath + '\' + LEVELName;
 path2 := LEVELPath + '\BACKUPS\' + LEVELName;

 CASE Backup_Method of
  0 : begin
       {full incremented backup names are xxxx.L00 => xxxx.L99}
       Inc(LEVELBNum);
       if LEVELBNum > MAXBACKUPS then LEVELBNum := 0;
       CopyFile(path1 + '.LEV', path2 + '.L' + Format('%-2.3d',[LEVELBNum]));
       CopyFile(path1 + '.O'  , path2 + '.O' + Format('%-2.3d',[LEVELBNum]));
       CopyFile(path1 + '.INF', path2 + '.I' + Format('%-2.3d',[LEVELBNum]));
       CopyFile(path1 + '.GOL', path2 + '.G' + Format('%-2.3d',[LEVELBNum]));
       CopyFile(path1 + '.PAL', path2 + '.P' + Format('%-2.3d',[LEVELBNum]));
       CopyFile(path1 + '.CMP', path2 + '.C' + Format('%-2.3d',[LEVELBNum]));

       CopyFile(ChangeFileExt(PROJECTFile, '.TXT'),
                LEVELPath + '\BACKUPS\' + ExtractFileName(ChangeFileExt(PROJECTFile, '.T')) + Format('%-2.3d',[LEVELBNum]));
       CopyFile(LEVELPath + '\jedi.lvl', LEVELPath + '\BACKUPS\jedi.L' + Format('%-2.3d',[LEVELBNum]));
       CopyFile(LEVELPath + '\text.msg', LEVELPath + '\BACKUPS\text.M' + Format('%-2.3d',[LEVELBNum]));

       {save the backup num}
       pjf := TIniFile.Create(PROJECTFile);
       try
        pjf.WriteInteger('WDFUSE Project', 'BACKUPNUM', LEVELBNum);
       finally
        pjf.Free;
       end;
      end;
  1 : begin
       {single backup}
       if not BACKUPED then
        begin
         CopyFile(path1 + '.LEV', path2 + '.~LE' );
         CopyFile(path1 + '.O'  , path2 + '.~O'  );
         CopyFile(path1 + '.INF', path2 + '.~IN' );
         CopyFile(path1 + '.GOL', path2 + '.~GO' );
         CopyFile(path1 + '.PAL', path2 + '.~PA' );
         CopyFile(path1 + '.CMP', path2 + '.~CM' );

         CopyFile(ChangeFileExt(PROJECTFile, '.txt'),
                  LEVELPath + '\BACKUPS\' + ExtractFileName(ChangeFileExt(PROJECTFile, '.~TX')));
         CopyFile(LEVELPath + '\jedi.lvl', LEVELPath + '\BACKUPS\jedi.~LV');
         CopyFile(LEVELPath + '\text.msg', LEVELPath + '\BACKUPS\text.~MS');
         BACKUPED := TRUE;
        end;
      end;
 END;


 IO_WriteLEV(LEVELPath + '\' + LEVELName + '.LEV');
 IO_WriteO(LEVELPath + '\' + LEVELName + '.O');
 IO_WriteINF2(LEVELPath + '\' + LEVELName + '.INF');

 Ini.WriteString('DARK FORCES',  'PROJECTFile', PROJECTFile);

 {set the LASTMODIF entry in the project file}
 pjf := TIniFile.Create(PROJECTFile);
 try
  pjf.WriteString('WDFUSE Project', 'LASTMODIF', DateTimeToStr(Now));
 finally
  pjf.Free;
 end;
 MODIFIED := FALSE;
end;


//  This is to only save individual LEV/O data for showcase.
procedure SaveShowCaseData;
var showcase_path  : String;
begin

 Log.Info('Saving Showcase Data ' + PROJECTFile, LogName);
 showcase_path := LEVELPath + '\SHOWCASE\';

 if not directoryexists(showcase_path) then
    createdir(showcase_path);

 // Only write LEV and O
 IO_WriteLEV(LEVELPath + '\' + LEVELName + '.LEV');
 IO_WriteO(LEVELPath + '\' + LEVELName + '.O');
end;

procedure DO_SetMapButtonsState;
begin
  if LevelLOADED then
   begin
    MAP_SEC_UNDO  := TStringList.Create;
    MAP_OBJ_UNDO  := TStringList.Create;
    MAP_GUI_UNDO  := TStringList.Create;
    MAP_GLOBAL_UNDO := TList<TStringList>.Create;
   end;

  MapWindow.SpeedButtonSave.Enabled      := LEVELLoaded;
  MapWindow.SpeedButtonSC.Enabled        := LEVELLoaded;
  MapWindow.SpeedButtonWL.Enabled        := LEVELLoaded;
  MapWindow.SpeedButtonVX.Enabled        := LEVELLoaded;
  MapWindow.SpeedButtonOB.Enabled        := LEVELLoaded;
  MapWindow.SpeedButtonSC.Down           := TRUE;
  MapWindow.SpeedButtonZoomIn.Enabled    := LEVELLoaded;
  MapWindow.SpeedButtonZoomOut.Enabled   := LEVELLoaded;
  MapWindow.SpeedButtonZoomNone.Enabled  := LEVELLoaded;
  MapWindow.SpeedButtonGridIn.Enabled    := LEVELLoaded;
  MapWindow.SpeedButtonGridOut.Enabled   := LEVELLoaded;
  MapWindow.SpeedButtonGridEight.Enabled := LEVELLoaded;
  MapWindow.SpeedButtonGridOnOff.Enabled := LEVELLoaded;{added by DL 10/nov/96}
  MapWindow.SpeedButtonCenterMap.Enabled := LEVELLoaded;
  MapWindow.SpeedButtonTools.Enabled     := LEVELLoaded;
  MapWindow.SpeedButtonInf.Enabled       := LEVELLoaded;
  MapWindow.SpeedButtonGol.Enabled       := LEVELLoaded;
  MapWindow.SpeedButtonLvl.Enabled       := LEVELLoaded;
  MapWindow.SpeedButtonMsg.Enabled       := LEVELLoaded;
  MapWindow.SpeedButtonTxt.Enabled       := LEVELLoaded;
  MapWindow.SpeedButtonLevel.Enabled     := LEVELLoaded;
  MapWindow.SpeedButtonGOBTest.Enabled   := LEVELLoaded;
{  MapWindow.PLTEDitor.Enabled            := LEVELLoaded;}
  MapWindow.SpeedButton3DPreview.Enabled := LEVELLoaded;
  MapWindow.SpeedButtonDF21.Enabled      := TRUE;
  MapWindow.SpeedButtonToolsMain.Enabled := LEVELLoaded;
  MapWindow.SpeedButtonChecks.Enabled    := LEVELLoaded;
  MapWindow.SBSaveMapBMP.Enabled         := LEVELLoaded;
  MapWindow.PanelMulti.Enabled           := LEVELLoaded;
  MapWindow.PanelMapType.Enabled         := LEVELLoaded;
  MapWindow.Panel1MapType.Enabled        := LEVELLoaded;{//Added DL 12/nov/96            }
  MapWindow.SpeedButtonQuery.Enabled     := LEVELLoaded;
  MapWindow.FileOpenFolder.Enabled       := LEVELLoaded;
  MapWindow.ProjectReopen.Enabled        := LEVELLoaded;






  {New smaller one next to scrollbars}
  MapWindow.SBCenterMap.Enabled          := LEVELLoaded;

  { Menu }
  MapWindow.ProjectSave.Enabled          := LEVELLoaded;
  MapWindow.ProjectClose.Enabled         := LEVELLoaded;
  MapWindow.ProjectDelete.Enabled        := not LEVELLoaded;
  MapWindow.ProjectChecks.Enabled        := LEVELLoaded;
  MapWindow.ProjectGOBTest.Enabled       := LEVELLoaded;
  MapWindow.RenderIn3D.Enabled           := LEVELLoaded;
  MapWindow.EditMenu.Enabled             := LEVELLoaded;
  MapWindow.ViewEditors.Enabled          := LEVELLoaded;
  MapWindow.ModeMenu.Enabled             := LEVELLoaded;
  MapWindow.MapMenu.Enabled              := LEVELLoaded;
  MapWindow.ToolsQuery.Enabled           := LEVELLoaded;
  MapWindow.ToolsTools.Enabled           := LEVELLoaded;

  { Scrollbars}
  MapWindow.HScrollBar.Enabled           := LEVELLoaded;
  MapWindow.VScrollBar.Enabled           := LEVELLoaded;
  MapWindow.LScrollBar.Enabled           := LEVELLoaded;
  MapWindow.LScrollBar1.Enabled          := LEVELLoaded;

  if LEVELLoaded then
    begin
      MapWindow.PanelLayer.Caption       := IntToStr(LAYER);
      MapWindow.PanelMapLayer.Caption    := IntToStr(LAYER); {//added by DL nov11/96}
      CASE OBDIFF OF
     {//  0 : MapWindow.PanelOBLayer.Caption     := 'All';  }
       0 : MapWindow.Panel1OBLayer.Caption     := 'All';   {//added DL 12/nov/96 }
    {//   1 : MapWindow.PanelOBLayer.Caption     := 'Easy'; }
       1 : MapWindow.Panel1OBLayer.Caption     := 'Easy';    {//added DL 12/nov/96  }
   {  //  2 : MapWindow.PanelOBLayer.Caption     := 'Med';   }
       2 : MapWindow.Panel1OBLayer.Caption     := 'Med';      { //added DL 12/nov/96  }
  { //    3 : MapWindow.PanelOBLayer.Caption     := 'Hard';  }
       3 : MapWindow.Panel1OBLayer.Caption     := 'Hard';     {//added DL 12/nov/96}
      END;
      MapWindow.PanelZoom.Caption             := '1,000';
      MapWindow.PanelGrid.Caption             := '8';
      CASE MAP_TYPE OF
    { //  MT_NO : MapWindow.PanelMapType.Caption  := 'Nor';  }
       MT_NO : MapWindow.Panel1MapType.Caption := 'Normal';{ //added DL 12/nov/96 }
    { //  MT_LI : MapWindow.PanelMapType.Caption  := 'Lig'; }
       MT_LI : MapWindow.Panel1MapType.Caption := 'Lights'; {//added DL 12/nov/96 }
    { //  MT_DM : MapWindow.PanelMapType.Caption  := 'Dam'; }
       MT_DM : MapWindow.Panel1MapType.Caption := 'Damage';{// added DL 12/nov/96 }
    { //  MT_2A : MapWindow.PanelMapType.Caption  := '2 A'; }
       MT_2A : MapWindow.Panel1MapType.Caption := '2 Alts'; {// added DL 12/nov/96 }
    { //  MT_SP : MapWindow.PanelMapType.Caption  := 'S&&P'; }
       MT_SP : MapWindow.Panel1MapType.Caption := 'Skies%Pits';{// added DL 12/nov/96 }
   { //  MT_SF : MapWindow.PanelMapType.Caption  := 'Sector Fill'; }
       MT_SF : MapWindow.Panel1MapType.Caption := 'Sector Fill';{// added Karjala 17/Jul/2021 }
      END;
    end
  else
    begin
      MapWindow.PanelLayer.Caption       := '';
      MapWindow.PanelOBLayer.Caption     := '';
      MapWindow.Panel1OBLayer.Caption    := '';  {// added DL 12/nov/96}
      MapWindow.PanelZoom.Caption        := '';
      MapWindow.PanelGrid.Caption        := '';
      MapWindow.PanelMapType.Caption     := '';
      MapWindow.Panel1MapType.Caption    := '';{// added DL 12/nov/96}
    end;
end;

function  GetSectorNumFromName(Name : String; VAR Num : Integer) : Boolean;
var
  TheSector           : TSector;
  s, sec              : Integer;
begin
  sec := -1;
  for s := 0 to MAP_SEC.Count - 1 do
   begin
    TheSector := TSector(MAP_SEC.Objects[s]);
    if AnsiLowerCase(TheSector.Name) = AnsiLowerCase(Name) then
     begin
      sec := s;
      break;
     end;
   end;

  if sec = -1 then
   Result := FALSE
  else
   begin
    Num := Sec;
    Result := TRUE;
   end;
end;

function  GetSectorNumFromNameNoCase(Name : String; VAR Num : Integer) : Boolean;
var
  TheSector           : TSector;
  s, sec              : Integer;
begin
  sec := -1;
  for s := 0 to MAP_SEC.Count - 1 do
   begin
    TheSector := TSector(MAP_SEC.Objects[s]);
    if Uppercase(TheSector.Name) = Uppercase(Name) then
     begin
      sec := s;
      break;
     end;
   end;

  if sec = -1 then
   Result := FALSE
  else
   begin
    Num := Sec;
    Result := TRUE;
   end;
end;

function  GetNearestSC(X, Z : Real; VAR ASector : Integer; ignore_layer : boolean = False) : Boolean;
var
  TheSector           : TSector;
  TheSector2          : TSector;
  TheWall             : TWall;
  LVertex, RVertex    : TVertex;
  s, w, its, itw      : Integer;
  x1, z1, x2, z2,
  dd, a1, b1, a2, b2  : Real;
  dmin, cal           : Real;
  xx, xi, zi          : Real;
  ox, oz,
  deltax, deltaz,
  dx, dz, gx, gz      : Real;
  dist_d, dist_g      : Real;
begin
 dmin := 999999.0;
 its  := -1;

 // Count backwards to capture subsectors first
 // Hacks R' Us!
 for s := MAP_SEC.Count - 1 downto 0 do
  begin

   TheSector := TSector(MAP_SEC.Objects[s]);
   if (TheSector.Layer = LAYER) or ignore_layer then
    begin


     // Quick polgygon check
    if IsPointInSector(s, x, z) and (s <> SC_HILITE) then
       begin
         its := s;
         break;
       end;

     for w := 0 to TheSector.Wl.Count - 1 do
      begin
       TheWall := TWall(TheSector.Wl.Objects[w]);

       
       LVertex := TVertex(TheSector.Vx.Objects[TheWall.left_vx]);
       RVertex := TVertex(TheSector.Vx.Objects[TheWall.right_vx]);
       x1      := LVertex.X;
       z1      := LVertex.Z;
       x2      := RVertex.X;
       z2      := RVertex.Z;
       if z1 <> z2 then { if not HORIZONTAL }
        begin
         if x1 = x2 then { if VERTICAL}
          begin
           xi := x1;
          end
         else
          begin
           dd := (z1 - z2) / (x1 - x2);
           xi := (z + dd * x1 - z1) / dd;
          end; {if VERTICAL}

         if (z >= real_min(z1, z2)) and (z <= real_max(z1, z2)) then { if intersection on wall }
          begin
            cal    := abs(xi - x);
            { a test on the orientation of the wall }
            ox     := (x1 + x2) / 2;
            oz     := (z1 + z2) / 2;
            deltax := x1 - x2;
            deltaz := z1 - z2;
            dx     := ox - deltaz;
            dz     := oz + deltax;
            gx     := ox + deltaz;
            gz     := oz - deltax;
            dist_d := (dx - x) * (dx - x) + (dz - z) * (dz - z);
            dist_g := (gx - x) * (gx - x) + (gz - z) * (gz - z);
            { must be <= to give adjoins a chance ! }
            if cal <= dmin then
             begin
              if dist_d > dist_g then
               begin
                if TheWall.Adjoin <> -1 then
                 begin
                  its := TheWall.Adjoin;
                  { adjoin could be on wrong layer! }
                  TheSector2 := TSector(MAP_SEC.Objects[its]);
                  if TheSector2.layer <> LAYER then its := -1;
                  dmin := cal;
                 end
                else
                 begin
                  its  := -1;
                  dmin := cal;
                 end;
               end
              else
               begin
                its     := s;
                dmin    := cal;
               end;
             end;
          end; { if intersection on wall }
        end; { if not HORIZONTAL }
      end; { for WALLS }
    end; { if LAYER }
  end; { for SECTORS }

 if its <> -1 then
  begin
   ASector := its;
   GetNearestSC := TRUE;
  end
 else
  begin
   GetNearestSC := FALSE;
  end;
end;


function  GetNearestWL(X, Z : Real; VAR ASector : Integer; VAR AWall : Integer) : Boolean;
var
  TheSector           : TSector;
  TheWall             : TWall;
  LVertex, RVertex    : TVertex;
  w, itw              : Integer;
  x1, z1, x2, z2,
  dd                  : Real;
  dmin, cal           : Real;
  xi, zi              : Real;
  Sector              : Integer;
  offset              : Real;
begin
 dmin := 9999999.0;
 itw  := -1;
 if GetNearestSC(X, Z, sector) then
  begin
   TheSector := TSector(MAP_SEC.Objects[sector]);
   for w := 0 to TheSector.Wl.Count - 1 do
    begin
     TheWall := TWall(TheSector.Wl.Objects[w]);
     LVertex := TVertex(TheSector.Vx.Objects[TheWall.left_vx]);
     RVertex := TVertex(TheSector.Vx.Objects[TheWall.right_vx]);
     x1      := LVertex.X;
     z1      := LVertex.Z;
     x2      := RVertex.X;
     z2      := RVertex.Z;

     // This kinda fixes the walls you are unable to click due to low z-delta
     if ((abs(z2-z1) < 1.0) and (z2<>z1)) then
       begin
         if z1 > z2 then
          begin
           z1 := z1 + (1 * scale);
           z2 := z2 - (1 * scale);
          end
         else
          begin
           z1 := z1 - (1 *scale);
           z2 := z2 + (1 *scale);
          end;
       end;

     if z1 <> z2 then { if not HORIZONTAL }
      begin
       if x1 = x2 then { if VERTICAL}
        begin
         xi := x1;
        end
       else
        begin
           dd := (z1 - z2) / (x1 - x2);
           xi := (z + dd * x1 - z1) / dd;
        end; {if VERTICAL}

       if (z >= real_min(z1, z2)) and (z <= real_max(z1, z2)) then { if intersection on wall }
        begin
         cal    := abs(xi - x);
         if cal <= dmin then
          begin
           dmin := cal;
           itw  := w;
          end;
        end;
      end { if not HORIZONTAL }
     else { if HORIZONTAL }
      begin
       zi := z1;
       if (x >= real_min(x1, x2)) and (x <= real_max(x1, x2)) then
        begin
         cal    := abs(zi - z);
         if cal <= dmin then
          begin
           dmin := cal;
           itw  := w;
          end;
        end;
      end; { if HORIZONTAL }
    end;
   ASector      := Sector;
   AWall        := itw;
   GetNearestWL := TRUE
  end
 else
  GetNearestWL := FALSE;
end;


function  GetNearestVX(X, Z : Real; VAR ASector : Integer; VAR AVertex : Integer) : Boolean;
var
  TheSector           : TSector;
  TheVertex           : TVertex;
  s, v, its, itv      : Integer;
  cal, dmin           : Real;
begin
 dmin := 99999;
 its  := -1;

 for s := 0 to MAP_SEC.Count - 1 do
  begin
   TheSector := TSector(MAP_SEC.Objects[s]);
   if TheSector.Layer = LAYER then
    begin
     for v := 0 to TheSector.Vx.Count - 1 do
      begin
       TheVertex := TVertex(TheSector.Vx.Objects[v]);
       cal       := (TheVertex.X - X) * (TheVertex.X - X)
                  + (TheVertex.Z - Z) * (TheVertex.Z - Z);
       if cal < dmin then
        begin
         dmin := cal;
         its  := s;
         itv  := v;
        end;
      end;
    end;
  end;

 if its <> -1 then
  begin
   ASector := its;
   AVertex := itv;
   GetNearestVX := TRUE;
  end
 else
  GetNearestVX := FALSE;
end;

function  GetNearestOB(X, Z : Real; VAR AObject : Integer) : Boolean;
var
  TheObject           : TOB;
  TheSector           : TSector;
  TheLayer            : Integer;
  o, ito              : Integer;
  cal, dmin           : Real;
begin
 dmin := 99999;
 ito  := -1;

 for o := 0 to MAP_OBJ.Count - 1 do
  begin
   TheObject := TOB(MAP_OBJ.Objects[o]);
   if not DifficultyOk(TheObject.Diff) then continue;
   if TheObject.Sec <> -1 then
    begin
     TheSector := TSector(MAP_SEC.Objects[TheObject.Sec]);
     TheLayer  := TheSector.Layer;
    end
   else
    TheLayer := 9999;
   if (TheLayer = LAYER) or (TheLayer = 9999) then
    begin
       cal       := (TheObject.X - X) * (TheObject.X - X)
                  + (TheObject.Z - Z) * (TheObject.Z - Z);
       if cal < dmin then
        begin
         dmin := cal;
         ito  := o;
        end;
    end;
  end;

 if ito <> -1 then
  begin
   AObject := ito;
   GetNearestOB := TRUE;
  end
 else
  GetNearestOB := FALSE;
end;

function  GetNextNearestVX(X, Z : Real; VAR ASector : Integer; VAR AVertex : Integer) : Boolean;
var
  TheSector           : TSector;
  TheVertex           : TVertex;
  s, v, its, itv      : Integer;
  cal, dmin           : Real;
begin
 dmin := 99999;
 its  := -1;

 for s := 0 to MAP_SEC.Count - 1 do
  begin
   TheSector := TSector(MAP_SEC.Objects[s]);
   if TheSector.Layer = LAYER then
    begin
     for v := 0 to TheSector.Vx.Count - 1 do
      begin
       TheVertex := TVertex(TheSector.Vx.Objects[v]);
       cal       := (TheVertex.X - X) * (TheVertex.X - X)
                  + (TheVertex.Z - Z) * (TheVertex.Z - Z);
       if cal < dmin then
        begin
         if (s <> SC_HILITE) or (v <> VX_HILITE) then
         dmin := cal;
         its  := s;
         itv  := v;
        end;
      end;
    end;
  end;

 if its <> -1 then
  begin
   ASector := its;
   AVertex := itv;
   GetNextNearestVX := TRUE;
  end
 else
  GetNextNearestVX := FALSE;
end;



function  GetWLfromLeftVX(sector, leftvx : Integer; VAR AWallNum : Integer) : Boolean;
var TheWall   : TWall;
    w, itw    : Integer;
    TheSector : TSector;
begin
 itw := -1;
 TheSector := TSector(MAP_SEC.Objects[sector]);
 for w := 0 to TheSector.Wl.Count - 1 do
  begin
   TheWall := TWall(TheSector.Wl.Objects[w]);
   if TheWall.left_vx = leftvx then itw := w;
  end;

 if itw <> -1 then
  begin
   AWallNum := itw;
   GetWLfromLeftVX := TRUE;
  end
 else
  GetWLfromLeftVX := FALSE;
end;

function  GetWLfromRightVX(sector, rightvx : Integer; VAR AWallNum : Integer) : Boolean;
var TheWall   : TWall;
    w, itw    : Integer;
    TheSector : TSector;
begin
 itw := -1;
 TheSector := TSector(MAP_SEC.Objects[sector]);
 for w := 0 to TheSector.Wl.Count - 1 do
  begin
   TheWall := TWall(TheSector.Wl.Objects[w]);
   if TheWall.right_vx = rightvx then itw := w;
  end;

 if itw <> -1 then
  begin
   AWallNum := itw;
   GetWLfromRightVX := TRUE;
  end
 else
  GetWLfromRightVX := FALSE;
end;

function IsPointInSector(sc : integer; x, z : real): Boolean;
var i : integer;
    TheSector : TSector;
    rgn : HRGN;
begin

  Result := True;
  TheSector := TSector(MAP_SEC.Objects[sc]);


  // Create region of sector verteces.
  //SetLength(secPolygon, TheSector.Vx.Count);
  for i:= 0 to TheSector.Vx.Count - 1 do
    secPolygon[i] := VxToPoint(TVertex(TheSector.Vx.objects[i]));

  rgn := CreatePolygonRgn(secPolygon[0], TheSector.Vx.Count, WINDING);

  // We don't want the subsector to be sticking outside the walls
  if not PtInRegion(rgn, trunc(m2sx(X)), trunc(m2sz(Z))) then
    Result := False;
  DeleteObject(rgn);

end;

procedure LayerAllObjects;
var o         : Integer;
    TheObject : TOB;
    OldCursor : HCursor;
begin
 OldCursor  := SetCursor(LoadCursor(0, IDC_WAIT));
 {handle progress window}
 ProgressWindow.Show;
 ProgressWindow.Progress1.Update;
 ProgressWindow.Progress1.Caption := 'Layering OBJECTS';
 ProgressWindow.Gauge.MinValue    := 0;
 ProgressWindow.Gauge.MaxValue    := MAP_OBJ.Count - 1;
 ProgressWindow.Gauge.Progress    := 0;
 ProgressWindow.Progress2.Caption := 'Layering ...';
 ProgressWindow.Progress2.Update;
 ProgressWindow.Update;

 for o := 0 to MAP_OBJ.Count - 1 do
  begin
   TheObject := TOB(MAP_OBJ.Objects[o]);
     if TheObject.Sec = -1 then LayerObject(o);
     if o mod 10 = 0 then
      ProgressWindow.Gauge.Progress := ProgressWindow.Gauge.Progress + 9;
  end;
  ProgressWindow.Hide;
  SetCursor(OldCursor);
end;

procedure LayerAllObjectsNoProgress;
var o         : Integer;
    TheObject : TOB;
begin
 for o := 0 to MAP_OBJ.Count - 1 do
  begin
   TheObject := TOB(MAP_OBJ.Objects[o]);
   if TheObject.Sec = -1 then LayerObject(o);
  end;
end;

function  LayerObject(obnum : Integer) : Boolean;
var sc        : Integer;
    TheObject : TOB;
begin
 sc := -1;
 if obnum = 360 then
    log.info('wtf', Logname);
 TheObject := TOB(MAP_OBJ.Objects[obnum]);
 if GetObjectSC(obnum, sc) then
  begin
   TheObject.Sec := sc;
   MODIFIED := TRUE;
   LayerObject := TRUE;
  end
 else
  begin
   LayerObject := FALSE;
  end;
end;

function  GetObjectSC(obnum : Integer; VAR ASector : Integer) : Boolean;
var l, sc     : Integer;
    TheObject : TOB;
    TheSector : TSector;
    found     : Boolean;
    oldLAYER  : Integer;
begin
  TheObject := TOB(MAP_OBJ.Objects[obnum]);
  Found     := FALSE;
  oldLAYER  := LAYER;

  for l := LAYER_MIN to LAYER_MAX do
   begin
     LAYER := l;
     if GetNearestSC(TheObject.X, TheObject.Z, sc) then
      begin
       TheSector := TSector(MAP_SEC.Objects[sc]);
       if (TheObject.Y >= TheSector.Floor_Alt) and (TheObject.Y <= TheSector.Ceili_Alt) then
        begin
         ASector := sc;
         Found   := TRUE;
         break;
        end;
      end;
   end;

  LAYER    := oldLAYER;
  GetObjectSC := Found;
end;

function ForceLayerObject(ob : Integer) : Boolean;
var l, sc      : Integer;
    TheObject  : TOB;
    TheSector  : TSector;
    TheSector2 : TSector;
    oldLAYER   : Integer;
begin
  TheObject := TOB(MAP_OBJ.Objects[ob]);
  Result    := FALSE;
  TheObject.Sec := -1;

  { make this two pass : first search in current layer,
    then in all the others }

  if GetNearestSC(TheObject.X, TheObject.Z, sc) then
   begin
    TheSector := TSector(MAP_SEC.Objects[sc]);
    if OBLAYERMODE = 1 then
     TheObject.Y   := TheSector.Floor_Alt
    else if OBLAYERMODE = 2 then
     TheObject.Y   := TheSector.Ceili_Alt
    else
     begin
      if (TheObject.Y < TheSector.Floor_Alt) or
         (TheObject.Y > TheSector.Ceili_Alt) then
       TheObject.Y   := TheSector.Floor_Alt
     end;
    TheObject.Sec := sc;
    Result := TRUE;
    exit;
   end;

  oldLAYER  := LAYER;
  for l := LAYER_MIN to LAYER_MAX do
   begin
     if l = oldLAYER then continue;
     LAYER := l;
     if GetNearestSC(TheObject.X, TheObject.Z, sc) then
      begin
       TheSector := TSector(MAP_SEC.Objects[sc]);
       if OBLAYERMODE = 1 then
        TheObject.Y   := TheSector.Floor_Alt
       else if OBLAYERMODE = 2 then
        TheObject.Y   := TheSector.Ceili_Alt
       else
        begin
         if (TheObject.Y < TheSector.Floor_Alt) or
            (TheObject.Y > TheSector.Ceili_Alt) then
          TheObject.Y   := TheSector.Floor_Alt
        end;
       TheObject.Sec := sc;
       Result := TRUE;
       break;
      end;
   end;
  LAYER  := oldLAYER;
end;

function MultiForceLayerObject : Integer;
var m, o      : Integer;
    OldCursor : HCursor;
begin
Result := 0;
OldCursor  := SetCursor(LoadCursor(0, IDC_WAIT));
if OB_MULTIS.Count <> 0 then
 for m := 0 to OB_MULTIS.Count - 1 do
  begin
   o := StrToInt(Copy(OB_MULTIS[m],5,4));
   if ForceLayerObject(o) then Inc(Result);
  end;
SetCursor(OldCursor);
end;

// Quickly check if vertices are at identical pos
function DO_SameVXPosition(left, right : TVertex) : Boolean;
begin
  Result := False;
  if (left.X = right.X) and (left.Z = right.Z) then Result := True;
end;

procedure DO_MarkAdjacentVertices(sc, wl : integer; rootvx : TVertex);
var i,j,m     : Integer;
    TheSector : TSector;
    TheSector2: TSector;
    TheVertex : TVertex;
    TheVertex2: TVertex;
    TheVertex3: TVertex;
    TheWall   : TWall;
    TheWall2  : TWall;
    TheObject : TOB;
    SectorID  : Integer;
    WallID    : Integer;
    VXID      : Integer;
begin
  TheSector := TSector(MAP_SEC.Objects[sc]);

  if TheSector.Layer <> Layer then exit;

  TheWall  := TWall(TheSector.Wl.Objects[wl]);

  if TheWall.adjoin = -1 then exit;

  TheSector2 := TSector(MAP_SEC.Objects[TheWall.adjoin]);
  TheWall2   := TWall(TheSector2.wl.Objects[TheWall.Mirror]);

  // Check Left
  TheVertex := TVertex(TheSector2.vx.Objects[TheWall2.left_vx]);
  if (TheVertex.mark <> 2) and DO_SameVXPosition(TheVertex, rootvx) then
    begin
      TheVertex.mark := 2;
      if not ShowCaseModSC.ContainsInt(TheWall.adjoin) then ShowCaseModSC.put(TheWall.adjoin);

      // Recurse from Left
      if GetWLfromRightVX(TheWall.adjoin, TheWall2.left_vx, WallID) then
          DO_MarkAdjacentVertices(TheWall.adjoin , WallID, rootvx);
    end;

  // Check Right
  TheVertex := TVertex(TheSector2.vx.Objects[TheWall2.right_vx]);
  if (TheVertex.mark <> 2) and DO_SameVXPosition(TheVertex, rootvx) then
    begin
      TheVertex.mark := 2;
      if not ShowCaseModSC.ContainsInt(TheWall.adjoin) then ShowCaseModSC.put(TheWall.adjoin);

      // Recurse from Right
      if GetWLfromLeftVX(TheWall.adjoin, TheWall2.right_vx, WallID) then
          DO_MarkAdjacentVertices(TheWall.adjoin , WallID, rootvx);
    end;

end;

procedure DO_TranslateVertex(sc,vx : Integer; x,z : Real);
var i,j,m     : Integer;
    TheSector : TSector;
    TheSector2: TSector;
    TheVertex : TVertex;
    TheVertex2: TVertex;
    TheVertex3: TVertex;
    TheWall   : TWall;
    TheWall2  : TWall;
    TheObject : TOB;
    SectorID  : Integer;
    WallID    : Integer;
    VXID      : Integer;
begin

    TheSector := TSector(MAP_SEC.Objects[sc]);
    TheVertex  := TVertex(TheSector.Vx.Objects[vx]);
    TheVertex.mark := 2;


    // Check Adjacent on Right
    if GetWLfromLeftVX(sc, vx, WallID) then
       DO_MarkAdjacentVertices(sc, WallID, TheVertex);

    // Check Adjacent on Left
    if GetWLfromRightVX(sc, vx, WallID) then
       DO_MarkAdjacentVertices(sc, WallID, TheVertex);

   {

    // Mark all vertices that match the hilighted one
    for i := 0 to MAP_SEC.Count - 1 do
      begin

       TheSector2 := TSector(MAP_SEC.Objects[i]);
       if TheSector2.layer = LAYER then
         begin
           for j := 0 to TheSector2.Vx.Count - 1 do
            begin
             // Don't look at yourself
             if (SC_HILITE = i) and (VX_HILITE = j)  then continue;

             TheVertex2      := TVertex(TheSector2.Vx.Objects[j]);

             // Make sure the positiosn are the same
             if (TheVertex2.X = TheVertex.X) and (TheVertex2.Z = TheVertex.Z)  then
              begin
                // Do not move vertices
                if sc = i  then

                TheVertex2.mark := 2;
                if not ShowCaseModSC.ContainsInt(i) then ShowCaseModSC.put(i);
              end;
            end;
         end;
      end;
    }

    // Update the new position for the initial vertex
    {TheVertex.X := RoundTo(TheVertex.X + x, -2);
    TheVertex.Z := RoundTo(TheVertex.Z + z, -2);

    // Now update the positions of all the adjoined ones.
    for i := 0 to MAP_SEC.Count - 1 do
      begin
       if (SC_HILITE = i) and (VX_HILITE = j)  then continue;
       TheSector2 := TSector(MAP_SEC.Objects[i]);
       for j := 0 to TheSector2.Vx.Count - 1 do
        begin
         TheVertex2      := TVertex(TheSector2.Vx.Objects[j]);
         if TheVertex2.mark = 2 then
          begin
            TheVertex2.X := TheVertex.X;
            TheVertex2.Z := TheVertex.Z;
            TheVertex2.mark := 0;
          end;
        end;
      end;
    TheVertex.mark := 0; }
end;

procedure DO_ProcessMarkedVX(x,z : Real);
var TheSector : TSector;
    TheVertex : TVertex;
    i,j : integer;
begin

    // Now update the positions of all the marked ones

    for i := 0 to MAP_SEC.Count - 1 do
      begin
       TheSector := TSector(MAP_SEC.Objects[i]);
       for j := 0 to TheSector.Vx.Count - 1 do
        begin
         TheVertex      := TVertex(TheSector.Vx.Objects[j]);
         if TheVertex.mark = 2 then
          begin
            TheVertex.X := RoundTo(TheVertex.X + x, -2);
            TheVertex.Z := RoundTo(TheVertex.Z + z, -2);
            TheVertex.mark := 0;
          end;
        end;
      end;
end;

procedure DO_Translate_SelMultiSel(x, z : Real);
var i,j,m     : Integer;
    TheSector : TSector;
    TheSector2: TSector;
    TheVertex : TVertex;
    TheVertex2: TVertex;
    TheWall   : TWall;
    TheWall2  : TWall;
    TheObject : TOB;
    SectorID  : Integer;
    WallID    : Integer;
    VXID      : Integer;
begin

 // Log.Info('X = '  + PosTrim(x) + ' Z = ' + PosTrim(Z), LogName);

  // NO OP
  if (x = 0) and (z = 0) then exit;

  x := RoundTo(x, -2);
  z := RoundTo(z, -2);

 {First clear all the VX marks}
 for i := 0 to MAP_SEC.Count - 1 do
  begin
   TheSector := TSector(MAP_SEC.Objects[i]);
   for j := 0 to TheSector.Vx.Count - 1 do
    begin
     TheVertex      := TVertex(TheSector.Vx.Objects[j]);
     TheVertex.Mark := 0;
    end;
  end;

 CASE MAP_MODE of
  MM_SC : begin
            {include the multiselection}
            for m := 0 to SC_MULTIS.Count - 1 do
              begin
               SectorID := StrToInt(Copy(SC_MULTIS[m],1,4));
               TheSector := TSector(MAP_SEC.Objects[SectorID]);
               for i := 0 to TheSector.Vx.Count - 1 do
                begin
                  DO_TranslateVertex(SectorID, i, x,z);
                  if not ShowCaseModSC.ContainsInt(SectorID) then ShowCaseModSC.put(SectorID);
                end;
              end;
            if SC_MULTIS.Count = 0 then
               begin
                 TheSector := TSector(MAP_SEC.Objects[SC_HILITE]);
                 for i := 0 to TheSector.Vx.Count - 1 do
                    DO_TranslateVertex(SC_HILITE, i, x,z );
               end;

          end;
  MM_WL : begin

            {include the multiselection and its mirrors}
            for m := 0 to WL_MULTIS.Count - 1 do
              begin
               SectorID       := StrToInt(Copy(WL_MULTIS[m],1,4));
               TheSector      := TSector(MAP_SEC.Objects[SectorID]);
               TheWall        := TWall(TheSector.Wl.Objects[StrToInt(Copy(WL_MULTIS[m],5,4))]);

               DO_TranslateVertex(SectorID, TheWall.left_vx, x,z);
               DO_TranslateVertex(SectorID, TheWall.right_vx, x,z);
               if not ShowCaseModSC.ContainsInt(SectorID) then ShowCaseModSC.put(SectorID);
              end;

            if WL_MULTIS.Count = 0 then
              begin
                 TheSector      := TSector(MAP_SEC.Objects[SC_HILITE]);
                 TheWall        := TWall(TheSector.Wl.Objects[WL_HILITE]);
                 DO_TranslateVertex(SC_HILITE, TheWall.left_vx, x,z);
                 DO_TranslateVertex(SC_HILITE, TheWall.right_vx, x,z);
              end;

          end;
  MM_VX : begin

            // Handle Multi  - modern rewrite
            for m := 0 to VX_MULTIS.Count - 1 do
              begin
               SectorID := StrToInt(Copy(VX_MULTIS[m],1,4));
               TheSector := TSector(MAP_SEC.Objects[SectorID]);
               if not ShowCaseModSC.ContainsInt(SectorID) then ShowCaseModSC.put(SectorID);
               VXID := StrToInt(Copy(VX_MULTIS[m],5,4));
               DO_TranslateVertex(SectorID, VXID, x,z);
              end;

           if VX_MULTIS.Count = 0 then
             DO_TranslateVertex(SC_HILITE, VX_HILITE, x,z);
          end;
  MM_OB : begin
            for m := 0 to OB_MULTIS.Count - 1 do
              begin
               TheObject := TOB(MAP_OBJ.Objects[StrToInt(Copy(OB_MULTIS[m],5,4))]);
               TheObject.X := TheObject.X + x;
               TheObject.Z := TheObject.Z + z;
              end;
             {if sel not in multisel then process it}
             TheObject := TOB(MAP_OBJ.Objects[OB_HILITE]);
             if OB_MULTIS.IndexOf(Format('%4d%4d', [TheObject.Sec, OB_HILITE])) = - 1 then
              begin
               TheObject := TOB(MAP_OBJ.Objects[OB_HILITE]);
               TheObject.X := TheObject.X + x;
               TheObject.Z := TheObject.Z + z;
              end;
          end;
 END;

  // Update Marked ones
 if MAP_MODE <> MM_OB then DO_ProcessMarkedVX(x,z);

 MODIFIED := TRUE;
end;

procedure DO_Select_In_Rect;
var i,j       : Integer;
    TheSector : TSector;
    TheVertex : TVertex;
    TheWall   : TWall;
    TheObject : TOB;
    p         : TPoint;
    tmp       : Integer;
    TheLayer  : Integer;
    allin     : Boolean;
begin

 if FOCUSRECT.right < FOCUSRECT.left then
  begin
   tmp := FOCUSRECT.right;
   FOCUSRECT.right := FOCUSRECT.left;
   FOCUSRECT.left := tmp;
  end;

 if not IsRectEmpty(FOCUSRECT) then
  begin
   MULTISEL_RECT := True;
   case MAP_MODE of
     MM_SC : begin
               for i := 0 to MAP_SEC.Count - 1 do
                begin
                 allin := TRUE;
                 TheSector := TSector(MAP_SEC.Objects[i]);
                 if (TheSector.Layer = LAYER) or SHADOW then
                  begin
                  for j := 0 to TheSector.Vx.Count - 1 do
                   begin
                    TheVertex := TVertex(TheSector.Vx.Objects[j]);
                    p.X       := M2SX(TheVertex.X);
                    p.Y       := M2SZ(TheVertex.Z);
                    If not PtInRect(FOCUSRECT, p) then
                     begin
                      allin := FALSE;
                      break;
                     end;
                   end;
                  if allin then DO_Multisel_SC(i);
                  end;
                end;
             end;
     MM_WL : begin
               for i := 0 to MAP_SEC.Count - 1 do
                begin
                 TheSector := TSector(MAP_SEC.Objects[i]);
                 if (TheSector.Layer = LAYER) or SHADOW then
                  begin
                   for j := 0 to TheSector.Wl.Count - 1 do
                    begin
                     allin     := TRUE;
                     TheWall   := TWall(TheSector.Wl.Objects[j]);
                     TheVertex := TVertex(TheSector.Vx.Objects[TheWall.left_vx]);
                     p.X       := M2SX(TheVertex.X);
                     p.Y       := M2SZ(TheVertex.Z);
                     If not PtInRect(FOCUSRECT, p) then allin := FALSE;
                     TheVertex := TVertex(TheSector.Vx.Objects[TheWall.right_vx]);
                     p.X       := M2SX(TheVertex.X);
                     p.Y       := M2SZ(TheVertex.Z);
                     If not PtInRect(FOCUSRECT, p) then allin := FALSE;
                     if allin then DO_Multisel_WL(i, j);
                    end;
                  end;
                end;
             end;
     MM_VX : begin
               for i := 0 to MAP_SEC.Count - 1 do
                begin
                 TheSector := TSector(MAP_SEC.Objects[i]);
                 if (TheSector.Layer = LAYER) or SHADOW then
                 for j := 0 to TheSector.Vx.Count - 1 do
                  begin
                   TheVertex := TVertex(TheSector.Vx.Objects[j]);
                   p.X       := M2SX(TheVertex.X);
                   p.Y       := M2SZ(TheVertex.Z);
                   If PtInRect(FOCUSRECT, p) then DO_Multisel_VX(i, j);
                  end;
                end;
             end;
     MM_OB : begin
               for i := 0 to MAP_OBJ.Count - 1 do
                begin
                  TheObject := TOB(MAP_OBJ.Objects[i]);
                  if TheObject.Sec <> -1 then
                   begin
                    TheSector := TSector(MAP_SEC.Objects[TheObject.Sec]);
                    TheLayer  := TheSector.Layer;
                   end
                  else
                   begin
                    TheLayer := 9999;
                   end;
                  if ((TheLayer = LAYER) or (TheLayer = 9999) or SHADOW) then
                   begin
                    p.X       := M2SX(TheObject.X);
                    p.Y       := M2SZ(TheObject.Z);
                    If PtInRect(FOCUSRECT, p) then DO_Multisel_OB(i);
                   end;
                end;
             end;
   end;
  MULTISEL_RECT := False;
  {Update the multiselection markers}
  case MAP_MODE of
    MM_SC : begin
             if SC_MULTIS.Count <> 0 then
              SectorEditor.ShapeMulti.Brush.Color := clRed
             else
              SectorEditor.ShapeMulti.Brush.Color := clBtnFace;
             MapWindow.PanelMulti.Caption := IntToStr(SC_MULTIS.Count);
            end;
    MM_WL : begin
             if WL_MULTIS.Count <> 0 then
              WallEditor.ShapeMulti.Brush.Color := clRed
             else
              WallEditor.ShapeMulti.Brush.Color := clBtnFace;
             MapWindow.PanelMulti.Caption := IntToStr(WL_MULTIS.Count);
            end;
    MM_VX : begin
{             if VX_MULTIS.Count <> 0 then
              VertexEditor.ShapeMulti.Brush.Color := clRed
             else
              VertexEditor.ShapeMulti.Brush.Color := clBtnFace;}
             MapWindow.PanelMulti.Caption := IntToStr(VX_MULTIS.Count);
            end;
    MM_OB : begin
             if OB_MULTIS.Count <> 0 then
              ObjectEditor.ShapeMulti.Brush.Color := clRed
             else
              ObjectEditor.ShapeMulti.Brush.Color := clBtnFace;
             MapWindow.PanelMulti.Caption := IntToStr(OB_MULTIS.Count);
            end;
  end;
  MapWindow.Map.Invalidate;
  end;
end;

function GetNearestGridPoint(X, Z : Real; VAR GX, GZ : Real) : Boolean;
var tx, tz : Real;
begin
 if GridON then
  begin
   {add half a grid cell}
   tx := X + Grid / 2;
   tz := Z + Grid / 2;

   {find bottom left grid point for this point}
   GX := Grid * Trunc(tx / Grid);
   GZ := Grid * Trunc(tz / Grid);

   {but the method for finding it is slightly different in negative areas!}
   if X < -Grid / 2.0 then GX := GX - Grid;
   if Z < -Grid / 2.0 then GZ := GZ - Grid;

   GetNearestGridPoint := TRUE;
  end
 else
  GetNearestGridPoint := FALSE;
end;

procedure DO_Find_SC_By_Name;
var s         : Integer;
    TheSector : TSector;
    TheVertex : TVertex;
begin
 FINDSC_VALUE := '';

 // Put the logic in FIND
 Application.CreateForm(TToolsFind, FindWindow);
 FindWindow.ShowModal;
 FindWindow.Destroy;

end;

procedure DO_Find_WL_Adjoin;
var TheSector : TSector;
    TheWall   : TWall;
begin
 TheSector := TSector(MAP_SEC.Objects[SC_HILITE]);
 TheWall   := TWall(TheSector.Wl.Objects[WL_HILITE]);
 if (TheWall.Adjoin > -1) and (TheWall.Mirror > -1) then
  if TheWall.Adjoin < MAP_SEC.Count then
   begin
    TheSector := TSector(MAP_SEC.Objects[TheWall.Adjoin]);
    if TheWall.Mirror < TheSector.Wl.Count then
     begin
      SC_HILITE := TheWall.Adjoin;
      WL_HILITE := TheWall.Mirror;
      DO_Fill_WallEditor;
      MapWindow.Map.Invalidate;
     end;
   end;
end;

function DO_Find_PlayerStart(update_player : boolean = true) : Integer;
var TheObject : TOB;
    o,s       : Integer;
begin
 RESULT := -1;
 for o := 0 to MAP_OBJ.Count - 1 do
   begin
    TheObject := TOB(MAP_OBJ.Objects[o]);
    if TheObject.Seq.Count <> 0 then
     for s := 0 to TheObject.Seq.Count - 1 do
      begin
       if Pos('EYE:', UpperCase(TheObject.Seq[s])) <> 0 then
        begin
         if update_player then
           begin
             OB_HILITE := o;
             DO_Fill_ObjectEditor;
             MapWindow.SetXOffset(Round(TheObject.X));
             MapWindow.SetZOffset(Round(TheObject.Z));
             MapWindow.Map.Invalidate;
           end
         else
           RESULT :=  o;
         break;
        end;
      end;
   end;
end;

procedure DO_Find_VX_AtSameCoords;
var TheVertex : TVertex;
    TheSector : TSector;
begin
 TheSector  := TSector(MAP_SEC.Objects[SC_HILITE]);
 TheVertex  := TVertex(TheSector.Vx.Objects[VX_HILITE]);
 if GetNextNearestVX(TheVertex.X, TheVertex.Z, SC_HILITE, VX_HILITE) then
  begin
   DO_Fill_VertexEditor;
   MapWindow.Map.Invalidate;
  end;
end;

function  GetWLLen(sc, wl : Integer) : Real;
var
  TheSector : TSector;
  TheWall   : TWall;
  vx1, vx2  : TVertex;
begin
 TheSector := TSector(MAP_SEC.Objects[sc]);
 TheWall   := TWall(TheSector.Wl.Objects[wl]);
 vx1       := TVertex(TheSector.Vx.Objects[TheWall.left_vx]);
 vx2       := TVertex(TheSector.Vx.Objects[TheWall.right_vx]);
 Result    := sqrt(sqr(vx1.X - vx2.X)+sqr(vx1.Z - vx2.Z));
end;

function  GetWLHei(sc, wl : Integer) : Real;
var
  TheSector : TSector;
begin
 TheSector := TSector(MAP_SEC.Objects[sc]);
 Result    := TheSector.Ceili_Alt - TheSector.Floor_Alt;
end;


function  DifficultyOk(diff : Integer) : Boolean;
begin
 CASE OBDIFF OF
   0 : Result := TRUE;
   1 : if (diff=2) or (diff = 3) then
        Result := FALSE
       else
        Result := TRUE;
   2 : if (diff=-1) or (diff = 3) then
        Result := FALSE
       else
        Result := TRUE;
   3 : if (diff=-2) or (diff = -1) then
        Result := FALSE
       else
        Result := TRUE;
 END;
 if diff = 0 then Result := TRUE;
end;

procedure DO_ConsistencyChecks;
var
  TheSector  : TSector;
  TheSector2 : TSector;
  TheWall    : TWall;
  TheWall2   : TWall;
  TheObject  : TOB;
  s,w,o      : Integer;
  players    : Integer;
  complete   : Boolean;
  scnames    : TStringList;
  INFList    : TStringList;
  errmsg     : String;
  i,j,k      : Integer;
  TheINFSeq  : TINFSequence;
  TheINFCls  : TINFCls;
  headers    : Boolean;
  l1, l2     : LongInt;
  OldCursor  : HCursor;
begin
 OldCursor  := SetCursor(LoadCursor(0, IDC_WAIT));
 ChecksWindow.LBChecks.Clear;

 headers := OptionsDialog.CBChecksHeaders.Checked;

 {Geometry Consistency}
 if headers then
 ChecksWindow.LBChecks.Items.Add('===============  GEOMETRY CONSISTENCY CHECKS      ==============');

 if headers then
 ChecksWindow.LBChecks.Items.Add('---------------  Adjoin/Mirror/Walk Consistency   --------------');

 if OptionsDialog.CBChecksAMW.Checked then
 for s := 0 to MAP_SEC.Count - 1 do
  begin
   TheSector := TSector(MAP_SEC.Objects[s]);
    for w := 0 to TheSector.Wl.Count - 1 do
     begin
      TheWall := TWall(TheSector.Wl.Objects[w]);
      if TheWall.Adjoin <> -1 then
       begin
        if TheWall.Adjoin > MAP_SEC.Count - 1 then
         begin
          ChecksWindow.LBChecks.Items.Add(Format('WL %4d SC %4d    Adjoin does not exist', [w, s]));
         end
        else
         begin
          TheSector2 := TSector(MAP_SEC.Objects[TheWall.Adjoin]);
          if (TheWall.Mirror > TheSector2.Wl.Count - 1) or (TheWall.Mirror < 0) then
           begin
            ChecksWindow.LBChecks.Items.Add(Format('WL %4d SC %4d    Mirror does not exist', [w, s]));
           end
          else
           begin
            TheWall2 := TWall(TheSector2.Wl.Objects[TheWall.Mirror]);
            if TheWall2.Adjoin <> s then
             ChecksWindow.LBChecks.Items.Add(Format('WL %4d SC %4d    Reverse Adjoin is not correct', [w, s]));
            if TheWall2.Mirror <> w then
             ChecksWindow.LBChecks.Items.Add(Format('WL %4d SC %4d    Reverse Mirror is not correct', [w, s]));
           end;
         end;
       end
      else
       begin
        if not ((TheWall.Mirror = -1) and (TheWall.Walk = -1)) then
         ChecksWindow.LBChecks.Items.Add(Format('WL %4d SC %4d    Adjoin is -1, Mirror/Walk should be -1', [w, s]));
       end;
     end;
  end;

 if headers then
 ChecksWindow.LBChecks.Items.Add('---------------  Sector Checks                    --------------');

 if OptionsDialog.CBChecksSector.Checked then
 for s := 0 to MAP_SEC.Count - 1 do
  begin
   TheSector := TSector(MAP_SEC.Objects[s]);
   if TheSector.Wl.COunt <> TheSector.Vx.Count then
    ChecksWindow.LBChecks.Items.Add(Format('SC %4d            Number of VX and WL don''t match', [s]));
  end;

 for s := 0 to MAP_SEC.Count - 1 do
  begin
   TheSector := TSector(MAP_SEC.Objects[s]);
   if TheSector.Floor_Alt > TheSector.Ceili_Alt then
    ChecksWindow.LBChecks.Items.Add(Format('SC %4d            Floor higher than Ceiling', [s]));
  end;

 if headers then
 ChecksWindow.LBChecks.Items.Add('===============  OBJECTS CONSISTENCY CHECKS       ==============');

 if headers then
 ChecksWindow.LBChecks.Items.Add('---------------  Player Starts                    --------------');
 players := 0;

 if OptionsDialog.CBChecksPlayer.Checked then
 for o := 0 to MAP_OBJ.Count - 1 do
   begin
    TheObject := TOB(MAP_OBJ.Objects[o]);
    if TheObject.Seq.Count <> 0 then
     for s := 0 to TheObject.Seq.Count - 1 do
      begin
       if Pos('EYE:', UpperCase(TheObject.Seq[s])) <> 0 then
        begin
         Inc(players);
         if players > 1 then
          ChecksWindow.LBChecks.Items.Add(Format('OB %4d            Duplicate Player Start', [o]));
        end;
      end;
   end;

 if OptionsDialog.CBChecksPlayer.Checked then
 if players = 0 then
   ChecksWindow.LBChecks.Items.Add('                  Player Start is missing');

 if headers then
 ChecksWindow.LBChecks.Items.Add('---------------  Object Layering                  --------------');

 if OptionsDialog.CBChecksLayering.Checked then
 begin
  LayerAllObjects;
  for o := 0 to MAP_OBJ.Count - 1 do
    begin
     TheObject := TOB(MAP_OBJ.Objects[o]);
     if TheObject.Sec = -1 then
      ChecksWindow.LBChecks.Items.Add(Format('OB %4d            No Sector found for object', [o]));
    end;
 end;

 if headers then
 ChecksWindow.LBChecks.Items.Add('===============  INF CONSISTENCY CHECKS           ==============');

 complete := FALSE;
 scnames  := TStringList.Create;

 for s := 0 to MAP_SEC.Count - 1 do
  begin
   TheSector := TSector(MAP_SEC.Objects[s]);
   if TheSector.Name = '' then
    begin
     if OptionsDialog.CBChecksGeneral.Checked then
      if TheSector.InfItems.Count <> 0 then
       ChecksWindow.LBChecks.Items.Add(Format('sc %4d            unnamed sector with INF entry', [s]));
    end
   else
    begin
     if scnames.IndexOf(TheSector.Name) = -1 then
      scnames.Add(TheSector.name)
     else
      if OptionsDialog.CBChecksGeneral.Checked then
       ChecksWindow.LBChecks.Items.Add(Format('sc %4d            %s duplicated sector name', [s, TheSector.Name]));
    end;

   if OptionsDialog.CBChecksGeneral.Checked then
   if TheSector.Name = '__wdfuse__' then
    begin
      if TheSector.InfItems.Count <> 0 then
       ChecksWindow.LBChecks.Items.Add(Format('sc %4d            __wdfuse__ sector should be renamed', [s]));
    end;

   if OptionsDialog.CBChecksGeneral.Checked then
   if TheSector.Name = 'complete' then
    begin
     complete := TRUE;
     if TheSector.InfItems.Count = 0 then
      ChecksWindow.LBChecks.Items.Add(Format('sc %4d            complete sector has no INF entry', [s]));
    end;
  end;

 if OptionsDialog.CBChecksGeneral.Checked then
  if not complete then
   ChecksWindow.LBChecks.Items.Add('                 No "complete" sector found');

 {here are the most complicated checks}
 for s := 0 to MAP_SEC.Count - 1 do
  begin
   TheSector := TSector(MAP_SEC.Objects[s]);
   INFList := TStringList.Create;
   if ParseINFItemsSCWL(s, -1, INFList, errmsg) > -1 then
    if OptionsDialog.CBChecksParsing.Checked then
     ChecksWindow.LBChecks.Items.Add(Format('sc %4d            INF entry does not parse correctly', [s]))
   else
    begin
     {check slaclitgt}
     for i := 0 to INFList.Count - 1 do
      begin
       TheINFSeq := TINFSequence(INFList.Objects[i]);
       for j := 0 to TheINFSeq.Classes.Count - 1 do
        begin
         TheINFCls := TINFCls(TheINFSeq.Classes.Objects[j]);
         CASE TheINFCls.ClsType OF
          0 : errmsg := 'Non existent slave: ';
          1 : errmsg := 'Non existent client: ';
          2 : errmsg := 'Non existent target: ';
         END;
         for k := 0 to TheINFCls.SlaCliTgt.Count - 1 do
          if scnames.IndexOf(TheINFCls.SlaCliTgt[k]) = -1 then
           if OptionsDialog.CBChecksSCT.Checked then
            ChecksWindow.LBChecks.Items.Add(Format('sc %4d            %s %s', [s, errmsg, TheINFCls.SlaCliTgt[k]]))
        end;
      end;
    end;
   FreeINFList(INFList);

   for w := 0 to TheSector.Wl.Count - 1 do
    begin
     INFList := TStringList.Create;
     if not ((s = 2) and (w=50)) then continue;

     if ParseINFItemsSCWL(s, w, INFList, errmsg) > -1 then
      if OptionsDialog.CBChecksParsing.Checked then
       ChecksWindow.LBChecks.Items.Add(Format('wl %4d sc %4d    INF entry does not parse correctly', [w, s]))
     else
      begin
      {check slaclitgt}
       for i := 0 to INFList.Count - 1 do
        begin
         TheINFSeq := TINFSequence(INFList.Objects[i]);
         for j := 0 to TheINFSeq.Classes.Count - 1 do
          begin
           TheINFCls := TINFCls(TheINFSeq.Classes.Objects[j]);
           CASE TheINFCls.ClsType OF
            0 : errmsg := 'Non existent slave: ';
            1 : errmsg := 'Non existent client: ';
            2 : errmsg := 'Non existent target: ';
           END;
           for k := 0 to TheINFCls.SlaCliTgt.Count - 1 do
            if scnames.IndexOf(TheINFCls.SlaCliTgt[k]) = -1 then
             if OptionsDialog.CBChecksSCT.Checked then
              ChecksWindow.LBChecks.Items.Add(Format('wl %4d sc %4d    %s %s', [w, s, errmsg, TheINFCls.SlaCliTgt[k]]))
          end;
        end;
      end;
     FreeINFList(INFList);
    end;
  end;

 scnames.Free;

 {we must do this in case the user hasn't opened the Options dialog in this
  session. Stupid, but part of the "gain global" scheme}
 with OptionsDialog do
  begin
   CBChecksAMW.Checked          := Ini.ReadBool('CHECKS', 'AMW',      TRUE);
   CBChecksSector.Checked       := Ini.ReadBool('CHECKS', 'Sector',   TRUE);
   CBChecksPlayer.Checked       := Ini.ReadBool('CHECKS', 'Player',   TRUE);
   CBChecksLayering.Checked     := Ini.ReadBool('CHECKS', 'Layering', TRUE);
   CBChecksGeneral.Checked      := Ini.ReadBool('CHECKS', 'General',  TRUE);
   CBChecksParsing.Checked      := Ini.ReadBool('CHECKS', 'Parsing',  TRUE);
   CBChecksSCT.Checked          := Ini.ReadBool('CHECKS', 'SCT',      TRUE);
   CBChecksBM.Checked           := Ini.ReadBool('CHECKS', 'BM',       TRUE);
   CBChecksFME.Checked          := Ini.ReadBool('CHECKS', 'FME',      TRUE);
   CBChecksWAX.Checked          := Ini.ReadBool('CHECKS', 'WAX',      TRUE);
   CBChecks3DO.Checked          := Ini.ReadBool('CHECKS', '3DO',      TRUE);
   CBChecksVOC.Checked          := Ini.ReadBool('CHECKS', 'VOC',      TRUE);
   CBChecksHeaders.Checked      := Ini.ReadBool('CHECKS', 'Headers',  TRUE);
  end;

 if OptionsDialog.CBChecksBM.Checked or
    OptionsDialog.CBChecksFME.Checked or
    OptionsDialog.CBChecksWAX.Checked or
    OptionsDialog.CBChecks3DO.Checked or
    OptionsDialog.CBChecksVOC.Checked then
  begin
   if headers then
    ChecksWindow.LBChecks.Items.Add('===============  RESOURCES CONSISTENCY CHECKS     ==============');

   ProgressWindow.Show;
   DO_RecomputeTexturesLists(TRUE, 'Consistency Checks');
   DO_RecomputeObjectsLists(TRUE, 'Consistency Checks');
   ProgressWindow.Hide;

   if OptionsDialog.CBChecksBM.Checked then
    begin
     if headers then
      ChecksWindow.LBChecks.Items.Add('---------------  BM  - Textures                   --------------');
     for i := 0 to TX_LIST.Count - 1 do
      begin
       if not IsResourceInGOB(TEXTURESgob, TX_LIST[i], l1, l2) then
        if not FileExists(LEVELPath + '\' + TX_LIST[i]) then
         ChecksWindow.LBChecks.Items.Add('                 BM  not found : ' + TX_LIST[i]);
      end;
    end;

    if OptionsDialog.CBChecksFME.Checked then
     begin
     if headers then
      ChecksWindow.LBChecks.Items.Add('---------------  FME - Frames                     --------------');
     for i := 0 to FME_LIST.Count - 1 do
      begin
       if not IsResourceInGOB(SPRITESgob, FME_LIST[i], l1, l2) then
        if not FileExists(LEVELPath + '\' + FME_LIST[i]) then
         ChecksWindow.LBChecks.Items.Add('                 FME not found : ' + FME_LIST[i]);
      end;
    end;

    if OptionsDialog.CBChecksWAX.Checked then
     begin
     if headers then
      ChecksWindow.LBChecks.Items.Add('---------------  WAX - Sprites                    --------------');
     for i := 0 to SPR_LIST.Count - 1 do
      begin
       if not IsResourceInGOB(SPRITESgob, SPR_LIST[i], l1, l2) then
        if not FileExists(LEVELPath + '\' + SPR_LIST[i]) then
         ChecksWindow.LBChecks.Items.Add('                 WAX not found : ' + SPR_LIST[i]);
      end;
    end;

   if OptionsDialog.CBChecks3DO.Checked then
    begin
     if headers then
      ChecksWindow.LBChecks.Items.Add('---------------  3DO - 3D Objects                 --------------');
     for i := 0 to POD_LIST.Count - 1 do
      begin
       if not IsResourceInGOB(DARKgob, POD_LIST[i], l1, l2) then
        if not FileExists(LEVELPath + '\' + POD_LIST[i]) then
         ChecksWindow.LBChecks.Items.Add('                 3DO not found : ' + POD_LIST[i]);
      end;
    end;

   if OptionsDialog.CBChecksVOC.Checked then
    begin
     if headers then
      ChecksWindow.LBChecks.Items.Add('---------------  VOC - Sounds                     --------------');
     for i := 0 to SND_LIST.Count - 1 do
      begin
       if not IsResourceInGOB(SOUNDSgob, SND_LIST[i], l1, l2) then
        if not FileExists(LEVELPath + '\' + SND_LIST[i]) then
         ChecksWindow.LBChecks.Items.Add('                 VOC not found : ' + SND_LIST[i]);
      end;
    end;
  end;

 SetCursor(OldCursor);
 ChecksWindow.Show;
end;

procedure DO_CloseSector(sc: Integer);
var TheSector     : TSector;
    NewWall       : TWall;
    TheWall       : TWall;
    vx, wl        : Integer;
    vx1,vx2       : Integer;
    dummy         : Integer;
begin
 TheSector := TSector(MAP_SEC.Objects[sc]);
 if TheSector.Wl.Count = TheSector.Vx.Count then
  begin
   Application.MessageBox('Number of Vx and Wl are equal. Sector is NOT closable.',
                          'WDFUSE Mapper - Close Sector',
                          mb_Ok or mb_IconExclamation);
   exit;
  end;

if MODIFIED then
 if Application.MessageBox('WARNING: This low level function may damage your unsaved level. Continue?',
                           'WDFUSE Mapper - Close Sector',
                           mb_YesNo or mb_IconQuestion) = idNo then exit;

vx1 := -1;
vx2 := -1;

for vx := 0 to TheSector.Vx.Count - 1 do
 begin
  if not GetWLfromLeftVX(sc, vx, dummy) then
   begin
    vx1 := vx;
    break;
   end;
 end;

for vx := TheSector.Vx.Count - 1 downto 0 do
 begin
  if not GetWLfromRightVX(sc, vx, wl) then
   begin
    vx2 := vx;
    break;
   end;
 end;

if (vx1 = -1) or (vx2 = -1) then
 begin
  Application.MessageBox('Could not find correct unclosed pattern. Sector is NOT closable.',
                         'WDFUSE Mapper - Close Sector',
                          mb_Ok or mb_IconExclamation);
  exit;
 end;

{now, we just have to create a new wall, going from vx1 to vx2,
 using wl as a reference}
 TheWall := TWall(TheSector.Wl.Objects[wl]);
 NewWall := TWall.Create;

 NewWall.Left_vx      := vx1;
 NewWall.Right_vx     := vx2;
 NewWall.Adjoin       := TheWall.Adjoin;
 NewWall.Mirror       := TheWall.Mirror;
 NewWall.Walk         := TheWall.Walk;
 NewWall.Light        := TheWall.Light;
 NewWall.Flag1        := TheWall.Flag1;
 NewWall.Flag2        := TheWall.Flag2;
 NewWall.Flag3        := TheWall.Flag3;
 NewWall.Mid.Name     := TheWall.Mid.Name;
 NewWall.Mid.f1       := TheWall.Mid.f1;
 NewWall.Mid.f2       := TheWall.Mid.f2;
 NewWall.Mid.i        := TheWall.Mid.i;
 NewWall.Top.Name     := TheWall.Top.Name;
 NewWall.Top.f1       := TheWall.Top.f1;
 NewWall.Top.f2       := TheWall.Top.f2;
 NewWall.Top.i        := TheWall.Top.i;
 NewWall.Bot.Name     := TheWall.Bot.Name;
 NewWall.Bot.f1       := TheWall.Bot.f1;
 NewWall.Bot.f2       := TheWall.Bot.f2;
 NewWall.Bot.i        := TheWall.Bot.i;
 NewWall.Sign.Name    := TheWall.Sign.Name;
 NewWall.Sign.f1      := TheWall.Sign.f1;
 NewWall.Sign.f2      := TheWall.Sign.f2;

 TheSector.Wl.AddObject('WL', NewWall);
 MODIFIED := TRUE;
 MapWindow.Map.Invalidate;
end;

procedure DO_Init_Markers;
var TheMarker : TPLACEMARKER;
    i         : Integer;
begin
 MAP_MARKERS := TStringList.Create;

 for i := 0 to 4 do
  begin
   TheMarker := TPlaceMarker.Create;
   with TheMarker do
    begin
     XOff       := XOffset;
     ZOff       := ZOffset;
     Lay        := LAYER;
     ZoomFactor := 1;
    end;
   MAP_MARKERS.AddObject(IntToStr(i), TheMarker);
  end;
end;

procedure DO_Set_Marker(n : Integer);
var TheMarker : TPLACEMARKER;
begin
 TheMarker := TPLACEMARKER(MAP_MARKERS.Objects[n]);
 with TheMarker do
    begin
     XOff       := XOffset;
     ZOff       := ZOffset;
     Lay        := LAYER;
     ZoomFactor := Scale;
    end;
end;

procedure DO_Goto_Marker(n : Integer);
var TheMarker : TPLACEMARKER;
begin
 TheMarker := TPLACEMARKER(MAP_MARKERS.Objects[n]);
 with TheMarker do
    begin
     MapWindow.SetXOffset(XOff);
     MapWindow.SetZOffset(ZOff);
     if (Lay < LAYER_MIN) or (Lay > LAYER_MAX) then
      LAYER := LAYER_MIN
     else
      LAYER := Lay;
     //Scale := ZoomFactor;
    end;
 MapWindow.PanelZoom.Caption := Format('%-6.3f', [Scale]);
 MapWindow.HScrollBar.SmallChange := Trunc(1+25/scale);
 MapWindow.HScrollBar.LargeChange := Trunc(1+100/scale);
 MapWindow.VScrollBar.SmallChange := Trunc(1+25/scale);
 MapWindow.VScrollBar.LargeChange := Trunc(1+100/scale);
 MapWindow.Map.Invalidate;
end;

{this won't either Show or Hide the progress window
 this is caller's responsability !!!}
procedure DO_RecomputeTexturesLists(usegauge : Boolean; maintitle : string);
var TheSector : TSector;
    TheWall   : TWall;
    TheObject : TOB;
    s,v,w,i   : Integer;
begin
 if usegauge then
  begin
   ProgressWindow.Progress1.Caption := maintitle;
   ProgressWindow.Gauge.Progress    := 0;
   ProgressWindow.Gauge.MinValue    := 0;
   ProgressWindow.Progress2.Caption := 'Compiling Textures TABLES...';
   ProgressWindow.Gauge.MaxValue    := MAP_SEC.Count;
   ProgressWindow.Update;
   ProgressWindow.Progress2.Update;
  end;

 TX_LIST.Clear;
 TX_LIST.Sorted := TRUE;
 for s := 0 to MAP_SEC.Count - 1 do
  begin
   TheSector := TSector(MAP_SEC.Objects[s]);
   if TX_LIST.IndexOf(TheSector.Floor.Name) = -1 then
    TX_LIST.Add(TheSector.Floor.Name);
   if TX_LIST.IndexOf(TheSector.Ceili.Name) = -1 then
    TX_LIST.Add(TheSector.Ceili.Name);
   for w := 0 to TheSector.Wl.Count - 1 do
    begin
      TheWall := TWall(TheSector.Wl.Objects[w]);
      if TX_LIST.IndexOf(TheWall.Mid.Name) = -1 then
       TX_LIST.Add(TheWall.Mid.Name);
      if TX_LIST.IndexOf(TheWall.Top.Name) = -1 then
       TX_LIST.Add(TheWall.Top.Name);
      if TX_LIST.IndexOf(TheWall.Bot.Name) = -1 then
       TX_LIST.Add(TheWall.Bot.Name);
      if TheWall.Sign.Name <> '' then
       if TX_LIST.IndexOf(TheWall.Sign.Name) = -1 then
        TX_LIST.Add(TheWall.Sign.Name);
    end;
   if usegauge then
    if s mod 20 = 19 then
     ProgressWindow.Gauge.Progress := ProgressWindow.Gauge.Progress + 20;
  end;
end;

procedure DO_RecomputeObjectsLists(usegauge : Boolean; maintitle : string);
var TheSector : TSector;
    TheWall   : TWall;
    TheObject : TOB;
    s,v,w,i   : Integer;
begin
 if usegauge then
  begin
   ProgressWindow.Progress1.Caption := maintitle;
   ProgressWindow.Gauge.Progress    := 0;
   ProgressWindow.Gauge.MinValue    := 0;
   ProgressWindow.Progress2.Caption := 'Compiling Objects TABLES...';
   ProgressWindow.Gauge.MaxValue    := MAP_OBJ.Count;
   ProgressWindow.Update;
   ProgressWindow.Progress2.Update;
  end;

 POD_LIST.Clear;
 POD_LIST.Sorted := TRUE;
 SPR_LIST.Clear;
 SPR_LIST.Sorted := TRUE;
 FME_LIST.Clear;
 FME_LIST.Sorted := TRUE;
 SND_LIST.Clear;
 SND_LIST.Sorted := TRUE;

 for s := 0 to MAP_OBJ.Count - 1 do
  begin
   TheObject := TOB(MAP_OBJ.Objects[s]);
   if TheObject.ClassName = '3D' then
    if POD_LIST.IndexOf(TheObject.DataName) = -1 then
     POD_LIST.Add(TheObject.DataName);

   if TheObject.ClassName = 'SPRITE' then
    if SPR_LIST.IndexOf(TheObject.DataName) = -1 then
     SPR_LIST.Add(TheObject.DataName);

   if TheObject.ClassName = 'FRAME' then
    if FME_LIST.IndexOf(TheObject.DataName) = -1 then
     FME_LIST.Add(TheObject.DataName);

   if TheObject.ClassName = 'SOUND' then
    if SND_LIST.IndexOf(TheObject.DataName) = -1 then
     SND_LIST.Add(TheObject.DataName);

   if usegauge then
    if s mod 20 = 19 then
     ProgressWindow.Gauge.Progress := ProgressWindow.Gauge.Progress + 20;
  end;

end;

procedure UpdateShowCase;
var
  client: TRESTClient;
  request: TRESTRequest;
  response: TCustomRESTResponse;
  i : integer;
  errmsg ,
  TheGob ,
  LevPath,
  ShowCaseStr,
  secidstr,
  obidstr : string;
  secid,
  objid : integer;
  tmp : array[0..255] of char;
  PayLoad,
  Sectors,
  Objects : TJson;
  SkipConnect : Boolean;
begin
  if (IGNORE_UNDO) or (UseShowCase <> True) or (IGNORE_SHOWCASE) then exit;

  PayLoad := TJson.Create;
  Sectors := TJson.Create;
  Objects := TJson.Create;

  TheGob := DarkInst + '\' + ChangeFileExt(ExtractFileName(PROJECTFile),'_SHOWCASE.GOB');
  LevPath :=  LEVELName;


  if not ProcessRunning('Dark Forces Showcase.exe') and not SHOWCASE_DEBUG then
   CASE Application.MessageBox('Dark Forces Showcase is not running. Level may not render due to file lock. Do you want to start it?',
                                   'Continue ',
                                   mb_YesNoCancel or mb_IconQuestion) OF
       idYes    : Preview_3D_Level;
       idNo     : exit;
       idCancel : exit;
      END;

  //  GOB it if you are resetting
  if ShowCaseReset then
    begin
      log.info('Resetting 3D Renderer with for GOB ' + TheGOB, LogName);
      PayLoad.put('Reset', True);
      GOB_CreateEmpty(TheGob);
      GOB_Folder(LEVELPath, TheGOB);
      ShowCaseReset := False;
    end;

    if ShowCaseCameraReset then
      begin
        ShowCaseCameraReset := False;
        PayLoad.put('UpdateCamera','True');
      end;

  PayLoad.put('GOBPath', TheGob);
  PayLoad.put('LEVPath', LevPath);

  // Sectors Walls and Vertices
  if MAP_MODE <> MM_OB then
    begin

      // Handle Multiselection
      if (SC_MULTIS.Count > 1) then
        begin
          for i := 0 to SC_MULTIS.Count - 1 do
            begin
              secid := StrToInt(Copy(SC_MULTIS[i],1,4));
              if not ShowCaseModSC.ContainsInt(secid) then
                 ShowCaseModSC.put(secid);
            end;
        end
      else
        if (not ShowCaseDelSC.ContainsInt(SC_HILITE) and not ShowCaseModSC.ContainsInt(SC_HILITE)) then
          Sectors.Put(IntToStr(SC_HILITE), SerializeSector(SC_HILITE));

      // Handle Modded Adjoins (things not specifically selected
      if ShowCaseModSC.Count > 0 then
         begin
           for i := 0 to ShowCaseModSC.Count - 1 do
            begin
              secid    := ShowCaseModSC.Items[i].AsInteger;
              secidstr := IntToStr(secid);

              // Don't Accidentally try to add sectors that don't are deleted
              if (not ShowCaseDelSC.ContainsInt(secid) and
                 (MAP_SEC.count > secid)) then
                 begin
                   ShowCaseStr := SerializeSector(secid);
                   Sectors.Put(secidstr, ShowCaseStr );
                 end;
            end;
         end;

      PayLoad.Put('Sectors', Sectors.Stringify);
      PayLoad.Put('SectorsDel', ShowCaseDelSC.Stringify);
    end;

  // Objects
  if MAP_MODE = MM_OB then
    begin
      if (OB_MULTIS.Count > 1) then
        begin
          for i := 0 to OB_MULTIS.Count - 1 do
            begin
              obidstr := Copy(OB_MULTIS[i],5,4);
              objid := StrToInt(obidstr);

              // Don't Accidentally try to add objects that don't are deleted
              if (not ShowCaseDelOB.ContainsInt(objid) and
                  (MAP_OBJ.count > objid)) then
                begin
                  ShowCaseStr := SerializeObject(objid);
                  Objects.Put(obidstr, ShowCaseStr );
                end;
            end;
        end
      else
        if (not ShowCaseDelOB.ContainsInt(OB_HILITE)) then
          Objects.Put(IntToStr(OB_HILITE), SerializeObject(OB_HILITE));

      PayLoad.Put('Objects', Objects.Stringify);
      PayLoad.Put('ObjectsDel', ShowCaseDelOB.Stringify);
    end;


  // Send Request to ShowCase
  client := TRESTClient.Create(nil);
  try
    SkipConnect := False;

    while not SkipConnect do
      begin
        client.BaseURL := 'http://localhost:' + IntToStr(ShowCasePort) + '/';
        //log.Info('Connecting with port ' +  IntToStr(ShowCasePort), LogName );
        errmsg := 'Failed to contact the Showcase on port ' +  IntToStr(ShowCasePort);
        try
          request := TRESTRequest.Create(nil);
          request.Timeout := 1;
          try
            request.Client := client;
            request.Method := rmPOST;
            request.AddParameter('Payload', PayLoad.Stringify, pkREQUESTBODY);
            request.Execute;
            response := request.Response;
            if not response.Status.Success then
            begin
              log.Info(errmsg, LogName);
              ShowMessage(errmsg);
            end
            else
              begin
                SkipConnect := True;
                break;
              end;
          except
            on Exception do
             begin
              log.Info(errmsg, LogName);
              strPcopy(tmp, 'Could not connect to 3D Preview on port ' + IntToStr(ShowCasePort) +
                                          '. Abandon Attempt?');
              CASE Application.MessageBox(tmp, 'ShowCase Connect Error', mb_YesNo or mb_IconQuestion) OF
               idNo    : begin
                            request.Free;
                         end;
               idYes   : begin
                            UseShowCase := False;
                            if (MAP_MODE = MM_OB) then ShowCaseDelOB.Clear;
                            if (MAP_MODE = MM_SC) then ShowCaseDelSC.Clear;
                            ShowCaseModSC.Clear;
                            exit;
                          end;
              END;
             end
          end;
        finally
        end;
      end;
  finally
    if (MAP_MODE = MM_OB) then ShowCaseDelOB.Clear;
    if (MAP_MODE = MM_SC) then ShowCaseDelSC.Clear;
    ShowCaseModSC.Clear;
    client.Free;
    ShowCasePort := ShowCasePortBase;
  end;
end;

procedure DO_StoreUndo;
var i,j,k     : Integer;
    TheSector : TSector;
    TheWall   : TWall;
    TheVertex : TVertex;
    TheObject : TOB;
    NewSector : TSector;
    NewWall   : TWall;
    NewVertex : TVertex;
    NewObject : TOB;
begin

 { DO_FreeUndo;}
 if IGNORE_UNDO = True then exit;

 try
     { If you UNDO a few times and then make a STORE operation
      Wipe the UNDO history to the RIGHT (newer) than now }
     if (MAP_GLOBAL_UNDO.Count / 5) > MAP_GLOBAL_UNDO_INDEX  then
        begin
          for i := MAP_GLOBAL_UNDO_INDEX to round((MAP_GLOBAL_UNDO.Count / 5) - 1)  do
            begin
               DO_FreeUndo(MAP_GLOBAL_UNDO_INDEX);
               MAP_GLOBAL_UNDO.Delete(MAP_GLOBAL_UNDO_INDEX*5);
               MAP_GLOBAL_UNDO.Delete(MAP_GLOBAL_UNDO_INDEX*5);
               MAP_GLOBAL_UNDO.Delete(MAP_GLOBAL_UNDO_INDEX*5);
               MAP_GLOBAL_UNDO.Delete(MAP_GLOBAL_UNDO_INDEX*5);
               MAP_GLOBAL_UNDO.Delete(MAP_GLOBAL_UNDO_INDEX*5);
            end;
        end;
     MAP_SEC_UNDO := TStringList.Create;
     MAP_OBJ_UNDO := TStringList.Create;
     MAP_GUI_UNDO := TStringList.Create;
     MAP_SCMULTI_UNDO := TStringList.Create;
     MAP_OBMULTI_UNDO := TStringList.Create;

     { Store the UI assets }
     MAP_GUI_UNDO.CommaText := Format('MAP_MODE=%d, SC_HILITE=%d, WL_HILITE=%d, ' +
     'VX_HILITE=%d, OB_HILITE=%d, XOffset=%d, ZOffset=%d, LAYER=%d, LAYER_MIN=%d, LAYER_MAX=%d',
     [MAP_MODE,SC_HILITE,WL_HILITE,VX_HILITE,OB_HILITE,XOffset,ZOffset,LAYER,LAYER_MIN,LAYER_MAX]);

     for i := 0 to MAP_SEC.Count - 1 do
      begin
        TheSector := TSector(MAP_SEC.Objects[i]);
        NewSector := TSector.Create;

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

        NewSector.Mark       := TheSector.Mark;
        NewSector.Reserved   := TheSector.Reserved;
        NewSector.InfItems.AddStrings(TheSector.InfItems);
        { we don't copy the InfClasses, Elevator, Trigger, Secret !!!
          if an undo must be made, we'll use ComputeINFClasses(SC, WL)
          to recompute them from scratch for all sectors and walls
        }

        for j := 0 to TheSector.Vx.Count - 1 do
         begin
          TheVertex := TVertex(TheSector.Vx.Objects[j]);
          Newvertex := TVertex.Create;

          NewVertex.Mark := TheVertex.Mark;
          NewVertex.X    := TheVertex.X;
          NewVertex.Z    := TheVertex.Z;

          NewSector.Vx.AddObject('VX', NewVertex);
         end;

        for j := 0 to TheSector.Wl.Count - 1 do
         begin
          TheWall := TWall(TheSector.Wl.Objects[j]);
          NewWall := TWall.Create;

          NewWall.left_vx      := TheWall.left_vx;
          NewWall.right_vx     := TheWall.right_vx;
          NewWall.Adjoin       := TheWall.Adjoin;
          NewWall.Mirror       := TheWall.Mirror;
          NewWall.Walk         := TheWall.Walk;
          NewWall.Light        := TheWall.Light;
          NewWall.Flag1        := TheWall.Flag1;
          NewWall.Flag2        := TheWall.Flag2;
          NewWall.Flag3        := TheWall.Flag3;
          NewWall.Mid.Name     := TheWall.Mid.Name;
          NewWall.Mid.f1       := TheWall.Mid.f1;
          NewWall.Mid.f2       := TheWall.Mid.f2;
          NewWall.Mid.i        := TheWall.Mid.i;
          NewWall.Top.Name     := TheWall.Top.Name;
          NewWall.Top.f1       := TheWall.Top.f1;
          NewWall.Top.f2       := TheWall.Top.f2;
          NewWall.Top.i        := TheWall.Top.i;
          NewWall.Bot.Name     := TheWall.Bot.Name;
          NewWall.Bot.f1       := TheWall.Bot.f1;
          NewWall.Bot.f2       := TheWall.Bot.f2;
          NewWall.Bot.i        := TheWall.Bot.i;
          NewWall.Sign.Name    := TheWall.Sign.Name;
          NewWall.Sign.f1      := TheWall.Sign.f1;
          NewWall.Sign.f2      := TheWall.Sign.f2;

          NewWall.Mark         := TheWall.Mark;
          NewWall.Reserved     := TheWall.Reserved;

          NewWall.InfItems.AddStrings(TheWall.InfItems);

          NewSector.Wl.AddObject('WL', NewWall);
         end;
       MAP_SEC_UNDO.AddObject('SC', NewSector);
      end;

     for i := 0 to MAP_OBJ.Count - 1 do
      begin
       TheObject := TOB(MAP_OBJ.Objects[i]);
       NewObject := TOB.Create;

       NewObject.ClassName := TheObject.ClassName;
       NewObject.DataName  := TheObject.DataName;
       NewObject.X         := TheObject.X;
       NewObject.Y         := TheObject.Y;
       NewObject.Z         := TheObject.Z;
       NewObject.Yaw       := TheObject.Yaw;
       NewObject.Pch       := TheObject.Pch;
       NewObject.Rol       := TheObject.Rol;
       NewObject.Diff      := TheObject.Diff;
       NewObject.Sec       := TheObject.Sec;
       NewObject.Col       := TheObject.Col;
       NewObject.OType     := TheObject.OType;
       NewObject.Special   := TheObject.Special;
       NewObject.Mark      := TheObject.Mark;

       NewObject.Seq.AddStrings(TheObject.Seq);
       MAP_OBJ_UNDO.AddObject('OB', newObject);
      end;

      if SC_MULTIS.Count > 0 then
         MAP_SCMULTI_UNDO.AddStrings(SC_MULTIS)
      else
         MAP_SCMULTI_UNDO.add(IntToStr(SC_HILITE));
      if OB_MULTIS.Count > 0 then
         MAP_OBMULTI_UNDO.AddStrings(OB_MULTIS)
      else
         MAP_OBMULTI_UNDO.Add(IntToStr(OB_HILITE));
      MAP_GLOBAL_UNDO.Add(MAP_SEC_UNDO);
      MAP_GLOBAL_UNDO.Add(MAP_OBJ_UNDO);
      MAP_GLOBAL_UNDO.Add(MAP_GUI_UNDO);
      MAP_GLOBAL_UNDO.Add(MAP_SCMULTI_UNDO);
      MAP_GLOBAL_UNDO.Add(MAP_OBMULTI_UNDO);

      // Trim the excess if past the limit.
      if (MAP_GLOBAL_UNDO.Count / 5) >= UNDO_LIMIT  then
        begin
          DO_FreeUndo(0);
          MAP_GLOBAL_UNDO.Delete(0);
          MAP_GLOBAL_UNDO.Delete(0);
          MAP_GLOBAL_UNDO.Delete(0);
          MAP_GLOBAL_UNDO.Delete(0);
          MAP_GLOBAL_UNDO.Delete(0);
        end
      else
        MAP_GLOBAL_UNDO_INDEX := MAP_GLOBAL_UNDO_INDEX + 1;
   except on E: Exception do
        // So you don't go into a crash loop
        begin
          HandleException('Failed to Store Undo', E);
        end;
     end;

end;

procedure DO_FreeUndo(UndoIndex : Integer = -1);
var i,j,k     : Integer;
    TheSector : TSector;
    TheWall   : TWall;
    TheObject : TOB;
    start,
    stop : Integer;
begin
  if (UndoIndex = -1) then
    begin
      start := 0;
      stop := Trunc(MAP_GLOBAL_UNDO.Count/5)- 1;
    end
  else
    begin
      start := UndoIndex;
      stop := UndoIndex;
    end;

  for k:=start to stop do
    begin
        MAP_SEC_UNDO := MAP_GLOBAL_UNDO[k*5];
        MAP_OBJ_UNDO := MAP_GLOBAL_UNDO[k*5+1];
        MAP_GUI_UNDO := MAP_GLOBAL_UNDO[k*5+2];
        MAP_SCMULTI_UNDO := MAP_GLOBAL_UNDO[k*5+3];
        MAP_OBMULTI_UNDO := MAP_GLOBAL_UNDO[k*5+4];

        for i := 0 to MAP_SEC_UNDO.Count - 1 do
         begin
          TheSector := TSector(MAP_SEC_UNDO.Objects[i]);
          for j := 0 to TheSector.Vx.Count - 1 do
            begin
             TVertex(TheSector.Vx.Objects[j]).Free;
            end;
          for j := 0 to TheSector.Wl.Count - 1 do
            begin
             TWall(TheSector.Wl.Objects[j]).Free;
            end;
          TheSector.Free;
         end;

       for i := 0 to MAP_OBJ_UNDO.Count - 1 do
        TOB(MAP_OBJ_UNDO.Objects[i]).Free;

       MAP_SEC_UNDO.Free;
       MAP_OBJ_UNDO.Free;
       MAP_GUI_UNDO.Free;
       MAP_SCMULTI_UNDO.Free;
       MAP_OBMULTI_UNDO.Free;
       MAP_GLOBAL_UNDO[k*5].clear;
       MAP_GLOBAL_UNDO[k*5+1].clear;
       MAP_GLOBAL_UNDO[k*5+2].clear;
       MAP_GLOBAL_UNDO[k*5+3].clear;
       MAP_GLOBAL_UNDO[k*5+4].clear;
    end;

  // Wipe everything
  if (UndoIndex = -1) then
    begin
       MAP_GLOBAL_UNDO.Clear;
       MAP_GLOBAL_UNDO_INDEX := 0;
    end;
end;

{ FOR DEBUGGING - REMOVE THIS FOR RELEASE } // <-- LOL ..two years later...
procedure DEBUG_UNDO;
var debugstr : string;
    i,j : Integer;
    tmpSector : TSector;
    arrowsuffix : String;
    tmpstr : String;
    foundIdx : boolean;
    endloop : integer;
begin
 debugstr := 'GLOBAL UNDO count [' +  inttostr(MAP_GLOBAL_UNDO.Count)  + '] IDX = '
             + inttostr(MAP_GLOBAL_UNDO_INDEX) + ' --> ' + EOL;

 foundIdx := False;
 endloop := round(MAP_GLOBAL_UNDO.Count/5)-1;
 log.Info('endloop = ' + inttostr(endloop), logName);
 tmpstr := '';
 for i := 0 to MAP_GLOBAL_UNDO_INDEX-1 do
  begin
    showmessage('SC=[' + MAP_GLOBAL_UNDO[i*5].CommaText + ']');
    showmessage('OB=[' + MAP_GLOBAL_UNDO[i*5+1].CommaText + ']');
    showmessage('GUI=[' + MAP_GLOBAL_UNDO[i*5+2].CommaText + ']');
    showmessage('SCMULTIS=[' + MAP_GLOBAL_UNDO[i*5+3].CommaText + ']');
    showmessage('OBMULTIS=[' + MAP_GLOBAL_UNDO[i*5+4].CommaText + ']');
  end;


end;

{ Reversing an Undo means a Redo }
procedure DO_ApplyUndo(reverse : Boolean = False);
var i,j,k     : Integer;
    TheSector : TSector;
    TheWall   : TWall;
    TheVertex : TVertex;
    TheObject : TOB;
    NewSector : TSector;
    NewWall   : TWall;
    NewVertex : TVertex;
    NewObject : TOB;
    Stopwatch: TStopwatch;
    Elapsed: TTimeSpan;
    TimerStr : String;
    MultiStrList : String;
begin
 if ((MAP_GLOBAL_UNDO_INDEX = 0) and (Not reverse)) then
  begin
   ShowMessage('Undo lists are empty !!!');
   exit;
  end;

 log.info('Starting an Undo operation', LogName);
 TimerStr := '';
 Stopwatch := TStopwatch.StartNew;
 TimerStr :=  'Start:' + FormatDateTime('hh:nn:ss.zzz', Time) + EOL;

 { If you are at the end of the Undo list and are restoring
   then store current state in case you want to Redo here again }
 if not reverse then
   begin

    if (MAP_GLOBAL_UNDO.Count / 5) = MAP_GLOBAL_UNDO_INDEX then
     begin
      Do_StoreUndo;
      MAP_GLOBAL_UNDO_INDEX := MAP_GLOBAL_UNDO_INDEX - 1;
     end;
 end;

 { If you are at the end of the Redo then throw an error,
   otherwise jump ahead into the Undo array and retrieve state }
 if reverse = True then
  begin
   if MAP_GLOBAL_UNDO.Count / 5 <= MAP_GLOBAL_UNDO_INDEX + 1  then
    begin

     showmessage('You cannot Redo this command. You are the end of the Undo List');
     exit;
    end
  else
    MAP_GLOBAL_UNDO_INDEX := MAP_GLOBAL_UNDO_INDEX  + 2 ;
 end;

 {first, empty the MAP completely}

 for i := 0 to MAP_SEC.Count - 1 do
    begin
      TheSector := TSector(MAP_SEC.Objects[i]);
      for j := 0 to TheSector.InfClasses.Count - 1 do
       TInfClass(TheSector.InfClasses.Objects[j]).Free;

      for j := 0 to TheSector.Vx.Count - 1 do
        TVertex(TheSector.Vx.Objects[j]).Free;
      for j := 0 to TheSector.Wl.Count - 1 do
       begin
        TheWall := TWall(TheSector.Wl.Objects[j]);
        for k := 0 to TheWall.InfClasses.Count - 1 do
         TInfClass(TheWall.InfClasses.Objects[k]).Free;
        TWall(TheSector.Wl.Objects[j]).Free;
       end;
      TheSector.Free;
    end;
  for i := 0 to MAP_OBJ.Count - 1 do
   TOB(MAP_OBJ.Objects[i]).Free;
 TimerStr :=  TimerStr + 'Done Empty:' + FormatDateTime('hh:nn:ss.zzz', Time) + AnsiString(#13#10);
 MAP_SEC.Free;
 MAP_OBJ.Free;
 SC_MULTIS.Clear;
 OB_MULTIS.Clear;
 MAP_SEC := TStringList.Create;
 MAP_OBJ := TStringList.Create;

 { LOAD the UNDO Lists from the Global Mapper }

 MAP_SEC_UNDO := MAP_GLOBAL_UNDO[(MAP_GLOBAL_UNDO_INDEX-1)*5];
 MAP_OBJ_UNDO := MAP_GLOBAL_UNDO[(MAP_GLOBAL_UNDO_INDEX-1)*5+1];
 MAP_GUI_UNDO := MAP_GLOBAL_UNDO[(MAP_GLOBAL_UNDO_INDEX-1)*5+2];
 MAP_SCMULTI_UNDO  := MAP_GLOBAL_UNDO[(MAP_GLOBAL_UNDO_INDEX-1)*5+3];
 MAP_OBMULTI_UNDO  := MAP_GLOBAL_UNDO[(MAP_GLOBAL_UNDO_INDEX-1)*5+4];

 SC_MULTIS.AddStrings(MAP_SCMULTI_UNDO);
 OB_MULTIS.AddStrings(MAP_OBMULTI_UNDO);



 MAP_GLOBAL_UNDO_INDEX := MAP_GLOBAL_UNDO_INDEX - 1;

 for i := 0 to MAP_SEC_UNDO.Count - 1 do
  begin
    TheSector := TSector(MAP_SEC_UNDO.Objects[i]);
    NewSector := TSector.Create;

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

    NewSector.Mark       := TheSector.Mark;
    NewSector.Reserved   := TheSector.Reserved;
    NewSector.InfItems.AddStrings(TheSector.InfItems);

    for j := 0 to TheSector.Vx.Count - 1 do
     begin
      TheVertex := TVertex(TheSector.Vx.Objects[j]);
      NewVertex := TVertex.Create;

      NewVertex.Mark := TheVertex.Mark;
      NewVertex.X    := TheVertex.X;
      NewVertex.Z    := TheVertex.Z;

      NewSector.Vx.AddObject('VX', NewVertex);
     end;

    for j := 0 to TheSector.Wl.Count - 1 do
     begin
      TheWall := TWall(TheSector.Wl.Objects[j]);
      NewWall := TWall.Create;

      NewWall.left_vx      := TheWall.left_vx;
      NewWall.right_vx     := TheWall.right_vx;
      NewWall.Adjoin       := TheWall.Adjoin;
      NewWall.Mirror       := TheWall.Mirror;
      NewWall.Walk         := TheWall.Walk;
      NewWall.Light        := TheWall.Light;
      NewWall.Flag1        := TheWall.Flag1;
      NewWall.Flag2        := TheWall.Flag2;
      NewWall.Flag3        := TheWall.Flag3;
      NewWall.Mid.Name     := TheWall.Mid.Name;
      NewWall.Mid.f1       := TheWall.Mid.f1;
      NewWall.Mid.f2       := TheWall.Mid.f2;
      NewWall.Mid.i        := TheWall.Mid.i;
      NewWall.Top.Name     := TheWall.Top.Name;
      NewWall.Top.f1       := TheWall.Top.f1;
      NewWall.Top.f2       := TheWall.Top.f2;
      NewWall.Top.i        := TheWall.Top.i;
      NewWall.Bot.Name     := TheWall.Bot.Name;
      NewWall.Bot.f1       := TheWall.Bot.f1;
      NewWall.Bot.f2       := TheWall.Bot.f2;
      NewWall.Bot.i        := TheWall.Bot.i;
      NewWall.Sign.Name    := TheWall.Sign.Name;
      NewWall.Sign.f1      := TheWall.Sign.f1;
      NewWall.Sign.f2      := TheWall.Sign.f2;

      NewWall.Mark         := TheWall.Mark;
      NewWall.Reserved     := TheWall.Reserved;

      NewWall.InfItems.AddStrings(TheWall.InfItems);

      NewSector.Wl.AddObject('WL', NewWall);
     end;
   MAP_SEC.AddObject('SC', NewSector);
  end;

 TimerStr :=  TimerStr + 'Done Sectors:' + FormatDateTime('hh:nn:ss.zzz', Time) + AnsiString(#13#10);
 for i := 0 to MAP_OBJ_UNDO.Count - 1 do
  begin
   TheObject := TOB(MAP_OBJ_UNDO.Objects[i]);
   NewObject := TOB.Create;

   NewObject.ClassName := TheObject.ClassName;
   NewObject.DataName  := TheObject.DataName;
   NewObject.X         := TheObject.X;
   NewObject.Y         := TheObject.Y;
   NewObject.Z         := TheObject.Z;
   NewObject.Yaw       := TheObject.Yaw;
   NewObject.Pch       := TheObject.Pch;
   NewObject.Rol       := TheObject.Rol;
   NewObject.Diff      := TheObject.Diff;
   NewObject.Sec       := TheObject.Sec;
   NewObject.Col       := TheObject.Col;
   NewObject.OType     := TheObject.OType;
   NewObject.Special   := TheObject.Special;
   NewObject.Mark      := TheObject.Mark;

   NewObject.Seq.AddStrings(TheObject.Seq);
   MAP_OBJ.AddObject('OB', newObject);
 end;

 TimerStr :=  TimerStr + 'Done Objects:' + FormatDateTime('hh:nn:ss.zzz', Time) + AnsiString(#13#10);
 { Reload the highlights of the map }

 MAP_MODE    := StrToInt(MAP_GUI_UNDO.Values['MAP_MODE']);
 SC_HILITE   := StrToInt(MAP_GUI_UNDO.Values['SC_HILITE']);
 WL_HILITE   := StrToInt(MAP_GUI_UNDO.Values['WL_HILITE']);
 VX_HILITE   := StrToInt(MAP_GUI_UNDO.Values['VX_HILITE']);
 OB_HILITE   := StrToInt(MAP_GUI_UNDO.Values['OB_HILITE']);
 XOffset     := StrToInt(MAP_GUI_UNDO.Values['XOffset']);
 ZOffset     := StrToInt(MAP_GUI_UNDO.Values['ZOffset']);
 //Scale       := Real(StrToInt(MAP_GUI_UNDO.Values['Scale']));
 LAYER       := StrToInt(MAP_GUI_UNDO.Values['LAYER']);
 LAYER_MIN   := StrToInt(MAP_GUI_UNDO.Values['LAYER_MIN']);
 LAYER_MAX   := StrToInt(MAP_GUI_UNDO.Values['LAYER_MAX']);

 // Fix hilights during multiselections
 if MAP_SEC.Count <= SC_HILITE then SC_HILITE := MAP_SEC.Count-1;
 if MAP_OBJ.Count <= OB_HILITE then OB_HILITE := MAP_OBJ.Count-1;


 {then recompute the INFClasses
  the following two lines are mandatory because ComputeINFClasses
  does update the sector/wall editor, so we must be sure there is
  a valid value in there}

  // To prevent full INF recalculation
  APPLYING_UNDO := True;
  for i := 0 to MAP_SEC.Count - 1 do
   begin
    TheSector := TSector(MAP_SEC.Objects[i]);
    if TheSector.InfItems.Count <> 0 then
     ComputeInfClasses(i, -1);
    for j := 0 to TheSector.Wl.Count - 1 do
     begin
      TheWall := TWall(TheSector.Wl.Objects[j]);
      if TheWall.InfItems.Count <> 0 then
       ComputeInfClasses(i, j);
     end;
   end;
  APPLYING_UNDO := FALSE;

 TimerStr :=  TimerStr + 'Done INF/Highlights:' + FormatDateTime('hh:nn:ss.zzz', Time) + AnsiString(#13#10);
 {recompute the textures and objects, etc.}
 ProgressWindow.Show;
 DO_RecomputeTexturesLists(TRUE, 'Undo');
 DO_RecomputeObjectsLists(TRUE, 'Undo');
 ProgressWindow.Hide;
 TimerStr :=  TimerStr + 'Done TextureReloads:' + FormatDateTime('hh:nn:ss.zzz', Time) + AnsiString(#13#10);

 CASE MAP_MODE of
  MM_SC : DO_Switch_To_SC_Mode;
  MM_WL : DO_Switch_To_WL_Mode;
  MM_VX : DO_Switch_To_VX_Mode;
  MM_OB : DO_Switch_To_OB_Mode;
 END;

 {this will ensure multisels are cleared, and the editors
  refreshed correctly, as well as repaint the map.}
 if UseShowCase then
     MapWindow.ToolsResetShowCaseClick(NIL);
 DO_Clear_MultiSel;
 Elapsed := Stopwatch.Elapsed;
 MODIFIED := True;
 log.info('Finished an Undo operation', LogName);
end;

{Free functions - deprecated Karjala 2021 }
procedure DO_FreeGeometryClip;
var i,j,k     : Integer;
    TheSector : TSector;
    TheWall   : TWall;
begin
  for i := 0 to MAP_SEC_Clip.Count - 1 do
   begin
    TheSector := TSector(MAP_SEC_Clip.Objects[i]);
    for j := 0 to TheSector.Vx.Count - 1 do
     TVertex(TheSector.Vx.Objects[j]).Free;
    for j := 0 to TheSector.Wl.Count - 1 do
     TWall(TheSector.Wl.Objects[j]).Free;
    TheSector.Free;
   end;
 MAP_SEC_Clip.Clear;
end;

{Free functions - deprecated Karjala 2021 }
procedure DO_FreeObjectsClip;
var i,j,k     : Integer;
    TheObject : TOB;
begin
 for i := 0 to MAP_OBJ_Clip.Count - 1 do
  TOB(MAP_OBJ_Clip.Objects[i]).Free;
 MAP_OBJ_Clip.Clear;
end;

procedure DO_WriteToClipBoard(ClipText : String);
var
  Success : boolean;
  RetryCount : integer;
begin

  RetryCount := 0;
  Success := false;
  while not Success do
    try
      Log.Info('Copying to ClipBoard Attempt ' + IntToStr(RetryCount), LogName);
      Clipboard.AsText := ClipText;
      Success := True;
    except
      on Exception do
      begin
        Log.error('Failed to Copy to ClipBoard on Attempt ' + IntToStr(RetryCount), LogName);
        Inc(RetryCount);
        if RetryCount < 30 then
          Sleep(RetryCount * 100)
        else
          begin
            log.error('Failed after 30 tries to Copy to ClipBoard', LogName);
            raise Exception.Create('Cannot set clipboard after ten attempts');
          end;
      end
    end;
    Log.Info('Done Copying to ClipBoard', LogName);
end;



{ New Serialization for ShowCase }
function SerializeSector(sc : Integer) : string;
var i,j,k     : Integer;
    TheSector : TSector;
    TheWall   : TWall;
    TheVertex : TVertex;
    SecJson,
    VertexJson,
    TextureJson,
    Position,
    WallJson : TJSONObject;
    Walls : TJSONArray;
    a : TJsonPair;
begin

    SecJson := TJsonObject.Create();
    TheSector := TSector(MAP_SEC.Objects[sc]);

    // Base SC Properties
    SecJson.AddPair('Name', TheSector.Name);
    SecJson.AddPair('LightLevel', IntToStr(TheSector.Ambient));
    SecJson.AddPair('AltY', PosTrim(-1*TheSector.Second_Alt));
    SecJson.AddPair('Flags', IntToStr(TheSector.Flag1));
    SecJson.AddPair('UnusuedFlags2', IntToStr(TheSector.Flag2));
    SecJson.AddPair('AltLightLevel', IntToStr(TheSector.Flag3));
    SecJson.AddPair('Layer', IntToStr(TheSector.Layer));

    // Floor
    TextureJson := TJsonObject.Create();
    Position := TJsonObject.Create();
    TextureJson.AddPair('Y', PosTrim(-1*TheSector.Floor_Alt));
    TextureJson.AddPair('TextureFile', TheSector.Floor.Name);
    TextureJson.AddPair('TextureUnknown',IntToStr(TheSector.Floor.i));

    Position.AddPair('X', PosTrim(TheSector.Floor.f1));
    Position.AddPair('Y', PosTrim(-1*TheSector.Floor.f2));
    TextureJson.AddPair('TextureOffset', Position);
    SecJson.AddPair('Floor', TextureJson);


    // Ceiling
    TextureJson := TJsonObject.Create();
    Position := TJsonObject.Create();
    TextureJson.AddPair('Y', PosTrim(-1*TheSector.Ceili_Alt));
    TextureJson.AddPair('TextureFile', TheSector.Ceili.Name);
    TextureJson.AddPair('TextureUnknown',IntToStr(TheSector.Floor.i));

    Position.AddPair('X', PosTrim(TheSector.Ceili.f1));
    Position.AddPair('Y', PosTrim(-1*TheSector.Ceili.f2));
    TextureJson.AddPair('TextureOffset', Position);
    SecJson.AddPair('Ceiling', TextureJson);



    // Walls
    Walls := TJSONArray.Create;

    for j := 0 to TheSector.Wl.Count - 1 do
      begin


        WallJson := TJSONObject.Create();
        TheWall := TWall(TheSector.Wl.Objects[j]);

        // Left Vertex
        VertexJson := TJsonObject.Create();
        Position := TJSONObject.Create();
        TheVertex := TVertex(TheSector.Vx.Objects[TheWall.left_vx]);
        Position.AddPair('X', PosTrim(TheVertex.X));
        Position.AddPair('Y', PosTrim(TheVertex.Z));
        VertexJson.AddPair('Position', Position);
        WallJson.AddPair('LeftVertex', VertexJson);

        // Right Vertex
        VertexJson := TJsonObject.Create();
        Position := TJSONObject.Create();
        TheVertex := TVertex(TheSector.Vx.Objects[TheWall.right_vx]);
        Position.AddPair('X', PosTrim(TheVertex.X));
        Position.AddPair('Y', PosTrim(TheVertex.Z));
        VertexJson.AddPair('Position', Position);
        WallJson.AddPair('RightVertex', VertexJson);


        // Mid Texture
        TextureJson := TJSONObject.Create();
        Position := TJSONObject.Create();
        TextureJson.AddPair('TextureFile', TheWall.Mid.Name);
        TextureJson.AddPair('TextureUnknown', IntToStr(TheWall.Mid.i));

        Position.AddPair('X', PosTrim(TheWall.Mid.f1));
        Position.AddPair('Y', PosTrim(TheWall.Mid.f2));
        TextureJson.AddPair('TextureOffset', Position);
        WallJson.AddPair('MainTexture', TextureJson);

         // Top Texture
        TextureJson := TJSONObject.Create();
        Position := TJSONObject.Create();
        TextureJson.AddPair('TextureFile', TheWall.Top.Name);
        TextureJson.AddPair('TextureUnknown', IntToStr(TheWall.Top.i));

        Position.AddPair('X', PosTrim(TheWall.Top.f1));
        Position.AddPair('Y', PosTrim(TheWall.Top.f2));
        TextureJson.AddPair('TextureOffset', Position);
        WallJson.AddPair('TopEdgeTexture', TextureJson);


        // Bot Texture
        TextureJson := TJSONObject.Create();
        Position := TJSONObject.Create();
        TextureJson.AddPair('TextureFile', TheWall.Bot.Name);
        TextureJson.AddPair('TextureUnknown', IntToStr(TheWall.Bot.i));

        Position.AddPair('X', PosTrim(TheWall.Bot.f1));
        Position.AddPair('Y', PosTrim(TheWall.Bot.f2));
        TextureJson.AddPair('TextureOffset', Position);
        WallJson.AddPair('BottomEdgeTexture', TextureJson);


        // Sign Texture
        TextureJson := TJSONObject.Create();
        Position := TJSONObject.Create();
        TextureJson.AddPair('TextureFile', TheWall.sign.Name);
        TextureJson.AddPair('TextureUnknown', IntToStr(TheWall.sign.i));

        Position.AddPair('X', PosTrim(TheWall.sign.f1));
        Position.AddPair('Y', PosTrim(TheWall.sign.f2));
        TextureJson.AddPair('TextureOffset', Position);
        WallJson.AddPair('SignTexture', TextureJson);

        // Wall Properties
        WallJson.AddPair('TextureAndMapFlags', IntToStr(TheWall.Flag1));
        WallJson.AddPair('UnusuedFlags2', IntToStr(TheWall.Flag2));
        WallJson.AddPair('AdjoinFlags', IntToStr(TheWall.Flag3));
        WallJson.AddPair('LightLevel', IntToStr(TheWall.Light));
        walljson.tostring;

        // Hack Adjoin (sector + wall)
        WallJson.AddPair('Adjoin', IntToStr(TheWall.Adjoin ));
        WallJson.AddPair('Mirror', IntToStr(TheWall.Mirror ));
        Walls.AddElement(WallJson);
      end;

    SecJson.AddPair('Walls', Walls);
    Result := SecJson.toString;



    {   // UNUSED
    SecJson.put('NewSector.Secret',TheSector.Secret);
    SecJson.put('NewSector.Mark',TheSector.Mark);
    SecJson.put('NewSector.Reserved',TheSector.Reserved);
    SecJson.put('NewSector.InfItems',TheSector.InfItems.DelimitedText);
    }

end;


function  SerializeObject(ob : Integer) : string;
var i,j,obclass     : Integer;
    OBJson,
    Position,
    Angles : TJSONObject;
    a : TJsonPair;
    TheObject : TOB;
    showclass : integer;
    oblcass : string;
    infs : TStrings;

begin



    OBJson := TJsonObject.Create();
    Position := TJsonObject.Create();
    Angles := TJsonObject.Create();

    TheObject := TOB(MAP_OBJ.Objects[ob]);

    if TheObject.ClassName = 'SPIRIT' then
      showclass := 0
    else if TheObject.ClassName = 'SAFE' then
      showclass := 1
    else if TheObject.ClassName = 'SPRITE' then
      showclass := 2
    else if TheObject.ClassName = 'FRAME' then
      showclass := 3
    else if TheObject.ClassName = '3D' then
      showclass := 4
    else if TheObject.ClassName = 'SOUND' then
      showclass := 5;

    // Base OB Properties
    OBJson.AddPair('Type', IntToStr(showclass));
    OBJson.AddPair('FileName', TheObject.DataName);
    OBJson.AddPair('Difficulty', IntToStr(TheObject.Diff));

    // OB Position
    Position.AddPair('X', PosTrim(TheObject.X));
    Position.AddPair('Y', PosTrim(-1*TheObject.Y));
    Position.AddPair('Z', PosTrim(TheObject.Z));
    OBJson.AddPair('Position', Position);

    // Angles
    Angles.AddPair('X', PosTrim(TheObject.Pch));
    Angles.AddPair('Y', PosTrim(TheObject.Yaw));
    Angles.AddPair('Z', PosTrim(TheObject.Rol));
    OBJson.AddPair('EulerAngles', Angles);

    // INF
    //TheObject.Seq.Delimiter := '\n';
    //TheObject.Seq.QuoteChar := #0;
    OBJson.AddPair('Logic', TheObject.Seq.Text);

    Result := OBJson.toString;

end;


procedure DO_CopyGeometry;
var i,j,k     : Integer;
    TheSector : TSector;
    TheWall   : TWall;
    TheVertex : TVertex;
    NewSector : TSector;
    NewWall   : TWall;
    NewVertex : TVertex;
    RootJson : TJSon;
    SecJson: TJson;
    WallJson: TJson;
    VxJson : TJson;
    SectorsJson : TJson;
    VertexesJson : TJson;
    WallsJson : TJson;
    ClipStr: String;
begin
 Log.Info('Copying Geometry', LogName);

 RootJson := TJson.Create();
 {here, it is different : we take only the multiselected
  sectors and their objects, not the full map}

 {add the Selection to the MultiSelection if necessary}
 if SC_MULTIS.IndexOf(Format('%4d%4d', [SC_HILITE, SC_HILITE])) = -1 then
  SC_MULTIS.Add(Format('%4d%4d', [SC_HILITE, SC_HILITE]));


 SectorsJson := TJson.Create();
 for i := 0 to SC_MULTIS.Count - 1 do
  begin
    TheSector := TSector(MAP_SEC.Objects[StrToInt(Copy(SC_MULTIS[i],1,4))]);
    NewSector := TSector.Create;

    SecJson := TJson.Create();

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
    NewSector.Secret     := TheSector.Secret;

    NewSector.Mark       := TheSector.Mark;
    NewSector.Reserved   := TheSector.Reserved;
    NewSector.InfItems.AddStrings(TheSector.InfItems);
    NewSector.InfItems.Delimiter := '�';
    NewSector.InfItems.QuoteChar := #0;

    { we don't copy the InfClasses, Elevator, Trigger !!!
      if an Clip must be made, we'll use ComputeINFClasses(SC, WL)
      to recompute them from scratch for the pasted sectors and walls
    }


    SecJson.put('NewSector.Name',NewSector.Name);
    SecJson.put('NewSector.Ambient',NewSector.Ambient);
    SecJson.put('NewSector.Flag1',NewSector.Flag1);
    SecJson.put('NewSector.Flag2',NewSector.Flag2);
    SecJson.put('NewSector.Flag3',NewSector.Flag3);
    SecJson.put('NewSector.Floor_Alt',NewSector.Floor_Alt);
    SecJson.put('NewSector.Floor.Name',NewSector.Floor.Name);
    SecJson.put('NewSector.Floor.f1',NewSector.Floor.f1);
    SecJson.put('NewSector.Floor.f2',NewSector.Floor.f2);
    SecJson.put('NewSector.Floor.i',NewSector.Floor.i);
    SecJson.put('NewSector.Ceili_Alt',NewSector.Ceili_Alt);
    SecJson.put('NewSector.Ceili.Name',NewSector.Ceili.Name);
    SecJson.put('NewSector.Ceili.f1',NewSector.Ceili.f1);
    SecJson.put('NewSector.Ceili.f2',NewSector.Ceili.f2);
    SecJson.put('NewSector.Ceili.i',NewSector.Ceili.i);
    SecJson.put('NewSector.Second_Alt',NewSector.Second_Alt);
    SecJson.put('NewSector.Layer',NewSector.Layer);
    SecJson.put('NewSector.Secret',NewSector.Secret);
    SecJson.put('NewSector.Mark',NewSector.Mark);
    SecJson.put('NewSector.Reserved',NewSector.Reserved);
    SecJson.put('NewSector.InfItems',NewSector.InfItems.DelimitedText);

    VertexesJson := TJson.Create();
    for j := 0 to TheSector.Vx.Count - 1 do
     begin
      TheVertex := TVertex(TheSector.Vx.Objects[j]);
      Newvertex := TVertex.Create;

      NewVertex.Mark := TheVertex.Mark;
      NewVertex.X    := TheVertex.X;
      NewVertex.Z    := TheVertex.Z;

      VxJson := TJson.Create();
      VxJson.Put('NewVertex.Mark', NewVertex.Mark);
      VxJson.Put('NewVertex.X', NewVertex.X);
      VxJson.Put('NewVertex.Z', NewVertex.Z);
      VertexesJson.Put(IntToStr(j),VXJson);

      NewSector.Vx.AddObject('VX', NewVertex);
     end;
    SecJson.Put('vx', VertexesJson);
    WallsJson := TJson.Create();
    for j := 0 to TheSector.Wl.Count - 1 do
     begin
      TheWall := TWall(TheSector.Wl.Objects[j]);
      NewWall := TWall.Create;
      NewWall.left_vx      := TheWall.left_vx;
      NewWall.right_vx     := TheWall.right_vx;
      NewWall.Adjoin       := TheWall.Adjoin;
      NewWall.Mirror       := TheWall.Mirror;
      NewWall.Walk         := TheWall.Walk;
      NewWall.Light        := TheWall.Light;
      NewWall.Flag1        := TheWall.Flag1;
      NewWall.Flag2        := TheWall.Flag2;
      NewWall.Flag3        := TheWall.Flag3;
      NewWall.Mid.Name     := TheWall.Mid.Name;
      NewWall.Mid.f1       := TheWall.Mid.f1;
      NewWall.Mid.f2       := TheWall.Mid.f2;
      NewWall.Mid.i        := TheWall.Mid.i;
      NewWall.Top.Name     := TheWall.Top.Name;
      NewWall.Top.f1       := TheWall.Top.f1;
      NewWall.Top.f2       := TheWall.Top.f2;
      NewWall.Top.i        := TheWall.Top.i;
      NewWall.Bot.Name     := TheWall.Bot.Name;
      NewWall.Bot.f1       := TheWall.Bot.f1;
      NewWall.Bot.f2       := TheWall.Bot.f2;
      NewWall.Bot.i        := TheWall.Bot.i;
      NewWall.Sign.Name    := TheWall.Sign.Name;
      NewWall.Sign.f1      := TheWall.Sign.f1;
      NewWall.Sign.f2      := TheWall.Sign.f2;
      NewWall.Mark         := TheWall.Mark;
      NewWall.Reserved     := TheWall.Reserved;

      NewWall.InfItems.AddStrings(TheWall.InfItems);
      NewWall.InfItems.Delimiter := '�';
      NewWall.InfItems.QuoteChar := #0;

      WallJson := TJson.Create();
      WallJson.put('NewWall.left_vx',NewWall.left_vx);
      WallJson.put('NewWall.right_vx',NewWall.right_vx);
      WallJson.put('NewWall.Adjoin',NewWall.Adjoin);
      WallJson.put('NewWall.Mirror',NewWall.Mirror);
      WallJson.put('NewWall.Walk',NewWall.Walk);
      WallJson.put('NewWall.Light',NewWall.Light);
      WallJson.put('NewWall.Flag1',NewWall.Flag1);
      WallJson.put('NewWall.Flag2',NewWall.Flag2);
      WallJson.put('NewWall.Flag3',NewWall.Flag3);
      WallJson.put('NewWall.Mid.Name',NewWall.Mid.Name);
      WallJson.put('NewWall.Mid.f1',NewWall.Mid.f1);
      WallJson.put('NewWall.Mid.f2',NewWall.Mid.f2);
      WallJson.put('NewWall.Mid.i',NewWall.Mid.i);
      WallJson.put('NewWall.Top.Name',NewWall.Top.Name);
      WallJson.put('NewWall.Top.f1',NewWall.Top.f1);
      WallJson.put('NewWall.Top.f2',NewWall.Top.f2);
      WallJson.put('NewWall.Top.i',NewWall.Top.i);
      WallJson.put('NewWall.Bot.Name',NewWall.Bot.Name);
      WallJson.put('NewWall.Bot.f1',NewWall.Bot.f1);
      WallJson.put('NewWall.Bot.f2',NewWall.Bot.f2);
      WallJson.put('NewWall.Bot.i',NewWall.Bot.i);
      WallJson.put('NewWall.Sign.Name',NewWall.Sign.Name);
      WallJson.put('NewWall.Sign.f1',NewWall.Sign.f1);
      WallJson.put('NewWall.Sign.f2',NewWall.Sign.f2);
      WallJson.put('NewWall.InfItems', NewWall.InfItems.DelimitedText);
      WallsJson.Put(IntToStr(j),Walljson);
     end;
     SecJson.Put('walls', WallsJson);
     SectorsJson.put(IntToStr(i), SecJson);
   MAP_SEC_Clip.AddObject('SC', NewSector);
  end;
  RootJson.Put('Sectors', SectorsJson);
  DO_WriteToClipBoard(RootJson.Stringify);
  log.Info('Done Copying Geometry. Total ' + IntToStr(SC_MULTIS.Count) + ' Sectors', LogName );
end;

procedure DO_PasteGeometry(cursX, cursZ : Real; payload : Tjson);
var i,j,k     : Integer;
    TheSector : TSector;
    TheWall   : TWall;
    TheVertex : TVertex;
    NewSector : TSector;
    NewWall   : TWall;
    NewVertex : TVertex;
    OldSCCnt  : Integer;
    XZero,
    ZZero     : Real;
    s,w        : Integer;
    TheSector1 : TSector;
    TheSector2 : TSector;
    TheWall1   : TWall;
    TheWall2   : TWall;
    LVertex1   : TVertex;
    RVertex1   : TVertex;
    LVertex2   : TVertex;
    RVertex2   : TVertex;
    found      : Boolean;
    TheInfCls  : TInfClass;
    RootJson : TJSon;
    SecJson: TJson;
    WallJson: TJson;
    VxJson : TJson;
    SectorsJson : TJSON;
    VertexesJson : TJson;
    WallsJson : TJson;
    JSONData       : String;
    JSONObject     : TJSONObject;
    JSONPair       : TJSONPair;
    INFs           : TStringList;
    firstVX        : Boolean;
    secname        : String;
    secnum         : Integer;
begin
 Log.Info('Pasting Geometry', LogName);
 SectorsJson := TJson.Create();
 SectorsJson.Parse(payload['Sectors'].stringify);
 OldSCCnt :=  MAP_SEC.Count;

 firstVX := True;
 XZero     := 0;
 ZZero     := 0;


 for i := 0 to SectorsJson.Count - 1 do
   begin
     SecJson := TJSon.Create();
     SecJson.Parse(SectorsJson[IntToStr(i)].Stringify);
     NewSector := TSector.Create;
     NewSector.Name       := SecJson['NewSector.Name'].AsString;
     NewSector.Ambient    := SecJson['NewSector.Ambient'].AsInteger;
     NewSector.Flag1      := SecJson['NewSector.Flag1'].AsInteger;
     NewSector.Flag2      := SecJson['NewSector.Flag2'].AsInteger;
     NewSector.Flag3      := SecJson['NewSector.Flag3'].AsInteger;
     NewSector.Floor_Alt  := SecJson['NewSector.Floor_Alt'].AsNumber;
     NewSector.Floor.Name := SecJson['NewSector.Floor.Name'].AsString;
     NewSector.Floor.f1   := SecJson['NewSector.Floor.f1'].AsNumber;
     NewSector.Floor.f2   := SecJson['NewSector.Floor.f2'].AsNumber;
     NewSector.Floor.i    := SecJson['NewSector.Floor.i'].AsInteger;
     NewSector.Ceili_Alt  := SecJson['NewSector.Ceili_Alt'].AsNumber;
     NewSector.Ceili.Name := SecJson['NewSector.Ceili.Name'].AsString;
     NewSector.Ceili.f1   := SecJson['NewSector.Ceili.f1'].AsNumber;
     NewSector.Ceili.f2   := SecJson['NewSector.Ceili.f2'].AsNumber;
     NewSector.Ceili.i    := SecJson['NewSector.Ceili.i'].AsInteger;
     NewSector.Second_Alt := SecJson['NewSector.Second_Alt'].AsNumber;
     NewSector.Layer      := SecJson['NewSector.Layer'].AsInteger;
     NewSector.Secret     := SecJson['NewSector.Secret'].AsBoolean;
     NewSector.Mark       := SecJson['NewSector.Mark'].AsInteger;
     NewSector.Reserved   := SecJson['NewSector.Reserved'].asInteger;


     // Ensure no dupe psector pastes
     if (NewSector.name <> '') then
        begin
          NewSector.name := NewSEctor.Name + '_' + IntToStr(Random(1000));
          if length(NewSector.Name) >= 16 then
             NewSector.name := 'NEWSECTOR_' + IntToStr(Random(1000));
        end;

     { INFs}
     INFs := TStringList.Create;
     INFs.delimiter := '�';
     INFs.StrictDelimiter := True;
     INFs.DelimitedText   := SecJson['NewSector.InfItems'].AsString;

     NewSector.InfItems.AddStrings(INFs);

     { Vertices }

     VertexesJson := TJson.Create();
     VertexesJson.Parse(SecJson['vx'].Stringify);

     for j := 0 to VertexesJson.Count - 1 do
       begin
        VxJson := TJSon.Create();
        VxJson.Parse(VertexesJson[IntToStr(j)].Stringify);
        NewVertex := TVertex.Create;
        NewVertex.Mark := VxJson['NewVertex.Mark'].AsInteger;

        { This ensures all the pasted assets are offset from a single point }
        if firstVX then
          begin
            xzero :=  VxJson['NewVertex.X'].AsNumber-cursx;
            zzero :=  VxJson['NewVertex.Z'].AsNumber-cursz;
            firstVX := False;
          end;

        NewVertex.X := VxJson['NewVertex.X'].AsNumber - xzero;
        NewVertex.Z := VxJson['NewVertex.Z'].AsNumber - zzero;

        NewSector.Vx.AddObject('VX', NewVertex);
      end;

     {Walls }

     WallsJson := TJson.Create();
     WallsJson.Parse(SecJson['walls'].Stringify);

     for j := 0 to WallsJson.Count - 1 do
      begin
        WallJson := TJson.Create();
        WallJson.Parse(WallsJson[IntToStr(j)].Stringify);

        NewWall := TWall.Create;

        NewWall.left_vx      := WallJson['NewWall.left_vx'].AsInteger;
        NewWall.right_vx     := WallJson['NewWall.right_vx'].AsInteger;
        NewWall.Adjoin       := -1;
        NewWall.Mirror       := -1;
        NewWall.Walk         := -1;
        NewWall.Light        := WallJson['NewWall.Light'].AsInteger;
        NewWall.Flag1        := WallJson['NewWall.Flag1'].AsInteger;
        NewWall.Flag2        := WallJson['NewWall.Flag2'].AsInteger;
        NewWall.Flag3        := WallJson['NewWall.Flag3'].AsInteger;
        NewWall.Mid.Name     := WallJson['NewWall.Mid.Name'].AsString;
        NewWall.Mid.f1       := WallJson['NewWall.Mid.f1'].AsNumber;
        NewWall.Mid.f2       := WallJson['NewWall.Mid.f2'].AsNumber;
        NewWall.Mid.i        := WallJson['NewWall.Mid.i'].AsInteger;
        NewWall.Top.Name     := WallJson['NewWall.Top.Name'].AsString;
        NewWall.Top.f1       := WallJson['NewWall.Top.f1'].AsNumber;
        NewWall.Top.f2       := WallJson['NewWall.Top.f2'].AsNumber;
        NewWall.Top.i        := WallJson['NewWall.Top.i'].AsInteger;
        NewWall.Bot.Name     := WallJson['NewWall.Bot.Name'].AsString;
        NewWall.Bot.f1       := WallJson['NewWall.Bot.f1'].AsNumber;
        NewWall.Bot.f2       := WallJson['NewWall.Bot.f2'].AsNumber;
        NewWall.Bot.i        := WallJson['NewWall.Bot.i'].AsInteger;
        NewWall.Sign.Name    := WallJson['NewWall.Sign.Name'].AsString;
        NewWall.Sign.f1      := WallJson['NewWall.Sign.f1'].AsNumber;
        NewWall.Sign.f2      := WallJson['NewWall.Sign.f2'].AsNumber;

        NewWall.Mark         := WallJson['NewWall.Mark'].AsInteger;
        NewWall.Reserved     := WallJson['NewWall.Reserved'].AsInteger;

        {INFs}
        INFs := TStringList.Create;
        INFs.delimiter := '�';
        INFs.StrictDelimiter := True;
        INFs.DelimitedText   := WallJson['NewWall.InfItems'].AsString;

        NewWall.InfItems.AddStrings(INFs);

        NewSector.Wl.AddObject('WL', NewWall);
      end;
      MAP_SEC.AddObject('SC', NewSector);
  end;

 {try to readjoin all the new walls BUT STAY IN THOSE TO SEARCH !!!}
 for i := OldSCCnt to MAP_SEC.Count - 1 do
   begin
     TheSector := TSector(MAP_SEC.Objects[i]);
     for j := 0 to TheSector.Wl.Count - 1 do
      begin
        TheSector1 := TSector(MAP_SEC.Objects[i]);
        TheWall1   := TWall(TheSector1.Wl.Objects[j]);
        LVertex1   := TVertex(TheSector1.Vx.Objects[TheWall1.left_vx]);
        RVertex1   := TVertex(TheSector1.Vx.Objects[TheWall1.right_vx]);
        found      := FALSE;

        for s := OldSCCnt to MAP_SEC.Count - 1 do
         begin
          TheSector2 := TSector(MAP_SEC.Objects[s]);
          for w := 0 to TheSector2.Wl.Count - 1 do
           begin
            TheWall2 := TWall(TheSector2.Wl.Objects[w]);
            LVertex2 := TVertex(TheSector2.Vx.Objects[TheWall2.left_vx]);
            RVertex2 := TVertex(TheSector2.Vx.Objects[TheWall2.right_vx]);

            {if found do the adjoin and prepare to break out of both loops}
            if ((LVertex1.X = RVertex2.X) and (LVertex1.Z = RVertex2.Z)) and
               ((RVertex1.X = LVertex2.X) and (RVertex1.Z = LVertex2.Z)) then
             begin
              TheWall2.Adjoin := i;
              TheWall2.Mirror := j;
              TheWall2.Walk   := i;
              TheWall1.Adjoin := s;
              TheWall1.Mirror := w;
              TheWall1.Walk   := s;
              found      := TRUE;
             end;
            if found then break;
           end;
           if found then break;
         end;
     end;
   end;

 {then recompute the INFClasses for the added sectors}
  for i := OldSCCnt to MAP_SEC.Count - 1 do
   begin
    TheSector := TSector(MAP_SEC.Objects[i]);

    if (TheSector.Flag1 and 2) <> 0 then
     begin
      TheInfCls := TInfClass.Create;
      TheInfCls.IsElev := TRUE;
      TheInfCls.Name := 'E. FLAG Door';
      TheSector.InfClasses.AddObject('D', TheInfCls);
      TheSector.Elevator := TRUE;
     end;
    if (TheSector.Flag1 and 64) <> 0 then
     begin
      TheInfCls := TInfClass.Create;
      TheInfCls.IsElev := TRUE;
      TheInfCls.Name := 'E. FLAG Exploding';
      TheSector.InfClasses.AddObject('X', TheInfCls);
      TheSector.Elevator := TRUE;
     end;

    if TheSector.InfItems.Count <> 0 then
     ComputeInfClasses(i, -1);
    for j := 0 to TheSector.Wl.Count - 1 do
     begin
      TheWall := TWall(TheSector.Wl.Objects[j]);
      if TheWall.InfItems.Count <> 0 then
       ComputeInfClasses(i, j);
     end;
   end;

 {recompute LAYER_MIN and LAYER_MAX
  Current LAYER is still valid of course}
 LAYER_MIN := 9999;
 LAYER_MAX := -9999;
 for i := 0 to MAP_SEC.Count - 1 do
  begin
   TheSector := TSector(MAP_SEC.Objects[i]);
   if TheSector.Layer > LAYER_MAX then LAYER_MAX := TheSector.Layer;
   if TheSector.Layer < LAYER_MIN then LAYER_MIN := TheSector.Layer;
  end;

 {recompute the textures and objects, etc.}
 ProgressWindow.Show;
 DO_RecomputeTexturesLists(TRUE, 'Paste Geometry');
 ProgressWindow.Hide;

 { Only multi select if you have more than 1 item }
 if SectorsJson.Count > 1 then
  begin
    DO_Clear_MultiSel2;
   {finish with creating a multiselection of the pasted sectors}
    for i := OldSCCnt to MAP_SEC.Count - 1 do
     SC_MULTIS.Add(Format('%4d%4d', [i, i]));
    MapWindow.PanelMulti.Caption := IntToStr(SC_MULTIS.Count);
  end;

 SC_HILITE := OldSCCnt;
 WL_HILITE := 0;
 VX_HILITE := 0;

 MODIFIED   := TRUE;
 DO_Fill_SectorEditor;
 MapWindow.Map.Invalidate;
 log.Info('Done Pasting Geometry. Total ' + IntToStr(SectorsJson.Count) + ' Sectors', LogName );
end;

procedure DO_CopyObjects;
var i,j,k     : Integer;
    TheObject : TOB;
    NewObject : TOB;
    RootJson : TJson;
    ObjectsJson : TJson;
    ObjectJson : TJson;
    clipStr : String;
begin
 Log.Info('Copying Objects', LogName);
 RootJson := TJson.Create;

 {add the Selection to the MultiSelection if necessary}

 TheObject := TOB(MAP_OBJ.Objects[OB_HILITE]);

 if OB_MULTIS.IndexOf(Format('%4d%4d', [TheObject.Sec, OB_HILITE])) = -1 then
  OB_MULTIS.Add(Format('%4d%4d', [TheOBject.Sec, OB_HILITE]));

 ObjectsJson := TJson.Create();

 for i := 0 to OB_MULTIS.Count - 1 do
  begin
   TheObject := TOB(MAP_OBJ.Objects[StrToInt(Copy(OB_MULTIS[i],5,8))]);

   ObjectJson := TJson.Create;
   ObjectJson.put('TheObject.ClassName',TheObject.ClassName);
   ObjectJson.put('TheObject.DataName',TheObject.DataName);
   ObjectJson.put('TheObject.X',TheObject.X);
   ObjectJson.put('TheObject.Y',TheObject.Y);
   ObjectJson.put('TheObject.Z',TheObject.Z);
   ObjectJson.put('TheObject.Yaw',TheObject.Yaw);
   ObjectJson.put('TheObject.Pch',TheObject.Pch);
   ObjectJson.put('TheObject.Rol',TheObject.Rol);
   ObjectJson.put('TheObject.Diff',TheObject.Diff);
   ObjectJson.put('TheObject.Sec',TheObject.Sec);
   ObjectJson.put('TheObject.Col',TheObject.Col);
   ObjectJson.put('TheObject.OType',TheObject.OType);
   ObjectJson.put('TheObject.Special',TheObject.Special);
   ObjectJson.put('TheObject.Mark',TheObject.Mark);
   ObjectJson.put('TheObject.Mark',TheObject.Mark);

   TheObject.Seq.Delimiter := '�';
   TheObject.Seq.QuoteChar := #0;
   ObjectJson.Put('TheObject.Seq', TheObject.Seq.DelimitedText);
   ObjectsJson.Put(inttostr(i), ObjectJson);
  end;
  RootJson.put('Objects', ObjectsJson);
  DO_WriteToClipBoard(RootJson.Stringify);
  log.Info('Done Copying Objects. Total ' + IntToStr(OB_MULTIS.Count) + ' Objects', LogName );
end;

procedure DO_PasteObjects(cursX, cursZ : Real; payload : TJson);
var i,j,k     : Integer;
    TheObject : TOB;
    NewObject : TOB;
    OldOBCnt  : Integer;
    XZero,
    ZZero     : Real;
    RootJson : TJson;
    ObjectsJson : TJson;
    ObjectJson : TJson;
    INFs : TStringList;
    firstVx : Boolean;
begin
 Log.Info('Pasting Objects', LogName);
 Do_StoreUndo;
 DO_Clear_MultiSel;
 DO_Clear_MultiSel2;

 firstVx := True;

 ObjectsJson := TJson.Create();
 ObjectsJson.Parse(payload['Objects'].stringify);
 OldOBCnt :=  MAP_SEC.Count;

 for i := 0 to ObjectsJson.Count - 1 do
   begin
     ObjectJson := TJSon.Create();
     ObjectJson.Parse(ObjectsJson[IntToStr(i)].Stringify);

     { This ensures all the pasted assets are offset from a single point }
     if firstVX then
      begin
        xzero := (ObjectJson['TheObject.X'].asNumber - cursx);
        zzero := (ObjectJson['TheObject.Z'].asNumber - cursz);
        firstVX := False;
      end;


     NewObject := TOB.Create;
     NewObject.ClassName := ObjectJson['TheObject.ClassName'].AsString;
     NewObject.DataName  := ObjectJson['TheObject.DataName'].AsString;
     NewObject.X         := ObjectJson['TheObject.X'].asNumber - xzero;
     NewObject.Y         := ObjectJson['TheObject.Y'].asNumber;
     NewObject.Z         := ObjectJson['TheObject.Z'].asNumber - zzero;
     NewObject.Yaw       := ObjectJson['TheObject.Yaw'].asNumber;
     NewObject.Pch       := ObjectJson['TheObject.Pch'].asNumber;
     NewObject.Rol       := ObjectJson['TheObject.Rol'].asNumber;
     NewObject.Diff      := ObjectJson['TheObject.Diff'].AsInteger;
     NewObject.Sec       := -1;
     NewObject.Col       := ObjectJson['TheObject.Col'].AsInteger;
     NewObject.OType     := ObjectJson['TheObject.OType'].AsInteger;
     NewObject.Special   := ObjectJson['TheObject.Special'].AsInteger;
     NewObject.Mark      := ObjectJson['TheObject.Mark'].AsInteger;

     {INFs}
     INFs := TStringList.Create;
     INFs.delimiter := '�';
     INFs.StrictDelimiter := True;
     INFs.DelimitedText   := ObjectJson['TheObject.Seq'].AsString;

     NewObject.Seq.AddStrings(INFs);

     MAP_OBJ.AddObject('OB', newObject);
   end;

 {recompute the textures and objects, etc.}
 LayerAllObjects;
 ProgressWindow.Show;
 DO_RecomputeObjectsLists(TRUE, 'Paste Objects');
 ProgressWindow.Hide;
 DO_Clear_MultiSel;
 DO_Clear_MultiSel2;

 {finish with creating a multiselection of the pasted objects }


 { Only multi select if you have more than 1 item }
 if ObjectsJson.Count > 1 then
   begin
     for i := OldOBCnt to MAP_OBJ.Count - 1 do
      begin
       TheObject := TOB(MAP_OBJ.Objects[i]);
       OB_MULTIS.Add(Format('%4d%4d', [TheOBject.Sec, i]));
      end;
     MapWindow.PanelMulti.Caption := IntToStr(OB_MULTIS.Count);
   end;

 OB_HILITE := OldOBCnt;
 MODIFIED   := TRUE;
 DO_Fill_ObjectEditor;
 MapWindow.Map.Invalidate;

 log.Info('Done Pasting Objects. Total ' + IntToStr(ObjectsJson.Count) + ' Objects', LogName );
 UpdateShowCase;
end;

procedure DO_PasteWrapper(cursX, cursZ : Real);
var WrapperJson : TJson;
    payloadStr : string;

begin
 if ClipBoard.AsText = '' then
  begin
   ShowMessage('Your ClipBoard is empty!');
   exit;
  end;

 try
   WrapperJson := TJson.Create();
   WrapperJson.Parse(ClipBoard.AsText);

 except
   begin
    ShowMessage('Unable to parse the Clipboard! Maybe it is malformed?');
    exit;
   end;
 end;

 Do_StoreUndo;
 DO_Clear_MultiSel;
 DO_Clear_MultiSel2;

 if not (WrapperJson['Sectors'].Stringify = 'null') then
   begin
    DO_Switch_To_SC_Mode;
    DO_PasteGeometry(cursx, cursz, WrapperJson)
   end
 else if not (WrapperJson['Objects'].Stringify = 'null') then
   begin
     DO_Switch_To_OB_Mode;
     DO_PasteObjects(cursx, cursz, WrapperJson)
   end
 else
   raise Exception.Create('Invalid JSON. Missing Sector/Object data');
 UpdateShowCase;
end;

procedure DO_UpdatePRJHistory;
var i : integer;
begin

  if PRJ_History.count > 0 then
    // Delete any instances of the same file from history to remove dupes
   for i := 0 to PRJ_History.count -1 do
      begin
        if PRJ_History[i] = PROJECTFile then
          begin
            PRJ_History.delete(i);
            break;
          end
      end;

 PRJ_History.insert(0, PROJECTFile);

 // Clean up anything over limit
 if PRJ_History.count > MAX_RECENT then
    PRJ_History.Delete(MAX_RECENT);
end;

end.



