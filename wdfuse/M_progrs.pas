unit M_progrs;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Gauges, ExtCtrls;

type
  TProgressWindow = class(TForm)
    Progress1: TPanel;
    Progress2: TPanel;
    Gauge: TGauge;
    Panel1: TPanel;
    Panel2: TPanel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ProgressWindow: TProgressWindow;

implementation

{$R *.DFM}

end.
