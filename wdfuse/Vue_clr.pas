unit vue_clr;

interface

uses
 WinTypes, WinProcs, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Spin, Buttons;

type
  TVUEClearWindow = class(TForm)
    RBAll: TRadioButton;
    RBFrames: TRadioButton;
    BBOk: TBitBtn;
    BitBtn1: TBitBtn;
    SEFrom: TSpinEdit;
    SETo: TSpinEdit;
    Label1: TLabel;
    Label2: TLabel;
    procedure RBAllClick(Sender: TObject);
    procedure RBFramesClick(Sender: TObject);
    procedure SEFromChange(Sender: TObject);
    procedure SEToChange(Sender: TObject);
    procedure BBOkClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  VUEClearWindow: TVUEClearWindow;

implementation

uses vuecreat, VUE_util;

{$R *.DFM}

procedure TVUEClearWindow.RBAllClick(Sender: TObject);
begin
 SEFrom.Enabled := False;
 SETo.Enabled := False;
end;

procedure TVUEClearWindow.RBFramesClick(Sender: TObject);
begin
 SEFrom.Enabled := True;
 SETo.Enabled := True;
end;

procedure TVUEClearWindow.SEFromChange(Sender: TObject);
begin
 SETo.MinValue := SEFrom.Value + 1;
end;

procedure TVUEClearWindow.SEToChange(Sender: TObject);
begin
 SEFrom.MaxValue := SETo.Value - 1;
end;

procedure TVUEClearWindow.BBOkClick(Sender: TObject);
var F, L: integer;
begin
 if RBAll.Checked then
  begin
   F := 1;
   L := 10000;
   ClearCells(F, L);
  end;

 if RBFrames.Checked then
  begin
   F := SEFrom.Value + 1;
   L := SETo.Value + 1;
   ClearCells(F, L);
  end;
end;

end.
