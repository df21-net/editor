unit M_io;

interface
uses SysUtils, WinTypes, WinProcs, Messages, Classes, Forms, IniFiles, Dialogs,
     StdCtrls,
     _Strings, _Files, M_Global, M_Progrs, G_Util, FileCtrl, V_Util,
     M_Editor, M_SCedit, M_WLedit, M_VXedit, M_OBedit, I_Util;

procedure FreeLevel;
procedure GOB_Test_Level;
function  IO_ReadLEV(levname : TFileName) : Boolean;
function  IO_ReadO(oname : TFileName) : Boolean;
function  IO_WriteLEV(levname : TFileName) : Boolean;
function  IO_WriteO(oname : TFileName) : Boolean;
procedure IO_ReadINF(infname : TFileName);
procedure IO_ReadINF2(infname : TFileName);
procedure IO_WriteINF2(infname : TFileName);
procedure IO_ReadGOL(golname : TFileName);
procedure IO_WriteGOL(golname : TFileName);

implementation
uses Mapper, M_Util, InfEdit2;

procedure FreeLevel;
var i,j,k     : Integer;
    TheSector : TSector;
    TheWall   : TWall;
    TheObject : TOB;
begin
  for i := 0 to MAP_SEC.Count - 1 do
    begin
      TheSector := TSector(MAP_SEC.Objects[i]);
      for j := 0 to TheSector.InfClasses.Count - 1 do
       begin
        TInfClass(TheSector.InfClasses.Objects[j]).Free;
       end;

      for j := 0 to TheSector.Vx.Count - 1 do
        TVertex(TheSector.Vx.Objects[j]).Free;
      for j := 0 to TheSector.Wl.Count - 1 do
       begin
        TheWall := TWall(TheSector.Wl.Objects[j]);
        for k := 0 to TheWall.InfClasses.Count - 1 do
         begin
          TInfClass(TheWall.InfClasses.Objects[k]).Free;
         end;
        TWall(TheSector.Wl.Objects[j]).Free;
       end;
      TheSector.Free;
    end;
  MAP_SEC.Free;
  LEVELLoaded := FALSE;

  for i := 0 to MAP_OBJ.Count - 1 do
    begin
      TheObject := TOB(MAP_OBJ.Objects[i]);
      TheObject.Free;
    end;
  MAP_OBJ.Free;
  OFILELoaded := FALSE;

  INFWindow2.CBINFNavigator.Items.Clear;
  INFComments.Free;
  INFErrors.Free;
  INFLevel.Free;
  INFRemote := FALSE;
  INFMisc := -1;
  INFWindow2.Hide;

  INFFILELoaded := FALSE;

  GOLComments.Free;
  GOLErrors.Free;

  GOLFILELoaded := FALSE;

  {Free textures, pods,...}
  TX_LIST.Free;
  POD_LIST.Free;
  SPR_LIST.Free;
  FME_List.Free;
  SND_LIST.Free;

  MAP_MARKERS.Free;

  SC_HILITE   := 0;
  WL_HILITE   := 0;
  VX_HILITE   := 0;
  OB_HILITE   := 0;

  SC_MULTIS.Clear;
  WL_MULTIS.Clear;
  VX_MULTIS.Clear;
  OB_MULTIS.Clear;

  ReleasePALPalette;

  SectorEditor.Hide;
  WallEditor.Hide;
  VertexEditor.Hide;
  ObjectEditor.Hide;

  MapWindow.PanelLevelName.Caption := '';
  MapWindow.Caption := 'WDFUSE';
  MapWindow.Map.Invalidate;
  DO_SetMapButtonsState;
end;

function ArrayToString(const a: array of Char): string;
begin
  if Length(a)>0 then
    SetString(Result, PChar(@a[0]), Length(a))
  else
    Result := '';
end;

procedure GOB_Test_Level;
var TheGob : TFileName;
    i      : Integer;
    tmp    : array[0..127] of char;
begin
 if not LEVELLoaded then exit;
 if LEVELLoaded and MODIFIED then
  CASE Application.MessageBox('Level has been modified. Do you want to SAVE ?',
                               'WDFUSE Mapper - Create GOB file',
                               mb_YesNoCancel or mb_IconQuestion) OF
   idYes    : begin
               {this is to pass by the registration check}
               MapWindow.SpeedButtonSaveClick(NIL);
              end;
   idNo     : ;
   idCancel : exit;
  END;

 TheGob := DarkInst + '\' + ChangeFileExt(ExtractFileName(PROJECTFile),'.GOB');
 GOB_CreateEmpty(TheGob);

 ProgressWindow.Progress1.Caption := 'Creating the project GOB file';
 ProgressWindow.Gauge.Progress    := 0;
 ProgressWindow.Gauge.MinValue    := 0;
 ProgressWindow.Gauge.MaxValue    := 0;
 ProgressWindow.Progress2.Caption := 'GOBing...';
 ProgressWindow.Progress2.Update;
 ProgressWindow.Show;
 ProgressWindow.Update;

 {This uses a dummy, invisible TFileListBox on The MapWindow form}
 MapWindow.DummyFileListBox.Visible := FALSE;
 MapWindow.DummyFileListBox.MultiSelect := TRUE;
 MapWindow.DummyFileListBox.Directory := LEVELPath;
 MapWindow.DummyFileListBox.Update;
 for i:= 0 to MapWindow.DummyFileListBox.Items.Count - 1 do MapWindow.DummyFileListBox.Selected[i] := TRUE;
 GOB_AddFiles(LEVELPath, TheGOB, MapWindow.DummyFileListBox, ProgressWindow.Gauge);

 ProgressWindow.Hide;

 {copy the txt file also...}
 CopyFile(ChangeFileExt(PROJECTFile, '.TXT'),
          DarkInst + '\' + ExtractFileName(ChangeFileExt(PROJECTFile, '.TXT')));

 if TestLaunch then
  begin
   strPcopy(tmp, WDFUSEdir + '\DARK.PIF -u' + ChangeFileExt(ExtractFileName(PROJECTFile),'.GOB'));
   WinExec(PAnsiChar(ArrayToString(tmp)), SW_SHOWMAXIMIZED);
  end;
end;

function IO_ReadLEV(levname : TFileName) : Boolean;
var lev       : System.TextFile;
    strin     : string;
    pars      : TStringParser;
    OldCursor : HCursor;
    TheSector : TSector;
    numsectors: Integer;
    textures  : Integer;
    TheVertex : TVertex;
    TheWall   : TWall;
    tmp       : array[0..127] of char;
    tmpreal   : Real;
    code      : Integer;
    First     : Boolean;
    sccounter : Integer;
begin
  if not FileExists(levname) then
    begin
      strPcopy(tmp, levname + ' does not exist !');
      Application.MessageBox(tmp, 'Map Editor Error', mb_Ok or mb_IconExclamation);
      IO_ReadLEV := FALSE;
    end
  else
    begin
      OldCursor  := SetCursor(LoadCursor(0, IDC_WAIT));
      numsectors := 0;
      textures   := 0;
      First      := TRUE;
      LAYER_MIN  :=  999;
      LAYER_MAX  := -999;
      sccounter  := -1;

      MAP_SEC := TStringList.Create;
      TX_LIST := TStringList.Create;

      ProgressWindow.Progress1.Caption := 'Loading LEV File';
      ProgressWindow.Gauge.Progress    := 0;
      ProgressWindow.Gauge.MinValue    := 0;
      ProgressWindow.Gauge.MaxValue    := 0;
      ProgressWindow.Show;
      ProgressWindow.Update;

      AssignFile(lev, levname);
      Reset(lev);
      while not SeekEof(lev) do
        begin
          Readln(lev, strin);
          if Pos('#', strin) = 1 then
            begin
            end
          else
          {vertices and walls are by far the most frequent, so place them
           first in the imbricated ifs. It saves THOUSANDS of tests !}
          if Pos('X:', UpperCase(strin)) = 1 then
            begin
              pars := TStringParser.Create(strin);
              try
                if pars.Count > 4 then
                  begin
                    TheVertex := TVertex.Create;
                    Val(pars[2], tmpreal, code);
                    TheVertex.X := tmpreal;
                    Val(pars[4], tmpreal, code);
                    TheVertex.Z := tmpreal;
                    TheSector.Vx.AddObject('VX', TheVertex);
                  end;
               finally
                pars.Free;
              end;
            end
          else
          if Pos('WALL', UpperCase(strin)) = 1 then
            begin
              pars := TStringParser.Create(strin);
              try
                if pars.Count > 36 then
                  begin
                  {  1 WALL
                     2 LEFT:  0
                     4 RIGHT: 1
                     6 MID:  47   0.00   0.00   0
                    11 TOP:  47   0.00   0.00   0
                    16 BOT:  47   0.00   0.00   0
                    21 SIGN:  -1   0.00   0.00
                    25 ADJOIN:  -1
                    27 MIRROR:  -1
                    29 WALK:  -1
                    31 FLAGS: 1024 0 0
                    35 LIGHT: 22
                  }

                    TheWall          := TWall.Create;
                    TheWall.Mark     := 0;
                    TheWall.Left_vx  := StrToInt(pars[3]);
                    TheWall.Right_vx := StrToInt(pars[5]);
                    with TheWall.Mid do
                      begin
                        Name := TX_LIST[StrToInt(pars[7])];
                        Val(pars[8], tmpreal, code);
                        f1   := tmpreal;
                        Val(pars[9], tmpreal, code);
                        f2   := tmpreal;
                        i    := StrToInt(pars[10]);
                      end;
                    with TheWall.Top do
                      begin
                        Name := TX_LIST[StrToInt(pars[12])];
                        Val(pars[13], tmpreal, code);
                        f1   := tmpreal;
                        Val(pars[14], tmpreal, code);
                        f2   := tmpreal;
                        i    := StrToInt(pars[15]);
                      end;
                    with TheWall.Bot do
                      begin
                        Name := TX_LIST[StrToInt(pars[17])];
                        Val(pars[18], tmpreal, code);
                        f1   := tmpreal;
                        Val(pars[19], tmpreal, code);
                        f2   := tmpreal;
                        i    := StrToInt(pars[20]);
                      end;
                    with TheWall.Sign do
                      begin
                        if StrToInt(pars[22]) <> -1 then
                          begin
                            Name := TX_LIST[StrToInt(pars[22])];
                            Val(pars[23], tmpreal, code);
                            f1   := tmpreal;
                            Val(pars[24], tmpreal, code);
                            f2   := tmpreal;
                          end
                        else
                          begin
                            Name := '';
                            f1   := 0;
                            f2   := 0;
                          end;
                      end;
                    TheWall.Adjoin  := StrToInt(pars[26]);
                    TheWall.Mirror  := StrToInt(pars[28]);
                    TheWall.Walk    := StrToInt(pars[30]);
                    TheWall.Flag1   := StrToInt(pars[32]);
                    TheWall.Flag2   := StrToInt(pars[33]);
                    TheWall.Flag3   := StrToInt(pars[34]);
                    TheWall.Light   := StrToInt(pars[36]);

                    TheSector.Wl.AddObject('WL', TheWall);
                  end;
               finally
                pars.Free;
              end;
            end
          else
          if Pos('SECTOR', UpperCase(strin)) = 1 then
            begin
              if not First then MAP_SEC.AddObject('SC', TheSector);
              TheSector := TSector.Create;
              TheSector.Mark := 0;
              First := FALSE;
              Inc(sccounter);
              if sccounter mod 20 = 19 then
               ProgressWindow.Gauge.Progress := ProgressWindow.Gauge.Progress + 20;
            end
          else
          if Pos('NAME', UpperCase(strin)) = 1 then
            begin
              pars := TStringParser.Create(strin);
              try
                if pars.Count > 2 then
                  TheSector.Name := pars[2]
                else
                  TheSector.Name := '';
              finally
                pars.Free;
              end;
            end
          else
          if Pos('AMBIENT', UpperCase(strin)) = 1 then
            begin
              pars := TStringParser.Create(strin);
              try
                if pars.Count > 2 then
                  TheSector.Ambient := StrToInt(pars[2]);
              finally
                pars.Free;
              end;
            end
          else
          if Pos('FLOOR', UpperCase(strin)) = 1 then
            begin
              pars := TStringParser.Create(strin);
              try
                if pars.Count > 2 then
                  if pars[2] = 'TEXTURE' then
                    if pars.Count > 6 then
                     with TheSector.Floor do
                      begin
                        Name := TX_LIST[StrToInt(pars[3])];
                        Val(pars[4], tmpreal, code);
                        f1   := tmpreal;
                        Val(pars[5], tmpreal, code);
                        f2   := tmpreal;
                        i    := StrToInt(pars[6]);
                      end
                    else
                  else
                    if pars.Count > 3 then
                      begin
                        Val(pars[3], tmpreal, code);
                        TheSector.Floor_alt := -tmpreal;
                      end;
              finally
                pars.Free;
              end;
            end
          else
          if Pos('CEILING', UpperCase(strin)) = 1 then
            begin
              pars := TStringParser.Create(strin);
              try
                if pars.Count > 2 then
                  if pars[2] = 'TEXTURE' then
                    if pars.Count > 6 then
                     with TheSector.Ceili do
                      begin
                        Name := TX_LIST[StrToInt(pars[3])];
                        Val(pars[4], tmpreal, code);
                        f1   := tmpreal;
                        Val(pars[5], tmpreal, code);
                        f2   := tmpreal;
                        i    := StrToInt(pars[6]);
                      end
                    else
                  else
                    if pars.Count > 3 then
                      begin
                        Val(pars[3], tmpreal, code);
                        TheSector.Ceili_alt := -tmpreal;
                      end;
              finally
                pars.Free;
              end;
            end
          else
          if Pos('SECOND', UpperCase(strin)) = 1 then
            begin
              pars := TStringParser.Create(strin);
              try
                if pars.Count > 3 then
                  begin
                    Val(pars[3], tmpreal, code);
                    TheSector.Second_alt := -tmpreal;
                  end;
              finally
                pars.Free;
              end;
            end
          else
          if Pos('FLAGS', UpperCase(strin)) = 1 then
            begin
              pars := TStringParser.Create(strin);
              try
                if pars.Count > 4 then
                  begin
                    TheSector.Flag1 := StrToInt(pars[2]);
                    TheSector.Flag2 := StrToInt(pars[3]);
                    TheSector.Flag3 := StrToInt(pars[4]);
                  end;
              finally
                pars.Free;
              end;
            end
          else
          if Pos('LAYER', UpperCase(strin)) = 1 then
            begin
              pars := TStringParser.Create(strin);
              try
                if pars.Count > 2 then
                 begin
                  TheSector.Layer := StrToInt(pars[2]);
                  if TheSector.Layer > LAYER_MAX then LAYER_MAX := TheSector.Layer;
                  if TheSector.Layer < LAYER_MIN then LAYER_MIN := TheSector.Layer;
                 end;
              finally
                pars.Free;
              end;
            end
          else
          if Pos('VERTICES', UpperCase(strin)) = 1 then
            begin
              pars := TStringParser.Create(strin);
              try
                if pars.Count > 2 then ;
              finally
                pars.Free;
              end;
            end
          else
          if Pos('WALLS', UpperCase(strin)) = 1 then
            begin
              pars := TStringParser.Create(strin);
              try
                if pars.Count > 2 then ;
              finally
                pars.Free;
              end;
            end
          else
          {LEVNAME must be before LEV}
          if Pos('LEVELNAME', UpperCase(strin)) = 1 then
           begin
            pars := TStringParser.Create(strin);
            try
             if pars.Count > 2 then LEV_LEVELNAME := pars[2];
            finally
             pars.Free;
            end;
           end
          else
          if Pos('LEV', UpperCase(strin)) = 1 then
           begin
            pars := TStringParser.Create(strin);
            try
             if pars.Count > 2 then LEV_VERSION := pars[2];
            finally
             pars.Free;
            end;
           end
          else
          if Pos('PALETTE', UpperCase(strin)) = 1 then
           begin
            pars := TStringParser.Create(strin);
            try
             if pars.Count > 2 then LEV_PALETTE := pars[2];
            finally
             pars.Free;
            end;
           end
          else
          if Pos('MUSIC', UpperCase(strin)) = 1 then
           begin
            pars := TStringParser.Create(strin);
            try
             if pars.Count > 2 then LEV_MUSIC := pars[2];
            finally
             pars.Free;
            end;
           end
          else
          if Pos('PARALLAX', UpperCase(strin)) = 1 then
           begin
            pars := TStringParser.Create(strin);
            try
             if pars.Count > 3 then
              begin
               Val(pars[2], tmpreal, code);
               LEV_PARALLAX1 := tmpreal;
               Val(pars[3], tmpreal, code);
               LEV_PARALLAX2 := tmpreal;
              end;
            finally
             pars.Free;
            end;
           end
          else
          if Pos('TEXTURES', UpperCase(strin)) = 1 then
            begin
              pars := TStringParser.Create(strin);
              try
                if pars.Count > 2 then textures := StrToInt(pars[2]);
                { HIDE progress for TEXTURES, showing it takes more
                       time than actually reading the textures!
                ProgressWindow.Gauge.MaxValue    := textures;
                ProgressWindow.Gauge.Progress    := 0;
                ProgressWindow.Progress2.Caption := 'Parsing TEXTURES...';
                ProgressWindow.Progress2.Update;
                }
              finally
                pars.Free;
              end;
            end
          else
          if Pos('TEXTURE:', UpperCase(strin)) = 1 then
            begin
              pars := TStringParser.Create(strin);
              try
                if pars.Count > 2 then TX_LIST.Add(pars[2]);
                {ProgressWindow.Gauge.Progress := ProgressWindow.Gauge.Progress + 1;}
              finally
                pars.Free;
              end;
            end
          else
          if Pos('NUMSECTORS', UpperCase(strin)) = 1 then
            begin
              pars := TStringParser.Create(strin);
              try
                if pars.Count > 2 then numsectors := StrToInt(pars[2]);
                ProgressWindow.Gauge.MaxValue     := numsectors;
                ProgressWindow.Gauge.Progress     := 0;
                ProgressWindow.Progress2.Caption  := 'Parsing GEOMETRY...';
                ProgressWindow.Progress2.Update;
              finally
                pars.Free;
              end;
            end
          else ;
        end;

      { add last sector}
      MAP_SEC.AddObject('SC', TheSector);
      System.CloseFile(lev);

      LAYER := LAYER_MIN;

      ProgressWindow.Hide;
      { compare the textures and sectors found with those announced
        and report errors }
      LEVELLoaded := TRUE;
      SetCursor(OldCursor);
      IO_ReadLEV := TRUE;
    end;
end;

function  IO_WriteLEV(levname : TFileName) : Boolean;
var lev       : System.TextFile;
    OldCursor : HCursor;
    TheSector : TSector;
    numsectors: Integer;
    TheVertex : TVertex;
    TheWall   : TWall;
    s,v,w,i   : Integer;
    tmpLight  : LongInt;
begin
 {check registration again}


 OldCursor  := SetCursor(LoadCursor(0, IDC_WAIT));
 numsectors := MAP_SEC.Count;

 ProgressWindow.Progress1.Caption := 'Saving LEV File';
 ProgressWindow.Gauge.Progress    := 0;
 ProgressWindow.Gauge.MinValue    := 0;
 ProgressWindow.Gauge.MaxValue    := 0;
 ProgressWindow.Show;
 ProgressWindow.Update;

 AssignFile(lev, levname);
 Rewrite(lev);

 WriteLn(lev, 'LEV ', LEV_VERSION);
 WriteLn(lev, '#');
 WriteLn(lev, '# GENERATED BY FREEWARE WDFUSE ', WDFUSE_VERSION);
 WriteLn(lev, '# (c) Y.Borckmans,A.Novikov,D.Lovejoy,J.Kok,F.Krueger 1995-1997');
 WriteLn(lev, '#');
 WriteLn(lev, '# GENTIME ', DateTimeToStr(Now));
 WriteLn(lev, '#');
 WriteLn(lev, '# AUTHOR ', USERname);
 WriteLn(lev, '# EMAIL  ', USERemail);
 WriteLn(lev, '#');
 WriteLn(lev, '# GENERAL LEVEL INFORMATION');
 WriteLn(lev, '# =========================');
 WriteLn(lev, '#');
 WriteLn(lev, 'LEVELNAME ', LEV_LEVELNAME);
 WriteLn(lev, 'PALETTE   ', LEV_PALETTE);
 WriteLn(lev, 'MUSIC     ', LEV_MUSIC);
 WriteLn(lev, 'PARALLAX  ', Format('%9.4f %9.4f',[LEV_PARALLAX1, LEV_PARALLAX2]));
 WriteLn(lev, '#');
 WriteLn(lev, '# TEXTURE TABLE');
 WriteLn(lev, '# =============');
 WriteLn(lev, '#');

 DO_RecomputeTexturesLists(TRUE, 'Saving LEV File');

 WriteLn(lev, 'TEXTURES ', TX_LIST.Count);
 for i := 0 to TX_LIST.Count - 1 do
  begin
   WriteLn(lev, ' TEXTURE: ', RPad(TX_LIST[i],13) , '# ', Format('%-3.3d', [i]));
  end;


 WriteLn(lev, '#');
 WriteLn(lev, '# SECTOR DEFINITIONS');
 WriteLn(lev, '# ==================');
 WriteLn(lev, '#');
 WriteLn(lev, 'NUMSECTORS ', numsectors);
 WriteLn(lev, '#');

 ProgressWindow.Progress2.Caption := 'Writing GEOMETRY...';
 ProgressWindow.Gauge.Progress    := 0;
 ProgressWindow.Gauge.MaxValue    := numsectors;
 ProgressWindow.Progress2.Update;

 for s := 0 to MAP_SEC.Count - 1 do
  begin
   TheSector := TSector(MAP_SEC.Objects[s]);
   WriteLn(lev, 'SECTOR ', s);
   WriteLn(lev, ' NAME             ', TheSector.Name);
   WriteLn(lev, ' AMBIENT          ', TheSector.Ambient);
   with TheSector.Floor do
   WriteLn(lev, ' FLOOR TEXTURE    ', TX_LIST.IndexOf(Name),
                Format(' %5.2f %5.2f %d', [f1, f2, i]));
   WriteLn(lev, ' FLOOR ALTITUDE   ', Format('%5.2f', [-TheSector.Floor_Alt]));
   with TheSector.Ceili do
   WriteLn(lev, ' CEILING TEXTURE  ', TX_LIST.IndexOf(Name),
                Format(' %5.2f %5.2f %d', [f1, f2, i]));
   WriteLn(lev, ' CEILING ALTITUDE ', Format('%5.2f', [-TheSector.Ceili_Alt]));
   WriteLn(lev, ' SECOND ALTITUDE  ', Format('%5.2f', [-TheSector.Second_Alt]));
   with TheSector do
   WriteLn(lev, ' FLAGS            ', Flag1, ' ', Flag2, ' ', Flag3);
   WriteLn(lev, ' LAYER            ', TheSector.Layer);

   WriteLn(lev, ' VERTICES ', TheSector.Vx.Count);

   for v := 0 to TheSector.Vx.Count - 1 do
    begin
     TheVertex := TVertex(TheSector.Vx.Objects[v]);
     with TheVertex do
     WriteLn(lev, Format('  X: %5.2f Z: %5.2f # %2d', [X, Z, v]));
    end;

   WriteLn(lev, ' WALLS ', TheSector.Wl.Count);
   for w := 0 to TheSector.Wl.Count - 1 do
    begin
     TheWall := TWall(TheSector.Wl.Objects[w]);
     with TheWall do
     Write (lev, Format('  WALL LEFT: %2d RIGHT: %2d MID: %3d %5.2f %5.2f %d TOP: %3d %5.2f %5.2f %d BOT: %3d %5.2f %5.2f %d',
                         [left_vx, right_vx,
                          TX_LIST.IndexOf(Mid.Name), Mid.f1, Mid.f2, Mid.i,
                          TX_LIST.IndexOf(Top.Name), Top.f1, Top.f2, Top.i,
                          TX_LIST.IndexOf(Bot.Name), Bot.f1, Bot.f2, Bot.i]));
     with TheWall do
     if Sign.Name <> '' then
      Write  (lev, Format(' SIGN: %d %5.2f %5.2f',
                          [TX_LIST.IndexOf(Sign.Name), Sign.f1, Sign.f2]))
     else
      Write  (lev, ' SIGN: -1 0.00 0.00');


     if TheWall.Light >= 0 then
      tmpLight := TheWall.Light
     else
      tmpLight := 65536 + TheWall.Light;

     with TheWall do
     WriteLn(lev, Format(' ADJOIN: %d MIRROR: %d WALK: %d FLAGS: %d %d %d LIGHT: %d',
                          [Adjoin, Mirror, Walk, Flag1, Flag2, Flag3, tmpLight]));
    end;
   WriteLn(lev, '#');
   if s mod 20 = 19 then
    ProgressWindow.Gauge.Progress := ProgressWindow.Gauge.Progress + 20;
  end;

 System.CloseFile(lev);
 ProgressWindow.Hide;
 SetCursor(OldCursor);
 IO_WriteLEV := TRUE;
end;


function IO_ReadO(oname : TFileName) : Boolean;
var o         : System.TextFile;
    strin     : string;
    pars      : TStringParser;
    OldCursor : HCursor;
    TheObject : TOB;
    numobjects: Integer;
    pods      : Integer;
    sprs      : Integer;
    fmes      : Integer;
    snds      : Integer;
    tmp       : array[0..127] of char;
    tmpreal   : Real;
    code      : Integer;
    First     : Boolean;
    Comment   : Boolean;
    COLORini  : TIniFile;
    i         : Integer;
    obcount   : Integer;
begin
  if not FileExists(oname) then
    begin
      strPcopy(tmp, oname + ' does not exist !');
      Application.MessageBox(tmp, 'Map Editor Error', mb_Ok or mb_IconExclamation);
      IO_ReadO := FALSE;
    end
  else
    begin
      OldCursor  := SetCursor(LoadCursor(0, IDC_WAIT));
      numobjects := 0;
      pods       := 0;
      sprs       := 0;
      fmes       := 0;
      snds       := 0;
      First      := TRUE;
      Comment    := FALSE;
      obcount    := -1;

      MAP_OBJ  := TStringList.Create;
      POD_LIST := TStringList.Create;
      SPR_LIST := TStringList.Create;
      FME_LIST := TStringList.Create;
      SND_LIST := TStringList.Create;
      COLORini := TIniFile.Create(WDFUSEdir + '\WDFDATA\OB_COLS.WDF');

      ProgressWindow.Progress1.Caption := 'Loading O File';
      ProgressWindow.Gauge.Progress    := 0;
      ProgressWindow.Gauge.MinValue    := 0;
      ProgressWindow.Gauge.MaxValue    := 0;
      ProgressWindow.Show;
      ProgressWindow.Update;

      AssignFile(o, oname);
      Reset(o);

      while not SeekEof(o) do
        begin
          Readln(o, strin);
          if Comment then
           begin
            if Pos('*/', strin) <> 0 then
             begin
              Comment := FALSE;
             end
            {forget comment in any case !}
           end
          else
          if Pos('/*', strin) = 1 then
            begin
             if Pos('*/', strin) = 0 then Comment := TRUE;
            end
          else
          {by far the most frequent}
          if Pos('CLASS:', UpperCase(strin)) = 1 then
            begin
              if not First then MAP_OBJ.AddObject('OB', TheObject);
              TheObject := TOB.Create;
              TheObject.Mark := 0;

              { parsing of CLASS

              1  CLASS: SPIRIT
              3  DATA: 0
              5  X: 24.80
              7  Y: -118.00
              9  Z: 195.08
              11 PCH: 0.00
              13 YAW: 271.47
              15 ROL: 0.00
              17 DIFF: 1
              19 SEC: 0        [WDFUSE addition !!!!!]

              }
              pars := TStringParser.Create(strin);
              try
                if pars.Count > 18 then
                 begin
                  TheObject.ClassName := pars[2];
                  if pars[2] = 'SPIRIT' then TheObject.DataName := 'SPIRIT';
                  if pars[2] = 'SAFE'   then TheObject.DataName := 'SAFE';
                  if pars[2] = 'SPRITE' then
                   begin
                    if StrToInt(pars[4]) < SPR_LIST.Count then
                     TheObject.DataName := SPR_LIST[StrToInt(pars[4])];
                   end;
                  if pars[2] = 'FRAME' then
                   begin
                    if StrToInt(pars[4]) < FME_LIST.Count then
                     TheObject.DataName := FME_LIST[StrToInt(pars[4])];
                   end;
                  if pars[2] = '3D' then
                   begin
                    if StrToInt(pars[4]) < POD_LIST.Count then
                     TheObject.DataName := POD_LIST[StrToInt(pars[4])];
                   end;
                  if pars[2] = 'SOUND' then
                   begin
                    if StrToInt(pars[4]) < SND_LIST.Count then
                     TheObject.DataName := SND_LIST[StrToInt(pars[4])];
                   end;

                  Val(pars[6] , tmpreal, code);  TheObject.X   := tmpreal;
                  Val(pars[8] , tmpreal, code);  TheObject.Y   := -tmpreal;
                  Val(pars[10], tmpreal, code);  TheObject.Z   := tmpreal;
                  Val(pars[12], tmpreal, code);  TheObject.PCH := tmpreal;
                  Val(pars[14], tmpreal, code);  TheObject.YAW := tmpreal;
                  Val(pars[16], tmpreal, code);  TheObject.ROL := tmpreal;

                  TheObject.Diff := StrToInt(pars[18]);

                  {!!!!! WDFUSE addition to O file !!!!!}
                  if pars.Count > 20 then
                   begin
                    TheObject.Sec := StrToInt(pars[20]);
                   end
                  else
                   TheObject.Sec  := -1;

                  { Encore remplir Type, Col, Special }
                  TheObject.Col := COLORini.ReadInteger(TheObject.DataName, 'COLOR', Ccol_shadow);
                  TheObject.OType := 0;
                  TheObject.Special := 0; {temporary}
                 end;
              finally
                pars.Free;
              end;

              First := FALSE;
              Inc(obcount);
              if obcount mod 20 = 19 then
               ProgressWindow.Gauge.Progress := ProgressWindow.Gauge.Progress + 20;
            end
          else
          {must be before seq !}
          if Pos('SEQEND', UpperCase(strin)) = 1 then
           begin
            {forget seqend}
           end
          else
          if Pos('SEQ', UpperCase(strin)) = 1 then
           begin
            {forget seq}
           end
          else
          if Pos('LEVELNAME', UpperCase(strin)) = 1 then
           begin
            pars := TStringParser.Create(strin);
            try
             if pars.Count > 2 then O_LEVELNAME := pars[2];
            finally
             pars.Free;
            end;
           end
          else
          if Pos('PODS', UpperCase(strin)) = 1 then
            begin
              pars := TStringParser.Create(strin);
              try
                if pars.Count > 2 then pods := StrToInt(pars[2]);
              finally
                pars.Free;
              end;
            end
          else
          if Pos('POD:', UpperCase(strin)) = 1 then
            begin
              pars := TStringParser.Create(strin);
              try
                if pars.Count > 2 then POD_LIST.Add(pars[2]);
                {ProgressWindow.Gauge.Progress := ProgressWindow.Gauge.Progress + 1;}
              finally
                pars.Free;
              end;
            end
          else
          if Pos('SPRS', UpperCase(strin)) = 1 then
            begin
              pars := TStringParser.Create(strin);
              try
                if pars.Count > 2 then sprs := StrToInt(pars[2]);
              finally
                pars.Free;
              end;
            end
          else
          if Pos('SPR:', UpperCase(strin)) = 1 then
            begin
              pars := TStringParser.Create(strin);
              try
                if pars.Count > 2 then SPR_LIST.Add(pars[2]);
                {ProgressWindow.Gauge.Progress := ProgressWindow.Gauge.Progress + 1;}
              finally
                pars.Free;
              end;
            end
          else
          if Pos('FMES', UpperCase(strin)) = 1 then
            begin
              pars := TStringParser.Create(strin);
              try
                if pars.Count > 2 then fmes := StrToInt(pars[2]);
              finally
                pars.Free;
              end;
            end
          else
          if Pos('FME:', UpperCase(strin)) = 1 then
            begin
              pars := TStringParser.Create(strin);
              try
                if pars.Count > 2 then FME_LIST.Add(pars[2]);
                {ProgressWindow.Gauge.Progress := ProgressWindow.Gauge.Progress + 1;}
              finally
                pars.Free;
              end;
            end
          else
          if Pos('SOUNDS', UpperCase(strin)) = 1 then
            begin
              pars := TStringParser.Create(strin);
              try
                if pars.Count > 2 then snds := StrToInt(pars[2]);
              finally
                pars.Free;
              end;
            end
          else
          if Pos('SOUND:', UpperCase(strin)) = 1 then
            begin
              pars := TStringParser.Create(strin);
              try
                if pars.Count > 2 then SND_LIST.Add(pars[2]);
                {ProgressWindow.Gauge.Progress := ProgressWindow.Gauge.Progress + 1;}
              finally
                pars.Free;
              end;
            end
          else
          if Pos('OBJECTS', UpperCase(strin)) = 1 then
            begin
              pars := TStringParser.Create(strin);
              try
                if pars.Count > 2 then numobjects := StrToInt(pars[2]);
                ProgressWindow.Gauge.MaxValue     := numobjects;
                ProgressWindow.Gauge.Progress     := 0;
                ProgressWindow.Progress2.Caption  := 'Parsing OBJECTS...';
                ProgressWindow.Progress2.Update;
              finally
                pars.Free;
              end;
            end
          else
          {O MUST be after OBJECTS !!!}
          if Pos('O', UpperCase(strin)) = 1 then
            begin
             pars := TStringParser.Create(strin);
             try
              if pars.Count > 2 then O_VERSION := pars[2];
             finally
              pars.Free;
             end;
            end
          else
           begin
            {add this line to current SEQ list}
            TheObject.Seq.Add(strin);
           end;
        end;

      { add last object}
      MAP_OBJ.AddObject('OB', TheObject);
      System.CloseFile(o);
      COLORini.Free;

      {check for generators}
      for i := 0 to MAP_OBJ.Count - 1 do
       begin
        TheObject := TOB(MAP_OBJ.Objects[i]);
        if TheObject.Seq.Count <> 0 then
         begin
          pars := TStringParser.Create(TheObject.Seq[0]);
          try
           if pars.Count > 2 then
            if pars[2] = 'GENERATOR' then
             TheObject.Special := 1
            else
             TheObject.Special := 0
           else
            TheObject.Special := 0;
          finally
           pars.Free;
          end;
         end;
       end;

      ProgressWindow.Hide;

      OFILELoaded := TRUE;
      SetCursor(OldCursor);
      IO_ReadO := TRUE;
    end;
end;

function  IO_WriteO(oname : TFileName) : Boolean;
var o         : System.TextFile;
    OldCursor : HCursor;
    TheData   : Integer;
    TheObject : TOB;
    numobjects: Integer;
    s,i       : Integer;
begin
 {check registration again}

 OldCursor  := SetCursor(LoadCursor(0, IDC_WAIT));
 numobjects := MAP_OBJ.Count;

 ProgressWindow.Progress1.Caption := 'Saving O File';
 ProgressWindow.Gauge.Progress    := 0;
 ProgressWindow.Gauge.MinValue    := 0;
 ProgressWindow.Gauge.MaxValue    := 0;
 ProgressWindow.Show;
 ProgressWindow.Update;

 AssignFile(o, oname);
 Rewrite(o);

 WriteLn(o, 'O ', O_VERSION);
 WriteLn(o, '/*');
 WriteLn(o, '# GENERATED BY WDFUSE ', WDFUSE_VERSION);
 WriteLn(o, '# (c) Yves BORCKMANS 1995-1996');
 WriteLn(o, '#');
 WriteLn(o, '# GENTIME ', DateTimeToStr(Now));
 WriteLn(o, '#');
 WriteLn(o, '# AUTHOR ', USERname);
 WriteLn(o, '# EMAIL  ', USERemail);
 WriteLn(o, '#');
 WriteLn(o, '# GENERAL LEVEL INFORMATION');
 WriteLn(o, '# =========================');
 WriteLn(o, '*/');
 WriteLn(o, 'LEVELNAME ', O_LEVELNAME);
 WriteLn(o, '');

 DO_RecomputeObjectsLists(TRUE, 'Saving O File');
 
 {PODS}
 WriteLn(o, '/*');
 WriteLn(o, '# 3D OBJECTS');
 WriteLn(o, '# ==========');
 WriteLn(o, '*/');

 WriteLn(o, 'PODS ', POD_LIST.Count);
 for i := 0 to POD_LIST.Count - 1 do
  begin
   WriteLn(o, ' POD: ', RPad(POD_LIST[i],13) , '# ', Format('%-3.3d', [i]));
  end;
 WriteLn(o, '');

{SPRITES}
 WriteLn(o, '/*');
 WriteLn(o, '# SPRITES');
 WriteLn(o, '# =======');
 WriteLn(o, '*/');

 WriteLn(o, 'SPRS ', SPR_LIST.Count);
 for i := 0 to SPR_LIST.Count - 1 do
  begin
   WriteLn(o, ' SPR: ', RPad(SPR_LIST[i],13) , '# ', Format('%-3.3d', [i]));
  end;
 WriteLn(o, '');

 {FRAMES}
 WriteLn(o, '/*');
 WriteLn(o, '# FRAMES');
 WriteLn(o, '# ======');
 WriteLn(o, '*/');

 WriteLn(o, 'FMES ', FME_LIST.Count);
 for i := 0 to FME_LIST.Count - 1 do
  begin
   WriteLn(o, ' FME: ', RPad(FME_LIST[i],13) , '# ', Format('%-3.3d', [i]));
  end;
 WriteLn(o, '');

 {SOUNDS}
 WriteLn(o, '/*');
 WriteLn(o, '# SOUNDS');
 WriteLn(o, '# ======');
 WriteLn(o, '*/');

 WriteLn(o, 'SOUNDS ', SND_LIST.Count);
 for i := 0 to SND_LIST.Count - 1 do
  begin
   WriteLn(o, ' SOUND: ', RPad(SND_LIST[i],13) , '# ', Format('%-3.3d', [i]));
  end;
 WriteLn(o, '');

 WriteLn(o, '/*');
 WriteLn(o, '# OBJECT DEFINITIONS');
 WriteLn(o, '# ==================');
 WriteLn(o, '*/');
 WriteLn(o, 'OBJECTS ', numobjects);
 WriteLn(o, '');

 ProgressWindow.Progress2.Caption := 'Writing OBJECTS...';
 ProgressWindow.Gauge.Progress    := 0;
 ProgressWindow.Gauge.MaxValue    := numobjects;
 ProgressWindow.Progress2.Update;

 for s := 0 to MAP_OBJ.Count - 1 do
  begin
   TheObject := TOB(MAP_OBJ.Objects[s]);
   WriteLn(o, Format('/* %-3.3d %s */', [s, RPad(TheObject.DataName, 13)]));

   if TheObject.ClassName = 'SPIRIT' then TheData := 0;
   if TheObject.ClassName = 'SAFE'   then TheData := 0;
   if TheObject.ClassName = '3D'     then TheData := POD_LIST.IndexOf(TheObject.DataName);
   if TheObject.ClassName = 'SPRITE' then TheData := SPR_LIST.IndexOf(TheObject.DataName);
   if TheObject.ClassName = 'FRAME'  then TheData := FME_LIST.IndexOf(TheObject.DataName);
   if TheObject.ClassName = 'SOUND'  then TheData := SND_LIST.IndexOf(TheObject.DataName);

   with TheObject do
   WriteLn(o, Format('CLASS: %s DATA: %2d X: %-5.2f Y: %-5.2f Z: %-5.2f PCH: %-5.2f YAW: %-5.2f ROL: %-5.2f DIFF: %d SEC: %d',
                      [ RPad(ClassName, 7), TheData, X, -Y, Z, Pch, Yaw, Rol, Diff, Sec ]));

   if TheObject.Seq.Count <> 0 then
    begin
     WriteLn(o, ' SEQ');
      for i := 0 to TheObject.Seq.Count - 1 do
       WriteLn(o, Format('  %s', [TheObject.Seq[i]]));
     WriteLn(o, ' SEQEND');
    end;

   WriteLn(o, '');
   if s mod 20 = 19 then
    ProgressWindow.Gauge.Progress := ProgressWindow.Gauge.Progress + 20;
  end;

 System.CloseFile(o);
 ProgressWindow.Hide;
 SetCursor(OldCursor);
 IO_WriteO := TRUE;
end;

procedure IO_ReadINF(infname : TFileName);
begin
 IO_ReadINF2(infname);
end;

procedure IO_ReadINF2(infname : TFileName);
var i,j,k    : Integer;
   strin     : string;
   oname     : string;
   onum      : Integer;
   lastnum   : Integer;
   otype     : char;
   Comment   : Boolean;
   StrList   : TStringList;
   pars      : TStringParserWithColon;
   OldCursor : HCursor;
   sc        : Integer;
   TheSector : TSector;
   TheWall   : TWall;
   TheInfClass : TInfClass;
   infcount  : Integer;
begin
   OldCursor := SetCursor(LoadCursor(0, IDC_WAIT));

   {first create all the flag and exploding door, and secret things
    for all sectors}
   for i := 0 to MAP_SEC.Count - 1 do
    begin
      TheSector := TSector(MAP_SEC.Objects[i]);
      TheSector.Elevator := FALSE;
      TheSector.Trigger := FALSE;
      if (TheSector.Flag1 and 524288) <> 0 then
       TheSector.Secret := TRUE
      else
       TheSector.Secret := FALSE;

      for j := 0 to TheSector.InfClasses.Count - 1 do
       begin
        TInfClass(TheSector.InfClasses.Objects[j]).Free;
       end;
      TheSector.InfClasses.Clear;

      if (TheSector.Flag1 and 2) <> 0 then
       begin
        TheInfClass := TInfClass.Create;
        TheInfClass.IsElev := TRUE;
        TheInfClass.Name := 'E. FLAG Door';
        TheSector.InfClasses.AddObject('D', TheInfClass);
        TheSector.Elevator := TRUE;
       end;

      if (TheSector.Flag1 and 64) <> 0 then
       begin
        TheInfClass := TInfClass.Create;
        TheInfClass.IsElev := TRUE;
        TheInfClass.Name := 'E. FLAG Exploding';
        TheSector.InfClasses.AddObject('X', TheInfClass);
        TheSector.Elevator := TRUE;
       end;

      for j := 0 to TheSector.Wl.Count - 1 do
       begin
        TheWall := TWall(TheSector.Wl.Objects[j]);
        TheWall.Elevator := FALSE;
        TheWall.Trigger  := FALSE;

        for k := 0 to TheWall.InfClasses.Count - 1 do
         begin
          TInfClass(TheWall.InfClasses.Objects[k]).Free;
         end;
        TheWall.InfClasses.Clear;
       end;
    end;

   Comment := FALSE;
   lastnum := 0;

   AssignFile(inf, infname);
   Reset(inf);

   {create the INFComments stringlist to store beginning comments}
   INFComments := TStringList.Create;
   {and the INFErrors stringlist to store errors}
   INFErrors := TStringList.Create;
   {and the INFLevel stringlist to store item: level entries}
   INFLevel  := TStringList.Create;

   {start a new string list}
   StrList := TStringList.Create;

   ProgressWindow.Progress1.Caption := 'Loading INF File';
   ProgressWindow.Progress2.Caption := 'Reading INF items...';
   ProgressWindow.Gauge.Progress    := 0;
   ProgressWindow.Gauge.MinValue    := 0;
   ProgressWindow.Gauge.MaxValue    := 0;
   ProgressWindow.Show;
   ProgressWindow.Update;

   while not SeekEof(inf) do
   begin
     if SeekEoln(inf) then StrList.Add(' ');

     Readln(inf, strin);

     if Pos('/*', strin) = 1 then
       begin
         StrList.Add(strin);
         if Pos('*/', strin) = 0 then Comment := TRUE;
       end
     else
     if Pos('*/', strin) <> 0 then
       begin
         StrList.Add(strin);
         Comment := FALSE;
       end
     else
     if Pos('inf', LowerCase(strin)) = 1 then
       begin
          {StrList.Add(strin); will use header editor instead}
          pars := TStringParserWithColon.Create(strin);
          try
           if pars.Count > 2 then
            INF_VERSION := pars[2]
           else
            INF_VERSION := '1.0';
          finally
           pars.Free;
          end;
       end
     else
     if Pos('levelname', LowerCase(strin)) = 1 then
       begin
          {StrList.Add(strin); will use header editor instead}
          pars := TStringParserWithColon.Create(strin);
          try
           if pars.Count > 2 then INF_LEVELNAME := pars[2];
          finally
           pars.Free;
          end;
       end
     else
     if Pos('items', LowerCase(strin)) = 1 then
       begin
          {don't write items, it will be computed}
          {StrList.Add(strin);}

          {here we store the main comments (ie before items)}
          INFComments.AddStrings(StrList);
          StrList.Free;

          {start new string list}
          StrList := TStringList.Create;

          {get the items count for progress bar}
          pars := TStringParserWithColon.Create(strin);
          try
           if pars.Count > 2 then
            infcount := StrToInt(pars[2])
           else
            infcount := 999;
          except
           on EConvertError do infcount := 999;
          end;
          pars.Free;
          ProgressWindow.Gauge.MaxValue    := infcount;
          infcount := 0;
       end
     else
     if Comment then
       begin
         StrList.Add(strin);
       end
     else
     if Pos('item:', LowerCase(strin)) = 1 then
       begin
         pars := TStringParserWithColon.Create(strin);
         try
           if LowerCase(pars[2]) = 'level' then
            begin
             oname := '?yb?'; {force it wrong!}
             otype := 'L';
            end
           else
           if LowerCase(pars[2]) = 'sector' then
             if pars.Count > 4 then
              begin
               oname := pars[4];
               otype := 'S';
              end
             else
              begin
               oname := '?yb?';
               otype := 'S';
              end
           else
             if pars.Count > 6 then
              begin
               oname := pars[4];
               onum  := StrToIntDef(pars[6], 0);
               lastnum := onum;
               otype := 'W';
              end
             else
              begin
               if pars.Count > 4 then
                begin
                 oname := pars[4];
                 onum  := lastnum;
                 otype := 'W';
                end
               else
                begin
                 oname := '?yb?';
                 onum  := 0;
                 otype := 'W';
                end;
              end;
         finally
           pars.Free;
         end;
         Inc(infcount);
         if infcount mod 10 = 9 then
          ProgressWindow.Gauge.Progress := ProgressWindow.Gauge.Progress + 10;
       end
     else
     if Pos('seqend', LowerCase(strin)) = 1 then
       begin
         StrList.Add('seqend');
         {add the stringlist to its correct sc or wl}
         if GetSectorNumFromNameNoCase(oname, sc) then
          begin
           TheSector := TSector(MAP_SEC.Objects[sc]);
           if otype = 'S' then
            begin
             TheSector.InfItems.AddStrings(StrList);
             ComputeINFClasses(sc, -1);
            end
           else
            begin
             if onum >= TheSector.WL.Count then
              begin
               onum := 0; {careful !}
               StrList.Add('/* Invalid wall set to 0 ! */');
              end;
             TheWall := TWall(TheSector.Wl.Objects[onum]);
             TheWall.InfItems.AddStrings(StrList);
             ComputeINFClasses(sc, onum);
            end;
          end
         else
          begin
           {sector not found, add to the INFErrors part unless it is an item: level}
           if otype = 'L' then
            begin
             INFLevel.Add('item: level');
             INFLevel.AddStrings(StrList);
             INFLevel.Add(' ');
            end
           else
            begin
             CASE otype of
              'S' : INFErrors.Add('item: sector name: ????????');
              'W' : INFErrors.Add('item: line   name: ???????? num: 0');
             END;
             INFErrors.AddStrings(StrList);
             INFErrors.Add(' ');
            end;
          end;

         StrList.Free;
         {start new string list, so that interitems comments will be ok}
         StrList := TStringList.Create;
       end
     else
     {must be AFTER !!! seqend, else seqend is never found !!!}
     if Pos('seq', LowerCase(strin)) = 1 then
       begin
         StrList.Add('seq');
       end
     else
       begin
         StrList.Add(LTrim(Rtrim(strin)));
       end;
   end;

   System.CloseFile(inf);
   {because a new StrList is created after the last seqend}
   StrList.Free;
   INFFILELoaded := TRUE;
   ProgressWindow.Hide;
   SetCursor(OldCursor);
end;


procedure IO_WriteINF2(infname : TFileName);
var i,j,k,l  : Integer;
   OldCursor : HCursor;
   TheSector : TSector;
   TheWall   : TWall;
   INFcount  : Integer;
   INFList   : TStringList;
   errmsg    : String;
   TheINFSeq : TINFSequence;
   foundcopy : Boolean;
begin
 OldCursor := SetCursor(LoadCursor(0, IDC_WAIT));

 ProgressWindow.Progress1.Caption := 'Writing INF File';
 ProgressWindow.Progress2.Caption := 'Writing INF items...';
 ProgressWindow.Gauge.Progress    := 0;
 ProgressWindow.Gauge.MinValue    := 0;
 ProgressWindow.Gauge.MaxValue    := 0;
 ProgressWindow.Show;
 ProgressWindow.Update;

 AssignFile(inf, infname);
 Rewrite(inf);

 WriteLn(inf, 'INF ' + INF_VERSION);
 WriteLn(inf, 'LEVELNAME ' + INF_LEVELNAME);
 WriteLn(inf, ' ');

 foundcopy := FALSE;
 for i := 0 to INFComments.Count - 1 do
  begin
   if Copy(INFComments[i], 1, 22) = '/* GENERATED BY WDFUSE' then
    foundcopy := TRUE;
  end;

 if not foundcopy then
  begin
   WriteLn(inf, '/* GENERATED BY WDFUSE '+WDFUSE_VERSION+' ON '+ DateTimeToStr(Now));
   WriteLn(inf, '   WDFUSE is (c) Yves BORCKMANS 1995-1996');
   WriteLn(inf, ' ');
   WriteLn(inf, '   AUTHOR ', USERname);
   WriteLn(inf, '   EMAIL  ', USERemail);
   WriteLn(inf, ' ');
   WriteLn(inf, '*/');
   WriteLn(inf, ' ');
  end;

 for i := 0 to INFComments.Count - 1 do
  begin
   if Copy(INFComments[i], 1, 22) = '/* GENERATED BY WDFUSE' then
    WriteLn(inf, '/* GENERATED BY WDFUSE '+WDFUSE_VERSION+' ON '+ DateTimeToStr(Now))
   else
    WriteLn(inf, INFComments[i]);
  end;
 WriteLn(inf, ' ');

 {first count the items and find if there are errors,
  simply count the number of "item:" to account for errors, etc.
  If a sector/wall has an Inf item and no name, it is simply assumed
  "__wdfuse__" to be consistent. The user will have to correct that,
  and before doing this he should do consistency checks.}

 INFcount := 0;

 {NORMAL items}
 for i := 0 to MAP_SEC.Count - 1 do
  begin
   TheSector := TSector(MAP_SEC.Objects[i]);
   for k := 0 to TheSector.InfItems.Count - 1 do
    begin
     {count the seqend, easier}
     if Pos('seqend', LTrim(TheSector.InfItems[k])) = 1 then Inc(INFCount);
    end;
   for j := 0 to TheSector.Wl.Count - 1 do
    begin
     TheWall := TWall(TheSector.Wl.Objects[j]);
     for k := 0 to TheWall.InfItems.Count - 1 do
      begin
       if Pos('seqend', LTrim(TheWall.InfItems[k])) = 1 then Inc(INFCount);
      end;
    end;
  end;

 {LEVEL items}
 for k := 0 to INFLevel.Count - 1 do
  begin
   if Pos('seqend', LTrim(INFLevel[k])) = 1 then Inc(INFCount);
  end;

 {ERRORS items}
 for k := 0 to INFErrors.Count - 1 do
  begin
   if Pos('seqend', LTrim(INFErrors[k])) = 1 then Inc(INFCount);
  end;

 WriteLn(inf, 'ITEMS ' + IntToStr(INFCount));
 WriteLn(inf, ' ');

 {first any possible item: level}
 for i := 0 to INFLevel.Count - 1 do WriteLn(inf, INFLevel[i]);
 WriteLn(inf, ' ');

 ProgressWindow.Gauge.MaxValue    := MAP_SEC.Count - 1;

 {then all other items}
 for i := 0 to MAP_SEC.Count - 1 do
  begin
   TheSector := TSector(MAP_SEC.Objects[i]);
   INFList := TStringList.Create;
   CASE ParseINFItemsSCWL(i, -1, INFList, errmsg) OF
    -2 : ;
    -1 : begin
          {no error, spruce the result}
          for k := 0 to INFList.Count - 1 do
           begin
            {first Output the comments}
            WriteLn(inf, ' ');
            TheINFSeq := TINFSequence(INFList.Objects[k]);
            for l := 0 to TheInfSeq.Comments.Count - 1 do
             WriteLn(inf, TheInfSeq.Comments[l]);
            MapWindow.HiddenINFOutMemo.Clear;
            INFListToMemoByItem(INFList, k, MapWindow.HiddenINFOutMemo, TRUE, FALSE);
            WriteLn(inf, ' ');
            if TheSector.Name <> '' then
             WriteLn(inf, 'item: sector name: ' + TheSector.Name)
            else
             WriteLn(inf, 'item: sector name: __wdfuse__');
            for l := 0 to MapWindow.HiddenINFOutMemo.Lines.Count - 1 do
             WriteLn(inf, ' ' + MapWindow.HiddenINFOutMemo.Lines[l]);
           end;
         end;
    ELSE begin
          {error found, just output the thing nearly as is,
           if a line begins with seq (but not seqend), then
           add item: before it}
           WriteLn(inf, ' ');
           for l := 0 to TheSector.InfItems.Count - 1 do
            begin
             if Pos('seq', LTrim(TheSector.InfItems[l])) = 1 then
              if Pos('seqend', LTrim(TheSector.InfItems[l])) <> 1 then
               begin
                WriteLn(inf, ' ');
                if TheSector.Name <> '' then
                 WriteLn(inf, 'item: sector name: ' + TheSector.Name)
                else
                 WriteLn(inf, 'item: sector name: __wdfuse__');
               end;

             WriteLn(inf, ' ' + TheSector.InfItems[l]);
            end;
         end;
   END;
   FreeINFList(INFList);

   for j := 0 to TheSector.Wl.Count - 1 do
    begin
     TheWall := TWall(TheSector.Wl.Objects[j]);
     INFList := TStringList.Create;
     CASE ParseINFItemsSCWL(i, j, INFList, errmsg) OF
      -2 : ;
      -1 : begin
            {no error, spruce the result}
            for k := 0 to INFList.Count - 1 do
             begin
              {first Output the comments}
              WriteLn(inf, ' ');
              TheINFSeq := TINFSequence(INFList.Objects[k]);
              for l := 0 to TheInfSeq.Comments.Count - 1 do
               WriteLn(inf, TheInfSeq.Comments[l]);
              MapWindow.HiddenINFOutMemo.Clear;
              WriteLn(inf, ' ');
              INFListToMemoByItem(INFList, k, MapWindow.HiddenINFOutMemo, TRUE, FALSE);
              if TheSector.Name <> '' then
               WriteLn(inf, 'item: line   name: ' + TheSector.Name + ' num: ' + IntToStr(j))
              else
               WriteLn(inf, 'item: line   name: __wdfuse__' + ' num: ' + IntToStr(j));
              for l := 0 to MapWindow.HiddenINFOutMemo.Lines.Count - 1 do
               WriteLn(inf, ' ' + MapWindow.HiddenINFOutMemo.Lines[l]);
             end;
           end;
      ELSE begin
            {error found, just output the thing nearly as is,
             if a line begins with seq (but not seqend), then
             add item: before it}
             WriteLn(inf, ' ');
             for l := 0 to TheWall.InfItems.Count - 1 do
              begin
               if Pos('seq', LTrim(TheWall.InfItems[l])) = 1 then
                if Pos('seqend', LTrim(TheWall.InfItems[l])) <> 1 then
                 begin
                  WriteLn(inf, ' ');
                  if TheSector.Name <> '' then
                   WriteLn(inf, 'item: line   name: ' + TheSector.Name + ' num: ' + IntToStr(j))
                  else
                   WriteLn(inf, 'item: line   name: __wdfuse__' + ' num: ' + IntToStr(j));
                 end;

               WriteLn(inf, ' ' + TheWall.InfItems[l]);
              end;
           end;
     END;
     FreeINFList(INFList);
    end;

   if i mod 30 = 29 then
    ProgressWindow.Gauge.Progress := ProgressWindow.Gauge.Progress + 30;
  end;

 MapWindow.HiddenINFOutMemo.Clear;

 {last any possible errors}
 for i := 0 to INFErrors.Count - 1 do WriteLn(inf, INFErrors[i]);
 WriteLn(inf, ' ');

 System.CloseFile(inf);

 ProgressWindow.Hide;
 SetCursor(OldCursor);
end;

procedure IO_ReadGOL(golname : TFileName);
var i,j,k    : Integer;
   strin     : string;
   Comment   : Boolean;
   pars      : TStringParserWithColon;
   OldCursor : HCursor;
begin
   OldCursor := SetCursor(LoadCursor(0, IDC_WAIT));

   Comment := FALSE;

   AssignFile(gol, golname);
   Reset(gol);

   {create the GOLComments stringlist to store beginning comments}
   GOLComments := TStringList.Create;
   {and the GOLErrors stringlist to store errors}
   GOLErrors := TStringList.Create;

   while not SeekEof(gol) do
   begin
     Readln(gol, strin);

     if Pos('#', strin) = 1 then
       begin
         GOLComments.Add(strin);
       end
     else
     if Pos('gol', LowerCase(strin)) = 1 then
       begin
          pars := TStringParserWithColon.Create(strin);
          try
           if pars.Count > 2 then
            GOL_VERSION := pars[2]
           else
            GOL_VERSION := '1.0';
          finally
           pars.Free;
          end;
       end
     else
     if Pos('goal:', LowerCase(strin)) = 1 then
       begin
          {
          pars := TStringParserWithColon.Create(strin);
          try
           if pars.Count > 2 then INF_LEVELNAME := pars[2];
          finally
           pars.Free;
          end;
          }
       end
     else
       begin
         GOLErrors.Add(strin);
       end;
   end;

   System.CloseFile(gol);
   GOLFILELoaded := TRUE;
   SetCursor(OldCursor);
end;

procedure IO_WriteGOL(golname : TFileName);
begin
end;

end.
