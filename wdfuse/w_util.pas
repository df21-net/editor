unit W_util;

interface
uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Buttons, StdCtrls, ExtCtrls, IniFiles, M_Global;

CONST
  WAD_SIZE_THING               =   10;  { Length of THING   record }
  WAD_SIZE_VERTEX              =    4;  { Length of VERTEX  record }
  WAD_SIZE_LINEDEF             =   14;  { Length of LINEDEF record }
  WAD_SIZE_SIDEDEF             =   30;  { Length of SIDEDEF record }
  WAD_SIZE_SECTOR              =   26;  { Length of SECTOR  record }

  WAD_LDF_NOTHINGCANCROSS      =   1;   { Linedef flags }
  WAD_LDF_ENNEMIESCANNOTCROSS  =   2;
  WAD_LDF_TWOSIDED             =   4;
  WAD_LDF_UPPERTXNOTPEGGED     =   8;
  WAD_LDF_LOWERTXNOTPEGGED     =  16;
  WAD_LDF_SECRET               =  32;
  WAD_LDF_SOUNDCANNOTCROSS     =  64;
  WAD_LDF_NEVERSHOWSONMAP      = 128;
  WAD_LDF_ALWAYSSHOWSONMAP     = 256;

TYPE
WAD_BEGIN = class                     { Beginning of xWAD file record       }
  WAD_MAGIC : array[0..4] of Char;    { can be 'IWAD' or 'PWAD'             }
  MASTERN   : LongInt;                { Number of Master Index Entries      }
  MASTERX   : LongInt;                { Offset of Master Index start in WAD }
end;

WAD_IX_ENTRY = class                  { One Entry in the Master Index       }
  IX        : LongInt;                { Index in WAD file of resource       }
  LEN       : LongInt;                { Length of resource                  }
  NAME      : array[0..8] of Char;    { Resource name                       }
                                      { This is one more than the reality,  }
                                      { we will force the last byte to #0,  }
                                      { so we'll always have ASCII0 strings }
end;

TWAD_VERTEX   = class
  X           : Integ16;
  Y           : Integ16;
end;

TWAD_LINEDEF  = class
  VERTEX1     : Integ16;              {}
  VERTEX2     : Integ16;              {}
  FLAGS       : Integ16;              {}
  ACTION      : Byte;                 {}
  filler      : Byte;
  TAG         : Integ16;              {}
  SIDEDEF1    : Integ16;              {}
  SIDEDEF2    : Integ16;              {}
end;

TWAD_SIDEDEF  = class
  X_OFFSET    : Integ16;              {}
  Y_OFFSET    : Integ16;              {}
  TX_UPPER    : array[0..8] of Char;  { This is one more than the reality }
  TX_LOWER    : array[0..8] of Char;  { This is one more than the reality }
  TX_MAIN     : array[0..8] of Char;  { This is one more than the reality }
  SECTOR      : Integ16;              {}
end;

TWAD_SECTOR   = class
  H_FLOOR     : Integ16;              {}
  H_CEILI     : Integ16;              {}
  TX_FLOOR    : array[0..8] of Char;  { This is one more than the reality }
  TX_CEILI    : array[0..8] of Char;  { This is one more than the reality }
  LIGHT       : Byte;                 {}
  filler1     : Byte;
  STYPE       : Byte;                 {}
  filler2     : Byte;
  TAG         : Integ16;              {}
end;

TWAD_THING    = class
  X           : Integ16;              {}
  Y           : Integ16;              {}
  FACING      : Integ16;              {}
  ID          : Integ16;              {}
  FLAGS       : Integ16;              {}
end;

function  IsWAD(TheWad : TFileName) : Boolean;
procedure GetWADDir(TheWad : TFileName;  TheDir : TStringList);
procedure GetWADMaps(TheWad : TFileName;  TheDir : TStrings);

function  GetWADEntryInfo(TheWad : TFileName; TheMap : String; TheRes :String;
                          VAR IX, LEN : LongInt) : Boolean;

implementation

function  IsWAD(TheWad : TFileName) : Boolean;
var    fw : Integer;
       wb : WAD_BEGIN;
begin
 wb := WAD_BEGIN.Create;
 fw := FileOpen(TheWad, fmOpenRead);
 FileRead(fw, wb.WAD_MAGIC, 4);
 wb.WAD_MAGIC[4] := #0;

 Result := (StrComp(wb.WAD_MAGIC, 'IWAD') = 0) or (StrComp(wb.WAD_MAGIC, 'PWAD') = 0);

 wb.Free;
 FileClose(fw);
end;

procedure GetWADDir(TheWad : TFileName;  TheDir : TStringList);
var    fw : Integer;
       i  : LongInt;
       wb : WAD_BEGIN;
       wx : WAD_IX_ENTRY;
begin
 TheDir.Clear;

 wb := WAD_BEGIN.Create;
 fw := FileOpen(TheWad, fmOpenRead);
 FileRead(fw, wb.WAD_MAGIC, 4);
 wb.WAD_MAGIC[4] := #0;
 FileRead(fw, wb.MASTERN, 8);
 FileSeek(fw, wb.MASTERX, 0);

 for i := 0 to wb.MASTERN - 1 do
  begin
   wx := WAD_IX_ENTRY.Create;
   FileRead(fw, wx.IX, 4);
   FileRead(fw, wx.LEN, 4);
   FileRead(fw, wx.NAME, 8);
   wx.NAME[8] := #0;
   TheDir.AddObject(StrPas(wx.NAME), wx);
  end;

 wb.Free;
 FileClose(fw);
end;

procedure GetWADMaps(TheWad : TFileName;  TheDir : TStringS);
var    fw : Integer;
       i  : LongInt;
       wb : WAD_BEGIN;
       wx : WAD_IX_ENTRY;
       pas    : String;
begin
 TheDir.Clear;

 wb := WAD_BEGIN.Create;
 fw := FileOpen(TheWad, fmOpenRead);
 FileRead(fw, wb.WAD_MAGIC, 4);
 wb.WAD_MAGIC[4] := #0;
 FileRead(fw, wb.MASTERN, 8);
 FileSeek(fw, wb.MASTERX, 0);

 for i := 0 to wb.MASTERN - 1 do
  begin
   wx := WAD_IX_ENTRY.Create;
   FileRead(fw, wx.IX, 8);
   FileRead(fw, wx.NAME, 8);
   wx.NAME[8] := #0;
   pas := Strpas(wx.NAME);

   {Doom, Heretic}
   if (pas[1] = 'E') and (pas[3] = 'M') and (Copy(pas,1,4) <> 'MAPE') then
    begin
     TheDir.AddObject(pas, wx);
    end;
   {Doom II, Hexen}
   if (Copy(pas, 1, 3) = 'MAP') and (pas <> 'MAPINFO') then
    begin
     TheDir.AddObject(pas, wx);
    end;
  end;

 wb.Free;
 FileClose(fw);
end;


function  GetWADEntryInfo(TheWad : TFileName; TheMap : String; TheRes :String;
                          VAR IX, LEN : LongInt) : Boolean;
var    fw : Integer;
       i  : LongInt;
       wb : WAD_BEGIN;
       wx : WAD_IX_ENTRY;
       foundmap : Boolean;
       foundres : Boolean;
       pas    : String;
begin
 wb := WAD_BEGIN.Create;
 fw := FileOpen(TheWad, fmOpenRead);
 FileRead(fw, wb.WAD_MAGIC, 4);
 wb.WAD_MAGIC[4] := #0;
 FileRead(fw, wb.MASTERN, 8);
 FileSeek(fw, wb.MASTERX, 0);

 FoundMap := FALSE;
 FoundRes := FALSE;

 for i := 0 to wb.MASTERN - 1 do
  begin
   wx := WAD_IX_ENTRY.Create;
   FileRead(fw, wx.IX, 8);
   FileRead(fw, wx.NAME, 8);
   wx.NAME[8] := #0;
   pas := Strpas(wx.NAME);
   if pas = TheMap then FoundMap := TRUE;
   if foundmap and (pas = TheRes) then
    begin
     IX  := wx.IX;
     LEN := wx.LEN;
     foundRes := TRUE;
     break;
    end;
  end;

 wb.Free;
 FileClose(fw);
 Result := foundmap and foundres;
end;

end.
