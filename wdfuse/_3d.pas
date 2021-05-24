unit _3d;
{*******************************************************************}
{ _3d     : base TYPEs for all 3D routines.                         }
{ Copyright (c) 1996 Yves Borckmans                                 }
{*******************************************************************}

interface
uses Classes;

TYPE Integ16 =
{$IFNDEF WDF32}
               Integer;
{$ELSE}
               SmallInt;
{$ENDIF}


type
 T3DPoint = record
  x,y,z : Real;
 end;

type
 T3DVertex = class
  x,y,z : Real;
  u,v   : Integ16; {projected x and y}
  w     : Real;    {transformed z, necessary for sorting later}
  Vis   : Integ16; {1 visible; 0 not visible; -1 problem}
 end;

type T3DPolygon = class
 sc, wl : Integ16; {to get back to DF data if necessary,
                    for testing purposes only}
 texture: Integ16; {offset in a textures list}
 light  : Integ16; {must include sector ambient + wall light}
 ptype  : Integ16; {0=floor, 1=ceiling,
                    2=MID, 3=TOP, 4=BOT, 5=SIGN}
 numvx  : Integ16; {number of vertices}
 first  : Integ16; {first vertex in vertices list}
 nx,
 ny,
 nz     : Real;    {normal}
 zorder : Real;
 notVis : Boolean; {polygon has been excluded from vis list}
end;

VAR
 PolyList,
 VertexList       : TStringList;

implementation

end.
