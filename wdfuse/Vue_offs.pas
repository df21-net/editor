unit vue_offs;

interface

uses
  WinTypes, WinProcs, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons, Grids;

type
  TVUEOffsetWindow = class(TForm)
    RadioGroup1: TRadioGroup;
    RBScale: TRadioButton;
    RBPitch: TRadioButton;
    RBYaw: TRadioButton;
    RBRoll: TRadioButton;
    RBXpos: TRadioButton;
    RBYpos: TRadioButton;
    RBZpos: TRadioButton;
    EDFactor: TEdit;
    Label1: TLabel;
    BBOk: TBitBtn;
    BitBtn1: TBitBtn;
    procedure BBOkClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  VUEOffsetWindow: TVUEOffsetWindow;

implementation

uses vuecreat;

{$R *.DFM}

procedure TVUEOffsetWindow.BBOkClick(Sender: TObject);
var a, i, LastFrame, col, code1, code2 : integer;
    Factor, TempNum : real;
    Data : TStringGrid;
    Error : boolean;
    Stri : string;
begin
 {Check Value ..............}
 val(EDFactor.Text, Factor, code1);
 Error := False;
 if code1 <> 0 then
  begin
   ShowMessage('Invalid number');
   EDFactor.SetFocus;
   Error := True;
  end;

 if not Error then
  if RBScale.Checked and (Factor <= 0) then
   begin
    ShowMessage('Must be > 0 for Scale');
    EDFactor.SetFocus;
    Error := True;
   end;

 if not Error then
  BEGIN
   Data := VUECreator.DataGrid;

   {Determine last frame ...........}
   i := 0;
   repeat
    i := i + 1;
   until (Data.Cells[1, i] = '') or (i = 10001);
   LastFrame := i - 1;

   {Offset ......................}
   if LastFrame > 0 then
    BEGIN
     if RBScale.Checked then
      for a := 1 to LastFrame do
       begin
        val(Data.Cells[2, a], TempNum, code2);
        if code2 <> 0 then
         with VUECreator do
          BEGIN
           PNLErrors.Caption := 'Error: Invalid number';
           DataGrid.Col := 2;
           DataGrid.Row := a;
           Break;
          END;
        if TempNum <= 0 then
         with VUECreator do
          BEGIN
           PNLErrors.Caption := 'Error: Scale must be greater than 0';
           DataGrid.Col := 2;
           DataGrid.Row := a;
           Break;
          END;
        TempNum := TempNum * Factor;
        if TempNum <= 0.01 then TempNum := 0.01;
        str(TempNum : 0 : 2, Stri);
        Data.Cells[2, a] := Stri;
       end;

     if RBPitch.Checked or RBYaw.Checked or RBRoll.Checked then
      BEGIN
       if RBPitch.Checked then col := 3;
       if RBYaw.Checked then col := 4;
       if RBRoll.Checked then col := 5;
       for a := 1 to LastFrame do
        begin
         val(Data.Cells[col, a], TempNum, code2);
         if (TempNum < 0) or (TempNum >= 360) then
          with VUECreator do
           BEGIN
            PNLErrors.Caption := 'Error: Angle must be >= 0 and < 360';
            DataGrid.Col := col;
            DataGrid.Row := a;
            Break;
           END;
         if code2 <> 0 then
          with VUECreator do
           BEGIN
            PNLErrors.Caption := 'Error: Invalid number';
            DataGrid.Col := col;
            DataGrid.Row := a;
            Break;
           END;
         TempNum := TempNum + Factor;
         if TempNum < 0 then TempNum := TempNum + 360;
         if TempNum >= 360 then TempNum := TempNum - 360;
         str(TempNum : 0 : 2, Stri);
         Data.Cells[col, a] := Stri;
        end;
      END;

     if RBXpos.Checked or RBYpos.Checked or RBZpos.Checked then
      BEGIN
       if RBXpos.Checked then col := 6;
       if RBYpos.Checked then col := 7;
       if RBZpos.Checked then col := 8;
       for a := 1 to LastFrame do
        begin
         val(Data.Cells[col, a], TempNum, code2);
         if code2 <> 0 then
          with VUECreator do
           BEGIN
            PNLErrors.Caption := 'Error: Invalid number';
            DataGrid.Col := col;
            DataGrid.Row := a;
            Break;
           END;
         TempNum := TempNum + Factor;
         str(TempNum : 0 : 2, Stri);
         Data.Cells[col, a] := Stri;
        end;
      END;

     VUECreator.DataGrid := Data;
     VUEOffsetWindow.Close;
    END;
  END;
end;

end.
