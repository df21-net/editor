unit _conv3do;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, Buttons,Asc3do,_3dotasc;

type
  TCONV3do = class(TForm)
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    RG3DOOptions: TRadioGroup;
    BNHelp: TBitBtn;
    procedure OKBtnClick(Sender: TObject);
    procedure BNHelpClick(Sender: TObject);
  
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  CONV3do: TCONV3do;

implementation
 uses Mapper;

{$R *.DFM}



procedure TCONV3do.BNHelpClick(Sender: TObject);
begin
    MapWindow.HelpTutorialClick(NIL);
end;

procedure TCONV3do.OKBtnClick(Sender: TObject);
begin
 CASE RG3DOOptions.ItemIndex of
  0 : begin
      Application.CreateForm(TCNV3do2asc , CNV3do2asc);
      CNV3do2asc.ShowModal;
      CNV3do2asc.Destroy;
     end;
  1 : begin
      Application.CreateForm(TASCto3DO , ASCto3DO);
      ASCto3DO.ShowModal;
      ASCto3DO.Destroy;
      end;
    end;
    end;
end.
