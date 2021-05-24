unit M_wadsut;

interface
uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, FileCtrl, ExtCtrls, Dialogs, SysUtils, IniFiles,
  M_Global, _files, _strings, M_Util, M_MapUt, M_mapfun;


function  GetNearAltitude(sc : Integer; asked : String) : Real;
function  GetNearAmbient(sc : Integer; asked : String) : Integer;

function  GetTaggedSector(tag : Integer) : Integer;
function  GetNextTaggedSector(tag, current : Integer) : Integer;

{those are used in the conversion, not useful anywhere else}
function  GetFirstUncheckedWall : Integer;
function  GetWallWithCycle(cy : Integer) : Integer;
function  GetWallBeginningWith(vx : Integer) : Integer;

implementation

function  GetNearAltitude(sc : Integer; asked : String) : Real;
var TheSector  : TSector;
    TheSector2 : TSector;
    TheWall    : TWall;
    wl         : Integer;
    TheFloor   : Real;
    TheCeiling : Real;
    Numeric    : Real;
    Code       : Integer;
begin
 {check for numerical values
  the stops construction part must add this to increment the floor altitudes}
 Val(asked, Numeric, code);
 if code = 0 then
  begin
   Result := Numeric;
   exit;
  end;

 TheSector  := TSector(MAP_SEC.Objects[sc]);
 TheFloor   := TheSector.Floor_alt;
 TheCeiling := TheSector.Ceili_alt;

 if (asked = 'FLO') then
  begin
   Result := TheFloor;
   exit;
  end;

 if (asked = 'FL1') then
  begin
   Result := TheFloor + 1;
   exit;
  end;

 if (asked = 'CEI') then
  begin
   Result := TheCeiling;
   exit;
  end;

 if (asked = 'SLX') then
  begin
   Result := TheFloor + 4; {wrong, but approximation...}
   exit;
  end;

 {initialize Result}
 if (asked = 'LHC') or
    (asked = 'LLC') or
    (asked = 'LHF') or
    (asked = 'LLF') then
  Result := 999999;

 if (asked = 'HHC') or
    (asked = 'HLC') or
    (asked = 'HHF') or
    (asked = 'HL1') or
    (asked = 'HLF') then
  Result := -999999;

 for wl := 0 to TheSector.Wl.Count - 1 do
  begin
   TheWall    := TWall(TheSector.Wl.Objects[wl]);
   if TheWall.Adjoin <> -1 then
    begin
     TheSector2 := TSector(MAP_SEC.Objects[TheWall.Adjoin]);

     if (asked = 'LHC') or (asked = 'LH1') then
      if TheSector2.Ceili_alt > TheCeiling then
       if TheSector2.Ceili_alt < Result then
        Result := TheSector2.Ceili_alt;

     if asked = 'LLC' then
      if TheSector2.Ceili_alt < TheCeiling then
       if TheSector2.Ceili_alt < Result then
        Result := TheSector2.Ceili_alt;

     if asked = 'HHC' then
      if TheSector2.Ceili_alt > TheCeiling then
       if TheSector2.Ceili_alt > Result then
        Result := TheSector2.Ceili_alt;

     if asked = 'HLC' then
      if TheSector2.Ceili_alt < TheCeiling then
       if TheSector2.Ceili_alt > Result then
        Result := TheSector2.Ceili_alt;

     if asked = 'LHF' then
      if TheSector2.Floor_alt > TheFloor then
       if TheSector2.Floor_alt < Result then
        Result := TheSector2.Floor_alt;

     if asked = 'LLF' then
      if TheSector2.Floor_alt < TheFloor then
       if TheSector2.Floor_alt < Result then
        Result := TheSector2.Floor_alt;

     if asked = 'HHF' then
      if TheSector2.Floor_alt > TheFloor then
       if TheSector2.Floor_alt > Result then
        Result := TheSector2.Floor_alt;

     if (asked = 'HLF') or (asked = 'HL1') then
      if TheSector2.Floor_alt < TheFloor then
       if TheSector2.Floor_alt > Result then
        Result := TheSector2.Floor_alt;

    end;
  end;


 {so the nothing found value is always 999999}
 if Result = -999999 then Result := 999999;

 if Result <> 999999 then
  begin
   {finalize}
   if asked = 'HL1' then Result := Result + 1;
   if asked = 'LH1' then Result := Result - 1;
  end
 else
  begin
   {special cases}
  end;

end;


function  GetNearAmbient(sc : Integer; asked : String) : Integer;
var TheSector  : TSector;
    TheSector2 : TSector;
    TheWall    : TWall;
    wl         : Integer;
    TheLight   : Integer;
    Numeric    : Integer;
    code       : Integer;
begin
 {check for numerical values}
 Val(asked, Numeric, code);
 if code = 0 then
  begin
   Result := Numeric;
   exit;
  end;

 TheSector  := TSector(MAP_SEC.Objects[sc]);
 TheLight   := TheSector.Ambient;

 if (asked = 'LIG') then
  begin
   Result := TheLight;
   exit
  end;

 {initialize Result}
 if (asked = 'BRI') then
  Result := -1;

 if (asked = 'DIM') then
  Result := 99;

 for wl := 0 to TheSector.Wl.Count - 1 do
  begin
   TheWall    := TWall(TheSector.Wl.Objects[wl]);
   if TheWall.Adjoin <> -1 then
    begin
     TheSector2 := TSector(MAP_SEC.Objects[TheWall.Adjoin]);

     if (asked = 'BRI') then
       if TheSector2.Ambient > Result then
        Result := TheSector2.Ambient;

     if (asked = 'DIM') then
       if TheSector2.Ambient < Result then
        Result := TheSector2.Ambient;
    end;
  end;

 {adjust for problems}
 if Result = -1 then Result := TheLight;
 if Result = 99 then Result := 0;
end;


function GetTaggedSector(tag : Integer) : Integer;
var sc          : Integer;
    TheSector   : TSector;
begin
 Result := -1;
 for sc := 0 to MAP_SEC.Count - 1 do
  begin
   TheSector := TSector(MAP_SEC.Objects[sc]);
   if TheSector.Floor.i = tag then
    begin
     Result := sc;
     break;
    end;
  end;
end;


function GetNextTaggedSector(tag, current : Integer) : Integer;
var sc          : Integer;
    TheSector   : TSector;
begin
 Result := -1;
 for sc := current + 1 to MAP_SEC.Count - 1 do
  begin
   TheSector := TSector(MAP_SEC.Objects[sc]);
   if TheSector.Floor.i = tag then
    begin
     Result := sc;
     break;
    end;
  end;
end;


{those are used in the conversion, not useful anywhere else}
function  GetFirstUncheckedWall : Integer;
var i : Integer;
    TheWall : TWall;
begin
 Result := -1;
 for i := 0 to tmpWalls.Count - 1 do
  begin
    TheWall := TWall(tmpWalls.Objects[i]);
    if TheWall.Cycle = -1 then
     begin
      Result := i;
      break;
     end;
  end;
end;

function  GetWallWithCycle(cy : Integer) : Integer;
var i : Integer;
    TheWall : TWall;
begin
 Result := -1;
 for i := 0 to tmpWalls.Count - 1 do
  begin
    TheWall := TWall(tmpWalls.Objects[i]);
    if TheWall.Cycle = cy then
     begin
      Result := i;
      break;
     end;
  end;
end;

function  GetWallBeginningWith(vx : Integer) : Integer;
var i : Integer;
    TheWall : TWall;
begin
 Result := -1;
 for i := 0 to tmpWalls.Count - 1 do
  begin
    TheWall := TWall(tmpWalls.Objects[i]);
    if TheWall.Cycle = -1 then
    if TheWall.Left_vx = vx then
     begin
      Result := i;
      break;
     end;
  end;
end;

end.
