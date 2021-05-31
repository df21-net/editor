unit U_Options;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, FileCtrl, ComCtrls, Tabnotbk, misc_utils, ExtCtrls, Grids,
  Buttons;

type
  TOptions = class(TForm)
    Pages: TPageControl;
    Outlaws: TTabSheet;
    Misc: TTabSheet;
    Label2: TLabel;
    CBCD: TDriveComboBox;
    DirList: TDirectoryListBox;
    Label1: TLabel;
    FixErrors: TRadioGroup;
    OLDrive: TDriveComboBox;
    LEVTextures: TRadioGroup;
    Confirmations: TTabSheet;
    SGConfirms: TStringGrid;
    Panel1: TPanel;
    BNOK: TButton;
    BNCancel: TButton;
    FontDialog: TFontDialog;
    GroupBox1: TGroupBox;
    CBScrEditOnTop: TCheckBox;
    BNScrEditFont: TButton;
    Label3: TLabel;
    GroupBox2: TGroupBox;
    CBLogTest: TCheckBox;
    SBHelp: TSpeedButton;
    procedure BNOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SGConfirmsDblClick(Sender: TObject);
    procedure BNScrEditFontClick(Sender: TObject);
    procedure SBHelpClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
 Procedure LoadConfirmations; 
  public
 Function ReadSettings:Boolean;
 Procedure SetOptions(curPage:TTabSheet);
    { Public declarations }
  end;

Procedure WriteSettings;

var
  Options: TOptions;
  SaveSettings:boolean=true;

implementation
uses GlobalVars, Registry, Mapper, LECScripts;
{$R *.DFM}

const YesNo:array[Boolean] of String=('No','Yes');

Procedure TOptions.LoadConfirmations;
var i:integer;
begin
 With SGConfirms do
 begin
  Cells[0,0]:='Action:'; Cells[1,0]:='Confitm it?';
  For i:=1 to Sizeof(Confirms) div sizeof(TConfirmRec) do
  begin
   Cells[0,i]:=Confirms[i].Text;
   Cells[1,i]:=YesNo[Confirms[i].Value];
  end;
 end;
end;

Procedure TOptions.SetOptions(curPage:TTabSheet);
begin
 if CurPage<>nil then Pages.ActivePage:=CurPage;
 CBLogTest.Checked:=LogTestSession;
 ShowModal;
end;

procedure TOptions.BNOKClick(Sender: TObject);
begin
 GameDir:=DirList.Directory;
 if gameDir[length(GameDir)]<>'\' then GameDir:=Gamedir+'\';
 if Not FileExists(GameDir+'Olwin.exe') then
 begin
  msgBox('Cannot locate Outlaws executable '+gamedir+'Olwin.exe',
         'Error',mb_ok);
  exit;
 end;
 CDDir:=CBCD.Drive+':\Outlaws\';
 cc_FixErrors:=FixErrors.ItemIndex;
 Lev_textures:=LevTextures.ItemIndex;
 ScriptOnTop:=CBScrEditOnTop.Checked;
 LogTestSession:=CBLogTest.Checked;
 WriteSettings;
 ModalResult:=mrOK;
 Hide;
end;

Procedure WriteSettings;
var reg:TRegistry;s:String;i:Integer;

procedure WriteWinPos(const PosName:String;var wpos:TWinPos);
begin
 Reg.WriteInteger(PosName+'.left',wpos.WLeft);
 Reg.WriteInteger(PosName+'.top',wpos.Wtop);
 Reg.WriteInteger(PosName+'.width',wpos.Wwidth);
 Reg.WriteInteger(PosName+'.height',wpos.Wheight);
end;

Procedure WriteFont(const Name:String;const f:TFontAttrib);
begin
 Reg.WriteString(Name+'.Name',F.Name);
 Reg.WriteInteger(Name+'.Size',F.Size);
 Reg.WriteInteger(Name+'.Style',f.Style);
{ Reg.WriteInteger(Name+'.Color',F.Color);}
end;


begin
 Reg:=TRegistry.Create;
 Reg.OpenKey(regbase,true);
 Reg.WriteString('GameDir',gameDir);
 Reg.WriteString('CD Dir',CDDir);
 WriteWinPos('MapperPos',MapperPos);
 WriteWinPos('SectorEditPos',SectorEditPos);
 WriteWinPos('WallEditPos',WallEditPos);
 WriteWinPos('VertexEditPos',VertexEditPos);
 WriteWinPos('ObjectEditPos',ObjectEditPos);
 WriteWinPos('ToolsPos',ToolsPos);
 Reg.WriteBool('SectorEdit.Ontop',SCEditOnTop);
 Reg.WriteBool('WallEdit.Ontop',WLEditOnTop);
 Reg.WriteBool('VertexEdit.Ontop',VXEditOnTop);
 Reg.WriteBool('ObjectEdit.Ontop',OBEditOnTop);
 Reg.WriteBool('Tools.Ontop',ToolsOnTop);
 Reg.WriteBool('Script.OnTop',ScriptOnTop);
 Reg.WriteBool('LogTestSession',LogTestSession);
 Reg.WriteInteger('cc_FixErrors',cc_FixErrors);
 Reg.WriteInteger('lev_textures',lev_textures);

  For i:=1 to sizeof(Confirms) div sizeof(TConfirmRec) do
 With Confirms[i] do Reg.WriteBool(Rkey,Value);

 For i:=0 to Recents.Count-1 do
  Reg.WriteString('Recent'+IntToStr(i),Recents[i]);
 WriteFont('ScriptFont',scFont);
 Reg.Free;
end;

Function TOptions.ReadSettings:Boolean;
var reg:TRegistry;s:String;i:Integer;

Procedure ReadStr(const Name:String;var s:String);
begin
Try
 s:=Reg.ReadString(Name);
Except
 on ERegistryException do;
end;
end;

Procedure ReadBool(const Name:String;var b:Boolean);
begin
Try
 b:=Reg.ReadBool(Name);
Except
 on ERegistryException do;
end;
end;

Procedure ReadInt(const Name:String;var i:Integer);
begin
Try
 i:=Reg.ReadInteger(Name);
Except
 on ERegistryException do;
end;
end;

Procedure ReadFont(const Name:String;var f:TFontAttrib);
begin
Try
 F.Name:=Reg.ReadString(Name+'.Name');
 f.Size:=Reg.ReadInteger(Name+'.Size');
 f.Style:=Reg.ReadInteger(Name+'.style');
Except
 On ERegistryException do;
end;
end;

procedure ReadWinPos(const PosName:String;var pos:TWinPos);
begin
 ReadInt(PosName+'.left',Pos.WLeft);
 ReadInt(PosName+'.top',Pos.WTop);
 ReadInt(PosName+'.width',Pos.WWidth);
 ReadInt(PosName+'.height',Pos.WHeight);
end;

Function GetGameLab(const Name:String):String;
begin
 if FileExists(GameDir+Name) then Result:=GameDir+Name
 else Result:=CDDir+Name;
end;

begin
 Result:=true;
 Reg:=TRegistry.Create;

 if not Reg.OpenKey(regbase,false) then
  begin
  Reg.Free;
  Result:=false;
  exit;
 end;

 GameDir:=Reg.ReadString('GameDir');
 DirList.Directory:=GameDir;
 CDDir:=Reg.ReadString('CD Dir');
 s:=ExtractFileDrive(CDDir);
 if s<>'' then CBCD.Drive:=s[1];
 Outlaws_lab:=GetGameLab('outlaws.lab');
 textures_lab:=GetGameLab('oltex.lab');
 Weapons_lab:=GetGameLab('olweap.lab');
 Objects_lab:=GetGameLab('olobj.lab');
 sounds_lab:=GetGameLab('olsfx.lab');
 geo_lab:=GetGameLab('olgeo.lab');
 taunts_lab:=GetGameLab('oltaunt.lab');
 olpatch1_lab:=GetGameLab('olpatch1.lab');
 olpatch2_lab:=GetGameLab('olpatch2.lab');

 ReadInt('cc_FixErrors',cc_FixErrors);
 ReadInt('lev_textures',lev_textures);
 FixErrors.ItemIndex:=cc_FixErrors;
 LEVTextures.ItemIndex:=lev_textures;

 ReadWinPos('MapperPos',MapperPos);
 ReadWinPos('SectorEditPos',SectorEditPos);
 ReadWinPos('WallEditPos',WallEditPos);
 ReadWinPos('VertexEditPos',VertexEditPos);
 ReadWinPos('ObjectEditPos',ObjectEditPos);
 ReadWinPos('ToolsPos',ToolsPos);
 ReadBool('SectorEdit.OnTop',SCEditOnTop);
 ReadBool('WallEdit.OnTop',WLEditOnTop);
 ReadBool('VertexEdit.OnTop',VXEditOnTop);
 ReadBool('ObjectEdit.OnTop',OBEditOnTop);
 ReadBool('Tools.OnTop',ToolsOnTop);
 ReadBool('Script.OnTop',ScriptOnTop);
 CBScrEditOnTop.Checked:=ScriptOnTop;
 ReadBool('LogTestSession',LogTestSession);
 For i:=1 to sizeof(Confirms) div sizeof(TConfirmRec) do
 With Confirms[i] do ReadBool(Rkey,Value);

 For i:=0 to 3 do
 begin
  s:='';
  ReadStr('Recent'+IntToStr(i),s);
  if s<>'' then MapWindow.AddRecent(s);
 end;
 ReadFont('ScriptFont',ScFont);
 Reg.Free;
end;

procedure TOptions.FormCreate(Sender: TObject);
begin
 if not ReadSettings then
 begin
  Pages.ActivePage:=Outlaws;
  if ShowModal<>mrOK then begin Application.Terminate; SaveSettings:=false; end;
 end;
 LoadConfirmations;
end;

procedure TOptions.SGConfirmsDblClick(Sender: TObject);
var i:Integer;
begin
 i:=SGConfirms.Row;
 Confirms[i].Value:=not Confirms[i].Value;
 SGConfirms.Cells[1,i]:=YesNo[Confirms[i].Value];
end;

procedure TOptions.BNScrEditFontClick(Sender: TObject);
begin
 SetFont(FontDialog.Font,scFont);
 if FontDialog.Execute then
 begin
  GetFont(scFont,FontDialog.Font);
  SetFont(ScriptEdit.Memo.Font,scFont);
  BNScrEditFont.Caption:=FontDialog.Font.Name;
 end;
end;

procedure TOptions.SBHelpClick(Sender: TObject);
begin
 Application.HelpJump('Hlp_Options');
end;

procedure TOptions.FormShow(Sender: TObject);
begin
 SetFont(FontDialog.Font,scFont);
 BNScrEditFont.Caption:=scFont.Name;
end;

Initialization
Finalization
if SaveSettings then WriteSettings;

end.
