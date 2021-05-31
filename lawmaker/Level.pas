unit Level;

interface
uses Classes;

Const

SECFLAG1_EXTCEILING             = $00000001;		// Exterior Ceiling
SECFLAG1_EXTFLOOR               = $00000002;		// Exterior Floor
SECFLAG1_EXTTOPADJOIN 		= $00000004;		// Exterior top adjoin
SECFLAG1_EXTBTMADJOIN		= $00000008;		// Exterior bottom adjoin
SECFLAG1_NOWALLS      		= $00000010;		// Sector is an automatic door
SECFLAG1_NOSLIP			= $00000020;		// no gravity slide on slope (meaningless on flat floor)
SECFLAG1_VELFLOORONLY		= $00000040;		// sector vel applies to floor only
SECFLAG1_WATER			= $00000080;
SECFLAG1_DOOR 	      		= $00000100;		// Sector is an automatic door
SECFLAG1_REVERSE      		= $00000200;		// reverse swing direction of auto door
SECFLAG1_USE_SUN_ANGLE		= $00000400;		// use the sun angle specified for the level
SECFLAG1_SWIRLFLOORTEX		= $00000800;
SECFLAG1_SECRET_AREA		= $00001000;
SECFLAG1_REVERB_LOW		= $00002000;	// unused
SECFLAG1_REVERB_MED		= $00004000;	// unused
SECFLAG1_REVERB_HIGH		= $00008000;	// unused
SECFLAG1_UNUSED_8		= $00010000;
SECFLAG1_UNUSED_9		= $00020000;
SECFLAG1_SECDAMAGE_SML		= $00040000;		// small sector damage
SECFLAG1_SECDAMAGE_LGE		= $00080000;		// large sector damage
SECFLAG1_SECDAMAGE_DIE		= $00100000;		// deadly sector damage
SECFLAG1_FLRDAMAGE_SML		= $00200000;		// small floor damage
SECFLAG1_FLRDAMAGE_LGE		= $00400000;		// large floor damage
SECFLAG1_FLRDAMAGE_DIE		= $00800000;		// deadly floor damage
SECFLAG1_SEC_TERMINATE		= $01000000;
SECFLAG1_SECRET_TAG		= $02000000;		// secret sector tag USED ONLY FOR COUNTING SECRETS FOUND...
SECFLAG1_NOSHADEFLOOR		= $04000000;		// don't shade the floor
SECFLAG1_RAIL_PULL		= $08000000;		// rail track pull chain
SECFLAG1_RAIL_LINE		= $10000000;		// rail line...
SECFLAG1_NOSHOW			= $20000000;		// don't show sector to player on map...
SECFLAG1_SLOPEDFLOOR   		= $40000000;		// Sector has sloped floor
SECFLAG1_SLOPEDCEILING 		= $80000000;		// Sector has sloped ceiling

WALLFLAG1_MIDTEX		= $00000001;  	// Wall has adjoining middle texture
WALLFLAG1_LITSIGN		= $00000002;  	// Wall has illuminated sign
WALLFLAG1_HFLIP			= $00000004;  	// Wall texture is flipped horizontally
WALLFLAG1_ANCHOR		= $00000008;  	// Wall textures are anchored
WALLFLAG1_ANCHORSIGN		= $00000010;  	// sign texture is anchored
WALLFLAG1_TINT       		= $00000020;  	// transparency with tinting	- srs
WALLFLAG1_MOVE			= $00000040;		// move the left vertice when rotating or moving the wall
WALLFLAG1_SCROLLTOP		= $00000080;
WALLFLAG1_SCROLLMID		= $00000100;
WALLFLAG1_SCROLLBOTTOM		= $00000200;
WALLFLAG1_SCROLLSIGN		= $00000400;
WALLFLAG1_NOPASS		= $00000800;		// can't walk through
WALLFLAG1_FORCEPASS		= $00001000;		// ignore height check
WALLFLAG1_FENCE			= $00002000;		// badguy no pass
WALLFLAG1_SHATTER		= $00004000;		// Shatter glass	- srs
WALLFLAG1_PROJECTILE_OK		= $00008000;		// Projectile's pass through...	-srs
WALLFLAG1_NORAIL		= $00010000;		// not a rail in a rail sector...
WALLFLAG1_NOSHOW		= $00020000;		// don't show this wall to the player....
WALLFLAG1_SECRET_AREA		= $00040000;		// a secret area, don't show on cheats...

// flags1 of the object declaration
LEV_OBJ_FLAG1_TYPE_PT_SOUND		= $00000001;
LEV_OBJ_FLAG1_TYPE_3DO			= $00000008;
LEV_OBJ_FLAG1_AUTO_VELOCITY		= $00000010;

// flags2 of the object declaration
LEV_OBJ_FLAG2_OBJECT_MULTI_AI		= $00200000;
LEV_OBJ_FLAG2_OBJECT_DMATCH		= $00400000;
LEV_OBJ_FLAG2_OBJECT_CAPTURE_FLAG 	= $00800000;
LEV_OBJ_FLAG2_OBJECT_TAG		= $01000000;
LEV_OBJ_FLAG2_OBJECT_MAN_BALL		= $02000000;
LEV_OBJ_FLAG2_OBJECT_SECRET_DOC		= $04000000;
LEV_OBJ_FLAG2_OBJECT_TEAM_PLAY		= $08000000;
LEV_OBJ_FLAG2_OBJECT_NOVICE		= $10000000;
LEV_OBJ_FLAG2_OBJECT_NORMAL		= $20000000;
LEV_OBJ_FLAG2_OBJECT_ADVANCED		= $40000000;
LEV_OBJ_FLAG2_OBJECT_EXPERT		= $80000000;

{reserved object names...
start positions (need at least 1 per game)
player		- player start pos (for single player)
startpos	- additional start positions for mp
flagstar	- flag start point (for CTF)
ballstar	- chicken start point for KFC}

LIFLAG_DUMP_WEAPONS		= $00000001;
LIFLAG_DUMP_AMMO		= $00000002;
LIFLAG_DUMP_HEALTH		= $00000004;
LIFLAG_DUMP_OIL			= $00000008;
LIFLAG_DUMP_ALL			= $00000010;
LIFLAG_SHOW_SCORE		= $00000020;
LIFLAG_DROP_NONNATIVE 		= $00000040;


Type
TLevel=class;
TSector=class;

TVector=record
 dx,dy,dz:double;
end;

TVertexClip=record
 X,Z:Double;
end;

TVertex=class
 X,Z:Double;
 mark:Integer;
 Function IsSameXZ(V:TVertex):Boolean;
end;

TClipString=String[31];

TOBClip=record
 Name:TClipString;
 X,Y,Z:Double;
 PCH,YAW,ROL:Double;
 Flags1,Flags2:Longint;
end;

TOB=class
 HexID:Longint;
 Name:String;
 Sector:Integer;
 X,Y,Z:Double;
 PCH,YAW,ROL:Double;
 flags1,Flags2:Longint;
 Procedure Assign(o:TOB);
 procedure CopyToClip(var Clip:TOBCLip);
 procedure PasteFromClip(const Clip:TOBClip);
end;

TMyList=class(TList)
 Procedure Delete(I:integer);
end;

TObjects=class(TMyList)
private
 function GetObject(n:Integer):TOB;
 procedure SetObject(n:Integer;LevelObject:TOB);
public
 Property Items[n:Integer]:TOB read GetObject write SetObject; default;
end;

TTexture=record
 Name:String;
 offsx,offsy:double;
end;

TTXClip=record
 Name:TClipString;
 offsx,offsy:double;
end;

TWallClip=record
 V1,V2:Integer;
 Mid,Top,Bot:TTXClip;
 OverLay:TTXClip;
 Flags:Longint;
 Light:Byte;
end;

TWall=class
 HexID:Longint;
 V1,V2:Integer;
 Mid,Top,Bot:TTexture;
 OverLay:TTexture;
 Adjoin,DAdjoin:Integer;
 Mirror,DMirror:Integer;
 Flags:Longint;
 Light:Byte;
 Trigger,elevator:Boolean;
 Mark, Mark1:Integer;
 procedure CopyToClip(var Clip:TWallClip);
 procedure PasteFromClip(const Clip:TWallClip);
 Function IsFlagSet(flag:Integer):Boolean;
 Procedure Assign(w:TWall);
Private
 IMID,ITOP,IBOT,IOverlay:Integer; {Undices of textures. Used when saving}
end;

TWalls=class(TMyList)
private
 function GetWall(n:Integer):TWall;
 procedure SetWall(n:Integer;wall:TWall);
public
 Property Items[n:Integer]:TWall read GetWall write SetWall; default;
end;

TVertices=class(TMyList)
private
 function GetVertex(n:Integer):TVertex;
 procedure SetVertex(n:Integer;vertex:TVertex);
public
 Property Items[n:Integer]:TVertex read GetVertex write SetVertex; default;
end;

TSlope=record
 sector,wall:Integer;
 angle:Double;
end;

TSectorClip=record
 nVertices,NWalls:Integer;
 Name:TClipString;
 Ambient:byte;
 Palette:TClipString;
 ColorMap:TClipString;
 Friction:double;
 Gravity: Double;
 Elasticity: Double;
 Velocity: TVector;
 Floor_Sound: TClipString;
 Floor_Y: Double;
 Floor_TX:TTXClip;
 Floor_extra:double;
 Ceiling_Y: Double;
 Ceiling_TX: TTXClip;
 Ceiling_Extra:Double;
 F_Overlay_TX:TTXClip;
 F_Overlay_Extra:Double;
 C_Overlay_TX:TTXClip;
 C_Overlay_Extra:Double;
 Flags: Longint;
 FloorSlope,
 CeilingSlope:TSlope;
 Layer: integer;
end;

TSector=class
private
 fvertices:TVertices;
 fwalls:TWalls;
 Function IsSecret:Boolean;
Public
 HexID:Longint;
 Elevator:Boolean;
 Trigger:Boolean;
 Name:String;
 Ambient:Byte;
 Palette:String;
 ColorMap:String;
 Friction:double;
 Gravity: Double;
 Elasticity: Double;
 Velocity: TVector;
 VAdjoin: Integer;
 Floor_Sound: String;
 Floor_Y: Double;
 Floor_Texture:TTexture;
 Floor_extra:double;
 Ceiling_Y: Double;
 Ceiling_Texture: TTexture;
 Ceiling_Extra:Double;
 F_Overlay_texture:TTexture;
 F_Overlay_Extra:Double;
 C_Overlay_texture:TTexture;
 C_Overlay_Extra:Double;
 floor_offsets: Integer;
 Flags: Longint;
 FloorSlope,
 CeilingSlope:TSlope;
 Layer: integer;
 procedure CopyToClip(var Clip:TSectorClip);
 procedure PasteFromClip(const Clip:TSectorClip);
 Constructor Create;
 Destructor Destroy;override;
 Property Vertices: Tvertices read fvertices;
 Property Walls: TWalls read fwalls;
 Property Secret:Boolean read IsSecret;
 Function IsFlagSet(flag:Integer):Boolean;
 Procedure Assign(s:TSector);
 Function GetWallByID(ID:Longint):Integer;
 Function IsWLValid(wl:Integer):Boolean;
 Function IsVXValid(VX:Integer):Boolean;
Private
 IFloor_TX,ICeiling_TX,ICOVR_TX,IFOVR_TX:Integer;
 IPalette,ICmap:Integer;
end;

TSectors=class(TMyList)
private
 function GetSector(n:Integer):TSector;
 procedure SetSector(n:Integer;sector:TSector);
public
 Property Items[n:Integer]:TSector read GetSector write SetSector; default;
end;

TShade=class
 r,g,b:byte;
 b4:byte;
 c1:char;
end;

TShades=class(TMyList)
private
 function GetShade(n:Integer):TShade;
 procedure SetShade(n:Integer;shade:TShade);
public
 Property Items[n:Integer]:TShade read GetShade write SetShade; default;
end;

TLevel=class
Private
 fsectors:TSectors;
 fshades:TShades;
 fobjects:TObjects;
 LastID:LongInt;
Public
 Name:String;
 Music:String;
 Version:Double;
 Parallax_x,Parallax_y:Double;
 {extra variables}
 MinX,MinY,MinZ,MaxX,MaxY,MaxZ:Double;
 MinLayer,MaxLayer:Integer;
 Constructor Create;
 Destructor Destroy;Override;
 Property Sectors:TSectors read fsectors;
 Property Shades:TShades read fshades;
 Property Objects:TObjects read fobjects;
 Procedure Clear;
 Procedure Load(FName:String);
 Procedure Save(FName:String);
 Procedure ImportLEV(FName:String);
 Procedure ImportWAD(FName:String);
 Procedure ImportMAP(FName:String);
 Function GetNewSectorID:Longint;
 Function GetNewWallID:Longint;
 Function GetNewObjectID:Longint;
 Function GetSectorbyID(ID:Longint):Integer;
 Function GetObjectbyID(ID:Longint):Integer;
 Procedure FindLimits;
 Procedure FindLayers;
 Procedure FindMaxID;
 {Helper routines}
 Function NewVertex:TVertex; {For creating new items with default
                              properties. Also sets the HexID field right}
 Function NewWall:TWall;
 Function NewSector:TSector;
 Function NewObject:TOB;
 Procedure SetDefaultShades;
 Function IsSCValid(sc:Integer):Boolean;
end;

implementation
uses Files, FileOperations, Misc_Utils, SysUtils, ProgressDialog, GlobalVars;

Procedure TXToClip(Var Clip:TTXClip;TX:TTexture);
begin
 Clip.Name:=TX.Name;
 Clip.OffsX:=TX.OffsX;
 Clip.OffsY:=TX.OffsY;
end;

Procedure ClipToTX(TX:TTexture;Const Clip:TTXClip);
begin
 TX.Name:=Clip.Name;
 TX.OffsX:=Clip.OffsX;
 TX.OffsY:=Clip.OffsY;
end;


Procedure TMyList.Delete(I:integer);
begin
 Inherited Delete(i);
 Pack;
end;

function TWalls.GetWall(n:Integer):TWall;
begin
 if (n<0) or (n>=count) then raise EListError.CreateFmt('Wall index is out of bounds: %d',[n])
  else Result:=TWall(List[n]);
end;

procedure TWalls.SetWall(n:Integer;wall:TWall);
begin
 Tlist(self).Items[n]:=wall;
end;

function TObjects.GetObject(n:Integer):TOB;
begin
 if (n<0) or (n>=count) then raise EListError.Create('Object index is out of bounds')
  else Result:=TOB(List[n]);
end;


procedure TObjects.SetObject(n:Integer;LevelObject:TOB);
begin
 List[n]:=LevelObject;
end;


function TVertices.GetVertex(n:Integer):TVertex;
begin
 if (n<0) or (n>=count) then raise EListError.CreateFmt('Vertex index is out of bounds: %d',[n])
  else Result:=TVertex(List[n]);
end;

procedure TVertices.SetVertex(n:Integer;vertex:TVertex);
begin
 Tlist(self).Items[n]:=Vertex;
end;

function TSectors.GetSector(n:Integer):TSector;
begin
 if (n<0) or (n>=count) then raise EListError.CreateFmt('Sector index is out of bounds: %d',[n])
  else Result:=TSector(List[n]);
end;

procedure TSectors.SetSector(n:Integer;sector:TSector);
begin
 List[n]:=Sector;
end;

function TShades.GetShade(n:Integer):TShade;
begin
 if n>=count then raise EListError.Create('Shade index is out of bounds')
  else Result:=TShade(List[n]);
end;

procedure TShades.SetShade(n:Integer;Shade:TShade);
begin
 List[n]:=Shade;
end;

{TSector Methods}
Constructor TSector.Create;
begin
 fwalls:=TWalls.Create;
 fvertices:=TVertices.Create;
end;

Function TSector.IsVXValid(VX:Integer):Boolean;
begin
 Result:=(VX>=0) and (VX<Vertices.count);
end;

Function TSector.GetWallByID(ID:Longint):Integer;
var i:Integer;
begin
 Result:=-1;
 for i:=0 to Walls.count-1 do
  if Walls[i].HexID=ID then begin Result:=i; exit; end; 
end;

Function TSector.IsWLValid(wl:Integer):Boolean;
begin
 if (wl<0) or (wl>=Walls.Count) then result:=false
 else Result:=true;
end;

Destructor TSector.Destroy;
var i:integer;
begin
 for i:=0 to vertices.count-1 do vertices[i].free;
 for i:=0 to walls.count-1 do walls[i].free;
 vertices.free;
 walls.free;
end;

procedure TSector.CopyToClip(var Clip:TSectorClip);
begin
 Clip.nVertices:=Vertices.Count;
 Clip.NWalls:=Walls.Count;
 Clip.Name:=Name;
 Clip.Ambient:=Ambient;
 Clip.Palette:=Palette;
 Clip.ColorMap:=ColorMap;
 Clip.Friction:=Friction;
 Clip.Gravity:=Gravity;
 Clip.Elasticity:=Elasticity;
 Clip.Velocity:=Velocity;
 Clip.Floor_Sound:=Floor_Sound;
 Clip.Floor_Y:=Floor_y;
 TXToCLip(Clip.Floor_TX,Floor_Texture);
 Clip.Floor_extra:=Floor_Extra;
 Clip.Ceiling_Y:=Ceiling_Y;
 TXToClip(Clip.Ceiling_TX,Ceiling_Texture);
 Clip.Ceiling_Extra:=Ceiling_Extra;
 TXToClip(Clip.F_Overlay_TX,F_Overlay_Texture);
 Clip.F_Overlay_Extra:=F_Overlay_Extra;
 TXToClip(Clip.C_Overlay_TX,C_Overlay_Texture);
 Clip.C_Overlay_Extra:=C_Overlay_Extra;
 Clip.Flags:=Flags;
 Clip.FloorSlope:=FloorSlope;
 Clip.CeilingSlope:=CeilingSlope;
 Clip.Layer:=Layer;
end;

procedure TSector.PasteFromClip(const Clip:TSectorClip);
begin
 Name:=Clip.Name;
 Ambient:=Clip.Ambient;
 Palette:=Clip.Palette;
 ColorMap:=Clip.ColorMap;
 Friction:=Clip.Friction;
 Gravity:=Clip.Gravity;
 Elasticity:=Clip.Elasticity;
 Velocity:=Clip.Velocity;
 Floor_Sound:=Clip.Floor_Sound;
 Floor_Y:=Clip.Floor_y;
 CLipToTX(Floor_Texture,Clip.Floor_TX);
 Floor_extra:=Clip.Floor_Extra;
 Ceiling_Y:=Clip.Ceiling_Y;
 ClipToTX(Ceiling_Texture,Clip.Ceiling_TX);
 Ceiling_Extra:=Clip.Ceiling_Extra;
 ClipToTX(F_Overlay_Texture,Clip.F_Overlay_TX);
 F_Overlay_Extra:=Clip.F_Overlay_Extra;
 ClipToTX(C_Overlay_Texture,Clip.C_Overlay_TX);
 C_Overlay_Extra:=Clip.C_Overlay_Extra;
 Flags:=Clip.Flags;
 FloorSlope:=Clip.FloorSlope;
 CeilingSlope:=Clip.CeilingSlope;
 Layer:=Clip.Layer;
end;

Procedure TSector.Assign;
begin
 Ambient:=s.Ambient;
 Palette:=s.Palette;
 ColorMap:=s.ColorMap;
 Friction:=s.Friction;
 Gravity:=s.Gravity;
 Elasticity:=s.Elasticity;
 Velocity:=s.Velocity;
 Floor_Sound:=s.Floor_Sound;
 Floor_Y:=s.Floor_Y;
 Floor_Texture:=s.Floor_Texture;
 Floor_extra:=s.Floor_extra;
 Ceiling_Y:=s.Ceiling_Y;
 Ceiling_Texture:=s.Ceiling_Texture;
 Ceiling_Extra:=s.Ceiling_Extra;
 F_Overlay_texture:=s.F_Overlay_texture;
 F_Overlay_Extra:=s.F_Overlay_Extra;
 C_Overlay_texture:=s.C_Overlay_texture;
 C_Overlay_Extra:=s.C_Overlay_Extra;
 Flags:=s.Flags;
 FloorSlope:=s.FloorSlope;
 CeilingSlope:=s.CeilingSlope;
 Layer:=s.Layer;
end;

Function TSector.IsSecret:Boolean;
begin
 Result:=(flags and SECFLAG1_SECRET_TAG)<>0;
end;

{TLevel methods}
Constructor TLevel.Create;
var i:Integer;
begin
 fsectors:=TSectors.Create;
 fshades:=TShades.Create;
 fobjects:=TObjects.Create;
 Version:=1535.022197;
 Music:='NULL';
 Parallax_x:=1024;
 Parallax_y:=1024;
 {extra variables}
 end;

Function TLevel.IsSCValid(sc:Integer):Boolean;
begin
 if (sc<0) or (sc>=sectors.Count) then result:=false
 else Result:=true;
end;


Procedure TLevel.SetDefaultShades;
var i:Integer;
begin
 Shades.Clear;
 For i:=0 to 12 do Shades.Add(TShades.Create);
 With Shades[0] do begin r:=200; g:=200; b:=200; b4:=10; c1:='L' end;
 With Shades[1] do begin r:=200; g:=200; b:=200; b4:=25; c1:='L' end;
 With Shades[2] do begin r:=200; g:=200; b:=200; b4:=50; c1:='L' end;
 With Shades[3] do begin r:=200; g:=200; b:=200; b4:=75; c1:='L' end;
 With Shades[4] do begin r:=0; g:=0; b:=0; b4:=85; c1:='G' end;
 With Shades[5] do begin r:=0; g:=0; b:=0; b4:=70; c1:='G' end;
 With Shades[6] do begin r:=0; g:=0; b:=0; b4:=55; c1:='G' end;
 With Shades[7] do begin r:=0; g:=0; b:=255; b4:=10; c1:='T' end;
 With Shades[8] do begin r:=0; g:=0; b:=255; b4:=30; c1:='T' end;
 With Shades[9] do begin r:=0; g:=0; b:=255; b4:=50; c1:='T' end;
 With Shades[10] do begin r:=255; g:=0; b:=0; b4:=10; c1:='T' end;
 With Shades[11] do begin r:=255; g:=0; b:=0; b4:=30; c1:='T' end;
 With Shades[12] do begin r:=255; g:=0; b:=0; b4:=50; c1:='T' end;
end;

Destructor TLevel.Destroy;
var i:integer;
begin
 Clear;
 Sectors.free;
 fshades.free;
end;

Procedure TLevel.Clear;
var i:Integer;
begin
 For i:=0 to sectors.count-1 do sectors[i].free;
 for i:=0 to fshades.count-1 do fshades[i].free;
 For i:=0 to fobjects.count-1 do fobjects[i].free;
 Sectors.Clear;
 Shades.Clear;
 Objects.Clear;
 LastID:=$10;
end;

Procedure TLevel.FindMaxID;
var i,s,w:Integer;
    CurID:Longint;
Function DWBigger(a,b:Longint):boolean;assembler;
asm
   Mov eax,a
   cmp eax,b
   mov al,FALSE
   jbe @below
   mov al,TRUE
@Below:
end;

begin
 LastID:=$10;
 For s:=0 to sectors.count-1 do
 With Sectors[s] do
 begin
  if DWBigger(HexID,LastID) then LastID:=HexID;
  For w:=0 to Walls.count-1 do
  begin
   CurID:=Walls[w].HexID;
   if DWBigger(CurID,LastID) then LastID:=CurID;
  end;
 end;

 For i:=0 to objects.count-1 do
 begin
  CurID:=Objects[i].HexID;
  if DWBigger(CurID,LastID) then LastID:=CurID;
 end;

end;

Function TLevel.GetNewSectorID:Longint;
begin
 Inc(LastID);
 Result:=LastID;
end;

Function TLevel.GetNewWallID:Longint;
begin
 Inc(LastID);
 Result:=LastID;
end;

Function TLevel.GetNewObjectID:Longint;
begin
 Inc(LastID);
 Result:=LastID;
end;

Function TLevel.GetSectorbyID(ID:Longint):Integer;
var i:integer;
begin
 result:=-1;
 for i:=0 to sectors.count-1 do
 if sectors[i].HexID=ID then begin result:=i; exit; end;
end;

Function TLevel.GetObjectbyID(ID:Longint):Integer;
var i:integer;
begin
 result:=-1;
 for i:=0 to objects.count-1 do
 if objects[i].HexID=ID then begin result:=i; exit; end;
end;

Procedure TWall.Assign(w:TWall);
begin
 Mid:=w.Mid;
 Top:=w.Top;
 Bot:=w.Bot;
 OverLay:=w.Overlay;
 Flags:=w.Flags;
 Light:=w.Light;
end;

procedure TWall.CopyToClip(var Clip:TWallClip);
begin
 Clip.V1:=V1;
 Clip.V2:=V2;
 TXToClip(Clip.Mid,Mid);
 TXToClip(Clip.Bot,Bot);
 TXToClip(Clip.Top,Top);
 TXToClip(Clip.Overlay,Overlay);
 Clip.Flags:=Flags;
 Clip.Light:=Light;
end;

procedure TWall.PasteFromClip(const Clip:TWallClip);
begin
 V1:=Clip.V1;
 V2:=Clip.V2;
 ClipToTX(Mid,Clip.Mid);
 ClipToTX(Bot,Clip.Bot);
 ClipToTX(Top,Clip.Top);
 ClipToTX(Overlay,Clip.Overlay);
 Flags:=Clip.Flags;
 Light:=Clip.Light;
end;

Function TWall.IsFlagSet(flag:Integer):Boolean;
begin
 Result:=flags and flag<>0;
end;

Function TSector.IsFlagSet(flag:Integer):Boolean;
begin
 Result:=flags and flag<>0;
end;

Procedure TLevel.FindLimits;
var i,j       : Integer;
    TheSector : TSector;
    TheVertex : TVertex;
begin
  minX := 99999;
  minY := 99999;
  minZ := 99999;
  maxX := -99999;
  maxY := -99999;
  maxZ := -99999;
  for i := 0 to Sectors.Count - 1 do
    begin
      TheSector := Sectors[i];

      if TheSector.Ceiling_Y > maxY then maxY := TheSector.Ceiling_Y;
      if TheSector.Floor_Y < minY then minY := TheSector.Floor_Y;

      for j := 0 to TheSector.Vertices.Count - 1 do
        begin
          TheVertex := TheSector.Vertices[j];
          if TheVertex.X > maxX then maxX := TheVertex.X;
          if TheVertex.Z > maxZ then maxZ := TheVertex.Z;
          if TheVertex.X < minX then minX := TheVertex.X;
          if TheVertex.Z < minZ then minZ := TheVertex.Z;
        end;
    end;

  For i:=0 to Objects.Count-1 do
  With Objects[i] do
  begin
   if X>MaxX then MaxX:=X;
   if X<MinX then MinX:=X;
   if Y>MaxY then MaxY:=Y;
   if Y<MinY then MinY:=Y;
   if Z>MaxZ then MaxZ:=Z;
   if Z<MinZ then MinZ:=Z;
  end;

  FindLayers;
  FindMaxID;
end;

Procedure TLevel.FindLayers;
var i:Integer;
begin
 MinLayer:=100;
 MaxLayer:=-100;
 for i:=0 to sectors.count-1 do
 With Sectors[i] do
 begin
  If Layer<MinLayer then MinLayer:=Layer;
  if Layer>MaxLayer then MaxLayer:=Layer;
 end;
end;

procedure TOB.CopyToClip(var Clip:TOBCLip);
begin
 Clip.Name:=Name;
 Clip.X:=X;
 Clip.Y:=Y;
 Clip.Z:=Z;
 Clip.PCH:=PCH;
 Clip.YAW:=YAW;
 Clip.ROL:=ROL;
 Clip.Flags1:=Flags1;
 Clip.Flags2:=Flags2;
end;

procedure TOB.PasteFromClip(const Clip:TOBClip);
begin
 Name:=Clip.Name;
 X:=Clip.X;
 Y:=Clip.Y;
 Z:=Clip.Z;
 PCH:=Clip.PCH;
 YAW:=Clip.YAW;
 ROL:=Clip.ROL;
 Flags1:=Clip.Flags1;
 Flags2:=Clip.Flags2;
end;

Procedure TOB.Assign;
begin
 Name:=o.Name;
 PCH:=O.PCH;
 YAW:=O.YAW;
 ROL:=O.ROL;
 flags1:=o.Flags1;
 Flags2:=o.Flags2;
end;

Function TLevel.NewVertex:TVertex;
begin
 Result:=TVertex.Create;
end;

Function TLevel.NewWall:TWall;
begin
 Result:=TWall.Create;
 With Result do
 begin
  HexID:=GetNewWallID;
  Mid.Name:='DEFAULT.PCX';
  Top.Name:='DEFAULT.PCX';
  Bot.Name:='DEFAULT.PCX';
  OverLay.Name:='';
  Adjoin:=-1;
  DAdjoin:=-1;
  Mirror:=-1;
  DMirror:=-1;
 end;
end;

Function Tlevel.NewSector:TSector;
begin
 Result:=TSector.Create;
With Result do
begin
 HexID:=GetNewSectorID;
 Palette:='RANCH';
 ColorMap:='RANCH';
 Friction:=1;
 Gravity:=-60;
 Elasticity:=0.3;
 VAdjoin:=-1;
 Floor_Sound:='NULL';
 Floor_Y:=0;
 Ceiling_Y:=8;
 Floor_Texture.Name:='DEFAULT.PCX';
 Ceiling_Texture.Name:='DEFAULT.PCX';
 With FloorSlope do
 begin
  Sector:=-1;
  Wall:=-1;
  Sector:=-1;
 end;
 With CeilingSlope do
 begin
  Sector:=-1;
  Wall:=-1;
  Sector:=-1;
 end;
 Layer:=1;
end;
end;

Function TLevel.NewObject:TOB;
begin
 Result:=TOB.Create;
With Result do
begin
 HexID:=GetNewObjectID;
 {Name:=''};
 Sector:=-1;
 Flags2:=$F0000000; {On all difficulties}
end;

end;

Function TVertex.IsSameXZ(V:TVertex):Boolean;
begin
 Result:=(X=V.X) and (Z=V.Z);
end;


{$i level_io.inc}

Initialization
DecimalSeparator:='.';

end.
