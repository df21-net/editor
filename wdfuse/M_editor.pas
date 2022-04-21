unit M_editor;

interface
uses
  SysUtils, WinTypes, WinProcs, Graphics, IniFiles, Dialogs, Forms, Controls,
  _Math, _Strings,
  M_Global,
  M_SCedit, M_WLedit, M_VXedit, M_OBedit, M_FlagEd, M_Diff,
  M_Resour, M_OBClas, M_ObSeq, M_ObSel, RichEdit, Grids, v_util32, Math;

function  IsBitSet(value : LongInt; bit : Integer) : Boolean;
function  FlagEdit(cellvalue, flagfile, title : String) : String;
function  ResEdit(cellvalue : String; resmode : Integer;
                  restype : integer = 0; textlen : String = '0') : String;
function  ClassEdit(cellvalue : String) : String;
function  DiffEdit(cellvalue : String) : String;
function  DiffEditNoCheck(cellvalue : String) : String;

procedure DO_Fill_VertexEditor;
function  Check_AllVertexEditor : Boolean;
function  Check_VertexEditorField(field : Integer) : Boolean;
function  CompareTwoVertices(VertexA: TVertex; VertexB: TVertex) : Boolean;
procedure DO_Commit_VertexEditor;
procedure DO_Commit_VertexEditorField(field : Integer);
procedure DO_ForceCommit_VertexEditorField(field : Integer);

procedure DO_Fill_SectorEditor;
procedure DO_SectorEditor_Specials_Init;
procedure DO_SectorEditor_Specials(c : Integer);
function  Check_AllSectorEditor : Boolean;
function  Check_SectorEditorField(field : Integer) : Boolean;
function  CompareTwoSectors(SectorA: TSector; SectorB : TSector) : Boolean;
procedure DO_Commit_SectorEditor;
procedure DO_Commit_SectorEditorField(field : Integer);
procedure DO_ForceCommit_SectorEditorField(field : Integer);

procedure DO_Fill_WallEditor;
procedure DO_WallEditor_Specials_Init;
procedure DO_WallEditor_Specials(c : Integer);
function  Check_AllWallEditor : Boolean;
function  Check_WallEditorField(field : Integer) : Boolean;
function  CompareTwoWalls(WallA: TWall; WallB: TWall) : Boolean;
function UpdateWallLengthVX(WallLength : Real) : Boolean;
procedure DO_Commit_WallEditor;
procedure DO_Commit_WallEditorField(field : Integer);
procedure DO_ForceCommit_WallEditorField(field : Integer);

procedure DO_Fill_ObjectEditor;
function  Check_AllObjectEditor : Boolean;
function  Check_ObjectEditorField(field : Integer) : Boolean;
function  CompareTwoObjects(ObjectA: TOB; ObjectB: TOB) : Boolean;
procedure DO_Commit_ObjectEditor;
procedure DO_Commit_ObjectEditorField(field : Integer);
procedure DO_ForceCommit_ObjectEditorField(field : Integer);

procedure DO_FillLogic;
procedure DO_FillOneLogic(num : Integer);
procedure DO_MakeGenerator;
procedure DO_FillOBColor;
procedure DO_SelectObject;

procedure UpdateSectorName(INFSector : Integer);

procedure SetDOOMEditors;

implementation
uses Mapper, M_Util, M_mapfun, InfEdit2;


function  IsBitSet(value : LongInt; bit : Integer) : Boolean;
begin
 if ((value shr bit) mod 2) = 1 then
  IsBitSet := TRUE
 else
  IsBitSet := FALSE;
end;

function  FlagEdit(cellvalue, flagfile, title : String) : String;
var ALong    : LongInt;
    Code     : Integer;
    i        : Integer;
begin
 Val(cellvalue, ALong, Code);
 if Code = 0 then
  if ALong >= 0 then
   FlagEditorVal := ALong
  else
   begin
    Application.MessageBox('Flag must be >= 0', 'Flag Editor Error', mb_Ok or mb_IconExclamation);
    FlagEdit := CellValue;
    exit;
   end
 else
  begin
   Application.MessageBox('Wrong value for Flag', 'Flag Editor Error', mb_Ok or mb_IconExclamation);
   FlagEdit := CellValue;
   exit;
  end;

 FlagEditor.Title.Caption := title;
 FlagEditor.LBFlags.Items.LoadFromFile(WDFUSEdir + '\wdfdata\' + flagfile);

 for i := 0 to FlagEditor.LBFlags.Items.Count - 1 do
  if IsBitSet(FlagEditorVal, i) then
   FlagEditor.LBFlags.Selected[i] := TRUE
  else
   FlagEditor.LBFlags.Selected[i] := FALSE;

 FlagEditor.ShowModal;
 if FlagEditor.ModalResult = idOk then
  begin
   ALong := 0;
   for i := 0 to FlagEditor.LBFlags.Items.Count - 1 do
    if FlagEditor.LBFlags.Selected[i] then
     ALong := ALong + LongInt(1) shl i;
   FlagEdit := IntToStr(ALong);
  end
 else
  FlagEdit := CellValue;
end;

function  ResEdit(cellvalue : String; resmode : Integer;
                  restype : integer = 0; textlen : String = '0') : String;
begin
 RES_PICKER_VALUE := cellvalue;
 RES_PICKER_MODE  := resmode;
 RES_PICKER_TYPE  := restype;

 // We only cares about ints to strip the floatiness
 RES_PICKER_LEN   := trunc(strtofloat(textlen));

 ResourcePicker.ShowModal;
 if ResourcePicker.ModalResult = mrOk then
  begin
   ResEdit := RES_PICKER_VALUE;
  end
 else
  ResEdit := CellValue;
end;

function  ClassEdit(cellvalue : String) : String;
var TheIndex : Integer;
begin
 OBCLASS_VALUE := cellvalue;
 TheIndex := OBClassWindow.LBClass.Items.IndexOf(cellvalue);
 if TheIndex <> -1 then
  begin
   OBClassWindow.LBClass.ItemIndex := TheIndex;
   OBClassWindow.ShowModal;
   ClassEdit := OBCLASS_VALUE;
  end
 else
  begin
   ShowMessage('Wrong Object Class');
   ClassEdit := CellValue;
  end;
end;

function  DiffEdit(cellvalue : String) : String;
begin
TMPObject := TOB.Create;
if Check_ObjectEditorField(8) then
 begin
   DiffEditor.RGDiff.ItemIndex := StrToInt(cellvalue) + 3;
   DiffEditor.ShowModal;
   if DiffEditor.ModalResult = mrOk then
    begin
     DiffEdit := IntToStr(DiffEditor.RGDiff.ItemIndex - 3);
    end
   else
    DiffEdit := cellvalue;
 end
else
 DiffEdit := cellvalue;
TMPObject.Free;
end;

{This is used by the query window, as it uses a bounded Spin Edit control}
function  DiffEditNoCheck(cellvalue : String) : String;
begin
 DiffEditor.RGDiff.ItemIndex := StrToInt(cellvalue) + 3;
 DiffEditor.ShowModal;
 if DiffEditor.ModalResult = mrOk then
  begin
   DiffEditNoCheck := IntToStr(DiffEditor.RGDiff.ItemIndex - 3);
  end
 else
  DiffEditNoCheck := cellvalue;
end;

{VERTEX EDITOR ************************************************************}
{VERTEX EDITOR ************************************************************}
{VERTEX EDITOR ************************************************************}

procedure DO_Fill_VertexEditor;
var
  TheSector : TSector;
  TheVertex : TVertex;
  numvx     : Integer;
  awall     : Integer;
  VXEd2     : TStringGrid;
  phandle   : HWND;
begin
 TheSector := TSector(MAP_SEC.Objects[SC_HILITE]);
 numvx     := TheSector.Vx.Count;
 TheVertex := TVertex(TheSector.Vx.Objects[VX_HILITE]);
 VertexEditor.Caption := Format('VX %d of %d, SC %d', [VX_HILITE, numvx, SC_HILITE]);

 VertexEditor.VXEd.Cells[1,  0] := PosTrim(TheVertex.X);
 VertexEditor.VXEd.Cells[1,  1] := PosTrim(TheVertex.Z);
 VertexEditor.PanelSCName.Caption := TheSector.Name;
 VertexEditor.PanelFloorAlt.Caption := Format('%-5.2f && %-5.2f', [TheSector.Floor_Alt, TheSector.Ceili_Alt]);
 if GetWLfromLeftVX(SC_HILITE, VX_HILITE, awall) then
  VertexEditor.PanelLeftOfWL.Caption := IntToStr(awall)
 else
  VertexEditor.PanelLeftOfWL.Caption := '[none]';
 if GetWLfromRightVX(SC_HILITE, VX_HILITE, awall) then
  VertexEditor.PanelRightOfWL.Caption := IntToStr(awall)
 else
  VertexEditor.PanelRightOfWL.Caption := '[none]';

 if VX_MULTIS.Count = 0 then
  begin
   VertexEditor.ShapeMulti.Brush.Color     := clBtnFace;
   VertexEditor.ForceCurrentField.Enabled  := FALSE;
  end
 else
  begin
   VertexEditor.ShapeMulti.Brush.Color := clRed;
   VertexEditor.ForceCurrentField.Enabled := TRUE;
  end;

 // Reset Focus
 if not AUTOCOMMIT_FLAG and not INF_READ and VertexEditor.visible then
   begin
     VertexEditor.FormCreate(NIL);
     VertexEditor.SetFocus;
     MapWindow.SetFocus;
   end;
 MapWindow.Invalidate;
end;

function  Check_AllVertexEditor : Boolean;
var i      : Integer;
begin
 Result := TRUE;
 for i := 0 to 1 do
  begin
   Result := Result and Check_VertexEditorField(i);
   if not Result then break;
  end;
end;

function  Check_VertexEditorField(field : Integer) : Boolean;
var
  AReal               : Real;
  Code                : Integer;
  title               : array[0..60] of char;
begin
 StrCopy(Title, 'Vertex Editor Error');
 Check_VertexEditorField := TRUE;
 CASE field of
   0 : begin
        { X }
        Val(VertexEditor.VXEd.Cells[1,  0], AReal, Code);
        if Code = 0 then
         TMPVertex.X := AReal
        else
         begin
          Application.MessageBox('Wrong value for X', Title, mb_Ok or mb_IconExclamation);
          Check_VertexEditorField := FALSE;
         end;
       end;
   1 : begin
        { Z }
        Val(VertexEditor.VXEd.Cells[1,  1], AReal, Code);
        if Code = 0 then
         TMPVertex.Z := AReal
        else
         begin
          Application.MessageBox('Wrong value for Z', Title, mb_Ok or mb_IconExclamation);
          Check_VertexEditorField := FALSE;
         end;
       end;
 END;
end;

function  CompareTwoVertices(VertexA: TVertex; VertexB: TVertex) : Boolean;
begin
 Result := False;
 if (VertexA.X = VertexB.X) and (VertexA.Z = VertexB.Z) then Result := True;
end;

procedure DO_Commit_VertexEditorField(field : Integer);
var
  TheSector           : TSector;
  TheVertex           : TVertex;
  TheSectorM          : TSector;
  TheVertexM          : TVertex;
  m                   : Integer;
begin

 TheSector     := TSector(MAP_SEC.Objects[SC_HILITE]);
 TheVertex     := TVertex(TheSector.Vx.Objects[VX_HILITE]);

 CASE field of
   0 : if ORIVertex.X <> TMPVertex.X then
        begin
         {selection}
         TheVertex.X := TMPVertex.X;
         {multiselection}
         if VX_MULTIS.Count <> 0 then
          for m := 0 to VX_MULTIS.Count - 1 do
           begin
            TheSectorM   := TSector(MAP_SEC.Objects[StrToInt(Copy(VX_MULTIS[m],1,4))]);
            TheVertexM   := TVertex(TheSectorM.Vx.Objects[StrToInt(Copy(VX_MULTIS[m],5,4))]);
            TheVertexM.X := TMPVertex.X;
           end;
         MODIFIED := TRUE;
        end;
   1 : if ORIVertex.Z <> TMPVertex.Z then
        begin
         {selection}
         TheVertex.Z := TMPVertex.Z;
         {multiselection}
         if VX_MULTIS.Count <> 0 then
          for m := 0 to VX_MULTIS.Count - 1 do
           begin
            TheSectorM   := TSector(MAP_SEC.Objects[StrToInt(Copy(VX_MULTIS[m],1,4))]);
            TheVertexM   := TVertex(TheSectorM.Vx.Objects[StrToInt(Copy(VX_MULTIS[m],5,4))]);
            TheVertexM.Z := TMPVertex.Z;
           end;
         MODIFIED := TRUE;
        end;
 END;
end;

procedure DO_Commit_VertexEditor;
var
  TheSector           : TSector;
  TheVertex           : TVertex;
  i                   : Integer;
begin
 TMPVertex := TVertex.Create;
 if not Check_AllVertexEditor then
  begin
   TMPVertex.Free;
   exit;
  end;

 TheSector     := TSector(MAP_SEC.Objects[SC_HILITE]);
 TheVertex     := TVertex(TheSector.Vx.Objects[VX_HILITE]);

 if CompareTwoVertices(TheVertex, TMPVertex) then exit;


 if CONFIRMMultiUpdate and (VX_MULTIS.Count <> 0) then
  begin
   if Application.MessageBox('Confirm Multiple Update ?',
                            'WDFUSE Vertex Editor - Update Vertices',
                            mb_YesNo or mb_IconQuestion) = idNo
    then exit;
  end;

 DO_StoreUndo;

 {Get original values, to see which values have changed}
 
 ORIVertex     := TVertex.Create;
 ORIVertex.X   := TheVertex.X;
 ORIVertex.Z   := TheVertex.Z;

 for i := 0 to 1 do
  DO_Commit_VertexEditorField(i);

 TMPVertex.Free;
 ORIVertex.Free;
 MapWindow.Map.Invalidate;
end;

{
this function is nearly the same, but
 * it works for a single field (check and commit)
 * it will set "impossible" values in the ORI field, forcing commit
}
procedure DO_ForceCommit_VertexEditorField(field : Integer);
begin
 TMPVertex := TVertex.Create;
 if not Check_VertexEditorField(field) then
  begin
   TMPVertex.Free;
   exit;
  end;

 if not IGNORE_UNDO and CONFIRMMultiUpdate and (VX_MULTIS.Count <> 0) then
  begin
   if Application.MessageBox('Confirm Multiple Update ?',
                            'WDFUSE Vertex Editor - Force Update Vertices',
                            mb_YesNo or mb_IconQuestion) = idNo
    then exit;
  end;

 ORIVertex     := TVertex.Create;
 ORIVertex.X   := -9876543.21;
 ORIVertex.Z   := -9876543.21;

 DO_Commit_VertexEditorField(field);

 TMPVertex.Free;
 ORIVertex.Free;
 MapWindow.Map.Invalidate;
end;

{SECTOR EDITOR ************************************************************}
{SECTOR EDITOR ************************************************************}
{SECTOR EDITOR ************************************************************}

procedure DO_Fill_SectorEditor;
var
  TheSector : TSector;
  numvx     : Integer;
  numwl     : Integer;
begin
 TheSector := TSector(MAP_SEC.Objects[SC_HILITE]);
 numvx     := TheSector.Vx.Count;
 numwl     := TheSector.Wl.Count;
 SectorEditor.Caption := Format('SC %d  %s', [SC_HILITE, TheSector.Name]);
 SectorEditor.SCEd.Cells[1,  0] := TheSector.Name;
 SectorEditor.SCEd.Cells[1,  1] := IntToStr(TheSector.Ambient);
 SectorEditor.SCEd.Cells[1,  2] := IntToStr(TheSector.Flag1);
 SectorEditor.SCEd.Cells[1,  3] := IntToStr(TheSector.Flag2);
 SectorEditor.SCEd.Cells[1,  4] := IntToStr(TheSector.Flag3);
 SectorEditor.SCEd.Cells[1,  5] := PosTrim(TheSector.Floor_Alt);
 SectorEditor.SCEd.Cells[1,  6] := TheSector.Floor.Name;
 SectorEditor.SCEd.Cells[1,  7] := PosTrim(TheSector.Floor.f1);
 SectorEditor.SCEd.Cells[1,  8] := PosTrim(TheSector.Floor.f2);
 SectorEditor.SCEd.Cells[1,  9] := IntToStr(TheSector.Floor.i);
 SectorEditor.SCEd.Cells[1, 10] := PosTrim(TheSector.Ceili_Alt);
 SectorEditor.SCEd.Cells[1, 11] := TheSector.Ceili.Name;
 SectorEditor.SCEd.Cells[1, 12] := PosTrim(TheSector.Ceili.f1);
 SectorEditor.SCEd.Cells[1, 13] := PosTrim(TheSector.Ceili.f2);
 SectorEditor.SCEd.Cells[1, 14] := IntToStr(TheSector.Ceili.i);
 SectorEditor.SCEd.Cells[1, 15] := PosTrim(TheSector.Second_Alt);
 SectorEditor.SCEd.Cells[1, 16] := IntToStr(TheSector.Layer);

 SectorEditor.PanelVXNum.Caption := IntToStr(numvx);
 SectorEditor.PanelWLNum.Caption := IntToStr(numwl);

  // Reset Focus
 if not AUTOCOMMIT_FLAG and not INF_READ and not APPLYING_UNDO and SectorEditor.visible then
   begin
     SectorEditor.FormCreate(NIL);
     SectorEditor.SetFocus;
     MapWindow.SetFocus;
   end;
 //MapWindow.Invalidate;

 DO_SectorEditor_Specials_Init;
 DO_SectorEditor_Specials(0);

 if SC_MULTIS.Count = 0 then
  begin
   SectorEditor.ShapeMulti.Brush.Color := clBtnFace;
   SectorEditor.ForceCurrentField.Enabled := FALSE;
  end
 else
  begin
   SectorEditor.ShapeMulti.Brush.Color := clRed;
   SectorEditor.ForceCurrentField.Enabled := TRUE;
  end;

 if TheSector.InfItems.Count = 0 then
  begin
   SectorEditor.INFButton.Visible := False;
   SectorEditor.INFButtonOff.Visible := True;
  end
 else
  begin
   SectorEditor.INFButton.Visible := True;
   SectorEditor.INFButtonOff.Visible := False;
  end;

 // Show it even if no INFs if visible
 if not APPLYING_UNDO and INFWindow2.Visible and INFWindow2.ontop then
   begin
     MapWindow.SpeedButtonINFClick(NIL);
     MapWindow.SetFocus;
   end;
end;

procedure DO_SectorEditor_Specials_Init;
var
  TheSector : TSector;
  i         : Integer;
  TheInfCls : TInfClass;
  TheClass  : String;
begin
 TheSector := TSector(MAP_SEC.Objects[SC_HILITE]);

 SectorEditor.CBClass.Enabled := TRUE;
 SectorEditor.CBSlaCLi.Enabled := TRUE;
 SectorEditor.CBClass.Clear;
 SectorEditor.CBSlaCli.Clear;

 IF TheSector.InfClasses.Count <> 0 THEN
  BEGIN
   for i := 0 to TheSector.InfClasses.Count - 1 do
    begin
     TheInfCls := TinfClass(TheSector.InfClasses.Objects[i]);
     if TheInfCls.IsElev then
      TheClass := 'E. '
     else
      TheClass := 'T. ';
     SectorEditor.CBClass.Items.Add({TheClass + }TheInfCls.Name);
    end;
  END
 ELSE
  BEGIN
   SectorEditor.CBClass.Enabled := FALSE;
   SectorEditor.CBSlaCLi.Enabled := FALSE;
  END;
 SUPERHILITE := -1;
end;

procedure DO_SectorEditor_Specials(c : Integer);
var
  TheSector : TSector;
  TheInfCls : TInfClass;
begin
 TheSector := TSector(MAP_SEC.Objects[SC_HILITE]);

 if TheSector.InfClasses.Count <> 0 then
 BEGIN
  SectorEditor.CBClass.ItemIndex := c;
  if SectorEditor.CBClass.Items[c][1] = 'E' then
   SectorEditor.PanelSlaCli.Caption := 'slave:'
  else
   if SectorEditor.CBClass.Items[c][1] = 'T' then
    SectorEditor.PanelSlaCli.Caption := 'client:'
   else
    SectorEditor.PanelSlaCli.Caption := 'target:';

  SectorEditor.CBSlaCli.Clear;
  TheInfCls := TInfClass(TheSector.InfClasses.Objects[c]);
  if TheInfCls.SlaCli.Count <> 0 then
   begin
    SectorEditor.CBSlaCli.Items.AddStrings(TheInfCls.SlaCli);
    SectorEditor.CBSlaCli.ItemIndex := 0;
    SUPERHILITE := -1;
     if GetSectorNumFromName(SectorEditor.CBSlaCli.Items[0], SUPERHILITE)
      then MapWindow.Map.Invalidate;
   end;
 END;
end;

function  Check_AllSectorEditor : Boolean;
var i      : Integer;
begin
 Result := TRUE;
 for i := 0 to 16 do
  begin
   Result := Result and Check_SectorEditorField(i);
   if not Result then break;
  end;
end;

function  Check_SectorEditorField(field : Integer) : Boolean;
var
  AReal               : Real;
  AInt                : Integer;
  ALong               : LongInt;
  Code                : Integer;
  title               : array[0..60] of char;
begin
 StrCopy(Title, 'Sector Editor Error');
 Check_SectorEditorField := TRUE;
 CASE field of
   0 : begin
       { Name }
        if Length(SectorEditor.SCEd.Cells[1,  0]) < 16 then
         TMPSector.Name := SectorEditor.SCEd.Cells[1,  0]
        else  {check here for lenght}
         begin
          Application.MessageBox('Name too long', Title, mb_Ok or mb_IconExclamation);
          Check_SectorEditorField := FALSE;
         end;
       end;
   1 : begin
        { Ambient }
        Val(SectorEditor.SCEd.Cells[1,  1], AInt, Code);
        if Code = 0 then
         if AInt >= 0 then
          TMPSector.Ambient := AInt
         else
          begin
           Application.MessageBox('Ambient must be >= 0', Title, mb_Ok or mb_IconExclamation);
           Check_SectorEditorField := FALSE;
          end
        else
         begin
          Application.MessageBox('Wrong value for Ambient', Title, mb_Ok or mb_IconExclamation);
          Check_SectorEditorField := FALSE;
         end;
       end;
   2 : begin
        { Flag1 }
        Val(SectorEditor.SCEd.Cells[1,  2], ALong, Code);
        if Code = 0 then
         if ALong >= 0 then
          TMPSector.Flag1 := ALong
         else
          begin
           Application.MessageBox('Flag1 must be >= 0', Title, mb_Ok or mb_IconExclamation);
           Check_SectorEditorField := FALSE;
          end
        else
         begin
          Application.MessageBox('Wrong value for Flag1', Title, mb_Ok or mb_IconExclamation);
          Check_SectorEditorField := FALSE;
         end;
       end;
   3 : begin
        { Flag2 }
        Val(SectorEditor.SCEd.Cells[1,  3], ALong, Code);
        if Code = 0 then
         if ALong >= 0 then
          TMPSector.Flag2 := ALong
         else
          begin
           Application.MessageBox('Flag2 must be >= 0', Title, mb_Ok or mb_IconExclamation);
           Check_SectorEditorField := FALSE;
          end
        else
         begin
          Application.MessageBox('Wrong value for Flag2', Title, mb_Ok or mb_IconExclamation);
          Check_SectorEditorField := FALSE;
         end;
       end;
   4 : begin
        { Flag3 }
        Val(SectorEditor.SCEd.Cells[1,  4], ALong, Code);
        if Code = 0 then
         if ALong >= 0 then
          TMPSector.Flag3 := ALong
         else
          begin
           Application.MessageBox('Flag3 must be >= 0', Title, mb_Ok or mb_IconExclamation);
           Check_SectorEditorField := FALSE;
          end
        else
         begin
          Application.MessageBox('Wrong value for Flag3', Title, mb_Ok or mb_IconExclamation);
          Check_SectorEditorField := FALSE;
         end;
       end;
   5 : begin
        { Floor_Alt }
        Val(SectorEditor.SCEd.Cells[1,  5], AReal, Code);
        if Code = 0 then
         TMPSector.Floor_Alt := AReal
        else
         begin
          Application.MessageBox('Wrong value for Floor Altitude', Title, mb_Ok or mb_IconExclamation);
          Check_SectorEditorField := FALSE;
         end;
       end;
   6 : begin
       { Floor name }
        if Length(SectorEditor.SCEd.Cells[1,  6]) < 13 then
         TMPSector.Floor.Name := SectorEditor.SCEd.Cells[1,  6]
        else
         begin
          Application.MessageBox('Floor Name too long', Title, mb_Ok or mb_IconExclamation);
          Check_SectorEditorField := FALSE;
         end;
       end;
   7 : begin
        { Floor X Offset }
        Val(SectorEditor.SCEd.Cells[1,  7], AReal, Code);
        if Code = 0 then
         TMPSector.Floor.f1 := AReal
        else
         begin
          Application.MessageBox('Wrong value for Floor X Offset', Title, mb_Ok or mb_IconExclamation);
          Check_SectorEditorField := FALSE;
         end;
       end;
   8 : begin
        { Floor Z Offset }
        Val(SectorEditor.SCEd.Cells[1,  8], AReal, Code);
        if Code = 0 then
          TMPSector.Floor.f2 := AReal
        else
         begin
          Application.MessageBox('Wrong value for Floor Z Offset', Title, mb_Ok or mb_IconExclamation);
          Check_SectorEditorField := FALSE;
         end;
       end;
   9 : begin
        { Floor i }
        Val(SectorEditor.SCEd.Cells[1,  9], AInt, Code);
        if Code = 0 then
         TMPSector.Floor.i := AInt
        else
         begin
          Application.MessageBox('Wrong value for Floor # (unused integer)', Title, mb_Ok or mb_IconExclamation);
          Check_SectorEditorField := FALSE;
         end;
       end;
  10 : begin
        { Ceili_Alt }
        Val(SectorEditor.SCEd.Cells[1,  10], AReal, Code);
        if Code = 0 then
         if AReal >= TMPSector.Floor_Alt then
          TMPSector.Ceili_Alt := AReal
         else
          begin
           Application.MessageBox('Ceiling must be higher than Floor', Title, mb_Ok or mb_IconExclamation);
           Check_SectorEditorField := FALSE;
          end
        else
         begin
          Application.MessageBox('Wrong value for Ceiling Altitude', Title, mb_Ok or mb_IconExclamation);
          Check_SectorEditorField := FALSE;
         end;
       end;
  11 : begin
       { Ceili name }
        if Length(SectorEditor.SCEd.Cells[1,  11]) < 13 then
         TMPSector.Ceili.Name := SectorEditor.SCEd.Cells[1, 11]
        else
         begin
          Application.MessageBox('Ceiling Name too long', Title, mb_Ok or mb_IconExclamation);
          Check_SectorEditorField := FALSE;
         end;
       end;
  12 : begin
        { Ceili X Offset }
        Val(SectorEditor.SCEd.Cells[1, 12], AReal, Code);
        if Code = 0 then
          TMPSector.Ceili.f1 := AReal
        else
         begin
          Application.MessageBox('Wrong value for Ceiling X Offset', Title, mb_Ok or mb_IconExclamation);
          Check_SectorEditorField := FALSE;
         end;
       end;
  13 : begin
        { Ceili Z Offset }
        Val(SectorEditor.SCEd.Cells[1, 13], AReal, Code);
        if Code = 0 then
         TMPSector.Ceili.f2 := AReal
        else
         begin
          Application.MessageBox('Wrong value for Ceiling Z Offset', Title, mb_Ok or mb_IconExclamation);
          Check_SectorEditorField := FALSE;
         end;
       end;
  14 : begin
        { Ceili i }
        Val(SectorEditor.SCEd.Cells[1, 14], AInt, Code);
        if Code = 0 then
         TMPSector.Ceili.i := AInt
        else
         begin
          Application.MessageBox('Wrong value for Ceiling # (unused integer)', Title, mb_Ok or mb_IconExclamation);
          Check_SectorEditorField := FALSE;
         end;
       end;
  15 : begin
        { Second Altitude }
        Val(SectorEditor.SCEd.Cells[1, 15], AReal, Code);
        if Code = 0 then
         TMPSector.Second_Alt := AReal
        else
         begin
          Application.MessageBox('Wrong value for Second Altitude', Title, mb_Ok or mb_IconExclamation);
          Check_SectorEditorField := FALSE;
         end;
       end;
  16 : begin
        { Layer }
        Val(SectorEditor.SCEd.Cells[1, 16], AInt, Code);
        if Code = 0 then
         if (AInt >= -9) and (AInt <= 9) then
          TMPSector.Layer := AInt
         else
          begin
           Application.MessageBox('Layer must be between -9 and +9', Title, mb_Ok or mb_IconExclamation);
           Check_SectorEditorField := FALSE;
          end
        else
         begin
          Application.MessageBox('Wrong value for Layer', Title, mb_Ok or mb_IconExclamation);
          Check_SectorEditorField := FALSE;
         end;
       end;
 END;
end;

function  CompareTwoSectors(SectorA: TSector; SectorB : TSector) : Boolean;
var i : integer;
begin
 Result := False;
 if (SectorA.Name        =  SectorB.Name)
 and (SectorA.Ambient    = SectorB.Ambient)
 and (SectorA.Flag1      = SectorB.Flag1)
 and (SectorA.Flag2      = SectorB.Flag2)
 and (SectorA.Flag3      = SectorB.Flag3)
 and (SectorA.Floor_Alt  = SectorB.Floor_Alt)
 and (SectorA.Floor.Name = SectorB.Floor.Name)
 and (SectorA.Floor.f1   = SectorB.Floor.f1)
 and (SectorA.Floor.f2   = SectorB.Floor.f2)
 and (SectorA.floor.i    = SectorB.floor.i)
 and (SectorA.Ceili_Alt  = SectorB.Ceili_Alt)
 and (SectorA.Ceili.Name = SectorB.Ceili.Name)
 and (SectorA.Ceili.f1   = SectorB.Ceili.f1)
 and (SectorA.Ceili.f2   = SectorB.Ceili.f2)
 and (SectorA.Ceili.i    = SectorB.Ceili.i)
 and (SectorA.Second_Alt = SectorB.Second_Alt)
 and (SectorA.Layer      = SectorB.Layer) then Result := True
end;

procedure DO_Commit_SectorEditor;
var
  TheSector           : TSector;
  TheWall             : TWall;
  i                   : Integer;
begin
 TMPSector := TSector.Create;
 if not Check_AllSectorEditor then
  begin
   TMPSector.Free;
   exit;
  end;

 // If the new values are identical then
 // Is this trip really necessary?
 TheSector := TSector(MAP_SEC.Objects[SC_HILITE]);
 if CompareTwoSectors(TheSector, TMPSector) then exit;

 if CONFIRMMultiUpdate and (SC_MULTIS.Count <> 0) then
  begin
   if Application.MessageBox('Confirm Multiple Update ?',
                            'WDFUSE Sector Editor - Update Sectors',
                            mb_YesNo or mb_IconQuestion) = idNo
    then exit;
  end;

 // Are you being naughty and trying to save a no-name sector with wall INF items?
 if (TMPSector.Name = '') then
  begin
    for i := 0 to TheSector.Wl.Count - 1 do
      begin
        TheWall := TWall(TheSector.Wl.Objects[i]);
        if (TheWall.InfItems.Count >0) then
          begin
            showmessage('Warning! Wall ' + inttostr(i) + ' has INF items but your ' +
                        'Sector doesnt have a name! Give it one to prevent a crash!');
            exit;
          end;
      end;
  end;


 DO_StoreUndo;

 {Get original values, to see which values have changed}

 ORISector := TSector.Create;
 ORISector.Name       := TheSector.Name;
 ORISector.Ambient    := TheSector.Ambient;
 ORISector.Flag1      := TheSector.Flag1;
 ORISector.Flag2      := TheSector.Flag2;
 ORISector.Flag3      := TheSector.Flag3;
 ORISector.Floor_Alt  := TheSector.Floor_Alt;
 ORISector.Floor.Name := TheSector.Floor.Name;
 ORISector.Floor.f1   := TheSector.Floor.f1;
 ORISector.Floor.f2   := TheSector.Floor.f2;
 ORISector.Floor.i    := TheSector.Floor.i;
 ORISector.Ceili_Alt  := TheSector.Ceili_Alt;
 ORISector.Ceili.Name := TheSector.Ceili.Name;
 ORISector.Ceili.f1   := TheSector.Ceili.f1;
 ORISector.Ceili.f2   := TheSector.Ceili.f2;
 ORISector.Ceili.i    := TheSector.Ceili.i;
 ORISector.Second_Alt := TheSector.Second_Alt;
 ORISector.Layer      := TheSector.Layer;

 for i := 0 to 16 do
  DO_Commit_SectorEditorField(i);

 UpdateSectorName(SC_HILITE);

 TMPSector.Free;
 ORISector.Free;

 DO_Fill_SectorEditor; {for eventual updates of infclasses}
 MapWindow.Map.Invalidate;
end;

procedure DO_Commit_SectorEditorField(field : Integer);
var
  TheSector           : TSector;
  TheSectorM          : TSector;
  m, i                : Integer;
  xor_flag,
  set_flag,
  reset_flag          : LongInt;
  TheInfCls           : TInfClass;
  found               : Boolean;
begin
 TheSector     := TSector(MAP_SEC.Objects[SC_HILITE]);

 CASE field of
   0 : if ORISector.Name <> TMPSector.Name then
        begin
         {selection}
         TheSector.Name := TMPSector.Name;

         // Add it to INF Sector for caching and force a rebuild
         // and remove old name from the list for caching.
         if RTrim(TheSector.Name) <> '' then
           INFSectors.Add(TheSector.Name)
         else if (RTrim(ORISector.Name) <> '') and (INFSectors.IndexOf(ORISector.Name) <> -1) then
             INFSectors.Delete(INFSectors.IndexOf(ORISector.Name));


         {multiselection}
         if SC_MULTIS.Count <> 0 then
          for m := 0 to SC_MULTIS.Count - 1 do
           begin
            TheSectorM   := TSector(MAP_SEC.Objects[StrToInt(Copy(SC_MULTIS[m],1,4))]);
            TheSectorM.Name  := TMPSector.Name ;
           end;
         MODIFIED := TRUE;
        end;
   1 : if ORISector.Ambient <> TMPSector.Ambient then
        begin
         {selection}
         TheSector.Ambient := TMPSector.Ambient;
         {multiselection}
         if SC_MULTIS.Count <> 0 then
          for m := 0 to SC_MULTIS.Count - 1 do
           begin
            TheSectorM   := TSector(MAP_SEC.Objects[StrToInt(Copy(SC_MULTIS[m],1,4))]);
            TheSectorM.Ambient  := TMPSector.Ambient ;
           end;
         MODIFIED := TRUE;
        end;
   2 : if ORISector.Flag1 <> TMPSector.Flag1 then
        begin
         {selection}
         TheSector.Flag1 := TMPSector.Flag1;
         { update elev (door and exploding), secret if necessary }
         if (TheSector.Flag1 and 2) <> 0 then
          begin
           TheSector.Elevator := TRUE;
           if TheSector.InfClasses.IndexOf('D') = -1 then
            begin
             TheInfCls := TInfClass.Create;
             TheInfCls.IsElev := TRUE;
             TheInfCls.Name := 'E. FLAG Door';
             TheSector.InfClasses.AddObject('D', TheInfCls);
            end;
          end
         else
          begin
           if TheSector.InfClasses.IndexOf('D') <> -1 then
            begin
             TheSector.InfClasses.Delete(TheSector.InfClasses.IndexOf('D'));
             {find if it is still an elev}
             if TheSector.InfClasses.Count = 0 then
              TheSector.Elevator := FALSE
             else
              begin
               found := FALSE;
               for i := 0 to TheSector.InfClasses.Count - 1 do
                begin
                 TheInfCls := TInfClass(TheSector.InfClasses.Objects[i]);
                 if TheInfCls.IsElev then
                  begin
                   found := TRUE;
                   break;
                  end;
                end;
               TheSector.Elevator := found;
              end;
            end;
          end;

         if (TheSector.Flag1 and 64) <> 0 then
          begin
           TheSector.Elevator := TRUE;
           if TheSector.InfClasses.IndexOf('X') = -1 then
            begin
             TheInfCls := TInfClass.Create;
             TheInfCls.IsElev := TRUE;
             TheInfCls.Name := 'E. FLAG Exploding';
             TheSector.InfClasses.AddObject('X', TheInfCls);
            end;
          end
         else
          begin
           if TheSector.InfClasses.IndexOf('X') <> -1 then
            begin
             TheSector.InfClasses.Delete(TheSector.InfClasses.IndexOf('X'));
             {find if it is still an elev}
             if TheSector.InfClasses.Count = 0 then
              TheSector.Elevator := FALSE
             else
              begin
               found := FALSE;
               for i := 0 to TheSector.InfClasses.Count - 1 do
                begin
                 TheInfCls := TInfClass(TheSector.InfClasses.Objects[i]);
                 if TheInfCls.IsElev then
                  begin
                   found := TRUE;
                   break;
                  end;
                end;
               TheSector.Elevator := found;
              end;
            end;
          end;

         if (TheSector.Flag1 and 524288) <> 0 then
          TheSector.Secret := TRUE
         else
          TheSector.Secret := FALSE;

         {multiselection}
         if SC_MULTIS.Count <> 0 then
          for m := 0 to SC_MULTIS.Count - 1 do
           begin
            TheSectorM   := TSector(MAP_SEC.Objects[StrToInt(Copy(SC_MULTIS[m],1,4))]);
            {Flag is updated, not copied !}
            xor_flag   := ORISector.Flag1 xor TMPSector.Flag1;
            set_flag   := xor_flag and TMPSector.Flag1;
            reset_flag := xor_flag and ORISector.Flag1;
            TheSectorM.Flag1 := (TheSectorM.Flag1 or set_flag) and not reset_flag;
            {!!!!!update elev (door and exploding), secret if necessary }
            if (TheSectorM.Flag1 and 2) <> 0 then
             begin
              TheSectorM.Elevator := TRUE;
              if TheSectorM.InfClasses.IndexOf('D') = -1 then
               begin
                TheInfCls := TInfClass.Create;
                TheInfCls.IsElev := TRUE;
                TheInfCls.Name := 'E. FLAG Door';
                TheSectorM.InfClasses.AddObject('D', TheInfCls);
               end;
             end
            else
             begin
              if TheSectorM.InfClasses.IndexOf('D') <> -1 then
               begin
                TheSectorM.InfClasses.Delete(TheSectorM.InfClasses.IndexOf('D'));
                {find if it is still an elev}
                if TheSectorM.InfClasses.Count = 0 then
                 TheSectorM.Elevator := FALSE
                else
                 begin
                  found := FALSE;
                  for i := 0 to TheSectorM.InfClasses.Count - 1 do
                   begin
                    TheInfCls := TInfClass(TheSectorM.InfClasses.Objects[i]);
                    if TheInfCls.IsElev then
                     begin
                      found := TRUE;
                      break;
                     end;
                   end;
                  TheSectorM.Elevator := found;
                 end;
               end;
             end;

            if (TheSectorM.Flag1 and 64) <> 0 then
             begin
              TheSectorM.Elevator := TRUE;
              if TheSectorM.InfClasses.IndexOf('X') = -1 then
               begin
                TheInfCls := TInfClass.Create;
                TheInfCls.IsElev := TRUE;
                TheInfCls.Name := 'E. FLAG Exploding';
                TheSectorM.InfClasses.AddObject('X', TheInfCls);
               end;
             end
            else
             begin
              if TheSectorM.InfClasses.IndexOf('X') <> -1 then
               begin
                TheSectorM.InfClasses.Delete(TheSectorM.InfClasses.IndexOf('D'));
                {find if it is still an elev}
                if TheSectorM.InfClasses.Count = 0 then
                 TheSectorM.Elevator := FALSE
                else
                 begin
                  found := FALSE;
                  for i := 0 to TheSectorM.InfClasses.Count - 1 do
                   begin
                    TheInfCls := TInfClass(TheSectorM.InfClasses.Objects[i]);
                    if TheInfCls.IsElev then
                     begin
                      found := TRUE;
                      break;
                     end;
                   end;
                  TheSectorM.Elevator := found;
                 end;
               end;
             end;

            if (TheSectorM.Flag1 and 524288) <> 0 then
             TheSectorM.Secret := TRUE
            else
             TheSectorM.Secret := FALSE;
           end;
         MODIFIED := TRUE;
        end;
   3 : if ORISector.Flag2 <> TMPSector.Flag2 then
        begin
         {selection}
         TheSector.Flag2 := TMPSector.Flag2;
         {multiselection}
         if SC_MULTIS.Count <> 0 then
          for m := 0 to SC_MULTIS.Count - 1 do
           begin
            TheSectorM   := TSector(MAP_SEC.Objects[StrToInt(Copy(SC_MULTIS[m],1,4))]);
            {Flag is updated, not copied !}
            xor_flag   := ORISector.Flag2 xor TMPSector.Flag2;
            set_flag   := xor_flag and TMPSector.Flag2;
            reset_flag := xor_flag and ORISector.Flag2;
            TheSectorM.Flag2 := (TheSectorM.Flag2 or set_flag) and not reset_flag;
           end;
         MODIFIED := TRUE;
        end;
   4 : if ORISector.Flag3 <> TMPSector.Flag3 then
        begin
         {selection}
         TheSector.Flag3 := TMPSector.Flag3;
         {multiselection}
         if SC_MULTIS.Count <> 0 then
          for m := 0 to SC_MULTIS.Count - 1 do
           begin
            TheSectorM   := TSector(MAP_SEC.Objects[StrToInt(Copy(SC_MULTIS[m],1,4))]);
            {Flag is updated, not copied !}
            xor_flag   := ORISector.Flag3 xor TMPSector.Flag3;
            set_flag   := xor_flag and TMPSector.Flag3;
            reset_flag := xor_flag and ORISector.Flag3;
            TheSectorM.Flag3 := (TheSectorM.Flag3 or set_flag) and not reset_flag;
           end;
         MODIFIED := TRUE;
        end;
   5 : if ORISector.Floor_Alt <> TMPSector.Floor_Alt then
        begin
         {selection}
         TheSector.Floor_Alt := TMPSector.Floor_Alt;
         {multiselection}
         if SC_MULTIS.Count <> 0 then
          for m := 0 to SC_MULTIS.Count - 1 do
           begin
            TheSectorM   := TSector(MAP_SEC.Objects[StrToInt(Copy(SC_MULTIS[m],1,4))]);
            TheSectorM.Floor_Alt  := TMPSector.Floor_Alt ;
           end;
         MODIFIED := TRUE;
        end;
   6 : if ORISector.Floor.Name <> TMPSector.Floor.Name then
        begin
         {selection}
         TheSector.Floor.Name := UpperCase(TMPSector.Floor.Name);
         {multiselection}
         if SC_MULTIS.Count <> 0 then
          for m := 0 to SC_MULTIS.Count - 1 do
           begin
            TheSectorM   := TSector(MAP_SEC.Objects[StrToInt(Copy(SC_MULTIS[m],1,4))]);
            TheSectorM.Floor.Name  := UpperCase(TMPSector.Floor.Name);
           end;
         MODIFIED := TRUE;
        {add to textures}
        if TX_LIST.IndexOf(UpperCase(TMPSector.Floor.Name)) = -1 then
         TX_LIST.Add(UpperCase(TMPSector.Floor.Name));
        end;
   7 : if ORISector.Floor.f1 <> TMPSector.Floor.f1 then
        begin
         {selection}
         TheSector.Floor.f1 := TMPSector.Floor.f1;
         {multiselection}
         if SC_MULTIS.Count <> 0 then
          for m := 0 to SC_MULTIS.Count - 1 do
           begin
            TheSectorM   := TSector(MAP_SEC.Objects[StrToInt(Copy(SC_MULTIS[m],1,4))]);
            TheSectorM.Floor.f1  := TMPSector.Floor.f1 ;
           end;
         MODIFIED := TRUE;
        end;
   8 : if ORISector.Floor.f2 <> TMPSector.Floor.f2 then
        begin
         {selection}
         TheSector.Floor.f2 := TMPSector.Floor.f2;
         {multiselection}
         if SC_MULTIS.Count <> 0 then
          for m := 0 to SC_MULTIS.Count - 1 do
           begin
            TheSectorM   := TSector(MAP_SEC.Objects[StrToInt(Copy(SC_MULTIS[m],1,4))]);
            TheSectorM.Floor.f2  := TMPSector.Floor.f2 ;
           end;
         MODIFIED := TRUE;
        end;
   9 : if ORISector.Floor.i <> TMPSector.Floor.i then
        begin
         {selection}
         TheSector.Floor.i := TMPSector.Floor.i;
         {multiselection}
         if SC_MULTIS.Count <> 0 then
          for m := 0 to SC_MULTIS.Count - 1 do
           begin
            TheSectorM   := TSector(MAP_SEC.Objects[StrToInt(Copy(SC_MULTIS[m],1,4))]);
            TheSectorM.Floor.i  := TMPSector.Floor.i ;
           end;
         MODIFIED := TRUE;
        end;
  10 : if ORISector.Ceili_Alt <> TMPSector.Ceili_Alt then
        begin
         {selection}
         TheSector.Ceili_Alt := TMPSector.Ceili_Alt;
         {multiselection}
         if SC_MULTIS.Count <> 0 then
          for m := 0 to SC_MULTIS.Count - 1 do
           begin
            TheSectorM   := TSector(MAP_SEC.Objects[StrToInt(Copy(SC_MULTIS[m],1,4))]);
            TheSectorM.Ceili_Alt  := TMPSector.Ceili_Alt;
           end;
         MODIFIED := TRUE;
        end;
  11 : if ORISector.Ceili.Name <> TMPSector.Ceili.Name then
        begin
         {selection}
         TheSector.Ceili.Name := UpperCase(TMPSector.Ceili.Name);
         {multiselection}
         if SC_MULTIS.Count <> 0 then
          for m := 0 to SC_MULTIS.Count - 1 do
           begin
            TheSectorM   := TSector(MAP_SEC.Objects[StrToInt(Copy(SC_MULTIS[m],1,4))]);
            TheSectorM.Ceili.Name  := UpperCase(TMPSector.Ceili.Name);
           end;
         MODIFIED := TRUE;
        {add to textures}
        if TX_LIST.IndexOf(UpperCase(TMPSector.Ceili.Name)) = -1 then
         TX_LIST.Add(UpperCase(TMPSector.Ceili.Name));
        end;
  12 : if ORISector.Ceili.f1 <> TMPSector.Ceili.f1 then
        begin
         {selection}
         TheSector.Ceili.f1 := TMPSector.Ceili.f1;
         {multiselection}
         if SC_MULTIS.Count <> 0 then
          for m := 0 to SC_MULTIS.Count - 1 do
           begin
            TheSectorM   := TSector(MAP_SEC.Objects[StrToInt(Copy(SC_MULTIS[m],1,4))]);
            TheSectorM.Ceili.f1  := TMPSector.Ceili.f1 ;
           end;
         MODIFIED := TRUE;
        end;
  13 : if ORISector.Ceili.f2 <> TMPSector.Ceili.f2 then
        begin
         {selection}
         TheSector.Ceili.f2 := TMPSector.Ceili.f2;
         {multiselection}
         if SC_MULTIS.Count <> 0 then
          for m := 0 to SC_MULTIS.Count - 1 do
           begin
            TheSectorM   := TSector(MAP_SEC.Objects[StrToInt(Copy(SC_MULTIS[m],1,4))]);
            TheSectorM.Ceili.f2  := TMPSector.Ceili.f2 ;
           end;
         MODIFIED := TRUE;
        end;
  14 : if ORISector.Ceili.i <> TMPSector.Ceili.i then
        begin
         {selection}
         TheSector.Ceili.i := TMPSector.Ceili.i;
         {multiselection}
         if SC_MULTIS.Count <> 0 then
          for m := 0 to SC_MULTIS.Count - 1 do
           begin
            TheSectorM   := TSector(MAP_SEC.Objects[StrToInt(Copy(SC_MULTIS[m],1,4))]);
            TheSectorM.Ceili.i  := TMPSector.Ceili.i ;
           end;
         MODIFIED := TRUE;
        end;
  15 : if ORISector.Second_Alt <> TMPSector.Second_Alt then
        begin
         {selection}
         TheSector.Second_Alt := TMPSector.Second_Alt;
         {multiselection}
         if SC_MULTIS.Count <> 0 then
          for m := 0 to SC_MULTIS.Count - 1 do
           begin
            TheSectorM   := TSector(MAP_SEC.Objects[StrToInt(Copy(SC_MULTIS[m],1,4))]);
            TheSectorM.Second_Alt := TMPSector.Second_Alt;
           end;
         MODIFIED := TRUE;
        end;
  16 : if ORISector.Layer <> TMPSector.Layer then
        begin
         {selection}
         TheSector.Layer := TMPSector.Layer;
         {multiselection}
         if SC_MULTIS.Count <> 0 then
          for m := 0 to SC_MULTIS.Count - 1 do
           begin
            TheSectorM   := TSector(MAP_SEC.Objects[StrToInt(Copy(SC_MULTIS[m],1,4))]);
            TheSectorM.Layer  := TMPSector.Layer;
           end;
         MODIFIED := TRUE;
         {create new layer if necessary}
         if TheSector.Layer > LAYER_MAX then LAYER_MAX := TheSector.Layer;
         if TheSector.Layer < LAYER_MIN then LAYER_MIN := TheSector.Layer;
         MapWindow.LScrollBar.SetParams(-LAYER, -LAYER_MAX, -LAYER_MIN);
        end;
 END;
end;

procedure DO_ForceCommit_SectorEditorField(field : Integer);
begin
 TMPSector := TSector.Create;
 if not Check_SectorEditorField(field) then
  begin
   TMPSector.Free;
   exit;
  end;


 if not IGNORE_UNDO and CONFIRMMultiUpdate and (SC_MULTIS.Count <> 0) then
  begin
   if Application.MessageBox('Confirm Multiple Update ?',
                            'WDFUSE Sector Editor - Force Update Sectors',
                            mb_YesNo or mb_IconQuestion) = idNo
    then exit;
  end;

 ORISector := TSector.Create;
 ORISector.Name       := '/////';
 ORISector.Ambient    := -12345;
 ORISector.Flag1      := -87654321;
 ORISector.Flag2      := -87654321;
 ORISector.Flag3      := -87654321;
 ORISector.Floor_Alt  := -9876543.21;
 ORISector.Floor.Name := '/////';
 ORISector.Floor.f1   := -9876543.21;
 ORISector.Floor.f2   := -9876543.21;
 ORISector.Floor.i    := -12345;
 ORISector.Ceili_Alt  := -9876543.21;
 ORISector.Ceili.Name := '/////';
 ORISector.Ceili.f1   := -9876543.21;
 ORISector.Ceili.f2   := -9876543.21;
 ORISector.Ceili.i    := -12345;
 ORISector.Second_Alt := -9876543.21;
 ORISector.Layer      := -12345;

 DO_Commit_SectorEditorField(field);

 TMPSector.Free;
 ORISector.Free;
 MapWindow.Map.Invalidate;
end;


{WALL EDITOR **************************************************************}
{WALL EDITOR **************************************************************}
{WALL EDITOR **************************************************************}

procedure DO_Fill_WallEditor;
var
  TheSector : TSector;
  TheWall   : TWall;
  numwl     : Integer;
  height    : Real;
  length    : Real;
  vx1, vx2  : TVertex;
begin
 TheSector := TSector(MAP_SEC.Objects[SC_HILITE]);
 numwl     := TheSector.Wl.Count;
 TheWall   := TWall(TheSector.Wl.Objects[WL_HILITE]);
 WallEditor.Caption := Format('WL %d of %d, SC %d', [WL_HILITE, numwl, SC_HILITE]);

 WallEditor.WLEd.Cells[1,  0] := IntToStr(TheWall.Adjoin);
 WallEditor.WLEd.Cells[1,  1] := IntToStr(TheWall.Mirror);
 WallEditor.WLEd.Cells[1,  2] := IntToStr(TheWall.Walk);
 WallEditor.WLEd.Cells[1,  3] := IntToStr(TheWall.Light);
 WallEditor.WLEd.Cells[1,  4] := IntToStr(TheWall.Flag1);
 WallEditor.WLEd.Cells[1,  5] := IntToStr(TheWall.Flag2);
 WallEditor.WLEd.Cells[1,  6] := IntToStr(TheWall.Flag3);
 WallEditor.WLEd.Cells[1,  7] := TheWall.Mid.Name;
 WallEditor.WLEd.Cells[1,  8] := PosTrim(TheWall.Mid.f1);
 WallEditor.WLEd.Cells[1,  9] := PosTrim(TheWall.Mid.f2);
 WallEditor.WLEd.Cells[1, 10] := IntToStr(TheWall.Mid.i);
 WallEditor.WLEd.Cells[1, 11] := TheWall.Top.Name;
 WallEditor.WLEd.Cells[1, 12] := PosTrim(TheWall.Top.f1);
 WallEditor.WLEd.Cells[1, 13] := PosTrim(TheWall.Top.f2);
 WallEditor.WLEd.Cells[1, 14] := IntToStr(TheWall.Top.i);
 WallEditor.WLEd.Cells[1, 15] := TheWall.Bot.Name;
 WallEditor.WLEd.Cells[1, 16] := PosTrim(TheWall.Bot.f1);
 WallEditor.WLEd.Cells[1, 17] := PosTrim(TheWall.Bot.f2);
 WallEditor.WLEd.Cells[1, 18] := IntToStr(TheWall.Bot.i);
 WallEditor.WLEd.Cells[1, 19] := TheWall.Sign.Name;
 WallEditor.WLEd.Cells[1, 20] := PosTrim(TheWall.Sign.f1);
 WallEditor.WLEd.Cells[1, 21] := PosTrim(TheWall.Sign.f2);

 WallEditor.PanelSCName.Caption := TheSector.Name;
 WallEditor.PanelFloorAlt.Caption := Format('%-5.2f && %-5.2f', [TheSector.Floor_Alt, TheSector.Ceili_Alt]);
 height := TheSector.Ceili_Alt - TheSector.Floor_Alt;
 WallEditor.PanelHeight.Caption := PosTrim(height);
 vx1 := TVertex(TheSector.Vx.Objects[TheWall.left_vx]);
 vx2 := TVertex(TheSector.Vx.Objects[TheWall.right_vx]);
 length := sqrt(sqr(vx1.X - vx2.X)+sqr(vx1.Z - vx2.Z));
 WallEditor.Panellength.Caption := PosTrim(length);
 WallEditor.PanelLRVX.Caption := Format('%d && %d', [TheWall.left_vx, TheWall.right_vx]);

 // Add Wall Length Changing
 WallEditor.WLEd.Cells[1, 22] := PosTrim(length);

  // Reset Focus
 if not AUTOCOMMIT_FLAG and not INF_READ and not APPLYING_UNDO and  WallEditor.visible then
   begin
     WallEditor.FormCreate(NIL);
     WallEditor.SetFocus;
     MapWindow.SetFocus;
   end;
 MapWindow.Invalidate;

 DO_WallEditor_Specials_Init;
 DO_WallEditor_Specials(0);

 if WL_MULTIS.Count = 0 then
  begin
   WallEditor.ShapeMulti.Brush.Color := clBtnFace;
   WallEditor.ForceCurrentField.Enabled := FALSE;
  end
 else
  begin
   WallEditor.ShapeMulti.Brush.Color := clRed;
   WallEditor.ForceCurrentField.Enabled := TRUE;
  end;

 if TheWall.InfItems.Count = 0 then
  begin
   WallEditor.INFButton.Visible := False;
   WallEditor.INFButtonOff.Visible := True;
  end
 else
  begin
   WallEditor.INFButton.Visible := True;
   WallEditor.INFButtonOff.Visible := False;

  end;

 //Force update - not during Undos
 if not APPLYING_UNDO and INFWindow2.Visible and INFWindow2.ontop then
    begin
      MapWindow.SpeedButtonINFClick(NIL);
      MapWindow.SetFocus;
    end;

end;

procedure DO_WallEditor_Specials_Init;
var
  TheSector : TSector;
  TheWall   : TWall;
  i         : Integer;
  TheInfCls : TInfClass;
  TheClass  : String;
begin
 TheSector := TSector(MAP_SEC.Objects[SC_HILITE]);
 TheWall   := TWall(TheSector.Wl.Objects[WL_HILITE]);

 WallEditor.CBClass.Enabled := TRUE;
 WallEditor.CBSlaCLi.Enabled := TRUE;
 WallEditor.CBClass.Clear;
 WallEditor.CBSlaCli.Clear;

 IF TheWall.InfClasses.Count <> 0 THEN
  BEGIN
   for i := 0 to TheWall.InfClasses.Count - 1 do
    begin
     TheInfCls := TinfClass(TheWall.InfClasses.Objects[i]);
     if TheInfCls.IsElev then
      TheClass := 'E. '
     else
      TheClass := 'T. ';
     WallEditor.CBClass.Items.Add({TheClass +} TheInfCls.Name);
    end;
  END
 ELSE
  BEGIN
   WallEditor.CBClass.Enabled := FALSE;
   WallEditor.CBSlaCLi.Enabled := FALSE;
  END;
 SUPERHILITE := -1;
end;

procedure DO_WallEditor_Specials(c : Integer);
var
  TheSector : TSector;
  TheWall   : TWall;
  TheInfCls : TInfClass;
begin
 TheSector := TSector(MAP_SEC.Objects[SC_HILITE]);
 TheWall   := TWall(TheSector.Wl.Objects[WL_HILITE]);

 if TheWall.InfClasses.Count <> 0 then
 BEGIN
  WallEditor.CBClass.ItemIndex := c;
  if WallEditor.CBClass.Items[c][1] = 'E' then
   WallEditor.PanelSlaCli.Caption := 'slave:'
  else
   if WallEditor.CBClass.Items[c][1] = 'T' then
    WallEditor.PanelSlaCli.Caption := 'client:'
   else
    WallEditor.PanelSlaCli.Caption := 'target:';

  WallEditor.CBSlaCli.Clear;
  TheInfCls := TInfClass(TheWall.InfClasses.Objects[c]);
  if TheInfCls.SlaCli.Count <> 0 then
   begin
    WallEditor.CBSlaCli.Items.AddStrings(TheInfCls.SlaCli);
    WallEditor.CBSlaCli.ItemIndex := 0;
    SUPERHILITE := -1;
     if GetSectorNumFromName(WallEditor.CBSlaCli.Items[0], SUPERHILITE)
      then
       begin
        MapWindow.Refresh;
       end;
   end;
 END;
end;

function  Check_AllWallEditor : Boolean;
var i      : Integer;
begin
 Result := TRUE;
 for i := 0 to 21 do
  begin
   Result := Result and Check_WallEditorField(i);
   if not Result then break;
  end;
end;

function  Check_WallEditorField(field : Integer) : Boolean;
var
  AReal               : Real;
  AInt                : Integer;
  ALong               : LongInt;
  Code                : Integer;
  title               : array[0..60] of char;
begin
 StrCopy(Title, 'Wall Editor Error');
 Check_WallEditorField := TRUE;
 CASE field of
   0 : begin
        { Adjoin }
        Val(WallEditor.WLEd.Cells[1,  0], AInt, Code);
        if Code = 0 then
         if AInt >= -1 then
          if AInt < MAP_SEC.Count then
           TMPWall.Adjoin := AInt
          else
           begin
            Application.MessageBox('Adjoin must be an existing sector', Title, mb_Ok or mb_IconExclamation);
            Check_WallEditorField := FALSE;
           end
         else
          begin
           Application.MessageBox('Adjoin must be >= -1', Title, mb_Ok or mb_IconExclamation);
           Check_WallEditorField := FALSE;
          end
        else
         begin
          Application.MessageBox('Wrong value for Adjoin', Title, mb_Ok or mb_IconExclamation);
          Check_WallEditorField := FALSE;
         end;
       end;
   1 : begin
        { Mirror }
        Val(WallEditor.WLEd.Cells[1,  1], AInt, Code);
        if Code = 0 then
         if AInt >= -1 then
          TMPWall.Mirror := AInt
         else
          begin
           Application.MessageBox('Mirror must be >= -1', Title, mb_Ok or mb_IconExclamation);
           Check_WallEditorField := FALSE;
          end
        else
         begin
          Application.MessageBox('Wrong value for Mirror', Title, mb_Ok or mb_IconExclamation);
          Check_WallEditorField := FALSE;
         end;
       end;
   2 : begin
        { Walk }
        Val(WallEditor.WLEd.Cells[1,  2], AInt, Code);
        if Code = 0 then
         if AInt >= -1 then
          TMPWall.Walk := AInt
         else
          begin
           Application.MessageBox('Walk must be >= -1', Title, mb_Ok or mb_IconExclamation);
           Check_WallEditorField := FALSE;
          end
        else
         begin
          Application.MessageBox('Wrong value for Walk', Title, mb_Ok or mb_IconExclamation);
          Check_WallEditorField := FALSE;
         end;
       end;
   3 : begin
        { Light }
        Val(WallEditor.WLEd.Cells[1,  3], AInt, Code);
        if Code = 0 then
         TMPWall.Light := AInt
        else
         begin
          Application.MessageBox('Wrong value for Light', Title, mb_Ok or mb_IconExclamation);
          Check_WallEditorField := FALSE;
         end;
       end;
   4 : begin
        { Flag1 }
        Val(WallEditor.WLEd.Cells[1,  4], ALong, Code);
        if Code = 0 then
         if ALong >= 0 then
          TMPWall.Flag1 := ALong
         else
          begin
           Application.MessageBox('Flag1 must be >= 0', Title, mb_Ok or mb_IconExclamation);
           Check_WallEditorField := FALSE;
          end
        else
         begin
          Application.MessageBox('Wrong value for Flag1', Title, mb_Ok or mb_IconExclamation);
          Check_WallEditorField := FALSE;
         end;
       end;
   5 : begin
        { Flag2 }
        Val(WallEditor.WLEd.Cells[1,  5], ALong, Code);
        if Code = 0 then
         if ALong >= 0 then
          TMPWall.Flag2 := ALong
         else
          begin
           Application.MessageBox('Flag2 must be >= 0', Title, mb_Ok or mb_IconExclamation);
           Check_WallEditorField := FALSE;
          end
        else
         begin
          Application.MessageBox('Wrong value for Flag2', Title, mb_Ok or mb_IconExclamation);
          Check_WallEditorField := FALSE;
         end;
       end;
   6 : begin
        { Flag3 }
        Val(WallEditor.WLEd.Cells[1,  6], ALong, Code);
        if Code = 0 then
         if ALong >= 0 then
          TMPWall.Flag3 := ALong
         else
          begin
           Application.MessageBox('Flag3 must be >= 0', Title, mb_Ok or mb_IconExclamation);
           Check_WallEditorField := FALSE;
          end
        else
         begin
          Application.MessageBox('Wrong value for Flag3', Title, mb_Ok or mb_IconExclamation);
          Check_WallEditorField := FALSE;
         end;
       end;
   7 : begin
        { MID name }
        if Length(WallEditor.WLEd.Cells[1,  7]) < 13 then
         TMPWall.Mid.Name := WallEditor.WLEd.Cells[1,  7]
        else
         begin
          Application.MessageBox('Mid Name too long', Title, mb_Ok or mb_IconExclamation);
          Check_WallEditorField := FALSE;
         end;
       end;
   8 : begin
        { MID X Offset }
        Val(WallEditor.WLEd.Cells[1,  8], AReal, Code);
        if Code = 0 then
          TMPWall.Mid.f1 := AReal
        else
         begin
          Application.MessageBox('Wrong value for Mid Tx X Offset', Title, mb_Ok or mb_IconExclamation);
          Check_WallEditorField := FALSE;
         end;
       end;
   9 : begin
        { MID Y Offset }
        Val(WallEditor.WLEd.Cells[1,  9], AReal, Code);
        if Code = 0 then
         TMPWall.Mid.f2 := AReal
        else
         begin
          Application.MessageBox('Wrong value for Mid Tx Y Offset', Title, mb_Ok or mb_IconExclamation);
          Check_WallEditorField := FALSE;
         end;
       end;
  10 : begin
        { MID i }
        Val(WallEditor.WLEd.Cells[1, 10], AInt, Code);
        if Code = 0 then
         TMPWall.Mid.i := AInt
        else
         begin
          Application.MessageBox('Wrong value for Mid Tx #', Title, mb_Ok or mb_IconExclamation);
          Check_WallEditorField := FALSE;
         end;
       end;
  11 : begin
        { Top name }
        if Length(WallEditor.WLEd.Cells[1,  11]) < 13 then
         TMPWall.Top.Name := WallEditor.WLEd.Cells[1, 11]
        else
         begin
          Application.MessageBox('Top Name too long', Title, mb_Ok or mb_IconExclamation);
          Check_WallEditorField := FALSE;
         end;
       end;
  12 : begin
        { Top X Offset }
        Val(WallEditor.WLEd.Cells[1, 12], AReal, Code);
        if Code = 0 then
          TMPWall.Top.f1 := AReal
        else
         begin
          Application.MessageBox('Wrong value for Top Tx X Offset', Title, mb_Ok or mb_IconExclamation);
          Check_WallEditorField := FALSE;
         end;
       end;
  13 : begin
        { Top Y Offset }
        Val(WallEditor.WLEd.Cells[1, 13], AReal, Code);
        if Code = 0 then
         TMPWall.Top.f2 := AReal
        else
         begin
          Application.MessageBox('Wrong value for Top Tx Y Offset', Title, mb_Ok or mb_IconExclamation);
          Check_WallEditorField := FALSE;
         end;
       end;
  14 : begin
        { Top i }
        Val(WallEditor.WLEd.Cells[1, 14], AInt, Code);
        if Code = 0 then
         TMPWall.Top.i := AInt
        else
         begin
          Application.MessageBox('Wrong value for Top Tx #', Title, mb_Ok or mb_IconExclamation);
          Check_WallEditorField := FALSE;
         end;
       end;
  15 : begin
        if Length(WallEditor.WLEd.Cells[1,  15]) < 13 then
         TMPWall.Bot.Name := WallEditor.WLEd.Cells[1, 15]
        else
         begin
          Application.MessageBox('Bot Name too long', Title, mb_Ok or mb_IconExclamation);
          Check_WallEditorField := FALSE;
         end;
       end;
  16 : begin
        { Bot X Offset }
        Val(WallEditor.WLEd.Cells[1, 16], AReal, Code);
        if Code = 0 then
         TMPWall.Bot.f1 := AReal
        else
         begin
          Application.MessageBox('Wrong value for Bot Tx X Offset', Title, mb_Ok or mb_IconExclamation);
          Check_WallEditorField := FALSE;
         end;
       end;
  17 : begin
        { Bot Y Offset }
        Val(WallEditor.WLEd.Cells[1, 17], AReal, Code);
        if Code = 0 then
         TMPWall.Bot.f2 := AReal
        else
         begin
          Application.MessageBox('Wrong value for Bot Tx Y Offset', Title, mb_Ok or mb_IconExclamation);
          Check_WallEditorField := FALSE;
         end;
       end;
  18 : begin
        { Bot i }
        Val(WallEditor.WLEd.Cells[1, 18], AInt, Code);
        if Code = 0 then
         TMPWall.Bot.i := AInt
        else
         begin
          Application.MessageBox('Wrong value for Bot Tx #', Title, mb_Ok or mb_IconExclamation);
          Check_WallEditorField := FALSE;
         end;
       end;
  19 : begin
        { Sign name }
        if Length(WallEditor.WLEd.Cells[1,  19]) < 13 then
         TMPWall.Sign.Name := WallEditor.WLEd.Cells[1, 19]
        else
         begin
          Application.MessageBox('Sign Name too long', Title, mb_Ok or mb_IconExclamation);
          Check_WallEditorField := FALSE;
         end;
       end;
  20 : begin
        { Sign X Offset }
        Val(WallEditor.WLEd.Cells[1, 20], AReal, Code);
        if Code = 0 then
          TMPWall.Sign.f1 := AReal
        else
         begin
          Application.MessageBox('Wrong value for Sgn Tx X Offset', Title, mb_Ok or mb_IconExclamation);
          Check_WallEditorField := FALSE;
         end;
       end;
  21 : begin
        { Sign Y Offset }
        Val(WallEditor.WLEd.Cells[1, 21], AReal, Code);
        if Code = 0 then
         TMPWall.Sign.f2 := AReal
        else
         begin
          Application.MessageBox('Wrong value for Sgn Tx Y Offset', Title, mb_Ok or mb_IconExclamation);
          Check_WallEditorField := FALSE;
         end;
       end;
 END;
end;

function  CompareTwoWalls(WallA: TWall; WallB: TWall) : Boolean;
begin
Result := False;
if (WallA.Adjoin    = WallB.Adjoin) and
   (WallA.Mirror    = WallB.Mirror) and
   (WallA.Walk      = WallB.Walk) and
   (WallA.Light     = WallB.Light) and
   (WallA.Flag1     = WallB.Flag1) and
   (WallA.Flag2     = WallB.Flag2) and
   (WallA.Flag3     = WallB.Flag3) and
   (WallA.Mid.Name  = WallB.Mid.Name) and
   (WallA.Mid.f1    = WallB.Mid.f1) and
   (WallA.Mid.f2    = WallB.Mid.f2) and
   (WallA.Mid.i     = WallB.Mid.i ) and
   (WallA.Top.Name  = WallB.Top.Name ) and
   (WallA.Top.f1    = WallB.Top.f1 ) and
   (WallA.Top.f2    = WallB.Top.f2 ) and
   (WallA.Top.i     = WallB.Top.i ) and
   (WallA.Bot.Name  = WallB.Bot.Name ) and
   (WallA.Bot.f1    = WallB.Bot.f1  ) and
   (WallA.Bot.f2    = WallB.Bot.f2  ) and
   (WallA.Bot.i     = WallB.Bot.i ) and
   (WallA.Sign.Name = WallB.Sign.Name ) and
   (WallA.Sign.f1   = WallB.Sign.f1 ) and
   (WallA.Sign.f2   = WallB.Sign.f2 ) then Result := True;
end;

procedure DO_Commit_WallEditorField(field : Integer);
var
  TheSector           : TSector;
  TheWall             : TWall;
  TheSectorM          : TSector;
  TheWallM            : TWall;
  m                   : Integer;
  xor_flag,
  set_flag,
  reset_flag          : LongInt;
begin
 TheSector := TSector(MAP_SEC.Objects[SC_HILITE]);
 TheWall   := TWall(TheSector.Wl.Objects[WL_HILITE]);

 CASE field of
   0 : if ORIWall.Adjoin <> TMPWall.Adjoin then
        begin
         {selection}
         TheWall.Adjoin := TMPWall.Adjoin;
         {multiselection}
         { !! NOT ALLOWED !!
         if WL_MULTIS.Count <> 0 then
          for m := 0 to WL_MULTIS.Count - 1 do
           begin
            TheSectorM   := TSector(MAP_SEC.Objects[StrToInt(Copy(WL_MULTIS[m],1,4))]);
            TheWallM     := TWall(TheSectorM.Wl.Objects[StrToInt(Copy(WL_MULTIS[m],5,4))]);
            TheWallM.Adjoin := TMPWall.Adjoin;
           end;
         }
         MODIFIED := TRUE;
        end;
   1 : if ORIWall.Mirror <> TMPWall.Mirror then
        begin
         {selection}
         TheWall.Mirror := TMPWall.Mirror;
         {multiselection}
         { !! NOT ALLOWED !!
         if WL_MULTIS.Count <> 0 then
          for m := 0 to WL_MULTIS.Count - 1 do
           begin
            TheSectorM   := TSector(MAP_SEC.Objects[StrToInt(Copy(WL_MULTIS[m],1,4))]);
            TheWallM     := TWall(TheSectorM.Wl.Objects[StrToInt(Copy(WL_MULTIS[m],5,4))]);
            TheWallM.Mirror := TMPWall.Mirror;
           end;
          }
         MODIFIED := TRUE;
        end;
   2 : if ORIWall.Walk <> TMPWall.Walk then
        begin
         {selection}
         TheWall.Walk := TMPWall.Walk;
         {multiselection}
         { !! NOT ALLOWED !!
         if WL_MULTIS.Count <> 0 then
          for m := 0 to WL_MULTIS.Count - 1 do
           begin
            TheSectorM   := TSector(MAP_SEC.Objects[StrToInt(Copy(WL_MULTIS[m],1,4))]);
            TheWallM     := TWall(TheSectorM.Wl.Objects[StrToInt(Copy(WL_MULTIS[m],5,4))]);
            TheWallM.Walk := TMPWall.Walk;
           end;
         }
         MODIFIED := TRUE;
        end;
   3 : if ORIWall.Light <> TMPWall.Light then
        begin
         {selection}
         TheWall.Light := TMPWall.Light;
         {multiselection}
         if WL_MULTIS.Count <> 0 then
          for m := 0 to WL_MULTIS.Count - 1 do
           begin
            TheSectorM   := TSector(MAP_SEC.Objects[StrToInt(Copy(WL_MULTIS[m],1,4))]);
            TheWallM     := TWall(TheSectorM.Wl.Objects[StrToInt(Copy(WL_MULTIS[m],5,4))]);
            TheWallM.Light := TMPWall.Light;
           end;
         MODIFIED := TRUE;
        end;
   4 : if ORIWall.Flag1 <> TMPWall.Flag1 then
        begin
         {selection}
         TheWall.Flag1 := TMPWall.Flag1;
         {multiselection}
         if WL_MULTIS.Count <> 0 then
          for m := 0 to WL_MULTIS.Count - 1 do
           begin
            TheSectorM   := TSector(MAP_SEC.Objects[StrToInt(Copy(WL_MULTIS[m],1,4))]);
            TheWallM     := TWall(TheSectorM.Wl.Objects[StrToInt(Copy(WL_MULTIS[m],5,4))]);
            {Flag is updated, not copied !}
            xor_flag   := ORIWall.Flag1 xor TMPWall.Flag1;
            set_flag   := xor_flag and TMPWall.Flag1;
            reset_flag := xor_flag and ORIWall.Flag1;
            TheWallM.Flag1 := (TheWallM.Flag1 or set_flag) and not reset_flag;
           end;
         MODIFIED := TRUE;
        end;
   5 : if ORIWall.Flag2 <> TMPWall.Flag2 then
        begin
         {selection}
         TheWall.Flag2 := TMPWall.Flag2;
         {multiselection}
         if WL_MULTIS.Count <> 0 then
          for m := 0 to WL_MULTIS.Count - 1 do
           begin
            TheSectorM   := TSector(MAP_SEC.Objects[StrToInt(Copy(WL_MULTIS[m],1,4))]);
            TheWallM     := TWall(TheSectorM.Wl.Objects[StrToInt(Copy(WL_MULTIS[m],5,4))]);
            {Flag is updated, not copied !}
            xor_flag   := ORIWall.Flag2 xor TMPWall.Flag2;
            set_flag   := xor_flag and TMPWall.Flag2;
            reset_flag := xor_flag and ORIWall.Flag2;
            TheWallM.Flag2 := (TheWallM.Flag2 or set_flag) and not reset_flag;
           end;
         MODIFIED := TRUE;
        end;
   6 : if ORIWall.Flag3 <> TMPWall.Flag3 then
        begin
         {selection}
         TheWall.Flag3 := TMPWall.Flag3;
         {multiselection}
         if WL_MULTIS.Count <> 0 then
          for m := 0 to WL_MULTIS.Count - 1 do
           begin
            TheSectorM   := TSector(MAP_SEC.Objects[StrToInt(Copy(WL_MULTIS[m],1,4))]);
            TheWallM     := TWall(TheSectorM.Wl.Objects[StrToInt(Copy(WL_MULTIS[m],5,4))]);
            {Flag is updated, not copied !}
            xor_flag   := ORIWall.Flag3 xor TMPWall.Flag3;
            set_flag   := xor_flag and TMPWall.Flag3;
            reset_flag := xor_flag and ORIWall.Flag3;
            TheWallM.Flag3 := (TheWallM.Flag3 or set_flag) and not reset_flag;
           end;
         MODIFIED := TRUE;
        end;
   7 : if ORIWall.Mid.Name <> TMPWall.Mid.Name then
        begin
         {selection}
         TheWall.Mid.Name := TMPWall.Mid.Name;
         {multiselection}
         if WL_MULTIS.Count <> 0 then
          for m := 0 to WL_MULTIS.Count - 1 do
           begin
            TheSectorM   := TSector(MAP_SEC.Objects[StrToInt(Copy(WL_MULTIS[m],1,4))]);
            TheWallM     := TWall(TheSectorM.Wl.Objects[StrToInt(Copy(WL_MULTIS[m],5,4))]);
            TheWallM.Mid.Name := TMPWall.Mid.Name;
           end;
         MODIFIED := TRUE;
         {add to textures}
         if TX_LIST.IndexOf(UpperCase(TMPWall.Mid.Name)) = -1 then
          TX_LIST.Add(UpperCase(TMPWall.Mid.Name));
        end;
   8 : if ORIWall.Mid.f1 <> TMPWall.Mid.f1 then
        begin
         {selection}
         TheWall.Mid.f1 := TMPWall.Mid.f1;
         {multiselection}
         if WL_MULTIS.Count <> 0 then
          for m := 0 to WL_MULTIS.Count - 1 do
           begin
            TheSectorM   := TSector(MAP_SEC.Objects[StrToInt(Copy(WL_MULTIS[m],1,4))]);
            TheWallM     := TWall(TheSectorM.Wl.Objects[StrToInt(Copy(WL_MULTIS[m],5,4))]);
            TheWallM.Mid.f1 := TMPWall.Mid.f1;
           end;
         MODIFIED := TRUE;
        end;
   9 : if ORIWall.Mid.f2 <> TMPWall.Mid.f2 then
        begin
         {selection}
         TheWall.Mid.f2 := TMPWall.Mid.f2;
         {multiselection}
         if WL_MULTIS.Count <> 0 then
          for m := 0 to WL_MULTIS.Count - 1 do
           begin
            TheSectorM   := TSector(MAP_SEC.Objects[StrToInt(Copy(WL_MULTIS[m],1,4))]);
            TheWallM     := TWall(TheSectorM.Wl.Objects[StrToInt(Copy(WL_MULTIS[m],5,4))]);
            TheWallM.Mid.f2 := TMPWall.Mid.f2;
           end;
         MODIFIED := TRUE;
        end;
  10 : if ORIWall.Mid.i <> TMPWall.Mid.i then
        begin
         {selection}
         TheWall.Mid.i := TMPWall.Mid.i;
         {multiselection}
         if WL_MULTIS.Count <> 0 then
          for m := 0 to WL_MULTIS.Count - 1 do
           begin
            TheSectorM   := TSector(MAP_SEC.Objects[StrToInt(Copy(WL_MULTIS[m],1,4))]);
            TheWallM     := TWall(TheSectorM.Wl.Objects[StrToInt(Copy(WL_MULTIS[m],5,4))]);
            TheWallM.Mid.i := TMPWall.Mid.i;
           end;
         MODIFIED := TRUE;
        end;
  11 : if ORIWall.Top.Name <> TMPWall.Top.Name then
        begin
         {selection}
         TheWall.Top.Name := TMPWall.Top.Name;
         {multiselection}
         if WL_MULTIS.Count <> 0 then
          for m := 0 to WL_MULTIS.Count - 1 do
           begin
            TheSectorM   := TSector(MAP_SEC.Objects[StrToInt(Copy(WL_MULTIS[m],1,4))]);
            TheWallM     := TWall(TheSectorM.Wl.Objects[StrToInt(Copy(WL_MULTIS[m],5,4))]);
            TheWallM.Top.Name := TMPWall.Top.Name;
           end;
         MODIFIED := TRUE;
         {add to textures}
         if TX_LIST.IndexOf(UpperCase(TMPWall.Top.Name)) = -1 then
          TX_LIST.Add(UpperCase(TMPWall.Top.Name));
        end;
  12 : if ORIWall.Top.f1 <> TMPWall.Top.f1 then
        begin
         {selection}
         TheWall.Top.f1 := TMPWall.Top.f1;
         {multiselection}
         if WL_MULTIS.Count <> 0 then
          for m := 0 to WL_MULTIS.Count - 1 do
           begin
            TheSectorM   := TSector(MAP_SEC.Objects[StrToInt(Copy(WL_MULTIS[m],1,4))]);
            TheWallM     := TWall(TheSectorM.Wl.Objects[StrToInt(Copy(WL_MULTIS[m],5,4))]);
            TheWallM.Top.f1 := TMPWall.Top.f1;
           end;
         MODIFIED := TRUE;
        end;
  13 : if ORIWall.Top.f2 <> TMPWall.Top.f2 then
        begin
         {selection}
         TheWall.Top.f2 := TMPWall.Top.f2;
         {multiselection}
         if WL_MULTIS.Count <> 0 then
          for m := 0 to WL_MULTIS.Count - 1 do
           begin
            TheSectorM   := TSector(MAP_SEC.Objects[StrToInt(Copy(WL_MULTIS[m],1,4))]);
            TheWallM     := TWall(TheSectorM.Wl.Objects[StrToInt(Copy(WL_MULTIS[m],5,4))]);
            TheWallM.Top.f2 := TMPWall.Top.f2;
           end;
         MODIFIED := TRUE;
        end;
  14 : if ORIWall.Top.i <> TMPWall.Top.i then
        begin
         {selection}
         TheWall.Top.i := TMPWall.Top.i;
         {multiselection}
         if WL_MULTIS.Count <> 0 then
          for m := 0 to WL_MULTIS.Count - 1 do
           begin
            TheSectorM   := TSector(MAP_SEC.Objects[StrToInt(Copy(WL_MULTIS[m],1,4))]);
            TheWallM     := TWall(TheSectorM.Wl.Objects[StrToInt(Copy(WL_MULTIS[m],5,4))]);
            TheWallM.Top.i := TMPWall.Top.i;
           end;
         MODIFIED := TRUE;
        end;
  15 : if ORIWall.Bot.Name <> TMPWall.Bot.Name then
        begin
         {selection}
         TheWall.Bot.Name := TMPWall.Bot.Name;
         {multiselection}
         if WL_MULTIS.Count <> 0 then
          for m := 0 to WL_MULTIS.Count - 1 do
           begin
            TheSectorM   := TSector(MAP_SEC.Objects[StrToInt(Copy(WL_MULTIS[m],1,4))]);
            TheWallM     := TWall(TheSectorM.Wl.Objects[StrToInt(Copy(WL_MULTIS[m],5,4))]);
            TheWallM.Bot.Name := TMPWall.Bot.Name;
           end;
         MODIFIED := TRUE;
         {add to textures}
         if TX_LIST.IndexOf(UpperCase(TMPWall.Bot.Name)) = -1 then
          TX_LIST.Add(UpperCase(TMPWall.Bot.Name));
        end;
  16 : if ORIWall.Bot.f1 <> TMPWall.Bot.f1 then
        begin
         {selection}
         TheWall.Bot.f1 := TMPWall.Bot.f1;
         {multiselection}
         if WL_MULTIS.Count <> 0 then
          for m := 0 to WL_MULTIS.Count - 1 do
           begin
            TheSectorM   := TSector(MAP_SEC.Objects[StrToInt(Copy(WL_MULTIS[m],1,4))]);
            TheWallM     := TWall(TheSectorM.Wl.Objects[StrToInt(Copy(WL_MULTIS[m],5,4))]);
            TheWallM.Bot.f1 := TMPWall.Bot.f1;
           end;
         MODIFIED := TRUE;
        end;
  17 : if ORIWall.Bot.f2 <> TMPWall.Bot.f2 then
        begin
         {selection}
         TheWall.Bot.f2 := TMPWall.Bot.f2;
         {multiselection}
         if WL_MULTIS.Count <> 0 then
          for m := 0 to WL_MULTIS.Count - 1 do
           begin
            TheSectorM   := TSector(MAP_SEC.Objects[StrToInt(Copy(WL_MULTIS[m],1,4))]);
            TheWallM     := TWall(TheSectorM.Wl.Objects[StrToInt(Copy(WL_MULTIS[m],5,4))]);
            TheWallM.Bot.f2 := TMPWall.Bot.f2;
           end;
         MODIFIED := TRUE;
        end;
  18 : if ORIWall.Bot.i <> TMPWall.Bot.i then
        begin
         {selection}
         TheWall.Bot.i := TMPWall.Bot.i;
         {multiselection}
         if WL_MULTIS.Count <> 0 then
          for m := 0 to WL_MULTIS.Count - 1 do
           begin
            TheSectorM   := TSector(MAP_SEC.Objects[StrToInt(Copy(WL_MULTIS[m],1,4))]);
            TheWallM     := TWall(TheSectorM.Wl.Objects[StrToInt(Copy(WL_MULTIS[m],5,4))]);
            TheWallM.Bot.i := TMPWall.Bot.i;
           end;
         MODIFIED := TRUE;
        end;
  19 : if ORIWall.Sign.Name <> TMPWall.Sign.Name then
        begin
         {selection}
         TheWall.Sign.Name := TMPWall.Sign.Name;
         {multiselection}
         if WL_MULTIS.Count <> 0 then
          for m := 0 to WL_MULTIS.Count - 1 do
           begin
            TheSectorM   := TSector(MAP_SEC.Objects[StrToInt(Copy(WL_MULTIS[m],1,4))]);
            TheWallM     := TWall(TheSectorM.Wl.Objects[StrToInt(Copy(WL_MULTIS[m],5,4))]);
            TheWallM.Sign.Name := TMPWall.Sign.Name;
           end;
         MODIFIED := TRUE;
         {add to textures}
         if TX_LIST.IndexOf(UpperCase(TMPWall.Sign.Name)) = -1 then
          TX_LIST.Add(UpperCase(TMPWall.Sign.Name));
        end;
  20 : if ORIWall.Sign.f1 <> TMPWall.Sign.f1 then
        begin
         {selection}
         TheWall.Sign.f1 := TMPWall.Sign.f1;
         {multiselection}
         if WL_MULTIS.Count <> 0 then
          for m := 0 to WL_MULTIS.Count - 1 do
           begin
            TheSectorM   := TSector(MAP_SEC.Objects[StrToInt(Copy(WL_MULTIS[m],1,4))]);
            TheWallM     := TWall(TheSectorM.Wl.Objects[StrToInt(Copy(WL_MULTIS[m],5,4))]);
            TheWallM.Sign.f1 := TMPWall.Sign.f1;
           end;
         MODIFIED := TRUE;
        end;
  21 : if ORIWall.Sign.f2 <> TMPWall.Sign.f2 then
        begin
         {selection}
         TheWall.Sign.f2 := TMPWall.Sign.f2;
         {multiselection}
         if WL_MULTIS.Count <> 0 then
          for m := 0 to WL_MULTIS.Count - 1 do
           begin
            TheSectorM   := TSector(MAP_SEC.Objects[StrToInt(Copy(WL_MULTIS[m],1,4))]);
            TheWallM     := TWall(TheSectorM.Wl.Objects[StrToInt(Copy(WL_MULTIS[m],5,4))]);
            TheWallM.Sign.f2 := TMPWall.Sign.f2;
           end;
         MODIFIED := TRUE;
        end;
 END;
end;

procedure DO_Commit_WallEditor;
var
  TheSector    : TSector;
  TheWall      : TWall;
  i, j         : Integer;
  AReal        : Real;
  LenUpdated   : Boolean;

begin
 TMPWall   := TWall.Create;
 if not Check_AllWallEditor then
  begin
   TMPWall.Free;
   exit;
  end;

 if not AUTOCOMMIT_MULTI and CONFIRMMultiUpdate and (WL_MULTIS.Count <> 0) then
  begin
   if Application.MessageBox('Confirm Multiple Update ?',
                            'WDFUSE Wall Editor - Update Walls',
                            mb_YesNo or mb_IconQuestion) = idNo
    then exit;
  end;

 TheSector := TSector(MAP_SEC.Objects[SC_HILITE]);
 TheWall   := TWall(TheSector.Wl.Objects[WL_HILITE]);

 //Special Wall Length Case
 Val(WallEditor.WLEd.Cells[1, 22], AReal, j);
 if j = 0 then
   begin
    LenUpdated := UpdateWallLengthVX(AReal);
   end
 else
   begin
    Application.MessageBox('Wrong value for Wall length', 'Wall Editor Error', mb_Ok or mb_IconExclamation);
    exit;
  end;

 // If length is updated - no need to compare anything
 // or attempt to store anything - we did it in WallLength function
 if (not LenUpdated) then
   if CompareTwoWalls(TMPWall, TheWall) then exit
   else DO_StoreUndo;

 UpdateSectorName(SC_HILITE);

 ORIWall   := TWall.Create;
 ORIWall.Adjoin       := TheWall.Adjoin;
 ORIWall.Mirror       := TheWall.Mirror;
 ORIWall.Walk         := TheWall.Walk;
 ORIWall.Light        := TheWall.Light;
 ORIWall.Flag1        := TheWall.Flag1;
 ORIWall.Flag2        := TheWall.Flag2;
 ORIWall.Flag3        := TheWall.Flag3;
 ORIWall.Mid.Name     := TheWall.Mid.Name;
 ORIWall.Mid.f1       := TheWall.Mid.f1;
 ORIWall.Mid.f2       := TheWall.Mid.f2;
 ORIWall.Mid.i        := TheWall.Mid.i;
 ORIWall.Top.Name     := TheWall.Top.Name;
 ORIWall.Top.f1       := TheWall.Top.f1;
 ORIWall.Top.f2       := TheWall.Top.f2;
 ORIWall.Top.i        := TheWall.Top.i;
 ORIWall.Bot.Name     := TheWall.Bot.Name;
 ORIWall.Bot.f1       := TheWall.Bot.f1;
 ORIWall.Bot.f2       := TheWall.Bot.f2;
 ORIWall.Bot.i        := TheWall.Bot.i;
 ORIWall.Sign.Name    := TheWall.Sign.Name;
 ORIWall.Sign.f1      := TheWall.Sign.f1;
 ORIWall.Sign.f2      := TheWall.Sign.f2;

 for i := 0 to 21 do
  DO_Commit_WallEditorField(i);

 // Normalize offsets
 TheWall := NormalizeWall(TheWall);

 TMPWall.Free;
 ORIWall.Free;
 { DO_Fill_WallEditor; }
 MapWindow.Map.Invalidate;
end;

procedure DO_ForceCommit_WallEditorField(field : Integer);
begin
 TMPWall   := TWall.Create;
 if not Check_WallEditorField(field) then
  begin
   TMPWall.Free;
   exit;
  end;

 if not IGNORE_UNDO and CONFIRMMultiUpdate and (WL_MULTIS.Count <> 0) then
  begin
   if Application.MessageBox('Confirm Multiple Update ?',
                            'WDFUSE Wall Editor - Force Update Walls',
                            mb_YesNo or mb_IconQuestion) = idNo
    then exit;
  end;

 ORIWall   := TWall.Create;
 { !! NOT ALLOWED !!
 ORIWall.Adjoin       := ;
 ORIWall.Mirror       := ;
 ORIWall.Walk         := ;
 }
 ORIWall.Light        := -12345;
 ORIWall.Flag1        := -87654321;
 ORIWall.Flag2        := -87654321;
 ORIWall.Flag3        := -87654321;
 ORIWall.Mid.Name     := '/////';
 ORIWall.Mid.f1       := -9876543.21;
 ORIWall.Mid.f2       := -9876543.21;
 ORIWall.Mid.i        := -12345;
 ORIWall.Top.Name     := '/////';
 ORIWall.Top.f1       := -9876543.21;
 ORIWall.Top.f2       := -9876543.21;
 ORIWall.Top.i        := -12345;
 ORIWall.Bot.Name     := '/////';
 ORIWall.Bot.f1       := -9876543.21;
 ORIWall.Bot.f2       := -9876543.21;
 ORIWall.Bot.i        := -12345;
 ORIWall.Sign.Name    := '/////';
 ORIWall.Sign.f1      := -9876543.21;
 ORIWall.Sign.f2      := -9876543.21;

 DO_Commit_WallEditorField(field);

 TMPWall.Free;
 ORIWall.Free;
 { DO_Fill_WallEditor; }
 MapWindow.Map.Invalidate;
end;

{ And you thought trig was a boring & useless school subject?
  We alwyas mod the RIGHT vertex. So a line with vertices  (0,0) (3,4)
  when length is doubled (5->10) becomes (0,0) (6,8). This also handles
  adjoin wall mirror. }
function  UpdateWallLengthVX(WallLength : Real) : boolean;
var vx1, vx2 : TVertex;
    orig_length,
    deltax,
    deltaz : Real;
    TheSector,
    TheSectorMirror : TSector;
    TheWall,
    TheWallMirror : Twall;
    TheVertexMirror : TVertex;
    tempreal : real;
begin
   Result := False;
   TheSector := TSector(MAP_SEC.Objects[SC_HILITE]);
   TheWall   := TWall(TheSector.Wl.Objects[WL_HILITE]);
   vx1 := TVertex(TheSector.Vx.Objects[TheWall.left_vx]);
   vx2 := TVertex(TheSector.Vx.Objects[TheWall.right_vx]);
   orig_length := sqrt(sqr(vx1.X - vx2.X)+sqr(vx1.Z - vx2.Z));

   tempreal := StrToFloat(PosTrim(orig_length));

   if tempreal <> WallLength then
     begin

       // Save here - we won't do it outside
       DO_StoreUndo;

       //Update X delta
       deltax := ((vx2.X-vx1.X) * (WallLength/orig_length));
       vx2.X := vx1.X + StrToFloat(PosTrim(deltax));

       //Update Z(Y) delta
       deltaz := ((vx2.Z-vx1.Z) * (WallLength/orig_length));
       vx2.Z := vx1.Z + StrToFloat(PosTrim(deltaz));

       //Handle Adjoin Mirrors (opposite of right is left)
        if TheWall.Adjoin <> -1 then
          begin
           TheSectorMirror  := TSector(MAP_SEC.Objects[TheWall.Adjoin]);
           TheWallMirror    := TWall(TheSectorMirror.Wl.Objects[TheWall.Mirror]);

           // What spectacular explosions you'll have if you simply stick vx2
           // Instead of creating a new vertex object...
           TheVertexMirror  := TVertex.Create;
           TheVertexMirror.X   := vx2.X;
           TheVertexMirror.Z   := vx2.Z;

           TheSectorMirror.Vx.Objects[TheWallMirror.left_vx] := TheVertexMirror;
           MAP_SEC.Objects[TheWall.Adjoin] := TheSectorMirror;
          end;

       // Update sector with updated vertex
       TheSector.Vx.Objects[TheWall.Right_vx] := vx2;
       MAP_SEC.Objects[SC_HILITE] := TheSector;
       MapWindow.invalidate;

       Result := True;
     end;
end;

{OBJECT EDITOR **********************************************************}
{OBJECT EDITOR **********************************************************}
{OBJECT EDITOR **********************************************************}

procedure DO_Fill_ObjectEditor;
var
  TheSector : TSector;
  TheObject : TOB;
begin
 TheObject := TOB(MAP_OBJ.Objects[OB_HILITE]);
 if TheObject.Sec <> -1 then
  TheSector := TSector(MAP_SEC.Objects[TheObject.Sec]);

 ObjectEditor.Caption := Format('OB %d', [OB_HILITE]);
 ObjectEditor.OBEd.Cells[1,  0] := TheObject.ClassName;
 ObjectEditor.OBEd.Cells[1,  1] := TheObject.DataName;
 ObjectEditor.OBEd.Cells[1,  2] := PosTrim(TheObject.X);
 ObjectEditor.OBEd.Cells[1,  3] := PosTrim(TheObject.Y);
 ObjectEditor.OBEd.Cells[1,  4] := PosTrim(TheObject.Z);
 ObjectEditor.OBEd.Cells[1,  5] := PosTrim(TheObject.Yaw);
 ObjectEditor.OBEd.Cells[1,  6] := PosTrim(TheObject.Pch);
 ObjectEditor.OBEd.Cells[1,  7] := PosTrim(TheObject.Rol);
 ObjectEditor.OBEd.Cells[1,  8] := IntToStr(TheObject.Diff);
 ObjectEditor.OBEd.Cells[1,  9] := IntToStr(TheObject.Sec);

 ObjectEditor.OBEd.Cells[1, 10] := IntToStr(TheObject.Col);
 ObjectEditor.OBEd.Cells[1, 11] := IntToStr(TheObject.OType);
 ObjectEditor.OBEd.Cells[1, 12] := IntToStr(TheObject.Special);

 ObjectEditor.OBSeq.Lines       := TheObject.Seq;

 if TheObject.Sec <> -1 then
  begin
   ObjectEditor.PanelSCName.Caption := TheSector.Name;
   ObjectEditor.PanelFloorAlt.Caption := Format('%-5.2f && %-5.2f', [TheSector.Floor_Alt, TheSector.Ceili_Alt]);
   ObjectEditor.PanelLayer.Caption := IntToStr(TheSector.Layer);
  end;

 if OB_MULTIS.Count = 0 then
  begin
   ObjectEditor.ShapeMulti.Brush.Color := clBtnFace;
   ObjectEditor.ForceCurrentField.Enabled := FALSE;
  end
 else
  begin
   ObjectEditor.ShapeMulti.Brush.Color := clRed;
   ObjectEditor.ForceCurrentField.Enabled := TRUE;
  end;

 // Reset Focus
 if not AUTOCOMMIT_FLAG and not INF_READ and ObjectEditor.visible  then
   begin
     ObjectEditor.FormCreate(NIL);
     ObjectEditor.SetFocus;
     MapWindow.SetFocus;
   end;
  MapWindow.Invalidate;
end;

function  Check_AllObjectEditor : Boolean;
var i      : Integer;
begin
 Result := TRUE;
 for i := 0 to 13 do
  begin
   Result := Result and Check_ObjectEditorField(i);
   if not Result then break;
  end;
end;

function  Check_ObjectEditorField(field : Integer) : Boolean;
var
  AReal               : Real;
  AInt                : Integer;
  ALong               : LongInt;
  Code                : Integer;
  title               : array[0..60] of char;
begin
 StrCopy(Title, 'Object Editor Error');
 Check_ObjectEditorField := TRUE;

 CASE field of
   0 : begin
        if (ObjectEditor.OBEd.Cells[1,  0] = 'SPIRIT') or
           (ObjectEditor.OBEd.Cells[1,  0] = 'SAFE')   or
           (ObjectEditor.OBEd.Cells[1,  0] = 'SPRITE') or
           (ObjectEditor.OBEd.Cells[1,  0] = 'FRAME')  or
           (ObjectEditor.OBEd.Cells[1,  0] = '3D')     or
           (ObjectEditor.OBEd.Cells[1,  0] = 'SOUND')  then
          TMPObject.ClassName := ObjectEditor.OBEd.Cells[1,  0]
         else
          begin
           Application.MessageBox('Wrong value for Class', Title, mb_Ok or mb_IconExclamation);
           Check_ObjectEditorField := FALSE;
          end;
       end;
   1 : begin
        if Length(ObjectEditor.OBEd.Cells[1,  1]) < 13 then
         begin
          TMPObject.DataName := ObjectEditor.OBEd.Cells[1,  1];
          {Don't forget to recheck the coloring !}
          DO_FillOBColor;
         end
        else
         begin
          Application.MessageBox('Name too long', Title, mb_Ok or mb_IconExclamation);
          Check_ObjectEditorField := FALSE;
         end;
       end;
   2 : begin
        { X }
        Val(ObjectEditor.OBEd.Cells[1,  2], AReal, Code);
        if Code = 0 then
         TMPObject.X := AReal
        else
         begin
          Application.MessageBox('Wrong value for X', Title, mb_Ok or mb_IconExclamation);
          Check_ObjectEditorField := FALSE;
         end;
       end;
   3 : begin
        { Y }
        Val(ObjectEditor.OBEd.Cells[1,  3], AReal, Code);
        if Code = 0 then
         TMPObject.Y := AReal
        else
         begin
          Application.MessageBox('Wrong value for Y', Title, mb_Ok or mb_IconExclamation);
          Check_ObjectEditorField := FALSE;
         end;
       end;
   4 : begin
        { Z }
        Val(ObjectEditor.OBEd.Cells[1,  4], AReal, Code);
        if Code = 0 then
         TMPObject.Z := AReal
        else
         begin
          Application.MessageBox('Wrong value for Z', Title, mb_Ok or mb_IconExclamation);
          Check_ObjectEditorField := FALSE;
         end;
       end;
   5 : begin
        { Yaw }
        Val(ObjectEditor.OBEd.Cells[1,  5], AReal, Code);
        if Code = 0 then
         if (AReal >= 0) and (AReal < 360) then
          TMPObject.Yaw := AReal
         else
          begin
           Application.MessageBox('Yaw must be >= 0 and < 360', Title, mb_Ok or mb_IconExclamation);
           Check_ObjectEditorField := FALSE;
          end
        else
         begin
          Application.MessageBox('Wrong value for Yaw', Title, mb_Ok or mb_IconExclamation);
          Check_ObjectEditorField := FALSE;
         end;
       end;
   6 : begin
        { Pch }
        Val(ObjectEditor.OBEd.Cells[1,  6], AReal, Code);
        if Code = 0 then
         TMPObject.Pch := AReal
        else
         begin
          Application.MessageBox('Wrong value for Pitch', Title, mb_Ok or mb_IconExclamation);
          Check_ObjectEditorField := FALSE;
         end;
       end;
   7 : begin
        { Roll }
        Val(ObjectEditor.OBEd.Cells[1,  7], AReal, Code);
        if Code = 0 then
         TMPObject.Rol := AReal
        else
         begin
          Application.MessageBox('Wrong value for Roll', Title, mb_Ok or mb_IconExclamation);
          Check_ObjectEditorField := FALSE;
         end;
       end;
   8 : begin
        { Diff }
        Val(ObjectEditor.OBEd.Cells[1,  8], AInt, Code);
        if Code = 0 then
         if (AInt >= -3) and (AInt <= 3) then
          TMPObject.Diff := AInt
         else
          begin
           Application.MessageBox('Diff must be between -3 and 3', Title, mb_Ok or mb_IconExclamation);
           Check_ObjectEditorField := FALSE;
          end
        else
         begin
          Application.MessageBox('Wrong value for Diff', Title, mb_Ok or mb_IconExclamation);
          Check_ObjectEditorField := FALSE;
         end;
       end;
   9 : begin
        { Sec }
        Val(ObjectEditor.OBEd.Cells[1,  9], AInt, Code);
        if Code = 0 then
         if (AInt >= -1) and (AInt < MAP_SEC.Count) then
          TMPObject.Sec := AInt
         else
          begin
           Application.MessageBox('Sec must be an existing sector or -1', Title, mb_Ok or mb_IconExclamation);
           Check_ObjectEditorField := FALSE;
          end
        else
         begin
          Application.MessageBox('Wrong value for Sec', Title, mb_Ok or mb_IconExclamation);
          Check_ObjectEditorField := FALSE;
         end;
       end;
  10 : begin
        { Col }
        Val(ObjectEditor.OBEd.Cells[1, 10], ALong, Code);
        if Code = 0 then
         if TRUE {test color !} then
          TMPObject.Col := ALong
         else
          begin
           Application.MessageBox('*Color must be a valid color', Title, mb_Ok or mb_IconExclamation);
           Check_ObjectEditorField := FALSE;
          end
        else
         begin
          Application.MessageBox('Wrong value for *Color', Title, mb_Ok or mb_IconExclamation);
          Check_ObjectEditorField := FALSE;
         end;
       end;
  11 : begin
        { OType }
         Val(ObjectEditor.OBEd.Cells[1, 11], AInt, Code);
         if Code = 0 then
          if TRUE {test type !} then
           TMPObject.OType := AInt
          else
           begin
            Application.MessageBox('*Type must be a valid type', Title, mb_Ok or mb_IconExclamation);
            Check_ObjectEditorField := FALSE;
           end
         else
          begin
           Application.MessageBox('Wrong value for *Type', Title, mb_Ok or mb_IconExclamation);
           Check_ObjectEditorField := FALSE;
          end;
       end;
  12 : begin
        { Special }
        Val(ObjectEditor.OBEd.Cells[1, 12], AInt, Code);
        if Code = 0 then
         if (AInt = 0) or (AInt=1) then
          TMPObject.Special := AInt
         else
          begin
           Application.MessageBox('*Generator must be 0 or 1', Title, mb_Ok or mb_IconExclamation);
           Check_ObjectEditorField := FALSE;
          end
        else
         begin
          Application.MessageBox('Wrong value for *Generator', Title, mb_Ok or mb_IconExclamation);
          Check_ObjectEditorField := FALSE;
         end;
       end;
  13 : begin
        { Seq : this isn't really a check, but MUST be done so that
                TMPObject.Seqs is filled }
        TMPObject.Seq.Clear;
        TMPObject.Seq.AddStrings(ObjectEditor.OBSeq.Lines);
       end;
 END;
end;

function CompareTwoObjects(ObjectA: TOB; ObjectB: TOB) : Boolean;
var
i : integer;
begin

Result := False;
if (ObjectA.ClassName = ObjectB.ClassName) and
   (ObjectA.DataName = ObjectB.DataName) and

    // Because the Map stores the X,Y,Z positions with multiple
    // decimal precision - we have to trim before comparing =(
    (AnsiCompareStr(PosTrim(ObjectA.x),
                    PosTrim(ObjectB.x)) = 0) and
    (AnsiCompareStr(PosTrim(ObjectA.y),
                    PosTrim(ObjectB.y)) = 0) and
    (AnsiCompareStr(PosTrim(ObjectA.z),
                    PosTrim(ObjectB.z)) = 0) and


   (ObjectA.Yaw = ObjectB.Yaw) and
   (ObjectA.Pch = ObjectB.Pch) and
   (ObjectA.Rol = ObjectB.Rol) and
   (ObjectA.Diff = ObjectB.Diff) and
   (ObjectA.Sec = ObjectB.Sec) and
   (ObjectA.Col = ObjectB.Col) and
   (ObjectA.OType = ObjectB.OType) and
   (ObjectA.Special = ObjectB.Special) then

    begin
      // Need to compare the logic lists as well
      if ObjectA.Seq.Count = ObjectB.Seq.Count  then
        begin
          for i:= 0 to ObjectA.Seq.Count -1 do
            if ObjectA.Seq[i] <> ObjectB.Seq[i] then
              begin
                Result := False;
                exit;
              end;
        end;
      Result := True;
    end;
end;

procedure DO_Commit_ObjectEditorField(field : Integer);
var
  TheObject           : TOB;
  TheObjectM          : TOB;
  m, i                : Integer;
  seqequal            : Boolean;
begin
 TheObject := TOB(MAP_OBJ.Objects[OB_HILITE]);

 CASE field of
   0 : if ORIObject.ClassName <> TMPObject.ClassName then
        begin
         {selection}
         TheObject.ClassName := TMPObject.ClassName;
         {multiselection}
         if OB_MULTIS.Count <> 0 then
          for m := 0 to OB_MULTIS.Count - 1 do
           begin
            TheObjectM  := TOB(MAP_OBJ.Objects[StrToInt(Copy(OB_MULTIS[m],5,4))]);
            TheObjectM.ClassName := TMPObject.ClassName;
           end;
         MODIFIED := TRUE;
        end;
   1 : if ORIObject.DataName <> TMPObject.DataName then
        begin
         {selection}
         TheObject.DataName := TMPObject.DataName;
         {multiselection}
         if OB_MULTIS.Count <> 0 then
          for m := 0 to OB_MULTIS.Count - 1 do
           begin
            TheObjectM  := TOB(MAP_OBJ.Objects[StrToInt(Copy(OB_MULTIS[m],5,4))]);
            TheObjectM.DataName := TMPObject.DataName;
           end;
         MODIFIED := TRUE;
        end;
   2 : if ORIObject.X <> TMPObject.X then
        begin
         {selection}
         TheObject.X := TMPObject.X;
         {multiselection}
         if OB_MULTIS.Count <> 0 then
          for m := 0 to OB_MULTIS.Count - 1 do
           begin
            TheObjectM  := TOB(MAP_OBJ.Objects[StrToInt(Copy(OB_MULTIS[m],5,4))]);
            TheObjectM.X := TMPObject.X;
           end;
         MODIFIED := TRUE;
        end;
   3 : if ORIObject.Y <> TMPObject.Y then
        begin
         {selection}
         TheObject.Y := TMPObject.Y;
         {multiselection}
         if OB_MULTIS.Count <> 0 then
          for m := 0 to OB_MULTIS.Count - 1 do
           begin
            TheObjectM  := TOB(MAP_OBJ.Objects[StrToInt(Copy(OB_MULTIS[m],5,4))]);
            TheObjectM.Y := TMPObject.Y;
           end;
         MODIFIED := TRUE;
        end;
   4 : if ORIObject.Z <> TMPObject.Z then
        begin
         {selection}
         TheObject.Z := TMPObject.Z;
         {multiselection}
         if OB_MULTIS.Count <> 0 then
          for m := 0 to OB_MULTIS.Count - 1 do
           begin
            TheObjectM  := TOB(MAP_OBJ.Objects[StrToInt(Copy(OB_MULTIS[m],5,4))]);
            TheObjectM.Z := TMPObject.Z;
           end;
         MODIFIED := TRUE;
        end;
   5 : if ORIObject.Yaw <> TMPObject.Yaw then
        begin
         {selection}
         TheObject.Yaw := TMPObject.Yaw;
         {multiselection}
         if OB_MULTIS.Count <> 0 then
          for m := 0 to OB_MULTIS.Count - 1 do
           begin
            TheObjectM  := TOB(MAP_OBJ.Objects[StrToInt(Copy(OB_MULTIS[m],5,4))]);
            TheObjectM.Yaw := TMPObject.Yaw;
           end;
         MODIFIED := TRUE;
        end;
   6 : if ORIObject.Pch <> TMPObject.Pch then
        begin
         {selection}
         TheObject.Pch := TMPObject.Pch;
         {multiselection}
         if OB_MULTIS.Count <> 0 then
          for m := 0 to OB_MULTIS.Count - 1 do
           begin
            TheObjectM  := TOB(MAP_OBJ.Objects[StrToInt(Copy(OB_MULTIS[m],5,4))]);
            TheObjectM.Pch := TMPObject.Pch;
           end;
         MODIFIED := TRUE;
        end;
   7 : if ORIObject.Rol <> TMPObject.Rol then
        begin
         {selection}
         TheObject.Rol := TMPObject.Rol;
         {multiselection}
         if OB_MULTIS.Count <> 0 then
          for m := 0 to OB_MULTIS.Count - 1 do
           begin
            TheObjectM  := TOB(MAP_OBJ.Objects[StrToInt(Copy(OB_MULTIS[m],5,4))]);
            TheObjectM.Rol := TMPObject.Rol;
           end;
         MODIFIED := TRUE;
        end;
   8 : if ORIObject.Diff <> TMPObject.Diff then
        begin
         {selection}
         TheObject.Diff := TMPObject.Diff;
         {multiselection}
         if OB_MULTIS.Count <> 0 then
          for m := 0 to OB_MULTIS.Count - 1 do
           begin
            TheObjectM  := TOB(MAP_OBJ.Objects[StrToInt(Copy(OB_MULTIS[m],5,4))]);
            TheObjectM.Diff := TMPObject.Diff;
           end;
         MODIFIED := TRUE;
        end;
   9 : if ORIObject.Sec <> TMPObject.Sec then
        begin
         {selection}
         TheObject.Sec := TMPObject.Sec;
         {multiselection}
         if OB_MULTIS.Count <> 0 then
          for m := 0 to OB_MULTIS.Count - 1 do
           begin
            TheObjectM  := TOB(MAP_OBJ.Objects[StrToInt(Copy(OB_MULTIS[m],5,4))]);
            TheObjectM.Sec := TMPObject.Sec;
           end;
         MODIFIED := TRUE;
        end;
  10 : if ORIObject.Col <> TMPObject.Col then
        begin
         {selection}
         TheObject.Col := TMPObject.Col;
         {multiselection}
         if OB_MULTIS.Count <> 0 then
          for m := 0 to OB_MULTIS.Count - 1 do
           begin
            TheObjectM  := TOB(MAP_OBJ.Objects[StrToInt(Copy(OB_MULTIS[m],5,4))]);
            TheObjectM.Col := TMPObject.Col;
           end;
         MODIFIED := TRUE;
        end;
  11 : if ORIObject.OType <> TMPObject.OType then
        begin
         {selection}
         TheObject.OType := TMPObject.OType;
         {multiselection}
         if OB_MULTIS.Count <> 0 then
          for m := 0 to OB_MULTIS.Count - 1 do
           begin
            TheObjectM  := TOB(MAP_OBJ.Objects[StrToInt(Copy(OB_MULTIS[m],5,4))]);
            TheObjectM.OType := TMPObject.OType;
           end;
         MODIFIED := TRUE;
        end;
  12 : if ORIObject.Special <> TMPObject.Special then
        begin
         {selection}
         TheObject.Special := TMPObject.Special;
         {multiselection}
         if OB_MULTIS.Count <> 0 then
          for m := 0 to OB_MULTIS.Count - 1 do
           begin
            TheObjectM  := TOB(MAP_OBJ.Objects[StrToInt(Copy(OB_MULTIS[m],5,4))]);
            TheObjectM.Special := TMPObject.Special;
           end;
         MODIFIED := TRUE;
        end;
  13 :  begin
         { !!!! this is a lot different !!!!}
         { we have to determine if the Seq are equal }
         seqequal := TRUE;

         if ORIObject.Seq.Count <> TMPObject.Seq.Count then
          seqequal := FALSE
         else
           for i := 0 to ORIObject.Seq.Count - 1 do
             if ORIObject.Seq[i] <> TMPObject.Seq[i] then
              begin
               seqequal := FALSE;
               break;
              end;

         if not seqequal then
          begin
           {selection}
           TheObject.Seq.Clear;
           TheObject.Seq.AddStrings(TMPObject.Seq);
           {multiselection}
           if OB_MULTIS.Count <> 0 then
            for m := 0 to OB_MULTIS.Count - 1 do
             begin
              TheObjectM  := TOB(MAP_OBJ.Objects[StrToInt(Copy(OB_MULTIS[m],5,4))]);
              TheObjectM.Seq.Clear;
              TheObjectM.Seq.AddStrings(TMPObject.Seq);
             end;
           MODIFIED := TRUE;
         end;
        end;
 END;
end;


procedure DO_Commit_ObjectEditor;
var
  TheObject : TOB;
  i         : Integer;
begin
 TMPObject := TOB.Create;
 if not Check_AllObjectEditor then
  begin
   TMPObject.Free;
   exit;
  end;

 TheObject := TOB(MAP_OBJ.Objects[OB_HILITE]);

 if CompareTwoObjects(TheObject, TMPObject) then exit;

 if not IGNORE_UNDO and CONFIRMMultiUpdate and (OB_MULTIS.Count <> 0) then
  begin
   if Application.MessageBox('Confirm Multiple Update ?',
                            'WDFUSE Object Editor - Update Objects',
                            mb_YesNo or mb_IconQuestion) = idNo
    then exit;
  end;

 DO_StoreUndo;

 ORIObject   := TOB.Create;
 ORIObject.ClassName := TheObject.ClassName;
 ORIObject.DataName  := TheObject.DataName;
 ORIObject.X         := TheObject.X;
 ORIObject.Y         := TheObject.Y;
 ORIObject.Z         := TheObject.Z;
 ORIObject.Yaw       := TheObject.Yaw;
 ORIObject.Pch       := TheObject.Pch;
 ORIObject.Rol       := TheObject.Rol;
 ORIObject.Diff      := TheObject.Diff;
 ORIObject.Sec       := TheObject.Sec;
 ORIObject.Col       := TheObject.Col;
 ORIObject.OType     := TheObject.OType;
 ORIObject.Special   := TheObject.Special;
 ORIObject.Seq.AddStrings(TheObject.Seq);

 for i := 0 to 13 do
  DO_Commit_ObjectEditorField(i);

 TMPObject.Free;
 ORIObject.Free;
 MapWindow.Map.Invalidate;
end;

procedure DO_ForceCommit_ObjectEditorField(field : Integer);
begin
 TMPObject := TOB.Create;
 if not Check_ObjectEditorField(field) then
  begin
   TMPObject.Free;
   exit;
  end;

 if not IGNORE_UNDO and CONFIRMMultiUpdate and (OB_MULTIS.Count <> 0) then
  begin
   if Application.MessageBox('Confirm Multiple Update ?',
                            'WDFUSE Object Editor - Force Update Objects',
                            mb_YesNo or mb_IconQuestion) = idNo
    then exit;
  end;

 ORIObject   := TOB.Create;
 ORIObject.ClassName := '/////';
 ORIObject.DataName  := '/////';
 ORIObject.X         := -9876543.21;
 ORIObject.Y         := -9876543.21;
 ORIObject.Z         := -9876543.21;
 ORIObject.Yaw       := -9876543.21;
 ORIObject.Pch       := -9876543.21;
 ORIObject.Rol       := -9876543.21;
 ORIObject.Diff      := -12345;
 ORIObject.Sec       := -12345;
 ORIObject.Col       := -20;
 ORIObject.OType     := -12345;
 ORIObject.Special   := -12345;
 ORIObject.Seq.Add('/////');

 DO_Commit_ObjectEditorField(field);

 TMPObject.Free;
 ORIObject.Free;
 MapWindow.Map.Invalidate;
end;


procedure DO_FillLogic;
var obs     : TIniFile;
    section : String;
    cnt     : Integer;
begin
 section := ObjectEditor.OBEd.Cells[1,1];
 if Doom then
  obs := TIniFile.Create(WDFUSEdir + '\WDFDATA\dm_seqs.wdf')
 else
  obs := TIniFile.Create(WDFUSEdir + '\WDFDATA\ob_seqs.wdf');
 try
  cnt := obs.ReadInteger(section, 'CNT', 0);
  CASE cnt OF
   {no seq defined, clear}
   0 : ObjectEditor.OBSeq.Clear;
   {one seq defined, use it}
   1 : DO_FillOneLogic(1);
   {more than one seq defined, use chooser}
   ELSE
       begin
        OBSEQNUMBER := cnt;
        OBSeqPicker.ShowModal;
       end;
  END;
 finally
  obs.Free;
 end;
end;

procedure DO_FillOneLogic(num : Integer);
var obs     : TIniFile;
    section : String;
    lines   : Integer;
    i       : Integer;
    ALine   : String;
begin
 section := ObjectEditor.OBEd.Cells[1,1];
 if Doom then
  obs := TIniFile.Create(WDFUSEdir + '\WDFDATA\dm_seqs.wdf')
 else
  obs := TIniFile.Create(WDFUSEdir + '\WDFDATA\ob_seqs.wdf');
 try
  ObjectEditor.OBSeq.Clear;
  lines := obs.ReadInteger(section, IntToStr(num*100), 0);
  for i := 1 to lines do
   begin
    ALine := obs.ReadString(section, IntToStr(num*100+i), '');
    ObjectEditor.OBSeq.Lines.Add(ALine);
   end;
 finally
  obs.Free;
 end;
end;

procedure DO_MakeGenerator;
var obs     : TIniFile;
    lines   : Integer;
    i       : Integer;
    ALine   : String;
    logic   : String;
    pars    : TStringParser;
begin

 {store the old logic}
 pars := TStringParser.Create(ObjectEditor.OBSeq.Lines[0]);
 try
  if pars.Count > 2 then
   logic := pars[2]
  else
   logic := '????';
 finally
  pars.Free;
 end;

 obs := TIniFile.Create(WDFUSEdir + '\WDFDATA\ob_seqs.wdf');
 try
  ObjectEditor.OBSeq.Clear;
  lines := obs.ReadInteger('GENERATOR', '100', 0);
  for i := 1 to lines do
   begin
    ALine := obs.ReadString('GENERATOR', IntToStr(100+i), '');
    ObjectEditor.OBSeq.Lines.Add(ALine);
   end;
  ObjectEditor.OBSeq.Lines[0] := ObjectEditor.OBSeq.Lines[0] + ' ' + logic;
  ObjectEditor.OBEd.Cells[1, 12] := '1';
 finally
  obs.Free;
 end;
end;

procedure DO_FillOBColor;
var
 COLORini  : TIniFile;
begin
 COLORini := TIniFile.Create(WDFUSEdir + '\WDFDATA\OB_COLS.WDF');
 try
  ObjectEditor.OBEd.Cells[1, 10] :=
    IntToStr(COLORini.ReadInteger(ObjectEditor.OBEd.Cells[1, 1], 'COLOR', Ccol_shadow));
 finally
  COLORini.Free;
 end;
end;

procedure DO_SelectObject;
begin
 OBSelector.ShowModal;
 if OBSelector.ModalResult = mrOk then
  begin
   if OBSEL_VALUE = 'SPIRIT' then
    with ObjectEditor.OBEd do
    begin
     Cells[1, 0] := 'SPIRIT';
     Cells[1, 1] := 'SPIRIT';
    end
   else
   if OBSEL_VALUE = 'SAFE' then
    with ObjectEditor.OBEd do
    begin
     Cells[1, 0] := 'SAFE';
     Cells[1, 1] := 'SAFE';
    end
   else
   if ExtractFileExt(OBSEL_VALUE) = '.WAX' then
   with ObjectEditor.OBEd do
    begin
     Cells[1, 0] := 'SPRITE';
     Cells[1, 1] := OBSEL_VALUE;
    end
   else
   if ExtractFileExt(OBSEL_VALUE) = '.FME' then
   with ObjectEditor.OBEd do
    begin
     Cells[1, 0] := 'FRAME';
     Cells[1, 1] := OBSEL_VALUE;
    end
   else
   if ExtractFileExt(OBSEL_VALUE) = '.3DO' then
   with ObjectEditor.OBEd do
    begin
     Cells[1, 0] := '3D';
     Cells[1, 1] := OBSEL_VALUE;
    end
   else
   if ExtractFileExt(OBSEL_VALUE) = '.VOC' then
   with ObjectEditor.OBEd do
    begin
     Cells[1, 0] := 'SOUND';
     Cells[1, 1] := OBSEL_VALUE;
    end
   else ;
   ObjectEditor.OBEd.Cells[1, 12] := '0'; {never a generator}
   DO_FillOBColor;
   DO_FillLogic;
  end;
end;

// Ensure we do not have empty sector names.
procedure UpdateSectorName(INFSector : Integer);
var
  TheSector : TSector;
  Thewall : TWall;
  hasInf : Boolean;
  j : Integer;
begin

   // You can't have empty sectors with INFs
   TheSector :=  TSector(MAP_SEC.Objects[INFSector]);

   hasInf:= False;

   // Find INFs inside sector
   if (TheSector.InfItems.Count > 0)
     then hasInf := True
   else
     begin
        // Find INFs inside Wall
        for j := 0 to TheSector.Wl.Count - 1 do
          begin
            TheWall := TWall(TheSector.Wl.Objects[j]);
            if TheWall.InfItems.Count > 0 then
              begin
                hasInf := True;
                break;
              end;
          end;
     end;

    if hasInf and (TheSector.Name = '')then
       TheSector.Name := 'CHANGEME_' + IntToStr(INFSector);

    // If we already have CHANGEME - delete it if there are no INFs
    if (not hasInf) and (String(TheSector.Name).startswith('CHANGEME_')) then
       TheSector.Name := '';

end;



procedure SetDOOMEditors;
begin
  if DOOM then
   begin
    SectorEditor.SCEd.Cells[0,  9] := 'WAD TAG';
    SectorEditor.SCEd.Cells[0, 14] := 'WAD TYPE';
    WallEditor.WLEd.Cells[0,  5]   := '+WAD Flags';
    WallEditor.WLEd.Cells[0, 10]   := 'WAD TAG';
    WallEditor.WLEd.Cells[0, 14]   := 'WAD ACTION';
    WallEditor.WLEd.Cells[0, 18]   := 'WAD SIDE';
   end
  else
   begin
    SectorEditor.SCEd.Cells[0,  9] := 'Floor Tx #';
    SectorEditor.SCEd.Cells[0, 14] := 'Ceili Tx #';
    WallEditor.WLEd.Cells[0,  5]   := '+Flag 2';
    WallEditor.WLEd.Cells[0, 10]   := 'Mid Tx #';
    WallEditor.WLEd.Cells[0, 14]   := 'Top Tx #';
    WallEditor.WLEd.Cells[0, 18]   := 'Bot Tx #';
   end
end;


end.
