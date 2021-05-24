unit vue_fldn;

interface

uses
  WinTypes, WinProcs, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Spin, Buttons, Grids;

type
  TVUEFillDownWindow = class(TForm)
    RadioGroup1: TRadioGroup;
    RBid: TRadioButton;
    RBScale: TRadioButton;
    RBPitch: TRadioButton;
    RBYaw: TRadioButton;
    RBRoll: TRadioButton;
    RBX: TRadioButton;
    RBY: TRadioButton;
    RBZ: TRadioButton;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    SEFrom: TSpinEdit;
    SETo: TSpinEdit;
    BBOk: TBitBtn;
    BBCancel: TBitBtn;
    EDIncrement: TEdit;
    EDAccel: TEdit;
    procedure RBidClick(Sender: TObject);
    procedure RBScaleClick(Sender: TObject);
    procedure RBPitchClick(Sender: TObject);
    procedure RBYawClick(Sender: TObject);
    procedure RBRollClick(Sender: TObject);
    procedure RBXClick(Sender: TObject);
    procedure RBYClick(Sender: TObject);
    procedure RBZClick(Sender: TObject);
    procedure BBOkClick(Sender: TObject);
    procedure SEToChange(Sender: TObject);
    procedure SEFromChange(Sender: TObject);
   private
    { Private declarations }
   public
    { Public declarations }
  end;

var
  VUEFillDownWindow: TVUEFillDownWindow;

implementation

uses vuecreat;

{$R *.DFM}

procedure TVUEFillDownWindow.RBidClick(Sender: TObject);
begin
 EDIncrement.Enabled := False;
 EDAccel.Enabled := False;
end;

procedure TVUEFillDownWindow.RBScaleClick(Sender: TObject);
begin
 EDIncrement.Enabled := True;
 EDAccel.Enabled := True;
end;

procedure TVUEFillDownWindow.RBPitchClick(Sender: TObject);
begin
 EDIncrement.Enabled := True;
 EDAccel.Enabled := True;
end;

procedure TVUEFillDownWindow.RBYawClick(Sender: TObject);
begin
 EDIncrement.Enabled := True;
 EDAccel.Enabled := True;
end;

procedure TVUEFillDownWindow.RBRollClick(Sender: TObject);
begin
 EDIncrement.Enabled := True;
 EDAccel.Enabled := True;
end;

procedure TVUEFillDownWindow.RBXClick(Sender: TObject);
begin
 EDIncrement.Enabled := True;
 EDAccel.Enabled := True;
end;

procedure TVUEFillDownWindow.RBYClick(Sender: TObject);
begin
 EDIncrement.Enabled := True;
 EDAccel.Enabled := True;
end;

procedure TVUEFillDownWindow.RBZClick(Sender: TObject);
begin
 EDIncrement.Enabled := True;
 EDAccel.Enabled := True;
end;

{************************************************************************}

procedure TVUEFillDownWindow.SEToChange(Sender: TObject);
begin
 SEFrom.MaxValue := SETo.Value - 1;
end;

procedure TVUEFillDownWindow.SEFromChange(Sender: TObject);
begin
 SETo.MinValue := SEFrom.Value + 1;
end;

{************************************************************************}

procedure TVUEFillDownWindow.BBOkClick(Sender: TObject);
var a, d, col, Icode, Acode, StartCode, ThisCode: integer;
    IVal, AVal, StartVal, ThisVal, NextVal: real;
    Stri, S: string;
    Err, Valid: Boolean;
    Data : TStringGrid;
begin
 Valid := True;

 Val(EDIncrement.Text, IVal, ICode);
 if (ICode <> 0) and not RBid.Checked then
  begin
   ShowMessage('Invalid Increment value');
   EDIncrement.SetFocus;
   Valid := False;
  end;

 Val(EDAccel.Text, AVal, ACode);
 if (ACode <> 0) and not RBid.Checked then
  begin
   ShowMessage('Invalid Acceleration value');
   EDAccel.SetFocus;
   Valid := False;
  end;

 if Valid then
  BEGIN
   Data := VUECreator.DataGrid;
   Err := False;

   if RBid.Checked then
    begin
     if Data.Cells[1, SEFrom.Value + 1] = '' then
      with VUECreator do
       BEGIN
        PNLErrors.Caption := 'Error: ID is empty';
        DataGrid.Col := 1;
        DataGrid.Row := SEFrom.Value + 1;
        Err := True;
       END;
     if Length(Data.Cells[1, SEFrom.Value + 1]) > 15 then
      with VUECreator do
       BEGIN
        PNLErrors.Caption := 'Error: ID too long (Max 15 characters)';
        DataGrid.Col := 1;
        DataGrid.Row := SEFrom.Value + 1;
        Err := True;
       END;
     if Pos(' ', Data.Cells[1, SEFrom.Value + 1]) <> 0 then
      with VUECreator do
       BEGIN
        PNLErrors.Caption := 'Error: ID contains space';
        DataGrid.Col := 1;
        DataGrid.Row := SEFrom.Value + 1;
        Err := True;
       END;
     if not Err then
      begin
       VUECreator.PNLErrors.Caption := '';
       for a := SEFrom.Value to SETo.Value do
        Data.Cells[1, a + 1] := Data.Cells[1, SEFrom.Value + 1];
      end;
    end;

   if RBScale.Checked then
    begin
     Val(Data.Cells[2, SEFrom.Value + 1] , StartVal, StartCode);
     if StartVal <= 0 then
      with VUECreator do
       BEGIN
        PNLErrors.Caption := 'Error: Scale must be greater than 0';
        DataGrid.Col := 2;
        DataGrid.Row := SEFrom.Value + 1;
       END;
     if StartCode <> 0 then
      with VUECreator do
       BEGIN
        PNLErrors.Caption := 'Error: Invalid number';
        DataGrid.Col := 2;
        DataGrid.Row := SEFrom.Value + 1;
       END;
     if (StartVal > 0) and (StartCode = 0) then
      begin
       VUECreator.PNLErrors.Caption := '';
       for a := SEFrom.Value to SETo.Value - 1 do
        BEGIN
         Val(Data.Cells[2, a + 1] , ThisVal, ThisCode);
         NextVal := ThisVal + IVal + (a - SEFrom.Value) * AVal;
         if NextVal <= 0 then NextVal := 0.01;
         Str(NextVal : 0 : 2, Stri);
         Data.Cells[2, a + 2] := Stri;
        END;
      end;
    end;

   if RBPitch.Checked or RBYaw.Checked or RBRoll.Checked then
    begin
     if RBPitch.Checked then col := 3;
     if RBYaw.Checked then col := 4;
     if RBRoll.Checked then col := 5;
     Val(Data.Cells[col, SEFrom.Value + 1] , StartVal, StartCode);
     if (StartVal < 0) or (StartVal >= 360) then
      with VUECreator do
       BEGIN
        PNLErrors.Caption := 'Error: Angle must be >= 0 and < 360';
        DataGrid.Col := col;
        DataGrid.Row := SEFrom.Value + 1;
       END;
     if StartCode <> 0 then
      with VUECreator do
       BEGIN
        PNLErrors.Caption := 'Error: Invalid number';
        DataGrid.Col := col;
        DataGrid.Row := SEFrom.Value + 1;
       END;
     if (StartCode = 0) and (StartVal >= 0) and (StartVal < 360) then
      begin
       VUECreator.PNLErrors.Caption := '';
       for a := SEFrom.Value to SETo.Value - 1 do
        BEGIN
         Val(Data.Cells[col, a + 1] , ThisVal, ThisCode);
         NextVal := ThisVal + IVal + (a - SEFrom.Value) * AVal;
         if NextVal < 0 then NextVal := 360 + NextVal;
         if NextVal >= 360 then NextVal := NextVal - 360;
         Str(NextVal : 0 : 2, Stri);
         Data.Cells[col, a + 2] := Stri;
        END;
      end;
    end;

   if RBX.Checked or RBY.Checked or RBZ.Checked then
    begin
     if RBX.Checked then col := 6;
     if RBY.Checked then col := 7;
     if RBZ.Checked then col := 8;
     Val(Data.Cells[col, SEFrom.Value + 1] , StartVal, StartCode);
     if StartCode <> 0 then
      with VUECreator do
       BEGIN
        PNLErrors.Caption := 'Error: Invalid number';
        DataGrid.Col := col;
        DataGrid.Row := SEFrom.Value + 1;
       END;
     if StartCode = 0 then
      begin
       VUECreator.PNLErrors.Caption := '';
       for a := SEFrom.Value to SETo.Value - 1 do
        BEGIN
         Val(Data.Cells[col, a + 1] , ThisVal, ThisCode);
         NextVal := ThisVal + IVal + (a - SEFrom.Value) * AVal;
         Str(NextVal : 0 : 2, Stri);
         Data.Cells[col, a + 2] := Stri;
        END;
      end;
    end;

   VUECreator.DataGrid := Data;
   VUEFillDownWindow.Close;
  END;
end;

end.
