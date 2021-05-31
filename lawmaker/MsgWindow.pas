unit MsgWindow;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, StdCtrls;

type
  TMsgForm = class(TForm)
    Memo: TMemo;
    MsgMain: TMainMenu;
    Messages1: TMenuItem;
    Clear1: TMenuItem;
    N1: TMenuItem;
    Hidethiswindow1: TMenuItem;
    procedure Clear1Click(Sender: TObject);
    procedure Hidethiswindow1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    MaxMsgs:Integer;
    Procedure SetMaxMsgs(n:Integer);
  public
    { Public declarations }
    Procedure AddMessage(const msg:String);
    Property MaxMessages:Integer read MaxMsgs write SetMaxMsgs;
  end;

var
  MsgForm: TMsgForm;

implementation

{$R *.DFM}

procedure TMsgForm.Clear1Click(Sender: TObject);
begin
 Memo.Lines.Clear;
end;

procedure TMsgForm.Hidethiswindow1Click(Sender: TObject);
begin
 Visible:=false;
end;

Procedure TMsgForm.SetMaxMsgs(n:Integer);
begin
 MaxMsgs:=n;
end;

Procedure TMsgForm.AddMessage(const msg:String);
var n:Integer;
begin
 n:=Memo.Lines.Count;
 if n>=MaxMsgs then Memo.Lines.Delete(n-1);
 Memo.Lines.Insert(0,msg);
end;

procedure TMsgForm.FormCreate(Sender: TObject);
begin
 MaxMessages:=1000;
end;

end.
