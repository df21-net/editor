unit WAD;
interface
Uses Files, Classes, SysUtils;

Type
Wad_index=packed record
 magic:array[0..3] of char;
 nentries:longint;
 pdirectory: longint;
end;

TWADDirectory=class(TContainerFile)
 wh:Wad_index;
 Procedure Refresh;override;
end;


implementation
Uses FileOperations;

Type

TWEInfo=TFileInfo;

c8=array[0..7] of char;
wad_entry=packed record
 pentry:longint;
 length:longint;
 name:c8;
end;

wad_thing=record
 x,y:integer;
 angle:integer;
 thing:integer;
 attrib:integer;
end;

{The last two bytes of a THING control a few attributes, according to which bits are set:
bit 0   the THING is present at skill 1 and 2
bit 1   the THING is present at skill 3 (hurt me plenty)
bit 2   the THING is present at skill 4 and 5 (ultra-violence, nightmare)
bit 3   indicates a deaf guard.
bit 4   means the THING only appears in multiplayer mode.
bits 5-15 have no effect.}


wad_line=record
 fromvert,
 tovert,
 attr,
 linetype,
 tag,
 rightdef,
 leftdef:integer;
end;

{The third field of each linedef is an integer which controls that line's attributes with bits, as follows:

bit #  condition if it is set (=1)

bit 0   Impassable. Players and monsters cannot cross this line, and
          projectiles explode or end if they hit this line. Note, however,
          that if there is no sector on the other side, things can't go
          through this line anyway.
bit 1   Monster-blocker. Monsters cannot cross this line.
bit 2   Two-sided. If this bit is set, then the linedef's two sidedefs can
          have "-" as a texture, which means "transparent". If this bit is not
          set, the sidedefs can't be transparent: if "-" is viewed, it will
          result in the hall of mirrors effect. However, the linedef CAN have
          two non-transparent sidedefs, even if this bit is not set, if it is
          between two sectors.
        Another side effect of this bit is that if it is set, then
          projectiles and gunfire (pistol, etc.) can go through it if there
          is a sector on the other side, even if bit 0 is set.
        Also, monsters see through these lines, regardless of the line's
          other attribute settings and its textures ("-" or not doesn't matter).
bit 3   Upper texture is "unpegged". This is usually done at windows.
          "Pegged" textures move up and down when the neighbor sector moves
          up or down. For example, if a ceiling comes down, then a pegged
          texture on its side will move down with it so that it looks right.
          If the side isn't pegged, it just sits there, the new material is
          spontaneously created. The best way to get an idea of this is to
          change a linedef on an elevator or door, which are always pegged,
          and observe the result.
bit 4   Lower texture is unpegged.
bit 5   Secret. The automap will draw this line like a normal solid line that
          doesn't have anything on the other side, thus protecting the secret
          until it is opened. This bit is NOT what determines the SECRET
          ratio at the end of a level, that is done by special sectors (#9).
bit 6   Blocks sound. Sound cannot cross a line that has this bit set.
          Sound normally travels from sector to sector, so long as the floor
          and ceiling heights allow it (e.g. sound wouldn't go from a sector
          with 0/64 floor/ceiling height to one with 72/128, but sound WOULD
          go from a sector with 0/64 to one with 56/128).
bit 7   Not on map. The line is not shown on the regular automap, not even if
          the computer all-map power up is gained.
bit 8   Already on map. When the level is begun, this line is already on the
          automap, even though it hasn't been seen (in the display) yet.}

{Dec/Hex   ACT   EFFECT

-1 ffff   ? ?   None? Only once in whole game, on e2m7, (960,768)-(928,768)
0    00   - -   nothing
1    01   S R   DOOR. Sector on the other side of this line has its
                ceiling rise to 8 below the first neighbor ceiling on the
                way up, then comes back down after 6 seconds.
2    02   W 1   Open door (stays open)
3    03   W 1   Close door
5    05   W 1   Floor rises to match highest neighbor's floor height.
7    07   S 1   Staircase rises up from floor in appropriate sectors.
8    08   W 1   Stairs
9    09   S 1   Floor lowers; neighbor sector's floor rises and changes
                TEXTURE and sector type to match surrounding neighbor.
10   0a   W 1   Floor lowers for 3 seconds, then rises
11   0b   S -   End level. Go to next level.
13   0d   W 1   Brightness goes to 255
14   0e   S 1   Floor rises to 64 above neighbor sector's floor
16   10   W 1   Close door for 30 seconds, then opens.
18   12   S 1   Floor rises to equal first neighbor floor
19   13   W 1   Floor lowers to equal neighboring sector's floor
20   14   S 1   Floor rises, texture and sector type change also.
21   15   S 1   Floor lowers to equal neighbor for 3 seconds, then rises back
                up to stop 8 below neighbor's ceiling height
22   16   W 1   Floor rises, texture and sector type change also
23   17   S 1   Floor lowers to match lowest neighbor sector
26   1a   S R   DOOR. Need blue key to open. Closes after 6 seconds.
27   1b   S R   DOOR. Yellow key.
28   1c   S R   DOOR. Red key.
29   1d   S 1   Open door, closes after 6 seconds
30   1e   W 1   Floor rises to 128 above neighbor's floor
31   1f   S 1   DOOR. Stays open.
32   20   S 1   DOOR. Blue key. Stays open.
33   21   S 1   DOOR. Yellow key. Stays open.
34   22   S 1   DOOR. Red key. Stays open.
35   23   W 1   Brightness goes to 0.
36   24   W 1   Floor lowers to 8 above next lowest neighbor
37   25   W 1   Floor lowers, change floor texture and sector type
38   26   W 1   Floor lowers to match neighbor
39   27   W 1   Teleport to sector. Only ONE sector can have the same tag #
40   28   W 1   Ceiling rises to match neighbor ceiling
41   29   S 1   Ceiling lowers to floor
42   2a   S R   Closes door
44   2c   W 1   Ceiling lowers to 8 above floor
46   2e   G 1   Opens door (stays open)
48   30   - -   Animated, horizontally scrolling wall.
51   33   S -   End level. Go to secret level 9.
52   34   W -   End level. Go to next level
56   38   W 1   Crushing floor rises to 8 below neighbor ceiling
58   3a   W 1   Floor rises 32
59   3b   W 1   Floor rises 8, texture and sector type change also
61   3d   S R   Opens door
62   3e   S R   Floor lowers for 3 seconds, then rises
63   3f   S R   Open door, closes after 6 seconds
70   46   S R   Sector floor drops quickly to 8 above neighbor
73   49   W R   Start crushing ceiling, slow crush but fast damage
74   4a   W R   Stops crushing ceiling
75   4b   W R   Close door
76   4c   W R   Close door for 30 seconds
77   4d   W R   Start crushing ceiling, fast crush but slow damage
80   50   W R   Brightness to maximum neighbor light level
82   52   W R   Floor lowers to equal neighbor
86   56   W R   Open door (stays open)
87   57   W R   Start moving floor (up/down every 5 seconds)
88   58   W R   Floor lowers quickly for 3 seconds, then rises
89   59   W R   Stops the up/down syndrome started by #87
90   5a   W R   Open door, closes after 6 seconds
91   5b   W R   Floor rises to 8 below neighbor ceiling
97   61   W R   Teleport to sector. Only ONE sector can have the same tag #
98   62   W R   Floor lowers to 8 above neighbor
102  66   S 1   Floor lowers to equal neighbor

103  67   S 1   Opens door (stays open)
104  68   W 1   Light drops to lowest light level amongst neighbor sectors}
{     * FLAG 1
     +-----------------------------------+
     |     1 ADJOINING MID TX            | the MID TX is NOT removed
     |     2 ILLUMINATED SIGN            |
     |     4 FLIP TEXTURE HORIZONTALLY   |
     |     8 ELEV CAN CHANGE WALL LIGHT  |
     |    16 WALL TX ANCHORED            |
     |    32 WALL MORPH WITH SECTOR      |
     |    64 ALLOW SCROLL TOP  TX        |
     |   128 ALLOW SCROLL MID  TX        |
     |   256 ALLOW SCROLL BOT  TX        |
     |   512 ALLOW SCROLL SIGN TX        |
     |  1024 HIDE ON MAP                 |
     |  2048 SHOW ON MAP                 |
     |  4096 SIGN ANCHORED               |
     |  8192 WALL DAMAGES PLAYER         |
     | 16384 SHOW AS LEDGE ON MAP        |
     | 32768 SHOW AS DOOR  ON MAP        |
     +-----------------------------------+

     * FLAG 2 is unused.

     * FLAG 3
     +-----------------------------------+
     |     1 CAN ALWAYS WALK             |
     |     2 CANNOT WALK THROUGH WALL    |
     |     4 FENCE - KEEP ENNEMIES IN    |
     |     8 CANNOT FIRE THROUGH WALL    |
     +-----------------------------------+}


wad_side=record
 xoffs,
 yoffs:integer;
 uptext,
 lowtext,
 midtext:c8;
 sector:integer;
end;

wad_vertex=record
 x,y:integer;
end;

wad_sector=record
 fheight,
 cheight:integer;
 ftext,
 ctext:c8;
 light,
 sectype,
 tag:integer;
end;

{
0   00  is normal, no special characteristic.
1   01  light blinks off at random times.
2   02  light blinks on every 0.5 second
3   03  light blinks on every 1.0 second
4   04  -10/20% health AND light blinks on every 0.5 second
5   05  -5/10% health
7   07  -2/5% health, this is the usual NUKAGE acid-floor.
8   08  light oscillates
9   09  SECRET: player must move into this sector to get credit for finding
        this secret. Counts toward the ratio at the end of the level.
10  0a  ?, ceiling comes down 30 seconds after level is begun
11  0b  -10/20% health. When player's HEALTH <= 10%, then the level ends. If
        it is a level 8, then the episode ends.
12  0c  light blinks on every 1.0 second
13  0d  light blinks on every 0.5 second
14  0e  ??? Seems to do nothing
16  10  -10/20% health}

{    +-----------------------------------+
     |      1 EXTERIOR - NO CEIL.  (SKY) |
     |      2 DOOR                       | instant door
     |      4 SHOT REFLEXION / MAG.SEAL  | walls reflect weapon shots
     |      8 EXTERIOR ADJOIN            | for adjacent skys with != alt.
     |     16 ICE FLOOR        (SKATING) |
     |     32 SNOW FLOOR                 |
     |     64 EXPLODING WALL/DOOR        | instant exploding door
     |    128 EXTERIOR - NO FLOOR  (PIT) |
     |    256 EXTERIOR FLOOR ADJOIN      | for adjacent pits with != alt.
     |    512 CRUSHING SECTOR            |
     |   1024 NO WALL DRAW / "HORIZON"   | horizon moves with eye level
     |   2048 LOW  DAMAGE                |
     |   4096 HIGH DAMAGE   (both = GAS) | both can be combined for GAS
     |   8192 NO SMART OBJECT REACTION   |
     |  16384 SMART OBJECT REACTION      |
     |  32768 SUBSECTOR                  | player won't follow moving SC
     |  65536 SAFE SECTOR                |
     | 131072 RENDERED     (do not use!) |
     | 262144 PLAYER       (do not use!) |
     | 524288 SECRET SECTOR              | increments the %secret when entered
     +-----------------------------------+}


Procedure TWADDirectory.Refresh;
var f:TFile;
    we:Wad_entry;
    Fi:TWEInfo;
    i:integer;
    s:string;
    ename:array[0..8] of char;
begin
 ClearIndex;
 f:=OpenFileRead(name,0);
Try
 F.FRead(wh,sizeof(wh));
 if (wh.magic<>'IWAD') and (wh.magic<>'PWAD') then raise Exception.Create(Name+' is not a WAD file');
 F.FSeek(wh.pdirectory);
 for i:=0 to wh.nentries-1 do
 begin
  F.FRead(we,sizeof(we));
  fi:=TWEInfo.Create;
  fi.offs:=we.Pentry;
  fi.size:=we.Length;
  Files.AddObject(StrLCopy(ename,we.name,8),fi);
 end;
Finally
 F.FClose;
end;
end;

end.
