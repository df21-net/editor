unit T_convrt;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, StdCtrls, Buttons, M_Global,
  C_Util, T_PalOpt;

type
  TConvertWindow = class(TForm)
    ConvertBM: TBitBtn;
    ConvertBMP: TBitBtn;
    ConvertDELT: TBitBtn;
    ConvertFME: TBitBtn;
    ConvertPAL: TBitBtn;
    ConvertBMTransparent: TCheckBox;
    ConvertFMECompressed: TCheckBox;
    ConvertFMEInsertX: TEdit;
    ConvertFMEInsertY: TEdit;
    LabelFMEInsertion: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    ConvertPLTT: TBitBtn;
    Bevel1: TBevel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    Bevel4: TBevel;
    Bevel5: TBevel;
    Bevel6: TBevel;
    ConvertName: TEdit;
    Label5: TLabel;
    BNChoseName: TBitBtn;
    BNCancel: TBitBtn;
    LabelDELTOffset: TLabel;
    Label7: TLabel;
    ConvertDELTOffsetX: TEdit;
    Label8: TLabel;
    ConvertDELTOffsetY: TEdit;
    BNHelp: TBitBtn;
    ConvertFMEFlip: TCheckBox;
    OpenPALorPLTT: TOpenDialog;
    ConvertPaletteOptions: TBitBtn;
    ConvertBMCompressed: TRadioGroup;
    procedure FormActivate(Sender: TObject);
    procedure ConvertPLTTClick(Sender: TObject);
    procedure ConvertPALClick(Sender: TObject);
    procedure ConvertBMPClick(Sender: TObject);
    procedure ConvertBMClick(Sender: TObject);
    procedure ConvertDELTClick(Sender: TObject);
    procedure ConvertFMEClick(Sender: TObject);
    procedure ConvertPaletteOptionsClick(Sender: TObject);
    procedure BNHelpClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ConvertWindow: TConvertWindow;

implementation

{$R *.DFM}

procedure TConvertWindow.FormActivate(Sender: TObject);
begin
 ConvertWindow.Caption := 'TOOLKIT Convert - ' + TheRES;
 ConvertName.Text    := ChangeFileExt(TheRES, '');
 TktPalette.ConvertPalette.Text := ThePAL;

 { enabled/disabled controls and default values for insertion}
 if ExtractFileExt(TheRes) = '.bm' then
  begin
   TktPalette.ConvertPalette.Enabled  := TRUE;
   TktPalette.ConvertNoPAL.Enabled    := FALSE;
   TktPalette.BNChosePalette.Enabled  := TRUE;
   ConvertPaletteOptions.Enabled  := TRUE;

   ConvertBM.Enabled              := FALSE;
   ConvertBMTransparent.Enabled   := FALSE;

   ConvertBMP.Enabled             := TRUE;

   ConvertDELT.Enabled            := FALSE;
   LabelDELTOffset.Enabled        := FALSE;
   ConvertDELTOffsetX.Enabled     := FALSE;
   ConvertDELTOffsetY.Enabled     := FALSE;

   ConvertFME.Enabled             := FALSE;
   ConvertFMECompressed.Enabled   := FALSE;
   LabelFMEInsertion.Enabled      := FALSE;
   ConvertFMEInsertX.Enabled      := FALSE;
   ConvertFMEInsertY.Enabled      := FALSE;
   ConvertFMEFlip.Enabled         := FALSE;

   ConvertPAL.Enabled             := FALSE;
   ConvertPLTT.Enabled            := FALSE;
  end;

 if ExtractFileExt(TheRes) = '.bmp' then
  begin
   TktPalette.ConvertPalette.Enabled  := TRUE;
   TktPalette.ConvertNoPAL.Enabled    := TRUE;
   TktPalette.BNChosePalette.Enabled  := TRUE;
   ConvertPaletteOptions.Enabled  := TRUE;

   ConvertBM.Enabled              := TRUE;
   ConvertBMTransparent.Enabled   := TRUE;

   ConvertBMP.Enabled             := FALSE;

   ConvertDELT.Enabled            := TRUE;
   LabelDELTOffset.Enabled        := TRUE;
   ConvertDELTOffsetX.Enabled     := TRUE;
   ConvertDELTOffsetY.Enabled     := TRUE;
   {Offsets to 0 by default}

   ConvertFME.Enabled             := TRUE;
   ConvertFMECompressed.Enabled   := TRUE;
   LabelFMEInsertion.Enabled      := TRUE;
   ConvertFMEInsertX.Enabled      := TRUE;
   ConvertFMEInsertY.Enabled      := TRUE;
   ConvertFMEFlip.Enabled         := TRUE;
   {Insertion defaults}

   ConvertPAL.Enabled             := FALSE;
   ConvertPLTT.Enabled            := FALSE;
  end;

 if ExtractFileExt(TheRes) = '.dlt' then
  begin
   TktPalette.ConvertPalette.Enabled  := TRUE;
   TktPalette.ConvertNoPAL.Enabled    := FALSE;
   TktPalette.BNChosePalette.Enabled  := TRUE;
   ConvertPaletteOptions.Enabled  := TRUE;

   ConvertBM.Enabled              := FALSE;
   ConvertBMTransparent.Enabled   := FALSE;

   ConvertBMP.Enabled             := TRUE;

   ConvertDELT.Enabled            := FALSE;
   LabelDELTOffset.Enabled        := FALSE;
   ConvertDELTOffsetX.Enabled     := FALSE;
   ConvertDELTOffsetY.Enabled     := FALSE;

   ConvertFME.Enabled             := FALSE;
   ConvertFMECompressed.Enabled   := FALSE;
   LabelFMEInsertion.Enabled      := FALSE;
   ConvertFMEInsertX.Enabled      := FALSE;
   ConvertFMEInsertY.Enabled      := FALSE;
   ConvertFMEFlip.Enabled         := FALSE;

   ConvertPAL.Enabled             := FALSE;
   ConvertPLTT.Enabled            := FALSE;
  end;

 if ExtractFileExt(TheRes) = '.fme' then
  begin
   TktPalette.ConvertPalette.Enabled := TRUE;
   TktPalette.ConvertNoPAL.Enabled   := FALSE;
   TktPalette.BNChosePalette.Enabled := TRUE;
   ConvertPaletteOptions.Enabled  := TRUE;

   ConvertBM.Enabled              := FALSE;
   ConvertBMTransparent.Enabled   := FALSE;

   ConvertBMP.Enabled             := TRUE;

   ConvertDELT.Enabled            := FALSE;
   LabelDELTOffset.Enabled        := FALSE;
   ConvertDELTOffsetX.Enabled     := FALSE;
   ConvertDELTOffsetY.Enabled     := FALSE;

   ConvertFME.Enabled             := FALSE;
   ConvertFMECompressed.Enabled   := FALSE;
   LabelFMEInsertion.Enabled      := FALSE;
   ConvertFMEInsertX.Enabled      := FALSE;
   ConvertFMEInsertY.Enabled      := FALSE;
   ConvertFMEFlip.Enabled         := FALSE;

   ConvertPAL.Enabled             := FALSE;
   ConvertPLTT.Enabled            := FALSE;
  end;

 if (ExtractFileExt(TheRes) = '.pal') or
    (ExtractFileExt(TheRes) = '.plt') then
  begin
   TktPalette.ConvertPalette.Enabled := FALSE;
   TktPalette.ConvertNoPAL.Enabled   := FALSE;
   TktPalette.BNChosePalette.Enabled := FALSE;
   ConvertPaletteOptions.Enabled  := FALSE;

   ConvertBM.Enabled              := FALSE;
   ConvertBMTransparent.Enabled   := FALSE;

   ConvertBMP.Enabled             := FALSE;

   ConvertDELT.Enabled            := FALSE;
   LabelDELTOffset.Enabled        := FALSE;
   ConvertDELTOffsetX.Enabled     := FALSE;
   ConvertDELTOffsetY.Enabled     := FALSE;

   ConvertFME.Enabled             := FALSE;
   ConvertFMECompressed.Enabled   := FALSE;
   LabelFMEInsertion.Enabled      := FALSE;
   ConvertFMEInsertX.Enabled      := FALSE;
   ConvertFMEInsertY.Enabled      := FALSE;
   ConvertFMEFlip.Enabled         := FALSE;

   if ExtractFileExt(TheRes) = '.pal' then
    begin
     ConvertPAL.Enabled             := FALSE;
     ConvertPLTT.Enabled            := TRUE;
    end
   else
    begin
     ConvertPAL.Enabled             := TRUE;
     ConvertPLTT.Enabled            := FALSE;
    end;

  end;

end;

procedure TConvertWindow.ConvertPLTTClick(Sender: TObject);
var output : String;
begin
 if ExtractFileExt(ConvertName.Text) = '' then
  Output := ConvertName.Text + '.plt'
 else
  Output := ConvertName.Text;

 if ConvertPAL2PLTT(TheRES, Output) then
  ConvertWindow.ModalResult := mrOk;
end;

procedure TConvertWindow.ConvertPALClick(Sender: TObject);
var output : String;
begin
 if ExtractFileExt(ConvertName.Text) = '' then
  Output := ConvertName.Text + '.pal'
 else
  Output := ConvertName.Text;

 if ConvertPLTT2PAL(TheRES, Output)
  then ConvertWindow.ModalResult := mrOk;
end;

procedure TConvertWindow.ConvertBMPClick(Sender: TObject);
var output : String;
begin
 if TktPalette.ConvertPalette.Text = '' then
  begin
   Application.MessageBox('You must select a palette !',
                          'WDFUSE Toolkit - Convert', mb_Ok or mb_IconExclamation);
   exit;
  end;

 if ExtractFileExt(ConvertName.Text) = '' then
  Output := ConvertName.Text + '.bmp'
 else
  Output := ConvertName.Text;

 if ExtractFileExt(TheRES) = '.anm' then
  begin
   if ConvertANIMDELT2BMP(TheRES, TktPalette.ConvertPalette.Text, Output, CurFrame) then
    ConvertWindow.ModalResult := mrOk;
  end;

 if ExtractFileExt(TheRES) = '.bm' then
  begin
   if ConvertBM2BMP(TheRES, TktPalette.ConvertPalette.Text, Output) then
    ConvertWindow.ModalResult := mrOk;
  end;

 if ExtractFileExt(TheRES) = '.dlt' then
  begin
   if ConvertANIMDELT2BMP(TheRES, TktPalette.ConvertPalette.Text, Output, -1) then
    ConvertWindow.ModalResult := mrOk;
  end;

 if ExtractFileExt(TheRES) = '.fme' then
  begin
   if ConvertFME2BMP(TheRES, TktPalette.ConvertPalette.Text, Output) then
    ConvertWindow.ModalResult := mrOk;
  end;
end;


procedure TConvertWindow.ConvertBMClick(Sender: TObject);
var output : String;
begin
 if (TktPalette.ConvertPalette.Text = '') and not TktPalette.ConvertNoPal.Checked then
  begin
   Application.MessageBox('You must select a palette !',
                          'WDFUSE Toolkit - Convert', mb_Ok or mb_IconExclamation);
   exit;
  end;

 if ExtractFileExt(ConvertName.Text) = '' then
  Output := ConvertName.Text + '.bm'
 else
  Output := ConvertName.Text;

 if ExtractFileExt(TheRES) = '.bmp' then
  begin
   if ConvertBMP2BM(TheRES, Output, TktPalette.ConvertPalette.Text,
                    not TktPalette.ConvertNoPal.Checked, ConvertBMTransparent.Checked) then
    ConvertWindow.ModalResult := mrOk;
  end;
end;



procedure TConvertWindow.ConvertFMEClick(Sender: TObject);
var output   : String;
    x, y     : LongInt;
    code     : Integer;
    selfcalc : Boolean;
begin
 if (TktPalette.ConvertPalette.Text = '') and not TktPalette.ConvertNoPal.Checked then
  begin
   Application.MessageBox('You must select a palette !',
                          'WDFUSE Toolkit - Convert', mb_Ok or mb_IconExclamation);
   exit;
  end;

 if (ConvertFMEInsertX.Text = '') and (ConvertFMEInsertY.Text = '') then
  SelfCalc := TRUE
 else
  begin
   SelfCalc := FALSE;
   Val(ConvertFMEInsertX.Text, x, code);
   if code <> 0 then
    begin
     Application.MessageBox('Invalid X Insertion Point',
                            'WDFUSE Toolkit - Convert',
                             mb_Ok or mb_IconExclamation);
     exit;
    end;

   Val(ConvertFMEInsertY.Text, y, code);
   if code <> 0 then
    begin
     Application.MessageBox('Invalid Y Insertion Point',
                            'WDFUSE Toolkit - Convert',
                             mb_Ok or mb_IconExclamation);
     exit;
    end;
  end;

 if ExtractFileExt(ConvertName.Text) = '' then
  Output := ConvertName.Text + '.fme'
 else
  Output := ConvertName.Text;

 if ExtractFileExt(TheRES) = '.bmp' then
  begin
   if ConvertFMECompressed.Checked then
    begin
     if ConvertBMP2CompressedFME(TheRES, Output, TktPalette.ConvertPalette.Text,
                                   x, y, SelfCalc,
                                   ConvertFMEFlip.Checked,
                                   not TktPalette.ConvertNoPal.Checked) then
      ConvertWindow.ModalResult := mrOk;
    end
   else
    begin
     if ConvertBMP2UnCompressedFME(TheRES, Output, TktPalette.ConvertPalette.Text,
                                   x, y, SelfCalc,
                                   ConvertFMEFlip.Checked,
                                   not TktPalette.ConvertNoPal.Checked) then
      ConvertWindow.ModalResult := mrOk;
    end;
  end;

end;


procedure TConvertWindow.ConvertDELTClick(Sender: TObject);
var output : String;
    x, y   : Integer;
    code   : Integer;
begin
 if (TktPalette.ConvertPalette.Text = '') and not TktPalette.ConvertNoPal.Checked then
  begin
   Application.MessageBox('You must select a palette !',
                          'WDFUSE Toolkit - Convert', mb_Ok or mb_IconExclamation);
   exit;
  end;

 Val(ConvertDELTOffsetX.Text, x, code);
 if code <> 0 then
  begin
   Application.MessageBox('Invalid X Offset',
                          'WDFUSE Toolkit - Convert',
                           mb_Ok or mb_IconExclamation);
   exit;
  end;

 Val(ConvertDELTOffsetY.Text, y, code);
 if code <> 0 then
  begin
   Application.MessageBox('Invalid Y Offset',
                          'WDFUSE Toolkit - Convert',
                           mb_Ok or mb_IconExclamation);
   exit;
  end;

 if ExtractFileExt(ConvertName.Text) = '' then
  Output := ConvertName.Text + '.dlt'
 else
  Output := ConvertName.Text;

 if ExtractFileExt(TheRES) = '.bmp' then
  begin
   if ConvertBMP2DELT(TheRES, Output, TktPalette.ConvertPalette.Text,
                      x, y, not TktPalette.ConvertNoPal.Checked) then
    ConvertWindow.ModalResult := mrOk;
  end;
end;

procedure TConvertWindow.ConvertPaletteOptionsClick(Sender: TObject);
begin
 TktPalette.ShowModal;
end;

procedure TConvertWindow.BNHelpClick(Sender: TObject);
begin
 Application.HelpJump('wdftkt_help_convertdialog');
end;

end.
