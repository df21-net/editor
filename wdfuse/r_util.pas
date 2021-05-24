unit R_util;

interface
uses SysUtils, Graphics, WinTypes, WinProcs, StdCtrls, ExtCtrls, Classes,
     G_Util, Forms, Messages, Dialogs,
     _undoc, _files, _strings, M_Global;

function BMSetTransparent(BMName : String; TransparentValue : Byte) : Boolean;

function DELTGetOffsets(DELTName : String; VAR X, Y : Integer) : Boolean;
function DELTSetOffsets(DELTName : String; X, Y : Integer) : Boolean;

function FMEGetInserts(FMEName : String; VAR X, Y : LongInt) : Boolean;
function FMESetInserts(FMEName : String; X, Y : LongInt) : Boolean;
function FMESetFlip(FMEName : String; IsFlip : Boolean) : Boolean;

implementation

function BMSetTransparent(BMName : String; TransparentValue : Byte) : Boolean;
var BMH    : TBM_HEADER;
    fbm    : Integer;
begin
 Result := FALSE;
 if not FileExists(BMname) then
  begin
   ShowMessage('Non existent BM in BMSetTransparent !');
   exit;
  end;

 Result := TRUE;
 fbm  := FileOpen(BMname, fmOpenRead);
 FileRead(fbm, BMH, SizeOf(TBM_HEADER));
 FileClose(fbm);

 BMH.Transparent := TransparentValue;

 fbm := FileOpen(BMname, fmOpenWrite);
 FileWrite(fbm, BMH, SizeOf(TBM_HEADER));
 FileClose(fbm);
end;

{**************************************************************************}

function DELTGetOffsets(DELTName : String; VAR X, Y : Integer) : Boolean;
var DH     : TDELTH;
    fd     : Integer;
begin
 Result := FALSE;
 if not FileExists(DELTname) then
  begin
   X := 0;
   Y := 0;
   ShowMessage('Non existent DELT in DELTGetOffsets !');
   exit;
  end;

 Result := TRUE;
 fd  := FileOpen(DELTname, fmOpenRead);
 FileRead(fd, DH, SizeOf(TDELTH));
 FileClose(fd);

 X := DH.OffsX;
 Y := DH.OffsY;
end;

function DELTSetOffsets(DELTName : String; X, Y : Integer) : Boolean;
var DH     : TDELTH;
    fd     : Integer;
begin
 Result := FALSE;
 if not FileExists(DELTname) then
  begin
   ShowMessage('Non existent DELT in DELTSetOffsets !');
   exit;
  end;

 Result := TRUE;
 fd  := FileOpen(DELTname, fmOpenRead);
 FileRead(fd, DH, SizeOf(TDELTH));
 FileClose(fd);

 DH.OffsX := X;
 DH.OffsY := Y;

 fd  := FileOpen(DELTname, fmOpenWrite);
 FileWrite(fd, DH, SizeOf(TDELTH));
 FileClose(fd);
end;

{**************************************************************************}

function FMEGetInserts(FMEName : String; VAR X, Y : LongInt) : Boolean;
var FH     : TFME_HEADER1;
    ff     : Integer;
begin
 Result := FALSE;
 if not FileExists(FMEname) then
  begin
   X := 0;
   Y := 0;
   ShowMessage('Non existent FME in FMEGetInserts !');
   exit;
  end;

 Result := TRUE;
 ff  := FileOpen(FMEname, fmOpenRead);
 FileRead(ff, FH, SizeOf(TFME_HEADER1));
 FileClose(ff);

 X := FH.InsertX;
 Y := FH.InsertY;
end;

function FMESetInserts(FMEName : String; X, Y : LongInt) : Boolean;
var FH     : TFME_HEADER1;
    ff     : Integer;
begin
 Result := FALSE;
 if not FileExists(FMEname) then
  begin
   ShowMessage('Non existent FME in FMESetInserts !');
   exit;
  end;

 Result := TRUE;
 ff  := FileOpen(FMEname, fmOpenRead);
 FileRead(ff, FH, SizeOf(TFME_HEADER1));
 FileClose(ff);

 FH.InsertX := X;
 FH.InsertY := Y;

 ff  := FileOpen(FMEname, fmOpenWrite);
 FileWrite(ff, FH, SizeOf(TFME_HEADER1));
 FileClose(ff);
end;

function FMESetFlip(FMEName : String; IsFlip : Boolean) : Boolean;
var FH   : TFME_HEADER1;
    ff   : Integer;
begin
 Result := FALSE;
 if not FileExists(FMEname) then
  begin
   ShowMessage('Non existent FME in FMESetFlip !');
   exit;
  end;

 Result := TRUE;
 ff  := FileOpen(FMEname, fmOpenRead);
 FileRead(ff, FH, SizeOf(TFME_HEADER1));
 FileClose(ff);

 if IsFlip then
  begin
   if FH.Flip = 1 then
    begin
     Application.MessageBox('FME is already Flipped',
                            'WDFUSE Toolkit - FMESetFlip',
                            mb_Ok or mb_IconInformation);
     exit;
    end
   else
    begin
     {set it transparent}
     FH.Flip := 1;
    end;
  end
 else
  begin
   if FH.Flip = 1 then
    begin
     {set it opaque}
     FH.Flip := 0;
    end
   else
    begin
     Application.MessageBox('FME is not Flipped',
                            'WDFUSE Toolkit - FMESetFlip',
                            mb_Ok or mb_IconInformation);
     exit;
    end;
  end;

 ff := FileOpen(FMEname, fmOpenWrite);
 FileWrite(ff, FH, SizeOf(TFME_HEADER1));
 FileClose(ff);
end;

{**************************************************************************}

end.
