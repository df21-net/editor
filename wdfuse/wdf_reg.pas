program Wdf_reg;

uses WinCrt, SysUtils;
var reg1,
    reg2     : LongInt;
    bidon    : LongInt;
    i        : Integer;
    USERname : String;
begin
WriteLn('*****************************************');
WriteLn('* WDFUSE Registration Numbers Generator *');
WriteLn('* (c) Yves Borckmans 1995               *');
WriteLn('*****************************************');
WriteLn;
Bidon := 1;

Write('Enter USER Name (>5 chars): ');
Readln(USERName);

WriteLn;
WriteLn('USERname to crypt is      : ', USERname);

if Length(Username)< 6 then
 WriteLn('                            !!!!!  TOO SHORT  !!!!!');

reg1 := Bidon * Byte(USERname[1]) * Byte(USERname[2]) * Byte(USERname[3])+
        Bidon * Byte(USERname[4]) * Byte(USERname[5]) * Byte(USERname[6])+
        10000;
WriteLn('c1*c2*c3+c4*c5*c6 + 10000 : ', reg1);
for i := 1 to Length(USERname) do reg1 := reg1 + Byte(Username[i]);
WriteLn('+ letters (1->len(name))  : ', reg1);
reg1 := reg1 mod 99997;
WriteLn('mod 99997                 : ', reg1);
WriteLn;

reg2 := Bidon * Byte(USERname[1]) * Byte(USERname[3]) * Byte(USERname[5])+
        Bidon * Byte(USERname[2]) * Byte(USERname[4]) * Byte(USERname[6])+
        10000;
WriteLn('c1*c3*c5+c2*c4*c6 + 10000 : ', reg2);
for i := 2 to Length(USERname) do reg2 := reg2 + Byte(Username[i]);
WriteLn('+ letters (2->len(name))  : ', reg2);
reg2 := reg2 mod 99993;
WriteLn('mod 99993                 : ', reg2);

WriteLn;
WriteLn(Format('WDFUSE Registration       : %5d%5d', [reg1, reg2]));

end.

