unit _3dotasc;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs,_3doCNV, Gauges, ExtCtrls, StdCtrls, Buttons,IniFiles,M_global;

type
  TCNV3do2asc = class(TForm)
    EditInput3DO: TEdit;
    EditOutputASC: TEdit;
    OpenDialogInput3DO: TOpenDialog;
    SBInput3DO: TSpeedButton;
    SBOutputASC: TSpeedButton;
    Label1: TLabel;
    Label2: TLabel;
    Bevel1: TBevel;
    SBExit: TSpeedButton;
    SBConvert: TSpeedButton;
    Gauge1: TGauge;
    SaveDialogOutputASC: TSaveDialog;
    Bevel2: TBevel;
    ScrollBarRed: TScrollBar;
    ScrollBarGreen: TScrollBar;
    ScrollBarBlue: TScrollBar;
    Label3: TLabel;
    LabelRed: TLabel;
    LabelGreen: TLabel;
    LabelBlue: TLabel;
    PanelRGB: TPanel;
    LabelRednum: TLabel;
    LabelGreenNum: TLabel;
    LabelBlueNum: TLabel;
    procedure SBExitClick(Sender: TObject);
    procedure SBInput3DOClick(Sender: TObject);
    procedure SBOutputASCClick(Sender: TObject);
    procedure SBConvertClick(Sender: TObject);
    procedure ScrollBarRedChange(Sender: TObject);
    procedure ScrollBarGreenChange(Sender: TObject);
    procedure ScrollBarBlueChange(Sender: TObject);
  
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  CNV3do2asc: TCNV3do2asc;
   ScrollRed,
   ScrollGreen,
   ScrollBlue : integer;

implementation

{$R *.DFM}



procedure TCNV3do2asc.SBExitClick(Sender: TObject);
begin
 close;
end;

procedure TCNV3do2asc.SBInput3DOClick(Sender: TObject);
 var
   Fname : string;

begin
  OpenDialogInput3DO.Execute ;
  Fname:= OpenDialogInput3DO.FileName ;
  EditInput3DO.Text := Fname  ;
  EditOutputASC.Text := (WDFUSEdir+ '\'+ 'WDFGRAPH' +'\' +ChangeFileExt(ExtractFileName(Fname),'.ASC'));
  ScrollBarRed.Enabled := True;
  ScrollBarGreen.Enabled := True;
  ScrollBarBlue.Enabled := True;
  ScrollRed :=ScrollBarRed.Position ;
  ScrollGreen :=ScrollBarGreen.Position;
  ScrollBlue := ScrollBarBlue.Position ;
  PanelRGB.Color:= RGB(ScrollRed,ScrollGreen,ScrollBlue );
  LabelRednum.Caption := IntToStr(ScrollRed) ;
  LabelGreenNum.Caption :=IntToStr(ScrollGreen);
  LabelBlueNum.Caption :=IntToStr(ScrollBlue);

end;

   {DirectoryExists(WDFUSEdir+ '\' + EDProjectName.Text) then }
procedure TCNV3do2asc.SBOutputASCClick(Sender: TObject);
 begin
  SaveDialogOutputASC.Execute;
  EditOutputASC.Text :=  SaveDialogOutputASC.FileName;

 end;


procedure TCNV3do2asc.SBConvertClick(Sender: TObject);
begin
if EditInput3DO.Text ='' then
      begin
     MessageDlg('3DO File To Be Converted Not Specified.', mtInformation,[mbOk], 0);
     Exit ;
    end;
  if EditOutputASC.Text ='' then
      begin
     MessageDlg('ASC File To Be Created Not Specified.', mtInformation,[mbOk], 0);
     Exit ;
    end;
 
  Convert3DO2ASC(EditInput3DO.Text,EditOutputASC.Text);

end;

procedure TCNV3do2asc.ScrollBarRedChange(Sender: TObject);

  begin
     ScrollRed :=ScrollBarRed.Position ;
     PanelRGB.Color:= RGB(ScrollRed,ScrollGreen,ScrollBlue );
     LabelRednum.Caption := IntToStr(ScrollRed) ;
end;

procedure TCNV3do2asc.ScrollBarGreenChange(Sender: TObject);
begin
     ScrollGreen :=ScrollBarGreen.Position;
     PanelRGB.Color:= RGB(ScrollRed,ScrollGreen,ScrollBlue );
     LabelGreenNum.Caption :=IntToStr(ScrollGreen);
end;

procedure TCNV3do2asc.ScrollBarBlueChange(Sender: TObject);

begin
   ScrollBlue := ScrollBarBlue.Position ;
   PanelRGB.Color:= RGB(ScrollRed,ScrollGreen,ScrollBlue );
   LabelBlueNum.Caption :=IntToStr(ScrollBlue);
end;

end.
