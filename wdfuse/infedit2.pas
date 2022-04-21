unit Infedit2;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, StdCtrls, Tabs, Buttons, Spin,
  M_Global, M_Test, I_Util, M_Util, _strings, M_Editor,
{$IFDEF WDF32}
  ComCtrls ,
{$ENDIF}
  TabNotBk, StrUtils;

CONST INF_NAVIG_MAX = 30;

type
  TSearchOption = (soIgnoreCase, soFromStart, soWrap);
  TSearchOptions = set of TSearchOption;
  TINFWindow2 = class(TForm)
    MainNotebook: TTabbedNotebook;
    PanelMain: TPanel;
    TabSet: TTabSet;
    PanelMultiDisplay: TPanel;
    Notebook: TNotebook;
    Label5: TLabel;
    Label6: TLabel;
    STKey: TLabel;
    STSpeed: TLabel;
    STCenter: TLabel;
    STAngle: TLabel;
    Label23: TLabel;
    Label20: TLabel;
    CBElevType: TComboBox;
    EDElevSpeed: TEdit;
    EDElevSpeed2: TEdit;
    CBElevKey: TComboBox;
    CBElevKey2: TComboBox;
    EDElevCenterX: TEdit;
    EDElevCenterZ: TEdit;
    EDElevAngle: TEdit;
    LBElevEventMask: TListBox;
    EDElevSound1: TEdit;
    EDElevSound2: TEdit;
    EDElevSound3: TEdit;
    EDElevFlags: TEdit;
    Label12: TLabel;
    CBStopRelative: TCheckBox;
    RGStopDHT: TRadioGroup;
    EDStopDelayValue: TEdit;
    BNStopMapValue: TBitBtn;
    Label13: TLabel;
    Label14: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label24: TLabel;
    CBTrigType: TComboBox;
    LBTrigEventMask: TListBox;
    LBTrigEntity: TListBox;
    LBTrigEvent: TListBox;
    EDTrigSound: TEdit;
    CBChuteTarget: TComboBox;
    Label18: TLabel;
    CBAdjoinSC1: TComboBox;
    MemoINF: TMemo;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    PanelBottom: TPanel;
    INFTextEditToolbar1: TPanel;
    SBCheck: TSpeedButton;
    SBFont: TSpeedButton;
    SBCommit: TSpeedButton;
    SBRollback: TSpeedButton;
    PanelTopRight: TPanel;
    SBHelp: TSpeedButton;
    Panel10: TPanel;
    SBWizGenerate: TSpeedButton;
    FontDialog1: TFontDialog;
    SBExit: TSpeedButton;
    INFTextEditToolbar2: TPanel;
    SBElev: TSpeedButton;
    SBTrig: TSpeedButton;
    SBChute: TSpeedButton;
    Panel6: TPanel;
    Panel7: TPanel;
    SBFontMisc: TSpeedButton;
    SBCommitMisc: TSpeedButton;
    SBRollbackMisc: TSpeedButton;
    SBExitMisc: TSpeedButton;
    Panel8: TPanel;
    SBHelpMisc: TSpeedButton;
    SBInfComments: TSpeedButton;
    SBInfLevel: TSpeedButton;
    SBInfErrors: TSpeedButton;
    Panel9: TPanel;
    Panel11: TPanel;
    MemoINFMisc: TMemo;
    Panel12: TPanel;
    SBEventMask: TSpeedButton;
    INF2Status: TPanel;
    Panel4: TPanel;
    SBHelpWiz: TSpeedButton;
    SBStop: TSpeedButton;
    SBAdjoin: TSpeedButton;
    INFTextEditToolbar4: TPanel;
    LBElevSlaves: TListBox;
    Label1: TLabel;
    LBTrigClients: TListBox;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label22: TLabel;
    EDPageFile: TEdit;
    Label19: TLabel;
    EDTextMsgNum: TEdit;
    BNTextMsgEdit: TBitBtn;
    CBAdjoinSC2: TComboBox;
    CBAdjoinWL1: TComboBox;
    CBAdjoinWL2: TComboBox;
    BNAdjoinCrTag1: TBitBtn;
    BNAdjoinCrTag2: TBitBtn;
    Label25: TLabel;
    Label26: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    Label29: TLabel;
    Label30: TLabel;
    Label31: TLabel;
    SEPage: TSpinEdit;
    Label32: TLabel;
    Label33: TLabel;
    SEMessage: TSpinEdit;
    Label34: TLabel;
    SEAdjoin: TSpinEdit;
    Label35: TLabel;
    CBMessageSC: TComboBox;
    Label36: TLabel;
    CBMessageWL: TComboBox;
    BNMessageCrTag: TBitBtn;
    Label37: TLabel;
    Label38: TLabel;
    RGMessageType: TRadioGroup;
    CBMessageUseElevSyntax: TCheckBox;
    EDMsgParam1: TEdit;
    EDMsgParam2: TEdit;
    STParam1: TLabel;
    STParam2: TLabel;
    SBMessage: TSpeedButton;
    SBPage: TSpeedButton;
    SBText: TSpeedButton;
    CBKeywords: TComboBox;
    CBINFNavigator: TComboBox;
    SBINFNavigNext: TSpeedButton;
    SBINFNavigPrev: TSpeedButton;
    SBINFNavigClear: TSpeedButton;
    BNElevSCMultis: TBitBtn;
    BNTrigSCMultis: TBitBtn;
    BNChuteSCSel: TBitBtn;
    BNStopSCSel: TBitBtn;
    BNAdjoinUseWLMultis: TBitBtn;
    BNMessageUseSCSel: TBitBtn;
    BNMessageUseWLSel: TBitBtn;
    CBElevMaster: TComboBox;
    CBTrigMaster: TComboBox;
    LBTextTextMSG: TListBox;
    SBIndent: TSpeedButton;
    CBElevSeqSeqend: TCheckBox;
    SEAdjoinWL1: TSpinEdit;
    SEAdjoinWL2: TSpinEdit;
    SEMessageWL: TSpinEdit;
    SBRefreshSCLists2: TSpeedButton;
    CBMessageUseWL: TCheckBox;
    CBStopValue: TComboBox;
    CBTrigEventMask: TCheckBox;
    CBElevEventMask: TCheckBox;
    LBEvMkEventMask: TListBox;
    Label7: TLabel;
    Label8: TLabel;
    SETexture: TSpinEdit;
    CBTexture: TComboBox;
    Label9: TLabel;
    BNTextureUseSCSel: TBitBtn;
    EDTexture: TEdit;
    Label10: TLabel;
    Label11: TLabel;
    SBRefreshSCLists: TSpeedButton;
    INFSearch: TEdit;
    INFTextEDitToolbar3: TPanel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    CBSectors: TComboBox;
    INFReplace: TEdit;
    SBINFSearchButton: TButton;
    SBINFReplaceButton: TButton;
    LookUpSector: TSpeedButton;
    INFStayOnTopCheckBox: TCheckBox;
    procedure SBRollbackClick(Sender: TObject);
    procedure SBFontClick(Sender: TObject);
    procedure SBCommitClick(Sender: TObject);
    procedure SBHelpClick(Sender: TObject);
    procedure SBCheckClick(Sender: TObject);
    procedure MemoINFKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure CBSectorsClick(Sender: TObject);
    procedure CBKeywordsClick(Sender: TObject);
    procedure SBInfCommentsClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure SBInfErrorsClick(Sender: TObject);
    procedure MemoINFDblClick(Sender: TObject);
    procedure SBInfLevelClick(Sender: TObject);
    procedure SBExitClick(Sender: TObject);
    procedure SBCommitMiscClick(Sender: TObject);
    procedure SBExitMiscClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SBRollbackMiscClick(Sender: TObject);
    procedure TabSetClick(Sender: TObject);
    procedure CBINFNavigatorClick(Sender: TObject);
    procedure SBINFNavigPrevClick(Sender: TObject);
    procedure SBINFNavigNextClick(Sender: TObject);
    procedure SBINFNavigClearClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BNTextMsgEditClick(Sender: TObject);
    procedure LBTextTextMSGClick(Sender: TObject);
    procedure EDElevSound1DblClick(Sender: TObject);
    procedure EDElevSound2DblClick(Sender: TObject);
    procedure EDElevSound3DblClick(Sender: TObject);
    procedure EDTrigSoundDblClick(Sender: TObject);
    procedure EDPageFileDblClick(Sender: TObject);
    procedure SBRenumStopsClick(Sender: TObject);
    procedure SBIndentClick(Sender: TObject);
    procedure SBWizGenerateClick(Sender: TObject);
    procedure SBElevClick(Sender: TObject);
    procedure SBRefreshSCListsClick(Sender: TObject);
    procedure RGMessageTypeClick(Sender: TObject);
    procedure EDMsgParam2DblClick(Sender: TObject);
    procedure CBElevTypeClick(Sender: TObject);
    procedure BNChuteSCSelClick(Sender: TObject);
    procedure BNMessageUseWLSelClick(Sender: TObject);
    procedure BNElevSCMultisClick(Sender: TObject);
    procedure SBMakeLinks(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure SBINFSearchButtonClick(Sender: TObject);
    function SearchText(Control: TCustomEdit; Search: string;
                        SearchOptions: TSearchOptions): Boolean;
    procedure SBINFReplaceButtonClick(Sender: TObject);
    procedure INFSearchClick(Sender: TObject);
    procedure INFReplaceClick(Sender: TObject);
    procedure INFReplaceChange(Sender: TObject);
    procedure INFSearchChange(Sender: TObject);
    procedure LookUpSectorClick(Sender: TObject);
    procedure INFStayOnTopCheckBoxClick(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
    ontop : Boolean;
    procedure AddToNavigator(SC, WL : Integer);
    procedure HiliteINFMemoLine(TheLine : Integer);
    procedure ActivateItem;

  end;


var
  INFWindow2: TINFWindow2;


implementation
uses Mapper;

{$R *.DFM}

procedure TINFWindow2.AddToNavigator(SC, WL : Integer);
var TheSector : TSector;
    TheWall   : TWall;
    str       : String;
    idx       : Integer;
begin
TheSector := TSector(MAP_SEC.Objects[SC]);
str       := RPad(TheSector.Name, 20);
if WL = -1 then {sector}
 begin
  str := str + '      ';
 end
else {wall}
 begin
  TheWall := TWall(TheSector.Wl.Objects[WL]);
  {should use wall name later on (ie tagNNN)}
  str := str + Format('%-6.6d',[WL]);
 end;


 if CBINFNavigator.Items.Count > INF_NAVIG_MAX then
   CBINFNavigator.Items.Delete(CBINFNavigator.Items.Count - 1);

 idx := CBINFNavigator.Items.IndexOf(str);
 if idx <> -1 then CBINFNavigator.Items.Delete(idx);
 CBINFNavigator.Items.Insert(0, str);
 CBINFNavigator.ItemIndex := 0;

 if CBINFNavigator.ItemIndex < CBINFNavigator.Items.Count - 1 then
  SBINFNavigPrev.Enabled := TRUE
 else
  SBINFNavigPrev.Enabled := FALSE;

 SBINFNavigNext.Enabled := FALSE;
end;

procedure TINFWindow2.HiliteINFMemoLine(TheLine : Integer);
var Line : Integer;
begin
 {check input, these SendMesage are quite touchy}
 Line := TheLine;
 if TheLine < 0 then Line := 0;
 if TheLine > MemoINF.Lines.Count-1 then Line := MemoINF.Lines.Count-1;

 MemoINF.SelStart  := SendMessage(MemoINF.Handle, EM_LINEINDEX, Line, 0);
 MemoINF.SelLength := Length(MemoINF.Lines[Line]);
end;


procedure TINFWindow2.INFReplaceChange(Sender: TObject);
begin
    if INFReplace.Text = '' then
      INFReplace.Text := 'Replace...';
end;

procedure TINFWindow2.INFReplaceClick(Sender: TObject);
begin
    if INFReplace.Text = 'Replace...' then
      INFReplace.Text := '';
end;

procedure TINFWindow2.INFSearchChange(Sender: TObject);
begin
    if INFSearch.Text = '' then
      INFSearch.Text := 'Search...';
end;

procedure TINFWindow2.INFSearchClick(Sender: TObject);
begin
   if INFSearch.Text = 'Search...' then
      INFSearch.Text := '';
end;

function TINFWindow2.SearchText(Control: TCustomEdit;
                     Search: string;
                     SearchOptions: TSearchOptions): Boolean;
var
  Text: string;
  Index: Integer;
  Search_orig,
  Reaplace_orig : String;
begin
  if soIgnoreCase in SearchOptions then
  begin
    Search_orig := Search;
    Search := UpperCase(Search);
    Text := UpperCase(Control.Text);
  end
  else
    Text := Control.Text;

  Index := 0;
  if not (soFromStart in SearchOptions) then
    Index := PosEx(Search, Text,
         Control.SelStart + Control.SelLength + 1);

  if (Index = 0) and
      ((soFromStart in SearchOptions) or
       (soWrap in SearchOptions)) then
    Index := PosEx(Search, Text, 1);

  Result := Index > 0;
  if Result then
  begin
    Control.SelStart := Index - 1;
    Control.SelLength := Length(Search);
  end;
end;

{***************************************************************************}

procedure TINFWindow2.ActivateItem;
var ret : Integer;
    lst : TStringList;
    msg : String;
begin
 INFReplace.Text := 'Replace...';
 INFSearch.Text := 'Search...';
 lst := TStringList.Create;
 ret := ParseINFItemsSCWL(INFSector, INFWall, lst, msg);
 INF2Status.Font.Color := clGreen;
 CASE ret OF
  -2 : begin
        InfWindow2.MemoINF.Clear;
        INF2Status.Caption := '';
       end;
  -1 : begin
        INFListToMemo(lst, InfWindow2.MemoINF, TRUE, TRUE);
        INF2Status.Caption := 'No Error';
       end;
  else begin
        INFItemsToMemo(INFSector, INFWall, InfWindow2.MemoINF);
        HiliteINFMemoLine(ret);
        INF2Status.Caption := msg;
        INF2Status.Font.Color := clRed;
       end;
 END;
 FreeINFList(lst);
 MemoINF.Modified := FALSE;
end;

procedure TINFWindow2.FormCreate(Sender: TObject);
begin
  CBElevType.ItemIndex := 0;
end;

procedure TINFWindow2.FormDeactivate(Sender: TObject);
var Action: TCloseAction;
begin
 Action := cafree;
 INFWindow2.FormClose(NIL, Action);
end;

procedure TINFWindow2.FormActivate(Sender: TObject);
var sfont : TArray<String>;
    iFont : TFont;
begin
{very important if INF editor is not modal,
 because FormActivate is also called when DEactivating}
IF LEVELLOADED THEN
BEGIN

  INFWindow2.Left   := Ini.ReadInteger('WINDOWS', 'INF Editor2    X', 0);
  INFWindow2.Top    := Ini.ReadInteger('WINDOWS', 'INF Editor2    Y', 72);
  INFWindow2.Width  := Ini.ReadInteger('WINDOWS', 'INF Editor2    W', 712);
  INFWindow2.Height := Ini.ReadInteger('WINDOWS', 'INF Editor2    H', 444);

  iFont := TFont.create;
  sfont := Ini.ReadString('INF Editor2', 'Font', 'System:10:10').Split([':']);
  ontop := Ini.ReadBool('INF Editor2', 'StayOnTop', False);

  iFont.Name := sfont[0];
  iFont.size := StrToint(sfont[1]);
  iFont.color := StrToInt(sfont[2]);

  MemoINF.Font     := iFont;
  MemoINFMisc.Font := MemoINF.Font;

  INFStayOnTopCheckBox.Checked := ontop;
  INFStayOnTopCheckBoxClick(NIL);


 {Initialize the Misc part if first load for this level}
 if INFMisc = -1 then
  begin
   MemoINFMisc.Clear;
   MemoINFMisc.Lines.AddStrings(INFComments);
   MemoINFMisc.Modified := FALSE;
   INFMisc := 0;
  end;

 {answer an external demand}
 if INFRemote then
  begin
   MainNotebook.PageIndex := 0;
   FillINFSectorNames;
   ActivateItem;
   AddToNavigator(INFSector, INFWall);
   INFRemote := FALSE;
  end;
END;
end;

procedure TINFWindow2.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 {!!!!! not sufficient, must be asked if INF editor is visible at
        all the possibilities of a level close in mapper !!!!!}
 {don't put something like SBExitClick(NIL), this will loop again and again
 until a stack overflow occurs
  }


  Ini.WriteInteger('WINDOWS', 'INF Editor2    X', INFWindow2.Left);
  Ini.WriteInteger('WINDOWS', 'INF Editor2    Y', INFWindow2.Top);
  Ini.WriteInteger('WINDOWS', 'INF Editor2    W', INFWindow2.Width);
  Ini.WriteInteger('WINDOWS', 'INF Editor2    H', INFWindow2.Height);
  Ini.WriteBool('INF Editor2', 'StayOnTop', ontop);
end;


{***************************************************************************}
{PAGE 1}

procedure TINFWindow2.SBINFNavigPrevClick(Sender: TObject);
begin
 CBINFNavigator.ItemIndex := CBINFNavigator.ItemIndex + 1;
 CBINFNavigatorClick(NIL);
end;

procedure TINFWindow2.SBINFReplaceButtonClick(Sender: TObject);
var searchstr,
    replacestr : String;
    searchres : Boolean;
    options : TSearchOptions;
begin
  searchstr := INFSearch.Text;
  replacestr := INFReplace.Text;
  MemoINF.Text := ReplaceText(MemoINF.Text,searchstr, replacestr);
end;

procedure TINFWindow2.SBINFSearchButtonClick(Sender: TObject);
var searchstr : String;
    searchres : Boolean;
    options : TSearchOptions;
begin
  searchstr := INFSearch.Text;
  options := [soIgnoreCase, soFromStart, soWrap];
  searchres := SearchText(MemoINF, searchstr, options);
end;

procedure TINFWindow2.SBINFNavigNextClick(Sender: TObject);
begin
 CBINFNavigator.ItemIndex := CBINFNavigator.ItemIndex - 1;
 CBINFNavigatorClick(NIL);
end;

procedure TINFWindow2.SBINFNavigClearClick(Sender: TObject);
begin
 CBINFNavigator.Clear;
 SBINFNavigPrev.Enabled := FALSE;
 SBINFNavigPrev.Enabled := FALSE;
end;

procedure TINFWindow2.CBINFNavigatorClick(Sender: TObject);
var strin : string;
    sc    : Integer;
    wl    : Integer;
    i     : Integer;
    found : Integer;
    closeok : Boolean;
    TheSector : TSector;
    TempCBItems : TStringList;
    OrigName : String;
begin
 closeok := TRUE;
 if MemoINF.Modified then
  begin
   CASE Application.MessageBox('Save changes ?', 'INF Editor',
                               mb_YesNo or mb_IconQuestion) OF
    idYes    : begin
                SBCommitClick(NIL);
               end;
    idNo     : ;
   END;
  end
 else ;

 OrigName :=  CBINFNavigator.items[CBINFNavigator.ItemIndex];

 TempCBItems := TStringList.Create;
 TempCBItems.Assign(CBINFNavigator.items);

 for i:=0 to CBINFNavigator.Items.count-1 do
   begin
    found := INFSectors.IndexOf(RTrim(CBINFNavigator.Items[i]));
    if found = -1 then
     begin
      TempCBItems.Delete(TempCBItems.IndexOf(CBINFNavigator.Items[i]));
     end;
   end;

 CBINFNavigator.Items.Assign(TempCBItems);

 // Reset index after deleting
 CBINFNavigator.ItemIndex := CBINFNavigator.Items.IndexOf(OrigName);


 if closeok then
  begin
   strin := CBINFNavigator.Items[CBINFNavigator.ItemIndex];
   if GetSectorNumFromNameNoCase(
       RTrim(Copy(strin,1,20)), sc) then
    begin
     if Copy(strin, 21,6) = '      ' then
      begin
       wl := -1;
      end
     else
      begin
       {this will have to be replaced by a tagNNN search}
       TheSector := TSector(MAP_SEC.Objects[sc]);
       wl := StrToIntDef(Copy(strin, 21,6), -2);
       if (wl < 0) or (wl >= TheSector.Wl.Count)
        then closeok := FALSE;
      end;
    end
   else
    begin
     closeok := FALSE;
    end;
  end;

 if closeok then
  begin
   {all is correct, do the jump and adapt the buttons state}
   INFSector := sc;
   INFWall   := wl;

   FillINFSectorNames; {useful ? could be navigated after a change...}
   ActivateItem;

   if CBINFNavigator.ItemIndex < CBINFNavigator.Items.Count - 1 then
    SBINFNavigPrev.Enabled := TRUE
   else
    SBINFNavigPrev.Enabled := FALSE;

   if CBINFNavigator.ItemIndex > 0 then
    SBINFNavigNext.Enabled := TRUE
   else
    SBINFNavigNext.Enabled := FALSE;
  end
 else
  begin
   //Application.MessageBox('Item was not found. Removed!', 'INF Editor', mb_Ok or mb_IconExclamation);
   CBINFNavigator.Items.Delete(CBINFNavigator.ItemIndex);
   if CBINFNavigator.Items.Count > 0 then
    begin
     CBINFNavigator.ItemIndex := 0;
     if CBINFNavigator.ItemIndex < CBINFNavigator.Items.Count - 1 then
      SBINFNavigPrev.Enabled := TRUE
     else
      SBINFNavigPrev.Enabled := FALSE;

     if CBINFNavigator.ItemIndex > 0 then
      SBINFNavigNext.Enabled := TRUE
     else
      SBINFNavigNext.Enabled := FALSE;
    end
   else
    begin
     SBINFNavigPrev.Enabled := FALSE;
     SBINFNavigNext.Enabled := FALSE;
     MemoINF.Clear;
     MemoINF.Modified := FALSE;
    end;
  end;
end;

procedure TINFWindow2.SBExitClick(Sender: TObject);
var closeok : Boolean;
begin
 closeok := TRUE;
 if MemoINF.Modified then
  begin
   CASE Application.MessageBox('Commit changes ?', 'INF Editor',
                               mb_YesNoCancel or mb_IconQuestion) OF
    idYes    : begin
                SBCommitClick(NIL);
               end;
    idNo     : ;
    idCancel : closeok := FALSE;
   END;
  end
 else ;

 if closeok then
  begin
   MainNotebook.PageIndex := 2;
   if MemoINFMisc.Modified then
    begin
     CASE Application.MessageBox('Commit changes ?', 'INF Editor2',
                                 mb_YesNoCancel or mb_IconQuestion) OF
      idYes : begin
               SBCommitMiscClick(NIL);
              end;
      idNo  : ;
      idCancel : closeok := FALSE;
     END;
    end
   else ;
  end;

 if closeok then Close;
end;

procedure TINFWindow2.SBCommitClick(Sender: TObject);
var TheSector : TSector;
    TheWall : TWall;
    j : Integer;
    hasInf : Boolean;
begin
 SBCheckClick(NIL);

 // Check if ok if errors and then continue
 if (not (INF2Status.Caption = '')) and (not (INF2Status.Caption = 'No Error')) then
   begin
       CASE Application.MessageBox('Error found! Commit anyway ?', 'INF Editor',
                               mb_YesNo or mb_IconQuestion) OF
           idYes :; //noop
           idNo  : exit;
       END;
   end;

   DO_StoreUndo;

   MemoToINFItems(INFSector, INFWall, MemoINF);
   ComputeINFClasses(INFSector, INFWall);

   UpdateSectorName(INFSector);


   CASE MAP_MODE OF
    MM_SC : DO_Fill_SectorEditor;
    MM_WL : DO_Fill_WallEditor;
   END;
   MODIFIED := TRUE;

end;

procedure TINFWindow2.SBRollbackClick(Sender: TObject);
var ret : Integer;
    lst : TStringList;
    msg : String;
begin
 lst := TStringList.Create;
 ret := ParseINFItemsSCWL(INFSector, INFWall, lst, msg);
 INF2Status.Font.Color := clGreen;
 CASE ret OF
  -2 : begin
        InfWindow2.MemoINF.Clear;
        INF2Status.Caption := '';
       end;
  -1 : begin
        INFListToMemo(lst, InfWindow2.MemoINF, TRUE, TRUE);
        INF2Status.Caption := 'No Error';
       end;
  else begin
        INFItemsToMemo(INFSector, INFWall, InfWindow2.MemoINF);
        HiliteINFMemoLine(ret);
        INF2Status.Caption := msg;
        INF2Status.Font.Color := clRed;
       end;
 END;
 FreeINFList(lst);
 MemoINF.Modified := FALSE;
end;

procedure TINFWindow2.SBCheckClick(Sender: TObject);
var ret : Integer;
    lst : TStringList;
    ml  : TStringList;
    msg : String;
begin
 lst := TStringList.Create;
 ml  := TStringList.Create;
 ml.AddStrings(MemoINF.Lines);
 ret := ParseINFItems(ml, lst, msg);
 ml.Free;
 INF2Status.Font.Color := clGreen;
 CASE ret of
  -2 : begin
        INF2Status.Caption := '';
       end;
  -1 : begin
        INFListToMemo(lst, InfWindow2.MemoINF, SBIndent.Down, TRUE);
        INF2Status.Caption := 'No Error';
       end;
  else begin
        HiliteINFMemoLine(ret);
        INF2Status.Caption := msg;
        INF2Status.Font.Color := clRed;
       end;
 END;
 FreeINFList(lst);
end;

procedure TINFWindow2.SBFontClick(Sender: TObject);
var sfont : string;
begin
with FontDialog1 do
  begin
   Font := MemoINF.Font;
   if Execute then
    begin
     MemoINF.Font     := Font;
     MemoINFMisc.Font := Font;


     sfont := font.name + ':' + inttostr(font.Size) + ':'
            + inttostr(font.color);
     Ini.WriteString('INF Editor', 'Font', sfont);
    end;
  end;
end;

procedure TINFWindow2.SBRenumStopsClick(Sender: TObject);
var stops   : Integer;
    line    : Integer;
    strin,
    strout  : String;
    Comment : Boolean;
    pars    : TStringParserWithColon;
    j       : Integer;
    renum   : Boolean;
begin
 stops   := -1;
 comment := FALSE;
 renum   := FALSE;

 for line := 0 to MemoINF.Lines.Count - 1 do
  begin
   strin := LTrim(MemoINF.Lines[line]);
   if strin = '' then continue;

   if Pos('/*', strin) = 1 then
    begin
     if Pos('*/', strin) = 0 then Comment := TRUE;
    end
   else
   if Pos('*/', strin) <> 0 then
    begin
     Comment := FALSE;
    end
   else
   if Comment then
    begin
    end
   else
   if Pos('class:', LowerCase(strin)) = 1 then
    begin
     pars := TStringParserWithColon.Create(strin);
     if pars.Count > 2 then
      begin
       if pars[2] = 'elevator' then
        begin
         renum := TRUE;
         stops := -1;
        end
       else
        renum := FALSE;
      end
     else
      begin
       pars.Free;
       {ERROR}
       exit;
      end;
     pars.Free;
    end
   else
   if Pos('stop:', LowerCase(strin)) = 1 then
    begin
     Inc(stops);
    end
   else
   if (Pos('adjoin:', LowerCase(strin)) = 1) or
      (Pos('texture:', LowerCase(strin)) = 1) or
      (Pos('message:', LowerCase(strin)) = 1) or
      (Pos('page:', LowerCase(strin)) = 1) then
    begin
     if renum then
      begin
       pars := TStringParserWithColon.Create(strin);
       if pars.Count > 2 then
        begin
         strout := '      ' + pars[1] + ' ' + IntToStr(stops);
         for j := 3 to pars.Count - 1 do
          strout := strout + ' ' + pars[j];
         MemoINF.Lines[line] := strout;
        end;
       pars.Free;
      end;
    end;

  end;
end;

procedure TINFWindow2.SBMakeLinks(Sender: TObject);
begin
 MemoINF.Lines.Insert(0, '/* LINKS :  */');
end;

procedure TINFWindow2.SBIndentClick(Sender: TObject);
begin
 SBCheckClick(NIL);
end;

procedure TINFWindow2.SBRefreshSCListsClick(Sender: TObject);
begin
 FillINFSectorNames;
end;

procedure TINFWindow2.SBHelpClick(Sender: TObject);
begin
  MapWindow.HelpTutorialClick(NIL);
end;

{***************************************************************************}

procedure TINFWindow2.CBSectorsClick(Sender: TObject);
begin
 MemoINF.SelText := CBSectors.Items[CBSectors.ItemIndex];
end;

procedure TINFWindow2.CBKeywordsClick(Sender: TObject);
begin
 MemoINF.SelText := CBKeywords.Items[CBKeywords.ItemIndex];
end;


procedure TINFWindow2.MemoINFKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if ssCtrl in Shift then
    Case Key of
      VK_RETURN  : SBCheckClick(NIL);
      $44 {VK_D} : MemoINF.SelText := 'done';
      $47 {VK_G} : MemoINF.SelText := 'goto_stop ';
      $4B {VK_K} : SBCheckClick(NIL);
      $4E {VK_N} : MemoINF.SelText := 'next_stop';
      $50 {VK_P} : MemoINF.SelText := 'prev_stop';
      $52 {VK_R} : SBRenumStopsClick(NIL);
      $53 {VK_S} : MemoINF.SelText := #13 + #10 + '    stop: ';
    end;
    CASE MainNotebook.PageIndex OF
  0 : begin
       if (Shift = []) and (Key = VK_F1) then SBHelpClick(NIL);
       if (Shift = []) and (Key = VK_F3) then SBCommitClick(NIL);
       if (Shift = []) and (Key = VK_F4) then MemoINFDblClick(NIL);
       if (Shift = []) and (Key = VK_ESCAPE) then SBRollbackClick(NIL);
      end;
  2 : begin
       if (Shift = []) and (Key = VK_F1) then SBHelpClick(NIL);
       if (Shift = []) and (Key = VK_F4) then SBCommitMiscClick(NIL);
       if (Shift = []) and (Key = VK_ESCAPE) then SBRollbackMiscClick(NIL);
      end;
  END;
end;

procedure TINFWindow2.MemoINFDblClick(Sender: TObject);
var sc  : Integer;
    wl  : Integer;
    wstr: String;
    par : Integer;
    go  : Boolean;
    TheSector : TSector;
begin
 go := FALSE;
 if GetSectorNumFromNameNoCase(LTrim(RTrim(MemoINF.SelText)), sc ) then
  begin
   go := TRUE;
   wl := -1;
  end
 else
  begin
   { try the sector(wall) construct !!!}
   par := Pos('(' , LTrim(RTrim(MemoINF.SelText)));
   if par <> 0 then
    if GetSectorNumFromNameNoCase(Copy(LTrim(RTrim(MemoINF.SelText)),1,par-1), sc ) then
     begin
      wstr := Copy(LTrim(RTrim(MemoINF.SelText)), par+1, 999);
      par := Pos(')' , wstr);
      if par <> 0 then
       begin
        wstr := Copy(wstr, 1 , par-1);
        wl   := StrToIntDef(wstr, -1);
        if wl > -1 then
         begin
          TheSector := TSector(MAP_SEC.Objects[sc]);
          if wl < TheSector.Wl.Count then
           begin
            go := TRUE;
           end;
         end;
       end;
     end;
  end;

 if go then
  if MemoINF.Modified then
    begin
     CASE Application.MessageBox('Commit changes ?', 'INF Editor',
                                 mb_YesNoCancel or mb_IconQuestion) OF
      idYes : begin
               SBCheckClick(NIL);
               if (INF2Status.Caption = '') or (INF2Status.Caption = 'No Error') then
                begin
                 MemoToINFItems(INFSector, INFWall, MemoINF);
                 ComputeINFClasses(INFSector, INFWall);
                 CASE MAP_MODE OF
                  MM_SC : DO_Fill_SectorEditor;
                  MM_WL : DO_Fill_WallEditor;
                 END;
                 MODIFIED := TRUE;
                 MemoINF.Modified := FALSE;
                end
               else
                begin
                 Application.MessageBox('Please correct error first.', 'INF Editor',
                                 mb_Ok or mb_IconExclamation);
                 go := FALSE;
                end;
              end;
      idNo  : begin
              end;
      idCancel : go := FALSE;
     END;
    end;

 if go then
  begin
   INFWall   := wl;
   INFSector := sc;
   FillINFSectorNames;
   ActivateItem;
   AddToNavigator(INFSector, INFWall);
   MemoINF.SelStart  := SendMessage(MemoINF.Handle, EM_LINEINDEX, 0, 0);
   MemoINF.SelLength := 0;
  end;
end;

{***************************************************************************}
{PAGE 3}

procedure TINFWindow2.SBExitMiscClick(Sender: TObject);
var closeok : Boolean;
begin
 closeok := TRUE;
 if MemoINFMisc.Modified then
  begin
   CASE Application.MessageBox('Commit changes ?', 'INF Editor',
                               mb_YesNoCancel or mb_IconQuestion) OF
    idYes : begin
             SBCommitMiscClick(NIL);
            end;
    idNo  : ;
    idCancel : closeok := FALSE;
   END;
  end
 else ;

if closeok then
  begin
   MainNotebook.PageIndex := 0;
   if MemoINF.Modified then
    begin
     CASE Application.MessageBox('Commit changes ?', 'INF Editor',
                                 mb_YesNoCancel or mb_IconQuestion) OF
      idYes : begin
               SBCommitClick(NIL);
              end;
      idNo  : ;
      idCancel : closeok := FALSE;
     END;
    end
   else ;
  end;

 if closeok then Close;
end;

procedure TINFWindow2.SBCommitMiscClick(Sender: TObject);
begin
 CASE INFMisc OF
  0: begin
      INFComments.Clear;
      INFComments.AddStrings(MemoINFMisc.Lines);
      MemoINFMisc.Modified := FALSE;
     end;
  1: begin
      INFLevel.Clear;
      INFLevel.AddStrings(MemoINFMisc.Lines);
      MemoINFMisc.Modified := FALSE;
     end;
  2: begin
      INFErrors.Clear;
      INFErrors.AddStrings(MemoINFMisc.Lines);
      MemoINFMisc.Modified := FALSE;
     end;
  ELSE ;
 END;
 MODIFIED := TRUE;
end;

procedure TINFWindow2.SBRollbackMiscClick(Sender: TObject);
begin
 MemoINFMisc.Clear;
 CASE INFMisc OF
  0 : MemoINFMisc.Lines.AddStrings(INFComments);
  1 : MemoINFMisc.Lines.AddStrings(INFLevel);
  2 : MemoINFMisc.Lines.AddStrings(INFErrors);
 END;
 MemoINFMisc.Modified := FALSE;
end;

procedure TINFWindow2.SBInfCommentsClick(Sender: TObject);
var go : Boolean;
begin
 go := TRUE;
 if MemoINFMisc.Modified then
  begin
   CASE Application.MessageBox('Commit changes ?', 'INF Editor',
                               mb_YesNoCancel or mb_IconQuestion) OF
    idYes : begin
             SBCommitMiscClick(NIL);
            end;
    idNo  : ;
    idCancel : go := FALSE;
   END;
  end;
 if go then
  begin
   MemoINFMisc.Clear;
   MemoINFMisc.Lines.AddStrings(INFComments);
   MemoINFMisc.Modified := FALSE;
   INFMisc := 0;
  end
 else
  begin
   CASE INFMisc OF
    0: SBInfComments.Down := TRUE;
    1: SBInfLevel.Down := TRUE;
    2: SBInfErrors.Down := TRUE;
   END;
  end;
end;

procedure TINFWindow2.SBInfLevelClick(Sender: TObject);
var go : Boolean;
begin
 go := TRUE;
 if MemoINFMisc.Modified then
  begin
   CASE Application.MessageBox('Commit changes ?', 'INF Editor',
                               mb_YesNoCancel or mb_IconQuestion) OF
    idYes : begin
             SBCommitMiscClick(NIL);
            end;
    idNo  : ;
    idCancel : go := FALSE;
   END;
  end;
 if go then
  begin
   MemoINFMisc.Clear;
   MemoINFMisc.Lines.AddStrings(INFLevel);
   MemoINFMisc.Modified := FALSE;
   INFMisc := 1;
  end
 else
  begin
   CASE INFMisc OF
    0: SBInfComments.Down := TRUE;
    1: SBInfLevel.Down := TRUE;
    2: SBInfErrors.Down := TRUE;
   END;
  end;
end;

procedure TINFWindow2.SBInfErrorsClick(Sender: TObject);
var go : Boolean;
begin
 go := TRUE;
 if MemoINFMisc.Modified then
  begin
   CASE Application.MessageBox('Commit changes ?', 'INF Editor',
                               mb_YesNoCancel or mb_IconQuestion) OF
    idYes : begin
             SBCommitMiscClick(NIL);
            end;
    idNo  : ;
    idCancel : go := FALSE;
   END;
  end;
 if go then
  begin
   MemoINFMisc.Clear;
   MemoINFMisc.Lines.AddStrings(INFErrors);
   MemoINFMisc.Modified := FALSE;
   INFMisc := 2;
  end
 else
  begin
   CASE INFMisc OF
    0: SBInfComments.Down := TRUE;
    1: SBInfLevel.Down := TRUE;
    2: SBInfErrors.Down := TRUE;
   END;
  end;
end;


procedure TINFWindow2.TabSetClick(Sender: TObject);
begin
 Notebook.PageIndex := TabSet.TabIndex;
end;

{**************************************************************************}

procedure TINFWindow2.BNTextMsgEditClick(Sender: TObject);
begin
 LBTextTextMSG.Items.LoadFromFile(LEVELPath + '\TEXT.MSG');
end;

procedure TINFWindow2.LBTextTextMSGClick(Sender: TObject);
var strin  : string;
    msgnum : Integer;
begin
 strin  := LBTextTextMSG.Items[LBTextTextMSG.ItemIndex];
 msgnum := StrToIntDef(RTrim(Copy(strin,1,3)), -12345);
 if msgnum <> -12345 then
  EDTextMsgNum.Text := IntToStr(msgnum);
end;

procedure TINFWindow2.LookUpSectorClick(Sender: TObject);
begin
   MemoINFDblClick(NIL);
end;

procedure TINFWindow2.EDElevSound1DblClick(Sender: TObject);
begin
 EDElevSound1.Text := ResEdit(EDElevSound1.Text, RST_SND);
end;

procedure TINFWindow2.EDElevSound2DblClick(Sender: TObject);
begin
 EDElevSound2.Text := ResEdit(EDElevSound2.Text, RST_SND);
end;

procedure TINFWindow2.EDElevSound3DblClick(Sender: TObject);
begin
 EDElevSound3.Text := ResEdit(EDElevSound3.Text, RST_SND);
end;

procedure TINFWindow2.EDTrigSoundDblClick(Sender: TObject);
begin
 EDTrigSound.Text := ResEdit(EDTrigSound.Text, RST_SND);
end;

procedure TINFWindow2.EDPageFileDblClick(Sender: TObject);
begin
 EDPageFile.Text := ResEdit(EDPageFile.Text, RST_SND);
end;

procedure TINFWindow2.RGMessageTypeClick(Sender: TObject);
begin
 EDMsgParam1.Text := '';
 EDMsgParam2.Text := '';
 EDMsgParam1.Visible := FALSE;
 EDMsgParam2.Visible := FALSE;
 STParam1.Caption := '';
 STParam2.Caption := '';

 CASE RGMessageType.ItemIndex OF
   0: begin
       {next_stop}
       EDMsgParam1.Visible := TRUE;
       STParam1.Caption := 'event (opt.)';
      end;
   1: begin
       {prev_stop}
       EDMsgParam1.Visible := TRUE;
       STParam1.Caption := 'event (opt.)';
      end;
   2: begin
       {goto_stop}
       EDMsgParam1.Visible := TRUE;
       EDMsgParam1.Text := '0';
       STParam1.Caption := 'stopnum (mand.)';
       EDMsgParam2.Visible := TRUE;
       STParam2.Caption := 'event (opt.)';
      end;
   3: begin
       {complete}
       EDMsgParam1.Visible := TRUE;
       STParam1.Caption := 'goalnum (mand.)';
      end;
   4: begin
       {done}
       {----}
      end;
   5: begin
       {wakeup}
       {----}
      end;
   6: begin
       {master_on}
       EDMsgParam1.Visible := TRUE;
       STParam1.Caption := 'event (opt.)';
      end;
   7: begin
       {master_off}
       EDMsgParam1.Visible := TRUE;
       STParam1.Caption := 'event (opt.)';
      end;
   8: begin
       {m_trigger}
       EDMsgParam1.Visible := TRUE;
       STParam1.Caption := 'event (opt.)';
      end;
   9: begin
       {clear_bits}
       EDMsgParam1.Visible := TRUE;
       EDMsgParam1.Text := '1';
       STParam1.Caption := 'flagnum (mand.)';
       EDMsgParam2.Visible := TRUE;
       EDMsgParam2.Text := '0';
       STParam2.Caption := '+ bits (mand.)';
      end;
  10: begin
       {set_bits}
       EDMsgParam1.Visible := TRUE;
       EDMsgParam1.Text := '1';
       STParam1.Caption := 'flagnum (mand.)';
       EDMsgParam2.Visible := TRUE;
       EDMsgParam2.Text := '0';
       STParam2.Caption := '+ bits (mand.)';
      end;
  11: begin
       {system}
       {----}
      end;
 END;
end;

procedure TINFWindow2.EDMsgParam2DblClick(Sender: TObject);
begin
  if (EDMsgParam1.Text = '1') or
     (EDMsgParam1.Text = '2') or
     (EDMsgParam1.Text = '3') then
   begin
    if CBMessageUseWL.Checked then
     EDMsgParam2.Text := FlagEdit(EDMsgParam2.Text, 'wl_flag'+EDMsgParam1.Text+'.wdf', 'Wall Flag '+EDMsgParam1.Text)
    else
     EDMsgParam2.Text := FlagEdit(EDMsgParam2.Text, 'sc_flag'+EDMsgParam1.Text+'.wdf', 'Sector Flag '+EDMsgParam1.Text);
   end
  else
   Application.MessageBox('Flagnum must be 1, 2 or 3', 'INF Editor', mb_Ok or mb_IconExclamation);

end;

procedure TINFWindow2.CBElevTypeClick(Sender: TObject);
begin

 STKey.Visible         := TRUE;
 CBElevKey.Visible     := TRUE;
 CBElevKey2.Visible    := FALSE;
 EDElevSpeed2.Visible  := FALSE;
 STAngle.Visible       := FALSE;
 EDElevAngle.Visible   := FALSE;
 STCenter.Visible      := FALSE;
 EDElevCenterX.Visible := FALSE;
 EDElevCenterZ.Visible := FALSE;

 CBElevKey.ItemIndex   := 0;
 CBElevKey2.ItemIndex  := 0;
 EDElevSpeed.Text      := '';
 EDElevSpeed2.Text     := '';
 EDElevAngle.Text      := '';
 EDElevCenterX.Text    := '';
 EDElevCenterZ.Text    := '';
 EDElevFlags.Text      := '';
 EDElevSound1.Text     := '';
 EDElevSound2.Text     := '';
 EDElevSound3.Text     := '';

 CASE CBElevType.ItemIndex OF
   0 : begin
       end;
   1 : begin
        STKey.Visible := FALSE;
        CBElevKey.Visible := FALSE;
       end;
   2 : begin
        STKey.Visible := FALSE;
        CBElevKey.Visible := FALSE;
       end;
   3 : begin
       end;
   4 : begin  {door_mid}
        CBElevKey2.Visible := TRUE;
        EDElevSpeed2.Visible := TRUE;
       end;
   5 : begin
       end;
   6 : begin
        STAngle.Visible := TRUE;
        EDElevAngle.Visible := TRUE;
       end;
   7 : begin
        STAngle.Visible := TRUE;
        EDElevAngle.Visible := TRUE;
       end;
   8 : begin
        STCenter.Visible  := TRUE;
        EDElevCenterX.Visible := TRUE;
        EDElevCenterZ.Visible := TRUE;
       end;
   9 : begin
        STCenter.Visible  := TRUE;
        EDElevCenterX.Visible := TRUE;
        EDElevCenterZ.Visible := TRUE;
       end;
  10 : begin
       end;
  11 : begin
       end;
  12 : begin
       end;
  13 : begin
       end;
  14 : begin
         EDElevAngle.Visible := TRUE;
         STKey.Visible := FALSE;
         CBElevKey.Visible := FALSE;
       end;
  15 : begin
        STCenter.Visible  := TRUE;
        EDElevCenterX.Visible := TRUE;
        EDElevCenterZ.Visible := TRUE;
       end;
  16 : begin
        STAngle.Visible := TRUE;
        EDElevAngle.Visible := TRUE;
        STKey.Visible := FALSE;
        CBElevKey.Visible := FALSE;
       end;
  17 : begin
        STAngle.Visible := TRUE;
        EDElevAngle.Visible := TRUE;
        STKey.Visible := FALSE;
        CBElevKey.Visible := FALSE;
       end;
  18 : begin
        STAngle.Visible := TRUE;
        EDElevAngle.Visible := TRUE;
        STKey.Visible := FALSE;
        CBElevKey.Visible := FALSE;
       end;
 END;

end;

{***********************************************************************}

procedure TINFWindow2.SBElevClick(Sender: TObject);
begin
 if Sender = SBElev      then TabSet.TabIndex := 0;
 if Sender = SBTrig      then TabSet.TabIndex := 1;
 if Sender = SBChute     then TabSet.TabIndex := 2;
 if Sender = SBStop      then TabSet.TabIndex := 3;
 if Sender = SBAdjoin    then TabSet.TabIndex := 4;
 if Sender = SBMessage   then TabSet.TabIndex := 5;
 if Sender = SBPage      then TabSet.TabIndex := 6;
 if Sender = SBText      then TabSet.TabIndex := 7;
 if Sender = SBEventMask then TabSet.TabIndex := 9;

 MainNotebook.PageIndex := 1;
end;

procedure TINFWindow2.SBWizGenerateClick(Sender: TObject);
var s   : String;
    id  : String;
    i,j : Integer;
    m   : longint;
    ms  : string;
begin
 if SBIndent.Down then
  id := '  '
 else
  id := '';

 CASE Notebook.PageIndex OF
  0: begin
      if CBElevSeqSeqend.Checked then
       s := #13 + #10 + 'seq'
      else
       s := '';

      s := s + #13 + #10 + id + 'class: elevator ' + CBElevType.Items[CBElevType.ItemIndex];
      if CBElevMaster.ItemIndex > 0 then
      s := s + #13 + #10 + id + id + id + 'master: ' + CBElevMaster.Items[CBElevMaster.ItemIndex];

      m := 0;
      for i := 0 to LBElevEventMask.Items.Count - 1 do
       if LBElevEventMask.Selected[i] then
        m := m + LongInt(1) shl i;
      if (m <> 0) or ((m = 0) and CBElevEventMask.Checked) then
       s := s + #13 + #10 + id + id + id + 'event_mask: ' + IntToStr(m);

      if EDElevFlags.Text <> '' then
       s := s + #13 + #10 + id + id + id + 'flags: ' + EDElevFlags.Text;

      if EDElevSound1.Text <> '' then
       s := s + #13 + #10 + id + id + id + 'sound: 1 ' + EDElevSound1.Text;
      if EDElevSound2.Text <> '' then
       s := s + #13 + #10 + id + id + id + 'sound: 2 ' + EDElevSound2.Text;
      if EDElevSound3.Text <> '' then
       s := s + #13 + #10 + id + id + id + 'sound: 3 ' + EDElevSound3.Text;

      memoINF.SelText := s;
      s := '';

      if EDElevAngle.Visible then
      if EDElevAngle.Text <> '' then
       s := s + #13 + #10 + id + id + id + 'angle: ' + EDElevAngle.Text;

      if EDElevCenterX.Visible then
      if EDElevCenterX.Text <> '' then
       s := s + #13 + #10 + id + id + id + 'center: ' + EDElevCenterX.Text + ' '
                                                      + EDElevCenterZ.Text;
{ DOOR_MID TEXT TO ADD FOR ITEMS}
      if CBElevType.Items[CBElevType.ItemIndex] <> 'door_mid' then
       begin
        if CBElevKey.ItemIndex > 0 then
         s := s + #13 + #10 + id + id + id + 'key: ' + CBElevKey.Items[CBElevKey.ItemIndex];
        if EDElevSpeed.Text <> '' then
         s := s + #13 + #10 + id + id + id + 'speed: ' + EDElevSpeed.Text;
       end
      else
       begin
        if (CBElevKey.ItemIndex > 0) or (EDElevSpeed.Text <> '') then
         begin
          s := s + #13 + #10 + id + id + 'addon: 0';
          if CBElevKey.ItemIndex > 0 then
           s := s + #13 + #10 + id + id + id + 'key: ' + CBElevKey.Items[CBElevKey.ItemIndex];
          if EDElevSpeed.Text <> '' then
           s := s + #13 + #10 + id + id + id + 'speed: ' + EDElevSpeed.Text;
          s := s + #13 + #10 + id + id + 'addon: 1';
          if CBElevKey2.ItemIndex > 0 then
           s := s + #13 + #10 + id + id + id + 'key: ' + CBElevKey2.Items[CBElevKey2.ItemIndex];
          if EDElevSpeed2.Text <> '' then
           s := s + #13 + #10 + id + id + id + 'speed: ' + EDElevSpeed2.Text;
         end;
       end;

      memoINF.SelText := s;
      s := '';
      for i := 0 to LBElevSlaves.Items.Count - 1 do
       if LBElevSlaves.Selected[i] then
        s := s + #13 + #10 + id + id + 'slave: ' + LBTrigClients.Items[i];
      if CBElevSeqSeqend.Checked then s := s + #13 + #10 + 'seqend';
      memoINF.SelText := s;
     end;
  1: begin
      s := #13 + #10 + 'seq';
      s := s + #13 + #10 + id + 'class: trigger ' + CBTrigType.Items[CBTrigType.ItemIndex];
      if CBTrigMaster.ItemIndex > 0 then
      s := s + #13 + #10 + id + id + id + 'master: ' + CBTrigMaster.Items[CBTrigMaster.ItemIndex];

      m := 0;
      for i := 0 to LBTrigEventMask.Items.Count - 1 do
       if LBTrigEventMask.Selected[i] then
        m := m + LongInt(1) shl i;
      if (m <> 0) or ((m = 0) and CBTrigEventMask.Checked) then
       s := s + #13 + #10 + id + id + id + 'event_mask: ' + IntToStr(m);

      j := 0;
      for i := 0 to 2 do
       if LBTrigEntity.Selected[i] then Inc(j);
      if j > 0 then
       begin
        if j = 3 then
         begin
          s := s + #13 + #10 + id + id + id + 'entity_mask: *';
         end
        else
         begin
          {
          m := 0;
          if LBTrigEntity.Selected[0] then m := m + 2147483647 + 1;
          if LBTrigEntity.Selected[1] then m := m + 1;
          if LBTrigEntity.Selected[2] then m := m + 8;
          }

          if LBTrigEntity.Selected[0] then
           begin
            if LBTrigEntity.Selected[1] then
             ms := '2147483649'
            else
             if LBTrigEntity.Selected[2] then
              ms := '2147483656'
             else
              ms := '2147483648'
           end
          else
           begin
            if LBTrigEntity.Selected[1] then
             begin
              if LBTrigEntity.Selected[2] then
               ms := '9'
              else
               ms := '1';
             end
            else
             ms := '8';
           end;
          s := s + #13 + #10 + id + id + id + 'entity_mask: ' + ms;
         end;
       end;

      m := 0;
      for i := 0 to LBTrigEvent.Items.Count - 1 do
       if LBTrigEvent.Selected[i] then
        m := m + LongInt(1) shl i;
      if m <> 0 then
       s := s + #13 + #10 + id + id + id + 'event: ' + IntToStr(m);

      if EDTrigSound.Text <> '' then
       s := s + #13 + #10 + id + id + id + 'sound: ' + EDTrigSound.Text;

      memoINF.SelText := s;
      s := '';
      for i := 0 to LBTrigClients.Items.Count - 1 do
       if LBTrigClients.Selected[i] then
        s := s + #13 + #10 + id + id + 'client: ' + LBTrigClients.Items[i];
      s := s + #13 + #10 + 'seqend';
      memoINF.SelText := s;
     end;
  2: begin
      s := #13 + #10 + 'seq';
      s := s + #13 + #10 + id + 'class: teleporter chute';
      s := s + #13 + #10 + id + id + 'target: ' + CBChuteTarget.Text;
      s := s + #13 + #10 + 'seqend';
      memoINF.SelText := s;
     end;
  3: begin
      s := #13 + #10 + id + id +'stop: ';
      if CBStopRelative.Checked then s := s + '@';
      s := s + CBStopValue.Text + ' ';
      CASE RGStopDHT.ItemIndex OF
       0 : s := s + EDStopDelayValue.Text;
       1 : s := s + 'hold';
       2 : s := s + 'terminate';
       3 : s := s + 'complete';
      END;
      memoINF.SelText := s;
     end;
  4: begin
      MemoINF.SelText := #13 + #10 + id+id+id+ 'adjoin: ' + IntToStr(SEAdjoin.Value)
                                   + ' ' + CBAdjoinSC1.Text
                                   + ' ' + IntToStr(SEAdjoinWL1.Value)
                                   + ' ' + CBAdjoinSC2.Text
                                   + ' ' + IntToStr(SEAdjoinWL2.Value);
     end;
  5: begin
      if CBMessageUseElevSyntax.Checked then
       begin
        s := #13 + #10 + id+id+id+'message: ' + IntToStr(SEMessage.Value) + ' '
                                           + CBMessageSC.Text;
        if CBMessageUseWL.Checked then
         s := s + '(' + IntToStr(SEMessageWL.Value) + ')';
       end
      else
       s := #13 + #10 + id+id+id+'message:';

      s := s + ' ' + RGMessageType.Items[RGMessageType.ItemIndex];
      s := s + ' ' + EDMsgParam1.Text + ' ' + EDMsgParam2.Text;
      memoINF.SelText := s;
     end;
  6: begin
      MemoINF.SelText := #13 + #10 + id+id+id+'page: ' + IntToStr(SEPage.Value)
                                   + ' ' + EDPageFile.Text;
     end;
  7: begin
      MemoINF.SelText := #13 + #10 + id+id+id+'text: ' + EDTextMsgNum.Text;
     end;
  8: begin
      {texture: [stopnum] [flag] [donor]}
      MemoINF.SelText := #13 + #10 + id+id+id + 'texture: '
                                   + IntToStr(SETexture.Value) + ' '
                                   + EDTexture.Text + ' '
                                   + CBTexture.Text;
     end;
  9: begin
      m := 0;
      for i := 0 to LBEvMkEventMask.Items.Count - 1 do
       if LBEvMkEventMask.Selected[i] then
        m := m + LongInt(1) shl i;
      MemoINF.SelText := #13 + #10 + id + id + id + 'event_mask: ' + IntToStr(m);
     end;
 END;

 MainNotebook.PageIndex := 0;
end;

procedure TINFWindow2.INFStayOnTopCheckBoxClick(Sender: TObject);
begin
  if INFStayOnTopCheckBox.Checked then
    begin
     ontop := true;
     INFWindow2.FormStyle := fsStayOnTop;
    end
   else
    begin
     ontop := false;
     INFWindow2.FormStyle := fsNormal;
    end;
end;

procedure TINFWindow2.BNChuteSCSelClick(Sender: TObject);
var TheSector    : TSector;
begin
 if MAP_MODE = MM_SC then
  begin
   TheSector := TSector(MAP_SEC.Objects[SC_HILITE]);
   if TheSector.Name <> '' then
    begin
     if Sender = BNChuteSCSel then CBChuteTarget.Text := TheSector.Name;
     if Sender = BNStopSCSel then CBStopValue.Text := TheSector.Name;
     if Sender = BNMessageUseSCSel then
      begin
       CBMessageSC.Text := TheSector.Name;
       CBMessageUseElevSyntax.Checked := TRUE;
       CBMessageUseWL.Checked := FALSE;
      end;
     if Sender = BNTextureUseSCSel then CBTexture.Text := TheSector.Name;
    end
   else
    Application.MessageBox('The sector must have a name !', 'INF Editor', mb_Ok or mb_IconExclamation);
  end
 else
  Application.MessageBox('You must be in SC mode !', 'INF Editor', mb_Ok or mb_IconExclamation);
end;

procedure TINFWindow2.BNMessageUseWLSelClick(Sender: TObject);
var TheSector    : TSector;
begin
 if MAP_MODE = MM_WL then
  begin
   TheSector := TSector(MAP_SEC.Objects[SC_HILITE]);
   if TheSector.Name <> '' then
    begin
     if Sender = BNMessageUseWLSel then
      begin
       CBMessageSC.Text := TheSector.Name;
       SEMessageWL.Value := WL_HILITE;
       CBMessageUseElevSyntax.Checked := TRUE;
       CBMessageUseWL.Checked := TRUE;
      end;
    end
   else
    Application.MessageBox('The sector must have a name !', 'INF Editor', mb_Ok or mb_IconExclamation);
  end
 else
  Application.MessageBox('You must be in WL mode !', 'INF Editor', mb_Ok or mb_IconExclamation);
end;

procedure TINFWindow2.BNElevSCMultisClick(Sender: TObject);
var TheSector    : TSector;
    i            : Integer;
    ix           : Integer;
begin
 FillINFSectorNames;
 if MAP_MODE = MM_SC then
  begin
   for i := 0 to SC_MULTIS.Count - 1 do
    begin
     TheSector := TSector(MAP_SEC.Objects[StrToInt(LTrim(Copy(SC_MULTIS[i],1,4)))]);
     if TheSector.Name <> '' then
      begin
       if Sender = BNElevSCMultis then
        begin
         ix := LBElevSlaves.Items.IndexOf(TheSector.Name);
         if ix <> - 1 then LBElevSlaves.Selected[ix] := TRUE;
        end;
       if Sender = BNTrigSCMultis then
        begin
         ix := LBTrigClients.Items.IndexOf(TheSector.Name);
         if ix <> - 1 then LBTrigClients.Selected[ix] := TRUE;
        end;
      end;
    end;
  end
 else
  Application.MessageBox('You must be in SC mode !', 'INF Editor', mb_Ok or mb_IconExclamation);
end;



end.
