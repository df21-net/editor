unit Level_Utils;

interface
uses Level, misc_utils, MultiSelection, SysUtils, Math, ProgressDialog;
Const
     Any_Layer=-5000;
     o_floors=1;
     o_ceilings=2;
     o_fcs=0;

{Complex level tranformations}

Procedure TranslateSector(L:TLevel;sc:Integer;x,z:double);
Procedure TranslateWall(L:TLevel;sc,wl:Integer;x,z:double);
Procedure TranslateVertex(L:TLevel;sc,vx:Integer;x,z:double);
Procedure TranslateObject(L:TLevel;ob:Integer;x,z:double);

Procedure RaiseSectorSelection(L:TLevel;sel:TMultiSelection;DY:Double;How:Integer);
Procedure RaiseObjectSelection(L:TLevel;sel:TMultiSelection;DY:Double);

Procedure TranslateSectorSelection(L:TLevel;sel:TMultiSelection;x,z:Double);
Procedure TranslateWallSelection(L:TLevel;sel:TMultiSelection;x,z:Double);
Procedure TranslateVertexSelection(L:TLevel;sel:TMultiSelection;x,z:Double);
Procedure TranslateObjectSelection(L:TLevel;sel:TMultiSelection;dx,dz:Double);

Procedure RotateSectorSelection(L:TLevel;sel:TMultiSelection;x,z,angle:Double);
Procedure RotateWallSelection(L:TLevel;sel:TMultiSelection;x,z,angle:Double);
Procedure RotateVertexSelection(L:TLevel;sel:TMultiSelection;x,z,angle:Double);
Procedure RotateObjectSelection(L:TLevel;sel:TMultiSelection;def_x,def_z,angle:Double;ObOrient:Boolean);

Procedure ScaleSectorSelection(L:TLevel;sel:TMultiSelection;x,z,factor:Double);
Procedure ScaleWallSelection(L:TLevel;sel:TMultiSelection;x,z,factor:Double);
Procedure ScaleVertexSelection(L:TLevel;sel:TMultiSelection;x,z,factor:Double);
Procedure ScaleObjectSelection(L:TLevel;sel:TMultiSelection;def_x,def_z,factor:Double);


Procedure DeleteSector(L:TLevel;sc:Integer);
Procedure DeleteVertex(L:TLevel;sc,vx:Integer);
Procedure DeleteWall(L:TLevel;sc,wl:Integer);
Procedure DeleteOB(L:TLevel;ob:Integer);
Procedure ClearVertexMarks(L:TLevel);
function MakeAdjoin(L:Tlevel; sc, wl : Integer) : Integer;
function MakeAdjoinFromSCUp(L:Tlevel; sc, wl : Integer;firstSC:Integer) : Integer;
function UnAdjoin(L:Tlevel; sc, wl : Integer) : Integer;
Function SplitWall(l:TLevel; sc, wl : Integer):Integer;
Function GetWLLen(L:TLevel;sc, wl:integer):Double;
function  GetWLfromV1(l:TLevel;sector, V1 : Integer) : Integer;
function  GetWLfromV2(l:TLevel;sector, V2 : Integer) : Integer;

Function CreatePolygonSector(l:TLevel;x,z,radius:Double;sides,likeSC,likeWL:Integer):Integer;
Procedure CreatePolygonGap(l:TLevel;sc:Integer;x,z,radius:Double;sides,likeSC,likeWL:Integer);

Procedure ExtrudeWall(L:TLevel;sc,wl:Integer;ExtrudeBy:Double);

function  GetNearestWL(L:TLevel; Layer:Integer; X, Z : Double; VAR ASector : Integer; VAR AWall : Integer) : Boolean;
function  GetNearestSC(L:TLevel; Layer:Integer; X, Z : Double; VAR ASector : Integer) : Boolean;
function  GetNextNearestSC(L:TLevel; Layer:Integer; X, Z : Double; VAR ASector : Integer) : Boolean;
function  GetNearestVX(L:TLevel; Layer:Integer; X, Z : Double; VAR ASector : Integer; VAR AVertex : Integer) : Boolean;
function  GetNearestOB(L:TLevel; Layer:Integer; X, Z : Double; VAR AObject : Integer) : Boolean;
function  GetNextNearestVX(L:TLevel; Layer:Integer; X, Z : Double; VAR ASector : Integer; VAR AVertex : Integer) : Boolean;

function  GetObjectSC(L:TLevel;Layer:Integer; obnum: Integer; VAR ASector : Integer) : Boolean;
Procedure ApplyFixUp(L:TLevel;const Name:String);
Function IsInSector(Sc:TSector;ptx,ptz:double):boolean;
Function GetFloorAt(L:TLevel;sc:integer;x,z:double):double;
Function GetCeilingAt(L:TLevel;sc:integer;x,z:double):double;
function  PutOnFloor(L:TLevel;Layer:Integer; obnum: Integer) : Boolean;
function  PutOnCeiling(L:TLevel;Layer:Integer; obnum: Integer) : Boolean;
Function ReverseAdjoinValid(L:TLevel; sc,wl:Integer):Boolean;

implementation
uses Files, FileOperations, Windows;

Function ReverseAdjoinValid(L:TLevel; sc,wl:Integer):Boolean;
var TheSector:TSector;
    TheWall:TWall;
    vx11,vx12:TVertex;

Function WallOK(nSc,nWl:Integer):boolean;
var vx21,vx22:TVertex;
    wl1,wl2:boolean;
    sec:TSector;
    wall:TWall;
begin
 sec:=L.Sectors[nSc];
 wall:=Sec.Walls[nWl];
 Result:=false;
 if ((Wall.Adjoin<>sc) and (Wall.Mirror<>wl)) and
    ((Wall.DAdjoin<>sc) and (Wall.DMirror<>wl)) then exit;
 Vx21:=Sec.Vertices[Wall.V1];
 Vx22:=Sec.Vertices[Wall.V2];
 Result:=((vx11.x=vx22.x) and (vx11.z=vx22.z)) and
         ((vx12.x=vx21.x) and (vx12.z=vx21.z));
end;

begin
 if (sc<-1) or (sc>=L.Sectors.Count) then begin Result:=false; exit; end;
 if sc=-1 then begin Result:=true; exit; end;

 TheSector:=L.Sectors[sc];
 TheWall:=TheSector.Walls[wl];

 vx11:=TheSector.Vertices[TheWall.V1];
 vx12:=TheSector.Vertices[TheWall.V2];

 Result:=true;
 if TheWall.Adjoin<>-1 then Result:=WallOK(TheWall.Adjoin,TheWall.Mirror);
 if TheWall.DAdjoin<>-1 then Result:=Result and WallOK(TheWall.DAdjoin,TheWall.DMirror);
end;


Function SCInvalid(L:TLevel;SC:Integer):Boolean;
begin
 Result:=(SC<-1) or (SC>=L.Sectors.Count);
end;

Function WLInvalid(L:TLevel;SC,WL:Integer):Boolean;
begin
 Result:=True;
 If SCInvalid(L,SC) then exit;
 if (SC<>-1) and (WL=-1) then exit;
 if SC=-1 then begin Result:=false; exit; end;
 Result:=(WL<-1) or (WL>=L.Sectors[SC].Walls.Count);
end;

Procedure ClearVertexMarks(L:TLevel);
var i,j:integer;
begin
 With L do
  For i:=0 to sectors.count-1 do
   with sectors[i] do
    for j:=0 to Vertices.count-1 do vertices[j].mark:=0;
end;

Procedure MarkAdjoins(L:TLevel;sc,wl:integer);
var TheWall,TheWall2:TWall;
    TheSector,TheSector2:TSector;
    TheAdjoin:TSector;
    TheMirror:TWall;


Procedure MarkAdjoinedWall(s,w:integer);
var oSC,oWL:Integer;
begin
 With L.Sectors[s] do
 With Walls[w] do
 begin
  {Check if adjoin is valid}
  if (Adjoin=sc) and (mirror=wl) then begin oSC:=Dadjoin; oWL:=DMirror; end
  else if (DAdjoin=sc) and (DMirror=wl) then begin oSC:=Adjoin; oWL:=Mirror; end
  else exit;

  if Not (TheSector.Vertices[TheWall.V1].IsSameXZ(Vertices[V2]) and
          TheSector.Vertices[TheWall.V2].IsSameXZ(Vertices[V1])) then exit;
  Vertices[V1].Mark:=1;
  Vertices[V2].Mark:=1;
  if oSC=-1 then exit;
  TheSector2:=L.Sectors[oSC];
  TheWall2:=TheSector.Walls[oWL];
  TheSector2.Vertices[TheWall2.V1].Mark:=1;
  TheSector2.Vertices[TheWall2.V2].Mark:=1;
 end;
end;

begin
Try
 TheSector:=L.Sectors[sc];
 TheWall:=TheSector.Walls[wl];

 if TheWall.Adjoin<>-1 then MarkAdjoinedWall(TheWall.Adjoin,TheWall.Mirror);
 if TheWall.DAdjoin<>-1 then MarkAdjoinedWall(TheWall.DAdjoin,TheWall.DMirror);
except
 on E:ElistError do PanMessage(mt_Warning,E.Message);
end;
end;

Procedure MarkSectors(L:TLevel;sel:TMultiSelection);
var s,m,v,w:Integer;
    TheSector:TSector;
begin
 For m:=0 to Sel.Count-1 do
 With L.Sectors[sel.GetSector(m)] do
 begin
  s:=Sel.GetSector(m);
 {Mark Sector's vertices}
  For v:=0 to Vertices.Count-1 do
   Vertices[v].Mark:=1;

(*   if VAdjoin<>-1 then
   begin
    TheSector:=L.Sectors[VAdjoin];
    For v:=0 to TheSector.Vertices.Count-1 do
     TheSector.Vertices[v].Mark:=1;
    For w:=0 to TheSector.Walls.Count-1 do
     MarkAdjoins(L,VAdjoin,w);
   end; *)
   {Mark wall's adjoin}
    For w:=0 to Walls.Count-1 do MarkAdjoins(L,s,w);
 end;
end;

Procedure MarkWalls(L:TLevel;sel:TMultiSelection);
var m,s,w:Integer;
    TheSector:TSector;
    TheWall:TWall;
begin
 for m:=0 to Sel.Count-1 do
 begin
  s:=Sel.GetSector(m);
  w:=Sel.GetWall(m);
  With L.Sectors[s] do
  With Walls[w] do
  begin
   {Mark Wall's vertices}
   Vertices[V1].Mark:=1;
   Vertices[V2].Mark:=1;
   {Mark Adjoins}
   MarkAdjoins(L,s,w);
  end;
 end;
end;

Procedure MarkVertices(L:TLevel;sel:TMultiSelection);
var m:Integer;
begin
 For m:=0 to Sel.Count-1 do
  L.Sectors[Sel.GetSector(m)].Vertices[Sel.GetVertex(m)].Mark:=1;
end;

Procedure TranslateGeometry(L:TLevel;DX,DZ:Double);
var i,j:Integer;
begin
 {process the marked VXs}
 for i := 0 to L.Sectors.Count - 1 do
 With L.Sectors[i] do
 for j := 0 to Vertices.Count - 1 do
 With Vertices[j] do
 begin
  if mark=0 then continue;
  X:=X+DX;
  Z:=Z+DZ;
 end;
end;


Procedure TranslateSectorSelection(L:TLevel;sel:TMultiSelection;x,z:Double);
begin
 ClearVertexMarks(l);
 MarkSectors(L,Sel);
 TranslateGeometry(L,X,Z);
end;

Procedure TranslateWallSelection(L:TLevel;sel:TMultiSelection;x,z:Double);
var m,i,j:Integer;
    TheWall, TheWall2:TWall;
    TheSector2:TSector;
    TheVertex:TVertex;
begin
 ClearVertexMarks(L);
 MarkWalls(L,Sel);
 TranslateGeometry(L,x,z);
end;



Procedure TranslateVertexSelection(L:TLevel;sel:TMultiSelection;x,z:Double);
var m:Integer;
    TheVertex:TVertex;
begin
{ ClearVertexMarks(l);
 MarkVertices(L,Sel);}
 for m := 0 to Sel.Count - 1 do
 With l.Sectors[sel.GetSector(m)] do
 begin
  TheVertex := Vertices[Sel.GetVertex(m)];
  TheVertex.X := TheVertex.X + x;
  TheVertex.Z := TheVertex.Z + z;
 end;
end;

Procedure TranslateObjectSelection(L:TLevel;sel:TMultiSelection;dx,dz:Double);
var m:Integer;
begin
 for m := 0 to Sel.Count - 1 do
 With l.Objects[Sel.GetObject(m)] do
 begin
  X:=X+dx;
  Z:=Z+dz;
 end;
end;

Procedure DeleteSector(L:TLevel;sc:Integer);
var i,j,k     : Integer;
    TheSector : TSector;
    TheWall   : TWall;
    TheObject : TOB;

Procedure  AdjustSCRef(Var oldSC:Integer);
begin
 if oldSC>sc then Dec(OldSC)
 else if oldSC=sc then OldSC:=-1;
end;

begin
  {Update all the adjoins > to the sector}
  {Delete the adjoins     = to the sector}
  for i := 0 to l.Sectors.Count - 1 do
  if i <> sc then
  With l.Sectors[i] do
   begin
    AdjustSCRef(VAdjoin);
    AdjustScRef(FloorSlope.Sector);
    AdjustScRef(CeilingSlope.Sector);
    for j := 0 to Walls.Count - 1 do
     begin
      TheWall := Walls[j];
      AdjustSCRef(TheWall.Adjoin);
      if TheWall.Adjoin = -1 then TheWall.Mirror := -1;
      AdjustSCRef(TheWall.DAdjoin);
      if TheWall.DAdjoin = -1 then TheWall.DMirror := -1;
     end; {walls}
   end; {sectors}

  {Correct corresponding objects references}
  for i := 0 to l.Objects.Count - 1 do
   AdjustScRef(l.Objects[i].Sector);

  {Delete the entry in MAP_SEC}
  L.Sectors[sc].Free;
  l.Sectors.Delete(sc);
end;

{Service function: Removes the vertex, adjusts references, change all
 references to this vertex to ChangetoVX}
Procedure RemoveVertex(Sec:TSector;vx:integer;ChangetoVX:Integer);
var i:Integer;
begin

For i:=0 to Sec.Walls.Count-1 do
 With Sec.Walls[i] do
 begin
  IF V1=vx then V1:=ChangeToVX;
  IF V2=vx then V2:=ChangeToVX;
 end;

 For i:=0 to Sec.Walls.Count-1 do
 With Sec.Walls[i] do
 begin
   if V1>vx then Dec(V1);
   if V2>vx then Dec(V2);
 end;
 Sec.Vertices.Delete(vx);
end;

{Service function: Removes the wall, adjusts references}
Procedure RemoveWall(L:TLevel;sc,wl:integer);
var i,j:Integer;
    TheSector:TSector;

Procedure AdjustWLRef(Var oldSC,oldWl:Integer);
begin
 if oldSC<>sc then exit;
 if oldWL>WL then Dec(oldWL)
 else if oldWL=WL then begin OldWL:=-1; OldSC:=-1; end;
end;

begin
  For i:=0 to l.sectors.count-1 do
  With l.Sectors[i] do
   begin
    AdjustWLRef(FloorSlope.Sector,FloorSlope.Wall);
    AdjustWLRef(CeilingSlope.Sector,CeilingSlope.Wall);
    for j:=0 to Walls.count-1 do
    With Walls[j] do
    begin
     AdjustWLRef(Adjoin,Mirror);
     AdjustWLRef(DAdjoin,DMirror);
    end;
   end;
 L.Sectors[sc].Walls.Delete(wl);
end;

Procedure DeleteIfEmpty(L:TLevel;Sec:TSector;sc:Integer);
begin
 if (Sec.Walls.Count=0) or (Sec.Vertices.Count=0) then DeleteSector(L,sc);
end;

Procedure DeleteVertex(L:TLevel;sc,vx:Integer);
var  TheSector:TSector;
     nDelWall:Integer; {Number of wall to be deleted}
     i,j:Integer;
     MoveToVX:Integer; {number of vertex that will replace the deleted one}
begin
TheSector:=l.Sectors[sc];
 With TheSector do
 begin
  NDelWall:=-1;
  MoveToVX:=-1;

  {Find a wall that starts at this vertex. It will be deleted}
  For i:=0 to Walls.Count-1 do {Look for wall that starts at this vertex}
   if Walls[i].V1=vx then begin nDelWall:=i; MoveToVX:=Walls[i].V2; break; end;

  {If no wall starts at this vertex, then wall ending at this vertex will be deleted}
  if nDelWall=-1 then
  For i:=0 to Walls.Count-1 do {Look for wall that ends at this vertex}
   if Walls[i].V2=vx then begin nDelWall:=i; MoveToVX:=Walls[i].V1; break; end;
 end;

   {Just in case, if vertex to change
   references to is to be deleted - i.e. bad wall}
   if VX=MoveToVX then MoveToVX:=0;

  {Delete Vertex and wall}
  RemoveVertex(TheSector,vx,MoveToVX);
  if NDelWall<>-1 then RemoveWall(L,Sc,nDelWall);
  DeleteIfEmpty(L,TheSector,Sc);
end;

Procedure DeleteWall(L:TLevel;sc,wl:Integer);
var TheWall:TWall;
    TheSector:TSector;
    i,j:Integer;
    V1InValid,V2InValid:boolean;
begin
 TheSector:=L.Sectors[sc];
 TheWall:=TheSector.Walls[wl];

{Find how many walls use each vertex}

For i:=0 to TheSector.Vertices.count-1 do
 TheSector.Vertices[i].Mark:=0;

For i:=0 to TheSector.Walls.Count-1 do
With TheSector.Walls[i] do
begin
 if TheSector.IsVXValid(V1) then Inc(TheSector.Vertices[V1].Mark);
 if TheSector.IsVXValid(V2) then Inc(TheSector.Vertices[V2].Mark);
end;

V1InValid:=not TheSector.IsVXValid(TheWall.V1);
V2InValid:=not TheSector.IsVXValid(TheWall.V2);

if V1InValid and V2InValid then begin RemoveWall(L,sc,wl); DeleteifEmpty(L,TheSector,sc); exit; end;

if V1InValid or V2InValid then
begin
 if V1InValid then i:=TheWall.V2 else i:=TheWall.V1;
 if TheSector.Vertices[i].Mark<=1 then RemoveVertex(TheSector,i,0);
 RemoveWall(L,sc,wl);
 DeleteIfEmpty(L,TheSector,sc);
 exit;
end;

if TheWall.V1=TheWall.V2 then
begin
 if TheSector.Vertices[TheWall.V1].Mark<=2 then RemoveVertex(TheSector,TheWall.V1,0);
 RemoveWall(L,sc,wl);
 DeleteIfEmpty(L,TheSector,sc);
 exit;
end;

RemoveVertex(TheSector,TheWall.V1,TheWall.V2);
RemoveWall(L,sc,wl);
DeleteIfEmpty(L,TheSector,Sc);
end;

Procedure DeleteOB(L:TLevel;ob:Integer);
begin
 l.Objects[ob].Free;
 l.Objects.Delete(ob);
end;


function MakeAdjoin(L:Tlevel; sc, wl : Integer) : Integer;
begin
 Result:=MakeAdjoinFromSCUp(L,sc,wl,0);
end;

function MakeAdjoinFromSCUp(L:Tlevel; sc, wl : Integer;firstSC:Integer) : Integer;
var s,w        : Integer;
    TheSector1 : TSector;
    TheSector2 : TSector;
    TheWall1   : TWall;
    TheWall2   : TWall;
    LVertex1   : TVertex;
    RVertex1   : TVertex;
    LVertex2   : TVertex;
    RVertex2   : TVertex;
    pSec1,PSec2,pWl1,PWl2:^Integer;

Procedure ArrangeDAdjoin(wall:TWall); {arranges adjoins so that Adjoin
                                      is a higher sector, DAdjoin - lower}

Var Sec1,Sec2:TSector;
    Adj,mir:Integer;
begin
 If (Wall.Adjoin<0) or (Wall.Adjoin>=l.Sectors.count) then
 begin
  PanMessage(mt_Warning,Format('Incorrect adjoin: wall id: %x',[Wall.HexID]));
  exit;
 end;

 If (Wall.DAdjoin<0) or (Wall.DAdjoin>=l.Sectors.count) then
 begin
  PanMessage(mt_Warning,Format('Incorrect second adjoin: wall id: %x',[Wall.HexID]));
  exit;
 end;

 Sec1:=l.Sectors[Wall.Adjoin];
 Sec2:=l.Sectors[Wall.Dadjoin];
 if Sec1.Floor_Y<Sec2.Floor_Y then {exchange adjoins}
 begin
  adj:=Wall.Adjoin;
  mir:=Wall.Mirror;
  Wall.Adjoin:=Wall.DAdjoin;
  Wall.Mirror:=Wall.DMirror;
  Wall.Dadjoin:=adj;
  Wall.DMirror:=mir;
 end;
end;

begin
  Result := 0;
  TheSector1 := l.Sectors[sc];
  TheWall1   := TheSector1.Walls[wl];
  if (TheWall1.Adjoin<>-1) and (TheWall1.Dadjoin<>-1) then exit;

  LVertex1 := TheSector1.Vertices[TheWall1.V1];
  RVertex1 := TheSector1.Vertices[TheWall1.V2];

  for s := FirstSC to l.Sectors.Count - 1 do
   begin
    TheSector2 := l.Sectors[s];
    for w := 0 to TheSector2.Walls.Count - 1 do
     begin
      TheWall2 := TheSector2.Walls[w];

      With TheWall2 do
      if ((Adjoin=sc) and (Mirror=wl)) or
         ((DAdjoin=sc) and (DMirror=wl)) or
         ((Adjoin<>-1) and (DAdjoin<>-1)) then continue;

      LVertex2 := TheSector2.Vertices[TheWall2.V1];
      RVertex2 := TheSector2.Vertices[TheWall2.V2];

      {if found do the adjoin and prepare to break out of both loops}
      if ((LVertex1.X = RVertex2.X) and (LVertex1.Z = RVertex2.Z)) and
         ((RVertex1.X = LVertex2.X) and (RVertex1.Z = LVertex2.Z)) then
       begin
        if TheWall1.Adjoin=-1 then begin PSec1:=@TheWall1.Adjoin; PWl1:=@TheWall1.Mirror end
        else if TheWall1.DAdjoin=-1 then begin PSec1:=@TheWall1.DAdjoin; PWl1:=@TheWall1.DMirror end
        else break;


        if TheWall2.Adjoin=-1 then begin PSec2:=@TheWall2.Adjoin; PWl2:=@TheWall2.Mirror end
        else if TheWall2.DAdjoin=-1 then begin PSec2:=@TheWall2.DAdjoin; PWl2:=@TheWall2.DMirror end;


         PSec2^ := sc;
         PWl2^ := wl;
         pSec1^ := s;
         pWl1^ := w;
         if (TheWall2.Adjoin<>-1) and (TheWall2.Dadjoin<>-1) then ArrangeDAdjoin(TheWall2);
         Inc(Result);
       end;

     end;
   end;
if (TheWall1.Adjoin<>-1) and (TheWall1.Dadjoin<>-1) then ArrangeDAdjoin(TheWall1);
end;

function UnAdjoin(L:Tlevel; sc, wl : Integer) : Integer;
var
    TheWall   : TWall;
    TheWall2   : TWall;
    TheSector2: TSector;
    BadAdjoin:Boolean;

Function BadRef(ref:Integer;Max:Integer):Boolean;
begin
 result:=(ref<0) or (ref>=Max);
end;

begin
 Result := 0;
 TheWall:=l.Sectors[sc].Walls[wl];

 BadAdjoin:=false;

Repeat
 if TheWall.Adjoin=-1 then break
 else if BadRef(TheWall.Adjoin,l.Sectors.Count) then
 begin BadAdjoin:=true; break; end;

 TheSector2:=l.Sectors[TheWall.Adjoin];
 if BadRef(TheWall.Mirror, TheSector2.walls.count) then
 begin badAdjoin:=true; break; end;

 TheWall2:=TheSector2.Walls[TheWall.Mirror];

 if (TheWall2.Adjoin=sc) and (TheWall2.Mirror=wl) then
 begin
  TheWall2.Adjoin:=-1;
  TheWall2.Mirror:=-1;
 end
 else if (TheWall2.DAdjoin=sc) and (TheWall2.DMirror=wl) then
 begin
  TheWall2.DAdjoin:=-1;
  TheWall2.DMirror:=-1;
 end;

 {Check if Adjoin is removed while Dadjoin remains}
 if (TheWall2.Adjoin=-1) and (TheWall2.Dadjoin<>-1) then
 begin
  TheWall2.Adjoin:=TheWall2.Dadjoin;
  TheWall2.Mirror:=TheWall2.DMirror;
  TheWall2.DAdjoin:=-1;
  TheWall2.Dmirror:=-1;
 end;
Until true; {Dummy cycle, just for break; to work}

if badAdjoin then PanMessage(mt_Warning,Format('Bad adjoin: SC %d WL %d',[sc,wl]));

BadAdjoin:=false;

Repeat
 if TheWall.DAdjoin=-1 then break
 else if BadRef(TheWall.DAdjoin,l.Sectors.Count) then
 begin BadAdjoin:=true; break; end;

 TheSector2:=l.Sectors[TheWall.DAdjoin];
 if BadRef(TheWall.DMirror, TheSector2.walls.count) then
 begin badAdjoin:=true; break; end;

 TheWall2:=TheSector2.Walls[TheWall.DMirror];

 if (TheWall2.Adjoin=sc) and (TheWall2.Mirror=wl) then
 begin
  TheWall2.Adjoin:=-1;
  TheWall2.Mirror:=-1;
 end
 else if (TheWall2.DAdjoin=sc) and (TheWall2.DMirror=wl) then
 begin
  TheWall2.DAdjoin:=-1;
  TheWall2.DMirror:=-1;
 end;
 {Check if Adjoin is removed while Dadjoin remains}
 if (TheWall2.Adjoin=-1) and (TheWall2.Dadjoin<>-1) then
 begin
  TheWall2.Adjoin:=TheWall2.Dadjoin;
  TheWall2.Mirror:=TheWall2.DMirror;
  TheWall2.DAdjoin:=-1;
  TheWall2.Dmirror:=-1;
 end;

Until true; {Dummy cycle, just for "break" to work}

if badAdjoin then PanMessage(mt_Warning,Format('Bad second adjoin: SC %d WL %d',[sc,wl]));

if TheWall.Adjoin<>-1 then
begin
 TheWall.Adjoin:=-1;
 TheWall.Mirror:=-1;
 Inc(Result);
end;

if TheWall.DAdjoin<>-1 then
begin
 TheWall.DAdjoin:=-1;
 TheWall.DMirror:=-1;
 Inc(Result);
end;

end;

Function GetWLLen(L:TLevel;sc, wl:integer):Double;
Var TheWall:TWall;
     vx1,vx2:TVertex;
begin
 With l.Sectors[sc] do
 begin
  TheWall:=Walls[wl];
  vx1:=Vertices[TheWall.V1];
  vx2:=Vertices[TheWall.V2];
  Result:=sqrt(sqr(vx1.X - vx2.X)+sqr(vx1.Z - vx2.Z));
 end;
end;

Function SplitWall(l:TLevel; sc, wl : Integer):Integer; {return the number of a new wall}
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
    walllen     : Double;
    I,j:Integer;

Procedure  AdjustWLRef(Var oldSC,oldWl:Integer);
begin
 if oldSC<>sc then exit;
 if oldWL>Wl then Inc(oldWL);
end;

begin
 Result:=-1;
 TheSector := l.Sectors[sc];
 TheWall   := TheSector.Walls[wl];

 walllen   := GetWLLen(l, sc, wl);

 LVertex           := TheSector.Vertices[TheWall.V1];
 RVertex           := TheSector.Vertices[TheWall.V2];

 NEWVertex         := L.NewVertex;
 NEWVertex.Mark    := 0;
 NEWVertex.X       := (LVertex.X + RVertex.X ) / 2;
 NEWVertex.Z       := (LVertex.Z + RVertex.Z ) / 2;

 NEWWall           := L.NewWall;
 NewWall.Assign(TheWall);

 {preserve texture horiz alignment}
 TheWall.Mid.Offsx    := RoundTo2Dec(TheWall.Mid.Offsx + walllen / 2);
 TheWall.Top.OffsX    := RoundTo2Dec(TheWall.Top.OffsX + walllen / 2);
 TheWall.Bot.OffsX    := RoundTo2Dec(TheWall.Bot.OffsX + walllen / 2);

 newvxpos          := TheWall.V1 + 1;
 NEWWall.V1   := TheWall.V1;
 NEWWall.V2  := newvxpos;

 {Adjusting references in the current sector}
 for w := 0 to TheSector.Walls.Count - 1 do
  begin
   TheWall2 := TheSector.Walls[w];
   if TheWall2.V1 >= newvxpos then Inc(TheWall2.V1);
   if TheWall2.V2 >= newvxpos then Inc(TheWall2.V2);
  end;

TheSector.Vertices.Insert(newvxpos, NEWVertex);
TheWall.V1   := newvxpos;

TheSector.Walls.Insert(wl, NEWWall);
Result:=Wl+1;

{Adjusting wall references}
 for i:=0 to l.Sectors.count-1 do
 With l.Sectors[i] do
 begin
  AdjustWLRef(FloorSlope.Sector,FloorSlope.Wall);
  AdjustWLRef(CeilingSlope.Sector,CeilingSlope.Wall);
  for j:=0 to Walls.count-1 do
  With Walls[j] do
  begin
   AdjustWLRef(Adjoin,Mirror);
   AdjustWLRef(DAdjoin,DMirror);
  end;
 end;


 {update the mirrors of the adjoins for the complete sector (easier)}
{ for w := 0 to TheSector.Walls.Count - 1 do
  begin
   TheWall := TheSector.Walls[w];
   if TheWall.Adjoin <> -1 then
    begin
     TheSector2 := l.Sectors[TheWall.Adjoin];
     TheWall2   := TheSector2.Walls[TheWall.Mirror];
     TheWall2.Mirror := w;
    end;

   if TheWall.DAdjoin <> -1 then
    begin
     TheSector2 := l.Sectors[TheWall.DAdjoin];
     TheWall2   := TheSector2.Walls[TheWall.DMirror];
     TheWall2.DMirror := w;
    end;
  end;}
end;

function  GetWLfromV1(l:TLevel;sector, V1 : Integer) : Integer;
var TheWall   : TWall;
    w         : Integer;
    TheSector : TSector;
begin
 Result := -1;
 TheSector := l.Sectors[sector];
 for w := 0 to TheSector.Walls.Count - 1 do
  begin
   TheWall := TheSector.Walls[w];
   if TheWall.V1 = V1 then begin Result := w; break; end;
  end;
end;

function  GetWLfromV2(l:TLevel;sector, V2 : Integer) : Integer;
var TheWall   : TWall;
    w         : Integer;
    TheSector : TSector;
begin
 Result := -1;
 TheSector := l.Sectors[sector];
 for w := 0 to TheSector.Walls.Count - 1 do
  begin
   TheWall := TheSector.Walls[w];
   if TheWall.V2 = V2 then begin Result := w; break; end;
  end;
end;

Function GeneratePolygon(x,z,radius:Double;sides:Integer;clockwise:boolean):TVertices;
var TheVertex:TVertex;
    alpha,delta:double;
    i:Integer;
begin
 Result:=TVertices.Create;
 if sides=4 then alpha := Pi/4 else Alpha:=0;
delta := 2 * Pi / Sides;
if clockwise then delta:=-delta;
for i := 0 to Sides - 1 do
 begin
  TheVertex      := TVertex.Create;
  TheVertex.X    := RoundTo2Dec(X + Radius * cos(alpha));
  TheVertex.Z    := RoundTo2Dec(Z + Radius * sin(alpha));
  alpha          := alpha + delta;
  Result.Add(TheVertex);
 end;

end;

Function CreatePolygonSector(l:TLevel;x,z,radius:Double;sides,likeSC,likeWL:Integer):Integer;
var 
    i:Integer;
    TheSector:TSector;
    Wall:TWall;
    RefWall:TWall;
    nWalls:Integer;
    vxs:Tvertices;
begin
 TheSector:=l.NewSector;
 Result:=l.Sectors.Add(TheSector);
 
 RefWall:=nil;
 if LikeSC<>-1 then
 begin
  TheSector.Assign(l.Sectors[likeSC]);
  RefWall:=l.Sectors[LikeSC].Walls[LikeWL];
 end;
 vxs:=GeneratePolygon(x,z,radius,sides,true);

 nWalls:=vxs.Count;

for i:=0 to nWalls-1 do
begin
 TheSector.Vertices.Add(vxs[i]);
 Wall:=l.NewWall;
 if RefWall<>nil then Wall.Assign(RefWall);
 Wall.V1:=i;
 if i=nwalls-1 then  Wall.V2:=0 else Wall.V2:=i+1;
 TheSector.Walls.Add(Wall);
end;
 vxs.Free;
end;

Procedure CreatePolygonGap(l:TLevel;sc:Integer;x,z,radius:Double;sides,likeSC,likeWL:Integer);
var
   vxs:TVertices;
    i:Integer;
    TheSector:TSector;
    Wall:TWall;
    RefWall:TWall;
    nNewWalls,NOldWalls:Integer;
    nOldVXs:Integer;
begin
 vxs:=GeneratePolygon(x,z,radius,sides,false);
 RefWall:=nil;
 if LikeSC<>-1 then
  RefWall:=l.Sectors[LikeSC].Walls[LikeWL];

TheSector:=l.Sectors[sc];
nOldWalls:=TheSector.Walls.Count;
nOldVXs:=TheSector.Vertices.Count;
nNewWalls:=vxs.Count;

for i:=0 to nNewWalls-1 do
begin
 TheSector.Vertices.Add(vxs[i]);
 Wall:=L.NewWall;
 if RefWall<>nil then Wall.Assign(RefWall);
 Wall.V1:=nOldVXs+i;
 if i=nNewWalls-1 then Wall.V2:=nOldVXs else Wall.V2:=nOldVXs+i+1;
 TheSector.Walls.Add(Wall);
end;
vxs.Free;
end;

Procedure TranslateSector(L:TLevel;sc:Integer;x,z:double);
var sel:TMultiSelection;
begin
 sel:=TMultiSelection.Create;
 Sel.AddSector(sc);
 TranslateSectorSelection(L,sel,x,z);
 Sel.Free;
end;

Procedure TranslateWall(L:TLevel;sc,wl:Integer;x,z:double);
var sel:TMultiSelection;
begin
 sel:=TMultiSelection.Create;
 Sel.AddWall(sc,wl);
 TranslateWallSelection(L,sel,x,z);
 Sel.Free;
end;

Procedure TranslateVertex(L:TLevel;sc,vx:Integer;x,z:double);
var sel:TMultiSelection;
begin
 sel:=TMultiSelection.Create;
 Sel.AddVertex(sc,vx);
 TranslateVertexSelection(L,sel,x,z);
 Sel.Free;
end;

Procedure TranslateObject(L:TLevel;ob:Integer;x,z:double);
var sel:TMultiSelection;
begin
 sel:=TMultiSelection.Create;
 Sel.AddObject(ob);
 TranslateObjectSelection(L,sel,x,z);
 Sel.Free;
end;

Procedure ExtrudeWall(L:TLevel;sc,wl:Integer;ExtrudeBy:Double);
var w          : Integer;
    TheSector  : TSector;
    TheSector2 : TSector;
    TheWall    : TWall;
    TheWall2   : TWall;
    TheVertex2 : TVertex;
    LVertex,
    RVertex    : TVertex;
    deltax,
    deltaz     : Double;
    NewSector  : Integer;
begin

 TheSector:=L.Sectors[sc];
 TheWall:=TheSector.Walls[wl];
 { prepare the coordinates of the new vertices }
 LVertex := TheSector.Vertices[TheWall.V1];
 RVertex := TheSector.Vertices[TheWall.V2];

 deltax  := LVertex.X - RVertex.x;
 deltaz  := LVertex.z - RVertex.z;

 { Create and fill the new sector }
 TheSector2 := L.NewSector;
 TheSector2.Assign(TheSector);
 TheSector2.Flags:=TheSector2.Flags and (Not SECFLAG1_DOOR);
 Newsector:=L.Sectors.Add(TheSector2);
 {VX 0}
 TheVertex2 := l.NewVertex;
 TheVertex2.X := RVertex.X;
 TheVertex2.Z := RVertex.Z;
 TheSector2.Vertices.Add(TheVertex2);
 {VX 1}
 TheVertex2 := l.NewVertex;
 TheVertex2.X := LVertex.X;
 TheVertex2.Z := LVertex.Z;
 TheSector2.Vertices.Add(TheVertex2);
 {VX 2}
 TheVertex2 := l.NewVertex;
 TheVertex2.X := LVertex.X + ExtrudeBy * deltaz;
 TheVertex2.Z := LVertex.Z - ExtrudeBy * deltax;
 TheSector2.Vertices.Add(TheVertex2);
 {VX 3}
 TheVertex2 := l.NewVertex;
 TheVertex2.X := RVertex.X + ExtrudeBy * deltaz;
 TheVertex2.Z := RVertex.Z - ExtrudeBy * deltax;
 TheSector2.Vertices.Add(TheVertex2);

 for w := 0 to 3 do
  begin
   TheWall2  := l.NewWall;
   TheWall2.Assign(TheWall);
   CASE w OF
    0 : begin
         TheWall2.V1  := 0;
         TheWall2.V2  := 1;
        end;
    1 : begin
         TheWall2.V1  := 1;
         TheWall2.V2  := 2;
        end;
    2 : begin
         TheWall2.V1  := 2;
         TheWall2.V2  := 3;
        end;
    3 : begin
         TheWall2.V1  := 3;
         TheWall2.V2  := 0;
        end;
   END;
   IF w = 0 then
    begin
     TheWall2.Adjoin    := sc;
     TheWall2.Mirror    := wl;
     With TheWall do
     if Adjoin=-1 then begin Adjoin:= newsector; Mirror:=0; end
     else if DAdjoin=-1 then begin DAdjoin:= newsector; DMirror:=0; end;
    end;
   TheSector2.Walls.Add(TheWall2);
  end;
end;

function  GetNearestWL(L:TLevel; Layer:Integer; X, Z : Double; VAR ASector : Integer; VAR AWall : Integer) : Boolean;
var
  TheSector           : TSector;
  TheWall             : TWall;
  LVertex, RVertex    : TVertex;
  s, w, itw              : Integer;
  x1, z1, x2, z2,
  dd                  : Double;
  dmin, cal           : Double;
  xi, zi              : Double;
  Sector              : Integer;
  a2,b2,c2,a,ax,bx,xl:double;
  LastOnLeft:boolean;
Function IsOnTheLeft:boolean;
var   dx,dz,nx1,nz1,nx2,nz2:double;
begin
 dx:=x2-x1;
 dz:=z2-z1;
 nx1:=x1-dz; nz1:=z1+dx;
 nx2:=x1+dz; nz2:=z1-dx;
 nx1:=sqr(nx1-x)+sqr(nz1-z);
 nx2:=sqr(nx2-x)+sqr(nz2-z);
 Result:=nx1>nx2;
end;

begin
 dmin := 9999999.0;
 itw  := -1;
 LastOnLeft:=false;
 With L do
 for s:=0 to Sectors.Count-1 do
  begin
   TheSector := Sectors[S];
   if (Layer=Any_Layer) or (TheSector.Layer=Layer) then
   for w := 0 to TheSector.Walls.Count - 1 do
    begin
     TheWall := TheSector.Walls[w];
     LVertex := TheSector.Vertices[TheWall.V1];
     RVertex := TheSector.Vertices[TheWall.V2];
     x1      := LVertex.X;
     z1      := LVertex.Z;
     x2      := RVertex.X;
     z2      := RVertex.Z;
     Try
     a2:=sqr(x2-x1)+sqr(z2-z1);
     b2:=sqr(x-x1)+sqr(z-z1);
     c2:=sqr(x-x2)+sqr(z-z2);
     a:=sqrt(a2);
     ax:=(b2-c2+a2)/(2*a);
     except
      on E:EMathError do begin PanMessage(mt_warning,e.message); continue; end;
     end;
     if (ax<0) or (ax>a) then continue;
     Try
     xl:=sqrt(b2-sqr(ax));

     if Abs(xl-dmin)<0.001 then
     begin
      if (not lastOnLeft) and IsOnTheLeft then
      begin
       lastOnLeft:=true;
       sector:=s; itw:=w; dmin:=xl;
      end;
      continue;
     end;
     if xl<dmin then
     begin
      lastOnLeft:=IsOnTheLeft;
      sector:=s; itw:=w; dmin:=xl; continue;
     end;
    {if xl is very close, check if this one has selection point on the right}

     except
      on E:EMathError do begin PanMessage(mt_warning,e.message); continue; end;
     end;

    end;
  end;
  if itw=-1 then Result:=false else
  begin
   ASector      := Sector;
   AWall        := itw;
   GetNearestWL := TRUE;
 end;
end;

function  GetNearestSC(L:TLevel; Layer:Integer; X, Z : Double; VAR ASector : Integer) : Boolean;
var NewSc:Integer;
begin
 NewSC:=-1;
 Result:=GetNextNearestSC(L,Layer,X,Z,NewSC);
 if Result then ASector:=NewSC;
end;

function  GetNextNearestSC(L:TLevel; Layer:Integer; X, Z : Double; VAR ASector : Integer) : Boolean;
var
  TheSector           : TSector;
  TheSector2          : TSector;
  TheWall             : TWall;
  LVertex, RVertex    : TVertex;
  s, w, its, itw      : Integer;
  x1, z1, x2, z2,
  dd, a1, b1, a2, b2  : Double;
  dmin, cal           : Double;
  xx, xi, zi          : Double;
  ox, oz,
  deltax, deltaz,
  dx, dz, gx, gz      : Double;
  dist_d, dist_g      : Double;
begin
 dmin := 999999.0;
 its  := -1;
 With L do
 for s := 0 to Sectors.Count - 1 do
  begin
   TheSector := Sectors[s];
   if (Layer=Any_Layer) or (TheSector.Layer = LAYER) and
      (s<>ASector) then
    begin
     for w := 0 to TheSector.Walls.Count - 1 do
      begin
       TheWall := TheSector.Walls[w];
       LVertex := TheSector.Vertices[TheWall.V1];
       RVertex := TheSector.Vertices[TheWall.V2];
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
              if dist_d < dist_g then
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
   GetNextNearestSC := TRUE;
  end
 else
  begin
   GetNextNearestSC := FALSE;
  end;
end;


function  GetNearestVX(L:TLevel; Layer:Integer; X, Z : Double; VAR ASector : Integer; VAR AVertex : Integer) : Boolean;
var
  TheSector           : TSector;
  TheVertex           : TVertex;
  s, v, its, itv      : Integer;
  cal, dmin           : Double;
begin
 dmin := 99999;
 its  := -1;
 With L do
 for s := 0 to Sectors.Count - 1 do
  begin
   TheSector := Sectors[s];
   if (Layer=Any_Layer) or (TheSector.Layer = LAYER) then
    begin
     for v := 0 to TheSector.Vertices.Count - 1 do
      begin
       TheVertex := TheSector.Vertices[v];
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

function  GetNearestOB(L:TLevel; Layer:Integer; X, Z : Double; VAR AObject : Integer) : Boolean;
var
  TheObject           : TOB;
  TheSector           : TSector;
  TheLayer            : Integer;
  o, ito              : Integer;
  cal, dmin           : Double;
begin
 dmin := 99999;
 ito  := -1;
 With L do
 for o := 0 to Objects.Count - 1 do
  begin
   TheObject := Objects[o];
   {if not DifficultyOk(TheObject) then continue;}
   if TheObject.Sector <> -1 then
    begin
     TheSector := Sectors[TheObject.Sector];
     TheLayer  := TheSector.Layer;
    end
   else
    TheLayer := 9999;
   if (Layer=Any_Layer) or (TheLayer = LAYER) or (TheLayer = 9999) then
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

function  GetNextNearestVX(L:TLevel; Layer:Integer; X, Z : Double; VAR ASector : Integer; VAR AVertex : Integer) : Boolean;
var
  TheSector           : TSector;
  TheVertex           : TVertex;
  s, v, its, itv      : Integer;
  cal, dmin           : Double;
begin
 dmin := 99999;
 its  := -1;
 With L do
 for s := 0 to Sectors.Count - 1 do
  begin
   TheSector := Sectors[s];
   if (Layer=Any_Layer) or (TheSector.Layer = LAYER) then
    begin
     for v := 0 to TheSector.Vertices.Count - 1 do
      begin
       TheVertex := TheSector.Vertices[v];
       cal       := (TheVertex.X - X) * (TheVertex.X - X)
                  + (TheVertex.Z - Z) * (TheVertex.Z - Z);
       if cal < dmin then
        begin
         if (s <> ASector) or (v <> AVertex) then
         dmin := cal;
         its  := s;
         itv  := v;
        end;
      end;
    end;
  end;
  if its<>-1 then begin Asector:=its; Avertex:=itv; Result:=true; end
  else Result:=false;
end;

Function GetHeightAt(L:TLevel;sc:integer;x,z:double;fc:integer):double;
var sec:TSector;
Function CalcDY(const slope:TSlope;x,z:double):Double;
var wlx,objx:double;
    wl:TWall;
    slSC:TSector;
    slWL:Twall;
    dxz,dzx:double;
    vx1,vx2:TVertex;
    pz,px:Double;
    dist:Double;
begin
 slSC:=L.Sectors[Slope.Sector];
 slWL:=slSC.Walls[Slope.wall];
 vx1:=slSC.Vertices[slWL.V1];
 vx2:=slSC.Vertices[slWL.V2];

 if vx1.x=vx2.x then {vertical}
 begin
  px:=vx1.x;
  pz:=z;
 end
 else
 if vx1.z=vx2.z then {horizontal}
 begin
  px:=x;
  pz:=vx1.z;
 end
 else {not vertical and not horizontal}
 begin
  dxz:=(vx1.x-vx2.x)/(vx1.z-vx2.z);
  dzx:=(vx1.z-vx2.z)/(vx1.x-vx2.x);
  pz:=(vx1.z*dxz-vx1.x+dzx*z+x)/(dxz+dzx);
  px:=dxz*(pz-vx1.z)+vx1.x;
 end;
  {Find the Y}
 dist:=sqrt(sqr(px-x)+sqr(pz-z));
 Result:=Tan(Slope.angle/8192)*dist;
end;

var dy:Double;
    flry:double;
    ceilY:double;

begin {GetHeightAt}
Sec:=L.Sectors[sc];
case fc of
 0:
begin
 if Sec.IsFlagSet(SECFLAG1_SLOPEDFLOOR) then
  begin
  if l.IsSCValid(Sec.FloorSlope.Sector) then
  if L.Sectors[Sec.FloorSlope.Sector].IsWLValid(Sec.FloorSlope.Wall) then
   begin
    Flry:=L.Sectors[Sec.FloorSlope.Sector].Floor_Y+CalcDY(Sec.FloorSlope,x,z);
    Result:=flry;
    exit;
   end;
   PanMessage(mt_Warning,Format('Bad floor slope: sc ID: %x',[Sec.HexID]));
  end;
 Result:=Sec.Floor_Y;
end;

 1:
 begin
 if Sec.IsFlagSet(SECFLAG1_SLOPEDCEILING) then
 begin
  if l.IsSCValid(Sec.CeilingSlope.Sector) then
   if L.Sectors[Sec.CeilingSlope.Sector].IsWLValid(Sec.CeilingSlope.Wall) then
   begin
    CeilY:=L.Sectors[Sec.FloorSlope.Sector].Ceiling_Y+CalcDY(Sec.CeilingSlope,x,z);
    Result:=Ceily;
    exit;
   end;
  PanMessage(mt_Warning,Format('Bad ceiling slope: sc ID: %x',[Sec.HexID]));
 end;
 Result:=Sec.Ceiling_Y;
end;
end;
end;

Function GetFloorAt(L:TLevel;sc:integer;x,z:double):double;
begin
 Result:=GetHeightAt(L,sc,x,z,0);
end;

Function GetCeilingAt(L:TLevel;sc:integer;x,z:double):double;
begin
 Result:=GetHeightAt(L,sc,x,z,1);
end;

function  GetObjectSC(L:TLevel;Layer:Integer; obnum: Integer; VAR ASector : Integer) : Boolean;
var sc     : Integer;
    TheObject : TOB;
    TheSector : TSector;

begin {getObjectSC}
  TheObject := L.Objects[obnum];
  Result     := FALSE;
  For sc:=0 to L.Sectors.count-1 do
  begin
  TheSector := l.Sectors[sc];
  if (Layer<>Any_Layer) and (TheSector.Layer<>Layer) then continue;
  if IsInSector(TheSector, TheObject.X, TheObject.Z) then
  begin
   if (GetFloorAt(L,sc,TheObject.X,TheObject.Z)<=TheObject.Y) and
      (GetCeilingAt(L,sc,TheObject.X,TheObject.Z)>=TheObject.Y) then
   begin
    ASector := sc;
    Result:=true;
    Exit;
   end;
  end;
 end;
end;

function  PutOnCeiling(L:TLevel;Layer:Integer; obnum: Integer) : Boolean;
var sc, insc  : Integer;
    TheObject : TOB;
    TheSector : TSector;
    MinFDist:double;

begin {PutOnFloor}
 inSc:=-1;
  TheObject := L.Objects[obnum];
  Result     := FALSE;
  For sc:=0 to L.Sectors.count-1 do
  begin
  TheSector := l.Sectors[sc];
  if (Layer<>Any_Layer) and (TheSector.Layer<>Layer) then continue;
  if IsInSector(TheSector, TheObject.X, TheObject.Z) then
  begin
   if inSc=-1 then
   begin
    MinFDist:=Abs(GetCeilingAt(L,sc,TheObject.X,TheObject.Z)-TheObject.Y);
    InSc:=sc;
    Continue;
   end;
   if Abs(GetCeilingAt(L,sc,TheObject.X,TheObject.Z)-TheObject.Y)<MinFDist then
   begin
    MinFDist:=Abs(GetCeilingAt(L,sc,TheObject.X,TheObject.Z)-TheObject.Y);
    inSC:=sc;
   end;
  end;
 end;

 if InSc<>-1 then
 begin
  MinFDist:=GetCeilingAt(L,InSc,TheObject.X,TheObject.Z);
  TheObject.Y:=RoundTo2Dec(MinFDist);
  if TheObject.Y>MinFDist then TheObject.Y:=TheObject.Y-0.01;
  TheObject.Sector:=inSc;
  Result:=true;
 end
 else
 begin
  TheObject.Sector:=-1;
  Result:=false;
 end;
end;

function  PutOnFloor(L:TLevel;Layer:Integer; obnum: Integer) : Boolean;
var sc, insc  : Integer;
    TheObject : TOB;
    TheSector : TSector;
    MinFDist:double;

begin {PutOnFloor}
 inSc:=-1;
  TheObject := L.Objects[obnum];
  Result     := FALSE;
  For sc:=0 to L.Sectors.count-1 do
  begin
  TheSector := l.Sectors[sc];
  if (Layer<>Any_Layer) and (TheSector.Layer<>Layer) then continue;
  if IsInSector(TheSector, TheObject.X, TheObject.Z) then
  begin
   if inSc=-1 then
   begin
    MinFDist:=Abs(GetFloorAt(L,sc,TheObject.X,TheObject.Z)-TheObject.Y);
    InSc:=sc;
    Continue;
   end;
   if Abs(GetFloorAt(L,sc,TheObject.X,TheObject.Z)-TheObject.Y)<MinFDist then
   begin
    MinFDist:=Abs(GetFloorAt(L,sc,TheObject.X,TheObject.Z)-TheObject.Y);
    inSC:=sc;
   end;
  end;
 end;

 if InSc<>-1 then
 begin
  MinFDist:=GetFloorAt(L,InSc,TheObject.X,TheObject.Z);
  TheObject.Y:=RoundTo2Dec(MinFDist);
  if TheObject.Y<MinFDist then TheObject.Y:=TheObject.Y+0.01;
  TheObject.Sector:=inSc;
  Result:=true;
 end
 else
 begin
  TheObject.Sector:=-1;
  Result:=false;
 end;
end;


Procedure ApplyFixUp(L:TLevel;const Name:String);
var t:TTextFile; s,w1,w2:String;
    p:Integer;
    TheWall:TWall;
    TheSector:TSector;

Procedure ReadFmt(const Fmt:String;args:array of pointer);
begin
 t.Readln(s);
 SScanf(s,fmt,args);
end;

Procedure LoadWall;
Var ID,N:Longint;
begin
 ReadFmt('SECTOR_TAG: %x',[@ID]);
 N:=L.GetSectorByID(ID);
 if N=-1 then
 begin
  PanMessage(mt_Warning,Format('Couldn''t find sector with ID %x',[ID]));
  exit;
 end;
 TheSector:=l.Sectors[N];
 ReadFmt('WALL_TAG: %x',[@ID]);
 N:=TheSector.GetWallByID(ID);
 TheWall:=TheSector.Walls[n];
 if N=-1 then
 begin
  PanMessage(mt_Warning,Format('Couldn''t find wall with ID %x',[ID]));
  exit;
 end;
With TheWall do
begin
 ReadFmt('UPPER_TEXTURE: %s %f %f',[@TOP.Name,@TOP.OffsX,@TOP.OffsY]);
 ReadFmt('MIDDLE_TEXTURE: %s %f %f',[@MID.Name,@MID.OffsX,@MID.OffsY]);
 ReadFmt('LOWER_TEXTURE: %s %f %f',[@BOT.Name,@BOT.OffsX,@BOT.OffsY]);
 ReadFmt('OVERLAY_TEXTURE: %s %f %f',[@Overlay.Name,@Overlay.OffsX,@Overlay.OffsY]);
 TOP.OffsX:=Top.OffsX/8;
 TOP.OffsY:=Top.OffsY/8;
 BOT.OffsX:=BOT.OffsX/8;
 BOT.OffsY:=BOT.OffsY/8;
 MID.OffsX:=MID.OffsX/8;
 MID.OffsY:=MID.OffsY/8;
 Overlay.OffsX:=Overlay.OffsX/8;
 Overlay.OffsY:=Overlay.OffsY/8;
 if Overlay.Name='-' then Overlay.Name:='';
 ReadFmt('FLAG_1: %x',[@flags]);
end;
end;

Procedure LoadSector;
Var ID,WId,N:Longint;

Procedure SetWall(ScID,WlID:Longint;var Sc,Wl:Integer);
var nSc,nWl:integer;
begin
 if ScID=0 then exit;
 nSc:=L.GetSectorByID(ScID);
 if nSc=-1 then
 begin
  PanMessage(mt_warning,Format('Couldn''t find sector with ID: %x',[ScID]));
  exit;
 end;
 nWl:=L.Sectors[nSc].GetWallByID(WlID);
 if nWl=-1 then
 begin
  PanMessage(mt_warning,Format('Couldn''t find wall with ID: SC %x WL %x',[ScID,WlID]));
  exit;
 end;
 Sc:=nSc;
 Wl:=nWl;
end;

begin
 ReadFmt('TAG: %x',[@ID]);
 N:=L.GetSectorByID(ID);
 if N=-1 then
 begin
  PanMessage(mt_Warning,Format('Couldn''t find sector with ID %x',[ID]));
  exit;
 end;
 TheSector:=l.Sectors[n];
With TheSector do
begin
 ReadFmt('LIGHT: %b',[@Ambient]);
 ReadFmt('FLAG_1: %x',[@Flags]);
 ReadFmt('FLAG_2: %x',[@ID]);
 ReadFmt('FLAG_3: %x',[@ID]);
 ReadFmt('CEILING: %f %s %f %f %f',
  [@Ceiling_Y,@Ceiling_Texture.Name,@Ceiling_Texture.OffsX,
  @Ceiling_Texture.OffsY,@Ceiling_extra]);
 ReadFmt('OVERLAY: %s %f %f',[@C_Overlay_texture.Name,@C_Overlay_Texture.OffsX,
 @C_Overlay_Texture.OffsY,@C_OverLay_Extra]);
 if C_Overlay_Texture.Name='-' then C_Overlay_Texture.Name:='';

 ReadFmt('FLOORS: %d',[@ID]);
 ReadFmt('FLOOR: %f %s %f %f %f',
  [@Floor_Y,@Floor_Texture.Name,@Floor_Texture.OffsX,
  @Floor_Texture.OffsY,@Floor_extra]);
 ReadFmt('OVERLAY: %s %f %f',[@F_OverLay_texture.Name,@F_OverLay_Texture.OffsX,
 @F_OverLay_Texture.OffsY,@F_OverLay_Extra]);
 if F_Overlay_Texture.Name='-' then F_Overlay_Texture.Name:='';
 if F_Overlay_Texture.Name='-' then F_Overlay_Texture.Name:='';

 ReadFmt('FLOOR SLOPE: %x %x %f',[@ID,@WID,@FloorSlope.angle]);
 With FloorSlope do SetWall(ID,WID,Sector,Wall);
 ReadFmt('CEILING SLOPE: %x %x %f',[@ID,@WID,@CeilingSlope.angle]);
 With CeilingSlope do SetWall(ID,WID,Sector,Wall);
 ReadFmt('FRICTION: %f',[@friction]);
 ReadFmt('GRAVITY: %f',[@gravity]);
 ReadFmt('ELASTICITY: %f',[@Elasticity]);
 With Velocity do ReadFmt('VELOCITY: %f %f %f',[@dx,@dy,@dz]);
 ReadFmt('STEP SOUND: %s',[@Floor_Sound]);
end;
end;

var OldCurSor:HCursor;
    LastPos:Longint;
begin {ApplyFixUp}
 OldCursor:=SetCursor(LoadCursor(0, IDC_WAIT));

 T:=TTextFile.CreateRead(OpenFileRead(Name,0));
 Progress.Reset(T.FSize);
 Progress.Msg:='Applying FixUp...';
 LastPos:=0;
Try
 While not t.Eof do
 begin
  t.Readln(s);
  p:=GetWord(s,1,w1);
  p:=GetWord(s,p,w2);
  if w1<>'FIXUP:' then continue;
  if w2='WALL' then LoadWall
  else if w2='SECTOR' then LoadSector
  else if w2='DONE' then break;
  Progress.StepBy(t.Fpos-LastPos);
  LastPos:=t.FPos;
 end;
Finally
 T.FClose;
 Progress.Hide;
 SetCursor(OldCursor);
end;
end;

Function IsInSector(Sc:TSector;ptx,ptz:double):boolean;

function GetAngle(x,z:Double;vx1,vx2:TVertex):Double; {calculates angle formed by the X,Z and vertices of the wall}
var a2,b2,c2,x1,z1,x2,z2:Double; {square of triangle sides}
    d:Double;
begin
 a2:=Sqr(vx1.x-x)+sqr(vx1.z-z);
 b2:=Sqr(vx2.x-x)+sqr(vx2.z-z);
 c2:=Sqr(vx2.x-vx1.x)+sqr(vx2.z-vx1.z);
 d:=(a2-c2+b2)/(2*sqrt(b2));
 Try
 Result:=ArcCos(d/sqrt(a2));
 except
  on EInvalidOp do if d/sqrt(a2)>1 then Result:=0 else Result:=Pi;
 end;
 {Find the sign of the angle}
 x1:=x-vx2.x;
 x2:=x-vx1.x;
 z1:=z-vx2.z;
 z2:=z-vx1.z;
 if (x1*z2-x2*z1)<0 then Result:=-Result;
end;

var i:Integer;
    ang:Double;
    vx1,vx2:TVertex;
begin {IsInSector}
 ang:=0;
 for i:=0 to Sc.Walls.Count-1 do
 With Sc.Walls[i] do
 begin
  vx1:=Sc.Vertices[v1];
  vx2:=Sc.Vertices[v2];
  if ((vx1.x=ptx) and (vx1.z=ptz)) or
     ((vx2.x=ptx) and (vx2.z=ptz)) then begin Result:=true; exit; end;
  ang:=ang+GetAngle(ptx,ptz,vx1,vx2);
 end;
Result:=Abs(ang-6.28)<0.01; {2*pi}
end;

procedure RotateGeometry(L:TLevel;def_x,def_z,angle : Double);
var i,j       : Integer;
    rad       : Double;
    oldx      : Double;
begin
 rad := angle * Pi / 180;

 for i := 0 to L.Sectors.Count - 1 do
 With l.Sectors[i] do
 for j := 0 to Vertices.Count - 1 do
 With Vertices[j] do
 begin
  if mark=0 then continue;
  oldx:= X;
  X:= RoundTo2Dec(DEF_X +
      (cos(rad) * (X - DEF_X)
       - sin(rad) * (Z - DEF_Z)));
  Z:= RoundTo2Dec(DEF_Z +
      (sin(rad) * (oldx        - DEF_X)
       + cos(rad) * (Z - DEF_Z)));
  Mark := 0;
 end;
end;

Procedure ScaleGeometry(L:TLevel;def_x,def_z,factor : Double);
var i,j:integer;
begin
 for i := 0 to L.Sectors.Count - 1 do
 With L.Sectors[i] do
 for j := 0 to Vertices.Count - 1 do
 With Vertices[j] do
 begin
  if Mark=0 then continue;
  X := DEF_X + (X - DEF_X) * factor;
  Z := DEF_Z + (Z - DEF_Z) * factor;
 end;
end;


Procedure RotateSectorSelection(L:TLevel;sel:TMultiSelection;x,z,angle:Double);
var m,v:Integer;
begin
 ClearVertexMarks(L);
 MarkSectors(L,Sel);
 RotateGeometry(L,x,z,angle);
end;

Procedure RotateWallSelection(L:TLevel;sel:TMultiSelection;x,z,angle:Double);
begin
 ClearVertexMarks(l);
 MarkWalls(L,Sel);
 RotateGeometry(L,x,z,angle);
end;

Procedure RotateVertexSelection(L:TLevel;sel:TMultiSelection;x,z,angle:Double);
begin
 ClearVertexMarks(l);
 MarkVertices(L,Sel);
 RotateGeometry(L,x,z,angle);
end;

Procedure RotateObjectSelection(L:TLevel;sel:TMultiSelection;def_x,def_z,angle:Double;ObOrient:Boolean);
var i,m:Integer;
    oldx:Double;
    rad:Double;
begin
 for m := 0 to Sel.Count - 1 do
 With L.Objects[Sel.GetObject(m)] do
 begin
  oldx := X;
  X := RoundTo2Dec(DEF_X +
       (cos(rad) * (X - DEF_X)
        - sin(rad) * (Z - DEF_Z)));
  Z := RoundTo2Dec(DEF_Z +
       (sin(rad) * (oldx - DEF_X)
        + cos(rad) * (Z - DEF_Z)));
  if OBOrient then
  begin
   Yaw  := Yaw + 360 - angle;
   if Yaw >= 360 then Yaw := Yaw - 360;
  end;
 end;
end;

Procedure ScaleSectorSelection(L:TLevel;sel:TMultiSelection;x,z,factor:Double);
begin
 ClearVertexMarks(L);
 MarkSectors(L,Sel);
 ScaleGeometry(L,x,z,factor);
end;

Procedure ScaleWallSelection(L:TLevel;sel:TMultiSelection;x,z,factor:Double);
begin
 ClearVertexMarks(L);
 MarkWalls(L,Sel);
 ScaleGeometry(L,x,z,factor);
end;

Procedure ScaleVertexSelection(L:TLevel;sel:TMultiSelection;x,z,factor:Double);
begin
 ClearVertexMarks(L);
 MarkVertices(L,Sel);
 ScaleGeometry(L,x,z,factor);
end;

Procedure ScaleObjectSelection(L:TLevel;sel:TMultiSelection;def_x,def_z,factor:Double);
var i:Integer;
begin
 for i := 0 to l.Objects.Count - 1 do
 With L.Objects[i] do
 begin
  X    := DEF_X + (X - DEF_X) * factor;
  Z    := DEF_Z + (Z - DEF_Z) * factor;
 end;
end;

Procedure RaiseSectorSelection(L:TLevel;sel:TMultiSelection;DY:Double;How:Integer);
var m:Integer;
begin
 for m:=0 to sel.Count-1 do
 With L.Sectors[Sel.GetSector(m)] do
 case how of
  o_floors: Floor_Y:=Floor_Y+DY;
  o_ceilings: Ceiling_Y:=Ceiling_Y+DY;
  o_fcs: begin
          Floor_Y:=Floor_Y+DY;
          Ceiling_Y:=Ceiling_Y+DY;
         end;
 end;
end;

Procedure RaiseObjectSelection(L:TLevel;sel:TMultiSelection;DY:Double);
var m:Integer;
begin
 for m:=0 to Sel.Count-1 do
 With L.Objects[Sel.GetObject(m)] do Y:=Y+DY;
end;

end.
