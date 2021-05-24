unit M_obsel;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, M_Global, ExtCtrls, _strings;

type
  TOBSelector = class(TForm)
    CBCategories: TComboBox;
    LBObjects: TListBox;
    HiddenListBox: TListBox;
    Panel1: TPanel;
    SBCommit: TSpeedButton;
    SBRollback: TSpeedButton;
    procedure CBCategoriesChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure LBObjectsClick(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure SBCommitClick(Sender: TObject);
    procedure SBRollbackClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  OBSelector: TOBSelector;

implementation

{$R *.DFM}

procedure TOBSelector.CBCategoriesChange(Sender: TObject);
begin
 LBObjects.Clear;
 LBObjects.Items.LoadFromFile(WDFUSEdir + '\WDFDATA\' + HiddenListBox.Items[CBCategories.ItemIndex]);
end;

procedure TOBSelector.FormActivate(Sender: TObject);
begin
 CBCategories.Items.LoadFromFile(WDFUSEdir + '\WDFDATA\OBJECTS.WDL');
 CBCategories.ItemIndex := 0;
 HiddenListBox.Items.LoadFromFile(WDFUSEdir + '\WDFDATA\OBJECTS.WDN');
 HiddenListBox.ItemIndex := 0;
 CBCategoriesChange(Sender);
end;

procedure TOBSelector.LBObjectsClick(Sender: TObject);
begin
 OBSEL_VALUE := RTrim(Copy(LBObjects.Items[LBObjects.ItemIndex],1,12));
end;

procedure TOBSelector.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
if Shift = [] then
    Case Key of
      VK_F2,
      VK_RETURN : OBSelector.ModalResult := mrOk;
      VK_ESCAPE : OBSelector.ModalResult := mrCancel;
    end;
end;

procedure TOBSelector.SBCommitClick(Sender: TObject);
begin
 OBSelector.ModalResult := mrOk;
end;

procedure TOBSelector.SBRollbackClick(Sender: TObject);
begin
 OBSelector.ModalResult := mrCancel;
end;

end.
