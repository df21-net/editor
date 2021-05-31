unit GlobalVars;

interface
uses Graphics, SysUtils, Registry, Classes;
Const
  VersionString  : String   = 'Version 1.0 beta 2';
  perp_ratio          = 0.25e0;
  MM_SC               = 0;
  MM_WL               = 1;
  MM_VX               = 2;
  MM_OB               = 3;
  MT_NO               = 0;
  MT_LI               = 1;
  MT_DM               = 2;
  MT_2A               = 3;
  MT_SP               = 4;
 RegBase='\Software\Code Alliance\LawMaker';
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

 cc_NeverFix=1;
 cc_Fix=2;
 cc_Ask=0;

 lev_default=0;
 lev_Keep=1;
 lev_ToPCX=2;


  bigvx_scale   : Integer=cbigvx_scale;
  bigvx_dim_max : Integer=cbigvx_dim_max;
  ob_scale      : Integer=cob_scale;
  ob_dim_max    : Integer=cob_dim_max;
  vx_scale      : Integer=cvx_scale;
  vx_dim_max    : Integer=cvx_dim_max;
  bigob_scale   : Integer=cbigob_scale;
  bigob_dim_max : Integer=cbigob_dim_max;

 Filter_OLLevelFiles='Outlaws files(*.lab;*.lvt)|*.lab;*.lvt|LAB Files(*.lab)|*.lab|Levels(*.lvt)|*.lvt';
 Filter_DFLevelFiles='DF files(*.gob;*.lev)|*.gob;*.lev';
 Filter_ScriptFiles='All scripts|*.lab;*.inf;*.itm;*.rc?;*.atx;*.phy;*.chk;*.msc|INF Scripts|*.inf|RCP Scripts(*.rc?)|*.rc?|ITM files|*.ITM|Other scripts|*.atx;*.phy;*.chk;*.msc';
 Filter_NonOLLevelFiles='All Files(*.*)|*.*|All readable files|*.lab;*.gob;*.lev;*.lvt|DF files(*.gob;*.lev)|*.gob;*.lev';

Type
    TWinPos=record
     WTop,Wleft,
     Wwidth,Wheight:Integer;
    end;

    TFontAttrib=record
     name:string;
     size:integer;
     style:byte;
    end;
Var
GameDir        : String; {Outlaws Directory}
BaseDir        : String; {Base LawMaker directory}
Recents        : TStringList;
CDDir      : String;
textures_Lab,
Weapons_lab,
Objects_lab,
sounds_lab,
Outlaws_lab,
Geo_lab,
taunts_lab,
olpatch1_lab,
olpatch2_lab: String;
Backup_Method  : Integer;
LogTestSession:Boolean;
cc_FixErrors:Integer=cc_Ask; {way to autofix consistency errors}
lev_textures:Integer=lev_default;

_VGA_MULTIPLIER     : Integer;

MapperPos,
SectorEditPos,
WallEditPos,
VertexEditPos,
ObjectEditPos,
ToolsPos:TWinPos;

SCEditOnTop,
WLEditOnTop,
VXEditOnTop,
OBEditOnTop,
ToolsOnTop,
ScriptOnTop:Boolean;

ScFont:TFontAttrib=(name:'';size:0;style:0);

Type TConfirmRec=record
                  value:boolean;
                  text:String;
                  rkey:String
                 end;
Const
 c_MDelete=1;
 c_MUpdate=2;
 c_MInsert=3;
 c_SCDelete=4;
 c_WLDelete=5;
 c_VXDelete=6;
 c_OBDelete=7;
 c_WLSplit=8;
 c_WLExtrude=9;
 c_VXOrderFix=10;

Var

Confirms:array[1..10] of TConfirmRec=(
(value:true ;text:'Multiple delete';rkey:'MDelete'),
(value:true ;text:'Multiple update';rkey:'MUpdate'),
(value:true ;text:'Multiple insert';rkey:'MInsert'),
(value:false ;text:'Sector delete';rkey:'SCDelete'),
(value:false;text:'Wall delete';rkey:'WLDelete'),
(value:false;text:'Vertex delete';rkey:'VXDelete'),
(value:false;text:'Object delete';rkey:'OBDelete'),
(value:false;text:'Wall split';rkey:'WLSplit'),
(value:false;text:'Wall extrude';rkey:'WLExtrude'),
(value:true;text:'Vertex order fix';rkey:'VXOrderFix'));

Const
{ShowMessage() modifieds}
  extr_ratio          = 0.25e0;
  sm_ShowInfo:boolean=false;
  sm_ShowWarnings:boolean=true;

 Ccol_back           = clBlack;
 Ccol_wall_n         = clLime;
 Ccol_wall_a         = clGreen;
 Ccol_shadow         = clGray;
 Ccol_grid           = clFuchsia;
 Ccol_select         = clRed;
 Ccol_select_multi   = clFuchsia;
 Ccol_multis         = clWhite;
 Ccol_elev           = clYellow;
 Ccol_trig           = clAqua;
 Ccol_goal           = clPurple;
 Ccol_secr           = clPurple;

 Ccol_dm_low         = clGreen;
 Ccol_dm_high        = clYellow;
 Ccol_dm_gas         = clRed;
 Ccol_2a_water       = clBlue;
 Ccol_2a_catwlk      = clGray;
 Ccol_sp_sky         = clAqua;
 Ccol_sp_pit         = clGray;
 Ccol_Object         = clGray;

  col_Object    : TColor=Ccol_Object;
  col_shadow    : TColor=Ccol_shadow;
  col_wall_n    : TColor=Ccol_wall_n;
  col_wall_a    : TColor=Ccol_wall_a;
  col_elev      : TColor=Ccol_elev;
  col_trig      : TColor=Ccol_trig;
  col_goal      : TColor=Ccol_goal;
  col_secr      : TColor=Ccol_secr;
  col_multis    : TColor=Ccol_multis;
  col_select    : TColor=Ccol_select;
  col_Select_multi: TColor=Ccol_select_multi;
  col_grid      : TColor=Ccol_grid;
  col_dm_low    : TColor=Ccol_dm_low;
  col_dm_high   : TColor=Ccol_dm_high;
  col_dm_gas    : TColor=Ccol_dm_gas;
  col_2a_water  : TColor=Ccol_2a_water;
  col_2a_catwlk : TColor=Ccol_2a_catwlk;
  col_sp_sky    : TColor=Ccol_sp_sky;
  col_sp_pit    : TColor=Ccol_sp_pit;
  col_back      : TColor=Ccol_back;

Function ProjectDir:String;
Function DoConfirm(what:integer):Boolean;

Procedure GetFont(var fa:TFontAttrib;f:TFont);
Procedure SetFont(f:TFont;const fa:TFontAttrib);

implementation
uses Forms, Mapper;

Function DoConfirm(what:integer):Boolean;
begin
 Result:=Confirms[what].Value;
end;


Function ProjectDir:String;
begin
 Result:=MapWindow.ProjectDirectory;
end;

Procedure GetFont(var fa:TFontAttrib;f:TFont);
var fs:TFontStyles;
    bs:Byte absolute fs;
begin
 fa.Name:=f.Name;
 fa.size:=f.size;
 fs:=f.Style;
 fa.Style:=bs;
end;

Procedure SetFont(f:TFont;const fa:TFontAttrib);
var fs:TFontStyles;
    bs:Byte absolute fs;
begin
 if fa.Name='' then exit;
 f.Name:=fa.Name;
 f.size:=fa.size;
 bs:=fa.Style;
 f.Style:=fs;
end;


Initialization
begin
 BaseDir:=ExtractFilePath(Paramstr(0));
 Application.HelpFile := BaseDir+'Lawmaker.hlp';
 Recents:=TStringList.Create;
end;

end.
