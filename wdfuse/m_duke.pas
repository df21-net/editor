unit M_duke;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, ExtCtrls, Spin, Dialogs,
  M_Global, D_Util, CNVEDIT, SysUtils, DF2Art;

type
  TDukeConvertWindow = class(TForm)
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    HelpBtn: TBitBtn;
    Label1: TLabel;
    Label2: TLabel;
    Label6: TLabel;
    ED_Map: TEdit;
    BNDukeMap: TBitBtn;
    SEHScale: TSpinEdit;
    SEVScale: TSpinEdit;
    SaveDukeMap: TSaveDialog;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    SEXOffset: TSpinEdit;
    SEZOffset: TSpinEdit;
    SEYOffset: TSpinEdit;
    Memo1: TMemo;
    ED_CNVFile: TEdit;
    BNCNVFile: TBitBtn;
    OFDuke3d: TOpenDialog;
    GroupBox1: TGroupBox;
    RBPalAuto: TRadioButton;
    RBUseCNV: TRadioButton;
    Bevel2: TBevel;
    Bevel1: TBevel;
    Bevel3: TBevel;
    CBAddSpecialTiles: TCheckBox;
    Memo2: TMemo;
    EBDuke3D_GRP: TEdit;
    BNSetDuke3D_GRP: TBitBtn;
    Label3: TLabel;
    CBEnemies: TCheckBox;
    procedure BNDukeMapClick(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure BNCNVFileClick(Sender: TObject);
    procedure CBAddSpecialTilesClick(Sender: TObject);
    procedure BNSetDuke3D_GRPClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DukeConvertWindow: TDukeConvertWindow;
  DefaultCNV:TPaletteConversionTable;

implementation

{$R *.DFM}
Const
 Pal2:TPalette=((r:0;g:0;b:0),
(r:4;g:4;b:4),
(r:16;g:12;b:16),
(r:24;g:24;b:24),
(r:36;g:32;b:32),
(r:44;g:40;b:44),
(r:56;g:52;b:52),
(r:64;g:60;b:60),
(r:76;g:72;b:72),
(r:88;g:80;b:80),
(r:96;g:88;b:92),
(r:108;g:96;b:100),
(r:116;g:108;b:112),
(r:128;g:116;b:120),
(r:136;g:124;b:128),
(r:148;g:136;b:140),
(r:152;g:140;b:144),
(r:160;g:148;b:152),
(r:168;g:156;b:160),
(r:172;g:164;b:168),
(r:176;g:172;b:172),
(r:184;g:176;b:180),
(r:192;g:184;b:184),
(r:200;g:188;b:192),
(r:204;g:196;b:200),
(r:212;g:204;b:208),
(r:216;g:212;b:216),
(r:224;g:216;b:220),
(r:228;g:224;b:228),
(r:236;g:232;b:236),
(r:244;g:240;b:244),
(r:252;g:252;b:252),
(r:0;g:0;b:0),
(r:4;g:4;b:0),
(r:12;g:4;b:4),
(r:24;g:12;b:4),
(r:32;g:16;b:8),
(r:40;g:20;b:12),
(r:48;g:28;b:16),
(r:60;g:32;b:20),
(r:68;g:36;b:24),
(r:76;g:44;b:24),
(r:84;g:48;b:28),
(r:96;g:52;b:32),
(r:104;g:60;b:36),
(r:112;g:64;b:40),
(r:120;g:68;b:44),
(r:132;g:76;b:48),
(r:140;g:84;b:56),
(r:144;g:92;b:60),
(r:152;g:100;b:68),
(r:160;g:108;b:72),
(r:168;g:116;b:80),
(r:172;g:124;b:88),
(r:176;g:132;b:96),
(r:184;g:144;b:104),
(r:188;g:152;b:112),
(r:196;g:160;b:120),
(r:204;g:172;b:128),
(r:212;g:176;b:140),
(r:216;g:184;b:148),
(r:220;g:196;b:156),
(r:228;g:204;b:168),
(r:236;g:216;b:176),
(r:80;g:96;b:148),
(r:84;g:104;b:152),
(r:92;g:112;b:160),
(r:96;g:120;b:168),
(r:104;g:128;b:172),
(r:112;g:136;b:180),
(r:120;g:144;b:188),
(r:124;g:152;b:196),
(r:132;g:164;b:204),
(r:140;g:172;b:208),
(r:148;g:176;b:216),
(r:156;g:184;b:220),
(r:164;g:196;b:228),
(r:172;g:204;b:236),
(r:180;g:212;b:244),
(r:188;g:220;b:252),
(r:0;g:0;b:0),
(r:4;g:4;b:4),
(r:4;g:8;b:16),
(r:12;g:12;b:24),
(r:16;g:20;b:32),
(r:20;g:24;b:44),
(r:24;g:32;b:52),
(r:32;g:40;b:64),
(r:36;g:44;b:72),
(r:40;g:52;b:80),
(r:44;g:56;b:92),
(r:52;g:64;b:100),
(r:56;g:68;b:108),
(r:60;g:76;b:120),
(r:64;g:80;b:128),
(r:72;g:88;b:140),
(r:0;g:0;b:0),
(r:4;g:4;b:4),
(r:12;g:12;b:8),
(r:24;g:20;b:12),
(r:32;g:32;b:16),
(r:40;g:40;b:24),
(r:48;g:48;b:28),
(r:60;g:56;b:36),
(r:68;g:64;b:40),
(r:76;g:76;b:44),
(r:84;g:84;b:52),
(r:96;g:92;b:56),
(r:104;g:100;b:64),
(r:112;g:108;b:68),
(r:120;g:116;b:72),
(r:132;g:128;b:80),
(r:140;g:136;b:84),
(r:148;g:148;b:84),
(r:152;g:156;b:88),
(r:156;g:164;b:92),
(r:160;g:172;b:96),
(r:164;g:176;b:96),
(r:168;g:184;b:100),
(r:172;g:192;b:104),
(r:172;g:200;b:104),
(r:172;g:208;b:108),
(r:176;g:216;b:108),
(r:176;g:220;b:112),
(r:176;g:228;b:112),
(r:176;g:236;b:116),
(r:176;g:244;b:116),
(r:176;g:252;b:120),
(r:0;g:0;b:0),
(r:12;g:0;b:0),
(r:24;g:4;b:0),
(r:40;g:4;b:0),
(r:52;g:8;b:4),
(r:68;g:12;b:4),
(r:84;g:16;b:4),
(r:96;g:20;b:4),
(r:112;g:24;b:8),
(r:128;g:28;b:8),
(r:140;g:32;b:12),
(r:156;g:36;b:12),
(r:172;g:40;b:12),
(r:184;g:44;b:16),
(r:200;g:48;b:16),
(r:216;g:52;b:20),
(r:100;g:68;b:24),
(r:104;g:80;b:4),
(r:116;g:88;b:4),
(r:128;g:100;b:4),
(r:140;g:108;b:8),
(r:148;g:120;b:8),
(r:160;g:128;b:8),
(r:172;g:140;b:8),
(r:176;g:148;b:16),
(r:188;g:160;b:16),
(r:200;g:172;b:16),
(r:212;g:180;b:20),
(r:216;g:192;b:20),
(r:228;g:200;b:20),
(r:240;g:216;b:20),
(r:252;g:224;b:24),
(r:0;g:0;b:0),
(r:4;g:4;b:0),
(r:8;g:8;b:4),
(r:16;g:12;b:8),
(r:20;g:16;b:16),
(r:28;g:20;b:20),
(r:32;g:28;b:24),
(r:40;g:32;b:28),
(r:48;g:36;b:32),
(r:52;g:44;b:40),
(r:60;g:48;b:44),
(r:64;g:52;b:48),
(r:72;g:60;b:52),
(r:76;g:64;b:56),
(r:84;g:68;b:64),
(r:92;g:76;b:68),
(r:100;g:84;b:76),
(r:108;g:92;b:80),
(r:120;g:100;b:88),
(r:128;g:108;b:96),
(r:140;g:116;b:104),
(r:148;g:124;b:112),
(r:156;g:132;b:120),
(r:168;g:140;b:124),
(r:172;g:148;b:132),
(r:180;g:156;b:140),
(r:192;g:164;b:148),
(r:200;g:172;b:156),
(r:212;g:176;b:164),
(r:216;g:184;b:172),
(r:224;g:196;b:176),
(r:236;g:204;b:184),
(r:52;g:28;b:0),
(r:68;g:40;b:0),
(r:88;g:48;b:0),
(r:108;g:56;b:0),
(r:128;g:64;b:0),
(r:144;g:72;b:0),
(r:164;g:80;b:0),
(r:180;g:84;b:4),
(r:200;g:92;b:4),
(r:204;g:104;b:24),
(r:212;g:116;b:48),
(r:216;g:132;b:68),
(r:220;g:144;b:88),
(r:228;g:160;b:112),
(r:236;g:172;b:136),
(r:244;g:192;b:160),
(r:216;g:64;b:24),
(r:216;g:76;b:28),
(r:220;g:92;b:40),
(r:224;g:104;b:48),
(r:228;g:120;b:56),
(r:232;g:132;b:64),
(r:236;g:144;b:72),
(r:240;g:160;b:80),
(r:240;g:172;b:92),
(r:240;g:184;b:100),
(r:244;g:196;b:116),
(r:244;g:208;b:124),
(r:248;g:216;b:140),
(r:248;g:224;b:148),
(r:248;g:232;b:164),
(r:252;g:240;b:172),
(r:8;g:16;b:52),
(r:8;g:8;b:64),
(r:20;g:8;b:76),
(r:28;g:8;b:88),
(r:48;g:8;b:92),
(r:64;g:16;b:100),
(r:84;g:20;b:104),
(r:104;g:24;b:112),
(r:124;g:24;b:120),
(r:136;g:32;b:116),
(r:152;g:32;b:108),
(r:164;g:24;b:96),
(r:176;g:40;b:76),
(r:188;g:44;b:56),
(r:204;g:48;b:24),
(r:216;g:52;b:20),
(r:68;g:68;b:0),
(r:164;g:164;b:0),
(r:252;g:252;b:0),
(r:68;g:0;b:68),
(r:164;g:0;b:164),
(r:252;g:0;b:252),
(r:88;g:0;b:0),
(r:172;g:0;b:0),
(r:252;g:0;b:0),
(r:0;g:68;b:0),
(r:0;g:164;b:0),
(r:0;g:252;b:0),
(r:0;g:0;b:68),
(r:0;g:0;b:164),
(r:0;g:0;b:252),
(r:252;g:0;b:252));

Var
     Pal1:TPalette;

procedure TDukeConvertWindow.BNDukeMapClick(Sender: TObject);
begin
 SaveDukeMap.FileName := ED_Map.Text;
 if SaveDukeMap.Execute then ED_Map.Text := SaveDukeMap.FileName;
end;

procedure TDukeConvertWindow.HelpBtnClick(Sender: TObject);
begin
 Application.HelpJump('wdfuse_help_dukeconvert');
end;

procedure TDukeConvertWindow.OKBtnClick(Sender: TObject);
begin
 DUKE_CEILIPIC := 1204;
 DUKE_FLOORPIC := 1205;
 DUKE_WALLPIC  := 868;
 DUKE_HSCALE   := SEHScale.Value;
 DUKE_VSCALE   := SEVScale.Value;
 DUKE_XOFFSET  := SEXOffset.Value * SEHScale.Value;
 DUKE_ZOFFSET  := SEZOffset.Value * SEHScale.Value;
 DUKE_YOFFSET  := SEYOffset.Value * SEVScale.Value;
 DUKE_1STTile  := 3328;

 SaveAsDukeMap(ED_MAP.Text);
end;


procedure TDukeConvertWindow.BNCNVFileClick(Sender: TObject);
begin
  ED_CNVFile.Text:=Edit_CNV(Pal1,Pal2,ED_CNVFile.Text);
end;

procedure TDukeConvertWindow.CBAddSpecialTilesClick(Sender: TObject);
begin
 If CBAddSpecialTiles.checked then
  if EBDuke3D_GRP.text='' then BNSetDuke3D_GRP.Click;
end;

procedure TDukeConvertWindow.BNSetDuke3D_GRPClick(Sender: TObject);
begin
 if OFDuke3D.Execute then EBDuke3d_GRP.Text := OFDuke3D.FileName
 else if EBDuke3d_GRP.Text='' then CBAddSpecialTiles.checked:=false;
end;

procedure TDukeConvertWindow.FormShow(Sender: TObject);
var f:Integer;i:integer;
begin
 ED_MAP.Text:=ChangeFileExt(ExtractFilePath(ED_MAP.Text)+ExtractFileName(ProjectFile),'.map');
 ED_CNVFile.Text:=WDFUSEDIR+'\WDFDATA\'+LevelName+'.cnv';
 CBAddSpecialTiles.Checked:=false;
 f:=FileOpen(LevelPath+'\'+LevelName+'.PAL',fmOpenRead);
 if f<0 then exit;
 FileRead(f,Pal1,sizeof(Pal1));
 FileClose(f);
 For i:=0 to 255 do
 With Pal1[i] do
 begin
  r:=r*4;
  g:=g*4;
  b:=b*4;
 end;
 MatchColors(Pal1,Pal2,DefaultCNV);
end;

end.
