unit u_tpledit;

{$MODE Delphi}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, Grids, ExtCtrls;

type
  TTplEdit = class(TForm)
    Panel1: TPanel;
    SGVals: TStringGrid;
    TVTpls: TTreeView;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  TplEdit: TTplEdit;

implementation

{$R *.lfm}

end.
