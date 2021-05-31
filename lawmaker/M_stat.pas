unit M_stat;

interface

uses Windows, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, ExtCtrls, FileCtrl, SysUtils, ComCtrls, Level;
type
  TStatWindow = class(TForm)
    OKBtn: TBitBtn;
    Pages: TPageControl;
    Map: TTabSheet;
    SysInfo: TTabSheet;
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
    PanelPAL: TPanel;
    PanelCMP: TPanel;
    PanelPOD: TPanel;
    PanelSND: TPanel;
    GroupBox3: TGroupBox;
    Label24: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    Label28: TLabel;
    Label31: TLabel;
    Label30: TLabel;
    Label29: TLabel;
    Label27: TLabel;
    PanelMinX: TPanel;
    PanelMinZ: TPanel;
    PanelMinY: TPanel;
    PanelMinL: TPanel;
    PanelMaxL: TPanel;
    PanelMaxY: TPanel;
    PanelMaxZ: TPanel;
    PanelMaxX: TPanel;
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
    Label11: TLabel;
    procedure DriveComboChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Procedure ShowInfo(L:TLevel);
  end;

var
  StatWindow: TStatWindow;

implementation

{$R *.DFM}

Procedure TStatWindow.ShowInfo(L:TLevel);
var OSI:TOSVERSIONINFO;
    MS:TMEMORYSTATUS;
    s:String;
    sumwl,
    sumvx,
    sc,wl        : Integer;
    txs,pls,cmps:TStringList;

Procedure sl_Add(sl:TStringList;const s:String);
begin
 if (s<>'') and (sl.IndexOf(s)=-1) then sl.Add(s);
end;

begin
  OSI.dwOSVersionInfoSize:=Sizeof(OSI);
  GetVersionEx(OSI);
  case OSI.dwPlatformId of
   VER_PLATFORM_WIN32s:        s:='Win32s';
   VER_PLATFORM_WIN32_WINDOWS: s:='Windows 95';
   VER_PLATFORM_WIN32_NT:      s:='Windows NT';
  else s:='Unknown Windows';
  end;
  
  With OSI do
  PanelVER.Caption    := Format('%s %d.%d Build %d %s',
  [s,dwMajorVersion,dwMinorVersion,dwBuildNumber,szCSDVersion]);

  MS.dwLength:=Sizeof(MS);
  GlobalMemoryStatus(ms);

  PanelMEM.Caption    := IntToStr(Ms.dwAvailPhys div 1024);
  PanelMEMMAX.Caption := IntToStr(Ms.dwAvailPageFile div 1024);

  PanelDSK.Caption    := IntToStr((DiskFree(3) div 1024) div 1024);
  PanelDSKMAX.Caption := IntToStr((DiskSize(3) div 1024) div 1024);
  DriveCombo.Drive    := 'c';

  if L<>nil then
   begin
    PanelSC.Caption   := IntToStr(L.Sectors.Count);
    sumvx             := 0;
    sumwl             := 0;

    txs:=TStringList.Create;
    pls:=TStringList.Create;
    cmps:=TStringList.Create;

    for sc := 0 to L.Sectors.Count - 1 do
    With L.Sectors[sc] do
     begin
      Sl_Add(Pls,Palette);
      Sl_Add(Cmps,ColorMap);
      Sl_Add(txs,Floor_Texture.Name);
      Sl_Add(txs,Ceiling_Texture.Name);
      Sl_Add(txs,F_Overlay_Texture.Name);
      SL_Add(txs,C_Overlay_Texture.Name);

      Inc(sumvx, Vertices.Count);
      Inc(sumwl, Walls.Count);
      for wl:=0 to Walls.Count-1 do
      With Walls[wl] do
      begin
       Sl_Add(txs,MID.Name);
       Sl_Add(txs,TOP.Name);
       Sl_Add(txs,BOT.Name);
       Sl_Add(txs,Overlay.Name);
      end;
     end;

    PanelVX.Caption   := IntToStr(sumvx);
    PanelWL.Caption   := IntToStr(sumwl);

    PanelTX.Caption   := IntToStr(txs.Count);
    PanelPal.Caption  := IntToStr(pls.Count);
    PanelCMP.Caption  := IntToStr(cmps.Count);
    txs.Free; pls.Free; cmps.Free;

    L.FindLimits;
    PanelMinX.Caption  := Format('%5.2f', [L.minX]);
    PanelMinY.Caption  := Format('%5.2f', [L.minY]);
    PanelMinZ.Caption  := Format('%5.2f', [L.minZ]);
    PanelMinL.Caption  := IntToStr(L.MINLayer);
    PanelMaxX.Caption  := Format('%5.2f', [L.maxX]);
    PanelMaxY.Caption  := Format('%5.2f', [L.maxY]);
    PanelMaxZ.Caption  := Format('%5.2f', [L.maxZ]);
    PanelMaxL.Caption  := IntToStr(L.MAXLayer);

    PanelOB.Caption   := IntToStr(L.Objects.Count);
   end 
  else
   begin
    PanelSC.Caption   := 'N/A';
    PanelVX.Caption   := 'N/A';
    PanelWL.Caption   := 'N/A';
    PanelTX.Caption   := 'N/A';

    PanelOB.Caption   := 'N/A';
    PanelPAL.Caption  := 'N/A';
    PanelCMP.Caption  := 'N/A';
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
  ShowModal;
end;

procedure TStatWindow.DriveComboChange(Sender: TObject);
var TheDrive : Integer;
begin
 TheDrive            := Ord(DriveCombo.Drive) - 96;
 PanelDSK.Caption    := IntToStr((DiskFree(TheDrive) div 1024) div 1024);
 PanelDSKMAX.Caption := IntToStr((DiskSize(TheDrive) div 1024) div 1024);
end;

end.
