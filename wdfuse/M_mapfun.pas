unit M_mapfun;

interface
uses
  SysUtils, WinTypes, WinProcs, Graphics, IniFiles, Dialogs, Forms, Classes,
  _Math, _Strings,
  M_Global, M_Util,   M_io, M_Progrs, M_smledt, M_Multi,
  M_Editor, M_SCedit, M_WLedit, M_VXedit, M_OBedit, I_Util ;


VAR
 {reference point for deformations}
 DEFORM_X,
 DEFORM_Z   : Real;

function  MakeAdjoin(sc, wl : Integer) : Boolean;
function  MakeLayerAdjoin(sc, wl : Integer) : Boolean;
function  UnAdjoin(sc, wl : Integer) : Boolean;
function  MultiMakeAdjoin : Integer;
function  MultiUnAdjoin : Integer;

procedure ShellInsertSC(cursX, cursZ : Real);
function  DeleteSC(sc : Integer) : Boolean;
procedure MultiDeleteSC;
procedure ShellDeleteSC;

procedure ShellInsertOB(cursX, cursZ : Real);
function  DeleteOB(ob : Integer) : Boolean;
procedure MultiDeleteOB;
procedure ShellDeleteOB;

procedure ShellExtrudeWL(sc, wl : Integer);
procedure ShellSplitWL(sc, wl : Integer);
procedure SplitWL(sc, wl : Integer);
function  ShellDeleteWL(sc, wl : Integer) : Boolean;

procedure ShellSplitVX(sc, vx : Integer);
procedure ShellDeleteVX(sc, vx : Integer);

{ CYCLES functions !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}

{ return 0 in error, or the number of cycles }
function  SetSectorCycles(sc : Integer) : Integer;
function  GetCycleLen(sc, cy : Integer) : Integer;
function  GetCycleFirstWl(sc, cy : Integer) : Integer;
function  GetCycleFirstVx(sc, cy : Integer) : Integer;

function  VxToPoint(vx : TVertex) : TPoint;

// normalization
function  NormalizeWall(AWall : TWall) : TWall;
function  NormalizeOffsets(WallTexture : TTEXTURE) : TTEXTURE;

{
function GetCycleNextVx(sc, cy, vx : Integer) : Integer;
function GetCycleNextWl(sc, cy, wl : Integer) : Integer;
}

procedure DO_Polygon;
procedure CreatePolygon(Sides : Integer; Radius, CX, CZ : Real; PolyType, sc : Integer);
procedure CreatePolygonGap(Sides : Integer; Radius, CX, CZ : Real; sc : Integer);
procedure CreatePolygonSector(Sides : Integer; Radius, CX, CZ : Real; sc : Integer);
function  GetSectorMaxradius(sc : Integer) : integer;
function  VerifyPolygonFits(Sides : Integer; Radius, CX, CZ : Real; sc : Integer) : Boolean;

procedure DO_Distribute(Altitudes : Boolean; FlCe : Integer; Ambient : Boolean);

procedure DO_StitchHorizontal(Mid, Top, Bot : Boolean);
procedure DO_StitchHorizontalInvert(Mid, Top, Bot : Boolean);
procedure DO_StitchVertical(Mid, Top, Bot : Boolean);

procedure DO_PrepareDeformation;
procedure DO_Translate(x, z : Real);
procedure DO_Rotate(angle : Real; OBOrient : Boolean);
procedure DO_Scale(factor : Real);

procedure DO_PrepareFlipping;
procedure DO_Flip(Horiz : Boolean; OBOrient : Boolean);
procedure SwapWLContents(sc, wl1, wl2 : Integer);

procedure DO_OffsetAltitude(y : Real; alt : Integer);
procedure DO_OffsetAmbient(a : Integer);

procedure DO_SplitSector(s, d, n, sc, wl1, wl2 : Integer);

implementation
uses Mapper, M_Tools, v_util32;

{ADJOINS ********************************************************************}
{ADJOINS ********************************************************************}
{ADJOINS ********************************************************************}

function MakeAdjoin(sc, wl : Integer) : Boolean;
var s,w        : Integer;
    TheSector1 : TSector;
    TheSector2 : TSector;
    TheWall1   : TWall;
    TheWall2   : TWall;
    LVertex1   : TVertex;
    RVertex1   : TVertex;
    LVertex2   : TVertex;
    RVertex2   : TVertex;
    found      : Boolean;
begin
  DO_StoreUndo;
  MakeAdjoin := FALSE;
  TheSector1 := TSector(MAP_SEC.Objects[sc]);
  TheWall1   := TWall(TheSector1.Wl.Objects[wl]);
  if TheWall1.Adjoin <> -1 then exit;

  LVertex1 := TVertex(TheSector1.Vx.Objects[TheWall1.left_vx]);
  RVertex1 := TVertex(TheSector1.Vx.Objects[TheWall1.right_vx]);
  found    := FALSE;

  for s := 0 to MAP_SEC.Count - 1 do
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
        TheWall2.Adjoin := sc;
        TheWall2.Mirror := wl;
        TheWall2.Walk   := sc;
        TheWall1.Adjoin := s;
        TheWall1.Mirror := w;
        TheWall1.Walk   := s;

        MODIFIED   := TRUE;
        found      := TRUE;
        MakeAdjoin := TRUE;
       end;

      if found then break;
     end;
     if found then break;
   end;
end;

function MakeLayerAdjoin(sc, wl : Integer) : Boolean;
var s,w        : Integer;
    TheSector1 : TSector;
    TheSector2 : TSector;
    TheWall1   : TWall;
    TheWall2   : TWall;
    LVertex1   : TVertex;
    RVertex1   : TVertex;
    LVertex2   : TVertex;
    RVertex2   : TVertex;
    found      : Boolean;
begin
  DO_StoreUndo;
  MakeLayerAdjoin := FALSE;
  TheSector1 := TSector(MAP_SEC.Objects[sc]);
  TheWall1   := TWall(TheSector1.Wl.Objects[wl]);
  if TheWall1.Adjoin <> -1 then exit;

  LVertex1 := TVertex(TheSector1.Vx.Objects[TheWall1.left_vx]);
  RVertex1 := TVertex(TheSector1.Vx.Objects[TheWall1.right_vx]);
  found    := FALSE;

  for s := 0 to MAP_SEC.Count - 1 do
   begin
    TheSector2 := TSector(MAP_SEC.Objects[s]);
    if TheSector1.Layer <> TheSector2.Layer then continue;
    for w := 0 to TheSector2.Wl.Count - 1 do
     begin
      TheWall2 := TWall(TheSector2.Wl.Objects[w]);
      LVertex2 := TVertex(TheSector2.Vx.Objects[TheWall2.left_vx]);
      RVertex2 := TVertex(TheSector2.Vx.Objects[TheWall2.right_vx]);

      {if found do the adjoin and prepare to break out of both loops}
      if ((LVertex1.X = RVertex2.X) and (LVertex1.Z = RVertex2.Z)) and
         ((RVertex1.X = LVertex2.X) and (RVertex1.Z = LVertex2.Z)) then
       begin
        TheWall2.Adjoin := sc;
        TheWall2.Mirror := wl;
        TheWall2.Walk   := sc;
        TheWall1.Adjoin := s;
        TheWall1.Mirror := w;
        TheWall1.Walk   := s;

        MODIFIED   := TRUE;
        found      := TRUE;
        MakeLayerAdjoin := TRUE;
       end;

      if found then break;
     end;
     if found then break;
   end;
end;

{-----------------------------------------------------------------------------}

function UnAdjoin(sc, wl : Integer) : Boolean;
var TheSector1 : TSector;
    TheSector2 : TSector;
    TheWall1   : TWall;
    TheWall2   : TWall;
begin
  DO_StoreUndo;
  UnAdjoin := FALSE;
  TheSector1 := TSector(MAP_SEC.Objects[sc]);
  TheWall1   := TWall(TheSector1.Wl.Objects[wl]);
  if TheWall1.Adjoin = -1 then exit;
  if (TheWall1.Adjoin < -1) or (TheWall1.Adjoin >= MAP_SEC.Count) then
   begin
    ShowMessage(Format('Invalid Adjoin found in SC : %d WL : %d', [sc, wl]));
    exit;
   end;

  TheSector2 := TSector(MAP_SEC.Objects[TheWall1.Adjoin]);
  if (TheWall1.Mirror < 0) or (TheWall1.Mirror >= TheSector2.Wl.Count) then
   begin
    ShowMessage(Format('Invalid Mirror found in SC : %d WL : %d', [sc, wl]));
    exit;
   end;
  TheWall2   := TWall(TheSector2.Wl.Objects[TheWall1.Mirror]);
  TheWall2.Adjoin := -1;
  TheWall2.Mirror := -1;
  TheWall2.Walk   := -1;
  TheWall1.Adjoin := -1;
  TheWall1.Mirror := -1;
  TheWall1.Walk   := -1;
  UnAdjoin := TRUE;
end;

{-----------------------------------------------------------------------------}

function MultiMakeAdjoin : Integer;
var m, s, w  : Integer;
    OldCursor : HCursor;
begin
DO_StoreUndo;
Result := 0;
OldCursor  := SetCursor(LoadCursor(0, IDC_WAIT));
if WL_MULTIS.Count <> 0 then
 for m := 0 to WL_MULTIS.Count - 1 do
  begin
   s := StrToInt(Copy(WL_MULTIS[m],1,4));
   w := StrToInt(Copy(WL_MULTIS[m],5,4));
   if MakeAdjoin(s, w) then Inc(Result);
  end;
SetCursor(OldCursor);
end;

{-----------------------------------------------------------------------------}

function MultiUnAdjoin : Integer;
var m, s, w  : Integer;
    OldCursor : HCursor;
begin
DO_StoreUndo;
Result := 0;
OldCursor  := SetCursor(LoadCursor(0, IDC_WAIT));
if WL_MULTIS.Count <> 0 then
 for m := 0 to WL_MULTIS.Count - 1 do
  begin
   s := StrToInt(Copy(WL_MULTIS[m],1,4));
   w := StrToInt(Copy(WL_MULTIS[m],5,4));
   if UnAdjoin(s, w) then Inc(Result);
  end;
SetCursor(OldCursor);
end;

{ SECTORS *******************************************************************}
{ SECTORS *******************************************************************}
{ SECTORS *******************************************************************}

procedure ShellInsertSC(cursX, cursZ : Real);
var s, w, v, m : Integer;
    ss, ww     : Integer;
    TheSector  : TSector;
    TheSector2 : TSector;
    TheWall    : TWall;
    TheWall2   : TWall;
    TheVertex  : TVertex;
    TheVertex2 : TVertex;
    LVertex1,
    RVertex1,
    LVertex2,
    RVertex2   : TVertex;
    TheInfCls  : TInfClass;
    oldsecs    : Integer;
    found      : Boolean;
    OldCursor  : HCursor;
    XZero,
    ZZero      : Real;
    debug : Integer;
begin
 if CONFIRMMultiInsert and (SC_MULTIS.Count <> 0) then
  begin
   if Application.MessageBox('Confirm MULTIPLE SECTOR INSERTION ?',
                            'WDFUSE Mapper - Insert Sectors',
                            mb_YesNo or mb_IconQuestion) = idNo
    then exit;
  end;

 OldCursor  := SetCursor(LoadCursor(0, IDC_WAIT));

 {add the Selection to the MultiSelection if necessary}
 if SC_MULTIS.IndexOf(Format('%4d%4d', [SC_HILITE, SC_HILITE])) = -1 then
  SC_MULTIS.Add(Format('%4d%4d', [SC_HILITE, SC_HILITE]));

 {first compute the offset to bring the copy on the cursor pos}
 {-100000,-100000 is used from the menu and means no offsetting}
 if (cursX = -100000.0) and (cursZ = -100000.0) then
  begin
   XZero     := 0.0;
   ZZero     := 0.0;
  end
 else
  begin
   TheSector := TSector(MAP_SEC.Objects[SC_HILITE]);
   TheVertex := TVertex(TheSector.Vx.Objects[0]);
   XZero     := TheVertex.X - cursX;
   ZZero     := TheVertex.Z - cursZ;
  end;

 oldsecs := MAP_SEC.Count;

 {create a new sector for each existing one, clearing
  all adjoins in all the walls
  as well as inf information ???
 }
 for m := 0 to SC_MULTIS.Count - 1 do
  begin
   s := StrToInt(Copy(SC_MULTIS[m],1,4));

   TheSector := TSector(MAP_SEC.Objects[s]);
   TheSector2 := TSector.Create;

   TheSector2.Mark       := 0;
   TheSector2.Name       := '';
   TheSector2.Layer      := TheSector.Layer;
   TheSector2.Floor_alt  := TheSector.Floor_alt;
   TheSector2.Ceili_alt  := TheSector.Ceili_alt;
   TheSector2.Second_alt := TheSector.Second_alt;
   TheSector2.Ambient    := TheSector.Ambient;
   TheSector2.Flag1      := TheSector.Flag1;
   TheSector2.Flag2      := TheSector.Flag2;
   TheSector2.Flag3      := TheSector.Flag3;
   TheSector2.Reserved   := 0;
   TheSector2.Floor      := TheSector.Floor;
   TheSector2.Ceili      := TheSector.Ceili;
   TheSector2.Elevator   := FALSE;
   TheSector2.Trigger    := FALSE;
   TheSector2.Secret     := TheSector.Secret;

   TheSector2.InfClasses.Clear;
   if (TheSector2.Flag1 and 2) <> 0 then
    begin
     TheInfCls := TInfClass.Create;
     TheInfCls.IsElev := TRUE;
     TheInfCls.Name := 'E. FLAG Door';
     TheSector2.InfClasses.AddObject('D', TheInfCls);
     TheSector2.Elevator := TRUE;
    end;
   if (TheSector2.Flag1 and 64) <> 0 then
    begin
     TheInfCls := TInfClass.Create;
     TheInfCls.IsElev := TRUE;
     TheInfCls.Name := 'E. FLAG Exploding';
     TheSector2.InfClasses.AddObject('X', TheInfCls);
     TheSector2.Elevator := TRUE;
    end;

   {Add an offset to these ?}

   for v := 0 to TheSector.Vx.Count - 1 do
     begin
      TheVertex  := TVertex(TheSector.Vx.Objects[v]);
      TheVertex2 := TVertex.Create;

      TheVertex2.Mark := 0;
      TheVertex2.X := TheVertex.X - XZero;
      TheVertex2.Z := TheVertex.Z - ZZero;

      TheSector2.Vx.AddObject('VX', TheVertex2);
     end;

   for w := 0 to TheSector.Wl.Count - 1 do
     begin
      TheWall   := TWall(TheSector.Wl.Objects[w]);
      TheWall2  := TWall.Create;

      TheWall2.Mark      := 0;
      TheWall2.Left_vx   := TheWall.Left_vx;
      TheWall2.Right_vx  := TheWall.Right_vx;
      TheWall2.Adjoin    := -1;
      TheWall2.Mirror    := -1;
      TheWall2.Walk      := -1;
      TheWall2.Light     := TheWall.Light;
      TheWall2.Flag1     := TheWall.Flag1;
      TheWall2.Flag2     := TheWall.Flag2;
      TheWall2.Flag3     := TheWall.Flag3;
      TheWall2.Reserved  := 0;
      TheWall2.Mid       := TheWall.Mid;
      TheWall2.Top       := TheWall.Top;
      TheWall2.Bot       := TheWall.Bot;
      TheWall2.Sign      := TheWall.Sign;
      TheWall2.Elevator  := FALSE;
      TheWall2.Trigger   := FALSE;


      TheSector2.Wl.AddObject('WL', TheWall2);
     end;
   MAP_SEC.AddObject('SC', TheSector2);
   MAP_DEBUG := TheSector2;
   //debug := MAP_SEC.IndexOfObject(TheSector2);
   //MAP_SEC.Delete(debug - 1);
  end;

 { Recreate the Adjoins wall by wall, but look only in the new sectors,
   so only internal adjoins will be created }
 { and Transfer the multiselection if there was one }

 if SC_MULTIS.Count = 1 then
  begin
   DO_Clear_Multisel;
  end
 else
 begin
  DO_Clear_Multisel;
   for s := oldsecs to MAP_SEC.Count - 1 do
    begin
     TheSector := TSector(MAP_SEC.Objects[s]);
     for w := 0 to TheSector.Wl.Count - 1 do
       begin
        TheWall :=  TWall(TheSector.Wl.Objects[w]);
        LVertex1 := TVertex(TheSector.Vx.Objects[TheWall.left_vx]);
        RVertex1 := TVertex(TheSector.Vx.Objects[TheWall.right_vx]);
        found    := FALSE;

        for ss := oldsecs to MAP_SEC.Count - 1 do
         begin
          TheSector2 := TSector(MAP_SEC.Objects[ss]);
          for ww := 0 to TheSector2.Wl.Count - 1 do
           begin
            TheWall2 := TWall(TheSector2.Wl.Objects[ww]);
            LVertex2 := TVertex(TheSector2.Vx.Objects[TheWall2.left_vx]);
            RVertex2 := TVertex(TheSector2.Vx.Objects[TheWall2.right_vx]);

            {if found do the adjoin and prepare to break out of both loops}
            if ((LVertex1.X = RVertex2.X) and (LVertex1.Z = RVertex2.Z)) and
               ((RVertex1.X = LVertex2.X) and (RVertex1.Z = LVertex2.Z)) then
             begin
              TheWall2.Adjoin := s;
              TheWall2.Mirror := w;
              TheWall2.Walk   := s;
              TheWall.Adjoin  := ss;
              TheWall.Mirror  := ww;
              TheWall.Walk    := ss;
              found      := TRUE;
             end;
            if found then break;
           end;
           if found then break;
         end;
       end;

     SC_MULTIS.Add(Format('%4d%4d', [s, s]));
    end;
 end;

 {make the hilited sector the last of the new ones}
 SC_HILITE := MAP_SEC.Count - 1;
 SetCursor(OldCursor);
 DO_Fill_SectorEditor;
 MapWindow.PanelMulti.Caption := IntToStr(SC_MULTIS.Count);
 MapWindow.Map.Refresh;
 MODIFIED := TRUE;
end;

{-----------------------------------------------------------------------------}

function  DeleteSC(sc : Integer) : Boolean;
var i,j,k     : Integer;
    TheSector : TSector;
    TheWall   : TWall;
    TheObject : TOB;
begin
  DO_StoreUndo;
  {Free the Sector}
  TheSector := TSector(MAP_SEC.Objects[sc]);
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
  {Update all the adjoins > to the sector}
  {Delete the adjoins     = to the sector}
  for i := 0 to MAP_SEC.Count - 1 do
  if i <> sc then
   begin
    TheSector := TSector(MAP_SEC.Objects[i]);
    for j := 0 to TheSector.Wl.Count - 1 do
     begin
      TheWall := TWall(TheSector.Wl.Objects[j]);
      if TheWall.Adjoin > sc then
       begin
        TheWall.Adjoin := TheWall.Adjoin - 1;
        TheWall.Walk   := TheWall.Walk - 1;
       end
      else
      if TheWall.Adjoin = sc then
       begin
        TheWall.Adjoin := -1;
        TheWall.Mirror := -1;
        TheWall.Walk   := -1;
       end;
     end; {walls}
   end; {sectors}

  {Correct corresponding objects references}
  for i := 0 to MAP_OBJ.Count - 1 do
   begin
    TheObject := TOB(MAP_OBJ.Objects[i]);
    if TheObject.Sec > sc then
     TheObject.Sec := TheObject.Sec - 1
    else
    if TheObject.Sec = sc then
     TheObject.Sec := -1;
   end;

  {Delete the entry in MAP_SEC}
  MAP_SEC.Delete(sc);
  SC_HILITE := 0;
  WL_HILITE := 0;
  VX_HILITE := 0;
  DeleteSC  := TRUE;
end;

{-----------------------------------------------------------------------------}

procedure MultiDeleteSC;
var m, s, mm, ss  : Integer;
begin

{add the Selection to the MultiSelection if necessary}
if SC_MULTIS.IndexOf(Format('%4d%4d', [SC_HILITE, SC_HILITE])) = -1 then
 SC_MULTIS.Add(Format('%4d%4d', [SC_HILITE, SC_HILITE]));

{this is in fact a recheck for the very rare case that every sector
 but one is in multi and the last sector IS the selection
 It will mess the multiselection, but better that to GPF !}
if SC_MULTIS.Count = MAP_SEC.Count then
 begin
   Application.MessageBox('YOU CANNOT DELETE ALL SECTORS !',
                          'WDFUSE Mapper - Delete Sectors',
                          mb_Ok or mb_IconExclamation);
   exit;
  end;

if SC_MULTIS.Count <> 0 then
 for m := 0 to SC_MULTIS.Count - 1 do
  begin
   {!!!! deleted sectors will affect multiselection !!!!}
   s := StrToInt(Copy(SC_MULTIS[m],1,4));
   DeleteSC(s);
   for mm := m+1 to SC_MULTIS.Count - 1 do
    begin
     ss := StrToInt(Copy(SC_MULTIS[mm],1,4));
     if ss > s then
      begin
       Dec(ss);
       SC_MULTIS[mm] := Format('%4d%4d', [ss, ss]);
      end;
    end;
  end;
end;

{-----------------------------------------------------------------------------}

{
 this will test the confirmations and so on,
 and refresh the map only once whatever the deletes done,
 and refresh the Sector Editor
 and also handle the cursor hourglass
}
procedure ShellDeleteSC;
var
    OldCursor : HCursor;
begin
 if (SC_MULTIS.Count = MAP_SEC.Count) or (MAP_SEC.Count = 1) then
  begin
   Application.MessageBox('YOU CANNOT DELETE ALL SECTORS !',
                          'WDFUSE Mapper - Delete Sectors',
                          mb_Ok or mb_IconExclamation);
   exit;
  end;

 if CONFIRMMultiDelete and (SC_MULTIS.Count <> 0) then
  begin
   if Application.MessageBox('Confirm MULTIPLE SECTOR DELETE ?',
                            'WDFUSE Mapper - Delete Sectors',
                            mb_YesNo or mb_IconQuestion) = idNo
    then exit;
  end;

 if CONFIRMSectorDelete and (SC_MULTIS.Count = 0) then
  begin
   if Application.MessageBox('Confirm SECTOR DELETE ?',
                            'WDFUSE Mapper - Delete Sector',
                            mb_YesNo or mb_IconQuestion) = idNo
    then exit;
  end;

 OldCursor  := SetCursor(LoadCursor(0, IDC_WAIT));

 {handle the selection only if no multiselection
  if there is a multiselection, it will handle the selection}
 if SC_MULTIS.Count = 0 then
  DeleteSC(SC_HILITE)
 else
  begin
   MultiDeleteSC;
   DO_Clear_MultiSel2;
  end;

 SetCursor(OldCursor);

 SC_HILITE := 0;
 VX_HILITE := 0;
 WL_HILITE := 0;
 MODIFIED := TRUE;
 DO_Fill_SectorEditor;
 MapWindow.Map.Refresh;
end;


{ OBJECTS ********************************************************************}
{ OBJECTS ********************************************************************}
{ OBJECTS ********************************************************************}

procedure ShellInsertOB(cursX, cursZ : Real);
var s, m       : Integer;
    TheObject  : TOB;
    TheObject2 : TOB;
    oldobjs    : Integer;
    OldCursor  : HCursor;
    XZero,
    ZZero      : Real;
begin
 if CONFIRMMultiInsert and (OB_MULTIS.Count <> 0) then
  begin
   if Application.MessageBox('Confirm MULTIPLE OBJECT INSERTION ?',
                            'WDFUSE Mapper - Insert Objects',
                            mb_YesNo or mb_IconQuestion) = idNo
    then exit;
  end;

 OldCursor  := SetCursor(LoadCursor(0, IDC_WAIT));

 {add the Selection to the MultiSelection if necessary}
 TheObject := TOB(MAP_OBJ.Objects[OB_HILITE]);
 m := OB_MULTIS.IndexOf(Format('%4d%4d', [TheObject.Sec, OB_HILITE]));
 if m = -1 then
  OB_MULTIS.Add(Format('%4d%4d', [TheOBject.Sec, OB_HILITE]));

 oldobjs := MAP_OBJ.Count;

 {first compute the offset to bring the copy on the cursor pos}
 {-100000,-100000 is used from the menu and means no offsetting}
 if (cursX = -100000.0) and (cursZ = -100000.0) then
  begin
   XZero     := 0.0;
   ZZero     := 0.0;
  end
 else
  begin
   TheObject := TOB(MAP_OBJ.Objects[OB_HILITE]);
   XZero     := TheObject.X - cursX;
   ZZero     := TheObject.Z - cursZ;
  end;

 for m := 0 to OB_MULTIS.Count - 1 do
  begin
   s := StrToInt(Copy(OB_MULTIS[m],5,4));

   TheObject := TOB(MAP_OBJ.Objects[s]);
   TheObject2 := TOB.Create;

   TheObject2.Mark       := 0;
   TheObject2.Sec        := TheObject.Sec;
   TheObject2.X          := TheObject.X - XZero;
   TheObject2.Y          := TheObject.Y;
   TheObject2.Z          := TheObject.Z - ZZero;
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

 { Transfer the multiselection if there was one }

 if OB_MULTIS.Count = 1 then
  begin
   DO_Clear_Multisel;
   ForceLayerObject(MAP_OBJ.Count - 1);
  end
 else
  begin
   DO_Clear_Multisel;
   for s := oldobjs to MAP_OBJ.Count - 1 do
    begin
     TheObject := TOB(MAP_OBJ.Objects[s]);
     OB_MULTIS.Add(Format('%4d%4d', [TheObject.Sec, s]));
    end;
  end;

  if (cursX <> -100000.0) or (cursZ <> -100000.0) then
   if OB_MULTIS.Count > 0 then
    begin
     for m := 0 to OB_MULTIS.Count - 1 do
      begin
       TheObject := TOB(MAP_OBJ.Objects[StrToInt(Copy(OB_MULTIS[m],5,4))]);
       TheObject.Sec := -1;
      end;
     MultiForceLayerObject;
   end;

  {now, recreate the multiselection, because the preceeding
   step may have messed up the SSSSOOOO format by reassigning the
   objects sectors !!!}
  if OB_MULTIS.Count > 0 then
   begin
   DO_Clear_Multisel;
   for s := oldobjs to MAP_OBJ.Count - 1 do
    begin
     TheObject := TOB(MAP_OBJ.Objects[s]);
     OB_MULTIS.Add(Format('%4d%4d', [TheObject.Sec, s]));
    end;
  end;

 {make the hilited object the last of the new ones}
 OB_HILITE := MAP_OBJ.Count - 1;
 SetCursor(OldCursor);
 DO_Fill_ObjectEditor;
 MapWindow.PanelMulti.Caption := IntToStr(OB_MULTIS.Count);
 MapWindow.Map.Refresh;
 MODIFIED := TRUE;
end;

{-----------------------------------------------------------------------------}

function  DeleteOB(ob : Integer) : Boolean;
var
    TheObject : TOB;
begin
  DO_StoreUndo;
  TheObject := TOB(MAP_OBJ.Objects[ob]);
  TheObject.Free;
  MAP_OBJ.Delete(ob);
  DeleteOB := TRUE;
end;

{-----------------------------------------------------------------------------}

procedure MultiDeleteOB;
var m, s, mm, ss  : Integer;
    TheObject : TOB;
begin
DO_StoreUndo;
TheObject := TOB(MAP_OBJ.Objects[OB_HILITE]);
m := OB_MULTIS.IndexOf(Format('%4d%4d', [TheObject.Sec, OB_HILITE]));
{add the Selection to the MultiSelection if necessary}
if m = -1 then
 OB_MULTIS.Add(Format('%4d%4d', [TheOBject.Sec, OB_HILITE]));

{this is in fact a recheck for the very rare case that every object
 but one is in multi and the last sector IS the selection
 It will mess the multiselection (because the selection will have been
 added to it incorrectly), but better that than getting
 a List Index Out Of Bounds fatal error !}
if OB_MULTIS.Count = MAP_OBJ.Count then
 begin
   Application.MessageBox('YOU CANNOT DELETE ALL OBJECTS !',
                          'WDFUSE Mapper - Delete Objects',
                          mb_Ok or mb_IconExclamation);
   exit;
  end;

for m := 0 to OB_MULTIS.Count - 1 do
 begin
  s := StrToInt(Copy(OB_MULTIS[m],5,4));
  DeleteOB(s);
  for mm := m+1 to OB_MULTIS.Count - 1 do
    begin
     ss := StrToInt(Copy(OB_MULTIS[mm],5,4));
     if ss > s then
      begin
       Dec(ss);
       OB_MULTIS[mm] := Copy(OB_MULTIS[mm],1,4) + Format('%4d', [ss]);
      end;
    end;
 end;
end;

{-----------------------------------------------------------------------------}

procedure ShellDeleteOB;
var
    OldCursor : HCursor;
begin
  DO_StoreUndo;
 if (OB_MULTIS.Count = MAP_OBJ.Count) or (MAP_OBJ.Count = 1) then
  begin
   Application.MessageBox('YOU CANNOT DELETE ALL OBJECTS !',
                          'WDFUSE Mapper - Delete Objects',
                          mb_Ok or mb_IconExclamation);
   exit;
  end;

 if CONFIRMMultiDelete and (OB_MULTIS.Count <> 0) then
  begin
   if Application.MessageBox('Confirm MULTIPLE OBJECT DELETE ?',
                            'WDFUSE Mapper - Delete Objects',
                            mb_YesNo or mb_IconQuestion) = idNo
    then exit;
  end;

 if CONFIRMObjectDelete and (OB_MULTIS.Count = 0) then
  begin
   if Application.MessageBox('Confirm OBJECT DELETE ?',
                            'WDFUSE Mapper - Delete Object',
                            mb_YesNo or mb_IconQuestion) = idNo
    then exit;
  end;

 OldCursor  := SetCursor(LoadCursor(0, IDC_WAIT));

 {handle the selection only if no multiselection
  if there is a multiselection, it will handle the selection}
 if OB_MULTIS.Count = 0 then
  DeleteOB(OB_HILITE)
 else
  begin
   MultiDeleteOB;
   {DO_Clear_MultiSel; this gives problems because it refreshes the OBEd}
   DO_Clear_MultiSel2;
  end;

 SetCursor(OldCursor);

 OB_HILITE := 0;
 DO_Fill_ObjectEditor;
 MapWindow.Map.Refresh;
 MODIFIED := TRUE;
end;


{ WALLS *********************************************************************}
{ WALLS *********************************************************************}
{ WALLS *********************************************************************}

procedure ShellExtrudeWL(sc, wl : Integer);
var w          : Integer;
    TheSector  : TSector;
    TheSector2 : TSector;
    TheWall    : TWall;
    TheWall2   : TWall;
    TheVertex2 : TVertex;
    LVertex,
    RVertex    : TVertex;
    deltax,
    deltaz     : Real;
    newsector  : Integer;
begin
 DO_StoreUndo;
 newsector := MAP_SEC.Count;
 TheSector := TSector(MAP_SEC.Objects[sc]);
 TheWall   := TWall(TheSector.Wl.Objects[wl]);

 if TheWall.Adjoin <> -1 then
   begin
    Application.MessageBox('CANNOT EXTRUDE ADJOINED WALL !',
                           'WDFUSE Mapper - Extrude Wall',
                           mb_Ok or mb_IconExclamation);
    exit;
  end;

 if CONFIRMWallExtrude then
  begin
   if Application.MessageBox('Confirm EXTRUDE WALL ?',
                            'WDFUSE Mapper - Extrude Wall',
                            mb_YesNo or mb_IconQuestion) = idNo
    then exit;
  end;

 { prepare the coordinates of the new vertices }
 LVertex := TVertex(TheSector.Vx.Objects[TheWall.left_vx]);
 RVertex := TVertex(TheSector.Vx.Objects[TheWall.right_vx]);

 deltax  := LVertex.X - RVertex.x;
 deltaz  := LVertex.z - RVertex.z;

 { Create and fill the new sector }
 TheSector2 := TSector.Create;

 TheSector2.Mark       := 0;
 TheSector2.Name       := '';
 TheSector2.Layer      := TheSector.Layer;
 TheSector2.Floor_alt  := TheSector.Floor_alt;
 TheSector2.Ceili_alt  := TheSector.Ceili_alt;
 TheSector2.Second_alt := TheSector.Second_alt;
 TheSector2.Ambient    := TheSector.Ambient;
 TheSector2.Flag1      := (((TheSector.Flag1 and not 2) and not 64) and not 524288);
 TheSector2.Flag2      := TheSector.Flag2;
 TheSector2.Flag3      := TheSector.Flag3;
 TheSector2.Reserved   := 0;
 TheSector2.Floor      := TheSector.Floor;
 TheSector2.Ceili      := TheSector.Ceili;
 TheSector2.Elevator   := FALSE;
 TheSector2.Trigger    := FALSE;
 TheSector2.Secret     := FALSE;
 TheSector2.InfClasses.Clear;

 {VX 0}
 TheVertex2 := TVertex.Create;
 TheVertex2.Mark := 0;
 TheVertex2.X := RVertex.X;
 TheVertex2.Z := RVertex.Z;
 TheSector2.Vx.AddObject('VX', TheVertex2);
 {VX 1}
 TheVertex2 := TVertex.Create;
 TheVertex2.Mark := 0;
 TheVertex2.X := LVertex.X;
 TheVertex2.Z := LVertex.Z;
 TheSector2.Vx.AddObject('VX', TheVertex2);
 {VX 2}
 TheVertex2 := TVertex.Create;
 TheVertex2.Mark := 0;
 TheVertex2.X := LVertex.X + extr_ratio * deltaz;
 TheVertex2.Z := LVertex.Z - extr_ratio * deltax;
 TheSector2.Vx.AddObject('VX', TheVertex2);
 {VX 3}
 TheVertex2 := TVertex.Create;
 TheVertex2.Mark := 0;
 TheVertex2.X := RVertex.X + extr_ratio * deltaz;
 TheVertex2.Z := RVertex.Z - extr_ratio * deltax;
 TheSector2.Vx.AddObject('VX', TheVertex2);

 for w := 0 to 3 do
  begin
   TheWall2  := TWall.Create;
   TheWall2.Mark      := 0;
   CASE w OF
    0 : begin
         TheWall2.Left_vx   := 0;
         TheWall2.Right_vx  := 1;
        end;
    1 : begin
         TheWall2.Left_vx   := 1;
         TheWall2.Right_vx  := 2;
        end;
    2 : begin
         TheWall2.Left_vx   := 2;
         TheWall2.Right_vx  := 3;
        end;
    3 : begin
         TheWall2.Left_vx   := 3;
         TheWall2.Right_vx  := 0;
        end;
   END;
   IF w = 0 then
    begin
     TheWall2.Adjoin    := sc;
     TheWall2.Mirror    := wl;
     TheWall2.Walk      := sc;
     TheWall.Adjoin     := newsector;
     TheWall.Mirror     := 0;
     TheWall.Walk       := newsector;
    end
   ELSE
    begin
     TheWall2.Adjoin    := -1;
     TheWall2.Mirror    := -1;
     TheWall2.Walk      := -1;
    end;
   TheWall2.Light     := TheWall.Light;
   TheWall2.Flag1     := TheWall.Flag1;
   TheWall2.Flag2     := TheWall.Flag2;
   TheWall2.Flag3     := TheWall.Flag3;
   TheWall2.Reserved  := 0;
   WITH TheWall2.Mid DO
    begin
     name := TheWall.Mid.Name;
     f1   := 0.0;
     f2   := 0.0;
     i    := 0;
    end;
   WITH TheWall2.Top DO
    begin
     name := TheWall.Top.Name;
     f1   := 0.0;
     f2   := 0.0;
     i    := 0;
    end;
   WITH TheWall2.Bot DO
    begin
     name := TheWall.Bot.Name;
     f1   := 0.0;
     f2   := 0.0;
     i    := 0;
    end;
   WITH TheWall2.Sign DO
    begin
     name := '';
     f1   := 0.0;
     f2   := 0.0;
     i    := 0;
    end;
   TheWall2.Elevator  := FALSE;
   TheWall2.Trigger   := FALSE;

   TheSector2.Wl.AddObject('WL', TheWall2);
  end;

 MAP_SEC.AddObject('SC', TheSector2);

 {make the hilited wall the new sector, wall 0}
 SC_HILITE := newsector;
 WL_HILITE := 0;
 DO_Fill_WallEditor;
 MapWindow.Map.Refresh;
 MODIFIED := TRUE;
end;

{-----------------------------------------------------------------------------}

procedure SplitWL(sc, wl : Integer);
var w           : Integer;
    TheSector   : TSector;
    TheSector2  : TSector;
    TheWall     : TWall;
    TheWall2    : TWall;
    NEWWall     : TWall;
    NEWVertex   : TVertex;
    LVertex     : TVertex;
    RVertex     : TVertex;
    newvxpos    : Integer;
    walllen     : Real;
    infi        : TStringList;
    hasINF      : boolean;
begin
 TheSector := TSector(MAP_SEC.Objects[sc]);
 TheWall   := TWall(TheSector.Wl.Objects[wl]);

 if TheWall.InfItems.Count <> 0 then
  begin
   hasINF := TRUE;
   infi   := TStringList.Create;
   infi.AddStrings(TheWall.InfItems);
   TheWall.InfItems.Clear;
   ComputeINFClasses(sc, wl);
  end
 else
  hasINF := FALSE;

 walllen   := GetWLLen(sc, wl);

 LVertex           := TVertex(TheSector.Vx.Objects[TheWall.left_vx]);
 RVertex           := TVertex(TheSector.Vx.Objects[TheWall.right_vx]);

 NEWVertex         := TVertex.Create;
 NEWVertex.Mark    := 0;
 NEWVertex.X       := (LVertex.X + RVertex.X ) / 2;
 NEWVertex.Z       := (LVertex.Z + RVertex.Z ) / 2;

 NEWWall           := TWall.Create;
 NEWWall.Mark      := 0;
 NEWWall.Adjoin    := -1;
 NEWWall.Mirror    := -1;
 NEWWall.Walk      := -1;
 NEWWall.Light     := TheWall.Light;
 NEWWall.Flag1     := TheWall.Flag1;
 NEWWall.Flag2     := TheWall.Flag2;
 NEWWall.Flag3     := TheWall.Flag3;
 NEWWall.Mid.Name  := TheWall.Mid.Name;
 NEWWall.Mid.f1    := TheWall.Mid.f1;
 NEWWall.Mid.f2    := TheWall.Mid.f2;
 NEWWall.Mid.i     := TheWall.Mid.i;
 NEWWall.Top.Name  := TheWall.Top.Name;
 NEWWall.Top.f1    := TheWall.Top.f1;
 NEWWall.Top.f2    := TheWall.Top.f2;
 NEWWall.Top.i     := TheWall.Top.i;
 NEWWall.Bot.Name  := TheWall.Bot.Name;
 NEWWall.Bot.f1    := TheWall.Bot.f1;
 NEWWall.Bot.f2    := TheWall.Bot.f2;
 NEWWall.Bot.i     := TheWall.Bot.i;
 NEWWall.Sign.Name := '';
 NEWWall.Sign.f1   := 0;
 NEWWall.Sign.f2   := 0;
 NEWWall.Elevator  := FALSE;
 NEWWall.Trigger   := FALSE;
 NEWWall.Cycle     := TheWall.Cycle;

 {preserve texture horiz alignment}
 TheWall.Mid.f1    := TheWall.Mid.f1 + walllen / 2;
 TheWall.Top.f1    := TheWall.Top.f1 + walllen / 2;
 TheWall.Bot.f1    := TheWall.Bot.f1 + walllen / 2;

 newvxpos          := TheWall.left_vx + 1;
 NEWWall.Left_vx   := TheWall.Left_vx;
 NEWWall.Right_vx  := newvxpos;

 if hasINF then
  begin
   NEWWall.InfItems.AddStrings(infi);
   infi.Free;
  end;

 for w := 0 to TheSector.Wl.Count - 1 do
  begin
   TheWall2 := TWall(TheSector.Wl.Objects[w]);
   if TheWall2.left_vx >= newvxpos then
    TheWall2.left_vx  := TheWall2.left_vx  + 1;
   if TheWall2.right_vx >= newvxpos then
   TheWall2.right_vx := TheWall2.right_vx + 1;
  end;
 TheSector.Vx.InsertObject(newvxpos, 'VX', NEWVertex);
 TheSector.Wl.InsertObject(wl, 'WL', NEWWall);
 TheWall.Left_vx   := newvxpos;

 {update the mirrors of the adjoins for the complete sector (easier)}
 for w := 0 to TheSector.Wl.Count - 1 do
  begin
   TheWall := TWall(TheSector.Wl.Objects[w]);
   if TheWall.Adjoin <> -1 then
    begin
     TheSector2 := TSector(MAP_SEC.Objects[TheWall.Adjoin]);
     TheWall2   := TWall(TheSector2.Wl.Objects[TheWall.Mirror]);
     TheWall2.Mirror := w;
    end;
   {recompute the INFClasses at the same time}
   ComputeINFClasses(sc, w);
  end;

 MODIFIED := TRUE;
end;

function  VxToPoint(vx : TVertex) : TPoint;
begin
  Result := Point(M2SX(vx.X), M2SZ(vx.z));
end;


function  NormalizeWall(AWall : TWall) : TWall;
var
err_msg : String;
begin
 // Normalize offsets
 if NORMALIZE_WALLS then
   begin

     if isFileLocked(TEXTURESGOB) then
       begin
        err_msg := 'TEXTURES.GOB is Locked. Is Dark Forces running?';
        log.Info(err_msg, LogName);
        showmessage(err_msg);
        Result := AWall;
       end;

     AWall.Mid := NormalizeOffsets(AWall.Mid);
     AWall.Top := NormalizeOffsets(AWall.Top);
     AWall.Bot := NormalizeOffsets(AWall.Bot);

     // Do not normalize signs
     //AWall.Sign := NormalizeOffsets(AWall.Sign);
   end;

 Result := AWall;
end;

// Given a texture component - normalize the offsets (no more x offset of +1000)
function  NormalizeOffsets(WallTexture : TTEXTURE) : TTEXTURE;
var
  wl_header : TBM_HEADER;
  err_msg : string;
begin
  try
    wl_header := GetNormalHeader(WallTexture.name);
    if (wl_header.Compressed = 0) and (wl_header.SizeX <> 1) or ((wl_header.SizeX = 1) and (wl_header.SizeY = 1)) then
      begin
        // Delphi doesn't have a built-in real modulo impl ??? I can't even...
        WallTexture.f1 :=  WallTexture.f1 -  Trunc(WallTexture.f1/Trunc(wl_header.SizeX/8)) * Trunc(wl_header.SizeX/8);
        WallTexture.f2 :=  WallTexture.f2 -  Trunc(WallTexture.f2/Trunc(wl_header.SizeY/8)) * Trunc(wl_header.SizeY/8);
      end;
    NormalizeOffsets := WallTexture;
  except on E: Exception do
    begin
       err_msg := 'Failed to Load texture in SC ' + IntToStr(SC_HILITE) +
                 ' WL ' + IntToStr(WL_HILITE)+ ' named ' +  WallTexture.name +
                 ' due to ' + E.Message;
       Log.error(err_msg, LogName);
       showmessage(err_msg);
       NormalizeOffsets := WallTexture;
     end;
  end;
end;
{-----------------------------------------------------------------------------}

procedure ShellSplitWL(sc, wl : Integer);
var adjoined    : Boolean;
    TheSector   : TSector;
    TheWall     : TWall;
    adjoin,
    mirror,
    walk        : Integer;
begin
 if CONFIRMWallSplit then
  begin
   if Application.MessageBox('Confirm SPLIT WALL ?',
                            'WDFUSE Mapper - Split Wall',
                            mb_YesNo or mb_IconQuestion) = idNo
    then exit;
  end;
 DO_StoreUndo;
 TheSector := TSector(MAP_SEC.Objects[sc]);
 TheWall   := TWall(TheSector.Wl.Objects[wl]);

 if TheWall.Adjoin <> -1 then
  begin
   adjoined := TRUE;
   adjoin   := TheWall.Adjoin;
   mirror   := TheWall.Mirror;
   walk     := TheWall.Walk;
   UnAdjoin(sc, wl);
  end
 else
  adjoined := FALSE;

 SplitWL(sc, wl);

 if Adjoined then
  begin
   SplitWL(adjoin, mirror);
   MakeAdjoin(sc, wl);
   MakeAdjoin(adjoin, mirror);
  end;

 MODIFIED := TRUE;
 DO_Fill_WallEditor;
 MapWindow.Map.Invalidate;
end;

{-----------------------------------------------------------------------------}

function  ShellDeleteWL(sc, wl : Integer) : Boolean;
var w,k,c      : Integer;
    TheSector  : TSector;
    TheSector2 : TSector;
    TheWall    : TWall;
    TheWall2   : TWall;
    seccycles  : Integer;
    cycle      : Integer;
    cyclewalls : Integer;
    delvx      : Integer;
    nxtwl      : Integer;
begin
 DO_StoreUndo;
 seccycles  := SetSectorCycles(sc);
 TheSector  := TSector(MAP_SEC.Objects[sc]);
 TheWall    := TWall(TheSector.Wl.Objects[wl]);
 cycle      := TheWall.Cycle;
 cyclewalls := GetCycleLen(sc, cycle);

 Result     := TRUE;

 if seccycles = 0 then
  begin
   {tricky sectors}
   if Application.MessageBox('This SECTOR isn''t COMPLETE, try anyway ? (maybe you should SAVE before!)',
                          'WDFUSE Mapper - Delete Wall',
                           mb_YesNo or mb_IconQuestion) = idNo
    then exit
    else cyclewalls := 0;

  end;

 if TheSector.Wl.Count < 4 then
  begin
   if Application.MessageBox('YOU CANNOT HAVE LESS THAN 3 WALLS IN A SECTOR - Delete SECTOR ?',
                          'WDFUSE Mapper - Delete Wall',
                          mb_YesNo or mb_IconQuestion) = idNo
   then exit
   else
    begin
     DeleteSC(sc);
     MapWindow.Map.Invalidate;
     exit;
    end;
  end;

 if (cycle = 1) and (cyclewalls < 4) then
  begin
   if Application.MessageBox('CANNOT HAVE LESS THAN 3 WALLS IN PRIMARY CYCLE - Delete SECTOR ?',
                            'WDFUSE Mapper - Delete Wall',
                            mb_YesNo or mb_IconQuestion) = idNo
    then exit
    else
     begin
      DeleteSC(sc);
      MapWindow.Map.Invalidate;
      exit;
     end;
  end;

 if (cycle > 1) and (cyclewalls < 4) then
  begin
   if Application.MessageBox('CANNOT HAVE LESS THAN 3 WALLS IN A CYCLE - Delete CYCLE ?',
                            'WDFUSE Mapper - Delete Wall',
                            mb_YesNo or mb_IconQuestion) = idNo
    then exit
    else
     begin
      { !!!!!delete cycle!!!!! }
      { unadjoin cycle walls   }
      for w := 0 to TheSector.Wl.Count - 1 do
       begin
        TheWall2 := TWall(TheSector.Wl.Objects[w]);
        if TheWall2.Cycle = cycle then
         if TheWall2.Adjoin <> -1 then UnAdjoin(sc, w);
       end;

      delvx := GetCycleFirstVx(sc, cycle);

      for w := 0 to TheSector.Wl.Count - 1 do
       begin
        TheWall2 := TWall(TheSector.Wl.Objects[w]);
        if TheWall2.left_vx > delvx then
         TheWall2.left_vx  := TheWall2.left_vx - cyclewalls;
        if TheWall2.right_vx >= delvx then
         TheWall2.right_vx := TheWall2.right_vx - cyclewalls;
        end;
       {delete the walls and their INF classes}
       for c := 1 to 3 do
        begin
         w := GetCycleFirstWl(sc, cycle);
         TheWall2 := TWall(TheSector.Wl.Objects[w]);
         for k := 0 to TheWall2.InfClasses.Count - 1 do
          begin
           TInfClass(TheWall2.InfClasses.Objects[k]).Free;
         end;
         TWall(TheSector.Wl.Objects[w]).Free;
         TheSector.Wl.Delete(w);
         TheSector.Vx.Delete(delvx);
        end;
      {update the mirrors of the adjoins for the complete sector (easier)}
       for w := 0 to TheSector.Wl.Count - 1 do
        begin
         TheWall := TWall(TheSector.Wl.Objects[w]);
         if TheWall.Adjoin <> -1 then
          begin
           TheSector2 := TSector(MAP_SEC.Objects[TheWall.Adjoin]);
           TheWall2   := TWall(TheSector2.Wl.Objects[TheWall.Mirror]);
           TheWall2.Mirror := w;
          end;
        end;
       WL_HILITE := 0;
       VX_HILITE := 0;
       MODIFIED := TRUE;
       DO_Fill_WallEditor;
       MapWindow.Map.Invalidate;
      exit;
     end;
  end;

 if CONFIRMWallDelete then
  begin
   if Application.MessageBox('Confirm WALL DELETE ?',
                             'WDFUSE Mapper - Delete Wall',
                             mb_YesNo or mb_IconQuestion) = idNo
    then exit;
  end;

 delvx := TheWall.right_vx;
 GetWLfromLeftVX(sc, delvx, nxtwl);
 UnAdjoin(sc, wl);
 {the next wall is also affected badly, so must unadjoin}
 UnAdjoin(sc, nxtwl);
 TheWall2 := TWall(TheSector.Wl.Objects[nxtwl]);
 TheWall2.left_vx := TheWall.left_vx;

 for w := 0 to TheSector.Wl.Count - 1 do
  begin
   TheWall2 := TWall(TheSector.Wl.Objects[w]);
   if TheWall2.left_vx > delvx then
    TheWall2.left_vx  := TheWall2.left_vx - 1;
   if TheWall2.right_vx >= delvx then
   TheWall2.right_vx := TheWall2.right_vx - 1;
  end;

 {delete the wall and its INF classes}
 for k := 0 to TheWall.InfClasses.Count - 1 do
  begin
   TInfClass(TheWall.InfClasses.Objects[k]).Free;
  end;
 TWall(TheSector.Wl.Objects[wl]).Free;
 TheSector.Wl.Delete(wl);
 TheSector.Vx.Delete(delvx);

 {update the mirrors of the adjoins for the complete sector (easier)}
 for w := 0 to TheSector.Wl.Count - 1 do
  begin
   TheWall := TWall(TheSector.Wl.Objects[w]);
   if TheWall.Adjoin <> -1 then
    begin
     TheSector2 := TSector(MAP_SEC.Objects[TheWall.Adjoin]);
     TheWall2   := TWall(TheSector2.Wl.Objects[TheWall.Mirror]);
     TheWall2.Mirror := w;
    end;
  end;
 MODIFIED := TRUE;
 WL_HILITE := 0;
 VX_HILITE := 0;
 DO_Fill_WallEditor;
 MapWindow.Map.Invalidate;
end;

{ VERTICES ****************************************************************** }
{ VERTICES ****************************************************************** }
{ VERTICES ****************************************************************** }

procedure ShellSplitVX(sc, vx : Integer);
var wl : Integer;
begin
 if GetWLfromLeftVX(sc, vx, wl) then
  begin
   ShellSplitWL(sc, wl);
   DO_Fill_VertexEditor;
  end;
end;

procedure ShellDeleteVX(sc, vx : Integer);
var wl : Integer;
begin
 if GetWLfromRightVX(sc, vx, wl) then
  begin
   ShellDeleteWL(sc, wl);
   DO_Fill_VertexEditor;
  end;
end;


{-----------------------------------------------------------------------------}


{ CYCLES ******************************************************************** }
{ CYCLES ******************************************************************** }
{ CYCLES ******************************************************************** }

function SetSectorCycles(sc : Integer) : Integer;
var w, ww     : Integer;
    TheSector : TSector;
    TheWall   : TWall;
    curcycle  : Integer;
begin
  DO_StoreUndo;
  TheSector := TSector(MAP_SEC.Objects[sc]);

  { Exit in case of problem
    Operation should then be handled by a non intelligent function }
  if TheSector.Wl.Count <> TheSector.Vx.Count then
   begin
    for ww := 0 to TheSector.Wl.Count - 1 do
     begin
      TheWall       := TWall(TheSector.Wl.Objects[ww]);
      TheWall.Cycle := 0;
     end;
    Result := 0;
    exit;
   end;

  curcycle := 1;
  for ww := 0 to TheSector.Wl.Count - 1 do
   begin
    if GetWLfromLeftVX(sc, ww, w) then
     begin
      TheWall       := TWall(TheSector.Wl.Objects[w]);
      TheWall.Cycle := CurCycle;
      if TheWall.Left_vx > TheWall.Right_vx then Inc(CurCycle);
     end
    else
     begin
      { unlikely problem }
      Result := 0;
      exit;
     end;
   end;
  Result := CurCycle - 1;
end;

{-----------------------------------------------------------------------------}

function  GetCycleLen(sc, cy : Integer) : Integer;
var w         : Integer;
    TheSector : TSector;
    TheWall   : TWall;
begin
 TheSector := TSector(MAP_SEC.Objects[sc]);
 Result    := 0;
 for w := 0 to TheSector.Wl.Count - 1 do
  begin
   TheWall := TWall(TheSector.Wl.Objects[w]);
   if TheWall.Cycle = cy then Inc(Result);
  end;
end;

function  GetCycleFirstWl(sc, cy : Integer) : Integer;
var w         : Integer;
    TheSector : TSector;
    TheWall   : TWall;
begin
 TheSector := TSector(MAP_SEC.Objects[sc]);
 for w := 0 to TheSector.Wl.Count - 1 do
  begin
   TheWall := TWall(TheSector.Wl.Objects[w]);
   if TheWall.Cycle = cy then
    begin
     Result := w;
     break;
    end;
  end;
end;

function  GetCycleFirstVx(sc, cy : Integer) : Integer;
var w         : Integer;
    TheSector : TSector;
    TheWall   : TWall;
begin
 Result := 999;
 TheSector := TSector(MAP_SEC.Objects[sc]);
 for w := 0 to TheSector.Wl.Count - 1 do
  begin
   TheWall := TWall(TheSector.Wl.Objects[w]);
   if TheWall.Cycle = cy then
    begin
     if TheWall.Left_vx  < Result then Result := TheWall.Left_vx;
     if TheWall.Right_vx < Result then Result := TheWall.Right_vx;
    end;
  end;
end;

{ POLYGON ********************************************************************}
{ POLYGON ********************************************************************}
{ POLYGON ********************************************************************}

procedure DO_Polygon;
var pt : TPoint;
    x  : Real;
    z  : Real;
begin
  GetCursorPos(pt);
  pt := MapWindow.Map.ScreenToClient(pt);
  x  := pt.x;
  z  := pt.y;
  x  := S2MX(x);
  z  := S2MZ(z);
  if GridOn then GetNearestGridPoint(x, z , x, z);
  ToolsWindow.EDPolyX.Text := PosTrim(x);
  ToolsWindow.EDPolyZ.Text := PosTrim(z);
  ToolsWindow.ToolsNotebook.PageIndex := 3;
  ToolsWindow.Show;
end;

procedure CreatePolygon(Sides : Integer; Radius, CX, CZ : Real;
                        PolyType, sc : Integer);
var    i          : Integer;
begin
 case PolyType of
  0: begin
      CreatePolygonGap(Sides, Radius, CX, CZ, sc);
     end;
  1: begin
      CreatePolygonGap(Sides, Radius, CX, CZ, sc);
      CreatePolygonSector(Sides, Radius, CX, CZ, sc);
      for i := 0 to Sides - 1 do MakeAdjoin(MAP_SEC.Count - 1, i);
     end;
  2: begin
      CreatePolygonSector(Sides, Radius, CX, CZ, sc);
     end;
 end;

 MODIFIED := TRUE;
 MapWindow.Map.Invalidate;
 CASE MAP_MODE of
  MM_SC : DO_Fill_SectorEditor;
  MM_WL : DO_Fill_WallEditor;
  MM_VX : DO_Fill_VertexEditor;
  MM_OB : DO_Fill_ObjectEditor;
 END;
end;


procedure CreatePolygonGap(Sides : Integer; Radius, CX, CZ : Real; sc : Integer);
var    i          : Integer;
       TheVertex  : TVertex;
       REFVertex  : TVertex;
       TheSector  : TSector;
       TMPSector  : TSector;
       TheWall    : TWall;
       REFWall    : TWall;
       alpha,
       delta      : Real;
       newvx      : Integer;
begin

 TheSector := TSector(MAP_SEC.Objects[sc]);
 if WL_HILITE < TheSector.Wl.COunt then
  REFWall   := TWall(TheSector.Wl.Objects[WL_HILITE])
 else
  REFWall   := TWall(TheSector.Wl.Objects[0]);
 newvx     := TheSector.Vx.Count;

{we'll use this one to store the calculated vertices}
TMPSector := TSector.Create;

alpha := 0.0;
delta := 2 * Pi / Sides;
for i := 0 to Sides - 1 do
 begin
  TheVertex      := TVertex.Create;

  // Special case to make neat squares (not diamonds).
  if sides = 4 then
     begin
      TheVertex.X    := CX + Radius * SEC_SQUARE[i].x;
      TheVertex.Z    := CZ + Radius * SEC_SQUARE[i].y;
     end
  else
     begin
      TheVertex.X    := CX + Radius * cos(alpha);
      TheVertex.Z    := CZ + Radius * sin(alpha);
      alpha          := alpha + delta;
     end;
  TheVertex.Mark := 0;
  TMPSector.Vx.AddObject('VX', TheVertex);
 end;

{So, the vertices positions are in TMPSector, and
 we'll use REFWall as a copy source}

for i := 0 to Sides - 1 do
 begin
  TheWall := TWall.Create;
  TheWall.Mark      := 0;
  TheWall.Left_vx   := newvx + i;
  if i <> Sides - 1 then
   TheWall.Right_vx := newvx + i + 1
  else
   TheWall.Right_vx := newvx;
  TheWall.Adjoin    := -1;
  TheWall.Mirror    := -1;
  TheWall.Walk      := -1;
  TheWall.Light     := REFWall.Light;
  TheWall.Flag1     := REFWall.Flag1;
  TheWall.Flag2     := REFWall.Flag2;
  TheWall.Flag3     := REFWall.Flag3;
  TheWall.Reserved  := 0;
  TheWall.Mid.Name  := REFWall.Mid.Name;
  TheWall.Mid.f1    := 0;
  TheWall.Mid.f2    := 0;
  TheWall.Mid.i     := 0;
  TheWall.Top.Name  := REFWall.Top.Name;
  TheWall.Top.f1    := 0;
  TheWall.Top.f2    := 0;
  TheWall.Top.i     := 0;
  TheWall.Bot.Name  := REFWall.Bot.Name;
  TheWall.Bot.f1    := 0;
  TheWall.Bot.f2    := 0;
  TheWall.Bot.i     := 0;
  TheWall.Sign.Name := '';
  TheWall.Sign.f1   := 0;
  TheWall.Sign.f2   := 0;
  TheWall.Elevator  := FALSE;
  TheWall.Trigger   := FALSE;
  TheSector.Wl.AddObject('WL', TheWall);

  REFVertex         := TVertex(TMPSector.Vx.Objects[i]);
  TheVertex         := TVertex.Create;
  TheVertex.Mark    := 0;
  TheVertex.X       := REFVertex.X;
  TheVertex.Z       := REFVertex.Z;
  TheSector.Vx.AddObject('VX', TheVertex);
 end;
 SC_HILITE := sc;
 WL_HILITE := 0;
 VX_HILITE := 0;

 {clean up the TMP sector}
 for i := 0 to TMPSector.Vx.Count - 1 do
    TVertex(TMPSector.Vx.Objects[i]).Free;
 TMPSector.Free;

 MODIFIED := TRUE;
end;

procedure CreatePolygonSector(Sides : Integer; Radius, CX, CZ : Real; sc : Integer);
var    i          : Integer;
       TheVertex  : TVertex;
       REFVertex  : TVertex;
       REFSector  : TSector;
       TMPSector  : TSector;
       NEWSector  : TSector;
       TheWall    : TWall;
       REFWall    : TWall;
       alpha,
       delta      : Real;
       newvx      : Integer;
begin
 REFSector            := TSector(MAP_SEC.Objects[sc]);
 NEWSector            := TSector.Create;
 NEWSector.Mark       := 0;
 NEWSector.Name       := '';
 NEWSector.Layer      := REFSector.Layer;
 NEWSector.Floor_alt  := REFSector.Floor_alt;
 NEWSector.Ceili_alt  := REFSector.Ceili_alt;
 NEWSector.Second_alt := REFSector.Second_alt;
 NEWSector.Ambient    := REFSector.Ambient;
 NEWSector.Flag1      := (((REFSector.Flag1 and not 2) and not 64) and not 524288);
 NEWSector.Flag2      := REFSector.Flag2;
 NEWSector.Flag3      := REFSector.Flag3;
 NEWSector.Reserved   := 0;
 NEWSector.Floor      := REFSector.Floor;
 NEWSector.Ceili      := REFSector.Ceili;
 NEWSector.Elevator   := FALSE;
 NEWSector.Trigger    := FALSE;
 NEWSector.Secret     := FALSE;
 NEWSector.INFClasses.Clear;

 if WL_HILITE < REFSector.Wl.Count then
  REFWall   := TWall(REFSector.Wl.Objects[WL_HILITE])
 else
  REFWall   := TWall(REFSector.Wl.Objects[0]);

 newvx     := 0;

{we'll use this one to store the calculated vertices}
TMPSector := TSector.Create;

// Special case to make neat squares (not diamonds).
alpha := 0.0;
if sides = 4 then
  alpha := Pi/2;

delta := 2 * Pi / Sides;
for i := 0 to Sides - 1 do
 begin
  TheVertex      := TVertex.Create;

  // Special case to make neat squares (not diamonds).
  if sides = 4 then
     begin
      TheVertex.X    := CX + Radius * SEC_SQUARE[i].x;
      TheVertex.Z    := CZ + Radius * SEC_SQUARE[i].y;
     end
  else
     begin
      TheVertex.X    := CX + Radius * cos(alpha);
      TheVertex.Z    := CZ + Radius * sin(alpha);
      alpha          := alpha + delta;
     end;

  TheVertex.Mark := 0;
  TMPSector.Vx.AddObject('VX', TheVertex);
 end;

{So, the vertices positions are in TMPSector, and
 we'll use REFWall as a copy source}

for i := 0 to Sides - 1 do
 begin
  TheWall := TWall.Create;
  TheWall.Mark      := 0;
  TheWall.Left_vx   := newvx + i;
  if i <> Sides - 1 then
   TheWall.Right_vx := newvx + i + 1
  else
   TheWall.Right_vx := newvx;
  TheWall.Adjoin    := -1;
  TheWall.Mirror    := -1;
  TheWall.Walk      := -1;
  TheWall.Light     := REFWall.Light;
  TheWall.Flag1     := REFWall.Flag1;
  TheWall.Flag2     := REFWall.Flag2;
  TheWall.Flag3     := REFWall.Flag3;
  TheWall.Reserved  := 0;
  TheWall.Mid.Name  := REFWall.Mid.Name;
  TheWall.Mid.f1    := 0;
  TheWall.Mid.f2    := 0;
  TheWall.Mid.i     := 0;
  TheWall.Top.Name  := REFWall.Top.Name;
  TheWall.Top.f1    := 0;
  TheWall.Top.f2    := 0;
  TheWall.Top.i     := 0;
  TheWall.Bot.Name  := REFWall.Bot.Name;
  TheWall.Bot.f1    := 0;
  TheWall.Bot.f2    := 0;
  TheWall.Bot.i     := 0;
  TheWall.Sign.Name := '';
  TheWall.Sign.f1   := 0;
  TheWall.Sign.f2   := 0;
  TheWall.Elevator  := FALSE;
  TheWall.Trigger   := FALSE;
  NEWSector.Wl.AddObject('WL', TheWall);

  REFVertex         := TVertex(TMPSector.Vx.Objects[Sides - 1 - i]);
  TheVertex         := TVertex.Create;
  TheVertex.Mark    := 0;
  TheVertex.X       := REFVertex.X;
  TheVertex.Z       := REFVertex.Z;
  NEWSector.Vx.AddObject('VX', TheVertex);
 end;

 MAP_SEC.AddObject('SC', NEWSector);

 SC_HILITE := MAP_SEC.Count - 1;
 WL_HILITE := 0;
 VX_HILITE := 0;

 {clean up the TMP sector}
 for i := 0 to TMPSector.Vx.Count - 1 do
    TVertex(TMPSector.Vx.Objects[i]).Free;
 TMPSector.Free;

 MODIFIED := TRUE;
end;

// Get an approximate horizontal length of the sector
function GetSectorMaxradius(sc : Integer) : integer;
var    i : integer;
       minx, maxx : Real;
       TheVertex  : TVertex;
       TheSector  : TSector;
begin

    TheSector := TSector(MAP_SEC.Objects[sc]);

    for i:= 0 to TheSector.Vx.Count - 1 do
     begin
       TheVertex := TVertex(TheSector.Vx.objects[i]);
       if i = 0 then
         begin
           minx := TheVertex.X;
           maxx := TheVertex.X;
         end
       else
         begin
           if TheVertex.X > maxx then maxx := TheVertex.X;
           if TheVertex.X < minx then minx := TheVertex.X;
         end;
     end;

    Result := trunc(maxx-minx);

end;

// Given a point - figure out if it fits inside the sector
function VerifyPolygonFits(Sides : Integer; Radius, CX, CZ : Real; sc : Integer) : Boolean;
var    i          : Integer;
       TheVertex  : TVertex;
       TheSector  : TSector;
       TMPSector  : TSector;
       alpha,
       delta     : Real;
       secPolygon  : array of TPoint;
       rgn : HRGN;
begin

  Result := True;
  TheSector := TSector(MAP_SEC.Objects[sc]);

  // Create region of sector verteces.
  SetLength(secPolygon, TheSector.Vx.Count);
  for i:= 0 to TheSector.Vx.Count - 1 do
    secPolygon[i] := VxToPoint(TVertex(TheSector.Vx.objects[i]));

  rgn := CreatePolygonRgn(secPolygon[0], Length(secPolygon), WINDING);

  { check if the tmp sector vertices are in region }
  TMPSector := TSector.Create;


  alpha := 0.0;
  delta := 2 * Pi / Sides;
  for i := 0 to Sides - 1 do
   begin
    TheVertex      := TVertex.Create;

    // Special case to make neat squares (not diamonds).
    if sides = 4 then
     begin
      TheVertex.X    := CX + Radius * SEC_SQUARE[i].x;
      TheVertex.Z    := CZ + Radius * SEC_SQUARE[i].y;
     end
    else begin
      TheVertex.X    := CX + Radius * cos(alpha);
      TheVertex.Z    := CZ + Radius * sin(alpha);
      alpha          := alpha + delta;
    end;


    // We don't want the subsector to be sticking outside the walls
    if not PtInRegion(rgn, trunc(m2sx(TheVertex.X)), trunc(m2sz(TheVertex.Z))) then
      begin
        Result := False;
        break;
      end;
   end;
  TMPSector.Free;

end;

{ DISTRIBUTE ******************************************************* }
{ DISTRIBUTE ******************************************************* }
{ DISTRIBUTE ******************************************************* }

procedure DO_Distribute(Altitudes : Boolean; FlCe : Integer; Ambient : Boolean);
var    m           : Integer;
       TheSector   : TSector;
       first_falt,
       last_falt   : Real;
       first_calt,
       last_calt   : Real;
       first_amb,
       last_amb    : Integer;
begin
 Do_StoreUndo;
 TheSector  := TSector(MAP_SEC.Objects[StrToInt(Copy(SC_MULTIS[0],1,4))]);
 first_falt := TheSector.Floor_Alt;
 first_calt := TheSector.Ceili_Alt;
 first_amb  := TheSector.Ambient;

 TheSector  := TSector(MAP_SEC.Objects[StrToInt(Copy(SC_MULTIS[SC_MULTIS.Count-1],1,4))]);
 last_falt  := TheSector.Floor_Alt;
 last_calt  := TheSector.Ceili_Alt;
 last_amb   := TheSector.Ambient;

 for m := 1 to SC_MULTIS.Count - 2 do
  begin
   TheSector := TSector(MAP_SEC.Objects[StrToInt(Copy(SC_MULTIS[m],1,4))]);
   if Altitudes then
    begin
     if (FlCe = 0) or (FlCe = 2) then
      begin
       TheSector.Floor_Alt := first_falt + (last_falt - first_falt)* m /(SC_MULTIS.Count -1);
      end;
     if (FlCe = 1) or (FlCe = 2) then
      begin
       TheSector.Ceili_Alt := first_calt + (last_calt - first_calt)* m /(SC_MULTIS.Count -1);
      end;
    end;
   if Ambient then
    begin
     TheSector.Ambient := first_amb + Round((last_amb - first_amb)* m /(SC_MULTIS.Count -1));
    end;
  end;
end;

{ STITCHING ******************************************************* }
{ STITCHING ******************************************************* }
{ STITCHING ******************************************************* }

procedure DO_StitchHorizontal(Mid, Top, Bot : Boolean);
var TheSector  : TSector;
    TheSector2 : TSector;
    TheWall    : TWall;
    Mofs       : Real;
    Tofs       : Real;
    Bofs       : Real;
    m          : Integer;
    Len        : Real;
begin
 Do_StoreUndo;
 TheSector  := TSector(MAP_SEC.Objects[StrToInt(Copy(WL_MULTIS[0],1,4))]);
 TheWall    := TWall(TheSector.Wl.Objects[StrToInt(Copy(WL_MULTIS[0],5,4))]);

 TheWall := NormalizeWall(TheWall);
 Len        := GetWLLen(StrToInt(Copy(WL_MULTIS[0],1,4)), StrToInt(Copy(WL_MULTIS[0],5,4)));
 Mofs       := TheWall.Mid.f1 + Len;
 Tofs       := TheWall.Top.f1 + Len;
 Bofs       := TheWall.Bot.f1 + Len;

 for m := 1 to WL_MULTIS.Count - 1 do
  begin
    TheSector  := TSector(MAP_SEC.Objects[StrToInt(Copy(WL_MULTIS[m],1,4))]);
    TheWall    := TWall(TheSector.Wl.Objects[StrToInt(Copy(WL_MULTIS[m],5,4))]);

    {keep the relative position of the SIGN}
    if (TheWall.Sign.Name <> '') then
     begin
      if TheWall.Adjoin = - 1 then
       begin
        if Mid then
         TheWall.Sign.f1 := TheWall.Sign.f1 + MOfs - TheWall.Mid.f1;
       end
      else
       begin
        TheSector2 := TSector(MAP_SEC.Objects[TheWall.Adjoin]);
        if TheSector2.Floor_Alt > TheSector.Floor_Alt then
         begin
          {there is a bot tx, so the SIGN is on the bot tx !}
          if Bot then
           TheWall.Sign.f1 := TheWall.Sign.f1 + BOfs - TheWall.Bot.f1;
         end
        else
         if TheSector2.Ceili_Alt < TheSector.Ceili_Alt then
          begin
          {there is no bot tx, but well a top tx,
           so the SIGN is on the top tx !}
           if Top then
            TheWall.Sign.f1 := TheWall.Sign.f1 + TOfs - TheWall.Top.f1;
          end
       end;
     end;

    if Mid then TheWall.Mid.f1 := MOfs;
    if Top then TheWall.Top.f1 := TOfs;
    if Bot then TheWall.Bot.f1 := BOfs;

    Len        := GetWLLen(StrToInt(Copy(WL_MULTIS[m],1,4)), StrToInt(Copy(WL_MULTIS[m],5,4)));
    Mofs       := Mofs + Len;
    Tofs       := Tofs + Len;
    Bofs       := Bofs + Len;
    TheWall := NormalizeWall(TheWall);
  end;

end;


procedure DO_StitchHorizontalInvert(Mid, Top, Bot : Boolean);
var TheSector  : TSector;
    TheSector2 : TSector;
    TheWall    : TWall;
    Mofs       : Real;
    Tofs       : Real;
    Bofs       : Real;
    m          : Integer;
    Len        : Real;
begin
 Do_StoreUndo;
 TheSector  := TSector(MAP_SEC.Objects[StrToInt(Copy(WL_MULTIS[WL_MULTIS.Count-1],1,4))]);
 TheWall    := TWall(TheSector.Wl.Objects[StrToInt(Copy(WL_MULTIS[WL_MULTIS.Count-1],5,4))]);
 TheWall    := NormalizeWall(TheWall);
 Mofs       := TheWall.Mid.f1;
 Tofs       := TheWall.Top.f1;
 Bofs       := TheWall.Bot.f1;

 for m := WL_MULTIS.Count - 2 downto 0 do
  begin
    TheSector  := TSector(MAP_SEC.Objects[StrToInt(Copy(WL_MULTIS[m],1,4))]);
    TheWall    := TWall(TheSector.Wl.Objects[StrToInt(Copy(WL_MULTIS[m],5,4))]);
    Len        := GetWLLen(StrToInt(Copy(WL_MULTIS[m],1,4)), StrToInt(Copy(WL_MULTIS[m],5,4)));
    Mofs       := Mofs - Len;
    Tofs       := Tofs - Len;
    Bofs       := Bofs - Len;

    {keep the relative position of the SIGN}
    if (TheWall.Sign.Name <> '') then
     begin
      if TheWall.Adjoin = - 1 then
       begin
        if Mid then
         TheWall.Sign.f1 := TheWall.Sign.f1 + MOfs - TheWall.Mid.f1;
       end
      else
       begin
        TheSector2 := TSector(MAP_SEC.Objects[TheWall.Adjoin]);
        if TheSector2.Floor_Alt > TheSector.Floor_Alt then
         begin
          {there is a bot tx, so the SIGN is on the bot tx !}
          if Bot then
           TheWall.Sign.f1 := TheWall.Sign.f1 + BOfs - TheWall.Bot.f1;
         end
        else
         if TheSector2.Ceili_Alt < TheSector.Ceili_Alt then
          begin
          {there is no bot tx, but well a top tx,
           so the SIGN is on the top tx !}
           if Top then
            TheWall.Sign.f1 := TheWall.Sign.f1 + TOfs - TheWall.Top.f1;
          end
       end;
     end;

    if Mid then TheWall.Mid.f1 := MOfs;
    if Top then TheWall.Top.f1 := TOfs;
    if Bot then TheWall.Bot.f1 := BOfs;
    TheWall := NormalizeWall(TheWall);
  end;

end;


procedure DO_StitchVertical(Mid, Top, Bot : Boolean);
var TheSector : TSector;
    TheWall   : TWall;
    Mofs      : Real;
    Tofs      : Real;
    Bofs      : Real;
    m         : Integer;
    Floor     : Real;
begin
 Do_StoreUndo;
 TheSector  := TSector(MAP_SEC.Objects[StrToInt(Copy(WL_MULTIS[0],1,4))]);
 Floor      := TheSector.Floor_Alt;
 TheWall    := TWall(TheSector.Wl.Objects[StrToInt(Copy(WL_MULTIS[0],5,4))]);

 Mofs       := TheWall.Mid.f2;
 Tofs       := TheWall.Top.f2;
 Bofs       := TheWall.Bot.f2;

 for m := 1 to WL_MULTIS.Count - 1 do
  begin
    TheSector  := TSector(MAP_SEC.Objects[StrToInt(Copy(WL_MULTIS[m],1,4))]);
    TheWall    := TWall(TheSector.Wl.Objects[StrToInt(Copy(WL_MULTIS[m],5,4))]);
    if Mid then TheWall.Mid.f2 := MOfs + TheSector.Floor_Alt - Floor;
    if Top then TheWall.Top.f2 := TOfs + TheSector.Floor_Alt - Floor;
    if Bot then TheWall.Bot.f2 := BOfs + TheSector.Floor_Alt - Floor;
  end;
end;


{ DEFORMATIONS ************************************************************* }
{ DEFORMATIONS ************************************************************* }
{ DEFORMATIONS ************************************************************* }

procedure DO_PrepareDeformation;
var i,j,m     : Integer;
    TheSector : TSector;
    TheVertex : TVertex;
    LVertex   : TVertex;
    RVertex   : TVertex;
    TheWall   : TWall;
    TheObject : TOB;
begin
{First clear the vertex or object marks}
IF MAP_MODE <> MM_OB THEN
 for i := 0 to MAP_SEC.Count - 1 do
  begin
   TheSector := TSector(MAP_SEC.Objects[i]);
   TheSector.Mark := 0;
   for j := 0 to TheSector.Vx.Count - 1 do
    begin
     TheVertex      := TVertex(TheSector.Vx.Objects[j]);
     TheVertex.Mark := 0;
    end;
  end
ELSE
 for i := 0 to MAP_OBJ.Count - 1 do
   begin
    TheObject := TOB(MAP_OBJ.Objects[i]);
    TheObject.Mark := 0;
   end;

 CASE MAP_MODE OF
  MM_SC : begin
           {selection}
           TheSector  := TSector(MAP_SEC.Objects[SC_HILITE]);
           TheSector.Mark := 1;
           for j := 0 to TheSector.Vx.Count - 1 do
            begin
             TheVertex      := TVertex(TheSector.Vx.Objects[j]);
             TheVertex.Mark := 1;
             if j = 0 then
              begin
               DEFORM_X := TheVertex.X;
               DEFORM_Z := TheVertex.Z;
              end;
            end;
           {multiselection}
           for m := 0 to SC_MULTIS.Count - 1 do
            begin
             TheSector  := TSector(MAP_SEC.Objects[StrToInt(Copy(SC_MULTIS[m],1,4))]);
             TheSector.Mark := 1;
             for j := 0 to TheSector.Vx.Count - 1 do
              begin
               TheVertex      := TVertex(TheSector.Vx.Objects[j]);
               TheVertex.Mark := 1;
              end;
            end;
          end;
  MM_WL : begin
           {selection}
           TheSector  := TSector(MAP_SEC.Objects[SC_HILITE]);
           TheWall    := TWall(TheSector.Wl.Objects[WL_HILITE]);
           LVertex    := TVertex(TheSector.Vx.Objects[TheWall.left_vx]);
           LVertex.Mark := 1;
           DEFORM_X := LVertex.X;
           DEFORM_Z := LVertex.Z;
           RVertex    := TVertex(TheSector.Vx.Objects[TheWall.right_vx]);
           RVertex.Mark := 1;
           {multiselection}
           for m := 0 to WL_MULTIS.Count - 1 do
            begin
             TheSector  := TSector(MAP_SEC.Objects[StrToInt(Copy(WL_MULTIS[m],1,4))]);
             TheWall    := TWall(TheSector.Wl.Objects[StrToInt(Copy(WL_MULTIS[m],5,4))]);
             LVertex    := TVertex(TheSector.Vx.Objects[TheWall.left_vx]);
             LVertex.Mark := 1;
             RVertex    := TVertex(TheSector.Vx.Objects[TheWall.right_vx]);
             RVertex.Mark := 1;
            end;
          end;
  MM_VX : begin
           {selection}
           TheSector  := TSector(MAP_SEC.Objects[SC_HILITE]);
           TheVertex  := TVertex(TheSector.Vx.Objects[VX_HILITE]);
           TheVertex.Mark := 1;
           DEFORM_X := TheVertex.X;
           DEFORM_Z := TheVertex.Z;
           {multiselection}
           for m := 0 to VX_MULTIS.Count - 1 do
            begin
             TheSector  := TSector(MAP_SEC.Objects[StrToInt(Copy(VX_MULTIS[m],1,4))]);
             TheVertex  := TVertex(TheSector.Vx.Objects[StrToInt(Copy(VX_MULTIS[m],5,4))]);
             TheVertex.Mark := 1;
            end;
          end;
  MM_OB : begin
           {selection}
           TheObject  := TOB(MAP_OBJ.Objects[OB_HILITE]);
           TheObject.Mark := 1;
           DEFORM_X := TheObject.X;
           DEFORM_Z := TheObject.Z;
           {multiselection}
           for m := 0 to OB_MULTIS.Count - 1 do
            begin
             TheObject  := TOB(MAP_OBJ.Objects[StrToInt(Copy(OB_MULTIS[m],5,4))]);
             TheObject.Mark := 1;
            end;
          end;
 END;
end;

procedure DO_Translate(x, z : Real);
var i,j       : Integer;
    TheSector : TSector;
    TheVertex : TVertex;
    TheObject : TOB;
begin
 DO_PrepareDeformation;

 IF MAP_MODE <> MM_OB THEN
 for i := 0 to MAP_SEC.Count - 1 do
  begin
   TheSector := TSector(MAP_SEC.Objects[i]);
   for j := 0 to TheSector.Vx.Count - 1 do
    begin
     TheVertex      := TVertex(TheSector.Vx.Objects[j]);
     if TheVertex.Mark <> 0 then
      begin
       TheVertex.X    := TheVertex.X + x;
       TheVertex.Z    := TheVertex.Z + z;
       TheVertex.Mark := 0;
      end
     else
      TheVertex.Mark := 0;
    end;
  end
ELSE
 for i := 0 to MAP_OBJ.Count - 1 do
   begin
    TheObject := TOB(MAP_OBJ.Objects[i]);
    if TheObject.Mark <> 0 then
     begin
      TheObject.X    := TheObject.X + x;
      TheObject.Z    := TheObject.Z + z;
      TheObject.Mark := 0;
     end
    else
     TheObject.Mark := 0;
   end;
end;

procedure DO_Rotate(angle : Real; OBOrient : Boolean);
var i,j       : Integer;
    TheSector : TSector;
    TheVertex : TVertex;
    TheObject : TOB;
    rad       : Real;
    oldx      : Real;
begin
 DO_PrepareDeformation;

 rad := angle * Pi / 180;

 IF MAP_MODE <> MM_OB THEN
 for i := 0 to MAP_SEC.Count - 1 do
  begin
   TheSector := TSector(MAP_SEC.Objects[i]);
   for j := 0 to TheSector.Vx.Count - 1 do
    begin
     TheVertex      := TVertex(TheSector.Vx.Objects[j]);
     if TheVertex.Mark <> 0 then
      begin
       oldx           := TheVertex.X;
       TheVertex.X    := DEFORM_X +
                          (cos(rad) * (TheVertex.X - DEFORM_X)
                         - sin(rad) * (TheVertex.Z - DEFORM_Z));
       TheVertex.Z    := DEFORM_Z +
                          (sin(rad) * (oldx        - DEFORM_X)
                         + cos(rad) * (TheVertex.Z - DEFORM_Z));
       TheVertex.Mark := 0;
      end
     else
      TheVertex.Mark := 0;
    end;
  end
ELSE
 for i := 0 to MAP_OBJ.Count - 1 do
   begin
    TheObject := TOB(MAP_OBJ.Objects[i]);
    if TheObject.Mark <> 0 then
     begin
      oldx           := TheObject.X;
      TheObject.X    := DEFORM_X +
                         (cos(rad) * (TheObject.X - DEFORM_X)
                        - sin(rad) * (TheObject.Z - DEFORM_Z));
      TheObject.Z    := DEFORM_Z +
                         (sin(rad) * (oldx        - DEFORM_X)
                        + cos(rad) * (TheObject.Z - DEFORM_Z));
      if OBOrient then
       begin
        TheObject.Yaw  := TheObject.Yaw + 360 - angle;
        if TheObject.Yaw >= 360 then
         TheObject.Yaw := TheObject.Yaw - 360;
       end;
      TheObject.Mark := 0;
     end
    else
     TheObject.Mark := 0;
   end;
end;

procedure DO_Scale(factor : Real);
var i,j       : Integer;
    TheSector : TSector;
    TheVertex : TVertex;
    TheObject : TOB;
begin
 DO_PrepareDeformation;

IF MAP_MODE <> MM_OB THEN
 for i := 0 to MAP_SEC.Count - 1 do
  begin
   TheSector := TSector(MAP_SEC.Objects[i]);
   for j := 0 to TheSector.Vx.Count - 1 do
    begin
     TheVertex      := TVertex(TheSector.Vx.Objects[j]);
     if TheVertex.Mark <> 0 then
      begin
       TheVertex.X    := DEFORM_X + (TheVertex.X - DEFORM_X) * factor;
       TheVertex.Z    := DEFORM_Z + (TheVertex.Z - DEFORM_Z) * factor;
       TheVertex.Mark := 0;
      end
     else
      TheVertex.Mark := 0;
    end;
  end
ELSE
 for i := 0 to MAP_OBJ.Count - 1 do
   begin
    TheObject := TOB(MAP_OBJ.Objects[i]);
    if TheObject.Mark <> 0 then
     begin
      TheObject.X    := DEFORM_X + (TheObject.X - DEFORM_X) * factor;
      TheObject.Z    := DEFORM_Z + (TheObject.Z - DEFORM_Z) * factor;
      TheObject.Mark := 0;
     end
    else
     TheObject.Mark := 0;
   end;
end;

procedure DO_PrepareFlipping;
var i, m      : Integer;
    TheSector : TSector;
begin
 {First Clear the Sector Marks}
 IF MAP_MODE = MM_SC THEN
  for i := 0 to MAP_SEC.Count - 1 do
   begin
    TheSector := TSector(MAP_SEC.Objects[i]);
    TheSector.Mark := 0;
   end;

  {we'll set the number of cycles in Mark !!!}

  {selection}
  TheSector  := TSector(MAP_SEC.Objects[SC_HILITE]);
  TheSector.Mark := SetSectorCycles(SC_HILITE);
  {multiselection}
  for m := 0 to SC_MULTIS.Count - 1 do
   begin
    TheSector  := TSector(MAP_SEC.Objects[StrToInt(Copy(SC_MULTIS[m],1,4))]);
    TheSector.Mark := SetSectorCycles(StrToInt(Copy(SC_MULTIS[m],1,4)));
   end;
end;

procedure DO_Flip(Horiz : Boolean; OBOrient : Boolean);
var i, j, c    : Integer;
    TheSector  : TSector;
    TheVertex  : TVertex;
    TheVertex1,
    TheVertex2 : TVertex;
    TheObject  : TOB;
    TheWall    : TWall;
    vxl,
    vxh        : Integer;
    wll,
    wlh        : Integer;
    OldCursor : HCursor;
begin
OldCursor  := SetCursor(LoadCursor(0, IDC_WAIT));

DO_PrepareDeformation;

IF MAP_MODE = MM_SC THEN
 BEGIN
   DO_PrepareFlipping;
   for i := 0 to MAP_SEC.Count - 1 do
    begin
     TheSector := TSector(MAP_SEC.Objects[i]);
     for j := 0 to TheSector.Vx.Count - 1 do
      begin
       TheVertex := TVertex(TheSector.Vx.Objects[j]);
       if TheVertex.Mark <> 0 then
        begin
         if Horiz then
          TheVertex.X := TheVertex.X - 2 * (TheVertex.X - DEFORM_X)
         else
          TheVertex.Z := TheVertex.Z - 2 * (TheVertex.Z - DEFORM_Z);
         TheVertex.Mark := 0;
        end
       else
        TheVertex.Mark := 0;
      end;
    end;
   { restore correct sectors walls and vertices }
   TheVertex := TVertex.Create;
   for i := 0 to MAP_SEC.Count - 1 do
    begin
     TheSector := TSector(MAP_SEC.Objects[i]);
     {Invert Vertices by Cycle!!!}
     {remember Mark contains the number of cycles !!!}
     if TheSector.Mark <> 0 then
      begin
       for c:= 1 to TheSector.Mark do
        begin
         {prepare vxh and vxl for this cycle}
         vxh := -1;
         vxl := 999;
         for j := 0 to TheSector.Wl.Count - 1 do
          begin
           TheWall := TWall(TheSector.Wl.Objects[j]);
           if TheWall.Cycle = c then
            begin
             if TheWall.Left_vx > vxh  then vxh := TheWall.Left_vx;
             if TheWall.Left_vx < vxl  then vxl := TheWall.Left_vx;
             if TheWall.Right_vx > vxh then vxh := TheWall.Right_vx;
             if TheWall.Right_vx < vxl then vxl := TheWall.Right_vx;
            end;
          end;
         {invert the vertices of this cycle}
         for j := vxl to vxl + ((vxh-vxl) div 2) do
          begin
           TheVertex1   := TVertex(TheSector.Vx.Objects[j]);
           TheVertex2   := TVertex(TheSector.Vx.Objects[vxh + vxl - j]);
           TheVertex.X  := TheVertex1.X;
           TheVertex.Z  := TheVertex1.Z;
           TheVertex1.X := TheVertex2.X;
           TheVertex1.Z := TheVertex2.Z;
           TheVertex2.X := TheVertex.X;
           TheVertex2.Z := TheVertex.Z;
          end;
        end;
     end;
    end;
    TheVertex.Free;
   for i := 0 to MAP_SEC.Count - 1 do
    begin
     TheSector := TSector(MAP_SEC.Objects[i]);
     {remember Mark contains the number of cycles !!!}
     if TheSector.Mark <> 0 then
      begin
       for c:= 1 to TheSector.Mark do
        begin
         wlh := -1;
         wll := 999;
         for j := 0 to TheSector.Wl.Count - 1 do
          begin
           TheWall := TWall(TheSector.Wl.Objects[j]);
           if TheWall.Cycle = c then
            begin
             if j > wlh then wlh := j;
             if j < wll then wll := j;
            end;
          end;

         for j := wll to wll + ((wlh - 1 -wll) div 2) do
          begin
           {the LAST WALL MUST NOT BE TAKEN !!!}
           SwapWLContents(i, j, wlh + wll - j - 1);
          end;

        end;
      end;
    end;
   for i := 0 to MAP_SEC.Count - 1 do
    begin
     TheSector := TSector(MAP_SEC.Objects[i]);
     if TheSector.Mark <> 0 then
      begin
       for j := 0 to TheSector.Wl.Count - 1 do
          begin
           UnAdjoin(i,j);
          end;
       for j := 0 to TheSector.Wl.Count - 1 do
          begin
           MakeAdjoin(i, j);
          end;
      end;
    end;
 END
ELSE
 for i := 0 to MAP_OBJ.Count - 1 do
   begin
    TheObject := TOB(MAP_OBJ.Objects[i]);
    if TheObject.Mark <> 0 then
     begin
      if Horiz then
       TheObject.X := TheObject.X - 2 * (TheObject.X - DEFORM_X)
      else
       TheObject.Z := TheObject.Z - 2 * (TheObject.Z - DEFORM_Z);
      {object orientation}
      if OBOrient then
       if Horiz then
        begin
         TheObject.Yaw := 360 - TheObject.Yaw;
         if TheObject.Yaw >= 360 then TheObject.Yaw := TheObject.Yaw - 360;
        end
       else
        if TheObject.Yaw <= 180 then
         TheObject.Yaw := 180 - TheObject.Yaw
        else
         TheObject.Yaw := 540 - TheObject.Yaw;

      TheObject.Mark := 0;
     end
    else
     TheObject.Mark := 0;
   end;

SetCursor(OldCursor);

end;

procedure SwapWLContents(sc, wl1, wl2 : Integer);
var TheSector  : TSector;
    TheWall1   : TWall;
    TheWall2   : TWall;
    TMPWall    : TWall;
begin
  TheSector  := TSector(MAP_SEC.Objects[sc]);
  TheWall1   := TWall(TheSector.Wl.Objects[wl1]);
  TheWall2   := TWall(TheSector.Wl.Objects[wl2]);
  TMPWall    := TWall.Create;

 TMPWall.Adjoin       := TheWall1.Adjoin;
 TMPWall.Mirror       := TheWall1.Mirror;
 TMPWall.Walk         := TheWall1.Walk;
 TMPWall.Light        := TheWall1.Light;
 TMPWall.Flag1        := TheWall1.Flag1;
 TMPWall.Flag2        := TheWall1.Flag2;
 TMPWall.Flag3        := TheWall1.Flag3;
 TMPWall.Mid.Name     := TheWall1.Mid.Name;
 TMPWall.Mid.f1       := TheWall1.Mid.f1;
 TMPWall.Mid.f2       := TheWall1.Mid.f2;
 TMPWall.Mid.i        := TheWall1.Mid.i;
 TMPWall.Top.Name     := TheWall1.Top.Name;
 TMPWall.Top.f1       := TheWall1.Top.f1;
 TMPWall.Top.f2       := TheWall1.Top.f2;
 TMPWall.Top.i        := TheWall1.Top.i;
 TMPWall.Bot.Name     := TheWall1.Bot.Name;
 TMPWall.Bot.f1       := TheWall1.Bot.f1;
 TMPWall.Bot.f2       := TheWall1.Bot.f2;
 TMPWall.Bot.i        := TheWall1.Bot.i;
 TMPWall.Sign.Name    := TheWall1.Sign.Name;
 TMPWall.Sign.f1      := TheWall1.Sign.f1;
 TMPWall.Sign.f2      := TheWall1.Sign.f2;

 TheWall1.Adjoin       := TheWall2.Adjoin;
 TheWall1.Mirror       := TheWall2.Mirror;
 TheWall1.Walk         := TheWall2.Walk;
 TheWall1.Light        := TheWall2.Light;
 TheWall1.Flag1        := TheWall2.Flag1;
 TheWall1.Flag2        := TheWall2.Flag2;
 TheWall1.Flag3        := TheWall2.Flag3;
 TheWall1.Mid.Name     := TheWall2.Mid.Name;
 TheWall1.Mid.f1       := TheWall2.Mid.f1;
 TheWall1.Mid.f2       := TheWall2.Mid.f2;
 TheWall1.Mid.i        := TheWall2.Mid.i;
 TheWall1.Top.Name     := TheWall2.Top.Name;
 TheWall1.Top.f1       := TheWall2.Top.f1;
 TheWall1.Top.f2       := TheWall2.Top.f2;
 TheWall1.Top.i        := TheWall2.Top.i;
 TheWall1.Bot.Name     := TheWall2.Bot.Name;
 TheWall1.Bot.f1       := TheWall2.Bot.f1;
 TheWall1.Bot.f2       := TheWall2.Bot.f2;
 TheWall1.Bot.i        := TheWall2.Bot.i;
 TheWall1.Sign.Name    := TheWall2.Sign.Name;
 TheWall1.Sign.f1      := TheWall2.Sign.f1;
 TheWall1.Sign.f2      := TheWall2.Sign.f2;

 TheWall2.Adjoin       := TMPWall.Adjoin;
 TheWall2.Mirror       := TMPWall.Mirror;
 TheWall2.Walk         := TMPWall.Walk;
 TheWall2.Light        := TMPWall.Light;
 TheWall2.Flag1        := TMPWall.Flag1;
 TheWall2.Flag2        := TMPWall.Flag2;
 TheWall2.Flag3        := TMPWall.Flag3;
 TheWall2.Mid.Name     := TMPWall.Mid.Name;
 TheWall2.Mid.f1       := TMPWall.Mid.f1;
 TheWall2.Mid.f2       := TMPWall.Mid.f2;
 TheWall2.Mid.i        := TMPWall.Mid.i;
 TheWall2.Top.Name     := TMPWall.Top.Name;
 TheWall2.Top.f1       := TMPWall.Top.f1;
 TheWall2.Top.f2       := TMPWall.Top.f2;
 TheWall2.Top.i        := TMPWall.Top.i;
 TheWall2.Bot.Name     := TMPWall.Bot.Name;
 TheWall2.Bot.f1       := TMPWall.Bot.f1;
 TheWall2.Bot.f2       := TMPWall.Bot.f2;
 TheWall2.Bot.i        := TMPWall.Bot.i;
 TheWall2.Sign.Name    := TMPWall.Sign.Name;
 TheWall2.Sign.f1      := TMPWall.Sign.f1;
 TheWall2.Sign.f2      := TMPWall.Sign.f2;

  TMPWall.Free;
end;

procedure DO_OffsetAltitude(y : Real; alt : Integer);
var i,j       : Integer;
    TheSector : TSector;
    TheVertex : TVertex;
    TheObject : TOB;
begin
 DO_PrepareDeformation;

IF MAP_MODE <> MM_OB THEN
 for i := 0 to MAP_SEC.Count - 1 do
  begin
   TheSector := TSector(MAP_SEC.Objects[i]);
   if TheSector.Mark <> 0 then
    begin
     if (alt = 0) or (alt = 1) then
      TheSector.Floor_alt := TheSector.Floor_alt + y;
     if (alt = 0) or (alt = 2) then
      TheSector.Ceili_alt := TheSector.Ceili_alt + y;
     TheSector.Mark := 0;
    end;
  end
ELSE
 for i := 0 to MAP_OBJ.Count - 1 do
  begin
   TheObject := TOB(MAP_OBJ.Objects[i]);
   if TheObject.Mark <> 0 then
    begin
     TheObject.Y    := TheObject.Y + y;
     TheObject.Mark := 0;
    end;
  end;
end;

procedure DO_OffsetAmbient(a : Integer);
var i,j       : Integer;
    TheSector : TSector;
begin
 DO_PrepareDeformation;

 for i := 0 to MAP_SEC.Count - 1 do
  begin
   TheSector := TSector(MAP_SEC.Objects[i]);
   if TheSector.Mark <> 0 then
    begin
     TheSector.Ambient := TheSector.Ambient + a;
     if TheSector.Ambient > 31 then TheSector.Ambient := 31;
     if TheSector.Ambient < 0  then TheSector.Ambient := 0;
     TheSector.Mark := 0;
    end;
  end;

end;

procedure DO_SplitSector(s, d, n, sc, wl1, wl2 : Integer);
var TheSector  : TSector;
    TheWall1   : TWall;
    TheWall2   : TWall;
    TheVertex0 : TVertex;
    TheVertex1 : TVertex;
    TheVertex2 : TVertex;
    TheVertex3 : TVertex;
begin
 TheSector  := TSector(MAP_SEC.Objects[sc]);
 TheWall1   := TWall(TheSector.Wl.Objects[wl1]);
 TheWall2   := TWall(TheSector.Wl.Objects[wl2]);
 TheVertex0 := TVertex(TheSector.Vx.Objects[0]);
 TheVertex1 := TVertex(TheSector.Vx.Objects[1]);
 TheVertex2 := TVertex(TheSector.Vx.Objects[2]);
 TheVertex3 := TVertex(TheSector.Vx.Objects[3]);


 { "I should have written a generic multi-split wall and a generic split
 sector FIRST, all the rest would have been easier!"  }

 CASE s OF
  0 : { door 1 - 1 - 1}
      begin

      end;
  1 : { door 1 - 2 - 1}
      begin
      end;
  2 : {stairs, distribution d, #steps n }
      begin
      end;
 END;
end;

end.
