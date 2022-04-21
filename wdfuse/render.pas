unit render;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Buttons, ExtCtrls, StdCtrls, Spin,
  M_Global, M_Util,
  _3d, _3dpoly;

type
 TRendererSettings = class
  Stretched : Boolean;
  Scale     : Real;
  CenterX,
  CenterY   : Integer;
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
  TRenderer = class(TForm)
    RenderBox: TPaintBox;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel5: TPanel;
    PanelX: TPanel;
    PanelZ: TPanel;
    PanelY: TPanel;
    SBXMinus: TSpeedButton;
    SBXPlus: TSpeedButton;
    SBZMinus: TSpeedButton;
    SBZPlus: TSpeedButton;
    SBYMinus: TSpeedButton;
    SBYPlus: TSpeedButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    PanelFacing: TPanel;
    Label4: TLabel;
    SBFacingMinus: TSpeedButton;
    SBFacingPlus: TSpeedButton;
    SBForward: TSpeedButton;
    SBBackward: TSpeedButton;
    SBStrafeLeft: TSpeedButton;
    SBStrafeRight: TSpeedButton;
    PanelSettings: TPanel;
    Label5: TLabel;
    SEMove: TSpinEdit;
    Label6: TLabel;
    SETurn: TSpinEdit;
    Label7: TLabel;
    SEStrafe: TSpinEdit;
    Label8: TLabel;
    SEScale: TSpinEdit;
    Panel7: TPanel;
    PanelLayer: TPanel;
    PanelInfo: TPanel;
    Panel4: TPanel;
    CBSelect: TComboBox;
    Panel6: TPanel;
    CBBackFaceCulling: TCheckBox;
    BNSize: TBitBtn;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormPaint(Sender: TObject);
    procedure SBXMinusMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SEScaleChange(Sender: TObject);
    procedure CBSelectClick(Sender: TObject);
    procedure CBBackFaceCullingClick(Sender: TObject);
    procedure BNSizeClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    procedure WMSize(var Msg: TWMSize); message WM_SIZE;
  public
    { Public declarations }
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
    {procedure Snap;}
  end;

var
  Renderer         : TRenderer;
  RENDERER_INITIALIZED : Boolean;
  RendererSettings : TRendererSettings;
  Camera           : TCamera;

  


implementation

{$R *.DFM}

procedure TRenderer.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 CloseRenderer;
end;

procedure TRenderer.WMSize(var Msg: TWMSize);
begin
 inherited;

 if RENDERER_INITIALIZED then
   SetRendererSettings(RendererSettings.Scale);
end;

procedure TRenderer.FormPaint(Sender: TObject);
begin
 if RENDERER_INITIALIZED then
  PolyDraw;
end;

procedure TRenderer.InitRenderer;
begin
 RendererSettings := TRendererSettings.Create;
 RendererSettings.Stretched := FALSE;
 SetRendererSettings(SEScale.Value);
 Camera           := TCamera.Create;
 PolyList         := TStringList.Create;
 VertexList       := TStringList.Create;
 CreateLists;
 RENDERER_INITIALIZED := TRUE;
end;

procedure TRenderer.CloseRenderer;
begin
 FreeLists;
 Camera.Free;
 RendererSettings.Free;
 RENDERER_INITIALIZED := FALSE;
end;

procedure TRenderer.SetRendererSettings(scale : Real);
begin
 if scale > 0 then
   RendererSettings.Scale := scale;
 RendererSettings.CenterX := RenderBox.Width div 2;
 RendererSettings.centerY := RenderBox.Height div 2;
end;

{SetCamera will return FALSE if the said point is not in a sector
 NOTE that height is **RELATIVE** to the sector floor !!!}
function  TRenderer.SetCamera(x,z,h,t : Real) : Boolean;
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

procedure TRenderer.SBXMinusMouseDown(Sender: TObject;
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

  Renderer.Invalidate;
end;

procedure TRenderer.CreateLists;
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

procedure TRenderer.FreeLists;
begin
 VertexList.Free;
 PolyList.Free;
end;

procedure TRenderer.Transform;
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

     if (w > 0.001) then
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

procedure TRenderer.PolyDraw;
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
    FrustumClip  : Boolean;
begin
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
   if CBBackFaceCulling.Checked and (bfc < 0) then continue;

   { ultra quick frustum clipping along Z=X and Z=-X
     to remove the polygon if entirely outside the frustum }

   {????? this has to be done by reverse transforming the frustum ?????}
   {
   FrustumClip := TRUE;
   for i := The3DPolygon.first to The3DPolygon.first + The3DPolygon.numvx - 1 do
    begin
     The3DVertex1 := T3DVertex(VertexList.Objects[i]);
     if The3DVertex1.Vis = 1 then
      begin
       if (The3DVertex1.u > 0) and (The3DVertex1.u > The3DVertex1.w)
        then FrustumClip := FALSE;
       if (The3DVertex1.u < 0) and (-The3DVertex1.u > The3DVertex1.w)
        then FrustumClip := FALSE;
      end
     else
      FrustumClip := FALSE;
    end;
    if FrustumClip then continue;
    }

   { *** texture mapping ***
    of some polygons, avoid all floors and ceilings !!}
   if (The3DPolygon.ptype >= 2) and (The3DPolygon.Sc = Camera.Sector) then
    begin
    end;

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

procedure TRenderer.SEScaleChange(Sender: TObject);
begin
 SetRendererSettings(SEScale.Value);
 Renderer.Invalidate;
end;

procedure TRenderer.CBSelectClick(Sender: TObject);
begin
 FreeLists;
 PolyList         := TStringList.Create;
 VertexList       := TStringList.Create;
 CreateLists;
 Invalidate;
end;

procedure TRenderer.CBBackFaceCullingClick(Sender: TObject);
begin
 Invalidate;
end;

procedure TRenderer.Test;
var The3DVertex  : T3DVertex;
    The3DPolygon : T3DPolygon;
    i,j,k        : Integer;
    du1, dv1     : Integer;
    du2, dv2     : Integer;
    dy           : Integer;
begin
 FreeLists;
 PolyList         := TStringList.Create;
 VertexList       := TStringList.Create;

 The3DVertex   := T3DVertex.Create;
 The3DVertex.u := -100;
 The3DVertex.v := -100;
 VertexList.AddObject('V', The3DVertex);

 The3DVertex   := T3DVertex.Create;
 The3DVertex.u := -150;
 The3DVertex.v := 110;
 VertexList.AddObject('V', The3DVertex);

 The3DVertex   := T3DVertex.Create;
 The3DVertex.u := 100;
 The3DVertex.v :=  80;
 VertexList.AddObject('V', The3DVertex);

 The3DVertex   := T3DVertex.Create;
 The3DVertex.u := 120;
 The3DVertex.v := -70;
 VertexList.AddObject('V', The3DVertex);

 The3DVertex   := T3DVertex.Create;
 The3DVertex.u := 20;
 The3DVertex.v := -130;
 VertexList.AddObject('V', The3DVertex);

 The3DPolygon := T3DPolygon.Create;
 with The3DPolygon do
  begin
   numvx  := 5;
   first  := 0;
  end;
 PolyList.AddObject('P' , The3DPolygon);

 The3DVertex   := T3DVertex.Create;
 The3DVertex.u := 180;
 The3DVertex.v := -100;
 VertexList.AddObject('V', The3DVertex);

 The3DVertex   := T3DVertex.Create;
 The3DVertex.u := 120;
 The3DVertex.v := -70;
 VertexList.AddObject('V', The3DVertex);

 The3DVertex   := T3DVertex.Create;
 The3DVertex.u :=   20;
 The3DVertex.v := -130;
 VertexList.AddObject('V', The3DVertex);

 The3DPolygon := T3DPolygon.Create;
 with The3DPolygon do
  begin
   numvx  := 3;
   first  := 5;
  end;
 PolyList.AddObject('P' , The3DPolygon);

 The3DVertex   := T3DVertex.Create;
 The3DVertex.u := 120;
 The3DVertex.v := -70;
 VertexList.AddObject('V', The3DVertex);

 The3DVertex   := T3DVertex.Create;
 The3DVertex.u := 100;
 The3DVertex.v :=  80;
 VertexList.AddObject('V', The3DVertex);

 The3DVertex   := T3DVertex.Create;
 The3DVertex.u := 300;
 The3DVertex.v := 0;
 VertexList.AddObject('V', The3DVertex);

 The3DVertex   := T3DVertex.Create;
 The3DVertex.u := 180;
 The3DVertex.v := -100;
 VertexList.AddObject('V', The3DVertex);

 The3DPolygon := T3DPolygon.Create;
 with The3DPolygon do
  begin
   numvx  := 4;
   first  := 8;
  end;

 PolyList.AddObject('P' , The3DPolygon);

 POLY_Simple_VerticalFill(0);
 POLY_Simple_VerticalFill(1);
 POLY_Simple_VerticalFill(2);

 FreeLists;
 PolyList         := TStringList.Create;
 VertexList       := TStringList.Create;
end;

procedure TRenderer.MoveTo2(x,y : Integer);
var xc, yc : Integer;
begin
 xc :=  x + RendererSettings.CenterX;
 yc := -y + RendererSettings.CenterY;
 RenderBox.Canvas.MoveTo(xc, yc);
end;

procedure TRenderer.LineTo2(x,y : Integer);
var xc, yc : Integer;
begin
 xc :=  x + RendererSettings.CenterX;
 yc := -y + RendererSettings.CenterY;
 RenderBox.Canvas.LineTo(xc, yc);
end;

procedure TRenderer.BNSizeClick(Sender: TObject);
begin
 {}
 if BNSize.Caption = '640 x 400' then
  begin
   Renderer.Width    := 663;
   Renderer.Height   := 562;
   RenderBox.Left    := 8;
   RenderBox.Top     := 8;
   RenderBox.Width   := 320;
   RenderBox.Height  := 200;
   BNSize.Caption    := '320 x 200';
   RendererSettings.Stretched := TRUE;
  end;
 if BNSize.Caption = '1280 x 800' then
  begin
   Renderer.Width    := 663;
   Renderer.Height   := 562;
   RenderBox.Left    := 8;
   RenderBox.Top     := 8;
   RenderBox.Width   := 640;
   RenderBox.Height  := 400;
   BNSize.Caption    := '640 x 400';
   RendererSettings.Stretched := TRUE;
  end;
 if BNSize.Caption = '320 x 200' then
  begin
   Renderer.Width    := 1350;
   Renderer.Height   := 890;
   RenderBox.Left    := 8;
   RenderBox.Top     := 8;
   RenderBox.Width   := 1280;
   RenderBox.Height  := 800;
   BNSize.Caption    := '1280 x 800';
   RendererSettings.Stretched := FALSE;
  end;

 if RENDERER_INITIALIZED then
   SetRendererSettings(RendererSettings.Scale);
end;

procedure TRenderer.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if Shift = [] then
    Case Key of
      $44 {VK_D} : {Snap};
      $49 {VK_I} : SBXMinusMouseDown(SBForward,     mbLeft, [ssAlt], 0, 0);
      $4A {VK_J} : SBXMinusMouseDown(SBFacingMinus, mbLeft, [ssAlt], 0, 0);
      $4B {VK_K} : SBXMinusMouseDown(SBBackward,    mbLeft, [ssAlt], 0, 0);
      $4C {VK_L} : SBXMinusMouseDown(SBFacingPlus,  mbLeft, [ssAlt], 0, 0);

      {add auto strafe keys : take care of AZERTY and QWERTY
       keyboards by setting both W and Z to strafe left}
      $57 {VK_W} : SBXMinusMouseDown(SBStrafeLeft,  mbLeft, [ssAlt], 0, 0);
      $5A {VK_Z} : SBXMinusMouseDown(SBStrafeLeft,  mbLeft, [ssAlt], 0, 0);
      $58 {VK_X} : SBXMinusMouseDown(SBStrafeRight, mbLeft, [ssAlt], 0, 0);
    end;

 if Shift = [ssAlt] then
    Case Key of
      $4A {VK_J} : SBXMinusMouseDown(SBStrafeLeft,  mbLeft, [ssAlt], 0, 0);
      $4C {VK_L} : SBXMinusMouseDown(SBStrafeRight, mbLeft, [ssAlt], 0, 0);
    end;
end;

(*
procedure TRenderer.Snap;
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
    FrustumClip  : Boolean;
begin
 Transform;

 {this is needed only for special cases}
 sint  := sin(Camera.theta/180*PI);
 cost  := cos(Camera.theta/180*PI);

 with Camera do
 Memo.Lines.Add(Format('Camera XYZ Angle = %5.2f %5.2f %5.2f %5.2f' , [x,y,z,theta]));


 for p := 0 to PolyList.Count - 1 do
  begin
   Memo.Lines.Add('');
   Memo.Lines.Add(Format('Polygon %d',[p]));
   The3DPolygon  := T3DPolygon(PolyList.Objects[p]);

   for i := The3DPolygon.first to The3DPolygon.first + The3DPolygon.numvx - 1 do
    begin
     The3DVertex1 := T3DVertex(VertexList.Objects[i]);
     with The3Dvertex1 do
     Memo.Lines.Add(Format('Vertex %d X Y Z = (%5.2f, %5.2f, %5.2f) u v w = (%d, %d, %7.3f)',
                           [i, x, y, z, u, v, w]));
    end;
  end;


end;
*)

end.
