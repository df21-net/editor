unit M_multi;

interface
uses
  SysUtils, WinTypes, WinProcs, Graphics, IniFiles, Dialogs, Forms,
  _Math, _Strings, _Files,
  M_Global, M_io, M_Progrs, M_Find,
  M_Editor, M_SCedit, M_WLedit, M_VXedit, M_OBedit;

procedure DO_Clear_MultiSel;
procedure DO_Clear_MultiSel2;

procedure DO_MultiSel_SC(s : Integer);
procedure DO_MultiSel_VX(s, v : Integer);
procedure DO_MultiSel_WL(s, w : Integer);
procedure DO_MultiSel_OB(o : Integer);

procedure DO_Convert_MultiSC_MultiVX;
procedure DO_Convert_MultiSC_MultiWL;
procedure DO_Convert_MultiSC_MultiOB;
procedure DO_Convert_MultiWL_MultiVX;

implementation
uses Mapper, M_MapUt;

procedure DO_Clear_MultiSel;
begin
 SC_MULTIS.Clear;
 VX_MULTIS.Clear;
 WL_MULTIS.Clear;
 OB_MULTIS.Clear;

 {this handles multi color indicator, back menu...}
 CASE MAP_MODE OF
  MM_SC : DO_Fill_SectorEditor;
  MM_WL : DO_Fill_WallEditor;
  MM_VX : DO_Fill_VertexEditor;
  MM_OB : DO_Fill_ObjectEditor;
 END;

 MapWindow.PanelMulti.Caption := '0';
 MapWindow.Map.Invalidate;
end;

{this is used by the delete functions, in which we are *NOT* sure
 the current XX_HILITE is still valid !}
procedure DO_Clear_MultiSel2;
begin
 SC_MULTIS.Clear;
 VX_MULTIS.Clear;
 WL_MULTIS.Clear;
 OB_MULTIS.Clear;
 MapWindow.PanelMulti.Caption := '0';
end;

procedure DO_MultiSel_SC(s : Integer);
var m : Integer;
begin
 m := SC_MULTIS.IndexOf(Format('%4d%4d', [s, s]));

 if (SC_MulTIS.Count = 0) and not MULTISEL_RECT and not MULTISEL_SPC
                          and not (s = SC_HILITE_ORG) then
  SC_MULTIS.Add(Format('%4d%4d', [SC_HILITE_ORG, SC_HILITE_ORG]));

 CASE MULTISEL_MODE[1] of
  'T' :  if  m <> -1 then
          SC_MULTIS.Delete(m)
         else
          SC_MULTIS.Add(Format('%4d%4d', [s, s]));
  '+' :  if  m  = -1 then SC_MULTIS.Add(Format('%4d%4d', [s, s]));
  '-' :  if  m <> -1 then SC_MULTIS.Delete(m);
 END;
 MapWindow.PanelMulti.Caption := IntToStr(SC_MULTIS.Count);
end;

procedure DO_MultiSel_VX(s, v : Integer);
var m : Integer;
    ms : String;
begin
 ms := Format('%4d%4d', [s, v]);
 m := VX_MULTIS.IndexOf(ms);

 if (VX_MULTIS.Count = 0) and not MULTISEL_RECT and not MULTISEL_SPC
                          and not ([s,v] = [SC_HILITE_ORG,VX_HILITE_ORG]) then
  VX_MULTIS.Add(Format('%4d%4d', [SC_HILITE_ORG, VX_HILITE_ORG]));

 CASE MULTISEL_MODE[1] of
  'T' :  if  m <> -1 then
          VX_MULTIS.Delete(m)
         else
          VX_MULTIS.Add(ms);
  '+' :  if  m  = -1 then VX_MULTIS.Add(ms);
  '-' :  if  m <> -1 then VX_MULTIS.Delete(m);
 END;

 MapWindow.PanelMulti.Caption := IntToStr(VX_MULTIS.Count);
end;

procedure DO_MultiSel_WL(s, w : Integer);
var m : Integer;
begin
 m := WL_MULTIS.IndexOf(Format('%4d%4d', [s, w]));

 if (WL_MULTIS.Count = 0) and not MULTISEL_RECT and not MULTISEL_SPC
                          and not ([s,w] = [SC_HILITE_ORG,WL_HILITE_ORG]) then
  WL_MULTIS.Add(Format('%4d%4d', [SC_HILITE_ORG, WL_HILITE_ORG]));

 CASE MULTISEL_MODE[1] of
  'T' :  if  m <> -1 then
          WL_MULTIS.Delete(m)
         else
          WL_MULTIS.Add(Format('%4d%4d', [s, w]));
  '+' :  if  m  = -1 then WL_MULTIS.Add(Format('%4d%4d', [s, w]));
  '-' :  if  m <> -1 then WL_MULTIS.Delete(m);
 END;
 MapWindow.PanelMulti.Caption := IntToStr(WL_MULTIS.Count);
end;

procedure DO_MultiSel_OB(o : Integer);
var m         : Integer;
    TheObject : TOB;
begin
 TheObject := TOB(MAP_OBJ.Objects[o]);
 m := OB_MULTIS.IndexOf(Format('%4d%4d', [TheObject.Sec, o]));

 if (OB_MULTIS.Count = 0) and not MULTISEL_RECT and not MULTISEL_SPC
                          and not (o = OB_HILITE_ORG) then
  OB_MULTIS.Add(Format('%4d%4d', [SC_HILITE_ORG, OB_HILITE_ORG]));

 CASE MULTISEL_MODE[1] of
  'T' :  if  m <> -1 then
          OB_MULTIS.Delete(m)
         else
          OB_MULTIS.Add(Format('%4d%4d', [TheOBject.Sec, o]));
  '+' :  if  m  = -1 then OB_MULTIS.Add(Format('%4d%4d', [TheOBject.Sec, o]));
  '-' :  if  m <> -1 then OB_MULTIS.Delete(m);
 END;
 MapWindow.PanelMulti.Caption := IntToStr(OB_MULTIS.Count);
end;

procedure DO_Convert_MultiSC_MultiVX;
var m, i       : Integer;
    TheSector  : TSector;
begin
 VX_MULTIS.Clear;
 VertexEditor.ShapeMulti.Brush.Color := clBtnFace;
 for m := 0 to SC_MULTIS.Count - 1 do
  begin
   TheSector := TSector(MAP_SEC.Objects[StrToInt(Copy(SC_MULTIS[m],1,4))]);
   for i := 0 to TheSector.Vx.Count - 1 do
    begin
     VX_MULTIS.Add(Format('%4d%4d', [StrToInt(Copy(SC_MULTIS[m],1,4)), i]));
    end;
  end;
 MapWindow.PanelMulti.Caption := IntToStr(VX_MULTIS.Count);
end;

procedure DO_Convert_MultiSC_MultiWL;
var m, i       : Integer;
    TheSector  : TSector;
begin
 WL_MULTIS.Clear;
 WallEditor.ShapeMulti.Brush.Color := clBtnFace;
 for m := 0 to SC_MULTIS.Count - 1 do
  begin
   TheSector := TSector(MAP_SEC.Objects[StrToInt(Copy(SC_MULTIS[m],1,4))]);
   for i := 0 to TheSector.Wl.Count - 1 do
    begin
     WL_MULTIS.Add(Format('%4d%4d', [StrToInt(Copy(SC_MULTIS[m],1,4)), i]));
    end;
  end;
 MapWindow.PanelMulti.Caption := IntToStr(WL_MULTIS.Count);
end;

procedure DO_Convert_MultiSC_MultiOB;
var m, o       : Integer;
    TheObject  : TOB;
begin
 OB_MULTIS.Clear;
 ObjectEditor.ShapeMulti.Brush.Color := clBtnFace;
 for o := 0 to MAP_OBJ.Count - 1 do
  begin
   TheObject := TOB(MAP_OBJ.Objects[o]);
   for m := 0 to SC_MULTIS.Count - 1 do
    begin
     if TheObject.Sec = StrToInt(Copy(SC_MULTIS[m],1,4)) then
      OB_MULTIS.Add(Format('%4d%4d', [StrToInt(Copy(SC_MULTIS[m],1,4)), o]));
    end;
  end;
 MapWindow.PanelMulti.Caption := IntToStr(OB_MULTIS.Count);
end;

procedure DO_Convert_MultiWL_MultiVX;
var m, i, v, s : Integer;
    TheSector  : TSector;
    TheWall    : TWall;
begin
 VX_MULTIS.Clear;
 VertexEditor.ShapeMulti.Brush.Color := clBtnFace;

 for m := 0 to WL_MULTIS.Count - 1 do
  begin
   s := StrToInt(Copy(WL_MULTIS[m],1,4));
   TheSector := TSector(MAP_SEC.Objects[s]);
   i := StrToInt(Copy(WL_MULTIS[m],5,8));

   TheWall := TWall(TheSector.Wl.Objects[i]);
   v := TheWall.left_vx;
   if VX_MULTIS.IndexOf(Format('%4d%4d', [s, v])) = -1 then
     VX_MULTIS.Add(Format('%4d%4d', [s, v]));
   v := TheWall.right_vx;
   if VX_MULTIS.IndexOf(Format('%4d%4d', [s, v])) = -1 then
     VX_MULTIS.Add(Format('%4d%4d', [s, v]));

  end;
 MapWindow.PanelMulti.Caption := IntToStr(VX_MULTIS.Count);
end;

end.
