unit Level_Utils;

interface
uses Level, misc_utils, MultiSelection, SysUtils, Math;
Const
     Any_Layer=-5000;
{Complex level tranformations}

Procedure TranslateSector(L:TLevel;sc:Integer;x,z:double);
Procedure TranslateWall(L:TLevel;sc,wl:Integer;x,z:double);
Procedure TranslateVertex(L:TLevel;sc,vx:Integer;x,z:double);
Procedure TranslateObject(L:TLevel;ob:Integer;x,z:double);

Procedure TranslateSectorSelection(L:TLevel;sel:TMultiSelection;x,z:Double);
Procedure TranslateWallSelection(L:TLevel;sel:TMultiSelection;x,z:Double);
Procedure TranslateVertexSelection(L:TLevel;sel:TMultiSelection;x,z:Double);
Procedure TranslateObjectSelection(L:TLevel;sel:TMultiSelection;dx,dz:Double);
Procedure DeleteSector(L:TLevel;sc:Integer);
Procedure DeleteVertex(L:TLevel;sc,vx:Integer);
Procedure DeleteWall(L:TLevel;sc,wl:Integer);
Procedure DeleteOB(L:TLevel;ob:Integer);
Procedure ClearMarks(L:TLevel);
function MakeAdjoin(L:Tlevel; sc, wl : Integer) : Integer;
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

function  GetObjectSC(L:TLevel;obnum : Integer; VAR ASector : Integer) : Boolean;
Procedure ApplyFixUp(L:TLevel;const Name:String);

implementation
uses Files, FileOperations, Windows;

Procedure ClearMarks(L:TLevel);
var i,j:integer;
begin
 With L do
  For i:=0 to sectors.count-1 do
   with sectors[i] do
    for j:=0 to Vertices.count-1 do vertices[j].mark:=0;
end;

Procedure TranslateSectorSelection(L:TLevel;sel:TMultiSelection;x,z:Double);
var i,j,m     : Integer;
    TheSector : TSector;
    TheSector2: TSector;
    TheVertex : TVertex;
    TheWall   : TWall;
    TheWall2  : TWall;
    TheObject : TOB;
begin
 ClearMarks(l);
 With L do
 begin
  {include the multiselection}
  for m := 0 to Sel.Count - 1 do
   With Sectors[Sel.GetSector(m)] do
    for i:=0 to vertices.count-1 do vertices[i].Mark:=1;

   {include the vertices of the adjoins}
    for m := 0 to Sel.Count - 1 do
     With Sectors[sel.GetSector(m)] do
      for i := 0 to Walls.Count - 1 do
      begin
       TheWall := Walls[i];
       if TheWall.Adjoin <> -1 then
       begin
        TheSector2  := Sectors[TheWall.Adjoin];
        TheWall2    := TheSector2.Walls[TheWall.Mirror];
        TheVertex   := TheSector2.Vertices[TheWall2.V1];
        TheVertex.Mark := 1;
        TheVertex   := TheSector2.Vertices[TheWall2.V2];
        TheVertex.Mark := 1;
       end;
       if TheWall.DAdjoin <> -1 then
       begin
        TheSector2  := Sectors[TheWall.DAdjoin];
        TheWall2    := TheSector2.Walls[TheWall.DMirror];
        TheVertex   := TheSector2.Vertices[TheWall2.V1];
        TheVertex.Mark := 1;
        TheVertex   := TheSector2.Vertices[TheWall2.V2];
        TheVertex.Mark := 1;
       end;
      end;

      {include the vertices of the adjoins of the selection}

      {process the marked VXs}
      for i := 0 to Sectors.Count - 1 do
      With Sectors[i] do
       for j := 0 to Vertices.Count - 1 do
       begin
        TheVertex:=Vertices[j];
         if TheVertex.Mark=1 then
         begin
          TheVertex.X:=TheVertex.X+X;
          TheVertex.Z:=TheVertex.Z+Z;
         end;
       end;
   end;
end;

Procedure TranslateWallSelection(L:TLevel;sel:TMultiSelection;x,z:Double);
var m,i,j:Integer;
    TheWall, TheWall2:TWall;
    TheSector2:TSector;
    TheVertex:TVertex;
begin
 ClearMarks(L);

 {include the multiselection and its mirrors}
 for m := 0 to Sel.Count - 1 do
 With L.Sectors[Sel.GetSector(m)] do
 begin
  TheWall        := Walls[Sel.GetWall(m)];
  Vertices[TheWall.V1].Mark:=1;
  Vertices[TheWall.V2].Mark:=1;
  if TheWall.Adjoin <> -1 then
  begin
   TheSector2:=l.Sectors[TheWall.Adjoin];
   TheWall2  := TheSector2.Walls[TheWall.Mirror];
   TheSector2.Vertices[TheWall2.V1].Mark:=1;
   TheSector2.Vertices[TheWall2.V2].Mark:=1;
  end;
  if TheWall.DAdjoin <> -1 then
  begin
   TheSector2:=l.Sectors[TheWall.DAdjoin];
   TheWall2  := TheSector2.Walls[TheWall.DMirror];
   TheSector2.Vertices[TheWall2.V1].Mark:=1;
   TheSector2.Vertices[TheWall2.V2].Mark:=1;
  end;
 end;

 {process the marked VXs}
 for i := 0 to l.Sectors.Count - 1 do
 With l.Sectors[i] do
 begin
  for j := 0 to Vertices.Count - 1 do
  begin
   TheVertex      := Vertices[j];
   if TheVertex.Mark = 1 then
   begin
    TheVertex.X := TheVertex.X + x;
    TheVertex.Z := TheVertex.Z + z;
   end;
  end;
 end;
end;



Procedure TranslateVertexSelection(L:TLevel;sel:TMultiSelection;x,z:Double);
var m:Integer;
    TheVertex:TVertex;
begin
 ClearMarks(l);
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

Procedure DeleteVertex(L:TLevel;sc,vx:Integer);
var TheWall,TheWall2:TWall;
     nDelWall,nWall,nWall2:Integer;
     i,j:Integer;

Procedure  AdjustWLRef(Var oldSC,oldWl:Integer);
begin
 if oldSC<>sc then exit;
 if oldWL>nDelWall then Dec(oldWL)
 else if oldWL=nDelWall then begin OldWL:=-1; OldSC:=-1; end;
end;

begin
 With l.Sectors[sc] do
 begin
  TheWall:=nil; nWall:=-1;
  TheWall2:=nil; nWall2:=-1;
  {Find two walls this that meet at this vertex}
  For i:=0 to Walls.Count-1 do {Look for wall that starts at this vertex}
   if Walls[i].V1=vx then begin nWall:=i; TheWall:=Walls[i]; break; end;

  For i:=0 to Walls.Count-1 do {Look for wall that ends at this vertex}
   if Walls[i].V2=vx then begin nWall2:=i; TheWall2:=Walls[i]; break; end;

  nDelWall:=nWall;

  {Mark the wall that starts at this vertex for deletion, unless
   no wall does. Then mark wall that ends at this vertex for deletion,
   if any}

  if (TheWall<>nil) and (TheWall2<>nil) then TheWall2.V2:=TheWall.V2
  else if TheWall=nil then nDelWall:=nWall2;

  {Adjusting vertex references}
  For i:= 0 to Walls.Count-1 do
  With Walls[i] do
  begin
   if V1>=vx then Dec(V1);
   if V2>=vx then Dec(V2);
  end;

  {Adjusting Wall references}
  if nDelWall<>-1 then
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

 {Deleting walls and vertices}
  Vertices.Delete(vx);
  if nDelWall<>-1 then Walls.Delete(nDelWall);
 end; {With}
 if l.Sectors[sc].Vertices.Count=0 then DeleteSector(l,sc); {if it was the last vertex}
end;

Procedure DeleteWall(L:TLevel;sc,wl:Integer);
begin
 DeleteVertex(L,sc,l.Sectors[sc].Walls[wl].V1);
end;

Procedure DeleteOB(L:TLevel;ob:Integer);
begin
 l.Objects[ob].Free;
 l.Objects.Delete(ob);
end;

function MakeAdjoin(L:Tlevel; sc, wl : Integer) : Integer;
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
  Wall.Mirror:=Wall.DAdjoin;
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

  for s := 0 to l.Sectors.Count - 1 do
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
 TheWall.Adjoin:=-1;
 TheWall.Mirror:=-1;

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
Inc(Result);
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
 TheWall.DAdjoin:=-1;
 TheWall.DMirror:=-1;

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
Inc(result);
Until true; {Dummy cycle, just for "break" to work}

if badAdjoin then PanMessage(mt_Warning,Format('Bad second adjoin: SC %d WL %d',[sc,wl]));
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
    walllen     : Real;
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
 {TheSector.Walls.Insert(wl, NEWWall);}
 Result:=TheSector.Walls.Add(NEWWall);
 TheWall.V1   := newvxpos;

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

Function GeneratePolygon(x,z,radius:Double;sides:Integer):TVertices;
var TheVertex:TVertex;
    alpha,delta:double;
    i:Integer;
begin
 Result:=TVertices.Create;
 if sides=4 then alpha := Pi/4 else Alpha:=0;
delta := 2 * Pi / Sides;

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
 vxs:=GeneratePolygon(x,z,radius,sides);

 nWalls:=vxs.Count;

for i:=0 to nWalls-1 do
begin
 TheSector.Vertices.Add(vxs[i]);
 Wall:=l.NewWall;
 if RefWall<>nil then Wall.Assign(RefWall);
 if i=nwalls-1 then  Wall.V1:=0 else Wall.V1:=i+1;
 Wall.V2:=i;
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
 vxs:=GeneratePolygon(x,z,radius,sides);
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
  w, itw              : Integer;
  x1, z1, x2, z2,
  dd                  : Double;
  dmin, cal           : Double;
  xi, zi              : Double;
  Sector              : Integer;
begin
 dmin := 9999999.0;
 itw  := -1;
 With L do
 if GetNearestSC(L,Layer,X, Z, sector) then
  begin
   TheSector := Sectors[sector];
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
              if dist_d > dist_g then
               begin
                if TheWall.Adjoin <> -1 then
                 begin
                  if TheWall.Adjoin<>ASector then
                  begin
                   its := TheWall.Adjoin;
                   { adjoin could be on wrong layer! }
                   TheSector2 := Sectors[its];
                   if Layer<>Any_Layer then if TheSector2.layer <> LAYER then its := -1;
                   dmin := cal;
                  end {If Adjoin<>Asector sector}
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

function  GetObjectSC(L:TLevel;obnum: Integer; VAR ASector : Integer) : Boolean;
var sc     : Integer;
    TheObject : TOB;
    TheSector : TSector;
    aLayer:Integer;
begin
  TheObject := L.Objects[obnum];
  Result     := FALSE;
  Sc:=-1;
  For aLayer:=l.MinLayer to L.MaxLayer do
  if GetNearestSC(L,aLayer,TheObject.X, TheObject.Z, sc) then
  begin
   TheSector := l.Sectors[sc];
   if (TheObject.Y >= TheSector.Floor_Y) and (TheObject.Y <= TheSector.Ceiling_Y) then
   begin
    ASector := sc;
    Result:=true;
    Break;
   end;
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
 if N=-1 then exit;
 TheSector:=l.Sectors[N];
 ReadFmt('WALL_TAG: %x',[@ID]);
 N:=TheSector.GetWallByID(ID);
 if N=-1 then
 begin
  PanMessage(mt_Warning,Format('Couldn''t find sector with ID %x',[ID]));
  exit;
 end;
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
 if Overlay.Name='-' then Overlay.Name:='';
 ReadFmt('FLAG_1: %x',[@flags]);
end;
end;

Procedure LoadSector;
Var ID,N:Longint;
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

 With FloorSlope do ReadFmt('FLOOR SLOPE: %x %x %f',[@Sector,@Wall,@angle]);
 With CeilingSlope do ReadFmt('CEILING SLOPE: %x %x %f',[@Sector,@Wall,@angle]);
 ReadFmt('FRICTION: %f',[@friction]);
 ReadFmt('GRAVITY: %f',[@gravity]);
 ReadFmt('ELASTICITY: %f',[@Elasticity]);
 With Velocity do ReadFmt('VELOCITY: %f %f %f',[@dx,@dy,@dz]);
 ReadFmt('STEP SOUND: %s',[@Floor_Sound]);
end;
end;

var OldCurSor:HCursor;
begin {ApplyFixUp}
 OldCursor:=SetCursor(LoadCursor(0, IDC_WAIT));
 
 T:=TTextFile.CreateRead(OpenFileRead(Name,0));
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
 end;
Finally
 T.FClose;
 SetCursor(OldCursor);
end;
end;

Function IsInSector(Sc:TSector;ptx,ptz:double):boolean;

function GetAngle(x,z:Double;vx1,vx2:TVertex):Double; {calculates angle formed by the X,Z and vertices of the wall}
var a2,b2,c2:Double; {square of triangle sides}
    d:Double;
begin
 a2:=Sqr(vx1.x-x)+sqr(vx1.z-z);
 b2:=Sqr(vx2.x-x)+sqr(vx2.z-z);
 c2:=Sqr(vx2.x-vx1.x)+sqr(vx2.z-vx1.z);
 d:=(a2-c2+b2)/(2*sqrt(b2));
 Result:=ArcCos(d/sqrt(a2));
end;

var i:Integer;
    ang:Double;
begin {IsInSector}
 ang:=0;
 for i:=0 to Sc.Walls.Count-1 do
 With Sc.Walls[i] do
 begin
  ang:=ang+GetAngle(ptx,ptz,Sc.Vertices[V1],Sc.Vertices[V2]);
 end;
 Result:=RoundTo2Dec(ang)<>0;
end;

end.
