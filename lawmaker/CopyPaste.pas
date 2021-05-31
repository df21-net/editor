unit CopyPaste;
interface
uses Level,Level_Utils,MultiSelection;

var CF_OLSectors:Word;
    CF_OLObjects:Word;

Procedure CopySectors(L:TLevel;Sel:Integer;MSel:TMultiSelection);
Procedure CopyObjects(L:TLevel;Sel:Integer;MSel:TMultiSelection);
Function CanPasteSectors:Boolean;
Function CanPasteObjects:Boolean;
Function PasteSectors(L:TLevel;atX,atZ:Double):Integer; {Returns first pasted Sector}
Function PasteObjects(L:TLevel;atX,atZ:Double):Integer; {Returns first pasted Object}

implementation
uses Windows,Clipbrd, Misc_utils;

Procedure CopySectors(L:TLevel;Sel:Integer;MSel:TMultiSelection);
var hg,size:Integer;
    pSec:^TSectorClip;
    pWall:^TWallClip;
    pVX:^TVertexClip;
    TheSector:TSector;
    TheWall:TWall;
    TheVertex:TVertex;
    refX,refZ:Double;
    pg:pointer;
    Clp:TClipboard;
    i,j:Integer;
    nSel:Integer;
begin
 {Add selection to multiselection, if not there}
 nSel:=MSel.FindSector(Sel);
 if NSel=-1 then NSel:=MSel.AddObject(Sel) else NSel:=-1;

 {Calc refrence point}
 With L.Sectors[Sel].Vertices[0] do
 begin
  RefX:=X;
  RefZ:=Z;
 end;

 {Calculate the size of the sector clip}

 Size:=mSel.Count*sizeof(TSectorClip)+sizeof(longint);
 for i:=0 to mSel.Count-1 do
 With L.Sectors[MSel.GetSector(i)] do
  inc(Size,sizeof(TWallClip)*Walls.Count+sizeof(TVertexClip)*Vertices.Count);

 hg:=GlobalAlloc(GMEM_MOVEABLE or GMEM_SHARE,size);
 pg:=GlobalLock(hg);
 Longint(pg^):=MSel.Count; inc(pchar(pg),sizeof(longint));

 For i:=0 to MSel.Count-1 do
 begin
  pSec:=pg;
  TheSector:=L.Sectors[MSel.GetSector(i)];
  TheSector.CopyToClip(pSec^);
  pg:=PChar(PSec)+sizeof(TSectorClip);
  pVX:=pg;
  For j:=0 to TheSector.Vertices.Count-1 do
  With TheSector.Vertices[j] do
  begin
   pVX^.X:=X-refX;
   pVX^.Z:=Z-refZ;
   inc(pVX);
  end;
  pg:=PVx;
  PWall:=Pg;

  for J:=0 to TheSector.Walls.Count-1 do
  With TheSector.Walls[j] do
  begin
   CopyToClip(pWall^);
   inc(pWall);
  end;
  pg:=pWall;
 end;

 {Delete selection from multiselection, if it was added}
 if NSel<>-1 then MSel.Delete(NSel);

 {Put data to clipboard}
 GlobalUnlock(hg);
 Clp:=Clipboard;
 Clp.Clear;
 Clp.SetAsHandle(CF_OLSectors,hg);
end;

Procedure CopyObjects(L:TLevel;Sel:Integer;MSel:TMultiSelection);
var hg:Integer;
    nsel:Integer;
    refX,RefZ:Double;
    pg:Pointer;
    pob:^TOBClip;
    Clp:TClipboard;
    i:Integer;
begin
 nSel:=MSel.FindObject(Sel);
 if NSel=-1 then NSel:=MSel.AddObject(Sel) else NSel:=-1;
 With L.Objects[Sel] do
 begin
  RefX:=X;
  RefZ:=Z;
 end;
 hg:=GlobalAlloc(GMEM_MOVEABLE or GMEM_SHARE,MSel.Count*Sizeof(TOBClip)+sizeof(Longint));
 pg:=GlobalLock(hg);
 Longint(pg^):=MSel.Count; Inc(pchar(pg),sizeof(LongInt));
 POb:=pg;

 for i:=0 to Msel.Count-1 do
 begin
  L.Objects[mSel.GetObject(i)].CopyToClip(pob^);
  POb^.X:=POb^.X-RefX;
  POb^.Z:=POb^.Z-RefZ;
  inc(pob);
 end;

 GlobalUnlock(hg);
 if NSel<>-1 then MSel.Delete(NSel);
 Clp:=Clipboard;
 Clp.Clear;
 Clp.SetAsHandle(CF_OLObjects,hg);
end;

Function CanPasteSectors:Boolean;
var Clp:TClipboard;
begin
 Clp:=Clipboard;
 Result:=Clp.HasFormat(CF_OLSectors);
end;

Function CanPasteObjects:Boolean;
var Clp:TClipboard;
begin
 Clp:=Clipboard;
 Result:=Clp.HasFormat(CF_OLObjects);
end;

Function PasteSectors(L:TLevel;atX,atZ:Double):Integer; {Returns first pasted Sector}
var hg:Integer;
    pg:Pointer;
    pSec:^TSectorClip;
    pWall:^TWallClip;
    pVX:^TVertexClip;
    Clp:TClipboard;
    i,j,n:Integer;
    TheSector:TSector;
    TheWall:TWall;
    TheVertex:TVertex;
begin
 Result:=-1;
 if not CanPasteSectors then exit;
 Clp:=Clipboard;
 Clp.Open;
 hg:=Clp.GetAsHandle(CF_OLSectors);
 pg:=GlobalLock(hg);

 n:=Longint(pg^);Inc(pchar(pg),sizeof(LongInt));


 Result:=L.Sectors.Count;
 for i:=0 to n-1 do
 begin
  PSec:=pg;
  TheSector:=L.NewSector;
  TheSector.PasteFromClip(pSec^);
  L.Sectors.Add(TheSector);
  pg:=PChar(PSec)+sizeof(TSectorClip);
  pVx:=pg;
  for j:=0 to pSec^.nVertices-1 do
  begin
   TheVertex:=L.NewVertex;
   TheVertex.X:=RoundTo2Dec(pVX^.X+atX);
   TheVertex.Z:=RoundTo2Dec(pVX^.Z+atZ);
   TheSector.Vertices.Add(TheVertex);
   inc(pVx);
  end;
  pg:=PVx;
  pWall:=pg;
  for j:=0 to pSec^.NWalls-1 do
  begin
   TheWall:=L.NewWall;
   TheWall.PasteFromClip(pWall^);
   TheSector.Walls.Add(TheWall);
   inc(pWall);
  end;
  pg:=PWall;
 end;

 GlobalUnlock(hg);
 Clp.Close;
 {Post Processing - adjoin walls and arrange slopes}
 For i:=Result to L.Sectors.Count-1 do
 With L.Sectors[i] do
 begin
  FloorSlope.Sector:=i;
  CeilingSlope.Sector:=i;
  for j:=0 to Walls.Count-1 do MakeAdjoinFromSCUp(L,i,j,Result);
 end;
end;

Function PasteObjects(L:TLevel;atX,atZ:Double):Integer; {Returns first pasted Object}
var hg:Integer;
    pg:Pointer;
    pob:^TOBClip;
    Clp:TClipboard;
    i,n:Integer;
    TheObject:TOB;
begin
 Result:=-1;
 if not CanPasteObjects then exit;
 Clp:=Clipboard;
 Clp.Open;
 hg:=Clp.GetAsHandle(CF_OLObjects);
 pg:=GlobalLock(hg);

 n:=Longint(pg^);Inc(pchar(pg),sizeof(LongInt));
 POb:=pg;

 Result:=L.Objects.Count;
 for i:=0 to n-1 do
 begin
  TheObject:=L.NewObject;
  TheObject.PasteFromClip(pob^);
  TheObject.X:=RoundTo2Dec(pOb^.X+atX);
  TheObject.Y:=pOb^.Y;
  TheObject.Z:=RoundTo2Dec(pOb^.Z+atZ);
  L.Objects.Add(TheObject);
  inc(pob);
 end;

 GlobalUnlock(hg);
 Clp.Close;
end;

Initialization
begin
 CF_OLObjects:=RegisterClipboardFormat('OLOBJECTS');
 CF_OLSectors:=RegisterClipboardFormat('OLSECTORS');
end;

end.
