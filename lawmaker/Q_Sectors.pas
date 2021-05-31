unit Q_Sectors;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Q_Utils, misc_utils, Level, MultiSelection, Buttons;

type
  TFindSectors = class(TForm)
    Label1: TLabel;
    CBID: TComboBox;
    EBID: TEdit;
    LBName: TLabel;
    CBName: TComboBox;
    EBName: TEdit;
    Label3: TLabel;
    CBFlags: TComboBox;
    EBFlags: TEdit;
    Label4: TLabel;
    CBPalette: TComboBox;
    EBPalette: TEdit;
    Label5: TLabel;
    CBFOverlay_TX: TComboBox;
    EBFOverlay_TX: TEdit;
    Label7: TLabel;
    CBAmbient: TComboBox;
    EBAmbient: TEdit;
    GroupBox1: TGroupBox;
    RBAdd: TRadioButton;
    RBSubtract: TRadioButton;
    RBFocus: TRadioButton;
    BNFind: TButton;
    BNCancel: TButton;
    CBSelOnly: TCheckBox;
    BNPalette: TButton;
    VBNFOverlay_TX: TButton;
    BNFlags: TButton;
    Label2: TLabel;
    CBCMap: TComboBox;
    EBCMap: TEdit;
    BNCMap: TButton;
    Label8: TLabel;
    CBFriction: TComboBox;
    EBFriction: TEdit;
    Label9: TLabel;
    CBGravity: TComboBox;
    EBGravity: TEdit;
    Label10: TLabel;
    CBElasticity: TComboBox;
    EBElasticity: TEdit;
    Label11: TLabel;
    CBVel_X: TComboBox;
    EBVel_X: TEdit;
    Label12: TLabel;
    CBVel_Y: TComboBox;
    EBVel_Y: TEdit;
    Label13: TLabel;
    CBVel_Z: TComboBox;
    EBVel_Z: TEdit;
    Label14: TLabel;
    CBVAdjoin: TComboBox;
    EBVAdjoin: TEdit;
    CBFSound: TComboBox;
    BNFSound: TButton;
    EBFSound: TEdit;
    Label15: TLabel;
    Label16: TLabel;
    CBFloor_Y: TComboBox;
    EBFloor_Y: TEdit;
    Label17: TLabel;
    CBFloor_TX: TComboBox;
    EBFloor_TX: TEdit;
    BNFloor_TX: TButton;
    Label18: TLabel;
    CBCeiling_TX: TComboBox;
    EBCeiling_TX: TEdit;
    BNCeiling_TX: TButton;
    Label19: TLabel;
    CBCeiling_Y: TComboBox;
    EBCeiling_Y: TEdit;
    Label20: TLabel;
    CBCOverlay_TX: TComboBox;
    EBCOverlay_TX: TEdit;
    BNCOverlay_TX: TButton;
    Label6: TLabel;
    CBLayer: TComboBox;
    EBLayer: TEdit;
    SBHelp: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure BNPaletteClick(Sender: TObject);
    procedure BNCMapClick(Sender: TObject);
    procedure BNFSoundClick(Sender: TObject);
    procedure BNFloor_TXClick(Sender: TObject);
    procedure BNCeiling_TXClick(Sender: TObject);
    procedure VBNFOverlay_TXClick(Sender: TObject);
    procedure BNCOverlay_TXClick(Sender: TObject);
    procedure BNFlagsClick(Sender: TObject);
    procedure SBHelpClick(Sender: TObject);
  private
    { Private declarations }
    fi:TSectorFindInfo;
  public
    { Public declarations }
    MapWindow:TForm;
    Function Find:Boolean;
    Function FindNext(curSC:integer):boolean;
  end;

var
  FindSectors: TFindSectors;

implementation

uses ResourcePicker, FlagEditor, Mapper;

{$R *.DFM}

procedure TFindSectors.FormCreate(Sender: TObject);
begin
 ClientWidth:=Label15.Left+BNFlags.Left+BNFlags.Width;
 ClientHeight:=Label1.Top+BNFind.Top+BNFind.Height;
 fi:=TSectorFindInfo.Create;
 TQueryField.CreateHex(CBID,EBID,fi.HexID);
 TQueryField.CreateStr(CBName,EBName,fi.Name);
 TQueryField.CreateInt(CBAmbient,EBAmbient,fi.Ambient);
 TQueryField.CreateStr(CBPalette,EBPalette,fi.Palette);
 TQueryField.CreateStr(CBCmap,EBCmap,fi.ColorMap);

 TQueryField.CreateDouble(CBFriction,EBFriction,fi.Friction);
 TQueryField.CreateDouble(CBGravity,EBGravity,fi.Gravity);
 TQueryField.CreateDouble(CBElasticity,EBElasticity,fi.Elasticity);

 TQueryField.CreateStr(CBFSound,EBFSound,fi.Floor_sound);

 TQueryField.CreateDouble(CBFloor_Y,EBFloor_Y,fi.Floor_Y);
 TQueryField.CreateDouble(CBCeiling_Y,EBCeiling_Y,fi.Ceiling_Y);

 TQueryField.CreateStr(CBFloor_TX,EBFloor_TX,fi.Floor_TX);
 TQueryField.CreateStr(CBCeiling_TX,EBCeiling_TX,fi.Ceiling_TX);
 TQueryField.CreateStr(CBFOverlay_TX,EBFOverlay_TX,fi.F_Overlay_TX);
 TQueryField.CreateStr(CBCOverlay_TX,EBCOverlay_TX,fi.C_Overlay_TX);

 TQueryField.CreateFlags(CBFlags,EBFlags,fi.Flags);
 TQueryField.CreateInt(CBLayer,EBLayer,fi.Layer);

 TQueryField.CreateDouble(CBVel_X,EBVel_X,fi.Velocity_X);
 TQueryField.CreateDouble(CBVel_Y,EBVel_Y,fi.Velocity_Y);
 TQueryField.CreateDouble(CBVel_Z,EBVel_Z,fi.Velocity_Z);

 TQueryField.CreateInt(CBVAdjoin,EBVAdjoin,fi.VAdjoin);
end;

procedure TFindSectors.BNPaletteClick(Sender: TObject);
begin
 EBPalette.Text:=ResPicker.PickPalette(EBPalette.Text);
end;

procedure TFindSectors.BNCMapClick(Sender: TObject);
begin
 EBCMap.Text:=ResPicker.PickPalette(EBCMap.Text);
end;

procedure TFindSectors.BNFSoundClick(Sender: TObject);
begin
 EBFSound.Text:=ResPicker.PickFloorSound(EBFSound.Text);
end;

procedure TFindSectors.BNFloor_TXClick(Sender: TObject);
begin
 EBFloor_TX.Text:=ResPicker.PickTexture(EBFloor_TX.Text);
end;

procedure TFindSectors.BNCeiling_TXClick(Sender: TObject);
begin
 EBCeiling_TX.Text:=ResPicker.PickTexture(EBCeiling_TX.Text);
end;

procedure TFindSectors.VBNFOverlay_TXClick(Sender: TObject);
begin
 EBFOverlay_TX.Text:=ResPicker.PickTexture(EBFOverlay_TX.Text);
end;

procedure TFindSectors.BNCOverlay_TXClick(Sender: TObject);
begin
 EBCOverlay_TX.Text:=ResPicker.PickTexture(EBCOverlay_TX.Text);
end;

procedure TFindSectors.BNFlagsClick(Sender: TObject);
var F:Longint;
begin
 ValDword(EBFlags.Text,f);
 f:=FlagEdit.EditSectorFlags(f);
 EBFlags.Text:=DwordToStr(f);
end;

Function TFindSectors.Find;
var Lev:TLevel;
    nSc,s:Integer;
    Ms:TMultiSelection;
begin
 Result:=false;

 Lev:=TMapWindow(MapWindow).Level;
 ms:=TMapWindow(MapWindow).SCMultiSel;
 if ShowModal<>mrOK then exit;

if RBAdd.Checked then
begin
 s:=FindNextSector(Lev,-1,fi);
 While s<>-1 do
 begin
  if ms.FindSector(s)=-1 then ms.AddSector(s);
  s:=FindNextSector(Lev,s,fi);
  Result:=true;
 end;
end;

if RBSubtract.Checked then
begin
 s:=FindNextSector(Lev,-1,fi);
 While s<>-1 do
 begin
  nSc:=ms.FindSector(s);
  if nSc<>-1 then ms.Delete(nSc);
  s:=FindNextSector(Lev,s,fi);
  Result:=true;
 end;
end;

if RBFocus.Checked then
begin
 s:=FindNextSector(Lev,-1,fi);
 if s<>-1 then
 begin TMapWindow(MapWindow).Goto_Sector(s); Result:=true; end;
end;

if not Result then ShowMessage('No hits!');
end;

Function TFindSectors.FindNext(curSC:Integer):Boolean;
var s:Integer;Lev:TLevel;
begin
 Lev:=TMapWindow(MapWindow).Level;
 s:=FindNextSector(Lev,CurSC,fi);
  if s<>-1 then
 begin
  TMapWindow(MapWindow).Goto_Sector(s);
  Result:=true;
 end;
Result:=s<>-1;
if not Result then ShowMessage('No more hits!');
end;


procedure TFindSectors.SBHelpClick(Sender: TObject);
begin
Application.HelpJump('Hlp_Find_Sectors');
end;

end.
