unit u_undo;

{$MODE Delphi}

interface

uses J_level, SysUtils, Classes, GlobalVars, values, u_3dos;

{$A-}

const
     {Undo change constants}
     ch_added=0;
     ch_deleted=1;
     ch_changed=2;

     {Sector change constants}
     sc_geo=4;
     sc_val=8;
     sc_both=sc_geo+sc_val;

Type
 PWord=^Word;
 PInt=^SmallInt;

 TVXRec=record
  x,y,z:double;
 end;
 PVXRec=^TVXRec;

 TSFVX=record
  nvx:word;
  u,v:single;
  intensity:single;
  r,g,b:single;
 end;

 PSFVX=^TSFVX;

 PSecRec=^TSecRec;
 TSecRec=record
  Flags:longint;
  Ambient:single;
  extra:single;
  ColorMap:array[0..31] of char;
  Tint:record r,g,b:single end;
  Sound:array[0..47] of char;
  snd_vol:single;
  layer:SmallInt;
  nvxs,nsfs:integer;
 end;

 PSurfRec=^TSurfRec;

 TSurfRec=record
  AdjSC,AdjSF:SmallInt;
  AdjoinFlags:Longint;
  Material:array[0..47] of char;
  SurfFlags,FaceFlags:Longint;
  geo,light,tex:byte;
  extraLight:single;
  uscale,vscale:single;
  nvxs:integer;
  adjID:integer;
 end;

TLightRec=record
 X,Y,Z:double;
 Intensity:double;
 Range:double;
 flags:longint;
 R,G,B:Single;
 rgbintensity:single;
 layer:SmallInt;
end;

PThingRec=^TThingRec;
TThingRec=record
 Sec:SmallInt;
 name:array[0..47] of char;
 X,Y,Z:double;
 PCH,YAW,ROL:Double;
 layer:SmallInt;
 vals:array[0..0] of char;
end;


TCogRec=record
 name:array[0..47] of char;
 vals:array[0..255] of char;
 {vals:TCOGValues;}
end;

TURQRec=record
 nodename:array[0..63] of char;
 x,y,z:double;
 pch,yaw,rol:double;
 ntype:integer;
 parent:integer;
end;

Procedure StartUndoRec(const name:string);
Procedure SaveSecUndo(sec:TJKSector;change:integer;how:integer);
Procedure SaveThingUndo(th:TJKThing;change:integer);
Procedure SaveLightUndo(lt:TJedLight;change:integer);
Procedure SaveCOGUndo(cog:TCOG);
Procedure SaveNodeUndo(node:THnode;change:integer);
Procedure ClearNodesUndo;

Procedure EndUndoRec;
Function GetUndoRecName:string;
Procedure ApplyUndo;
Procedure ClearUndoBuffer;

Procedure GetLight(light:TJedLight;var lrec:TLightRec);
Procedure SetLight(light:TJedLight;var lrec:TLightRec);
Function GetLightRecSize:integer;

Function GetThingRecSize(thing:TJKThing):integer;
Function GetThing(thing:TJKThing;trec:PThingRec):integer;
Function SetThing(thing:TJKThing;trec:PThingRec):integer;

Function GetThingValSize(thing:TJKThing):integer;
Function getThingVals(thing:TJKThing;pvals:Pchar):integer;
Function SetThingVals(thing:TJKThing;pvals:Pchar):integer;

Function GetCOGRecRecSize:integer;
Procedure GetCOG(cog:TCog;var crec:TCogRec);
Procedure SetCOG(cog:TCog;var crec:TCogRec);


Function GetSecRecSize:Integer;
Procedure GetSec(sec:TJKSector;var srec:TSecRec);
Procedure SetSec(sec:TJKSector;var srec:TSecRec);
Procedure GetSurf(surf:TJKSurface;var sfrec:TSurfRec);
Function GetSurfRecSize:Integer;
Procedure SetSurf(surf:TJKSurface;var sfrec:TSurfRec);
Function SCVertSize(vs:TJKVertices):integer;
Procedure GetSCVertices(vs:TJKVertices;vxrecs:PVXRec);
Procedure SetSCVertices(vs:TJKVertices;nvxs:integer;vxrecs:PVXRec);
Function SFVertSize(vs:TJKVertices):integer;
Procedure GetSFVertices(surf:TJKSurface;pvxs:PSFVX);
Procedure SetSFVertices(sec:TJKSector;surf:TJKSUrface;nvxs:integer;pvxs:PSFVX);

Function GetURQRecSize:integer;
Procedure GetURQRec(node:THNode;var nrec:TURQRec);
Procedure SetURQRec(node:THNode;var nrec:TURQRec);

implementation

uses Misc_utils,  Jed_Main, lev_utils, u_3doform;

Type

TUndoChange=class
 change:integer; {ch_ constants}
 data:pointer; {undo data}
 Procedure SaveUndo(obj:TObject;ch:integer);virtual;abstract;
 procedure Undo(objid:Integer);virtual;abstract;
 Destructor Destroy;override;
end;


TLightUndo=class(TUndoChange)
 Procedure SaveUndo(obj:TObject;ch:integer);override;
 procedure Undo(objid:Integer);override;
end;

TThingUndo=class(TUndoChange)
 Procedure SaveUndo(obj:TObject;ch:integer);override;
 procedure Undo(objid:Integer);override;
end;

TSecValUndo=class(TUndoChange)
 nsfs:integer;
 Procedure SaveUndo(obj:TObject;ch:integer);override;
 procedure Undo(objid:Integer);override;
end;

TSecGeoUndo=class(TUndoChange)
 nvxs,nsfs:integer;
 Procedure SaveUndo(obj:TObject;ch:integer);override;
 procedure Undo(objid:Integer);override;
end;

TURQUndo=class(TUndoChange)
 Procedure SaveUndo(obj:TObject;ch:integer);override;
 procedure Undo(objid:Integer);override;
end;


 TObjList=Class(TList)
  ids:TIntList;
  Constructor Create;
  Destructor Destroy; override;
  Procedure AddObject(obj:TObject; objid:integer);
  Function FindObjID(objid:integer):integer;
  Function GetObj(n:integer):TUndoChange;
  Function GetObjID(n:integer):Integer;
{  Procedure SetIdxObj(n:integer;idxobj:TObject);}
 end;

 TUndoRec=class
  name:string;
  thchanges:TObjList;
  ltchanges:TObjList;
  cgchanges:TObjList;
  scvchanges:TObjList;
  scgchanges:TObjList;
  nodechanges:TObjList;
  Constructor Create;
  Destructor Destroy;override;
 end;



var
  UndoStack:TList;
  curUndoRec:TUndoRec;

Destructor TUndoChange.Destroy;
begin
 if data<>nil then FreeMem(data);
end;


Constructor TObjList.Create;
begin
 ids:=TIntList.Create;
end;

Destructor TObjList.Destroy;
var i:integer;
begin
 for i:=0 to count-1 do
  GetObj(i).Free;
 ids.free;
 Inherited Destroy;
end;

Procedure TObjList.AddObject(obj:TObject; objid:integer);
begin
 ids.Add(objid);
 Add(obj);
end;

Function TObjList.FindObjID(objid:integer):integer;
begin
 Result:=ids.IndexOf(ObjID);
end;

Function TObjList.GetObj(n:integer):TUndoChange;
begin
 Result:=TUndoChange(Items[n]);
end;

Function TObjList.GetObjID(n:integer):Integer;
begin
 Result:=ids[n];
end;

{Procedure TObjList.SetIdxObj(n:integer;idxobj:TObject);
begin
 idx[n]:=idxobj;
end;}

Constructor TUndoRec.Create;
begin
 thchanges:=TObjList.Create;
 ltchanges:=TObjList.Create;
 cgchanges:=TObjList.Create;
 scvchanges:=TObjList.Create;
 scgchanges:=TObjList.Create;
 nodechanges:=TObjList.Create;
end;

Destructor TUndoRec.Destroy;
begin
 thchanges.Free;
 ltchanges.Free;
 cgchanges.Free;
 scvchanges.Free;
 scgchanges.Free;
 nodechanges.Free;
end;



Function GetSecRecSize:Integer;
begin
 result:=sizeof(TSecRec);
end;

Procedure GetSec(sec:TJKSector;var srec:TSecRec);
begin
 with sec do
 begin
  srec.flags:=Flags;
  srec.Ambient:=Ambient;
  srec.extra:=extra;
  StrLCopy(srec.ColorMap,pchar(Colormap),Sizeof(srec.colormap));
  srec.tint.r:=Tint.dx;
  srec.tint.g:=Tint.dy;
  srec.tint.b:=Tint.dz;
  StrLCopy(srec.Sound,Pchar(Sound),sizeof(srec.Sound));
  srec.snd_vol:=snd_vol;
  srec.layer:=Layer;
  srec.nvxs:=Vertices.count;
  srec.nsfs:=Surfaces.count;
 end;
end;

Procedure SetSec(sec:TJKSector;var srec:TSecRec);
begin
 with sec do
 begin
  Flags:=srec.flags;
  Ambient:=srec.Ambient;
  extra:=srec.extra;
  ColorMap:=srec.Colormap;
  Tint.dx:=srec.tint.r;
  Tint.dy:=srec.tint.g;
  Tint.dz:=srec.tint.b;
  sound:=Srec.Sound;
  snd_vol:=srec.snd_vol;
  layer:=srec.layer;
 end;
end;

Procedure GetSurf(surf:TJKSurface;var sfrec:TSurfRec);
begin
With surf do
begin
 if adjoin=nil then begin sfrec.adjSC:=-1; sfrec.adjSF:=0; end else
 begin
  sfrec.AdjSC:=adjoin.sector.num;
  sfrec.adjSF:=adjoin.num;
  sfrec.adjID:=adjoin.sector.id;
 end;
 sfrec.AdjoinFlags:=AdjoinFlags;
 StrLCopy(sfrec.Material,pchar(Material),sizeof(sfrec.Material));
 sfrec.SurfFlags:=SurfFlags;
 sfrec.FaceFlags:=FaceFlags;
 sfrec.geo:=geo;
 sfrec.light:=light;
 sfrec.tex:=tex;
 sfrec.extraLight:=extralight;
 sfrec.uscale:=uscale;
 sfrec.vscale:=vscale;
 sfrec.nvxs:=Vertices.count;
end;
end;

Function GetSurfRecSize:Integer;
begin
 Result:=sizeof(TSurfRec);
end;

Procedure SetSurf(surf:TJKSurface;var sfrec:TSurfRec);
begin
 surf.mark:=sfrec.AdjSC*65536+sfrec.AdjSF;
 surf.nadj:=sfrec.adjID;
 surf.AdjoinFlags:=sfrec.AdjoinFlags;
 surf.Material:=sfrec.Material;
 surf.SurfFlags:=sfrec.SurfFlags;
 surf.FaceFlags:=sfrec.FaceFlags;
 surf.geo:=sfrec.geo;
 surf.light:=sfrec.light;
 surf.tex:=sfrec.tex;
 surf.extralight:=sfrec.extraLight;
 surf.uscale:=sfrec.uscale;
 surf.vscale:=sfrec.vscale;
end;

Function SCVertSize(vs:TJKVertices):integer;
begin
 result:=vs.count*sizeof(TVXRec);
end;

Procedure GetSCVertices(vs:TJKVertices;vxrecs:PVXRec);
var i:integer;
begin
 for i:=0 to vs.count-1 do
 with vs[i] do
 begin
  vxrecs^.x:=x;
  vxrecs^.y:=y;
  vxrecs^.z:=z;
  inc(vxrecs);
 end;
end;

Procedure SetSCVertices(vs:TJKVertices;nvxs:integer;vxrecs:PVXRec);
var i:integer;
begin
 for i:=0 to nvxs-1 do
 with vs[i] do
 begin
  x:=vxrecs^.x;
  y:=vxrecs^.y;
  z:=vxrecs^.z;
  inc(vxrecs);
 end;
end;


Function SFVertSize(vs:TJKVertices):integer;
begin
 result:=vs.count*sizeof(TSFVX);
end;

Procedure GetSFVertices(surf:TJKSurface;pvxs:PSFVX);
var i:integer;
begin
 for i:=0 to surf.vertices.count-1 do
 with surf.vertices[i],surf.txvertices[i] do
 begin
  pvxs^.nvx:=surf.vertices[i].num;
  pvxs^.u:=u;
  pvxs^.v:=v;
  pvxs^.intensity:=Intensity;
  pvxs^.r:=r;
  pvxs^.g:=g;
  pvxs^.b:=b;
  inc(pvxs);
 end;
end;

Procedure SetSFVertices(sec:TJKSector;surf:TJKSUrface;nvxs:integer;pvxs:PSFVX);
var i:integer;
begin
 for i:=0 to nvxs-1 do
 with surf.txvertices[i] do
 begin
  surf.vertices[i]:=sec.Vertices[pvxs^.nvx];
  u:=pvxs^.u;
  v:=pvxs^.v;
  Intensity:=pvxs^.intensity;
  r:=pvxs^.r;
  g:=pvxs^.g;
  b:=pvxs^.b;
  inc(pvxs);
 end;
end;

Function GetLightRecSize:integer;
begin
 Result:=Sizeof(TLightRec);
end;

Procedure GetLight(light:TJedLight;var lrec:TLightRec);
begin
 With light do
 begin
  lrec.X:=x;
  lrec.Y:=y;
  lrec.Z:=z;
  lrec.Intensity:=Intensity;
  lrec.Range:=range;
  lrec.flags:=flags;
  lrec.R:=r;
  lrec.G:=g;
  lrec.B:=b;
  lrec.rgbintensity:=rgbintensity;
  lrec.layer:=layer;
 end;
end;

Procedure SetLight(light:TJedLight;var lrec:TLightRec);
begin
 With light do
 begin
  x:=lrec.X;
  y:=lrec.Y;
  z:=lrec.Z;
  Intensity:=lrec.Intensity;
  range:=lrec.Range;
  flags:=lrec.flags;
  r:=lrec.R;
  g:=lrec.G;
  b:=lrec.B;
  rgbintensity:=lrec.rgbintensity;
  layer:=lrec.layer;
 end;
end;

Function GetThingRecSize(thing:TJKThing):integer;
begin
 Result:=Sizeof(TThingRec)+GetThingValSize(thing);
end;

Function GetThing(thing:TJKThing;trec:PThingRec):integer;
begin
 With thing do
 begin
  if sec=nil then trec.Sec:=-1 else trec.sec:=Sec.num;
  StrLCopy(trec.Name,pchar(Name),sizeof(trec.Name));
  trec.X:=X;
  trec.Y:=Y;
  trec.Z:=Z;
  trec.PCH:=PCH;
  trec.YAW:=YAW;
  trec.ROL:=ROL;
  trec.layer:=layer;
 end;
 result:=sizeof(TThingRec)+GetThingVals(thing,trec.vals);
end;

Function SetThing(thing:TJKThing;trec:PThingRec):integer;
begin
 With thing do
 begin
  {Mark:=trec.sec;}
  name:=trec.Name;
  X:=trec.X;
  Y:=trec.Y;
  Z:=trec.Z;
  PCH:=trec.PCH;
  YAW:=trec.YAW;
  ROL:=trec.ROL;
  layer:=trec.layer;
 end;
 result:=sizeof(TThingRec)+SetThingVals(thing,trec.vals);
end;

Function GetThingValSize(thing:TJKThing):integer;
var i:integer;
begin
 result:=0;
 for i:=0 to thing.Vals.count-1 do
 with thing.vals[i] do
 begin
  inc(result);
  inc(result,length(name));
  inc(result);
  inc(result,length(AsString));
 end;
end;

Function getThingVals(thing:TJKThing;pvals:Pchar):integer;
var st:string;
    i:integer;
begin
  st:='';
  for i:=0 to thing.vals.count-1 do
  With thing.vals[i] do
  begin
   if st='' then st:=ConCat(name,'=',AsString) else
                st:=ConCat(st,#32,name,'=',AsString);
  end;
  StrCopy(pvals,pchar(st));
 result:=length(st);
end;

Function SetThingVals(thing:TJKThing;pvals:Pchar):integer;
var
    n,p:integer;
    v:TTPLValue;
    s,w:string;
begin
  s:=pvals;
  result:=length(s);
  p:=1;n:=0;
  while p<=length(s) do
  begin
   p:=GetWord(s,p,w);
   if n<thing.Vals.count then v:=thing.vals[n] else
   begin v:=TTPLValue.Create; thing.Vals.Add(v); end;
   S2TPLVal(w,v);
   inc(n);
  end;

  for p:=thing.Vals.count-1 downto n do
   begin
    thing.Vals[p].Free;
    thing.Vals.Delete(p);
   end;
end;


Procedure ResolveThingRefs(thing:TJKThing;var trec:TThingRec);
begin
 if (trec.sec<0) or (trec.sec>=Level.Sectors.count) then Thing.sec:=nil
 else thing.Sec:=Level.Sectors[trec.sec];
end;

Function GetCOGRecRecSize:integer;
begin
 result:=Sizeof(TCOGRec);
end;

Procedure GetCOG(cog:TCog;var crec:TCogRec);
var s:string;
    i:integer;
begin
 StrLCopy(crec.Name,pchar(cog.Name),sizeof(crec.Name));
 s:='';
 for i:=0 to cog.vals.count-1 do
 begin
 end;
end;

Procedure SetCOG(cog:TCog;var crec:TCogRec);
begin
 cog.name:=crec.name;
end;

Function GetURQRecSize:integer;
begin
 result:=sizeof(TURQRec);
end;

Procedure GetURQRec(node:THNode;var nrec:TURQRec);
begin
 StrLCopy(nrec.NodeName,pchar(node.NodeName),sizeof(nrec.NodeName));
 nrec.x:=node.x;
 nrec.y:=node.y;
 nrec.z:=node.z;
 nrec.pch:=node.pch;
 nrec.yaw:=node.yaw;
 nrec.rol:=node.rol;
 nrec.ntype:=node.ntype;
 nrec.parent:=node.parent;
end;

Procedure SetURQRec(node:THNode;var nrec:TURQRec);
begin
 StrLCopy(nrec.NodeName,pchar(node.NodeName),sizeof(nrec.NodeName));
 node.x:=nrec.x;
 node.y:=nrec.y;
 node.z:=nrec.z;
 node.pch:=nrec.pch;
 node.yaw:=nrec.yaw;
 node.rol:=nrec.rol;
 node.ntype:=nrec.ntype;
 node.parent:=nrec.parent;
end;

Procedure StartUndoRec(const name:string);
begin
 if not UndoEnabled then
 begin
  ClearUndoBuffer;
  exit;
 end;

 While UndoStack.Count>4 do
 begin
  TUndoRec(UndoStack[0]).Free;
  UndoStack.Delete(0);
 end;

 curUndoRec:=TUndoRec.Create;
 CurUndoRec.Name:=name;
 UndoStack.Add(CurUndoRec);
end;

Procedure TLightUndo.SaveUndo(obj:TObject;ch:integer);
begin
 change:=ch;
 case change of
  ch_added:;
  ch_deleted,ch_changed:
  begin
   GetMem(Data,GetLightRecSize);
   getLight(TJedLight(obj),TLightRec(data^));
  end;
 end;

end;

procedure TLightUndo.Undo(objid:Integer);
var n:integer;
    lt:TJedLight;
begin
 n:=Level.GetLightByID(objid);

 case change of
  ch_added: if n=-1 then exit else Level.Lights.Delete(n);
  ch_deleted,ch_changed:
  begin
   if (change=ch_deleted) then
   begin
     if (n<>-1) then exit;
     lt:=Level.NewLight; Level.Lights.Add(lt);
   end;
   if (change=ch_changed) then
   begin
    if (n=-1) then exit;
    lt:=Level.Lights[n];
   end;
   SetLight(lt,TLightRec(data^));
  end;
 end;
 JedMain.LevelChanged;
end;

Procedure TThingUndo.SaveUndo(obj:TObject;ch:integer);
begin
 change:=ch;
 case change of
  ch_added:;
  ch_deleted,ch_changed:
  begin
   GetMem(Data,GetThingRecSize(TJKThing(obj)));
   getThing(TJKThing(obj),PThingRec(data));
  end;
 end;
end;

procedure TThingUndo.Undo(objid:Integer);
var n:integer;
    th:TJKThing;
    tmpur:TUndoRec;
begin
 n:=Level.GetThingByID(objid);
 case change of
  ch_added: if n=-1 then exit else
            begin
             tmpur:=CurUndoRec;
             CurUndoRec:=nil;
             DeleteThing(Level,n);
             CurUndoRec:=tmpur;
            end;
  ch_deleted: begin
               if n<>-1 then exit;
               th:=Level.NewThing;
               SetThing(th,PThingRec(data));
               ResolveThingRefs(th,TThingRec(data^));
               Level.Things.Add(th);
               Level.RenumThings;
               JedMain.ThingAdded(th);
              end;
  ch_changed: begin
               if (n=-1) then exit;
               th:=Level.Things[n];
               SetThing(th,PThingRec(data));
               ResolveThingRefs(th,TThingRec(data^));
               JedMain.ThingChanged(th);
              end;
 end;
end;

Procedure TSecValUndo.SaveUndo(obj:TObject;ch:integer);
var sec:TJKSector;
    pd:pchar;
    i:integer;
begin
 change:=ch;
 if (ch<>ch_changed) and (ch<>ch_deleted) then exit;
 sec:=TJKSector(obj);
 nsfs:=sec.surfaces.count;
 GetMem(Data,GetSecRecSize+GetSurfRecSize*nsfs);
 pd:=Data;
 GetSec(sec,PSecRec(pd)^);
 inc(pd,GetSecRecSize);
 for i:=0 to sec.surfaces.count-1 do
 begin
  GetSurf(sec.surfaces[i],PSurfRec(pd)^);
  inc(pd,GetSurfRecSize);
 end;

end;

procedure TSecValUndo.Undo(objid:Integer);
var sec:TJKSector;
    pd:pchar;
    i,n:integer;

Procedure ResolveRefs;
var asec:TJKSector;
    surf,asurf:TJKSurface;
    i:integer;
    sc,sf:integer;
begin

 for i:=0 to sec.surfaces.count-1 do
 begin
  surf:=sec.surfaces[i];
  sc:=surf.mark shr 16;
  sf:=surf.mark and 65535;
  surf.adjoin:=nil;
  if sc=65535 then continue;

  sc:=Level.GetSectorByID(surf.nadj);
  if sc=-1 then continue;

  if sc>=Level.Sectors.Count then continue;
  asec:=Level.Sectors[sc];
  if sf>=aSec.Surfaces.Count then continue;
  asurf:=asec.surfaces[sf];

{  if (asurf.adjoin<>nil) and (asurf.adjoin.sector<>sec) then continue;}
  surf.adjoin:=asurf;
  asurf.adjoin:=surf;

  {if asurf.adjoin=nil then}


 end;
end;


begin
 case change of
  ch_changed,ch_deleted:
              begin
               n:=Level.GetSectorByID(objid);
               if n=-1 then exit;
               sec:=Level.Sectors[n];
              end;
 else exit;
 end;


 pd:=Data;

 SetSec(sec,PSecRec(pd)^);
 inc(pd,GetSecRecSize);


 n:=sec.surfaces.count;
 if n>nsfs then n:=nsfs;

 for i:=0 to n-1 do
 begin
  SetSurf(sec.surfaces[i],PSurfRec(pd)^);
  inc(pd,GetSurfRecSize);
  sec.surfaces[i].adjoin:=nil;
 end;

 ResolveRefs;
 JedMain.SectorChanged(sec);

end;



Procedure TSecGeoUndo.SaveUndo(obj:TObject;ch:integer);
type
    pword=^word;
var pd:pchar;
    size,i:integer;
    sec:TJKSector;
    surf:TJKSurface;
begin
 change:=ch;
 case change of
  ch_added:;
  ch_deleted,ch_changed:
  begin
   sec:=TJKSector(Obj);
   sec.Renumber;
   nsfs:=sec.surfaces.count;
   nvxs:=sec.vertices.count;

   size:=SCVertSize(sec.vertices);
   for i:=0 to sec.surfaces.count-1 do
    inc(size,2+SFVertSize(sec.Surfaces[i].Vertices));
   GetMem(Data,size);

   pd:=data;
   GetSCVertices(sec.vertices,PVXRec(pd));
   inc(pd,SCVertSize(sec.vertices));

   for i:=0 to sec.surfaces.count-1 do
   begin
    surf:=sec.surfaces[i];
    pword(pd)^:=surf.vertices.count;
    inc(pd,2);
    GetSFVertices(surf,PSFVX(pd));
    inc(pd,SFVertSize(surf.vertices));
   end;

 end;
end;
end;

procedure TSecGeoUndo.Undo(objid:Integer);
type
    pword=^word;
var n:integer;
    sec:TJKSector;
    tmpur:TUndoRec;
    pd:pchar;

Procedure SetSector;
var i,j,n:integer;
    surf:TJKSurface;
begin
 tmpur:=CurUndoRec;
 CurUndoRec:=nil;
try
 pd:=data;

 if nvxs<sec.vertices.count then
 For i:=sec.vertices.count-1 downto nvxs do
 begin
  sec.vertices[i].Free;
  sec.vertices.Delete(i);
 end;

 if nvxs>sec.vertices.count then
 For i:=sec.vertices.count to nvxs-1 do
  sec.Newvertex;


 SetSCVertices(sec.vertices,nvxs,PVXRec(pd));
 inc(pd,SCVertSize(sec.vertices));

 if nsfs<sec.surfaces.count then
 for i:=sec.surfaces.count-1 downto nsfs do
 begin
   surf:=sec.surfaces[i];
   RemoveSurfRefs(Level,surf);
   surf.free;
   sec.surfaces.Delete(i);
 end;

 if nsfs>sec.surfaces.count then
 for i:=sec.surfaces.count to nsfs-1 do
 begin
  surf:=sec.NewSurface;
  sec.surfaces.Add(surf);
 end;

 for i:=0 to nsfs-1 do
 begin
  surf:=sec.surfaces[i];
  n:=pword(pd)^;
  inc(pd,2);

  if n<surf.vertices.count then
  for j:=surf.vertices.count-1 downto n do
   surf.DeleteVertex(j);

  if n>surf.vertices.count then
  for j:=surf.vertices.count to n-1 do
   surf.AddVertex(nil);

  SetSFVertices(sec,surf,n,PSFVX(pd));
  inc(pd,SFVertSize(surf.vertices));
 end;

finally
 sec.Renumber;

 for i:=0 to sec.surfaces.count-1 do
  sec.surfaces[i].Recalc;

 CurUndoRec:=tmpur;
end;

end;

begin
 n:=Level.GetSectorByID(objID);
 case change of
  ch_added: if n=-1 then exit else
            begin
             tmpur:=CurUndoRec;
             CurUndoRec:=nil;
             DeleteSector(Level,n);
             CurUndoRec:=tmpur;
            end;
  ch_deleted: begin
               if n<>-1 then exit;
               sec:=Level.NewSector;
               sec.ID:=ObjID;
               SetSector;
               Level.Sectors.Add(sec);
               Level.RenumSecs;
               JedMain.SectorAdded(sec);
              end;
  ch_changed: begin
               if (n=-1) then exit;
               sec:=Level.Sectors[n];
               SetSector;
               JedMain.SectorChanged(sec);
              end;
 end;
end;


Procedure TURQUndo.SaveUndo(obj:TObject;ch:integer);
begin
 change:=ch;
 case change of
  ch_added:;
  ch_deleted,ch_changed:
  begin
   GetMem(Data,GetURQRecSize);
   getURQRec(THNode(obj),TURQRec(data^));
  end;
 end;

end;

procedure TURQUndo.Undo(objid:Integer);
var n:integer;
    node:THNode;
begin
 n:=Level.GetNodeByID(objid);

 case change of
  ch_added: if n=-1 then exit else Level.h3donodes.Delete(n);
  ch_deleted,ch_changed:
  begin
   if (change=ch_deleted) then
   begin
    if n<>-1 then exit;
    node:=THNode.Create; Level.h3donodes.Add(node);
   end;

   if (change=ch_changed) then
   if n=-1 then exit else node:=Level.h3donodes[n];

    SetURQRec(node,TURQRec(data^));
  end;
 end;
 UrqForm.UpdateMeshOffsets;
 UrqForm.reload;
 JedMain.LevelChanged;
end;

Procedure SaveNodeUndo(node:THnode;change:integer);
var nch:TUndoChange;
begin
 if CurUndoRec=nil then exit;

 if CurUndoRec.nodechanges.FindObjID(node.id)<>-1 then exit; {already saved}

 nch:=TURQUndo.Create;
 nch.SaveUndo(node,change);
 CurUndoRec.nodechanges.AddObject(nch,node.id);
end;


Procedure SaveLightUndo(lt:TJedLight;change:integer);
var lch:TUndoChange;
begin
 if CurUndoRec=nil then exit;

 if CurUndoRec.ltchanges.FindObjID(lt.id)<>-1 then exit; {already saved}

 lch:=TLightUndo.Create;
 lch.SaveUndo(lt,change);
 CurUndoRec.ltchanges.AddObject(lch,lt.id);
end;

Procedure SaveSecUndo(sec:TJKSector;change:integer;how:integer);
var lch:TUndoChange;
begin
 if CurUndoRec=nil then exit;

 if (how and sc_geo)<>0 then
 if CurUndoRec.scgchanges.FindObjID(sec.id)=-1 then
 begin
  lch:=TSecGeoUndo.Create;
  lch.SaveUndo(sec,change);
  CurUndoRec.scgchanges.AddObject(lch,sec.id);
 end;

 if (how and sc_val)<>0 then
 if CurUndoRec.scvchanges.FindObjID(sec.id)=-1 then
 begin
  lch:=TSecValUndo.Create;
  lch.SaveUndo(sec,change);
  CurUndoRec.scvchanges.AddObject(lch,sec.id);
 end;

end;


Procedure SaveThingUndo(th:TJKThing;change:integer);
var tch:TUndoChange;
begin
 if CurUndoRec=nil then exit;

 if CurUndoRec.thchanges.FindObjID(th.id)<>-1 then exit; {already saved}

 tch:=TThingUndo.Create;
 tch.SaveUndo(th,change);
 CurUndoRec.thchanges.AddObject(tch,th.id);
end;


Procedure SaveCOGUndo(cog:TCOG);
begin
end;

Procedure EndUndoRec;
begin
end;

Function GetUndoRecName:string;
begin
 Result:='';
 if CurUndoRec=nil then exit;
 result:=CurUndoRec.Name;
end;

Procedure ApplyUndo;
var i:integer;
    id:Integer;
    uobj:TUndoChange;
begin
 if CurUndoRec=nil then exit;

 With CurUndoRec do
 begin

 {Undo sec geometry}
 for i:=0 to scgchanges.count-1 do
  begin
   id:=scgchanges.GetObjID(i);
   uobj:=scgchanges.GetObj(i);
   uobj.Undo(id);
  end;

 {Undo sec values}
 for i:=0 to scvchanges.count-1 do
  begin
   id:=scvchanges.GetObjID(i);
   uobj:=scvchanges.GetObj(i);
   uobj.Undo(id);
  end;

  {Undo lights}
  for i:=0 to ltchanges.count-1 do
  begin
   id:=ltchanges.GetObjID(i);
   uobj:=ltchanges.GetObj(i);
   uobj.Undo(id);
  end;

  {Undo things}
  for i:=0 to thchanges.count-1 do
  begin
   id:=thchanges.GetObjID(i);
   uobj:=thchanges.GetObj(i);
   uobj.Undo(id);
  end;

  for i:=0 to nodechanges.count-1 do
  begin
   id:=nodechanges.GetObjID(i);
   uobj:=nodechanges.GetObj(i);
   uobj.Undo(id);
  end;

 end;

 CurUndoRec.Free;
 CurUndoRec:=nil;
 UndoStack.Delete(UndoStack.Count-1);
 if UndoStack.Count<>0 then CurUndoRec:=TUndoRec(UndoStack[UndoStack.Count-1]);

end;

Procedure ClearUndoBuffer;
var i:integer;
begin
 CurUndoRec:=nil;
 for i:=0 to UndoStack.count-1 do
  TUndoRec(UndoStack[i]).Free;
 UndoStack.Clear;
end;

Procedure ClearNodesUndo;
var i:integer;
begin
 CurUndoRec:=nil;
 for i:=UndoStack.count-1 downto 0 do
 if TUndoRec(UndoStack[i]).nodechanges.count<>0 then
 begin
  TUndoRec(UndoStack[i]).Free;
  UndoStack.Delete(i);
 end;
end;


var i:integer;

Initialization
 UndoStack:=TList.Create;

Finalization
begin
 For i:=0 to UndoStack.Count-1 do
  TObject(UndoStack[i]).Free;
 UndoStack.Free;
end;


end.
