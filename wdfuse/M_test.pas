unit M_test;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, _3dmath, Buttons;

type
  TTestWindow = class(TForm)
    Memo: TMemo;
    BitBtn1: TBitBtn;
    CBUseWinG: TCheckBox;
    BitBtn2: TBitBtn;
    procedure BitBtn1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  TestWindow: TTestWindow;
  M,N,I     : TMATRIX4;

implementation

{$R *.DFM}

procedure TTestWindow.BitBtn1Click(Sender: TObject);
var i,j,k      : Word;
begin
 {WinG test}

end;

end.


(*
 {MATRIX TEST}
 M4_AssignUnity(M);
 M[0,0] := 2;
 M[0,1] := 1;
 M[0,2] := 17;
 M[0,3] := 3;
 M[1,0] := 12;
 M[1,1] := 2;
 M[1,2] := 5;
 M[1,3] := 23;
 M[2,0] := 3;
 M[2,1] := 19;
 M[2,2] := 2;
 M[2,3] := -5;
 M[3,0] := 6;
 M[3,1] := 16;
 M[3,2] := 1;
 M[3,3] := -4;

 Memo.Clear;
 for i := 0 to 3 do Memo.Lines.Add(M4_DisplayALine(M,i));
 Memo.Lines.Add('');

 Memo.Lines.Add(Format('Det = %10.3f' , [M4_Determinant(M)]));
 Memo.Lines.Add('');

 M4_AssignM4(N,M);
 M4_Invert(N);
 for i := 0 to 3 do Memo.Lines.Add(M4_DisplayALine(N,i));
 Memo.Lines.Add('');

 M4_PostMultiplyByM4(M,N);
 for i := 0 to 3 do Memo.Lines.Add(M4_DisplayALine(M,i));
 Memo.Lines.Add('');
 *)
