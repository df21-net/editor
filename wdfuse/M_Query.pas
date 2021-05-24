unit M_query;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, TabNotBk, StdCtrls, Buttons, ExtCtrls, Spin,
  M_Global,
{$IFDEF WDF32}
  ComCtrls,
{$ENDIF}
  M_Editor
  ;

type
  TQueryWindow = class(TForm)
    TNQuery: TTabbedNotebook;
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    HelpBtn: TBitBtn;
    Panel1: TPanel;
    CB_SC_FloorAlt: TCheckBox;
    CB_SCC_FloorAlt: TComboBox;
    ED_SCV_FloorAlt: TEdit;
    CB_SC_FloorTX: TCheckBox;
    CB_SCC_FloorTX: TComboBox;
    CB_SC_CeiliTX: TCheckBox;
    CB_SCC_CeiliTX: TComboBox;
    CB_SC_Ambient: TCheckBox;
    CB_SCC_Ambient: TComboBox;
    SE_SCV_Ambient: TSpinEdit;
    CB_SC_CeiliAlt: TCheckBox;
    CB_SCC_CeiliAlt: TComboBox;
    ED_SCV_CeiliAlt: TEdit;
    CB_SC_SecondAlt: TCheckBox;
    CB_SCC_SecondAlt: TComboBox;
    ED_SCV_SecondAlt: TEdit;
    CB_SC_Layer: TCheckBox;
    CB_SCC_Layer: TComboBox;
    SE_SCV_Layer: TSpinEdit;
    CB_SC_Name: TCheckBox;
    CB_SCC_Name: TComboBox;
    CB_SCV_Name: TComboBox;
    CBSearch: TCheckBox;
    RGResults: TRadioGroup;
    CB_SC_Flag1: TCheckBox;
    CB_SCC_Flag1: TComboBox;
    ED_SCV_Flag1: TEdit;
    Panel2: TPanel;
    Panel3: TPanel;
    CB_WL_Flag1: TCheckBox;
    CB_WLC_Flag1: TComboBox;
    ED_WLV_Flag1: TEdit;
    CB_WL_MidTX: TCheckBox;
    CB_WLC_MidTX: TComboBox;
    CB_WL_Flag3: TCheckBox;
    CB_WLC_Flag3: TComboBox;
    ED_WLV_Flag3: TEdit;
    CB_WL_TopTX: TCheckBox;
    CB_WLC_TopTX: TComboBox;
    CB_WL_BotTX: TCheckBox;
    CB_WLC_BotTX: TComboBox;
    CB_WL_SgnTX: TCheckBox;
    CB_WLC_SgnTX: TComboBox;
    CB_WL_Flag2: TCheckBox;
    CB_WLC_Flag2: TComboBox;
    ED_WLV_Flag2: TEdit;
    CB_WL_Light: TCheckBox;
    CB_WLC_Light: TComboBox;
    SE_WLV_Light: TSpinEdit;
    CB_OB_Class: TCheckBox;
    CB_OBC_Class: TComboBox;
    CB_OBV_Class: TComboBox;
    CB_OB_Data: TCheckBox;
    CB_OBC_Data: TComboBox;
    CB_OB_Diff: TCheckBox;
    CB_OBC_Diff: TComboBox;
    SE_OBV_Diff: TSpinEdit;
    CB_OB_Gen: TCheckBox;
    CB_OBC_Gen: TComboBox;
    CB_OB_Layer: TCheckBox;
    CB_OBC_Layer: TComboBox;
    SE_OBV_Layer: TSpinEdit;
    CB_WL_Layer: TCheckBox;
    CB_WLC_Layer: TComboBox;
    SE_WLV_Layer: TSpinEdit;
    ED_SCV_FloorTX: TEdit;
    ED_SCV_CeiliTX: TEdit;
    ED_WLV_MidTX: TEdit;
    ED_WLV_TopTX: TEdit;
    ED_WLV_BotTX: TEdit;
    ED_WLV_SgnTX: TEdit;
    ED_OBV_Data: TEdit;
    procedure RGResultsClick(Sender: TObject);
    procedure ED_SCV_FloorTXDblClick(Sender: TObject);
    procedure ED_SCV_CeiliTXDblClick(Sender: TObject);
    procedure ED_WLV_MidTXDblClick(Sender: TObject);
    procedure ED_WLV_TopTXDblClick(Sender: TObject);
    procedure ED_WLV_BotTXDblClick(Sender: TObject);
    procedure ED_WLV_SgnTXDblClick(Sender: TObject);
    procedure ED_SCV_Flag1DblClick(Sender: TObject);
    procedure ED_WLV_Flag1DblClick(Sender: TObject);
    procedure ED_WLV_Flag3DblClick(Sender: TObject);
    procedure ED_WLV_Flag2DblClick(Sender: TObject);
    procedure SE_OBV_DiffDblClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TNQueryChange(Sender: TObject; NewTab: Integer;
      var AllowChange: Boolean);
    procedure HelpBtnClick(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure ED_OBV_DataDblClick(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  QueryWindow: TQueryWindow;
  initializing : Boolean;

implementation
uses Mapper;

{$R *.DFM}

procedure TQueryWindow.RGResultsClick(Sender: TObject);
begin
 CASE RGResults.ItemIndex OF
  0 : begin
       CBSearch.Checked := FALSE;
       CBSearch.Enabled := TRUE;
      end;
  1 : begin
       CBSearch.Checked := TRUE;
       CBSearch.Enabled := FALSE;
      end;
  2 : begin
       CBSearch.Checked := FALSE;
       CBSearch.Enabled := FALSE;
      end;
 END;
end;

{double click chose routines for textures, flags and diff}
procedure TQueryWindow.ED_SCV_FloorTXDblClick(Sender: TObject);
begin
 ED_SCV_FloorTX.Text := ResEdit(ED_SCV_FloorTX.Text, RST_BM);
end;

procedure TQueryWindow.ED_SCV_CeiliTXDblClick(Sender: TObject);
begin
 ED_SCV_CeiliTX.Text := ResEdit(ED_SCV_CeiliTX.Text, RST_BM);
end;

procedure TQueryWindow.ED_WLV_MidTXDblClick(Sender: TObject);
begin
 ED_WLV_MidTX.Text := ResEdit(ED_WLV_MidTX.Text, RST_BM);
end;

procedure TQueryWindow.ED_WLV_TopTXDblClick(Sender: TObject);
begin
 ED_WLV_TopTX.Text := ResEdit(ED_WLV_TopTX.Text, RST_BM);
end;

procedure TQueryWindow.ED_WLV_BotTXDblClick(Sender: TObject);
begin
 ED_WLV_BotTX.Text := ResEdit(ED_WLV_BotTX.Text, RST_BM);
end;

procedure TQueryWindow.ED_WLV_SgnTXDblClick(Sender: TObject);
begin
 ED_WLV_SgnTX.Text := ResEdit(ED_WLV_SgnTX.Text, RST_BM);
end;

procedure TQueryWindow.ED_SCV_Flag1DblClick(Sender: TObject);
begin
 ED_SCV_Flag1.Text := FlagEdit(ED_SCV_Flag1.Text, 'sc_flag1.wdf', 'Sector Flag 1');
end;

procedure TQueryWindow.ED_WLV_Flag1DblClick(Sender: TObject);
begin
 ED_WLV_Flag1.Text := FlagEdit(ED_WLV_Flag1.Text, 'wl_flag1.wdf', 'Wall Flag 1');
end;

procedure TQueryWindow.ED_WLV_Flag2DblClick(Sender: TObject);
begin
 ED_WLV_Flag2.Text := FlagEdit(ED_WLV_Flag2.Text, 'wl_flag2.wdf', 'Wall Flag 2');
end;

procedure TQueryWindow.ED_WLV_Flag3DblClick(Sender: TObject);
begin
 ED_WLV_Flag3.Text := FlagEdit(ED_WLV_Flag3.Text, 'wl_flag3.wdf', 'Wall Flag 3');
end;

procedure TQueryWindow.SE_OBV_DiffDblClick(Sender: TObject);
begin
 SE_OBV_Diff.Value := StrToInt(DIFFEditNoCheck(IntToStr(SE_OBV_Diff.Value)));
end;

procedure TQueryWindow.ED_OBV_DataDblClick(Sender: TObject);
begin
 CASE CB_OBV_CLASS.ItemIndex of
  -1 : ED_OBV_Data.Text := '';
   0 : ED_OBV_Data.Text := 'SPIRIT';
   1 : ED_OBV_Data.Text := 'SAFE';
   2 : ED_OBV_Data.Text := ResEdit(ED_OBV_Data.Text, RST_WAX);
   3 : ED_OBV_Data.Text := ResEdit(ED_OBV_Data.Text, RST_FME);
   4 : ED_OBV_Data.Text := ResEdit(ED_OBV_Data.Text, RST_3DO);
   5 : ED_OBV_Data.Text := ResEdit(ED_OBV_Data.Text, RST_SND);
 END;
end;

procedure TQueryWindow.FormCreate(Sender: TObject);
var sc        : Integer;
    TheSector : TSector;
begin
 initializing := TRUE;
 CASE MAP_MODE of
   MM_SC : begin
            CB_SCC_Name.ItemIndex      := 0;
            CB_SCC_Flag1.ItemIndex     := 0;
            CB_SCC_Ambient.ItemIndex   := 0;
            CB_SCC_FloorAlt.ItemIndex  := 0;
            CB_SCC_FloorTX.ItemIndex   := 0;
            CB_SCC_CeiliAlt.ItemIndex  := 0;
            CB_SCC_CeiliTX.ItemIndex   := 0;
            CB_SCC_SecondAlt.ItemIndex := 0;
            CB_SCC_Layer.ItemIndex     := 0;

            CB_SCV_Name.Sorted := TRUE;
            CB_SCV_Name.Items.BeginUpdate;
            for sc := 0 to MAP_SEC.Count - 1 do
             begin
              TheSector := TSector(MAP_SEC.Objects[sc]);
              if TheSector.Name <> '' then
               CB_SCV_Name.Items.Add(TheSector.Name);
             end;
            CB_SCV_Name.Items.EndUpdate;

            SE_SCV_Layer.Value    := LAYER;
            if LAYER_MIN <> LAYER_MAX then
             begin
              SE_SCV_Layer.MinValue := LAYER_MIN;
              SE_SCV_Layer.MaxValue := LAYER_MAX;
             end
            else
             SE_SCV_Layer.ReadOnly := TRUE;

            TNQuery.PageIndex          := 0;
            if SC_MULTIS.Count <> 0 then
             begin
              RGResults.ItemIndex := 0;
              CBSearch.Checked    := FALSE;
              CBSearch.Enabled    := TRUE;
             end
            else
             begin
              RGResults.ItemIndex := 0;
              RGResults.Enabled   := FALSE;
              CBSearch.Checked    := FALSE;
              CBSearch.Enabled    := FALSE;
             end;
           end;
   MM_WL : begin
            CB_WLC_Flag1.ItemIndex     := 0;
            CB_WLC_Flag2.ItemIndex     := 0;
            CB_WLC_Flag3.ItemIndex     := 0;
            CB_WLC_Light.ItemIndex     := 0;
            CB_WLC_MidTX.ItemIndex     := 0;
            CB_WLC_TopTX.ItemIndex     := 0;
            CB_WLC_BotTX.ItemIndex     := 0;
            CB_WLC_SgnTX.ItemIndex     := 0;
            CB_WLC_Layer.ItemIndex     := 0;

            SE_WLV_Layer.Value    := LAYER;
            if LAYER_MIN <> LAYER_MAX then
             begin
              SE_WLV_Layer.MinValue := LAYER_MIN;
              SE_WLV_Layer.MaxValue := LAYER_MAX;
             end
            else
             SE_WLV_Layer.ReadOnly := TRUE;

            TNQuery.PageIndex          := 1;
            if WL_MULTIS.Count <> 0 then
             begin
              RGResults.ItemIndex := 0;
              CBSearch.Checked    := FALSE;
              CBSearch.Enabled    := TRUE;
             end
            else
             begin
              RGResults.ItemIndex := 0;
              RGResults.Enabled   := FALSE;
              CBSearch.Checked    := FALSE;
              CBSearch.Enabled    := FALSE;
             end;
           end;
   MM_OB : begin
            CB_OBC_Class.ItemIndex     := 0;
            CB_OBC_Data.ItemIndex      := 0;
            CB_OBC_Diff.ItemIndex      := 0;
            CB_OBC_Gen.ItemIndex       := 0;
            CB_OBC_Layer.ItemIndex     := 0;

            SE_OBV_Layer.Value    := LAYER;
            if LAYER_MIN <> LAYER_MAX then
             begin
              SE_OBV_Layer.MinValue := LAYER_MIN;
              SE_OBV_Layer.MaxValue := LAYER_MAX;
             end
            else
             SE_OBV_Layer.ReadOnly := TRUE;

            TNQuery.PageIndex          := 2;
            if OB_MULTIS.Count <> 0 then
             begin
              RGResults.ItemIndex := 0;
              CBSearch.Checked    := FALSE;
              CBSearch.Enabled    := TRUE;
             end
            else
             begin
              RGResults.ItemIndex := 0;
              RGResults.Enabled   := FALSE;
              CBSearch.Checked    := FALSE;
              CBSearch.Enabled    := FALSE;
             end;
           end;
 END;
 initializing := FALSE;
end;

procedure TQueryWindow.TNQueryChange(Sender: TObject; NewTab: Integer;
  var AllowChange: Boolean);
begin
 AllowChange := initializing;
 if not initializing then
  Application.MessageBox('Changing map mode is not allowed!',
                         'WDFUSE - Query',
                         mb_Ok or mb_IconExclamation);
end;

procedure TQueryWindow.HelpBtnClick(Sender: TObject);
begin
 Application.HelpJump('wdfuse_help_query');
end;

procedure TQueryWindow.OKBtnClick(Sender: TObject);
var QUERY_SELECT : TStringList;
    sc        : Integer;
    wl        : Integer;
    TheSector : TSector;
    TheWall   : TWall;
    TheObject : TOB;
    in_multi  : Integer;
    rvalue    : Real;
    lvalue    : LongInt;
    code      : Integer;
begin
 CASE MAP_MODE OF
  MM_SC :
   begin
     QUERY_SELECT := TStringList.Create;

     for sc := 0 to MAP_SEC.Count - 1 do
      begin
       TheSector := TSector(MAP_SEC.Objects[sc]);
       {do we take the sector in consideration ?}
       if not CBSearch.Checked or
          (CBSearch.Checked and
           (SC_MULTIS.IndexOf(Format('%4d%4d',[sc,sc])) <> -1)
          ) then
        begin

         if CB_SC_Name.Checked then
          begin
           case CB_SCC_Name.ItemIndex of
            0 : {=}    if TheSector.Name <> CB_SCV_Name.Text then continue;
            1 : {<>}   if TheSector.Name =  CB_SCV_Name.Text then continue;
            2 : {LIKE} if Copy(TheSector.Name,1,Length(CB_SCV_Name.Text))
                           <> CB_SCV_Name.Text then continue;
           end;
          end;

         if CB_SC_Flag1.Checked then
          begin
           Val(ED_SCV_Flag1.Text, lvalue, code);
           if code <> 0 then
            begin
             Application.MessageBox('Invalid value for Flag1 !',
                         'WDFUSE - Query', mb_Ok or mb_IconExclamation);
             exit;
            end;
           case CB_SCC_Flag1.ItemIndex of
            0 : {=}     if TheSector.Flag1 <> lvalue then continue;
            1 : {<>}    if TheSector.Flag1 =  lvalue then continue;
            2 : {set}   if (TheSector.Flag1 and lvalue) =  0 then continue;
            3 : {reset} if (TheSector.Flag1 and lvalue) <> 0 then continue;
           end;
          end;

         if CB_SC_Ambient.Checked then
          begin
           case CB_SCC_Ambient.ItemIndex of
            0 : {=}    if TheSector.Ambient <> SE_SCV_Ambient.Value then continue;
            1 : {<>}   if TheSector.Ambient =  SE_SCV_Ambient.Value then continue;
            2 : {>}    if TheSector.Ambient <= SE_SCV_Ambient.Value then continue;
            3 : {>=}   if TheSector.Ambient <  SE_SCV_Ambient.Value then continue;
            4 : {<}    if TheSector.Ambient >= SE_SCV_Ambient.Value then continue;
            5 : {<=}   if TheSector.Ambient >  SE_SCV_Ambient.Value then continue;
           end;
          end;

         if CB_SC_FloorAlt.Checked then
          begin
           Val(ED_SCV_FloorAlt.Text, rvalue, code);
           if code <> 0 then
            begin
             Application.MessageBox('Invalid value for Floor Altitude !',
                         'WDFUSE - Query', mb_Ok or mb_IconExclamation);
             exit;
            end;
           case CB_SCC_FloorAlt.ItemIndex of
            0 : {=}    if TheSector.Floor_Alt <> rvalue then continue;
            1 : {<>}   if TheSector.Floor_Alt =  rvalue then continue;
            2 : {>}    if TheSector.Floor_Alt <= rvalue then continue;
            3 : {>=}   if TheSector.Floor_Alt <  rvalue then continue;
            4 : {<}    if TheSector.Floor_Alt >= rvalue then continue;
            5 : {<=}   if TheSector.Floor_Alt >  rvalue then continue;
           end;
          end;

         if CB_SC_FloorTX.Checked then
          begin
           case CB_SCC_FloorTX.ItemIndex of
            0 : {=}    if TheSector.Floor.Name <> ED_SCV_FloorTX.Text then continue;
            1 : {<>}   if TheSector.Floor.Name =  ED_SCV_FloorTX.Text then continue;
            2 : {LIKE} if Copy(TheSector.Floor.Name,1,Length(ED_SCV_FloorTX.Text))
                           <> ED_SCV_FloorTX.Text then continue;
           end;
          end;

         if CB_SC_CeiliAlt.Checked then
          begin
           Val(ED_SCV_CeiliAlt.Text, rvalue, code);
           if code <> 0 then
            begin
             Application.MessageBox('Invalid value for Ceiling Altitude !',
                         'WDFUSE - Query', mb_Ok or mb_IconExclamation);
             exit;
            end;
           case CB_SCC_CeiliAlt.ItemIndex of
            0 : {=}    if TheSector.Ceili_Alt <> rvalue then continue;
            1 : {<>}   if TheSector.Ceili_Alt =  rvalue then continue;
            2 : {>}    if TheSector.Ceili_Alt <= rvalue then continue;
            3 : {>=}   if TheSector.Ceili_Alt <  rvalue then continue;
            4 : {<}    if TheSector.Ceili_Alt >= rvalue then continue;
            5 : {<=}   if TheSector.Ceili_Alt >  rvalue then continue;
           end;
          end;

         if CB_SC_CeiliTX.Checked then
          begin
           case CB_SCC_CeiliTX.ItemIndex of
            0 : {=}    if TheSector.Ceili.Name <> ED_SCV_CeiliTX.Text then continue;
            1 : {<>}   if TheSector.Ceili.Name =  ED_SCV_CeiliTX.Text then continue;
            2 : {LIKE} if Copy(TheSector.Ceili.Name,1,Length(ED_SCV_CeiliTX.Text))
                           <> ED_SCV_CeiliTX.Text then continue;
           end;
          end;

         if CB_SC_SecondAlt.Checked then
          begin
           Val(ED_SCV_SecondAlt.Text, rvalue, code);
           if code <> 0 then
            begin
             Application.MessageBox('Invalid value for Second Altitude !',
                         'WDFUSE - Query', mb_Ok or mb_IconExclamation);
             exit;
            end;
           case CB_SCC_SecondAlt.ItemIndex of
            0 : {=}    if TheSector.Second_Alt <> rvalue then continue;
            1 : {<>}   if TheSector.Second_Alt =  rvalue then continue;
            2 : {>}    if TheSector.Second_Alt <= rvalue then continue;
            3 : {>=}   if TheSector.Second_Alt <  rvalue then continue;
            4 : {<}    if TheSector.Second_Alt >= rvalue then continue;
            5 : {<=}   if TheSector.Second_Alt >  rvalue then continue;
           end;
          end;

         if CB_SC_Layer.Checked then
          begin
           case CB_SCC_Layer.ItemIndex of
            0 : {=}    if TheSector.Layer <> SE_SCV_Layer.Value then continue;
            1 : {<>}   if TheSector.Layer =  SE_SCV_Layer.Value then continue;
            2 : {>}    if TheSector.Layer <= SE_SCV_Layer.Value then continue;
            3 : {>=}   if TheSector.Layer <  SE_SCV_Layer.Value then continue;
            4 : {<}    if TheSector.Layer >= SE_SCV_Layer.Value then continue;
            5 : {<=}   if TheSector.Layer >  SE_SCV_Layer.Value then continue;
           end;
          end;

         {if we got here, the sector satisfies all conditions !}
         QUERY_SELECT.Add(Format('%4d%4d', [sc, sc]));
        end; {if not CBSearch ...}
      end; {for sc:= ...}

     if QUERY_SELECT.Count <> 0 then
      begin
       CASE RGResults.ItemIndex OF
        0 : begin
             {clear the multiselection and add the current selection}
             SC_MULTIS.Clear;
             SC_MULTIS.AddStrings(QUERY_SELECT);
            end;
        1 : begin
             {delete the current selection from the multiselection}
             for sc := 0 to QUERY_SELECT.Count - 1 do
              begin
               in_multi := SC_MULTIS.IndexOf(QUERY_SELECT[sc]);
               if in_multi <> -1 then SC_MULTIS.Delete(in_multi);
              end;
            end;
        2 : begin
             {add the current selection to the multiselection}
             for sc := 0 to QUERY_SELECT.Count - 1 do
              begin
               in_multi := SC_MULTIS.IndexOf(QUERY_SELECT[sc]);
               if in_multi = -1 then SC_MULTIS.Add(QUERY_SELECT[sc]);
              end;
            end;
       END;
       QUERY_SELECT.Free;
       MapWindow.PanelMulti.Caption := IntToStr(SC_MULTIS.Count);
       DO_Fill_SectorEditor;
       MapWindow.Map.Invalidate;
       ModalResult := mrOk;
      end
     else
      begin
       QUERY_SELECT.Free;
       Application.MessageBox('No Hits !', 'WDFUSE - Query', mb_Ok or mb_IconExclamation);
      end;
   end; {MM_SC}

  MM_WL :
   begin
     QUERY_SELECT := TStringList.Create;

     for sc := 0 to MAP_SEC.Count - 1 do
      begin
       TheSector := TSector(MAP_SEC.Objects[sc]);
       for wl := 0 to TheSector.Wl.Count - 1 do
        begin
         TheWall := TWall(TheSector.Wl.Objects[wl]);  
         {do we take the wall in consideration ?}
         if not CBSearch.Checked or
            (CBSearch.Checked and
             (WL_MULTIS.IndexOf(Format('%4d%4d',[sc,wl])) <> -1)
            ) then
          begin

           if CB_WL_Flag1.Checked then
            begin
             Val(ED_WLV_Flag1.Text, lvalue, code);
             if code <> 0 then
              begin
               Application.MessageBox('Invalid value for Flag1 !',
                           'WDFUSE - Query', mb_Ok or mb_IconExclamation);
               exit;
              end;
             case CB_WLC_Flag1.ItemIndex of
              0 : {=}     if TheWall.Flag1 <> lvalue then continue;
              1 : {<>}    if TheWall.Flag1 =  lvalue then continue;
              2 : {set}   if (TheWall.Flag1 and lvalue) =  0 then continue;
              3 : {reset} if (TheWall.Flag1 and lvalue) <> 0 then continue;
             end;
            end;

           if CB_WL_Flag2.Checked then
            begin
             Val(ED_WLV_Flag2.Text, lvalue, code);
             if code <> 0 then
              begin
               Application.MessageBox('Invalid value for Flag2 !',
                           'WDFUSE - Query', mb_Ok or mb_IconExclamation);
               exit;
              end;
             case CB_WLC_Flag2.ItemIndex of
              0 : {=}     if TheWall.Flag2 <> lvalue then continue;
              1 : {<>}    if TheWall.Flag2 =  lvalue then continue;
              2 : {set}   if (TheWall.Flag2 and lvalue) =  0 then continue;
              3 : {reset} if (TheWall.Flag2 and lvalue) <> 0 then continue;
             end;
            end;

           if CB_WL_Flag3.Checked then
            begin
             Val(ED_WLV_Flag3.Text, lvalue, code);
             if code <> 0 then
              begin
               Application.MessageBox('Invalid value for Flag3 !',
                           'WDFUSE - Query', mb_Ok or mb_IconExclamation);
               exit;
              end;
             case CB_WLC_Flag3.ItemIndex of
              0 : {=}     if TheWall.Flag3 <> lvalue then continue;
              1 : {<>}    if TheWall.Flag3 =  lvalue then continue;
              2 : {set}   if (TheWall.Flag3 and lvalue) =  0 then continue;
              3 : {reset} if (TheWall.Flag3 and lvalue) <> 0 then continue;
             end;
            end;

           if CB_WL_Light.Checked then
            begin
             case CB_WLC_Light.ItemIndex of
              0 : {=}    if TheWall.Light <> SE_WLV_Light.Value then continue;
              1 : {<>}   if TheWall.Light =  SE_WLV_Light.Value then continue;
              2 : {>}    if TheWall.Light <= SE_WLV_Light.Value then continue;
              3 : {>=}   if TheWall.Light <  SE_WLV_Light.Value then continue;
              4 : {<}    if TheWall.Light >= SE_WLV_Light.Value then continue;
              5 : {<=}   if TheWall.Light >  SE_WLV_Light.Value then continue;
             end;
            end;

           if CB_WL_MidTX.Checked then
            begin
             case CB_WLC_MidTX.ItemIndex of
              0 : {=}    if TheWall.Mid.Name <> ED_WLV_MidTX.Text then continue;
              1 : {<>}   if TheWall.Mid.Name =  ED_WLV_MidTX.Text then continue;
              2 : {LIKE} if Copy(TheWall.Mid.Name,1,Length(ED_WLV_MidTX.Text))
                             <> ED_WLV_MidTX.Text then continue;
             end;
            end;

           if CB_WL_TopTX.Checked then
            begin
             case CB_WLC_TopTX.ItemIndex of
              0 : {=}    if TheWall.Top.Name <> ED_WLV_TopTX.Text then continue;
              1 : {<>}   if TheWall.Top.Name =  ED_WLV_TopTX.Text then continue;
              2 : {LIKE} if Copy(TheWall.Top.Name,1,Length(ED_WLV_TopTX.Text))
                             <> ED_WLV_TopTX.Text then continue;
             end;
            end;

           if CB_WL_BotTX.Checked then
            begin
             case CB_WLC_BotTX.ItemIndex of
              0 : {=}    if TheWall.Bot.Name <> ED_WLV_BotTX.Text then continue;
              1 : {<>}   if TheWall.Bot.Name =  ED_WLV_BotTX.Text then continue;
              2 : {LIKE} if Copy(TheWall.Bot.Name,1,Length(ED_WLV_BotTX.Text))
                             <> ED_WLV_BotTX.Text then continue;
             end;
            end;

           if CB_WL_SgnTX.Checked then
            begin
             case CB_WLC_SgnTX.ItemIndex of
              0 : {=}    if TheWall.Sign.Name <> ED_WLV_SgnTX.Text then continue;
              1 : {<>}   if TheWall.Sign.Name =  ED_WLV_SgnTX.Text then continue;
              2 : {LIKE} if Copy(TheWall.Sign.Name,1,Length(ED_WLV_SgnTX.Text))
                             <> ED_WLV_SgnTX.Text then continue;
             end;
            end;

           if CB_WL_Layer.Checked then
            begin
             case CB_WLC_Layer.ItemIndex of
              0 : {=}    if TheSector.Layer <> SE_WLV_Layer.Value then continue;
              1 : {<>}   if TheSector.Layer =  SE_WLV_Layer.Value then continue;
              2 : {>}    if TheSector.Layer <= SE_WLV_Layer.Value then continue;
              3 : {>=}   if TheSector.Layer <  SE_WLV_Layer.Value then continue;
              4 : {<}    if TheSector.Layer >= SE_WLV_Layer.Value then continue;
              5 : {<=}   if TheSector.Layer >  SE_WLV_Layer.Value then continue;
             end;
            end;

           {if we got here, the wall satisfies all conditions !}
           QUERY_SELECT.Add(Format('%4d%4d', [sc, wl]));
          end;
        end;
      end;

     if QUERY_SELECT.Count <> 0 then
      begin
       CASE RGResults.ItemIndex OF
        0 : begin
             {clear the multiselection and add the current selection}
             WL_MULTIS.Clear;
             WL_MULTIS.AddStrings(QUERY_SELECT);
            end;
        1 : begin
             {delete the current selection from the multiselection}
             for sc := 0 to QUERY_SELECT.Count - 1 do
              begin
               in_multi := WL_MULTIS.IndexOf(QUERY_SELECT[sc]);
               if in_multi <> -1 then WL_MULTIS.Delete(in_multi);
              end;
            end;
        2 : begin
             {add the current selection to the multiselection}
             for sc := 0 to QUERY_SELECT.Count - 1 do
              begin
               in_multi := WL_MULTIS.IndexOf(QUERY_SELECT[sc]);
               if in_multi = -1 then WL_MULTIS.Add(QUERY_SELECT[sc]);
              end;
            end;
       END;
       QUERY_SELECT.Free;
       MapWindow.PanelMulti.Caption := IntToStr(WL_MULTIS.Count);
       DO_Fill_WallEditor;
       MapWindow.Map.Invalidate;
       ModalResult := mrOk;
      end
     else
      begin
       QUERY_SELECT.Free;
       Application.MessageBox('No Hits !', 'WDFUSE - Query', mb_Ok or mb_IconExclamation);
      end;
   end;

  MM_OB :
   begin
    QUERY_SELECT := TStringList.Create;

     for sc := 0 to MAP_OBJ.Count - 1 do
      begin
       TheObject := TOB(MAP_OBJ.Objects[sc]);
       {do we take the object in consideration ?}
       if not CBSearch.Checked or
          (CBSearch.Checked and
           (OB_MULTIS.IndexOf(Format('%4d%4d',[TheObject.Sec,sc])) <> -1)
          ) then
        begin

         {class}
         if CB_OB_Class.Checked then
          begin
           case CB_OBC_Class.ItemIndex of
            0 : {=}    if TheObject.ClassName <> CB_OBV_Class.Items[CB_OBV_Class.ItemIndex] then continue;
            1 : {<>}   if TheObject.ClassName =  CB_OBV_Class.Items[CB_OBV_Class.ItemIndex] then continue;
           end;
          end;

         if CB_OB_Data.Checked then
          begin
           case CB_OBC_Data.ItemIndex of
            0 : {=}    if TheObject.DataName <> ED_OBV_Data.Text then continue;
            1 : {<>}   if TheObject.DataName =  ED_OBV_Data.Text then continue;
            2 : {LIKE} if Copy(TheObject.DataName,1,Length(ED_OBV_Data.Text))
                           <> ED_OBV_Data.Text then continue;
           end;
          end;

         if CB_OB_Diff.Checked then
          begin
           case CB_OBC_Diff.ItemIndex of
            0 : {=}    if TheObject.Diff <> SE_OBV_Diff.Value then continue;
            1 : {<>}   if TheObject.Diff =  SE_OBV_Diff.Value then continue;
            2 : {>}    if TheObject.Diff <= SE_OBV_Diff.Value then continue;
            3 : {>=}   if TheObject.Diff <  SE_OBV_Diff.Value then continue;
            4 : {<}    if TheObject.Diff >= SE_OBV_Diff.Value then continue;
            5 : {<=}   if TheObject.Diff >  SE_OBV_Diff.Value then continue;
           end;
          end;

         if CB_OB_Gen.Checked then
          begin
           case CB_OBC_Gen.ItemIndex of
            0 : {YES}  if TheObject.Special <> 1 then continue;
            1 : {NO}   if TheObject.Special =  1 then continue;
           end;
          end;

         if CB_OB_Layer.Checked then
          begin
           if TheObject.Sec = -1 then
            begin
             {non layered objects }
             case CB_OBC_Layer.ItemIndex of
              0 : {=}    continue;
              1 : {<>}   continue;
              2 : {>}    continue;
              3 : {>=}   continue;
              4 : {<}    continue;
              5 : {<=}   continue;
              6 : {none} ;
             end;
            end
           else
            begin
             TheSector := TSector(MAP_SEC.Objects[TheObject.Sec]);
             case CB_OBC_Layer.ItemIndex of
              0 : {=}    if TheSector.Layer <> SE_OBV_Layer.Value then continue;
              1 : {<>}   if TheSector.Layer =  SE_OBV_Layer.Value then continue;
              2 : {>}    if TheSector.Layer <= SE_OBV_Layer.Value then continue;
              3 : {>=}   if TheSector.Layer <  SE_OBV_Layer.Value then continue;
              4 : {<}    if TheSector.Layer >= SE_OBV_Layer.Value then continue;
              5 : {<=}   if TheSector.Layer >  SE_OBV_Layer.Value then continue;
              6 : {none} continue;
             end;
            end;
          end;

         {if we got here, the object satisfies all conditions !}
         QUERY_SELECT.Add(Format('%4d%4d', [TheObject.Sec, sc]));
        end;
      end;

     if QUERY_SELECT.Count <> 0 then
      begin
       CASE RGResults.ItemIndex OF
        0 : begin
             {clear the multiselection and add the current selection}
             OB_MULTIS.Clear;
             OB_MULTIS.AddStrings(QUERY_SELECT);
            end;
        1 : begin
             {delete the current selection from the multiselection}
             for sc := 0 to QUERY_SELECT.Count - 1 do
              begin
               in_multi := OB_MULTIS.IndexOf(QUERY_SELECT[sc]);
               if in_multi <> -1 then OB_MULTIS.Delete(in_multi);
              end;
            end;
        2 : begin
             {add the current selection to the multiselection}
             for sc := 0 to QUERY_SELECT.Count - 1 do
              begin
               in_multi := OB_MULTIS.IndexOf(QUERY_SELECT[sc]);
               if in_multi = -1 then OB_MULTIS.Add(QUERY_SELECT[sc]);
              end;
            end;
       END;
       QUERY_SELECT.Free;
       MapWindow.PanelMulti.Caption := IntToStr(OB_MULTIS.Count);
       DO_Fill_ObjectEditor;
       MapWindow.Map.Invalidate;
       ModalResult := mrOk;
      end
     else
      begin
       QUERY_SELECT.Free;
       Application.MessageBox('No Hits !', 'WDFUSE - Query', mb_Ok or mb_IconExclamation);
      end;
   end;
 END;
end;

procedure TQueryWindow.CancelBtnClick(Sender: TObject);
begin
 Close;
end;

end.
