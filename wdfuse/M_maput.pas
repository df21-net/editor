unit M_maput;

interface
uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Buttons, ExtCtrls, IniFiles, Menus,
  StdCtrls, FileCtrl, Grids,
  _Math, _Strings,
  M_Global, M_Util,   M_io, M_Progrs, M_smledt, M_Multi,
  M_Editor, M_SCedit, M_WLedit, M_VXedit, M_OBedit, System.Math;

procedure DO_Switch_To_SC_Mode;
procedure DO_Switch_To_WL_Mode;
procedure DO_Switch_To_VX_Mode;
procedure DO_Switch_To_OB_Mode;

procedure DO_Scroll_Up;
procedure DO_Scroll_Down;
procedure DO_Scroll_Left;
procedure DO_Scroll_Right;
procedure DO_Scroll_UpUp;
procedure DO_Scroll_DownDown;
procedure DO_Scroll_LeftLeft;
procedure DO_Scroll_RightRight;

procedure DO_Layer_Up;
procedure DO_Layer_Down;
procedure DO_Layer_OnOff;

procedure DO_OBShadow_OnOff;

procedure DO_Zoom_In;
procedure DO_Zoom_Out;
procedure DO_Zoom_None;

procedure DO_Grid_In;
procedure DO_Grid_Out;
procedure DO_Grid_OnOff;
procedure DO_Grid_8;

procedure DO_GetMapLimits(VAR minX, minY, minZ, maxX, maxY, maxZ : Real);
procedure DO_Center_Map;
procedure DO_Set_ScrollBars_Ranges(Left, Right, Bottom, Up : Integer);

procedure DO_Center_On_Cursor;
procedure DO_Center_On_CurrentObject;

procedure DO_Next_SC;
procedure DO_Prev_SC;
procedure DO_Next_WL;
procedure DO_Prev_WL;
procedure DO_Next_VX;
procedure DO_Prev_VX;
procedure DO_Next_OB;
procedure DO_Prev_OB;

procedure DO_Edit_Short_Text_File(txt : TFileName);

procedure DO_SetMAP_TYPENormal;
procedure DO_SetMAP_TYPELight;
procedure DO_SetMAP_TYPEDamage;
procedure DO_SetMAP_TYPE2ndAltitude;
procedure DO_SetMAP_TYPESkyPit;
procedure DO_SetMap_TYPESectorFill;

implementation
uses Mapper;

procedure DO_Switch_To_SC_Mode;
begin
  if MAP_MODE <> MM_SC then
    begin
      MapWindow.SpeedButtonSC.Down := TRUE;
      MAP_MODE  := MM_SC;
      VX_HILITE := 0;
      WL_HILITE := 0;

      MapWindow.ModeObjects.Checked  := FALSE;
      MapWindow.ModeVertices.Checked := FALSE;
      MapWindow.ModeWalls.Checked    := FALSE;
      MapWindow.ModeSectors.Checked  := TRUE;
      MapWindow.EditAdjoin.Enabled := FALSE;
      MapWindow.EditStitchLeft.Enabled := FALSE;
      MapWindow.EditStitchRight.Enabled := FALSE;
      MapWindow.EditUnAdjoin.Enabled := FALSE;
      MapWindow.EditExtrude.Enabled := FALSE;
      MapWindow.PanelEditMode.Caption := 'SECTOR';

      ObjectEditor.Hide;
      VertexEditor.Hide;
      WallEditor.Hide;
      SectorEditor.Show;
      DO_Fill_SectorEditor;

      MapWindow.Caption := 'WDFUSE ' +  WDFUSE_VERSION + ' - ' + LowerCase(PROJECTFile) + ' : SECTORS';
      MapWindow.Map.Invalidate;
      MapWindow.SetFocus;
    end;
end;

procedure DO_Switch_To_WL_Mode;
begin
  { ne pas oublier les transferts de multiselection }
  if MAP_MODE <> MM_WL then
    begin
      { multiselection transfer }
      CASE MAP_MODE of
       MM_SC : DO_Convert_MultiSC_MultiWL;
      END;

      if MAP_MODE = MM_VX then
       begin
        if not GetWLfromLeftVX(SC_HILITE, VX_HILITE , WL_HILITE) then
         WL_HILITE := 0;
       end;
      MAP_MODE := MM_WL;
      MapWindow.SpeedButtonWL.Down := TRUE;

      MapWindow.ModeObjects.Checked  := FALSE;
      MapWindow.ModeVertices.Checked := FALSE;
      MapWindow.ModeWalls.Checked    := TRUE;
      MapWindow.ModeSectors.Checked  := FALSE;
      MapWindow.EditAdjoin.Enabled := TRUE;
      MapWindow.EditUnAdjoin.Enabled := TRUE;
      MapWindow.EditExtrude.Enabled := TRUE;
      MapWindow.PanelEditMode.Caption := 'WALL';
      if WL_MULTIS.Count > 1 then
       begin
        MapWindow.EditStitchLeft.Enabled := FALSE;
        MapWindow.EditStitchRight.Enabled := FALSE;
       end
      else
       begin
        MapWindow.EditStitchLeft.Enabled := TRUE;
        MapWindow.EditStitchRight.Enabled := TRUE;
       end;

      ObjectEditor.Hide;
      VertexEditor.Hide;
      SectorEditor.Hide;
      WallEditor.Show;
      DO_Fill_WallEditor;
      MapWindow.Caption := 'WDFUSE ' +  WDFUSE_VERSION + ' - '+ LowerCase(PROJECTFile) + ' : WALLS';
      MapWindow.Map.Invalidate;
      MapWindow.SetFocus;
    end;
end;

procedure DO_Switch_To_VX_Mode;
var TheSector           : TSector;
    TheWall             : TWall;
begin
  if MAP_MODE <> MM_VX then
    begin
      { multiselection transfer }
      CASE MAP_MODE of
       MM_SC : DO_Convert_MultiSC_MultiVX;
       MM_WL : DO_Convert_MultiWL_MultiVX;
      END;

      if MAP_MODE = MM_WL then
       begin
        TheSector := TSector(MAP_SEC.Objects[SC_HILITE]);
        TheWall := TWall(TheSector.Wl.Objects[WL_HILITE]);
        VX_HILITE := TheWall.left_vx;
       end;

      MAP_MODE := MM_VX;
      MapWindow.SpeedButtonVX.Down := TRUE;

      MapWindow.ModeObjects.Checked  := FALSE;
      MapWindow.ModeVertices.Checked := TRUE;
      MapWindow.ModeWalls.Checked    := FALSE;
      MapWindow.ModeSectors.Checked  := FALSE;
      MapWindow.EditAdjoin.Enabled := FALSE;
      MapWindow.EditUnAdjoin.Enabled := FALSE;
      MapWindow.EditExtrude.Enabled := FALSE;
      MapWindow.PanelEditMode.Caption := 'VERTEX';

      ObjectEditor.Hide;
      WallEditor.Hide;
      SectorEditor.Hide;
      VertexEditor.Show;
      DO_Fill_VertexEditor;
      MapWindow.Caption := 'WDFUSE ' +  WDFUSE_VERSION + ' - ' + LowerCase(PROJECTFile) + ' : VERTICES';
      MapWindow.Map.Invalidate;
      MapWindow.SetFocus;
    end;
end;

procedure DO_Switch_To_OB_Mode;
begin
  if MAP_MODE <> MM_OB then
    begin
      { multiselection transfer }
      CASE MAP_MODE of
       MM_SC : DO_Convert_MultiSC_MultiOB;
      END;

      MapWindow.SpeedButtonOB.Down := TRUE;
      MAP_MODE := MM_OB;

      MapWindow.ModeObjects.Checked  := TRUE;
      MapWindow.ModeVertices.Checked := FALSE;
      MapWindow.ModeWalls.Checked    := FALSE;
      MapWindow.ModeSectors.Checked  := FALSE;
      MapWindow.EditAdjoin.Enabled := FALSE;
      MapWindow.EditUnAdjoin.Enabled := FALSE;
      MapWindow.EditExtrude.Enabled := FALSE;
      MapWindow.PanelEditMode.Caption := 'OBJECT';

      WallEditor.Hide;
      SectorEditor.Hide;
      VertexEditor.Hide;
      ObjectEditor.Show;
      DO_Fill_ObjectEditor;
      MapWindow.Caption := 'WDFUSE ' +  WDFUSE_VERSION + ' - ' + LowerCase(PROJECTFile) + ' : OBJECTS';
      MapWindow.Map.Invalidate;
      MapWindow.SetFocus;
    end;
end;

procedure DO_Scroll_Up;
begin
  if MapWindow.SetZOffset(Zoffset + Trunc(1+25/scale)) then
   MapWindow.Map.Invalidate;
end;

procedure DO_Scroll_Down;
begin
  if MapWindow.SetZOffset(Zoffset - Trunc(1+25/scale)) then
   MapWindow.Map.Invalidate;
end;

procedure DO_Scroll_Left;
begin
  if MapWindow.SetXOffset(Xoffset - Trunc(1+25/scale)) then
   MapWindow.Map.Invalidate;
end;

procedure DO_Scroll_Right;
begin
  if MapWindow.SetXOffset(Xoffset + Trunc(1+25/scale)) then
   MapWindow.Map.Invalidate;
end;

procedure DO_Scroll_UpUp;
begin
  if MapWindow.SetZOffset(Zoffset + Trunc(1+100/scale)) then
   MapWindow.Map.Invalidate;
end;

procedure DO_Scroll_DownDown;
begin
  if MapWindow.SetZOffset(Zoffset - Trunc(1+100/scale)) then
   MapWindow.Map.Invalidate;
end;

procedure DO_Scroll_LeftLeft;
begin
  if MapWindow.SetXOffset(Xoffset - Trunc(1+100/scale)) then
   MapWindow.Map.Invalidate;
end;

procedure DO_Scroll_RightRight;
begin
  if MapWindow.SetXOffset(Xoffset + Trunc(1+100/scale)) then
   MapWindow.Map.Invalidate;
end;

procedure DO_Layer_Up;
begin
  if LAYER < LAYER_MAX then
    begin
      Inc(LAYER);
      MapWindow.PanelLayer.Caption := IntToStr(LAYER);
      MapWindow.PanelMapLayer.Caption := IntToStr(LAYER);{// added by Dl 11/nov/96  }
      MapWindow.LScrollBar.Position := LAYER;
      MapWindow.Map.Invalidate;
    end;
end;

procedure DO_Layer_Down;
begin
  if LAYER > LAYER_MIN then
    begin
      Dec(LAYER);
      MapWindow.PanelLayer.Caption := IntToStr(LAYER);
      MapWindow.PanelMapLayer.Caption := IntToStr(LAYER); { // added by Dl 11/nov/96}
      MapWindow.LScrollBar.Position := LAYER;
      MapWindow.Map.Invalidate;
    end;
end;

procedure DO_Layer_OnOff;
begin
  SHADOW := not SHADOW;
  if SHADOW then
    begin
     MapWindow.PanelMapLayer.Font.Color := clRed; {//DL nov/11/96 }
     MapWindow.ShowAllLayer.Checked := True;
    end
  else
    begin
     MapWindow.PanelMapLayer.Font.Color := clBlack; {//DL nov/11/96 }
     //MapWindow.ModeShadow.Checked := SHADOW;
     MapWindow.ShowAllLayer.Checked := False;
    end;
  MapWindow.Map.Invalidate;
end;

procedure DO_OBShadow_OnOff;
begin
  OBSHADOW := not OBSHADOW;
  if OBSHADOW then
  {//  MapWindow.PanelOBLayer.Font.Color := clRed }
  MapWindow.Panel1OBLayer.Font.Color := clRed    {//DL nov/96 }
  else
  {//  MapWindow.PanelOBLayer.Font.Color := clBlack;}
    MapWindow.Panel1OBLayer.Font.Color := clBlack;
  MapWindow.ModeObjectShadow.Checked := OBSHADOW; {// DL/NOV/96}
  MapWindow.Map.Invalidate;
end;

procedure DO_Zoom_In;
begin
  if Scale < 128 then
    begin
      if ZoomOutLock then
        ZoomOutLock := False;

      dec(GRID_OFFSET);
      Scale := Scale * Sqrt(2);
      MapWindow.PanelZoom.Caption := Format('%-6.3f', [Scale]);
      MapWindow.HScrollBar.SmallChange := Trunc(1+25/scale);
      MapWindow.HScrollBar.LargeChange := Trunc(1+100/scale);
      MapWindow.VScrollBar.SmallChange := Trunc(1+25/scale);
      MapWindow.VScrollBar.LargeChange := Trunc(1+100/scale);
      MapWindow.Map.Invalidate;
    end
  else
    begin
      if ZoomInLock then exit;
      ZoomInLock := True;
      showmessage('Maximum Zoom In Reached!');
    end;
end;

procedure DO_Zoom_Out;
begin

  if Scale > 0.05 then
    begin
      if ZoomInLock then
        ZoomInLock := False;
      inc(GRID_OFFSET);
      Scale := Scale / Sqrt(2);
      MapWindow.PanelZoom.Caption := Format('%-6.3f', [Scale]);
      MapWindow.HScrollBar.SmallChange := Trunc(1+25/scale);
      MapWindow.HScrollBar.LargeChange := Trunc(1+100/scale);
      MapWindow.VScrollBar.SmallChange := Trunc(1+25/scale);
      MapWindow.VScrollBar.LargeChange := Trunc(1+100/scale);
      MapWindow.Map.Invalidate;
    end
  else
    begin
      if ZoomOutLock then exit;
      ZoomOutLock := True;
      showmessage('Maximum Zoom Out Reached!');

    end;
end;

procedure DO_Zoom_None;
begin
  if Scale <> 1 then
    begin
      Scale := 1;
      GRID_OFFSET := 4;
      MapWindow.PanelZoom.Caption := '1,000';
      MapWindow.HScrollBar.SmallChange := Trunc(1+25/scale);
      MapWindow.HScrollBar.LargeChange := Trunc(1+100/scale);
      MapWindow.VScrollBar.SmallChange := Trunc(1+25/scale);
      MapWindow.VScrollBar.LargeChange := Trunc(1+100/scale);
      MapWindow.Map.Invalidate;
    end;
end;

procedure DO_Grid_In;
begin
  if Grid < 256 then
    begin
      Grid := 2 * Grid;
      MapWindow.PanelGrid.Caption := FloatToStr(Grid);
      if GridON then MapWindow.Map.Invalidate;
    end;
end;

procedure DO_Grid_Out;
begin
  if Grid > 0.125 then
    begin
      Grid := Grid / 2.0;
      MapWindow.PanelGrid.Caption := FloatToStr(Grid);
      if GridON then MapWindow.Map.Invalidate;
    end
  else
    showmessage('Cannot make the grid any smaller!')
end;

procedure DO_Grid_OnOff;
begin
  GridON := not GridON;
  if GridON then
    MapWindow.PanelGrid.Font.Color := clRed
  else
    MapWindow.PanelGrid.Font.Color := clBlack;
  MapWindow.GridOnOff1.Checked := GridON;
  MapWindow.Map.Invalidate;
end;

procedure DO_Grid_8;
begin
  if Grid <> 8 then
    begin
      if scale * Power(2,GRID_OFFSET) > 8 then
        showmessage('Cannot set grid to 8 at this Zoom Level. Please Zoom in!')
      else if scale * Power(2,GRID_OFFSET+3) < 8 then
        showmessage('Cannot set grid to 8 at this Zoom Level. Please Zoom Out!')
      else
        begin
          Grid := 8;
          MapWindow.PanelGrid.Caption := '8';
          if GridON then MapWindow.Map.Invalidate;
        end;
    end;
end;

procedure DO_Center_Map;
var minX,
    minY,
    minZ,
    maxX,
    maxY,
    maxZ      : Real;
begin
  DO_GetMapLimits(minX, minY, minZ, maxX, maxY, maxZ);
  Xoffset := Round((minX + maxX) / 2);
  Zoffset := Round((minZ + maxZ) / 2);
  // TODO(azurda): This does not play nicely.
  // DO_Set_ScrollBars_Ranges(round(minX), round(maxX), round(minZ), round(maxZ));
  MapWindow.Map.Invalidate;
end;

procedure DO_Set_ScrollBars_Ranges(Left, Right, Bottom, Up : Integer);
var HLeft, HRight,
    Vup, Vbottom   : Integer;
begin
 HLeft   := Left;
 HRight  := Right;
 Vup     := -Up;
 Vbottom := -Bottom;
 MapWindow.HScrollBar.SetParams(XOffset, HLeft, HRight);
 MapWindow.VScrollBar.SetParams(-ZOffset, Vup, Vbottom);
 MapWindow.LScrollBar.SetParams(-LAYER, -LAYER_MAX, -LAYER_MIN);

 MapWindow.HScrollBar.SmallChange := SmallInt(Trunc(1+25/scale));
 MapWindow.HScrollBar.LargeChange := SmallInt(Trunc(1+100/scale));
 MapWindow.VScrollBar.SmallChange := SmallInt(Trunc(1+25/scale));
 MapWindow.VScrollBar.LargeChange := SmallInt(Trunc(1+100/scale));
end;

procedure DO_GetMapLimits(VAR minX, minY, minZ, maxX, maxY, maxZ : Real);
var i,j       : Integer;
    TheSector : TSector;
    TheVertex : TVertex;
begin
  minX := 99999;
  minY := 99999;
  minZ := 99999;
  maxX := -99999;
  maxY := -99999;
  maxZ := -99999;
  for i := 0 to MAP_SEC.Count - 1 do
    begin
      TheSector := TSector(MAP_SEC.Objects[i]);

      if TheSector.Ceili_alt > maxY then maxY := TheSector.Ceili_alt;
      if TheSector.Floor_alt < minY then minY := TheSector.Floor_alt;

      for j := 0 to TheSector.Vx.Count - 1 do
        begin
          TheVertex := TVertex(TheSector.Vx.Objects[j]);
          if TheVertex.X > maxX then maxX := TheVertex.X;
          if TheVertex.Z > maxZ then maxZ := TheVertex.Z;
          if TheVertex.X < minX then minX := TheVertex.X;
          if TheVertex.Z < minZ then minZ := TheVertex.Z;
        end;
    end;
end;

procedure DO_Center_On_Cursor;
var ThePoint : TPoint;
    MapPoint : TPoint;
begin
  GetCursorPos(ThePoint);
  MapPoint := MapWindow.Map.ScreenToClient(ThePoint);
  MapWindow.SetXoffset(Round(S2MX(MapPoint.X)));
  MapWindow.SetZoffset(Round(S2MZ(MapPoint.Y)));
  MapWindow.Map.Invalidate;
end;

procedure DO_Center_On_CurrentObject;
var TheSector : TSector;
    TheWall   : TWall;
    TheVertex : TVertex;
    TheObject : TOB;
begin
 CASE MAP_MODE OF
  MM_SC : begin
           TheSector := TSector(MAP_SEC.Objects[SC_HILITE]);
           TheVertex := TVertex(TheSector.Vx.Objects[0]);
           MapWindow.SetXoffset(Round(TheVertex.X));
           MapWindow.SetZoffset(Round(TheVertex.Z));
          end;
  MM_WL : begin
           TheSector := TSector(MAP_SEC.Objects[SC_HILITE]);
           TheWall   := TWall(TheSector.Wl.Objects[WL_HILITE]);
           TheVertex := TVertex(TheSector.Vx.Objects[TheWall.left_vx]);
           MapWindow.SetXoffset(Round(TheVertex.X));
           MapWindow.SetZoffset(Round(TheVertex.Z));
          end;
  MM_VX : begin
           TheSector := TSector(MAP_SEC.Objects[SC_HILITE]);
           TheVertex := TVertex(TheSector.Vx.Objects[VX_HILITE]);
           MapWindow.SetXoffset(Round(TheVertex.X));
           MapWindow.SetZoffset(Round(TheVertex.Z));
          end;
  MM_OB : begin
           TheObject := TOB(MAP_OBJ.Objects[OB_HILITE]);
           MapWindow.SetXoffset(Round(TheObject.X));
           MapWindow.SetZoffset(Round(TheObject.Z));
          end;
 END;
 MapWindow.Map.Invalidate;
end;

procedure DO_Next_SC;
begin
  if SC_HILITE < MAP_SEC.Count - 1 then
    Inc(SC_HILITE)
  else
    SC_HILITE := 0;
  WL_HILITE := 0;
  VX_HILITE := 0;
  DO_Fill_SectorEditor;
  MapWindow.Map.Invalidate;
end;

procedure DO_Prev_SC;
begin
  if SC_HILITE > 0  then
    Dec(SC_HILITE)
  else
    SC_HILITE := MAP_SEC.Count - 1;
  WL_HILITE := 0;
  VX_HILITE := 0;
  DO_Fill_SectorEditor;
  MapWindow.Map.Invalidate;
end;

procedure DO_Next_WL;
var TheSector : TSector;
begin
  TheSector := TSector(MAP_SEC.Objects[SC_HILITE]);
  if WL_HILITE < TheSector.Wl.Count - 1 then
    Inc(WL_HILITE)
  else
    WL_HILITE := 0;
  DO_Fill_WallEditor;
  MapWindow.Map.Invalidate;
end;

procedure DO_Prev_WL;
var TheSector : TSector;
begin
  TheSector := TSector(MAP_SEC.Objects[SC_HILITE]);
  if WL_HILITE > 0  then
    Dec(WL_HILITE)
  else
    WL_HILITE := TheSector.Wl.Count - 1;
  DO_Fill_WallEditor;
  MapWindow.Map.Invalidate;
end;

procedure DO_Next_VX;
var TheSector : TSector;
begin
  TheSector := TSector(MAP_SEC.Objects[SC_HILITE]);
  if VX_HILITE < TheSector.Vx.Count - 1 then
    Inc(VX_HILITE)
  else
    VX_HILITE := 0;
  DO_Fill_VertexEditor;
  MapWindow.Map.Invalidate;
end;

procedure DO_Prev_VX;
var TheSector : TSector;
begin
  TheSector := TSector(MAP_SEC.Objects[SC_HILITE]);
  if VX_HILITE > 0  then
    Dec(VX_HILITE)
  else
    VX_HILITE := TheSector.Vx.Count - 1;
  DO_Fill_VertexEditor;
  MapWindow.Map.Invalidate;
end;

procedure DO_Next_OB;
begin
  if OB_HILITE < MAP_OBJ.Count - 1 then
    Inc(OB_HILITE)
  else
    OB_HILITE := 0;
  DO_Fill_ObjectEditor;
  MapWindow.Map.Invalidate;
end;

procedure DO_Prev_OB;
begin
  if OB_HILITE > 0  then
    Dec(OB_HILITE)
  else
    OB_HILITE := MAP_OBJ.Count - 1;
  DO_Fill_ObjectEditor;
  MapWindow.Map.Invalidate;
end;

procedure DO_Edit_Short_Text_File(txt : TFileName);
begin
  Application.CreateForm(TSmallTextEditor, SmallTextEditor);

  SmallTextEditor.TheFile := txt;
  SmallTextEditor.ShowModal;

  SmallTextEditor.Destroy;
end;


procedure DO_SetMAP_TYPENormal;
begin
 MAP_TYPE := MT_NO;
 MapWindow.PanelMapType.Caption := 'Nor';
 MapWindow.Panel1MapType.Caption := 'Normal';
 MapWindow.NormalMap.Checked := TRUE;
 MapWindow.MMNormal.Checked := TRUE;
 MapWindow.Map.Invalidate;
end;

procedure DO_SetMAP_TYPELight;
begin
 MAP_TYPE := MT_LI;
 MapWindow.PanelMapType.Caption := 'Lig';
 MapWindow.Panel1MapType.Caption := 'Lights'; {//Added DL 12/nov/96  }
 MapWindow.LightsMap.Checked := TRUE;
 MapWindow.MMLight.Checked := TRUE;
 MapWindow.Map.Invalidate;
end;

procedure DO_SetMAP_TYPEDamage;
begin
 MAP_TYPE := MT_DM;
 MapWindow.PanelMapType.Caption := 'Dam';
 MapWindow.Panel1MapType.Caption := 'Damage'; { //Added DL 12/nov/96 }
 MapWindow.DamageMap.Checked := TRUE;
 MapWindow.MMDamage.Checked := TRUE;
 MapWindow.Map.Invalidate;
end;

procedure DO_SetMAP_TYPE2ndAltitude;
begin
 MAP_TYPE := MT_2A;
 MapWindow.PanelMapType.Caption := '2 A';
 MapWindow.Panel1MapType.Caption := '2Alt';   {//Added DL 12/nov/96}
 MapWindow.SecAltitudesMap.Checked := TRUE;
 MapWindow.MM2ndAltitudes.Checked := TRUE;
 MapWindow.Map.Invalidate;
end;

procedure DO_SetMAP_TYPESkyPit;
begin
 MAP_TYPE := MT_SP;
 MapWindow.PanelMapType.Caption := 'S&&P';
 MapWindow.Panel1MapType.Caption := 'Sky%Pit'; {//Added DL 12/nov/96}
 MapWindow.SkiesPitsMap.Checked := TRUE;
 MapWindow.MMSkiesPits.Checked := TRUE;
 MapWindow.Map.Invalidate;
end;

procedure DO_SetMap_TYPESectorFill;
begin
 MAP_TYPE := MT_SF;
 MapWindow.PanelMapType.Caption := 'Sector Fill';
 MapWindow.Panel1MapType.Caption := 'Sector Fill'; {//Added Karjala 16/jul/2021}
 MapWindow.SectorFill.Checked := TRUE;
 MapWindow.MMSectorFill.Checked := TRUE;
 MapWindow.Map.Invalidate;
end;

end.
