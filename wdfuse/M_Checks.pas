unit M_checks;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, SysUtils, _Strings, M_Global;

type
  TChecksWindow = class(TForm)
    BNGoto: TBitBtn;
    CloseBtn: TBitBtn;
    LBChecks: TListBox;
    BNRecheck: TBitBtn;
    CBOnTop: TCheckBox;
    CBPin: TCheckBox;
    Memo: TMemo;
    procedure LBChecksClick(Sender: TObject);
    procedure BNGotoClick(Sender: TObject);
    procedure CloseBtnClick(Sender: TObject);
    procedure BNRecheckClick(Sender: TObject);
    procedure CBOnTopClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ChecksWindow: TChecksWindow;

implementation
uses Mapper, M_MapUt, M_Util, M_Editor, Infedit2;

{$R *.DFM}

procedure TChecksWindow.LBChecksClick(Sender: TObject);
var TheLine : String;
begin
  TheLine := LBChecks.Items[LBChecks.ItemIndex];
  if (TheLine[1] = 'S') or
     (TheLine[1] = 's') or
     (TheLine[1] = 'W') or
     (TheLine[1] = 'w') or
     (TheLine[1] = 'O') then
    BNGoto.Enabled := TRUE
  else
   BNGoto.Enabled := FALSE;
end;

procedure TChecksWindow.BNGotoClick(Sender: TObject);
var TheLine : String;
    TheSector : TSector;
    pars    : TStringParser;
begin
 TheLine := LBChecks.Items[LBChecks.ItemIndex];
 pars    := TStringParser.Create(TheLine);
 CASE TheLine[1] OF
  'S','s' : begin
             if StrToInt(pars[2]) < MAP_SEC.Count then
              begin
               SC_HILITE := StrToInt(pars[2]);
               WL_HILITE := 0;
               VX_HILITE := 0;
               if MAP_MODE = MM_SC then
                DO_Fill_SectorEditor
               else
                DO_Switch_To_SC_Mode;
               DO_Center_On_CurrentObject;
               if TheLine[1] = 's' then
                begin
                 INFSector := SC_HILITE;
                 INFWall   := -1;
                 INFRemote := TRUE;
                 INFWindow2.Show;
                 INFWindow2.FormActivate(NIL);
                end;
              end
             else
              begin
               Application.MessageBox('This sector doesn''t exist anymore !',
                                      'Consistency Checks',
                                       mb_Ok or mb_IconExclamation);
              end;
        end;
  'W','w' : begin
             if StrToInt(pars[4]) < MAP_SEC.Count then
              begin
               TheSector := TSector(MAP_SEC.Objects[StrToInt(pars[4])]);
               if StrToInt(pars[2]) < TheSector.Wl.Count then
                begin
                 SC_HILITE := StrToInt(pars[4]);
                 WL_HILITE := StrToInt(pars[2]);
                 VX_HILITE := 0;
                 if MAP_MODE = MM_WL then
                  DO_Fill_WallEditor
                 else
                  DO_Switch_To_WL_Mode;
                 DO_Center_On_CurrentObject;
                 if TheLine[1] = 'w' then
                  begin
                   INFSector := SC_HILITE;
                   INFWall   := WL_HILITE;
                   INFRemote := TRUE;
                   INFWindow2.Show;
                   INFWindow2.FormActivate(NIL);
                  end;
                end
               else
                begin
                 Application.MessageBox('This wall doesn''t exist anymore !',
                                        'Consistency Checks',
                                         mb_Ok or mb_IconExclamation);
                end;
              end
             else
              begin
               Application.MessageBox('This sector doesn''t exist anymore !',
                                      'Consistency Checks',
                                       mb_Ok or mb_IconExclamation);
              end;
        end;
  'O' : begin
         if StrToInt(pars[2]) < MAP_OBJ.Count then
          begin
           OB_HILITE := StrToInt(pars[2]);
           if MAP_MODE = MM_OB then
            DO_Fill_ObjectEditor
           else
            DO_Switch_To_OB_Mode;
           DO_Center_On_CurrentObject;
          end
         else
          begin
           Application.MessageBox('This object doesn''t exist anymore !',
                                  'Consistency Checks',
                                   mb_Ok or mb_IconExclamation);
          end;
        end;
 END;
 pars.Free;
 BNGoto.Enabled := FALSE;
 LBChecks.ItemIndex := -1;
 if not CBPin.Checked then Close;
end;

procedure TChecksWindow.BNRecheckClick(Sender: TObject);
begin
 DO_ConsistencyChecks;
end;

procedure TChecksWindow.CBOnTopClick(Sender: TObject);
begin
 if CBOnTop.Checked then
  FormStyle := fsStayOnTop
 else
  FormStyle := fsNormal;
end;

procedure TChecksWindow.CloseBtnClick(Sender: TObject);
begin
 Close;
end;

procedure TChecksWindow.FormCreate(Sender: TObject);
begin
 ChecksWindow.Left   := Ini.ReadInteger('WINDOWS', 'Checks         X', 0);
 ChecksWindow.Top    := Ini.ReadInteger('WINDOWS', 'Checks         Y', 72);
 ChecksWindow.CBPin.Checked   := Ini.ReadBool('WINDOWS', 'Checks         P', TRUE);
 ChecksWindow.CBOnTop.Checked := Ini.ReadBool('WINDOWS', 'Checks         T', FALSE);
end;

procedure TChecksWindow.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
 Ini.WriteInteger('WINDOWS', 'Checks         X', ChecksWindow.Left);
 Ini.WriteInteger('WINDOWS', 'Checks         Y', ChecksWindow.Top);
 Ini.WriteBool   ('WINDOWS', 'Checks         P', ChecksWindow.CBPin.Checked);
 Ini.WriteBool   ('WINDOWS', 'Checks         T', ChecksWindow.CBOnTop.Checked);
end;

procedure TChecksWindow.FormDblClick(Sender: TObject);
begin
 Memo.Clear;
 Memo.Lines.AddStrings(LBChecks.Items);
 Memo.SelectAll;
 Memo.CopyToClipboard;
end;

end.
