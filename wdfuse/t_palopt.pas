unit T_palopt;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons;

type
  TTktPalette = class(TForm)
    Label4: TLabel;
    ConvertPalette: TEdit;
    BNChosePalette: TBitBtn;
    ConvertNoPal: TCheckBox;
    ConvertKeepZero: TCheckBox;
    ConvertNot131: TCheckBox;
    ConvertNot0: TCheckBox;
    OpenPALorPLTT: TOpenDialog;
    BNOk: TBitBtn;
    procedure BNChosePaletteClick(Sender: TObject);
    procedure ConvertNoPalClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  TktPalette: TTktPalette;

implementation

{$R *.DFM}

procedure TTktPalette.BNChosePaletteClick(Sender: TObject);
begin
 with OpenPALorPLTT do
  if Execute then
    ConvertPalette.Text := LowerCase(FileName);
end;

procedure TTktPalette.ConvertNoPalClick(Sender: TObject);
begin
if ConvertNoPal.Checked then
  begin
   ConvertPalette.Enabled := FALSE;
   BNChosePalette.Enabled := FALSE;
   ConvertKeepZero.Enabled := FALSE;
   ConvertNot0.Enabled := FALSE;
   ConvertNot131.Enabled := FALSE;
  end
 else
  begin
   ConvertPalette.Enabled := TRUE;
   BNChosePalette.Enabled := TRUE;
   ConvertKeepZero.Enabled := TRUE;
   ConvertNot0.Enabled := TRUE;
   ConvertNot131.Enabled := TRUE;
  end;
end;

end.
