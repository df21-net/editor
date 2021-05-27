unit D_util;

interface
uses SysUtils, WinTypes, WinProcs, Messages, Classes,
     StdCtrls, FileCtrl, Forms, Dialogs,
     _Strings, _Files, M_Global, M_Util, G_Util, df2art, M_Progrs;

TYPE
TD3D_MAPHEADER     = record
 mapversion       : LongInt;      {should be 7}
 posx             : LongInt;
 posy             : LongInt;
 posz             : LongInt;      {Z coordinates are all shifted up 4}
 ang              : Integ16;      {All angles are from 0-2047, clockwise}
 cursectnum       : Integ16;      {Sector of starting point}
end;

TD3D_SECTOR        = class
 wallptr,
 wallnum          : Integ16;
 ceilingz,
 floorz           : LongInt;
 ceilingstat,
 floorstat        : Integ16;
 ceilingpicnum,
 ceilingheinum    : Integ16;
 ceilingshade     : Byte; {should be signed char ?}
 ceilingpal,
 ceilingxpanning,
 ceilingypanning  : Byte;
 floorpicnum,
 floorheinum      : Integ16;
 floorshade       : Byte; {should be signed char ?}
 floorpal,
 floorxpanning,
 floorypanning    : Byte;
 visibility,
 filler           : Byte;
 lotag,
 hitag,
 extra            : Integ16;
end;

{
wallptr - index to first wall of sector
wallnum - number of walls in sector
z's - z coordinate (height) of ceiling / floor at first point of sector
stat's
   bit 0: 1 = parallaxing, 0 = not                                 "P"
   bit 1: 1 = sloped, 0 = not
   bit 2: 1 = swap x&y, 0 = not                                    "F"
   bit 3: 1 = double smooshiness                                   "E"
   bit 4: 1 = x-flip                                               "F"
   bit 5: 1 = y-flip                                               "F"
   bit 6: 1 = Align texture to first wall of sector                "R"
   bits 7-15: reserved
picnum's - texture index into art file
heinum's - slope value (rise/run) (0-parallel to floor, 4096-45 degrees)
shade's - shade offset of ceiling/floor
pal's - palette lookup table number (0 - use standard colors)
panning's - used to align textures or to do texture panning
visibility - determines how fast an area changes shade relative to distance
filler - useless byte to make structure aligned
lotag, hitag, extra - These variables used by the game programmer only

MAX = 1024
}

TD3D_WALL          = class
 x,
 y                : LongInt;
 point2,
 nextwall,
 nextsector,
 cstat            : Integ16;
 picnum,
 overpicnum       : Integ16;
 shade            : Byte; {should be signed char ?}
 pal,
 xrepeat,
 yrepeat,
 xpanning,
 ypanning         : Byte;
 lotag,
 hitag,
 extra            : Integ16;
 DF_Sector,
 DF_Wall          : Integ16;
 DoubleWall       : Boolean;
end;

{
x, y: Coordinate of left side of wall, get right side from next wall's left side
point2: Index to next wall on the right (always in the same sector)
nextwall: Index to wall on other side of wall (-1 if there is no sector)
nextsector: Index to sector on other side of wall (-1 if there is no sector)
cstat:
   bit 0: 1 = Blocking wall (use with clipmove, getzrange)         "B"
   bit 1: 1 = bottoms of invisible walls swapped, 0 = not          "2"
   bit 2: 1 = align picture on bottom (for doors), 0 = top         "O"
   bit 3: 1 = x-flipped, 0 = normal                                "F"
   bit 4: 1 = masking wall, 0 = not                                "M"
   bit 5: 1 = 1-way wall, 0 = not                                  "1"
   bit 6: 1 = Blocking wall (use with hitscan / cliptype 1)        "H"
   bit 7: 1 = Transluscence, 0 = not                               "T"
   bit 8: 1 = y-flipped, 0 = normal                                "F"
   bit 9: 1 = Transluscence reversing, 0 = normal                  "T"
   bits 10-15: reserved
picnum - texture index into art file
overpicnum - texture index into art file for masked walls / 1-way walls
shade - shade offset of wall
pal - palette lookup table number (0 - use standard colors)
repeat's - used to change the size of pixels (stretch textures)
pannings - used to align textures or to do texture panning
lotag, hitag, extra - These variables used by the game programmer only

MAX = 8192
}

TD3D_SPRITE        = class
 x,
 y,
 z                : LongInt;
 cstat,
 picnum           : Integ16;
 shade            : Byte; {should be signed char ?}
 pal,
 clipdist,
 filler           : Byte;
 xrepeat,
 yrepeat          : Byte;
 xoffset,
 yoffset          : Byte; {should be signed char ?}
 sectnum,
 statnum          : Integ16;
 ang,
 owner,
 xvel,
 yvel,
 zvel             : Integ16;
 lotag,
 hitag,
 extra            : Integ16;
end;

{
x, y, z - position of sprite - can be defined at center bottom or center
cstat:
   bit 0: 1 = Blocking sprite (use with clipmove, getzrange)       "B"
   bit 1: 1 = transluscence, 0 = normal                            "T"
   bit 2: 1 = x-flipped, 0 = normal                                "F"
   bit 3: 1 = y-flipped, 0 = normal                                "F"
   bits 5-4: 00 = FACE sprite (default)                            "R"
             01 = WALL sprite (like masked walls)
             10 = FLOOR sprite (parallel to ceilings&floors)
   bit 6: 1 = 1-sided sprite, 0 = normal                           "1"
   bit 7: 1 = Real centered centering, 0 = foot center             "C"
   bit 8: 1 = Blocking sprite (use with hitscan / cliptype 1)      "H"
   bit 9: 1 = Transluscence reversing, 0 = normal                  "T"
   bits 10-14: reserved
   bit 15: 1 = Invisible sprite, 0 = not invisible
picnum - texture index into art file
shade - shade offset of sprite
pal - palette lookup table number (0 - use standard colors)
clipdist - the size of the movement clipping square (face sprites only)
filler - useless byte to make structure aligned
repeat's - used to change the size of pixels (stretch textures)
offset's - used to center the animation of sprites
sectnum - current sector of sprite
statnum - current status of sprite (inactive/monster/bullet, etc.)

ang - angle the sprite is facing
owner, xvel, yvel, zvel, lotag, hitag, extra - These variables used by the
                                               game programmer only

MAX = 4096
}

(* MAP LOADING/SAVING PLAN

      // map header

      //Load all sectors
   read(fil,&numsectors,2);
   read(fil,&sector[0],sizeof(sectortype)*numsectors);

      //Load all walls
   read(fil,&numwalls,2);
   read(fil,&wall[0],sizeof(walltype)*numwalls);

      //Load all sprites

   read(fil,&numsprites,2);
   read(fil,&sprite[0],sizeof(spritetype)*numsprites);
*)

TYPE
 TTILENUM = class
  num : Integ16;
 end;

VAR
 DUKE_MAP_HEADER  : TD3D_MAPHEADER;

 DUKE_SECTORS     : TStringList;
 DUKE_WALLS       : TSTringList;
 DUKE_SPRITES     : TStringList;

 DUKE_TX_LIST     : TStringList;

 DUKE_NUMSECTORS,
 DUKE_NUMWALLS,
 DUKE_NUMSPRITES  : Integ16;

 DA               : TDukeArtTiles;

procedure SaveAsDukeMap(mapname : String);

function  GetDukeTileNum(tilename : String) : Integ16;

function  FillDukeHeader(mapname : String) : Boolean;
Function FillDukeStuff:boolean;
procedure WriteDukeStuff(mapname : String);
procedure FreeDukeStuff;
procedure GeneratePaletteDotDat(dirname : String);

implementation
uses M_Duke;

procedure SaveAsDukeMap(mapname : String);
begin
 if FillDukeHeader(mapname) then
  begin
   if FillDukeStuff then
   WriteDukeStuff(mapname);
   FreeDukeStuff;
  end;
end;

function  GetDukeTileNum(tilename : String) : Integ16;
var idx     : Integer;
    dummy1,
    dummy2  : LongInt;
    TheTileNum : TTILENUM;
    Gob:String;
begin
 {firstly, do we have handled the tile already ?}
 idx:=DA.SeeInDuke_wdf(tilename);
 if idx<>-1 then begin Result:=idx; exit; end;
 idx := DUKE_TX_LIST.IndexOf(tilename);
 if idx <> -1 then
  begin
   TheTileNum := TTILENUM(DUKE_TX_LIST.Objects[idx]);
   Result     := TheTileNum.num;
  end
 else
  begin
   {then search in projectdir}
   if FileExists(LEVELPath + '\' + tilename) then
    begin
     TheTileNum := TTILENUM.Create;
     TheTileNum.num := DA.AddDFFile(LEVELPath + '\' + tilename);
     DUKE_TX_LIST.AddObject(tilename, TheTileNum);
     Result := TheTileNum.num;
    end
   else
    begin
     {else, search in textures.gob}
     {My addition}
     if UpperCase(ExtractFileExt(TileName))='.BM' then gob:=TEXTURESgob
     else gob:=SPRITESgob;
     {Further TEXTURESgob was replaced with gob}
     if IsResourceInGOB(gob, tilename, dummy1, dummy2) then
      begin
       TheTileNum := TTILENUM.Create;
       TheTileNum.num := DA.AddDFFile('[' + gob + ']' + tilename);
       DUKE_TX_LIST.AddObject(tilename, TheTileNum);
       Result := TheTileNum.num;
       if result=-1 then
        result:=0;
      end
     else
      begin
       {set default Duke texture}
       Result := 0;
      end;
    end;
  end;
end;

{this function is responsible for existence tests
 overwrite confirmation etc. hence it receives the map name
 It should also test if something prohibits the conversion}
function FillDukeHeader(mapname : String) : Boolean;
var o, s      : Integer;
    ob        : Integer;
    TheObject : TOB;
begin
 with DUKE_MAP_HEADER do
  begin
   mapversion := 7;

   ob := -1;
   for o := 0 to MAP_OBJ.Count - 1 do
    begin
     TheObject := TOB(MAP_OBJ.Objects[o]);
     if TheObject.Seq.Count <> 0 then
      for s := 0 to TheObject.Seq.Count - 1 do
       begin
        if Pos('EYE:', UpperCase(TheObject.Seq[s])) <> 0 then
         begin
          ob := o;
          break;
         end;
       end;
      if ob <> -1 then break;
    end;

   if ob <> - 1 then
    begin
     posx       := Round(TheObject.X * DUKE_HSCALE) + DUKE_XOFFSET;
     posy       := -Round(TheObject.Z * DUKE_HSCALE) + DUKE_ZOFFSET;
     posz       := -Round(TheObject.Y * DUKE_VSCALE * 16) + DUKE_YOFFSET;
     ang:=(round(TheObject.Yaw * 256 / 45)-512) and $7FF;

     if TheObject.Sec <> -1 then
      cursectnum := TheObject.Sec
     else
      begin
      {ERROR player start not in a sector}
       Result := FALSE;
       exit;
      end;
    end;
  end;

 if ob = -1 then
  begin
   {ERROR No player start found}
   Result := FALSE;
   exit;
  end;

 Result := TRUE;
end;

Procedure CopyFile(INFile,OutFile:TFileName);
Var InF,OutF:TFileStream;
    tmp:array[0..255] of char;
    Error:Boolean;
begin
Error:=false;
Try
 InF:=TFileStream.Create(INFile,fmOpenRead);
except
  On EFOpenError do
  begin
   Error:=true;
   Application.MessageBox(StrPCopy(tmp,'Cannot open file '+InFile),'Disturbance in the Force',MB_OK);
  end;
end;
if Error then begin if Inf<>Nil then Inf.Destroy; exit; end;
Error:=false;
Try
 OutF:=TFileStream.Create(OutFile,fmCreate);
except
 On EFCreateError do
 begin
  Application.MessageBox(StrPCopy(tmp,'Cannot create file '+OutFile),'Disturbance in the Force',MB_OK); error:=true;
 end;
end;
if Error then
begin
 InF.Destroy;
 if OutF<>Nil then OutF.Destroy;
 exit;
end;
 OutF.CopyFrom(InF,InF.size);
 InF.Destroy;
 OutF.Destroy;
end;

Function FillDukeStuff:Boolean;
var s, w, o, i    : Integer;
    TheSector     : TSector;
    TheWall       : TWall;
    TheSector2    : TSector;
    TheWall2      : TWall;
    TheVertex     : TVertex;
    TheDukeSector : TD3D_SECTOR;
    TheDukeWall   : TD3D_WALL;
    TheDukeWall2  : TD3D_WALL;
    TheDukeSprite : TD3D_SPRITE;
    TheDukeSprite2 : TD3D_SPRITE;
    OldCursor     : HCursor;
    convtable     : TPaletteConversionTable;
    cvt           : Integer;
    sc_centerX,
    sc_centerZ    : Real;
    TheObject:TOB; p:Integer; NTile:Integer;
    wrd,seq:string[80];
    Msg:array[0..255] of char;
    Sounds:TDFSounds;
    SrcPath,DestPath:TFileName;
    MakeEnemies:boolean; {Nice name, huh?}
    swzbase,swx,swy,swang,x1,y1,x2,y2,wlen:Real;
    swdx,swdy,lotag,hitag:Integer;
begin
 Result:=false;
 OldCursor := SetCursor(LoadCursor(0, IDC_WAIT));
 DUKE_SECTORS  := TStringList.Create;
 DUKE_WALLS    := TSTringList.Create;
 DUKE_SPRITES  := TStringList.Create;
 DUKE_TX_LIST  := TStringList.Create;
 DA:= TDukeArtTiles.Create(ExtractFilePath(DukeConvertWindow.ED_MAP.Text),15);
 if DukeConvertWindow.CBAddSpecialTiles.Checked then
 begin
  DestPath:=ExtractFilePath(DukeConvertWindow.ED_MAP.Text);
  SrcPath:=WDFUSEDIR+'\WDFDATA\';
  CopyFile(SrcPath+'game.con',DestPath+'game.con');
  CopyFile(SrcPath+'user.con',DestPath+'user.con');
  CopyFile(SrcPath+'defs.con',DestPath+'defs.con');

  DA.SetGobs(TEXTURESgob,SPRITESgob);
  DA.SetGRP(DukeConvertWindow.EBDuke3D_GRP.text);
  DA.SetInDir(WDFUSEDIR+'\wdfdata\');
  if DA.AddSpecialTiles(WDFUSEDIR+'\wdfdata\duke.wdf')<>0 then
  Application.Messagebox(StrPCopy(msg,DA.ErrorMessage),'Disturbance in the Force',MB_OK);
  Sounds:=TDFSounds.Create(SOUNDSgob);
  If Sounds=nil then Application.Messagebox('Cannot Open Sounds.Gob','Disturbance in the Force',MB_OK)
  else
  begin
   if Sounds.Extract(WDFUSEDIR+'\wdfdata\vocs.wdf',ExtractFilePath(DukeConvertWindow.ED_MAP.Text))<>0 then
    Application.Messagebox('Cannot Extact VOC files from Sounds.GOB','Disturbance in the Force',MB_OK);
    Sounds.Free;
  end;
 end;

 if DA.SetDuke_wdf(WDFUSEDIR+'\wdfdata\duke.wdf')<>0 then
 begin
  Application.MessageBox(StrPCopy(Msg,DA.ErrorMessage+' Conversion aborted.'),'Disturbance in the Force',MB_OK);
  exit;
 end;

 if DA.SetLogic2Tile(WDFUSEDIR+'\wdfdata\logics.wdf')<>0 then
 begin
  Application.MessageBox(StrPCopy(Msg,DA.ErrorMessage+' Conversion aborted.'),'Disturbance in the Force',MB_OK);
  exit;
 end;
DA.SetInDir('');

 if DukeConvertWindow.RBPalAuto.Checked then ConvTable:=DefaultCNV
 else
 begin
  cvt  := FileOpen(DukeConvertWindow.ED_CNVFile.Text, fmOpenRead);
  if cvt<0 then
  begin
   Application.MessageBox(StrPCopy(Msg,'Cannot open CNV file. Conversion aborted'),'Disturbance in the Force',MB_OK);
   exit;
  end;
  FileRead(cvt, convtable, 256);
  convtable.Color0 := 0;
  FileClose(cvt);
end;
 DA.SetConversionTable(convtable);
 DA.SetAllowTransparent(FALSE);

 {Progress}
 ProgressWindow.Show;
 ProgressWindow.Progress1.Update;
 ProgressWindow.Progress1.Caption := 'Converting level';
 ProgressWindow.Gauge.MinValue    := 0;
 ProgressWindow.Gauge.MaxValue    := MAP_SEC.Count+2;
 ProgressWindow.Gauge.Progress    := 0;
 ProgressWindow.Progress2.Caption := 'Converting Sectors...';
 ProgressWindow.Progress2.Update;
 ProgressWindow.Update;

 {first number all the walls sequentially using the mark field}
 i := 0;
 for s := 0 to MAP_SEC.Count - 1 do
  begin
   TheSector := TSector(MAP_SEC.Objects[s]);
   for w := 0 to TheSector.Wl.Count - 1 do
    begin
     TheWall := TWall(TheSector.Wl.Objects[w]);
     TheWall.Mark := i;
     Inc(i);
     if TheWall.Sign.Name<>'' then {Add Switch sprite}
     begin
      if TheWall.Adjoin=-1 then swzbase:=TheSector.Floor_Alt
      else
      begin
       TheSector2:=TSector(MAP_SEC.Objects[TheWall.Adjoin]);
       if TheSector2.Floor_alt>TheSector.Floor_alt then swzbase:=TheSector2.Floor_alt
       else swzbase:=TheSector2.Ceili_alt;
      end;
      TheVertex       := TVertex(TheSector.Vx.Objects[TheWall.left_vx]);
      x1:=TheVertex.x;
      y1:=TheVertex.z;
      TheVertex       := TVertex(TheSector.Vx.Objects[TheWall.right_vx]);
      x2:=TheVertex.x;
      y2:=TheVertex.z;
      wlen:=Sqrt((x2-x1)*(x2-x1)+(y2-y1)*(y2-y1));
      if wlen=0 then begin swdx:=0; swdy:=0; end
      else
      begin
       swdx:=round((y2-y1)/wlen*2);
       swdy:=round((x2-x1)/wlen*2);
      end;
      swx:=x1+(x2-x1)/2;
      swy:=y1+(y2-y1)/2;
      if x2=x1 then
      begin
       if y1>y2 then swang:=1024 else swang:=0;
      end else
      begin
       if x2>x1 then
       swang:=1536+1024-ArcTan((y2-y1)/(x2-x1))*1024/Pi
       else swang:=1536+ArcTan((y2-y1)/(x1-x2))*1024/Pi;
      end;

      TheDukeSprite         := TD3D_SPRITE.Create;
      TheDukeSprite.picnum  := GetDukeTileNum(TheWall.Sign.Name);
      TheDukeSprite.x       :=  Round(swx * DUKE_HSCALE) + DUKE_XOFFSET + swdx;
      TheDukeSprite.y       := -Round(swy * DUKE_HSCALE) + DUKE_ZOFFSET + swdy;
      TheDukeSprite.z       := -Round((swzbase-TheWall.Sign.f2) * DUKE_VSCALE * 16) + DUKE_YOFFSET;
      TheDukeSprite.sectnum := s;
      TheDukeSprite.clipdist:= 32;
      TheDukeSprite.xrepeat := 64;
      TheDukeSprite.yrepeat := 64;
      TheDukeSprite.cstat   := 80;
      TheDukeSprite.hitag   := 0;
      TheDukeSprite.lotag   := 0;
      TheDukeSprite.owner   := -1;
      TheDukeSprite.extra   := -1;
      TheDukeSprite.ang:=Round(swang) and $7FF;
      DUKE_SPRITES.AddObject('S', TheDukeSprite);

     end; {Add switch}
    end;
  end;
 {sadly, we'll have to make this two pass for the adjoined walls, because
  wall "doubling" implies setting values in the mirror, so I must be sure
  it has already been created !}

 for s := 0 to MAP_SEC.Count - 1 do
  begin
  ProgressWindow.Gauge.Progress    := ProgressWindow.Gauge.Progress+1;
   TheSector := TSector(MAP_SEC.Objects[s]);
   TheDukeSector := TD3D_SECTOR.Create;

   with TheSector, TheDukeSector do
    begin
     wallptr         := DUKE_WALLS.Count;
     wallnum         := Wl.Count;
     ceilingz        := -Round(Ceili_Alt * DUKE_VSCALE * 16) + DUKE_YOFFSET;
     floorz          := -Round(Floor_Alt * DUKE_VSCALE * 16) + DUKE_YOFFSET;
     ceilingstat     := 0;
     floorstat       := 0;
     ceilingpicnum   := GetDukeTileNum(Ceili.Name);
     ceilingheinum   := 0;
     ceilingshade    := (32 - Ambient) div 2;
     ceilingpal      := 0;
     ceilingxpanning := Byte((256 - Round(Ceili.f1 * DUKE_HSCALE / 4) mod 256));
     ceilingypanning := Byte((256 - Round(Ceili.f2 * DUKE_HSCALE / 4) mod 256));
     floorpicnum     := GetDukeTileNum(Floor.Name);
     floorheinum     := 0;
     floorshade      := (32 - Ambient) div 2;
     floorpal        := 0;
     floorxpanning   := Byte((256 - Round(Floor.f1 * DUKE_HSCALE / 4) mod 256));
     floorypanning   := Byte((256 - Round(Floor.f2 * DUKE_HSCALE / 4) mod 256));
     visibility      := 0;
     filler          := 0;
     lotag           := 0;
     hitag           := 0;
     extra           := -1;
     {sector flags}
     if (Flag1 and 1) = 1 then
      begin
       ceilingstat := ceilingstat + 1;
      end;

     {set the automatic doors at 1 above ground}
     if (Flag1 and 2) = 2 then
      begin
       ceilingz := floorz{ - DUKE_HSCALE * 16};
       lotag    := 20; {ceiling door}
       {see if we can create a door auto close SE}
       if TheSector.Vx.Count = 4 then
        begin
         sc_centerX := 0;
         sc_centerZ := 0;
         for i := 0 to 3 do
          begin
           TheVertex := TVertex(TheSector.Vx.Objects[i]);
           sc_centerX := sc_centerX + TheVertex.X;
           sc_centerZ := sc_centerZ + TheVertex.Z;
          end;

         TheDukeSprite         := TD3D_SPRITE.Create;
         TheDukeSprite.picnum  := 1; {sector effector}
         TheDukeSprite.x       := Round(sc_centerX * DUKE_HSCALE / 4) + DUKE_XOFFSET;
         TheDukeSprite.y       := -Round(sc_centerZ * DUKE_HSCALE / 4) + DUKE_ZOFFSET;
         TheDukeSprite.z       := floorz;
         TheDukeSprite.sectnum := s;
         TheDukeSprite.xrepeat := 64;
         TheDukeSprite.yrepeat := 64;
         TheDukeSprite.hitag   := 128; {close after 4 secs}
         TheDukeSprite.lotag   := 10;  {door autoclose}
         DUKE_SPRITES.AddObject('S', TheDukeSprite);

         TheDukeSprite2         := TD3D_SPRITE.Create;
         TheDukeSprite2.x:=TheDukeSprite.x+2;
         TheDukeSprite2.y:=TheDukeSprite.y+2;
         TheDukeSprite2.z:=TheDukeSprite.z;
         TheDukeSprite2.sectnum := s;
         TheDukeSprite2.xrepeat := 64;
         TheDukeSprite2.yrepeat := 64;
         TheDukeSprite2.picnum  := 5; {Music and SFX}
         TheDukeSprite2.lotag   := DA.GetTileByLogic('DOOR.VOC');
         TheDukeSprite2.hitag   := 0;
         DUKE_SPRITES.AddObject('S', TheDukeSprite2);
         
        end;
      end;
    end;

   DUKE_SECTORS.AddObject('S', TheDukeSector);
   for w := 0 to TheSector.Wl.Count - 1 do
    begin
     TheWall := TWall(TheSector.Wl.Objects[w]);
     TheDukeWall := TD3D_WALL.Create;
     with TheWall, TheDukeWall do
      begin
       TheVertex       := TVertex(TheSector.Vx.Objects[left_vx]);
       x               :=  Round(TheVertex.X * DUKE_HSCALE) + DUKE_XOFFSET;
       y               := -Round(TheVertex.Z * DUKE_HSCALE) + DUKE_ZOFFSET;
       GetWLfromLeftVX(s, right_vx, i);
       TheSector2      := TSector(MAP_SEC.Objects[s]);
       TheWall2        := TWall(TheSector2.Wl.Objects[i]);
       point2          := TheWall2.Mark;
       cstat           := 0;

       if (TheWall.Flag1 and 4) <> 0 then {flip texture horizontally}
        begin
         cstat         := cstat + 8; {xflip}
        end;

       if (TheWall.Flag3 and 2) <> 0 then {cannot walk through}
        begin
         cstat         := cstat + 1; {block move}
        end;

       shade           := (32 - TheSector.Ambient) div 2;

       overpicnum      := 0;
       pal             := 0;
       xrepeat         := Byte(Round(GetWlLen(s, w) * DUKE_HSCALE / 128));
       yrepeat         := 8;

       lotag           := 0;
       hitag           := 0;
       extra           := -1;

       {store these as reference for the second pass}
       DF_Sector       := s;
       DF_Wall         := w;
       DoubleWall      := FALSE;

       {wall flags}
       if Adjoin = -1 then
        begin
         nextwall      := -1;
         nextsector    := -1;
         {for the unadjoined, because DF always textures BOTTOM to TOP
          this is exactly the contrary to Duke !}
         cstat         := cstat + 4;
         picnum        := GetDukeTileNum(Mid.Name); {MID TX}

         {take the MID offsets}
         xpanning      := Byte((Round(TheWall.Mid.f1 * DUKE_HSCALE / 16) mod 256));
         ypanning      := Byte((256 - Round(TheWall.Mid.f2 * DUKE_VSCALE / 8)) mod 256);
        end
       else
        begin
         TheSector2    := TSector(MAP_SEC.Objects[Adjoin]);
         TheWall2      := TWall(TheSector2.Wl.Objects[Mirror]);
         nextwall      := TheWall2.Mark;
         nextsector    := Adjoin;
        end;

       if Adjoin <> -1 then
        begin
         {add support for overpics}
         if (TheWall.Flag1 and 1) <> 0 then {Adjoining MID TX}
          begin
           DA.SetAllowTransparent(TRUE);
           overpicnum := GetDukeTileNum(Mid.Name); {MID TX}
           DA.SetAllowTransparent(FALSE);
           cstat      := cstat + 16; {masking wall "M"}
          end;

         if (TheSector2.Ceili_alt < TheSector.Ceili_Alt) or
            (TheSector2.Flag1 and 2 = 2) {auto door} then
          begin
           xpanning   := Byte((Round(TheWall.Top.f1 * DUKE_HSCALE / 16) mod 256));
           ypanning   := 0 {Byte((256 - Round(TheWall.Top.f2 * DUKE_VSCALE / 16)) mod 256)};
           ypanning   := Byte((Round(TheWall.Top.f2 * DUKE_VSCALE / 16)) mod 256);
           picnum     := GetDukeTileNum(Top.Name); {TOP TX}
           cstat      := cstat + 4;
           if (TheSector2.Floor_alt > TheSector.Floor_Alt) then
            begin
             {this becomes a "2" wall then !}
             DoubleWall := TRUE;
            end;
          end
         else
          if (TheSector2.Floor_alt > TheSector.Floor_Alt) then
           begin
            xpanning    := Byte((Round(TheWall.Bot.f1 * DUKE_HSCALE / 16) mod 256));
            {ypanning    := 0; }
            ypanning    := Byte((256 - Round(TheWall.Bot.f2 * DUKE_VSCALE / 16)) mod 256);
            {ypanning    := Byte(Round((TheSector.Ceili_Alt - TheSector.Floor_Alt
                                 + TheWall.Bot.f2)* DUKE_VSCALE / 16) mod 256);}
            picnum      := GetDukeTileNum(Bot.Name); {BOT TX}
            {cstat       := cstat + 4;}
           end
          else
           begin
            {do NOTHING ! this is the reverse of a double wall}
           end;
        end;

      end;
     DUKE_WALLS.AddObject('W', TheDukeWall);
    end; {for Walls}
  end; {for Sectors}
 {Progress}
 ProgressWindow.Gauge.Progress    := ProgressWindow.Gauge.Progress+1;
 ProgressWindow.Progress2.Caption := 'Converting adjoined walls...';
 ProgressWindow.Progress2.Update;


 { handle double walls }
 for w := 0 to DUKE_WALLS.Count - 1 do
  begin
   TheDukeWall := TD3D_WALL(DUKE_WALLS.Objects[w]);
   if TheDukeWall.DoubleWall then
    begin
     TheSector    := TSector(MAP_SEC.Objects[TheDukeWall.DF_Sector]);
     TheWall      := TWall(TheSector.Wl.Objects[TheDukeWall.DF_Wall]);

     {make it double}
     TheDukeWall.cstat := TheDukeWall.cstat + 2;

     TheDukeWall2 := TD3D_WALL(DUKE_WALLS.Objects[TheDukeWall.nextwall]);
     TheDukeWall2.cstat := TheDukeWall2.cstat + 4;
     with TheDukeWall2 do
      begin
       xpanning    := Byte((Round(TheWall.Bot.f1 * DUKE_HSCALE / 16) mod 256));
       ypanning    := Byte((Round(TheWall.Bot.f2 * DUKE_VSCALE / 16)) mod 256);
       picnum      := GetDukeTileNum(TheWall.Bot.Name);  {BOT TX}
       shade       := (32 - TheSector.Ambient) div 2;
      end;
    end;
  end;

 ProgressWindow.Gauge.Progress    := ProgressWindow.Gauge.Progress+1;
 ProgressWindow.Progress2.Caption := 'Converting Objects...';
 ProgressWindow.Progress2.Update;

{ My Addition}
MakeEnemies:=DukeConvertWindow.CBEnemies.Checked;
DA.SetAllowTransparent(TRUE);
for o := 0 to MAP_OBJ.Count - 1 do
begin
    NTile:=-1;
    TheObject := TOB(MAP_OBJ.Objects[o]);

    if TheObject.Sec=-1 then continue; {Skip objects out of sectors}
    {For each object search all TYPE: and LOGIC: statements}
    for s := 0 to TheObject.Seq.Count - 1 do
     begin
     seq:=UpperCase(TheObject.Seq[s]);
      { IGNORE DUKE NOT NEEDED FOR WDFUSE p:=GetWord(seq,1,wrd); }
      if (wrd='TYPE:') or (wrd='LOGIC:') then
      begin
       {IGNORE DUKE NOT NEEDED FOR WDFUSE  p:=GetWord(seq,p,wrd); }
       { IGNORE DUKE NOT NEEDED FOR WDFUSE  if (wrd='GENERATOR') or (wrd='ITEM') then GetWord(seq,p,wrd); }
       NTile:=DA.GetTileByLogic(wrd);
       if NTile <> -1 then break;
       {If object logics translates by .GetTileByLogic, proceed}
      end;
     end;
    {If object logic does not translate by .GetTileByLogic
     check object type.
     Safe -> Player start
     SPIRIT,3D, SOUND  -> Discard
     FME, WAX ->Static scenery }
    {If no logic, try retrieving type by WAX or FME name}
    if NTile=-1 then
     if (TheObject.Classname='SPRITE') or (TheObject.Classname='FRAME')
      then NTile:=DA.GetTileByLogic(TheObject.DataName);

    if NTile=-2 then continue;

    if not MakeEnemies then
    begin
     if (TheObject.Classname<>'SAFE') then
      if NTile>100 then continue;
    end;

    lotag:=0;
    hitag:=0;

    if NTile=-1 then
    begin
     if (TheObject.Classname='SAFE') then NTile:=1405
     else if (TheObject.Classname='SPRITE') or (TheObject.Classname='FRAME') then
      NTile:=GetDukeTileNum(TheObject.DataName)
     else if (TheObject.ClassName='SOUND') then
     begin
      NTile:=5; {Music and SFX}
      Lotag:=DA.GetTileByLogic(TheObject.DataName);
      If LoTag=-1 then continue;
      Hitag:=8192;
     end else continue;
    end;
    TheDukeSprite         := TD3D_SPRITE.Create;
    TheDukeSprite.picnum  := NTile;
    TheDukeSprite.x       :=  Round(TheObject.X * DUKE_HSCALE) + DUKE_XOFFSET;
    TheDukeSprite.y       := -Round(TheObject.Z * DUKE_HSCALE) + DUKE_ZOFFSET;
    TheDukeSprite.z       := -Round(TheObject.Y * DUKE_VSCALE * 16) + DUKE_YOFFSET;
    TheDukeSprite.sectnum := TheObject.Sec;
    TheDukeSprite.clipdist := 32;
    TheDukeSprite.xrepeat := 64;
    TheDukeSprite.yrepeat := 64;
    TheDukeSprite.cstat   := 257;
    TheDukeSprite.hitag   := Hitag;;
    TheDukeSprite.lotag   := Lotag;
    TheDukeSprite.ang:=(Round(TheObject.Yaw * 256 / 45)-512) and $7FF;

    DUKE_SPRITES.AddObject('S', TheDukeSprite);

end;
{End of my addition}
 DUKE_NUMSECTORS := DUKE_SECTORS.Count;
 DUKE_NUMWALLS   := DUKE_WALLS.Count;
 DUKE_NUMSPRITES := DUKE_SPRITES.Count;
 {Progress}
 ProgressWindow.hide;
 SetCursor(OldCursor);
 Result:=true;
end;

Procedure WriteScript(name:TFileName);
var t:text;
    i:integer;
begin
 AssignFile(t,name);
 {$i-}
 Rewrite(t);
 {$i+}
 if ioresult<>0 then exit;
 Writeln(t,'[Conversion Settings]');
 Writeln(t,'defs.con='#13#10+
         'user.con='#13#10+
         'game.con='#13#10+
         'logics.wdf='#13#10+
         'duke.wdf='#13#10+
         'vocs.wdf='#13#10+
         'version=1'#13#10);
Writeln(t,'[TILES]');
For i:=0 to DUKE_TX_LIST.Count-1 do
 Writeln(t,DUKE_TX_LIST.Strings[i],' ',TTileNum(DUKE_TX_LIST.Objects[i]).num);
CloseFile(t);
end;


procedure WriteDukeStuff(mapname : String);
var map           : Integer;
    i             : Integer;
    TheDukeSector : TD3D_SECTOR;
    TheDukeWall   : TD3D_WALL;
    TheDukeSprite : TD3D_SPRITE;
    OldCursor     : HCursor;
begin
 OldCursor := SetCursor(LoadCursor(0, IDC_WAIT));
 map := FileCreate(mapname);

 FileWrite(map, DUKE_MAP_HEADER , SizeOf(DUKE_MAP_HEADER));

 FileWrite(map, DUKE_NUMSECTORS, 2);
 for i := 0 to DUKE_NUMSECTORS - 1 do
  begin
   TheDukeSector := TD3D_SECTOR(DUKE_SECTORS.Objects[i]);
   with TheDukeSector do
    begin
     FileWrite(map, wallptr, 2);
     FileWrite(map, wallnum, 2);
     FileWrite(map, ceilingz, 4);
     FileWrite(map, floorz, 4);
     FileWrite(map, ceilingstat, 2);
     FileWrite(map, floorstat, 2);
     FileWrite(map, ceilingpicnum, 2);
     FileWrite(map, ceilingheinum, 2);
     FileWrite(map, ceilingshade, 1);
     FileWrite(map, ceilingpal, 1);
     FileWrite(map, ceilingxpanning, 1);
     FileWrite(map, ceilingypanning, 1);
     FileWrite(map, floorpicnum, 2);
     FileWrite(map, floorheinum, 2);
     FileWrite(map, floorshade, 1);
     FileWrite(map, floorpal, 1);
     FileWrite(map, floorxpanning, 1);
     FileWrite(map, floorypanning, 1);
     FileWrite(map, visibility, 1);
     FileWrite(map, filler, 1);
     FileWrite(map, lotag, 2);
     FileWrite(map, hitag, 2);
     FileWrite(map, extra, 2);
    end;
  end;

 FileWrite(map, DUKE_NUMWALLS, 2);
 for i := 0 to DUKE_NUMWALLS - 1 do
  begin
   TheDukeWall := TD3D_WALL(DUKE_WALLS.Objects[i]);
   with TheDukeWall do
    begin
     FileWrite(map, x, 4);
     FileWrite(map, y, 4);
     FileWrite(map, point2, 2);
     FileWrite(map, nextwall, 2);
     FileWrite(map, nextsector, 2);
     FileWrite(map, cstat, 2);
     FileWrite(map, picnum, 2);
     FileWrite(map, overpicnum, 2);
     FileWrite(map, shade, 1);
     FileWrite(map, pal, 1);
     FileWrite(map, xrepeat, 1);
     FileWrite(map, yrepeat, 1);
     FileWrite(map, xpanning, 1);
     FileWrite(map, ypanning, 1);
     FileWrite(map, lotag, 2);
     FileWrite(map, hitag, 2);
     FileWrite(map, extra, 2);
    end;
  end;

 FileWrite(map, DUKE_NUMSPRITES, 2);
 for i := 0 to DUKE_NUMSPRITES - 1 do
  begin
   TheDukeSprite := TD3D_SPRITE(DUKE_SPRITES.Objects[i]);
   with TheDukeSprite do
    begin
     FileWrite(map, x, 4);
     FileWrite(map, y, 4);
     FileWrite(map, z, 4);
     FileWrite(map, cstat, 2);
     FileWrite(map, picnum, 2);
     FileWrite(map, shade, 1);
     FileWrite(map, pal, 1);
     FileWrite(map, clipdist, 1);
     FileWrite(map, filler, 1);
     FileWrite(map, xrepeat, 1);
     FileWrite(map, yrepeat, 1);
     FileWrite(map, xoffset, 1);
     FileWrite(map, yoffset, 1);
     FileWrite(map, sectnum, 2);
     FileWrite(map, statnum, 2);
     FileWrite(map, ang, 2);
     FileWrite(map, owner, 2);
     FileWrite(map, xvel, 2);
     FileWrite(map, yvel, 2);
     FileWrite(map, zvel, 2);
     FileWrite(map, lotag, 2);
     FileWrite(map, hitag, 2);
     FileWrite(map, extra, 2);
    end;
  end;

 FileClose(map);
 WriteScript(ChangeFileExt(DukeConvertWindow.ED_MAP.Text,'.wcs'));
 SetCursor(OldCursor);
end;


procedure FreeDukeStuff;
begin
 DUKE_SECTORS.Free;
 DUKE_WALLS.Free;
 DUKE_SPRITES.Free;
 DUKE_TX_LIST.Free;
 DA.Free;
end;

procedure GeneratePaletteDotDat(dirname : String);
var fin, fout : Integer;
    buffer    : array[0..770] of Byte;
    i         : Integer;
begin
 fin  := FileOpen(LEVELPath + '\' + LEVELName + '.PAL', fmOpenRead);
 FileRead(fin, buffer, 768);
 FileClose(fin);

 buffer[768] := 32;
 buffer[769] := 0;

 fout := FileCreate(dirname + 'PALETTE.DAT');
 FileWrite(fout, buffer, 770);

 fin  := FileOpen(LEVELPath + '\' + LEVELName + '.CMP', fmOpenRead);
 for i := 31 downto 0 do
  begin
   FileSeek(fin, i * 256, 0);
   FileRead(fin, buffer, 256);
   {keep transparent}
   {buffer[255] := 255;}
   FileWrite(fout, buffer, 256);
  end;

 FileClose(fin);
 FileClose(fout);
end;

end.

