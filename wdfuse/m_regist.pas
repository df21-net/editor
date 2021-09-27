unit M_regist;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, M_Global, Dialogs;

type
  TRegisterWindow = class(TForm)
    Memo1: TMemo;
    OKButton: TBitBtn;
    procedure OKBtnClick(Sender: TObject);
   
   
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  RegisterWindow: TRegisterWindow;

implementation
uses Mapper;

{$R *.DFM}

procedure TRegisterWindow.OKBtnClick(Sender: TObject);
begin
 USERname  := 'DF-21.NET';
 USERemail := 'DF21.NET@GMAIL.COM';
 USERreg   := '0000';
 Ini.WriteString('REGISTRATION', 'Name',  USERname);
 Ini.WriteString('REGISTRATION', 'email', USERemail);
 Ini.WriteString('REGISTRATION', 'Reg',   USERreg);

 if IsRegistered then
  begin
   Application.MessageBox('Registration Accepted. Thanks again !',
                        'WDFUSE - Register Dialog',
                        mb_Ok or mb_IconInformation);
   RegisterWindow.ModalResult := mrOk;
  end
 else
  begin
   Application.MessageBox('Invalid Registration #',
                        'WDFUSE - Register Dialog',
                        mb_Ok or mb_IconExclamation);
  end;
end;

end.
