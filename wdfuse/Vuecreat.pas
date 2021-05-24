unit vuecreat;

interface

uses
  WinTypes, WinProcs, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, ExtCtrls, Buttons ;

type
  TVUECreator = class(TForm)
    DataGrid: TStringGrid;
    OpenDataFile: TOpenDialog;
    SaveDataFile: TSaveDialog;
    Panel1: TPanel;
    SBQuit: TSpeedButton;
    SBLoad: TSpeedButton;
    SBSave: TSpeedButton;
    SBCreateVue: TSpeedButton;
    SBFillDown: TSpeedButton;
    SBCheck: TSpeedButton;
    PNLErrors: TPanel;
    SaveVUEFile: TSaveDialog;
    SBClear: TSpeedButton;
    SBPreview: TSpeedButton;
    SBOffset: TSpeedButton;
    SBHelp: TSpeedButton;
    SBCurve: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure SBQuitClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure SBLoadClick(Sender: TObject);
    procedure SBSaveClick(Sender: TObject);
    procedure SBCheckClick(Sender: TObject);
    procedure SBCreateVueClick(Sender: TObject);
    procedure SBFillDownClick(Sender: TObject);
    procedure SBOffsetClick(Sender: TObject);
    procedure SBClearClick(Sender: TObject);
    procedure SBPreviewClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  VUECreator: TVUECreator;

implementation

uses vue_fldn, vue_clr, vue_util, vue_offs;

{$R *.DFM}

procedure TVUECreator.FormCreate(Sender: TObject);
var
 a: integer;
 FrameNum: string;
begin
 with DataGrid do
  begin
   ColWidths[0] := 40;
   ColWidths[1] := 112;

   Cells[0, 0] := 'Frame';
   Cells[1, 0] := 'Id';
   Cells[2, 0] := 'Scale';
   Cells[3, 0] := 'Pitch';
   Cells[4, 0] := 'Yaw';
   Cells[5, 0] := 'Roll';
   Cells[6, 0] := 'X pos';
   Cells[7, 0] := 'Y pos';
   Cells[8, 0] := 'Z pos';

   for a := 1 to 10001 do
    begin
     Str(a - 1, FrameNum);
     Cells[0, a] := FrameNum;
    end;
  end;
end;

procedure TVUECreator.SBQuitClick(Sender: TObject);
begin
 VUECreator.Close;
end;

procedure TVUECreator.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
 CanClose := True;
end;

procedure TVUECreator.SBLoadClick(Sender: TObject);
var F, L : integer;
begin
 if OpenDataFile.Execute then
  if not LoadData(OpenDataFile.FileName, DataGrid) then
   begin
    F := 1;
    L := 10000;
    ClearCells(F, L);
    ShowMessage('Error reading VSD File');
   end;
end;

procedure TVUECreator.SBSaveClick(Sender: TObject);
var Error : boolean;
begin
 CheckData(DataGrid, PNLErrors, Error);
 if not error then
  if SaveDataFile.Execute then SaveData(SaveDataFile.FileName, DataGrid);
end;

procedure TVUECreator.SBCheckClick(Sender: TObject);
var Error : boolean;
begin
 CheckData(DataGrid, PNLErrors, Error);
end;

procedure TVUECreator.SBCreateVueClick(Sender: TObject);
var Error : boolean;
begin
 CheckData(DataGrid, PNLErrors, Error);
 if not error then
  if SaveVUEFile.Execute then CreateVUE(SaveVUEFile.FileName, DataGrid);
end;

procedure TVUECreator.SBFillDownClick(Sender: TObject);
begin
 VUEFillDownWindow.ShowModal;
end;

procedure TVUECreator.SBOffsetClick(Sender: TObject);
begin
 VUEOffsetWindow.ShowModal;
end;

procedure TVUECreator.SBClearClick(Sender: TObject);
begin
 VUEClearWindow.ShowModal;
end;

procedure TVUECreator.SBPreviewClick(Sender: TObject);
begin
 ShowMessage('Not Implemented Yet!');
end;

end.
