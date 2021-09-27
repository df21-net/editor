unit M_stat;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, ExtCtrls, FileCtrl, SysUtils,
  M_Global, M_MapUt,
  {$IFDEF WDF32}
ZRender,ComCtrls,
{$ENDIF}
  Stitch,  Tabnotbk;
type
  TStatWindow = class(TForm)
    OKBtn: TBitBtn;
    TabbedNotebook1: TTabbedNotebook;
    GroupBox4: TGroupBox;
    Label1: TLabel;
    Label3: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    PanelSC: TPanel;
    PanelVX: TPanel;
    PanelWL: TPanel;
    PanelOB: TPanel;
    PanelTX: TPanel;
    PanelSPR: TPanel;
    PanelFME: TPanel;
    PanelPOD: TPanel;
    PanelSND: TPanel;
    GroupBox3: TGroupBox;
    Label24: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    Label29: TLabel;
    Label30: TLabel;
    Label31: TLabel;
    PanelMinX: TPanel;
    PanelMaxX: TPanel;
    PanelMinZ: TPanel;
    PanelMaxZ: TPanel;
    PanelMinY: TPanel;
    PanelMaxY: TPanel;
    PanelMinL: TPanel;
    PanelMaxL: TPanel;
    GroupBox2: TGroupBox;
    Label10: TLabel;
    Label12: TLabel;
    Label14: TLabel;
    Label13: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    DriveCombo: TDriveComboBox;
    PanelVER: TPanel;
    PanelMEM: TPanel;
    PanelDSK: TPanel;
    PanelMEMMAX: TPanel;
    PanelDSKMAX: TPanel;
    procedure FormActivate(Sender: TObject);
    procedure DriveComboChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  StatWindow: TStatWindow;

implementation

{$R *.DFM}

procedure TStatWindow.FormActivate(Sender: TObject);
var long      : LongInt;
    w2        : Word;
    b1, b2    : Byte;
    TheSector : TSector;
    sumwl,
    sumvx,
    sc        : Integer;
    minX,
    minY,
    minZ,
    maxX,
    maxY,
    maxZ      : Real;
    memory: TMemoryStatusEx;
begin

  memory.dwLength := SizeOf(memory);
  GlobalMemoryStatusEx(memory);

  long                := GetVersion;
  w2                  := LoWord(long);
  b1                  := LoByte(w2);
  b2                  := HiByte(w2);
  PanelVER.Caption    := IntToStr(b1) + '.' + IntToStr(b2);
  PanelMEM.Caption    := IntToStr(memory.ullAvailPhys div (1024*1024));
  PanelMEMMAX.Caption := IntToStr(memory.ullTotalPhys div (1024*1024));

  PanelDSK.Caption    := IntToStr((DiskFree(3) div 1024) div 1024);
  PanelDSKMAX.Caption := IntToStr((DiskSize(3) div 1024) div 1024);
  DriveCombo.Drive    := 'c'; 

  if LEVELLoaded then
   begin
    PanelSC.Caption   := IntToStr(MAP_SEC.Count);
    sumvx             := 0;
    sumwl             := 0;
    for sc := 0 to MAP_SEC.Count - 1 do
     begin
      TheSector := TSector(MAP_SEC.Objects[sc]);
      Inc(sumvx, TheSector.Vx.Count);
      Inc(sumwl, TheSector.Wl.Count);
     end;
    PanelVX.Caption   := IntToStr(sumvx);
    PanelWL.Caption   := IntToStr(sumwl);
    PanelTX.Caption   := IntToStr(TX_LIST.Count);

    DO_GetMapLimits(minX, minY, minZ, maxX, maxY, maxZ);

    PanelMinX.Caption  := Format('%5.2f', [minX]);
    PanelMinY.Caption  := Format('%5.2f', [minY]);
    PanelMinZ.Caption  := Format('%5.2f', [minZ]);
    PanelMinL.Caption  := IntToStr(LAYER_MIN);
    PanelMaxX.Caption  := Format('%5.2f', [maxX]);
    PanelMaxY.Caption  := Format('%5.2f', [maxY]);
    PanelMaxZ.Caption  := Format('%5.2f', [maxZ]);
    PanelMaxL.Caption  := IntToStr(LAYER_MAX);

    if OFILELoaded then
     begin
      PanelOB.Caption   := IntToStr(MAP_OBJ.Count);
      PanelSPR.Caption  := IntToStr(SPR_LIST.Count);
      PanelFME.Caption  := IntToStr(FME_LIST.Count);
      PanelPOD.Caption  := IntToStr(POD_LIST.Count);
      PanelSND.Caption  := IntToStr(SND_LIST.Count);
     end
    else
     begin
      PanelOB.Caption   := 'N/A';
      PanelSPR.Caption  := 'N/A';
      PanelFME.Caption  := 'N/A';
      PanelPOD.Caption  := 'N/A';
      PanelSND.Caption  := 'N/A';
     end;
   end
  else
   begin
    PanelSC.Caption   := 'N/A';
    PanelVX.Caption   := 'N/A';
    PanelWL.Caption   := 'N/A';
    PanelTX.Caption   := 'N/A';

    PanelOB.Caption   := 'N/A';
    PanelSPR.Caption  := 'N/A';
    PanelFME.Caption  := 'N/A';
    PanelPOD.Caption  := 'N/A';
    PanelSND.Caption  := 'N/A';

    PanelMinX.Caption  := 'N/A';
    PanelMinY.Caption  := 'N/A';
    PanelMinZ.Caption  := 'N/A';
    PanelMinL.Caption  := 'N/A';
    PanelMaxX.Caption  := 'N/A';
    PanelMaxY.Caption  := 'N/A';
    PanelMaxZ.Caption  := 'N/A';
    PanelMaxL.Caption  := 'N/A';
   end;
end;

procedure TStatWindow.DriveComboChange(Sender: TObject);
var TheDrive : Integer;
begin
 TheDrive            := Ord(DriveCombo.Drive) - 96;
 PanelDSK.Caption    := IntToStr((DiskFree(TheDrive) div 1024) div 1024);
 PanelDSKMAX.Caption := IntToStr((DiskSize(TheDrive) div 1024) div 1024);
end;

end.
