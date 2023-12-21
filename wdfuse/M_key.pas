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
    StayOnTopCheckBox: TCheckBox;

    function LoadKeys(KeyFile : String) : String;
    procedure SBMapAllClick(Sender: TObject);
    procedure SBMapEditModesClick(Sender: TObject);
    procedure SBMapEditorClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure StayOnTopCheckBoxClick(Sender: TObject);

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
  MapKeys: String;
  MapEditKeys: String;
  EditorKeys: String;
  OnTop : Integer;
  OnTopState : Boolean;
implementation

{$R *.DFM}

procedure TAllKeys.FormCreate(Sender: TObject);
begin
 if not DirectoryExists(WDFUSEdir + '\WDFDATA\')  then
    begin
      log.error('Cannot load help keys because WDFDATA directory is missing!', LogName);
      exit;
    end;

 MapKeys := LoadKeys('Keymap.wdl');
 MapEditKeys := LoadKeys('Keymapmd.wdl');
 EditorKeys := LoadKeys('Keymaped.wdl');
 SBMapAllClick(Sender);
 OnTop               := Ini.ReadInteger('KEYS', 'ONTOP', 1);
 if OnTop = 0 then
   begin
    Allkeys.StayOnTopCheckBox.Checked := FALSE;
    Allkeys.FormStyle := fsNormal;
    OnTopState := FALSE;
   end
 else
   begin
    Allkeys.StayOnTopCheckBox.Checked := TRUE;
    Allkeys.FormStyle := fsStayOnTop;
    OnTopState := TRUE;
   end

end;

function TAllKeys.LoadKeys(KeyFile : string) : string;
var KeyString, KeyStringTemp : string;
begin
   KeyString := '';
   AssignFile(KeyText,(WDFUSEdir + '\WDFDATA\' + KeyFile));
   Reset(KeyText);
    Try
      while not eof(KeyText) do begin
       readln(KeyText,KeyStringTemp);
       KeyString := KeyString + sLineBreak  + KeyStringTemp;
    end;
     finally
     CloseFile(KeyText);
  end;
  Result := KeyString;
end;

procedure TAllKeys.SBMapAllClick(Sender: TObject);
begin
 Allkeys.Memokeys.clear ;
 Allkeys.Memokeys.Text := MapKeys;
 Allkeys.Memokeys.SelStart := 0;
end;

procedure TAllKeys.SBMapEditModesClick(Sender: TObject);
begin
 Allkeys.Memokeys.clear ;
 Allkeys.Memokeys.Text := MapEditKeys;
 Allkeys.Memokeys.SelStart := 0;
end;

procedure TAllKeys.SBMapEditorClick(Sender: TObject);
begin
 Allkeys.Memokeys.clear ;
 Allkeys.Memokeys.Text := EditorKeys;
 Allkeys.Memokeys.SelStart := 0;
end;

procedure TAllKeys.StayOnTopCheckBoxClick(Sender: TObject);
begin
  if OnTopState then
   begin
    StayOnTopCheckBox.Checked := FALSE;
    Allkeys.FormStyle := fsNormal;
    Ini.WriteInteger('KEYS', 'ONTOP', 0);
   end
  else
   begin
    StayOnTopCheckBox.Checked := TRUE;
    Allkeys.FormStyle := fsStayOnTop;
    Ini.WriteInteger('KEYS', 'ONTOP', 1)
   end;
  OnTopState := StayOnTopCheckBox.Checked;
end;

{
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

     }

procedure TAllKeys.FormClose(Sender: TObject; var Action: TCloseAction);
begin
      Memokeys.Clear
end;

end.
