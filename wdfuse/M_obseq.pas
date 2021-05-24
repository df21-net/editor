unit M_obseq;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, Spin, IniFiles, M_Global;

type
  TOBSeqPicker = class(TForm)
    OKBtn: TBitBtn;
    SeqSpin: TSpinEdit;
    procedure FormActivate(Sender: TObject);
    procedure SeqSpinChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  OBSeqPicker: TOBSeqPicker;

implementation
uses M_Editor;

{$R *.DFM}

procedure TOBSeqPicker.FormActivate(Sender: TObject);
begin
 SeqSpin.MaxValue := OBSEQNUMBER;
 SeqSpin.Value    := 1;
 DO_FillOneLogic(1);
end;

procedure TOBSeqPicker.SeqSpinChange(Sender: TObject);
begin
 DO_FillOneLogic(SeqSpin.Value);
end;

end.
