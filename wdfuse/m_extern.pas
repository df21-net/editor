unit M_extern;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, SysUtils, M_Global;

type
  TExtToolsWindow = class(TForm)
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    HelpBtn: TBitBtn;
    EDParameters: TEdit;
    LBExtTools: TListBox;
    Label1: TLabel;
    LBHidden: TListBox;
    procedure FormActivate(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ExtToolsWindow: TExtToolsWindow;

implementation
uses Mapper;

{$R *.DFM}

procedure TExtToolsWindow.FormActivate(Sender: TObject);
begin
 if FileExists(WDFUSEdir + '\WDFDATA\external.wdl') and
    FileExists(WDFUSEdir + '\WDFDATA\external.wdn') then
  begin
   LBExtTools.Items.LoadFromFile(WDFUSEdir + '\WDFDATA\external.wdl');
   LBHidden.Items.LoadFromFile(WDFUSEdir + '\WDFDATA\external.wdn');
  end
 else
  Application.MessageBox('Problem : check the External Tools settings',
                         'WDFUSE - External Tools',
                          mb_Ok or mb_IconExclamation);
end;

function ArrayToString(const a: array of Char): string;
begin
  if Length(a)>0 then
    SetString(Result, PChar(@a[0]), Length(a))
  else
    Result := '';
end;

procedure TExtToolsWindow.OKBtnClick(Sender: TObject);
var tmp : array[0..127] of char;
begin
 if LBExtTools.ItemIndex <> -1 then
  begin
   Chdir(WDFUSEdir);
   StrPcopy(tmp, LBHidden.Items[LBExtTools.ItemIndex] + ' ' + EDParameters.Text);
   WinExec(PAnsiChar(AnsiString(tmp)), SW_SHOWNORMAL);
   ShowWindow(MapWindow.Handle, SW_HIDE);
   TMPHWindow := GetActiveWindow;
   ShowWindow(MapWindow.Handle, SW_SHOW);
  end;
end;

procedure TExtToolsWindow.HelpBtnClick(Sender: TObject);
begin
 Application.HelpJump('wdfuse_help_optionsexternal');
end;

end.
