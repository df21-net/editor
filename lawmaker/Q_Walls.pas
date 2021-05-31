unit Q_Walls;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Q_Utils, Misc_Utils, Level, MultiSelection, Buttons;

type
  TFindWalls = class(TForm)
    Label1: TLabel;
    CBID: TComboBox;
    EBID: TEdit;
    Label2: TLabel;
    CBMID: TComboBox;
    EBMID: TEdit;
    Label3: TLabel;
    CBFlags: TComboBox;
    EBFlags: TEdit;
    Label4: TLabel;
    CBTOP: TComboBox;
    EBTOP: TEdit;
    Label5: TLabel;
    CBBOT: TComboBox;
    EBBOT: TEdit;
    Label6: TLabel;
    CBOverlay: TComboBox;
    EBOverlay: TEdit;
    Label7: TLabel;
    CBLight: TComboBox;
    EBLight: TEdit;
    GroupBox1: TGroupBox;
    RBAdd: TRadioButton;
    RBSubtract: TRadioButton;
    RBFocus: TRadioButton;
    BNFind: TButton;
    BNCancel: TButton;
    CBSelOnly: TCheckBox;
    BNMID: TButton;
    BNTOP: TButton;
    BNBOT: TButton;
    BNOverlay: TButton;
    BNFlags: TButton;
    SBHelp: TSpeedButton;
    Label8: TLabel;
    CBAdjoin: TComboBox;
    EBAdjoin: TEdit;
    Label9: TLabel;
    CBMirror: TComboBox;
    EBMirror: TEdit;
    Label10: TLabel;
    CBDAdjoin: TComboBox;
    EBDAdjoin: TEdit;
    Label11: TLabel;
    CBDMirror: TComboBox;
    EBDMirror: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure BNMIDClick(Sender: TObject);
    procedure BNTOPClick(Sender: TObject);
    procedure BNBOTClick(Sender: TObject);
    procedure BNOverlayClick(Sender: TObject);
    procedure BNFlagsClick(Sender: TObject);
    procedure SBHelpClick(Sender: TObject);
  private
    fi:TWallFindInfo;
    { Private declarations }
  public
    { Public declarations }
    MapWindow:TForm;
    Function Find:Boolean;
    Function FindNext(curSC,curWL:integer):boolean;
  end;

var
  FindWalls: TFindWalls;

implementation

uses ResourcePicker, FlagEditor, Mapper;

{$R *.DFM}

procedure TFindWalls.FormCreate(Sender: TObject);
begin
 ClientWidth:=Label5.Left+GroupBox1.Left+GroupBox1.Width;
 ClientHeight:=Label1.Top+BNFind.Top+BNFind.Height;
 fi:=TWallFindInfo.Create;
 TQueryField.CreateHex(CBID,EBID,fi.HexID);
 TQueryField.CreateStr(CBMID,EBMID,fi.MID);
 TQueryField.CreateStr(CBTOP,EBTOP,fi.TOP);
 TQueryField.CreateStr(CBBOT,EBBOT,fi.BOT);
 TQueryField.CreateStr(CBOverlay,EBOverlay,fi.Overlay);
 TQueryField.CreateFlags(CBFlags,EBFlags,fi.Flags);
 TQueryField.CreateInt(CBLight,EBLight,fi.Light);
 TQueryField.CreateInt(CBAdjoin,EBAdjoin,fi.Adjoin);
 TQueryField.CreateInt(CBDAdjoin,EBDAdjoin,fi.DAdjoin);
 TQueryField.CreateInt(CBMirror,EBMirror,fi.Mirror);
 TQueryField.CreateInt(CBDMirror,EBDMirror,fi.DMirror);
end;

procedure TFindWalls.BNMIDClick(Sender: TObject);
begin
 EBMid.Text:=ResPicker.PickTexture(EBMid.Text);
end;

procedure TFindWalls.BNTOPClick(Sender: TObject);
begin
 EBTop.Text:=ResPicker.PickTexture(EBTop.Text);
end;

procedure TFindWalls.BNBOTClick(Sender: TObject);
begin
 EBBot.Text:=ResPicker.PickTexture(EBBot.Text);
end;

procedure TFindWalls.BNOverlayClick(Sender: TObject);
begin
 EBOverlay.Text:=ResPicker.PickTexture(EBOverlay.Text);
end;

procedure TFindWalls.BNFlagsClick(Sender: TObject);
var F:Longint;
begin
 ValDword(EBFlags.Text,f);
 f:=FlagEdit.EditWallFlags(f);
 EBFlags.Text:=DwordToStr(f);
end;

Function TFindWalls.Find;
var Lev:TLevel;
    nWl,s,w:Integer;
    Ms:TMultiSelection;
    OldCursor:HCursor;
begin
Result:=false;
 Lev:=TMapWindow(MapWindow).Level;
 ms:=TMapWindow(MapWindow).WLMultiSel;
 if ShowModal<>mrOK then exit;
 
OldCursor  := SetCursor(LoadCursor(0, IDC_WAIT));
if RBAdd.Checked then
begin
 w:=FindNextWall(Lev,0,-1,fi,s);
 While w<>-1 do
 begin
  Result:=true;
  if ms.FindWall(s,w)=-1 then ms.AddWall(s,w);
  w:=FindNextWall(Lev,s,w,fi,s);
 end;
end;

if RBSubtract.Checked then
begin
 w:=FindNextWall(Lev,0,-1,fi,s);
 While w<>-1 do
 begin
  Result:=true;
  nWl:=ms.FindWall(s,w);
  if nWL<>-1 then ms.Delete(nWl);
  w:=FindNextWall(Lev,s,w,fi,s);
 end;
end;

if RBFocus.Checked then
begin
 w:=FindNextWall(Lev,0,-1,fi,s);
 if w<>-1 then
 begin
  TMapWindow(MapWindow).Goto_Wall(s,w);
  Result:=true;
 end;
end;

SetCursor(OldCursor);

if not Result then ShowMessage('No hits!');

end;

Function TFindWalls.FindNext(CurSC,curWL:Integer):Boolean;
var s,w:Integer;lev:TLevel;
begin
 Lev:=TMapWindow(MapWindow).Level;
 w:=FindNextWall(Lev,CurSC,CurWL,fi,s);
  if w<>-1 then
 begin
  TMapWindow(MapWindow).Goto_Wall(s,w);
  Result:=true;
 end;
Result:=w<>-1;
if not Result then ShowMessage('No more hits!');
end;


procedure TFindWalls.SBHelpClick(Sender: TObject);
begin
 Application.HelpJump('Hlp_Find_Walls');
end;

end.
