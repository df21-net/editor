unit VUE_util;

interface
 uses Grids, SysUtils, ExtCtrls, vuecreat, M_global, _strings;

 procedure CheckData(var Data: TStringGrid; var Panel: TPanel; var error: boolean);
 procedure ClearCells(FirstFrame : integer; LastFrame : integer);
 procedure FormatNumbers(LastFrame: integer; var Data: TStringGrid);
 procedure SaveData(Filename  : string;     Data : TStringGrid);
 function  LoadData(Filename  : string; var Data : TStringGrid) : Boolean;
 procedure CreateVUE(Filename : string;     Data : TStringGrid);

implementation

{****************************************************************************}

procedure CheckData(var Data: TStringGrid; var Panel: TPanel; var error: boolean);
var i, a, b, c, d, LastFrame, Code : integer;
    Value: real;
    S: string;
begin
 error := False;

 {Determine last frame ...........}
 i := 0;
 repeat
  i := i + 1;
 until (Data.Cells[1, i] = '') or (i = 10001);
 LastFrame := i - 1;

 {Begin Checking ...............}
 if LastFrame > 0 then
  BEGIN
   for a := 1 to LastFrame do
    BEGIN {ID Checks}
     if length(Data.Cells[1, a]) > 15 then
      begin
       Panel.Caption := 'Error: ID too long (Max 15 characters)';
       Data.Col := 1;
       Data.Row := a;
       error := True;
       Break;
      end;
     if Pos(' ', Data.Cells[1, a]) <> 0 then
      begin
       Panel.Caption := 'Error: ID contains space';
       Data.Col := 1;
       Data.Row := a;
       error := True;
       Break;
      end;
    END;

   if error <> True then
     for c := 1 to LastFrame do
      BEGIN {Scale Checks}
       val(Data.Cells[2, c], Value, code);
       if code <> 0 then
        begin
         Panel.Caption := 'Error: Invalid number';
         Data.Col := 2;
         Data.Row := c;
         error := True;
         Break;
        end;
       if Value <= 0 then
        begin
         Panel.Caption := 'Error: Scale must be greater than 0';
         Data.Col := 2;
         Data.Row := c;
         error := True;
         Break;
        end;
      END;

   if error <> True then
     for b := 3 to 5 do
      begin {Orientation (P, Y, R) Checks}
       for c := 1 to LastFrame do
        BEGIN
         val(Data.Cells[b, c], Value, code);
         if code <> 0 then
          begin
           Panel.Caption := 'Error: Invalid number';
           Data.Col := b;
           Data.Row := c;
           error := True;
           Break;
          end;
         if (Value < 0) or (Value >= 360) then
          begin
           Panel.Caption := 'Error: Angle must be >= 0 and < 360';
           Data.Col := b;
           Data.Row := c;
           error := True;
           Break;
          end;
        END;
       if error then Break;
      end;

   if error <> True then
     for b := 6 to 8 do
      begin {Coordinate (X, Y, Z) Checks}
       for c := 1 to LastFrame do
        BEGIN
         val(Data.Cells[b, c], Value, code);
         if code <> 0 then
          begin
           Panel.Caption := 'Error: Invalid number';
           Data.Col := b;
           Data.Row := c;
           error := True;
           Break;
          end;
        END;
       if error then Break;
      end;

   if not error then
    Panel.Caption := 'No Errors';
  END;

end;

{****************************************************************************}

procedure ClearCells(FirstFrame : integer; LastFrame : integer);
var a, b: integer;
begin
 for a := FirstFrame to LastFrame do
  for b := 1 to 8 do
   if VUECreator.DataGrid.Cells[b, a] <> '' then VUECreator.DataGrid.Cells[b, a] := '';
end;

{****************************************************************************}

procedure FormatNumbers(LastFrame: integer; var Data: TStringGrid);
var a, b, i, Code : integer;
    Num : real;
    Strin : string;
begin
 for a := 2 to 8 do
  for b := 1 to LastFrame do
   begin
    val(Data.Cells[a, b], Num, Code);
    str(Num : 0 : 2, Strin);
    Data.Cells[a, b] := Strin;
   end;
end;

{****************************************************************************}

procedure SaveData(Filename : string; Data : TStringGrid);
var VSDFile : TextFile;
    a, i, LastFrame : integer;
    TempString: string;
begin
 {Determine last frame ...........}
 i := 0;
 repeat
  i := i + 1;
 until (Data.Cells[1, i] = '') or (i = 10001);
 LastFrame := i - 1;

 FormatNumbers(LastFrame, Data);

 {Open VSD file and write data .............}
 AssignFile(VSDFile, Filename);
 Rewrite(VSDFile);

 Writeln(VSDFile, '# VUE Source Data File');
 Writeln(VSDFile, '#');
 Writeln(VSDFile, '# Created by WDFUSE '+ WDFUSE_VERSION + ' on ' + DateTimeToStr(Date + Time));
 Writeln(VSDFile, '#');
 Writeln(VSDFile, '# WDFUSE is (c) Yves BORCKMANS, Alexei NOVIKOV, David LOVEJOY,');
 Writeln(VSDFile, '# Jereth KOK, Frank KRUEGER 1995-1997');
 Writeln(VSDFile, '#');
 Writeln(VSDFile, '# AUTHOR: ', USERname);
 Writeln(VSDFile, '# EMAIL:  ', USERemail);
 Writeln(VSDFile, '');
 Writeln(VSDFile, '');
 Writeln(VSDFile, '# <ID>             <Scale>  <Pitch> <Yaw>   <Roll>  <X>        <Y>        <Z>');
 Writeln(VSDFile, '');

 for a := 1 to LastFrame do
  begin
   TempString := Data.Cells[1, a] + Spaces(17 - length(Data.Cells[1, a])) +
                 Data.Cells[2, a] + Spaces(9 - length(Data.Cells[2, a])) +
                 Data.Cells[3, a] + Spaces(8 - length(Data.Cells[3, a])) +
                 Data.Cells[4, a] + Spaces(8 - length(Data.Cells[4, a])) +
                 Data.Cells[5, a] + Spaces(8 - length(Data.Cells[5, a])) +
                 Data.Cells[6, a] + Spaces(11 - length(Data.Cells[6, a])) +
                 Data.Cells[7, a] + Spaces(11 - length(Data.Cells[7, a])) +
                 Data.Cells[8, a];

   Writeln(VSDFile, '  ' + TempString);
  end;

 CloseFile(VSDFile);
end;

{****************************************************************************}

function LoadData(Filename : string; var Data : TStringGrid) : Boolean;
var VSDFile : TextFile;
    TempString, TempValue: string;
    F, L, a, c, v : integer;
    Ignore : Boolean;
begin
 {Clear all cells}
 F := 1;
 L := 10000;
 ClearCells(F, L);

 {Open VSD file and write data .............}
 AssignFile(VSDFile, Filename);
 Reset(VSDFile);
 a := 0;
 Result := True;

 While not SeekEof(VSDFile) do
  BEGIN
   Readln(VSDFile, TempString);
   Ignore := False;
   if pos('#', TempString) = 1 then Ignore := True;
   if TempString = '' then Ignore := True;

   if not Ignore then
    begin
     a := a + 1;
     v := 1;

     for c := 1 to length(TempString) do
      if not (TempString[c] = ' ') then
       BEGIN
        if TempString[c - 1] = ' ' then v := v + 1;
        Data.Cells[v, a] := Data.Cells[v, a] + TempString[c];
       END;

     if v <> 8 then Result := False;
    end;
  END;

 Close(VSDFile);
end;

{****************************************************************************}

procedure CreateVUE(Filename : string; Data : TStringGrid);
var VUEFile : TextFile;
    a, i, LastFrame, Code : integer;
    TempString, ID, X, Y, Z,
    Val1, Val2, Val3, Val4, Val5, Val6, Val7, Val8, Val9 : string;
    Scale, Pitch, Yaw, Roll : Real;
begin
 {Determine last frame ...........}
 i := 0;
 repeat
  i := i + 1;
 until (Data.Cells[1, i] = '') or (i = 10001);
 LastFrame := i - 1;

 FormatNumbers(LastFrame, Data);

 {Open VUE file, perform calculations, and write data .............}
 AssignFile(VUEFile, Filename);
 Rewrite(VUEFile);

 Writeln(VUEFile, 'VUE 1');
 Writeln(VUEFile, '');
 Writeln(VUEFile, '/*');
 Writeln(VUEFile, 'Generated by WDFUSE '+ WDFUSE_VERSION + ' on ' + DateTimeToStr(Date + Time));
 Writeln(VUEFile, '');
 Writeln(VUEFile, 'WDFUSE is (c) Yves BORCKMANS, Alexei NOVIKOV, David LOVEJOY,');
 Writeln(VUEFile, 'Jereth KOK, Frank KRUEGER 1995-1997');
 Writeln(VUEFile, '');
 Writeln(VUEFile, 'AUTHOR: ', USERname);
 Writeln(VUEFile, 'EMAIL:  ', USERemail);
 Writeln(VUEFile, '*/');
 Writeln(VUEFile, '');

 for a := 1 to LastFrame do
  begin
   ID := '"' + Data.Cells[1, a] + '" ';
   val(Data.Cells[2, a], Scale, Code);
   val(Data.Cells[3, a], Pitch, Code);
   val(Data.Cells[4, a], Yaw,   Code);
   val(Data.Cells[5, a], Roll,  Code);
   X := Data.Cells[6, a];
   Y := Data.Cells[7, a];
   Z := Data.Cells[8, a];

   Pitch := Pitch * Pi / 180;
   Yaw := Yaw * Pi / 180;
   Roll := Roll * Pi / 180;

   Str(Scale * (cos(Yaw) * cos(Roll)) : 0 : 4, Val1);
   Str(Scale * (-sin(Yaw) * cos(Pitch) + cos(Yaw) * sin(Roll) * sin(Pitch)) : 0 : 4, Val2);
   Str(Scale * (-sin(Yaw) * sin(Pitch) - cos(Yaw) * sin(Roll) * cos(Pitch)) : 0 : 4, Val3);
   Str(Scale * (sin(Yaw) * cos(Roll)) : 0 : 4, Val4);
   Str(Scale * (cos(Yaw) * cos(Pitch) + sin(Yaw) * sin(Roll) * sin(Pitch)) : 0 : 4, Val5);
   Str(Scale * (cos(Yaw) * sin(Pitch) - sin(Yaw) * sin(Roll) * cos(Pitch)) : 0 : 4, Val6);
   Str(Scale * (sin(Roll)) : 0 : 4, Val7);
   Str(Scale * (-cos(Roll) * sin(Pitch)) : 0 : 4, Val8);
   Str(Scale * (cos(Roll) * cos(Pitch)) : 0 : 4, Val9);

   TempString := 'transform ' + ID + Val1 + ' ' + Val2 + ' ' +
                 Val3 + ' ' + Val4 + ' ' + Val5 + ' ' + Val6 + ' ' +
                 Val7 + ' ' + Val8 + ' ' + Val9 + ' ' + X + ' ' +
                 Z + ' ' + Y;

   Writeln(VUEFile, TempString);
  end;

 Close(VUEFile);
end;


end.

