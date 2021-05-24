unit _3dpoly;
{*******************************************************************}
{ _3dpoly : 3D Polygons drawing functions.                          }
{ Copyright (c) 1996 Yves Borckmans                                 }
{*******************************************************************}

interface
uses _3d,      {for TYPE definitions}
     Classes,  {for TStringList}
     WinTypes, {for Win API drawing functions only, removed later}
     WinProcs; {for Win API drawing functions only, removed later}

function  POLY_Simple_VerticalFill(polygon : Integer) : Integer;
procedure POLY_ScanEdge(X1, Y1, X2, Y2, SetYStart, SkipFirst : Integer;
                        VAR EdgePointPtr : Integer);
procedure POLY_DrawVerticalLineList;

Type
 TPOLY_Segment = class
  YStart,
  YEnd          : Integer;
 end;

var
 POLY_FirstVX,
 POLY_LastVX,
 POLY_NumVX      : Integer;       { this will avoid passing parameters      }
 POLY_Segments   : TStringList;   { list of segments to draw                }
 POLY_XStart     : Integer;

implementation

uses render;   {for drawing purposes only}

procedure INDEX_FORWARD(VAR Index : Integer);
begin
 Inc(Index);
 if Index > POLY_LastVX then Index := POLY_FirstVX;
end;

procedure INDEX_BACKWARD(VAR Index : Integer);
begin
 Dec(Index);
 if Index < POLY_FirstVX then Index := POLY_LastVX;
end;

procedure INDEX_MOVE(VAR Index : Integer; Direction : Integer);
begin
 if Direction > 0 then
  begin
   Inc(Index);
   if Index > POLY_LastVX then Index := POLY_FirstVX;
  end
 else
  begin
   Dec(Index);
   if Index < POLY_FirstVX then Index := POLY_LastVX;
  end;
end;

{ This function is very much inspired by listing 21.1 in Michel Abrash's    }
{ excellent _ZEN of Graphics Programming_                                   }
{ I just draw top => bottom instead of left => right for constant Z reasons }
{ Returns  1 = success                                                      }
{          0 = nothing to do (degenerated polygons)                         }
function  POLY_Simple_VerticalFill(polygon : Integer) : Integer;
var  The3DPolygon : T3DPolygon;   { The polygon                             }
     The3DVertex  : T3DVertex;    { A vertex                                }
     The3DVertex2 : T3DVertex;    { A vertex                                }
     i,j,k        : Integer;      { loop counters                           }
     MinL,                        { bottommost left vertex                  }
     MaxL,                        { topmost left vertex                     }
     RightVx      : Integer;      { most right vertex                       }
     MinX,                        { min X of scan range                     }
     MaxX         : Integer;      { max X of scan range                     }
     LeftIsFlat   : Integer;      { is leftmost part of polygon an edge ?   }
                                  { 1 if so, 0 else (simple vertex)         }
     TopEdgeDir   : Integer;      { does the top edge run like the vertices }
                                  { array (1) or the contrary (-1) ?        }
     SkipFirst    : Integer;      { flag used to skip one line if necessary }
     NextIndex,                   { an index to traverse the vertices list  }
     PrevIndex    : Integer;      { an index to traverse the vertices list  }
     CurrIndex    : Integer;      { an index to traverse the vertices list  }
     temp         : Integer;      { used in exchanging two variables        }
     EdgePointPtr : Integer;      { "pointer" in the list of segments       }
     DeltaXN,
     DeltaYN,
     DeltaXP,
     DeltaYP      : Integer;      { used to compute slopes                  }
     AReal        : Real;
begin
 {Get the polygon from the polygon list}
 The3DPolygon  := T3DPolygon(PolyList.Objects[polygon]);

 {not a polygon!}
 if The3DPolygon.numvx < 3 then
  begin
   Result      := 0;
   exit;
  end;

 POLY_NumVX    := The3DPolygon.numvx;
 POLY_FirstVX  := The3DPolygon.first;
 POLY_LastVX   := The3DPolygon.first + The3DPolygon.numvx - 1;

 {first find our left and right scan range}
 The3DVertex   := T3DVertex(VertexList.Objects[POLY_FirstVX]);
 MinL          := POLY_FirstVX;
 RightVx       := POLY_FirstVX;
 MinX          := The3DVertex.u;
 MaxX          := The3DVertex.u;
 for i := POLY_FirstVX + 1 to POLY_LastVX do
  begin
   The3DVertex := T3DVertex(VertexList.Objects[i]);
   if The3DVertex.u < MinX then
    begin
     MinL := i;
     MinX := The3DVertex.u;
    end
   else
   if The3DVertex.u > MaxX then
    begin
     RightVx := i;
     MaxX := The3DVertex.u;
    end;
  end;

 {polygon has 0 width}
 if MinX = MaxX then
  begin
   Result      := 0;
   exit;
  end;

 {so we now have range (MinX,MaxX),
  with a left vertex in MinL and a right vertex in RightVx
  May be more than one, so find the upper left, and upper right}

 MaxL := MinL;

 repeat
  INDEX_BACKWARD(MinL);
  The3DVertex := T3DVertex(VertexList.Objects[MinL]);
 until The3DVertex.u <> MinX;
 INDEX_FORWARD(MinL);
 The3DVertex := T3DVertex(VertexList.Objects[MinL]);

 repeat
  INDEX_FORWARD(MaxL);
  The3DVertex2 := T3DVertex(VertexList.Objects[MaxL]);
 until The3DVertex2.u <> MinX;
 INDEX_BACKWARD(MaxL);
 The3DVertex2 := T3DVertex(VertexList.Objects[MaxL]);

 if (The3DVertex.v <> The3DVertex2.v) then
  LeftIsFlat := 1
 else
  LeftIsFlat := 0;

 {now, find in which direction to travel the top and bottom edges
  (upper left=>upper right and lower left=>lower right, respectively)
  in the list of vertices}

 { assume top edge runs same direction as vertex array }
 TopEdgeDir := 1;

 if (LeftIsFlat = 1) then
  begin
   {just see which of MinL or MaxL is topmost}
   if The3DVertex.v > The3DVertex2.v then
    begin
     { it seems that we assumed wrong, so reverse... }
     TopEdgeDir := -1;
     temp       := MinL;
     MinL       := MaxL;
     MaxL       := temp;
    end;
  end
 else
  begin
   { now, this is a bit more difficult, lets examine the next and
    previous points using our assumption}

   The3DVertex  := T3DVertex(VertexList.Objects[MinL]);
   PrevIndex    := MinL;
   INDEX_BACKWARD(PrevIndex);
   The3DVertex2 := T3DVertex(VertexList.Objects[PrevIndex]);
   DeltaXP      := The3DVertex2.u - The3DVertex.u;
   DeltaYP      := The3DVertex2.v - The3DVertex.v;

   The3DVertex  := T3DVertex(VertexList.Objects[MaxL]);
   NextIndex    := MaxL;
   INDEX_FORWARD(NextIndex);
   The3DVertex2 := T3DVertex(VertexList.Objects[NextIndex]);
   DeltaXN      := The3DVertex2.u - The3DVertex.u;
   DeltaYN      := The3DVertex2.v - The3DVertex.v;

   AReal        := 1.0;
   AReal        := AReal * DeltaXN * DeltaYP - AReal * DeltaYN * DeltaXP;

   { if the actual slopes don't agree with what we assumed just reverse ! }
   if AReal < 0 then
    begin
     TopEdgeDir := -1;
     temp       := MinL;
     MinL       := MaxL;
     MaxL       := temp;
    end;
  end;

 { polygon has zero drawable width }
 if (MaxX - MinX - 1 + LeftIsFlat) <= 0 then
  begin
   Result      := 0;
   exit;
  end;

 { On to creating the segments now }
 POLY_Segments  := TStringList.Create; {could perhaps use a TList instead}
 POLY_XStart    := MinX - 1 + LeftIsFlat;

 EdgePointPtr := 0;
 PrevIndex := MaxL;
 CurrIndex := MaxL;
 SkipFirst := 1 - LeftIsFlat;

 {scan convert each line in the top edge from left to right}
 repeat
  INDEX_MOVE(CurrIndex, TopEdgeDir);
  The3DVertex  := T3DVertex(VertexList.Objects[PrevIndex]);
  The3DVertex2 := T3DVertex(VertexList.Objects[CurrIndex]);
  POLY_ScanEdge(The3DVertex.u,  The3DVertex.v,
                The3DVertex2.u, The3DVertex2.v,
                0, SkipFirst, EdgePointPtr);
  PrevIndex := CurrIndex;
  SkipFirst := 0;
 until CurrIndex = RightVx;

 EdgePointPtr := 0;
 PrevIndex := MinL;
 CurrIndex := MinL;
 SkipFirst := 1 - LeftIsFlat;

 {scan convert each line in the bottom edge from left to right}
 repeat
  INDEX_MOVE(CurrIndex, -TopEdgeDir);
  The3DVertex  := T3DVertex(VertexList.Objects[PrevIndex]);
  The3DVertex2 := T3DVertex(VertexList.Objects[CurrIndex]);
  POLY_ScanEdge(The3DVertex.u,  The3DVertex.v-1,
                The3DVertex2.u, The3DVertex2.v-1,
                1, SkipFirst, EdgePointPtr);
  PrevIndex := CurrIndex;
  SkipFirst := 0;
 until CurrIndex = RightVx;

 { finally, draw the list of segments }
 POLY_DrawVerticalLineList;

 Result := 1;
end;

procedure POLY_ScanEdge(X1, Y1, X2, Y2, SetYStart, SkipFirst : Integer;
                        VAR EdgePointPtr : Integer);
var X, DeltaX, DeltaY  : Integer;
    InverseSlope       : Real;
    TempR              : Real;
    PolySeg            : TPOLY_Segment;
begin
 DeltaX := X2 - X1;
 DeltaY := Y2 - Y1;

 if DeltaX <= 0 then exit;

 InverseSlope := DeltaY / DeltaX;

 for x := X1 + SkipFirst to X2 - 1 do
  begin
   if SetYStart = 0 then
    begin
     PolySeg := TPOLY_Segment.Create;
     TempR   := (x-X1) * InverseSlope;
     { the Ceil function is mising in DELPHI, so improvise... }
     if TempR < 0 then
      PolySeg.YStart := Y1 + Trunc(TempR - 0.5)
     else
      PolySeg.YStart := Y1 + Trunc(TempR + 0.5);
     POLY_Segments.AddObject('S', PolySeg);
    end
   else
    begin
     PolySeg := TPOLY_Segment(POLY_Segments.Objects[EdgePointPtr]);
     TempR   := (x-X1) * InverseSlope;
     { the Ceil function is mising in DELPHI, so improvise... }
     if TempR < 0 then
      PolySeg.YEnd := Y1 + Trunc(TempR - 0.5)
     else
      PolySeg.YEnd := Y1 + Trunc(TempR + 0.5);
     Inc(EdgePointPtr);
    end;
  end;
end;

procedure POLY_DrawVerticalLineList;
var i,j       : Integer;
    PolySeg   : TPOLY_Segment;
    TheHandle : THandle;
begin
 for i := 0 to POLY_Segments.Count - 1 do
  begin
   PolySeg := TPOLY_Segment(POLY_Segments.Objects[i]);
   { draw from (POLY_XStart, PolySeg.YStart) to (POLY_XStart, PolySeg.YEnd) }

   { using MoveTo LineTo generates gaps, because LineTo doesn't
     draw the last pixel !!
     Anyway, we need pixel by pixel for texture mapping, so it isn't
     really a problem                                                       }
   {
   Renderer.MoveTo2(POLY_XStart + i, PolySeg.YStart);
   Renderer.LineTo2(POLY_XStart + i, PolySeg.YEnd);
   }

   TheHandle := Renderer.RenderBox.Canvas.Handle;
   for j := PolySeg.YStart to PolySeg.YEnd do
    SetPixel(TheHandle,
             RendererSettings.CenterX + POLY_XStart + i,
             RendererSettings.CenterY - j,
             $01000000);
  end;

 POLY_Segments.Free;
end;


end.

