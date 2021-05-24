unit M_find;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls,
  M_Global;

type
  TFindWindow = class(TForm)
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    LBSectorNames: TListBox;
    procedure FormActivate(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure LBSectorNamesDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FindWindow: TFindWindow;

implementation
uses Mapper;

{$R *.DFM}

procedure TFindWindow.FormActivate(Sender: TObject);
var s         : Integer;
    TheSector : TSector;
begin
 LBSectorNames.Clear;
 for s := 0 to MAP_SEC.Count - 1 do
  begin
   TheSector := TSector(MAP_SEC.Objects[s]);
   if TheSector.Name <> '' then LBSectorNames.Items.Add(TheSector.Name);
  end;
 if LBSectorNames.Items.Count <> 0 then LBSectorNames.ItemIndex := 0;
end;

procedure TFindWindow.OKBtnClick(Sender: TObject);
begin
 FINDSC_VALUE := LBSectorNames.Items[LBSectorNames.ItemIndex];
 FindWindow.Close;
end;

procedure TFindWindow.LBSectorNamesDblClick(Sender: TObject);
begin
 OKBtnClick(Sender);
end;

end.
