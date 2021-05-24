unit M_motif;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, TabNotBk, Spin;

type
  TMotifWindow = class(TForm)
    TabbedNotebook: TTabbedNotebook;
    ListBox1: TListBox;
    Label1: TLabel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Edit1: TEdit;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    Edit2: TEdit;
    Edit3: TEdit;
    SpinEdit1: TSpinEdit;
    BitBtn3: TBitBtn;
    BitBtn4: TBitBtn;
    Label2: TLabel;
    ListBox2: TListBox;
    BitBtn5: TBitBtn;
    BitBtn6: TBitBtn;
    BitBtn7: TBitBtn;
    Edit4: TEdit;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    SpinEdit2: TSpinEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    CheckBox7: TCheckBox;
    Edit7: TEdit;
    BitBtn8: TBitBtn;
    BitBtn9: TBitBtn;
    BitBtn10: TBitBtn;
    CheckBox8: TCheckBox;
    CheckBox9: TCheckBox;
    CheckBox10: TCheckBox;
    CheckBox11: TCheckBox;
  private
    { Déclarations private }
  public
    { Déclarations public }
  end;

var
  MotifWindow: TMotifWindow;

implementation

{$R *.DFM}

end.
