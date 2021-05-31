unit LHEdit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Level, Misc_utils;

type
  TLHEditor = class(TForm)
    Label1: TLabel;
    EBMusic: TEdit;
    BNMusic: TButton;
    Label2: TLabel;
    EBParallax_X: TEdit;
    Label3: TLabel;
    EBParallax_Y: TEdit;
    BNOK: TButton;
    Button3: TButton;
    procedure BNOKClick(Sender: TObject);
    procedure BNMusicClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    Lev:TLevel;
  public
    MapWindow:TForm;

    { Public declarations }
    Function EditHeader(L:TLevel):Boolean;
  end;

var
  LHEditor: TLHEditor;

implementation

uses ResourcePicker, Mapper;

{$R *.DFM}

Function TLHEditor.EditHeader(L:TLevel):Boolean;
begin
 EBMusic.Text:=L.Music;
 EBParallax_X.Text:=FloatToStr(L.Parallax_X);
 EBParallax_Y.Text:=FloatToStr(L.Parallax_Y);
 Lev:=l;
 Result:=ShowModal=mrOK;
end;

procedure TLHEditor.BNOKClick(Sender: TObject);
var P_X,P_Y:double;
begin
 if ValDouble(EBParallax_X.Text,P_X) then
  if ValDouble(EBParallax_Y.Text,P_Y) then
  begin
   if Trim(EBMusic.Text)='' then Lev.Music:='NULL' else Lev.Music:=EBMusic.Text;
   Lev.Parallax_X:=P_X;
   Lev.Parallax_Y:=P_Y;
   ModalResult:=mrOK;
   Hide;
  end
  else MsgBox('Invalid value for Parallax Y','Error',mb_ok)
 else MsgBox('Invalid value for Parallax Y','Error',mb_ok);
end;

procedure TLHEditor.BNMusicClick(Sender: TObject);
begin
{ if MapWindow<>nil then ResPicker.ProjectDirectory:=
  TMapWindow(MapWindow).ProjectDirectory;}
 EBMusic.Text:=ResPicker.PickMusic(EBMusic.Text);
end;

procedure TLHEditor.FormCreate(Sender: TObject);
begin
 ClientWidth:=Label1.Left+BNOK.Left+BNOK.Width;
 ClientHeight:=Label1.Top+EBParallax_X.Top+EBParallax_X.Height;
end;

end.
