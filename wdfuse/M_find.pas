unit M_find;

interface



uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls,
  M_Global, SysUtils, M_Editor;

type
  TToolsFind = class(TForm)
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    LBSectorNames: TListBox;
    FindName: TButton;
    FindID: TButton;
    procedure FormActivate(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure LBSectorNamesDblClick(Sender: TObject);
    procedure ListItems;
    procedure FindIDClick(Sender: TObject);
    procedure FindNameClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FindWindow : TToolsFind;
  UseNames : Boolean;

implementation
uses Mapper, M_Util;

{$R *.DFM}

procedure TToolsFind.ListItems;
var s         : Integer;
    TheSector : TSector;
begin

 LBSectorNames.Clear;
 LBSectorNames.Sorted :=  True;
 if not UseNames then LBSectorNames.Sorted := False;
 for s := 0 to MAP_SEC.Count - 1 do
  begin
   TheSector := TSector(MAP_SEC.Objects[s]);
   if not UseNames then
     LBSectorNames.Items.Add(inttostr(s))
   else
     if TheSector.Name <> '' then LBSectorNames.Items.Add(TheSector.Name);
  end;
 if LBSectorNames.Items.Count <> 0 then LBSectorNames.ItemIndex := 0;
end;

procedure TToolsFind.FindIDClick(Sender: TObject);
begin
     FindWindow.Caption := 'Find Sectors by ID';
     UseNames := False;
     ListItems;
end;

procedure TToolsFind.FindNameClick(Sender: TObject);
begin
     FindWindow.Caption := 'Find Sectors by Name';
     UseNames := True;
     ListItems;
end;

procedure TToolsFind.FormActivate(Sender: TObject);
begin
 FindNameClick(NIL);
end;

procedure TToolsFind.OKBtnClick(Sender: TObject);
var s : integer;
TheSector : TSector;
TheVertex : TVertex;
begin
 FINDSC_VALUE := LBSectorNames.Items[LBSectorNames.ItemIndex];
 if UseNames then
  begin
   if FINDSC_VALUE <> '' then
    for s := 0 to MAP_SEC.Count - 1 do
     begin
      TheSector := TSector(MAP_SEC.Objects[s]);
      if TheSector.Name = FINDSC_VALUE then
       begin
        TheVertex  := TVertex(TheSector.Vx.Objects[0]);
        MapWindow.SetXOffset(Round(TheVertex.X));
        MapWindow.SetZOffset(Round(TheVertex.Z));
        SC_HILITE := s;
        WL_HILITE := 0;
        VX_HILITE := 0;
        DO_Fill_SectorEditor;
        MapWindow.Map.Invalidate;
        break;
       end;
     end;
  end
 else
  begin
   SC_HILITE := LBSectorNames.ItemIndex;
   TheSector := TSector(MAP_SEC.Objects[SC_HILITE]);
   TheVertex := TVertex(TheSector.Vx.Objects[0]);
   MapWindow.SetXOffset(Round(TheVertex.X));
   MapWindow.SetZOffset(Round(TheVertex.Z));
   WL_HILITE := 0;
   VX_HILITE := 0;
   DO_Fill_SectorEditor;
   MapWindow.Map.Invalidate;
  end;
end;

procedure TToolsFind.LBSectorNamesDblClick(Sender: TObject);
begin
 OKBtnClick(Sender);
end;

end.
