unit M_global;

interface
uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, IniFiles, Graphics,
  Generics.Collections, Vcl.Dialogs, StrUtils, LoggerPro, LoggerPro.FileAppender,
  LoggerPro.OutputDebugStringAppender, VCL.forms;

TYPE Integ16 =
{$IFNDEF WDF32}
               Integer;
{$ELSE}
               SmallInt;
{$ENDIF}


{ CONSTANTS }
CONST
{$IFNDEF WDF32}napi.
 WDFUSE_VERSION      = 'Version 2.60 Beta 1 (16 bits)';
{$ELSE}
 WDFUSE_VERSION      = 'Version 2.60 Beta 1 (32 bits)';
{$ENDIF}

 MM_SC               = 0;
 MM_WL               = 1;
 MM_VX               = 2;
 MM_OB               = 3;

 MT_NO               = 0;
 MT_LI               = 1;
 MT_DM               = 2;
 MT_2A               = 3;
 MT_SP               = 4;
 MT_SF               = 5;

 RST_BM              = 0;
 RST_3DO             = 2;
 RST_WAX             = 3;
 RST_FME             = 4;
 RST_SND             = 5;
 OBT_SPIRIT          = 0;
 OBT_SAFE            = 1;
 OBT_3D              = 2;
 OBT_SPRITE          = 3;
 OBT_FRAME           = 4;
 OBT_SOUND           = 5;
 OBS_GENERATOR       = 1;

 CUsePlusVX          = FALSE;
 CUsePlusOBShad      = FALSE;
 CSpecialsVX         = TRUE;
 CSpecialsOB         = TRUE;
 Cvx_scale           = 6;
 Cvx_dim_max         = 3;
 Cbigvx_scale        = 13;
 Cbigvx_dim_max      = 5;
 Cob_scale           = 6;
 Cob_dim_max         = 3;
 Cbigob_scale        = 13;
 Cbigob_dim_max      = 5;
 perp_ratio          = 0.25e0;
 extr_ratio          = 0.25e0;

{ DEFAULTS }
CONST
 Ccol_back           = clBlack;
 Ccol_wall_n         = clLime;
 Ccol_wall_a         = clGreen;
 Ccol_shadow         = clGray;
 Ccol_grid           = clFuchsia;
 Ccol_select         = clRed;
 Ccol_multis         = clWhite;
 Ccol_elev           = clYellow;
 Ccol_trig           = clAqua;
 Ccol_goal           = clPurple;
 Ccol_secr           = clFuchsia;

 Ccol_dm_low         = clGreen;
 Ccol_dm_high        = clYellow;
 Ccol_dm_gas         = clRed;
 Ccol_2a_water       = clBlue;
 Ccol_2a_catwlk      = clGray;
 Ccol_sp_sky         = clAqua;
 Ccol_sp_pit         = clGray;
 Ccol_sec_inner      = clWebChartreuse;

 STEAM_REG           = '\Software\Wow6432Node\Valve\Steam';
 GOG_REG             = '\Software\Wow6432Node\GOG.com\Games\1421404433';

const rs  = 20; {size of the palette squares}
const rcs = 12; {size of the colormap squares}

TYPE
 PByte = ^Byte;
 PInt  = ^Integer;
 PLong = ^LongInt;

TYPE
{INF CLASS}
TInfClass = class
 IsElev   : Boolean;
 Name     : String[30];
 SlaCli   : TStringList;
 constructor Create;
 procedure   Free;
end;

TINFSequence = class
 Comments    : TStringList;
 Classes     : TSTringList;
 Constructor Create;
 Procedure   Free;
end;

TINFCls = class
 ClsName     : String[19];
 ClsType     : Integer;           {0=Elev, 1=Trig, 2=Chute}
 SlaCliTgt   : TStringList;       {Slaves, Clients, Target}
 Stops       : TStringList;
 Actions     : TStringList;       {stockage : 'stopnum', TINFAction}
 Master      : String[15];
 Start       : String[15];
 Sound1,
 Sound2,
 Sound3      : String[15];
 Flags       : String[15];
 event,
 event_mask,
 entity_mask : string[15];        {convert to longint only when needed
                                   ! entity_mask may be '*' !}
 key,
 key1        : String[15];
 speed,
 speed1      : String[15];
 angle       : String[15];
 centerX,
 centerZ     : String[15];        {! precision may be 4 decimals !}

 Constructor Create;
 Procedure   Free;
end;

TINFStop = class
 IsAtStop    : Boolean;
 Value       : String[20];         {! may be a sector name !}
 DHT         : String[15];
end;

TINFAction = class
 ActName     : String[15];         {'adjoin:', 'message:', 'page:', 'text:'}
 Value       : String[15];         {main value : for page & text}
 sc1         : String[30];         {may also be 'system'}
 wl1,
 sc2,
 wl2         : String[20];
 MsgType     : String[15];         {master_on, lights, set_bits, ...}
 MsgParam1,
 MsgParam2   : String[15];
end;

{TEXTURE}
TTEXTURE = record
  name : String[16];
  f1   : Real;
  f2   : Real;
  i    : Integ16;
end;

{ SECTOR }
TSECTOR = class(TObject)
  Vx            : TStringList;
  Wl            : TStringList;
  Mark          : Integ16; { reserved for multiple selection }
  Name          : String[20];
  Layer         : Integ16;
  Floor_alt     : Real;
  Ceili_alt     : Real;
  Second_alt    : Real;
  Ambient       : Integ16;
  Flag1         : LongInt;
  Flag2         : LongInt;
  Flag3         : LongInt;
  Reserved      : Integ16; { used in the deformations }
  Floor,
  Ceili         : TTexture;
  Elevator      : Boolean; {used in drawing, faster than listing the classes}
  Trigger       : Boolean;
  Secret        : Boolean;
  InfClasses    : TStringList;
  InfItems      : TStringList; {NEW}
  constructor Create;
  procedure   Free;
end;

{ WALL }
TWALL = class(TObject)
  Left_vx       : Integ16;
  Right_vx      : Integ16;
  Adjoin        : Integ16;
  Mirror        : Integ16;
  Mark          : Integ16;  { reserved for multiple selection }
  Walk          : Integ16;
  Light         : Integ16;
  Flag1         : LongInt;
  Flag2         : LongInt;
  Flag3         : LongInt;
  Reserved      : Integ16; { used in the deformations }
  Mid,
  Top,
  Bot,
  Sign          : TTexture;
  Elevator      : Boolean;
  Trigger       : Boolean;
  InfClasses    : TStringList;
  Cycle         : Integer; {This field is valid only just after calculating it}
  InfItems      : TStringList; {NEW}
  constructor Create;
  procedure   Free;
end;

{ VERTEX }
TVERTEX = class(TObject)
  Mark          : Integ16;  { reserved for multiple selection }
  X             : Real;
  Z             : Real;
end;

{ OBJECT }
TOB = class(TObject)
  Mark          : Integ16;
  Sec           : Integer;    {for object layering}
                              {DON'T use Integ16 for this one, it is used
                               as a VAR parameter in a fx somewhere}
  X, Y, Z       : Real;
  Yaw, Pch, Rol : Real;
  Diff          : Integ16;
  ClassName     : String[16];
  DataName      : String[16];
  Seq           : TStringList;
  Col           : TColor;
  Otype         : Integ16;    { reserved for different displays  }
  Special       : Integ16;    { reserved for generators objects  }
  constructor Create;
  procedure   Free;
end;

{ RESOURCES & TOOLKIT TYPES }
TRESOURCE = record
 Name           : String;
 Ext            : String;
 SizeX          : LongInt;
 SizeY          : LongInt;
 InsertX        : LongInt;
 InsertY        : LongInt;
 OffsetX        : Integer;
 OffsetY        : Integer;
 Multiple       : Boolean;
 Number         : Integer;
 Current        : Integer;
 Compressed     : Boolean;
 Flipped        : Boolean;
 Transparent    : Boolean;
 Colors         : Integer;
 ColFrom        : Integer;
 ColTo          : Integer;
end;

TYPE
 { ARHHHHH - Since 2009 CHARS are 2 bytes!!!!! - Karjala }
 TBM_HEADER = record
   BM_MAGIC    : array[1..4] of AnsiChar;
   SizeX       : SmallInt;
   SizeY       : SmallInt;
   idemX       : SmallInt;
   idemY       : SmallInt;
   transparent : Byte;
   logSizeY    : Byte;
   Compressed  : SmallInt;
   DataSize    : LongInt;
   filler      : array[1..12] of AnsiChar;
 end;

 TBM_SUBHEADER = record
   SizeX       : Integ16;
   SizeY       : Integ16;
   idemX       : Integ16;
   idemY       : Integ16;
   DataSize    : LongInt;
   logSizeY    : Byte;
   filler1     : array[1..11] of AnsiChar;
   transparent : Byte;
   filler2     : array[1..3] of AnsiChar;
 end;

 TFME_HEADER1 = record
   InsertX     : LongInt;
   InsertY     : LongInt;
   Flip        : LongInt;
   Header2     : LongInt;
   UnitWidth   : LongInt;    { cell width in feet}
   UnitHeight  : LongInt;    { cell height in feet}
   pad3,
   pad4        : LongInt;
 end;

 TFME_HEADER2 = record
   SizeX       : LongInt;
   SizeY       : LongInt;
   Compressed  : LongInt;
   DataSize    : LongInt;
   ColOffs     : Longint;    { offset to column table = 0 in all known cases
                               because the table follows }
   pad1        : LongInt;
 end;

TYPE
 TDELTH = record
  OffsX,
  OffsY,
  SizeX,
  SizeY   : Integ16;
 end;

 TDELTL = record
  Size,
  PosX,
  PosY    : Integ16;
 end;

T3DO_object = class(TObject)
  Name          : String[30];
  Vertices      : TStringList;
  Triangles     : TStringList;
  Quads         : TStringList;
  constructor Create;
  procedure   Free;
end;

T3DO_VERTEX = class(TObject)
 X, Y, Z        : Real;
end;

T3DO_TRIANGLE = class(TObject)
 A, B, C        : Integer;
end;

T3DO_QUAD = class(TObject)
 A, B, C, D     : Integer;
end;

TPLACEMARKER = class(TObject)
 XOff, ZOff, Lay : Integer;
 ZoomFactor      : Real;
end;

VAR
 Ini                 : TIniFile;
 WDFUSEdir           : String[255];
 DarkInst            : TFileName;
 RenderInst          : TFileName;
 DarkCD              : String[20];

 DARKgob,
 SPRITESgob,
 TEXTURESgob,
 SOUNDSgob           : TFileName;
 ChkCmdLine          : Boolean;
 INFEditor           : TFileName;
 Voc2Wav             : TFileName;
 Wav2Voc             : TFileName;
 TestLaunch          : Boolean;
 Backup_Method       : Integer;
 CurrentGOB          : TFileName;
 CurrentLFD          : TFileName;
 CurrentLFDir        : TFileName;
 CurrentGOBDir       : TFileName;

 inf                 : System.TextFile;
 INFLoaded           : Boolean;
 INFModified         : Boolean;
 INFComments         : TStringList;
 INFErrors           : TStringList;
 INFLevel            : TStringlist;
 INFMisc             : Integer;
 INFRemote           : Boolean;
 INFSector           : Integer;
 INFWall             : Integer;

 gol                 : System.TextFile;
 GOLComments         : TStringList;
 GOLErrors           : TStringList;
 GOLItems            : TStringList;

 CreateItem          : Boolean;
 OldSel              : Integer;
 _VGA_MULTIPLIER     : Integer;
 HPALPalette         : HPalette;
 HPLTTPalette        : HPalette;
 TheRES              : String[255];
 ThePAL              : String[255];
 CONFIRMMultiDelete  : Boolean;
 CONFIRMMultiUpdate  : Boolean;
 CONFIRMMultiInsert  : Boolean;
 CONFIRMSectorDelete : Boolean;
 CONFIRMWallDelete   : Boolean;
 CONFIRMVertexDelete : Boolean;
 CONFIRMObjectDelete : Boolean;
 CONFIRMWallSplit    : Boolean;
 CONFIRMWallExtrude  : Boolean;
 USERName            : string[20];
 USERreg             : string[12];
 USERemail           : string[40];
 NOT_REG             : array[0..127] of char;
 num1                : Integer;
 num2                : Integer;
 num3                : Integer;
 XOffsetStart        : Integer;
 ZOffsetStart        : Integer;
 MoveXOffset         : Integer;
 MoveYOffset         : Integer;
 MenuYOffset         : Integer;

 { History Lists }
 GOB_History         : TStringList;
 LFD_History         : TStringList;
 PAL_History         : TStringList;
 PLT_History         : TStringList;

 FINDSC_VALUE     : String[20];
 RES_PICKER_MODE  : Integer;
 RES_PICKER_VALUE : String[20];
 OBCLASS_VALUE    : String[20];
 OBSEQNUMBER      : Integer;
 OBSEL_VALUE      : String[20];

 UsePlusVX     : Boolean;
 UsePlusOBShad : Boolean;
 SpecialsVX    : Boolean;
 SpecialsOB    : Boolean;
 vx_scale      : Integer;
 vx_dim_max    : Integer;
 bigvx_scale   : Integer;
 bigvx_dim_max : Integer;
 ob_scale      : Integer;
 ob_dim_max    : Integer;
 bigob_scale   : Integer;
 bigob_dim_max : Integer;
 col_back      : TColor;
 col_wall_n    : TColor;
 col_wall_a    : TColor;
 col_shadow    : TColor;
 col_grid      : TColor;
 col_select    : TColor;
 col_multis    : TColor;
 col_elev      : TColor;
 col_trig      : TColor;
 col_goal      : TColor;
 col_secr      : TColor;

 col_dm_low    : TColor;
 col_dm_high   : TColor;
 col_dm_gas    : TColor;
 col_2a_water  : TColor;
 col_2a_catwlk : TColor;
 col_sp_sky    : TColor;
 col_sp_pit    : TColor;
 col_sec_inner : TColor;

DOOM          : Boolean;
FIRSTLOAD     : Boolean;
NO_INI        : Boolean;
LOADPREVPRJ   : Boolean;
MAP_RECT      : TRect;
MAP_SEC       : TStringList;
MAP_DEBUG     : TSector;
MAP_OBJ       : TStringList;
TX_LIST       : TStringList;
POD_LIST      : TStringList;
SPR_LIST      : TStringList;
FME_LIST      : TStringList;
SND_LIST      : TStringList;
PROJECTFile   : TFileName;
LEVELName     : String;
LEVELPath     : TFileName;
LEVELBNum     : Integer;
LEVELloaded   : Boolean;
OFILELoaded   : Boolean;
INFFILELoaded : Boolean;
GOLFILELoaded : Boolean;
LEV_VERSION,
LEV_LEVELNAME,
LEV_PALETTE,
LEV_MUSIC     : String[20];
LEV_PARALLAX1,
LEV_PARALLAX2 : Real;
O_VERSION,
O_LEVELNAME   : String[20];
INF_VERSION,
INF_LEVELNAME : String[20];
GOL_VERSION   : String[20];
Scale         : Real;
ZoomInLock      : Boolean;
ZoomOutLock     : Boolean;
ZoomTimer       : Integer;
GridON        : Boolean;
GRID          : Real;
GRID_OFFSET   : Integer;
ScreenX       : Integer;
ScreenZ       : Integer;
ScreenCenterX : Integer;
ScreenCenterZ : Integer;
Xoffset       : Integer;
Zoffset       : Integer;
SHADOW        : Boolean;
OBSHADOW      : Boolean;
OBDIFF        : Integer;
OBLAYERMODE   : Integer; {0 : no layering, 1 floor, 2 ceiling}
LAYER         : Integer;
LAYER_MIN,
LAYER_MAX     : Integer;
SHADOW_LAYERS : array[-9..9] of Boolean;
MAP_MODE      : Integer;
MAP_TYPE      : Integer;
SC_HILITE,
WL_HILITE,
VX_HILITE,
OB_HILITE,
SC_HILITE_ORG,
WL_HILITE_ORG,
VX_HILITE_ORG,
OB_HILITE_ORG : Integer;
SUPERHILITE   : Integer;
SC_MULTIS,
WL_MULTIS,
VX_MULTIS,
OB_MULTIS     : TStringList;

MAP_GLOBAL_UNDO : TList<TStringList>;
MAP_GLOBAL_UNDO_INDEX : Integer;
MAP_SEC_UNDO     : TStringList;
MAP_OBJ_UNDO     : TStringList;
MAP_GUI_UNDO     : TStringList;
UNDO_LIMIT       : Integer;

{ Sometimes there are recursive calls - only store the root Undo }
IGNORE_UNDO      : Boolean;
APPLYING_UNDO    : Boolean;
MAP_MODE_UNDO    : Integer;
SC_HILITE_UNDO,
WL_HILITE_UNDO,
VX_HILITE_UNDO,
OB_HILITE_UNDO   : Integer;
XOffset_UNDO,
ZOffset_UNDO     : Integer;
Scale_UNDO       : Real;
LAYER_UNDO       : Integer;
LAYER_MIN_UNDO,
LAYER_MAX_UNDO   : Integer;

MAP_SEC_CLIP     : TStringList;
MAP_OBJ_CLIP     : TStringList;

MULTISEL_RECT : Boolean;
MULTISEL_MODE : String[1];
MULTISEL_SPC  : Boolean;
FlagEditorVal : LongInt;
FastSCROLL    : Boolean;
FastDRAG      : Boolean;
IsDRAG        : Boolean;
FirstDRAG     : Boolean;
FirstMDown    : Boolean;
ORIGIN        : TPoint;
DESTIN        : TPoint;
IsFOCUSRECT   : Boolean;
FOCUSRECT     : TRect;
IsRULERLINE   : Boolean;
MODIFIED      : Boolean;
BACKUPED      : Boolean;
TMPSector,
ORISector     : TSector;
TMPWall,
ORIWall       : TWall;
TMPVertex,
ORIVertex     : TVertex;
TMPObject,
ORIObject     : TOB;
TMPHWindow    : HWnd;

TheRESOURCE   : TRESOURCE;
CurFrame      : Integer;

quantize     : array[0..255] of Byte;
PALbuffer    : array[0..767] of Byte;
BMPpalette   : array[0..767] of Byte;
COLtable     : array[0..1023] of Byte;

tmpWalls     : TStringList;

MAP_MARKERS  : TStringList;


DUKE_CEILIPIC : Integ16;
DUKE_FLOORPIC : Integ16;
DUKE_WALLPIC  : Integ16;
DUKE_HSCALE   : Integ16;
DUKE_VSCALE   : Integ16;
DUKE_1STTILE  : Integ16;
DUKE_XOFFSET  : LongInt;
DUKE_ZOFFSET  : LongInt;
DUKE_YOFFSET  : LongInt;

DOSBOX_PATH   : String;
DOSBOX_CONF   : String;
LAUNCHER_TYPE : String;
ShortCutProc  : TShortCutEvent;

ZoneInfo : TTimeZoneInformation;

Log: ILogWriter;
LogName : String;
LogFilePath : String;
LogPath : String;
UseLog : Boolean;

EOL : String;
INF_SEP     : String;
INF_READ    : Boolean;
INFCache    : TDictionary<String, String>;


{ Screen to Map and Map to Screen converters - Karjala
  This basically converts the X/Y screen positions to the DF map offsets }
function S2MX(x : Real) : Real;
function S2MZ(z : Real) : Real;
function M2SX(x : Real) : Integer;
function M2SZ(z : Real) : Integer;

function SortVX(List: TStringList; idx1, idx2: Integer): Integer;



{*****************************************************************************}
implementation

constructor TInfClass.Create;
begin
  inherited Create;
  SlaCli := TStringList.Create;
end;

procedure  TInfClass.Free;
begin
  SlaCLi.Free;
  inherited Free;
end;


constructor TSector.Create;
begin
  inherited Create;
  Vx := TStringList.Create;
  Wl := TStringList.Create;
  InfClasses := TStringList.Create;
  InfItems := TStringList.Create;
end;

procedure  TSector.Free;
begin
  Vx.Free;
  Wl.Free;
  InfClasses.Free;
  InfItems.Free;
  inherited Free;
end;

constructor TWall.Create;
begin
  inherited Create;
  InfClasses := TStringList.Create;
  InfItems := TStringList.Create;
end;

procedure  TWall.Free;
begin
  InfClasses.Free;
  InfItems.Free;
  inherited Free;
end;

constructor TOB.Create;
begin
  inherited Create;
  Seq := TStringList.Create;
end;

procedure  TOB.Free;
begin
  Seq.Free;
  inherited Free;
end;

constructor TINFSequence.Create;
begin
  inherited Create;
  Comments := TStringList.Create;
  Classes  := TStringList.Create;
end;

procedure  TINFSequence.Free;
begin
  Comments.Free;
  Classes.Free;
  inherited Free;
end;

constructor TINFCls.Create;
begin
  inherited Create;
  SlaCliTgt := TStringList.Create;
  Stops := TStringList.Create;
  Actions := TStringList.Create;
end;

procedure  TINFCls.Free;
begin
  SlaCliTgt.Free;
  Stops.Free;
  Actions.Free;
  inherited Free;
end;

constructor T3DO_object.Create;
begin
  inherited Create;
  Vertices  := TStringList.Create;
  Triangles := TStringList.Create;
  Quads     := TStringList.Create;
end;

procedure  T3DO_object.Free;
begin
  Vertices.Free;
  Triangles.Free;
  Quads.Free;
  inherited Free;
end;

function S2MX(x : Real) : Real;
var s2mx_result : Real;
    s2mx_key : String;
begin
  S2MX := Xoffset + ((x - ScreenCenterX) / scale);
end;

function S2Mz(z : Real) : Real;
var s2mz_result : Real;
    s2mz_key : String;
begin
  S2MZ := Zoffset + ((ScreenCenterZ - z) / scale);
end;


function M2SX(x : Real) : Integer;
var m2sx_result : Integer;
    m2sx_key : String;
begin
  M2SX := Round( ScreenCenterX + ( (x - xoffset) * scale) );
end;

function M2SZ(z : Real) : Integer;
var m2sz_result : Integer;
    m2sz_key : String;
begin
  M2SZ := Round( ScreenCenterZ + ((Zoffset - z) * scale) );
end;

function SortVX(List: TStringList; idx1, idx2: Integer): Integer;
var
  s1 : Integer;
  s2 : Integer;
  w1 : Integer;
  w2 : Integer;
begin
  s1 := StrToInt(Copy(List[idx1],1,4));
  w1 := StrToInt(Copy(List[idx1],5,4));
  s2 := StrToInt(Copy(List[idx2],1,4));
  w2 := StrToInt(Copy(List[idx2],5,4));
  if s1 < s2 then
    Result := -1
  else
    begin
      if s2 > s1 then
        Result := 1
      else
        begin
          if w1 < w2 then
            Result := 1
          else
            if w1 = w2 then
              Result := 0
            else
              Result := -1
        end;
    end;
end;

begin

  // First time launching or deleted ini file
  NO_INI := FileExists(ExtractFilePath(ParamStr(0)) + 'wdfuse.ini');

  Ini  := TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'wdfuse.ini');
  UseLog   := Ini.ReadBool('DARK FORCES', 'Logger', True);
  LogPath  := ExtractFilePath(ParamStr(0)) + 'log';

  if UseLog then
    begin
      if not directoryexists(LogPath) then CreateDir(LogPath);
      Log := BuildLogWriter([TLoggerProFileAppender.Create(10, 5000, LogPath)])
    end
  else
    Log := BuildLogWriter([]);

  LogName := formatdatetime('_mmm-d-yyy_hh-nn-ss',Now);
  LogFilePath := LogPath + '\' + 'wdfuse32.00.' + LogName + '.log';
  Log.Info('Starting WDFUSE...',LogName);
  Log.info('Will Write Logs to ' + LogFilePath, LogName);
  log.Info('WDFUSE Compile Timestamp ' + floattostr(PImageNtHeaders(HInstance +
   Cardinal(PImageDosHeader(HInstance)^._lfanew))^.FileHeader.TimeDateStamp), LogName);



  // to be overriden later
  UNDO_LIMIT  := 32;
  FIRSTLOAD   := TRUE;
  DOOM        := FALSE;
  MAP_MODE    := MM_VX;
  MAP_TYPE    := MT_NO;
  SHADOW      := TRUE;
  OBSHADOW    := FALSE;
  OBDIFF      := 0;
  GridON      := FALSE;
  GRID        := 8;
  LAYER       := 0;
  OBLAYERMODE := 1; {layer to floor}

  SC_HILITE   := 0;
  WL_HILITE   := 0;
  VX_HILITE   := 0;
  OB_HILITE   := 0;

  SUPERHILITE := -1;
  INFRemote   := FALSE;
  INFMisc     := -1;

  SC_MULTIS   := TStringList.Create;
  WL_MULTIS   := TStringList.Create;
  VX_MULTIS   := TStringList.Create;
  OB_MULTIS   := TStringList.Create;

  MULTISEL_RECT := False;
  MULTISEL_MODE := 'T';
  MULTISEL_SPC  := FALSE;

  FastSCROLL  := TRUE;
  FastDRAG    := TRUE;
  IsDRAG      := FALSE;
  IsFOCUSRECT := FALSE;

  ZoomTimer := GetTickCount;

  num1        := 13;
  num2        := 20;
  num3        := 57;

  EOL         := AnsiString(#13#10);
  INF_SEP     := StringOfChar('-', 100);

  ShortCutProc := NIL;

end.

