unit ZRender;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, Spin, Buttons,
  M_Global, M_Util;

type
 TZBUFFER_CELL = record
  color : Byte;
  invz  : Real;
 end;

type
 TZBUFFER = array[0..319, 0..199] of TZBUFFER_CELL;

type
 T3DPoint = record
  x,y,z : Real;
 end;

type
 T3DVertex = class
  x,y,z : Real;
  Vis   : Integ16; {1 visible; 0 not visible; -1 problem}
  u,v   : Integ16;
  w     : Real;    {w = 1/z ? is necessary for sorting later}
 end;

type T3DPolygon = class
 sc, wl : Integ16; {to get back to DF data if necessary}
 texture: Integ16;
 ptype  : Integ16; {0=floor, 1=ceiling, 2=MID, 3=TOP, 4=BOT}
 numvx  : Integ16;
 first  : Integ16;
 nx,
 ny,
 nz     : Real;    {normal}
 zorder : Real;
 notVis : Boolean;
end;

type
 TRendererSettings = class
  Scale    : Real;
  CenterX,
  CenterY  : Integer;
 end;

type
 TCamera = class
  x,
  z,
  y      : Real;
  height : Real;
  theta  : Real;
  Sector : Integer;
  Layer  : Integer;
 end;

type
  TZRenderer = class(TForm)
    Panel2: TPanel;
    Panel3: TPanel;
    SBXMinus: TSpeedButton;
    SBXPlus: TSpeedButton;
    SBZMinus: TSpeedButton;
    SBZPlus: TSpeedButton;
    SBYMinus: TSpeedButton;
    SBYPlus: TSpeedButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    PanelX: TPanel;
    PanelZ: TPanel;
    PanelY: TPanel;
    Panel5: TPanel;
    Label4: TLabel;
    SBFacingMinus: TSpeedButton;
    SBForward: TSpeedButton;
    SBFacingPlus: TSpeedButton;
    SBStrafeLeft: TSpeedButton;
    SBBackward: TSpeedButton;
    SBStrafeRight: TSpeedButton;
    PanelFacing: TPanel;
    PanelInfo: TPanel;
    PanelLayer: TPanel;
    Panel1: TPanel;
    CBMoreSettings: TCheckBox;
    Panel4: TPanel;
    CBSelect: TComboBox;
    Panel6: TPanel;
    CBBackFaceCulling: TCheckBox;
    PanelSettings: TPanel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    SEMove: TSpinEdit;
    SETurn: TSpinEdit;
    SEStrafe: TSpinEdit;
    SEScale: TSpinEdit;
    RenderBox: TPaintBox;
    procedure SBXMinusMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure CBBackFaceCullingClick(Sender: TObject);
    procedure SEScaleChange(Sender: TObject);
    procedure CBMoreSettingsClick(Sender: TObject);
    procedure CBSelectClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormPaint(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
    procedure InitRenderer;
    procedure CloseRenderer;
    procedure SetRendererSettings(scale : Real);
    function  SetCamera(x,z,h,t : Real) : Boolean;

    procedure CreateLists;
    procedure FreeLists;

    procedure Transform;
    procedure PolyDraw;

    procedure MoveTo2(x,y : Integer);
    procedure LineTo2(x,y : Integer);

    procedure Test;
  end;

var
  ZRenderer            : TZRenderer;
  ZBuffer              : TZBUFFER;
  RENDERER_INITIALIZED : Boolean;
  RendererSettings     : TRendererSettings;
  Camera               : TCamera;

  PolyList,
  VertexList           : TStringList;

implementation

{$R *.DFM}

procedure TZRenderer.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 CloseRenderer;
end;

procedure TZRenderer.FormPaint(Sender: TObject);
begin
 if RENDERER_INITIALIZED then PolyDraw;
end;

procedure TZRenderer.InitRenderer;
begin
 RendererSettings := TRendererSettings.Create;
 SetRendererSettings(SEScale.Value);
 Camera           := TCamera.Create;
 PolyList         := TStringList.Create;
 VertexList       := TStringList.Create;
 CreateLists;
 RENDERER_INITIALIZED := TRUE;
end;

procedure TZRenderer.CloseRenderer;
begin
 FreeLists;
 Camera.Free;
 RendererSettings.Free;
 RENDERER_INITIALIZED := FALSE;
end;

procedure TZRenderer.SetRendererSettings(scale : Real);
begin
 if scale > 0 then
   RendererSettings.Scale := scale;
 RendererSettings.CenterX := RenderBox.Width div 2;
 RendererSettings.centerY := RenderBox.Height div 2;
end;

{SetCamera will return FALSE if the said point is not in a sector
 NOTE that height is **RELATIVE** to the sector floor !!!}
function  TZRenderer.SetCamera(x,z,h,t : Real) : Boolean;
var tmpsc     : integer;
    TheSector : TSector;
begin
 if GetNearestSC(x, z, tmpsc) then
  begin
   TheSector := TSector(MAP_SEC.Objects[tmpsc]);
   Camera.X       := x;
   Camera.Z       := z;
   Camera.Height  := h;
   if Camera.Height < 0 then Camera.Height := 0;
   if TheSector.Floor_Alt + Camera.Height > TheSector.Ceili_Alt then
    Camera.Height := TheSector.Ceili_Alt - TheSector.Floor_Alt;
   Camera.Y       := TheSector.Floor_Alt + Camera.Height;
   Camera.Theta   := t;
   Camera.Sector  := tmpsc;
   Camera.Layer   := TheSector.Layer;
   PanelX.Caption      := PosTrim(Camera.X);
   PanelZ.Caption      := PosTrim(Camera.Z);
   PanelY.Caption      := PosTrim(Camera.Y);
   PanelFacing.Caption := PosTrim(Camera.Theta);
   PanelLayer.caption  := 'SC ' + IntToStr(Camera.Sector) +
                          ' on layer ' + IntToStr(Camera.Layer);
   Result       := TRUE;
  end
 else
  begin
   {invalid camera position, no change made!!!}
   Result := FALSE;
  end;
end;

procedure TZRenderer.SBXMinusMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var tet : Real;
begin
 with Camera do
  begin
   if Sender = SBXMinus then SetCamera(X-SEMove.Value, Z, Height, Theta);
   if Sender = SBXPlus  then SetCamera(X+SEMove.Value, Z, Height, Theta);
   if Sender = SBZMinus then SetCamera(X, Z-SEMove.Value, Height, Theta);
   if Sender = SBZPlus  then SetCamera(X, Z+SEMove.Value, Height, Theta);
   if Sender = SBYMinus then SetCamera(X, Z, Height-1, Theta);
   if Sender = SBYPlus  then SetCamera(X, Z, Height+1, Theta);

   if Sender = SBFacingMinus then
    begin
     tet := Theta - SETurn.Value;
     if tet < 0 then tet := 360 + tet;
     SetCamera(X, Z, Height, tet);
    end;
   if Sender = SBFacingPlus then
    begin
     tet := Theta + SETurn.Value;
     if tet >= 360 then tet := tet - 360;
     SetCamera(X, Z, Height, tet);
    end;

   if Sender = SBBackward then
    SetCamera(X-SEMove.Value * sin(Theta/180*PI), Z-SEMove.Value*cos(Theta/180*PI), Height, Theta);
   if Sender = SBForward  then
    SetCamera(X+SEMove.Value * sin(Theta/180*PI), Z+SEMove.Value*cos(Theta/180*PI), Height, Theta);

   if Sender = SBStrafeLeft then
    SetCamera(X-SEStrafe.Value * cos(Theta/180*PI), Z+SEStrafe.Value*sin(Theta/180*PI), Height, Theta);
   if Sender = SBStrafeRight then
    SetCamera(X+SEStrafe.Value * cos(Theta/180*PI), Z-SEStrafe.Value*sin(Theta/180*PI), Height, Theta);
  end;

  ZRenderer.Invalidate;
end;

procedure TZRenderer.CreateLists;
var sint,
    cost       : Real;
    s,w,v      : Integer;
    TheSector  : TSector;
    TheSector2 : TSector;
    TheWall    : TWall;
    Vertex1,
    Vertex2    : TVertex;
    deltax,
    deltaz     : Real;
    The3DVertex  : T3DVertex;
    The3DPolygon : T3DPolygon;
begin
 PolyList.Clear;
 VertexList.Clear;
 {select what to take into account}
 for s := 0 to MAP_SEC.Count - 1 do
  begin
   TheSector := TSector(MAP_SEC.Objects[s]);
   TheSector.Mark := 0;
  end;

 for s := 0 to MAP_SEC.Count - 1 do
  begin
   TheSector := TSector(MAP_SEC.Objects[s]);
   CASE CBSelect.ItemIndex OF
    0:       TheSector.Mark := 1;
    -1,1:    if TheSector.Layer = Camera.Layer then TheSector.Mark := 1;
    2,3,4,5: if s = Camera.Sector then TheSector.Mark := 1;
    6:       if SC_MULTIS.IndexOf(Format('%4d%4d',[s,s])) <> -1 then TheSector.Mark := 1;
   END;
  end;

 {add adjoining sectors according to depth}
 if (CBSelect.ItemIndex >= 2) and (CBSelect.ItemIndex <= 4) then
  begin
   for s := 0 to MAP_SEC.Count - 1 do
    begin
     TheSector := TSector(MAP_SEC.Objects[s]);
     if TheSector.Mark = 1 then
      begin
       for w := 0 to TheSector.Wl.Count - 1 do
        begin
         TheWall := TWall(TheSector.Wl.Objects[w]);
         if TheWall.Adjoin <> -1 then
          begin
           TheSector2 := TSector(MAP_SEC.Objects[TheWall.Adjoin]);
           TheSector2.Mark := 2;
          end;
        end;
      end;
    end;
  end;

 if (CBSelect.ItemIndex >= 2) and (CBSelect.ItemIndex <= 3) then
  begin
   for s := 0 to MAP_SEC.Count - 1 do
    begin
     TheSector := TSector(MAP_SEC.Objects[s]);
     if TheSector.Mark = 2 then
      begin
       for w := 0 to TheSector.Wl.Count - 1 do
        begin
         TheWall := TWall(TheSector.Wl.Objects[w]);
         if TheWall.Adjoin <> -1 then
          begin
           TheSector2 := TSector(MAP_SEC.Objects[TheWall.Adjoin]);
           TheSector2.Mark := 3;
          end;
        end;
      end;
    end;
  end;

 if (CBSelect.ItemIndex = 2) then
  begin
   for s := 0 to MAP_SEC.Count - 1 do
    begin
     TheSector := TSector(MAP_SEC.Objects[s]);
     if TheSector.Mark = 3 then
      begin
       for w := 0 to TheSector.Wl.Count - 1 do
        begin
         TheWall := TWall(TheSector.Wl.Objects[w]);
         if TheWall.Adjoin <> -1 then
          begin
           TheSector2 := TSector(MAP_SEC.Objects[TheWall.Adjoin]);
           TheSector2.Mark := 4;
          end;
        end;
      end;
    end;
  end;

 for s := 0 to MAP_SEC.Count - 1 do
  begin
   TheSector := TSector(MAP_SEC.Objects[s]);
   if TheSector.Mark = 0 then continue;
    for w := 0 to TheSector.Wl.Count - 1 do
     begin
      TheWall := TWall(TheSector.Wl.Objects[w]);
      Vertex1 := TVertex(TheSector.Vx.Objects[TheWall.left_vx]);
      Vertex2 := TVertex(TheSector.Vx.Objects[TheWall.right_vx]);

      if TheWall.Adjoin = -1 then
       begin
        {wall hasn't got an adjoin, just generate polygon for MID}
        The3DPolygon := T3DPolygon.Create;
        The3DPolygon.sc    := s;
        The3DPolygon.wl    := w;
        The3DPolygon.ptype := 2; {MID}
        The3DPolygon.numvx := 4;
        The3DPolygon.first := VertexList.Count;
        {note that the normal isn't... normalized !}
        The3DPolygon.nx    := -(Vertex1.Z - Vertex2.Z);
        The3DPolygon.ny    := 0;
        The3DPolygon.nz    := (Vertex1.X - Vertex2.X);
        PolyList.AddObject('', The3DPolygon);

        The3DVertex   := T3DVertex.Create;
        The3DVertex.x := Vertex1.X;
        The3DVertex.y := TheSector.Floor_Alt;
        The3DVertex.z := Vertex1.Z;
        VertexList.AddObject('', The3DVertex);

        The3DVertex   := T3DVertex.Create;
        The3DVertex.x := Vertex1.X;
        The3DVertex.y := TheSector.Ceili_Alt;
        The3DVertex.z := Vertex1.Z;
        VertexList.AddObject('', The3DVertex);

        The3DVertex   := T3DVertex.Create;
        The3DVertex.x := Vertex2.X;
        The3DVertex.y := TheSector.Ceili_Alt;
        The3DVertex.z := Vertex2.Z;
        VertexList.AddObject('', The3DVertex);

        The3DVertex   := T3DVertex.Create;
        The3DVertex.x := Vertex2.X;
        The3DVertex.y := TheSector.Floor_Alt;
        The3DVertex.z := Vertex2.Z;
        VertexList.AddObject('', The3DVertex);
       end
      else
       begin
        {wall has adjoin, we'll have to generate polygons for
         TOP and BOT textures (or MID is flag tells it (not done now))}
        TheSector2 := TSector(MAP_SEC.Objects[TheWall.Adjoin]);
        if TheSector.Ceili_Alt > TheSector2.Ceili_Alt then
         begin
          {There is a TOP texture}
          The3DPolygon := T3DPolygon.Create;
          The3DPolygon.sc    := s;
          The3DPolygon.wl    := w;
          The3DPolygon.ptype := 3; {TOP}
          The3DPolygon.numvx := 4;
          The3DPolygon.first := VertexList.Count;
          {note that the normal isn't... normalized !}
          The3DPolygon.nx    := -(Vertex1.Z - Vertex2.Z);
          The3DPolygon.ny    := 0;
          The3DPolygon.nz    := (Vertex1.X - Vertex2.X);
          PolyList.AddObject('', The3DPolygon);

          The3DVertex   := T3DVertex.Create;
          The3DVertex.x := Vertex1.X;
          The3DVertex.y := TheSector2.Ceili_Alt;
          The3DVertex.z := Vertex1.Z;
          VertexList.AddObject('', The3DVertex);

          The3DVertex   := T3DVertex.Create;
          The3DVertex.x := Vertex1.X;
          The3DVertex.y := TheSector.Ceili_Alt;
          The3DVertex.z := Vertex1.Z;
          VertexList.AddObject('', The3DVertex);

          The3DVertex   := T3DVertex.Create;
          The3DVertex.x := Vertex2.X;
          The3DVertex.y := TheSector.Ceili_Alt;
          The3DVertex.z := Vertex2.Z;
          VertexList.AddObject('', The3DVertex);

          The3DVertex   := T3DVertex.Create;
          The3DVertex.x := Vertex2.X;
          The3DVertex.y := TheSector2.Ceili_Alt;
          The3DVertex.z := Vertex2.Z;
          VertexList.AddObject('', The3DVertex);
         end;
        if TheSector.Floor_Alt < TheSector2.Floor_Alt then
         begin
          {There is a BOT texture}
          The3DPolygon := T3DPolygon.Create;
          The3DPolygon.sc    := s;
          The3DPolygon.wl    := w;
          The3DPolygon.ptype := 4; {BOT}
          The3DPolygon.numvx := 4;
          The3DPolygon.first := VertexList.Count;
          {note that the normal isn't... normalized !}
          The3DPolygon.nx    := -(Vertex1.Z - Vertex2.Z);
          The3DPolygon.ny    := 0;
          The3DPolygon.nz    := (Vertex1.X - Vertex2.X);
          PolyList.AddObject('', The3DPolygon);

          The3DVertex   := T3DVertex.Create;
          The3DVertex.x := Vertex1.X;
          The3DVertex.y := TheSector.Floor_Alt;
          The3DVertex.z := Vertex1.Z;
          VertexList.AddObject('', The3DVertex);

          The3DVertex   := T3DVertex.Create;
          The3DVertex.x := Vertex1.X;
          The3DVertex.y := TheSector2.Floor_Alt;
          The3DVertex.z := Vertex1.Z;
          VertexList.AddObject('', The3DVertex);

          The3DVertex   := T3DVertex.Create;
          The3DVertex.x := Vertex2.X;
          The3DVertex.y := TheSector2.Floor_Alt;
          The3DVertex.z := Vertex2.Z;
          VertexList.AddObject('', The3DVertex);

          The3DVertex   := T3DVertex.Create;
          The3DVertex.x := Vertex2.X;
          The3DVertex.y := TheSector.Floor_Alt;
          The3DVertex.z := Vertex2.Z;
          VertexList.AddObject('', The3DVertex);
         end;
       end;
     end;
    end;

 PanelInfo.Caption :=   'Poly: '
                      + IntToStr(PolyList.Count)
                      + ' / Vert: '
                      + IntToStr(VertexList.Count);
end;

procedure TZRenderer.FreeLists;
begin
 VertexList.Free;
 PolyList.Free;
end;

procedure TZRenderer.Transform;
var i           : Integer;
    sint,
    cost        : Real;
    xx,yy,zz    : Real;
    dd          : Real;
    The3DVertex : T3DVertex;
begin
 sint  := sin(Camera.theta/180*PI);
 cost  := cos(Camera.theta/180*PI);

 for i := 0 to VertexList.Count - 1 do
  begin
   The3DVertex  := T3DVertex(VertexList.Objects[i]);
   with The3DVertex do
    begin
     xx := x - Camera.X;
     zz := z - Camera.Z;
     yy := y - Camera.Y;
     w  := sint * xx  + cost * zz;
     if w > 0.00 then
      begin
       Vis := 1;
       try
        u :=  Round(RendererSettings.Scale / w * (cost * xx  - sint * zz)) + RendererSettings.CenterX;
        v := -Round(RendererSettings.Scale / w * yy) + RendererSettings.CenterY;
        if (u > 10000) or (u<-10000) or (v>10000) or (v<-10000) then Vis := -1;
       except
        on EInvalidOp do Vis := -1;
       end;
      end
     else
      begin
       Vis := 0;
      end;
    end; {with The3DVertex do}
  end; {for VertexList}
end;

procedure TZRenderer.PolyDraw;
var p, i  : Integer;
    sint,
    cost         : Real;
    x0,y0        : Real;
    xc,yc        : Integer;
    x1,y1,z1     : Real;
    x2,y2,z2     : Real;
    xx1,yy1,zz1  : Real;
    xx2,yy2,zz2  : Real;
    dd           : Real;
    The3DPolygon : T3DPolygon;
    The3DVertex1 : T3DVertex;
    The3DVertex2 : T3DVertex;
    The3DVertex3 : T3DVertex;
    The3DVertex4 : T3DVertex;
    bfc          : Real;
    TextureMapped : Boolean;
begin

{!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 must describe the rendering pipeline much more clearly
 ie rewrite the all stuff to have nice clean separate functions for
 everything}

 Transform;

 {this is needed only for special cases}
 sint  := sin(Camera.theta/180*PI);
 cost  := cos(Camera.theta/180*PI);

 for p := 0 to PolyList.Count - 1 do
  begin
   The3DPolygon  := T3DPolygon(PolyList.Objects[p]);
   TextureMapped := FALSE;

   { *** backface culling ***}
   with The3DPolygon do
    begin
     The3DVertex1 := T3DVertex(VertexList.Objects[first]);
     bfc := (Camera.X-The3DVertex1.x) * nx +
            (Camera.Y-The3DVertex1.y) * ny +
            (Camera.Z-The3DVertex1.z) * nz;
    end;
   {nota : CBBackFaceCulling.Checked is a property, hence slooooow
           must use a real boolean instead}
   if CBBackFaceCulling.Checked and (bfc < 0) then continue;

   if The3DPolygon.Sc = Camera.Sector then
    RenderBox.Canvas.Pen.Color := 0
   else
    RenderBox.Canvas.Pen.Color := 8421504;

   if not TextureMapped then
   for i := The3DPolygon.first to The3DPolygon.first + The3DPolygon.numvx - 1 do
    begin
     {take the vertices 2 by 2, just watch for the loop back to first one}
     The3DVertex1 := T3DVertex(VertexList.Objects[i]);
     if i <> The3DPolygon.first+The3DPolygon.numvx - 1 then
      The3DVertex2 := T3DVertex(VertexList.Objects[i+1])
     else
      The3DVertex2 := T3DVertex(VertexList.Objects[The3DPolygon.first]);

     {now just draw from 1 => 2, taking special care with
      lines going from a point in front to a point behind}
     if (The3DVertex1.Vis = 1) and (The3DVertex2.Vis = 1) then
      begin
       RenderBox.Canvas.MoveTo(The3DVertex1.u, The3DVertex1.v);
       RenderBox.Canvas.LineTo(The3DVertex2.u, The3DVertex2.v);
      end;

     if (The3DVertex1.Vis = 1) and (The3DVertex2.Vis = 0) then
      begin
       {transform the 2 points}
       with The3DVertex1 do
        begin
         xx1 := x - Camera.X;
         zz1 := z - Camera.Z;
         yy1 := y - Camera.Y;
         x1  := cost * xx1  - sint * zz1;
         y1  := yy1;
         z1  := sint * xx1  + cost * zz1;
        end;
       with The3DVertex2 do
        begin
         xx2 := x - Camera.X;
         zz2 := z - Camera.Z;
         yy2 := y - Camera.Y;
         x2  := cost * xx2  - sint * zz2;
         y2  := yy2;
         z2  := sint * xx2  + cost * zz2;
        end;
       {compute the line passing by the two, then clip it at z = 0}
       try
        {this should be kept complete for head tilting,
         but else could simplify y0 := -z1 + y1
         since (except for vertical edges which can never be
         handled here) all lines have constant Y
         IF THERE IS NO HEAD TILTING
         BTW, z2 = z1 never happens, because this would mean an
         "horizontal" on the projection, and those are either in front
         or behind but not half and half}
          y0 := (-z1) * (y2-y1)/(z2-z1) + y1;
          x0 := (-z1) * (x2-x1)/(z2-z1) + x1;
          xc :=  Round(RendererSettings.Scale * x0) + RendererSettings.CenterX;
          yc := -Round(RendererSettings.Scale * y0) + RendererSettings.CenterY;
          RenderBox.Canvas.MoveTo(The3DVertex1.u, The3DVertex1.v);
          RenderBox.Canvas.LineTo(xc, yc);
       except
        on EZeroDivide do ;
        on EInvalidOp  do ;
       end;
      end;

     if (The3DVertex1.Vis = 0) and (The3DVertex2.Vis = 1) then
      begin
       {transform the 2 points}
       with The3DVertex1 do
        begin
         xx1 := x - Camera.X;
         zz1 := z - Camera.Z;
         yy1 := y - Camera.Y;
         x1  := cost * xx1  - sint * zz1;
         y1  := yy1;
         z1  := sint * xx1  + cost * zz1;
        end;
       with The3DVertex2 do
        begin
         xx2 := x - Camera.X;
         zz2 := z - Camera.Z;
         yy2 := y - Camera.Y;
         x2  := cost * xx2  - sint * zz2;
         y2  := yy2;
         z2  := sint * xx2  + cost * zz2;
        end;
       {compute the line passing by the two, then clip it at z = 0}
       try
          y0 := (-z1) * (y2-y1)/(z2-z1) + y1;
          x0 := (-z1) * (x2-x1)/(z2-z1) + x1;
          xc :=  Round(RendererSettings.Scale * x0) + RendererSettings.CenterX;
          yc := -Round(RendererSettings.Scale * y0) + RendererSettings.CenterY;
          RenderBox.Canvas.MoveTo(The3DVertex2.u, The3DVertex2.v);
          RenderBox.Canvas.LineTo(xc, yc);
       except
        on EZeroDivide do ;
        on EInvalidOp  do ;
       end;
      end;

    end;
  end;
end;

procedure TZRenderer.SEScaleChange(Sender: TObject);
begin
 SetRendererSettings(SEScale.Value);
 ZRenderer.Invalidate;
end;

procedure TZRenderer.CBMoreSettingsClick(Sender: TObject);
begin
 PanelSettings.Visible := CBMoreSettings.Checked;
end;

procedure TZRenderer.CBSelectClick(Sender: TObject);
begin
 FreeLists;
 PolyList         := TStringList.Create;
 VertexList       := TStringList.Create;
 CreateLists;
 Invalidate;
end;

procedure TZRenderer.CBBackFaceCullingClick(Sender: TObject);
begin
 Invalidate;
end;

procedure TZRenderer.Test;
var The3DVertex1 : T3DVertex;
    The3DVertex2 : T3DVertex;
    The3DVertex3 : T3DVertex;
    The3DVertex4 : T3DVertex;
    i,j,k        : Integer;
    du1, dv1     : Integer;
    du2, dv2     : Integer;
    dy           : Integer;
begin
 The3DVertex1 := T3DVertex.Create;
 with The3DVertex1 do
  begin
   u := -100;
   v := -100;
  end;

 The3DVertex2 := T3DVertex.Create;
 with The3DVertex2 do
  begin
   u := -100;
   v := 100;
  end;

 The3DVertex3 := T3DVertex.Create;
 with The3DVertex3 do
  begin
   u := 100;
   v := 50;
  end;

 The3DVertex4 := T3DVertex.Create;
 with The3DVertex4 do
  begin
   u := 100;
   v := -50;
  end;

 RenderBox.Canvas.Pen.Color := 0;
 MoveTo2(The3DVertex1.u, The3DVertex1.v);
 LineTo2(The3DVertex2.u, The3DVertex2.v);
 LineTo2(The3DVertex3.u, The3DVertex3.v);
 LineTo2(The3DVertex4.u, The3DVertex4.v);
 LineTo2(The3DVertex1.u, The3DVertex1.v);
 RenderBox.Canvas.Pen.Color := 8421504;

 du1 := The3DVertex3.u - The3DVertex2.u;
 dv1 := The3DVertex3.v - The3DVertex2.v;
 du2 := The3DVertex4.u - The3DVertex1.u;
 dv2 := The3DVertex4.v - The3DVertex1.v;

 for i := 0 to du1 do
  begin
   {for each point in this range compute the start and end}
   dy := Round(The3DVertex2.v + i * dv1 / du1);
   MoveTo2(The3DVertex2.u + i, dy);
   dy := Round(The3DVertex1.v + i * dv2 / du2);
   LineTo2(The3DVertex2.u + i, dy);
  end;

 RenderBox.Canvas.Pen.Color := 0;
 MoveTo2(The3DVertex1.u, The3DVertex1.v);
 LineTo2(The3DVertex2.u, The3DVertex2.v);
 LineTo2(The3DVertex3.u, The3DVertex3.v);
 LineTo2(The3DVertex4.u, The3DVertex4.v);
 LineTo2(The3DVertex1.u, The3DVertex1.v);
end;

procedure TZRenderer.MoveTo2(x,y : Integer);
var xc, yc : Integer;
begin
 xc :=  x + RendererSettings.CenterX;
 yc := -y + RendererSettings.CenterY;
 RenderBox.Canvas.MoveTo(xc, yc);
end;

procedure TZRenderer.LineTo2(x,y : Integer);
var xc, yc : Integer;
begin
 xc :=  x + RendererSettings.CenterX;
 yc := -y + RendererSettings.CenterY;
 RenderBox.Canvas.LineTo(xc, yc);
end;




end.
