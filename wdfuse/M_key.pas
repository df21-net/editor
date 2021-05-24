unit M_key;

interface

uses
WinTypes, WinProcs, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,FileCtrl, IniFiles,  M_Global, _Files, G_Util, Buttons, ExtCtrls,
   {$IFDEF WDF32}
ZRender,ComCtrls,
{$ENDIF}
  Stitch,  Tabnotbk;

type
  TAllKeys = class(TForm)
    Memokeys: TMemo;
    PanelTop: TPanel;
    SBMapAll: TSpeedButton;
    SBMapEditModes: TSpeedButton;
    SBMapEditor: TSpeedButton;

    procedure SBMapAllClick(Sender: TObject);
    procedure SBMapEditModesClick(Sender: TObject);
    procedure SBMapEditorClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);

  private
    { Private declarations }

  public

    { Public declarations }
  end;

var
  AllKeys: TAllKeys;
  KeyText: TextFile;
        S: String;
  KeyFile: String;
implementation

{$R *.DFM}



procedure TAllKeys.SBMapAllClick(Sender: TObject);
         begin
     Allkeys.Memokeys.clear ;
       AssignFile(KeyText,(WDFUSEdir + '\WDFDATA\' + 'Keymap.wdl'));
       Reset(KeyText);
        Try
          while not eof(KeyText) do begin
           readln(KeyText,s);
        ALLKeys.Memokeys.lines.Add(s);
        end;
         finally
         CloseFile(KeyText);
      end;
   end;

procedure TAllKeys.SBMapEditModesClick(Sender: TObject);
   begin
    Memokeys.clear ;
       AssignFile(KeyText,(WDFUSEdir + '\WDFDATA\' + 'Keymapmd.wdl'));
       Reset(KeyText);
        Try
          while not eof(KeyText) do begin
           readln(KeyText,s);
           Memokeys.lines.Add(s);
        end;
         finally
         CloseFile(KeyText);
      end;
   end;



procedure TAllKeys.SBMapEditorClick(Sender: TObject);
begin
       begin
    Memokeys.clear ;
       AssignFile(KeyText,(WDFUSEdir + '\WDFDATA\' + 'Keymaped.wdl'));
       Reset(KeyText);
        Try
          while not eof(KeyText) do begin
           readln(KeyText,s);
           Memokeys.lines.Add(s);
        end;
         finally
         CloseFile(KeyText);
      end;
   end;
end;



procedure TAllKeys.FormClose(Sender: TObject; var Action: TCloseAction);
begin
      Memokeys.Clear
end;

end.
