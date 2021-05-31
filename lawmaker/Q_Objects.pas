unit Q_Objects;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Q_Utils, misc_utils, Level, MultiSelection, Buttons;

type
  TFindObjects = class(TForm)
    Label1: TLabel;
    CBID: TComboBox;
    EBID: TEdit;
    Label2: TLabel;
    CBName: TComboBox;
    EBName: TEdit;
    Label3: TLabel;
    CBFlags1: TComboBox;
    EBFlags1: TEdit;
    GroupBox1: TGroupBox;
    RBAdd: TRadioButton;
    RBSubtract: TRadioButton;
    RBFocus: TRadioButton;
    BNFind: TButton;
    BNCancel: TButton;
    CheckBox1: TCheckBox;
    BNName: TButton;
    BNFlags1: TButton;
    Label4: TLabel;
    CBFlags2: TComboBox;
    EBFlags2: TEdit;
    BNFlags2: TButton;
    SBHelp: TSpeedButton;
    Label5: TLabel;
    CBPCH: TComboBox;
    EBPCH: TEdit;
    Label6: TLabel;
    CBYAW: TComboBox;
    EBYAW: TEdit;
    Label7: TLabel;
    CBROL: TComboBox;
    EBROL: TEdit;
    Label8: TLabel;
    CBX: TComboBox;
    EBX: TEdit;
    Label9: TLabel;
    CBY: TComboBox;
    EBY: TEdit;
    Label10: TLabel;
    CBZ: TComboBox;
    EBZ: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure BNNameClick(Sender: TObject);
    procedure BNFlags1Click(Sender: TObject);
    procedure BNFlags2Click(Sender: TObject);
    procedure SBHelpClick(Sender: TObject);
  private
    { Private declarations }
    fi:TObjectFindInfo;
    LastFound:Boolean;
  public
    { Public declarations }
    MapWindow:TForm;
    Function Find:Boolean;
    Function FindNext(curOB:Integer):Boolean;
  end;

var
  FindObjects: TFindObjects;

implementation

uses ResourcePicker, FlagEditor, Mapper;

{$R *.DFM}

procedure TFindObjects.FormCreate(Sender: TObject);
begin
 fi:=TObjectFindInfo.Create;
 TQueryField.CreateHex(CBID,EBID,fi.HexID);
 TQueryField.CreateStr(CBName,EBName,fi.Name);
 TQueryField.CreateFlags(CBFlags1,EBFlags1,fi.Flags1);
 TQueryField.CreateFlags(CBFlags2,EBFlags2,fi.Flags2);
 TQueryField.CreateDouble(CBPCH,EBPCH,fi.PCH);
 TQueryField.CreateDouble(CBYAW,EBYAW,fi.YAW);
 TQueryField.CreateDouble(CBROL,EBROL,fi.ROL);
 TQueryField.CreateDouble(CBX,EBX,fi.X);
 TQueryField.CreateDouble(CBY,EBY,fi.Y);
 TQueryField.CreateDouble(CBZ,EBZ,fi.Z);
end;

procedure TFindObjects.BNNameClick(Sender: TObject);
begin
 EBName.Text:=ResPicker.PickItem(EBName.Text);
end;

procedure TFindObjects.BNFlags1Click(Sender: TObject);
var F:Longint;
begin
 ValDword(EBFlags1.Text,f);
 f:=FlagEdit.EditObjectFlags1(f);
 EBFlags1.Text:=DwordToStr(f);
end;

procedure TFindObjects.BNFlags2Click(Sender: TObject);
var F:Longint;
begin
 ValDword(EBFlags2.Text,f);
 f:=FlagEdit.EditObjectFlags2(f);
 EBFlags2.Text:=DwordToStr(f);
end;

Function TFindObjects.Find;
var Lev:TLevel;
    nOb,o:Integer;
    Ms:TMultiSelection;
begin
 Result:=false;
 Lev:=TMapWindow(MapWindow).Level;
 ms:=TMapWindow(MapWindow).OBMultiSel;
 if ShowModal<>mrOK then exit;

if RBAdd.Checked then
begin
 o:=FindNextObject(Lev,-1,fi);
 While o<>-1 do
 begin
  Result:=true;
  if ms.FindObject(o)=-1 then ms.AddObject(o);
  o:=FindNextObject(Lev,o,fi);
 end;
end;

if RBSubtract.Checked then
begin
 o:=FindNextObject(Lev,-1,fi);
 While o<>-1 do
 begin
  Result:=true;
  nOb:=ms.FindObject(o);
  if nOb<>-1 then ms.Delete(nOb);
  o:=FindNextObject(Lev,o,fi);
 end;
end;

if RBFocus.Checked then
begin
 o:=FindNextObject(Lev,-1,fi);
 if o<>-1 then
 begin
  TMapWindow(MapWindow).Goto_Object(o);
  Result:=true;
 end;
end;

if not Result then ShowMessage('No hits!');

end;

Function TFindObjects.FindNext(curOB:Integer):Boolean;
var o:Integer;lev:TLevel;
begin
 Lev:=TMapWindow(MapWindow).Level;
 o:=FindNextObject(Lev,CurOB,fi);
  if o<>-1 then
 begin
  TMapWindow(MapWindow).Goto_Object(o);
  Result:=true;
 end;
Result:=o<>-1;
if not Result then ShowMessage('No more hits!');
end;


procedure TFindObjects.SBHelpClick(Sender: TObject);
begin
 Application.HelpJump('Hlp_Find_Objects');
end;

end.
