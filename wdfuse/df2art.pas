unit df2art;
interface
uses Wintypes,WinProcs,SysUtils, DFFiles, Classes, M_Progrs;
Const
     TilesPerArt=256;
     MaxHeight=6000;
Type
TPaletteConversionTable=record
                         cnv:array[0..255] of byte;
                         Color0:byte;
                        end;
TSpecialTileRec=Class(TObject)
                 TileN:word;
                 waxN:byte;
                end;
TIndex=Class(Tobject)
        Index:Integer;
       end;

TTileHeader=record
 Version:longint;
 NTiles:longint;
 First,Last:longint;
end;
TTileDimensions=array[0..TilesPerArt-1] of word;
TColumn=array[0..MaxHeight-1] of byte;
TTileAnim=record
 anim:byte;
 dx,dy:ShortInt;
 speed:byte;
end;
TTileAnims=array[0..TilesPerArt-1] of TTileAnim;
TGRP_Entry_Info=class(TObject)
           fPos,
           fsize:longint;
          end;

Const
     ArtDataStart=sizeof(TTileHeader)+sizeof(TTileDimensions)*2+sizeof(TTileAnims);
{$IFDEF WDF32}
J_CNV:TPaletteConversionTable=(
Cnv:(0,31,79,78,76,72,248,247,247,133,251,250,250,249,249,254,254,253,253,219,
     215,212,200,140,245,245,245,245,245,245,245,245,29,28,26,25,24,24,22,21,20,
     19,18,17,16,15,14,13,12,12,11,11,10,10,9,8,8,7,6,6,5,5,4,166,12,11,10,10,92,
     8,7,7,6,5,4,3,83,98,1,0,223,62,60,58,56,54,52,50,48,146,144,144,194,193,192,
     36,201,200,200,199,199,198,197,197,196,195,195,194,135,193,192,192,121,116,
     115,113,110,250,250,250,250,240,249,240,240,240,38,36,191,191,207,206,206,205,
     204,204,203,202,202,201,199,199,198,198,148,197,196,195,136,135,134,133,254,
     254,253,253,253,253,227,252,248,248,247,247,137,246,246,132,201,200,200,199,
     197,137,136,134,52,51,50,49,48,47,46,45,44,42,41,40,39,38,37,39,79,78,77,76,
     76,74,73,72,72,71,71,69,67,67,67,67,158,157,156,156,154,153,152,150,150,150,
     50,198,197,197,196,196,196,195,195,43,195,134,134,133,133,132,132,131,130,129,
     129,128,128,49,223,185,178,108,106,105,102,101,99,98,194,197,198,31);
Color0:0);
S_CNV:TPaletteConversionTable=(
Cnv:(0,31,79,79,77,75,248,238,138,133,251,250,
250,249,249,254,254,253,253,158,217,212,210,140,245,245,245,245,245,245,245,245,
29,28,26,25,25,24,22,21,20,19,18,17,16,15,14,13,12,12,11,11,10,10,9,8,8,7,6,6,5,
5,4,166,64,93,91,92,92,89,87,87,6,85,84,3,83,98,1,0,223,62,60,58,56,54,52,148,147
,146,144,144,194,193,192,36,201,200,200,199,199,198,197,197,196,195,195,194,135,
193,192,192,124,121,116,113,112,250,250,250,110,108,249,240,240,240,38,36,191,191,
207,206,206,205,204,204,203,202,202,201,199,199,198,198,47,197,196,195,136,135,
134,133,254,254,253,253,253,253,227,252,248,248,247,247,137,246,246,132,202,200,
200,199,197,137,136,134,202,51,50,49,48,47,46,45,44,42,41,40,39,38,37,39,79,78,77,
76,76,74,73,72,72,71,71,69,67,67,67,67,93,94,93,91,92,91,92,90,92,91,91,91,89,87,
87,86,6,87,5,5,86,4,85,3,3,2,2,82,1,1,0,0,253,253,227,227,227,252,252,252,252,224,
83,82,82,0,0,31);
Color0:0);
R_CNV:TPaletteConversionTable=(
Cnv:(0,31,79,78,76,72,248,247,247,133,251,250,250,249,249,254,254,253,253,219,215,212,
200,140,245,245,245,245,245,245,245,245,29,28,26,25,24,24,22,21,20,19,18,17,16,
15,14,13,12,12,11,11,10,10,9,8,8,7,6,6,5,5,4,166,12,11,10,10,92,8,7,7,6,5,4,3,
83,98,1,0,223,62,60,58,56,54,52,50,48,146,144,144,194,193,192,36,201,200,200,199,
199,198,197,197,196,195,195,194,135,193,192,192,121,116,115,113,110,250,250,250,
250,240,249,240,240,240,38,36,191,191,207,206,206,205,204,204,203,202,202,201,
199,199,198,198,148,197,196,195,136,135,134,133,254,254,253,253,253,253,227,252,
248,248,247,247,137,246,246,132,201,200,200,199,197,137,136,134,52,51,50,49,48,
47,46,45,44,42,41,40,39,38,37,39,79,78,77,76,76,74,73,72,72,71,71,69,67,67,67,
67,29,28,26,78,77,76,75,73,72,72,70,69,68,67,66,65,65,94,93,93,91,90,89,89,87,
86,86,224,224,83,83,82,30,30,29,29,28,79,79,79,78,77,77,76,76,76,75,31);
Color0:0);

G_CNV:TPaletteConversionTable=(
Cnv:(0,31,79,78,76,72,248,247,247,133,251,250,250,249,249,254,254,253,253,219,215,212,
200,140,245,245,245,245,245,245,245,245,27,25,190,189,188,187,186,184,183,183,
54,180,50,50,49,48,46,46,45,44,43,43,42,41,40,40,39,133,132,132,131,131,175,174,
43,42,40,40,39,39,132,132,36,130,130,129,129,0,219,217,215,203,202,201,199,197,
139,137,136,135,134,133,132,131,143,143,142,142,140,140,139,139,137,137,136,135,
246,246,133,133,117,241,241,149,147,145,240,240,240,240,100,192,192,133,132,131,
207,206,205,204,212,211,210,209,208,142,142,141,141,140,140,140,139,138,137,136,
136,246,246,246,254,253,253,253,252,252,224,82,248,248,247,247,247,136,246,133,
208,143,142,140,139,137,136,246,142,141,141,140,139,138,137,137,136,135,134,134,
133,132,132,133,79,78,77,76,74,72,72,71,69,69,67,67,65,64,95,253,210,209,200,200,
200,200,200,199,199,141,140,140,139,139,138,137,137,137,136,135,135,135,134,134,
133,133,132,132,131,131,131,130,186,184,183,181,180,50,49,48,46,45,43,43,42,40,
39,31);
Color0:0);

{$ENDIF}

Type

TOriginalTiles=class
 hgrp:integer;
 Arts:TStringList;
 Cur_art:integer;
 xs,ys:TTileDimensions;
 anm:TTileAnims;
 CurPos,fpos,cursize:longint;
 bi:TBitmapInfo;
 Constructor Create(GRP:TFileName);
 Procedure SetTile(N:integer);
 Procedure GetInfo(var b:TbitmapInfo);
 Procedure GetColumn(var b;N:integer);
 Destructor Free;
Private
 Procedure Fread(var b;size:integer);
 Procedure SetArt(N:integer);
end;

TDukeArtTiles=class
 Tiles:integer;
 Tile_org:longint;
 Start_tile:integer;
 Cur_start_tile:integer;
 Start_art,Cur_art:integer;
 ART_open:boolean;
 Fin:TDFImage;
 Textures_gob,Sprites_gob:TFilename;
 Duke3D_grp:TFilename;
 InDir:TfileName;
 fout:integer;
 xs,ys:TTileDimensions;
 anm:TTileAnims;
 col:Tcolumn;
 err_msg:String;
 to_dir:string;
 rcnv,cnv:TPaletteConversionTable;
 AllowTransparent:boolean;
 Logics:TStringList;
 Files:TStringList;
 SecbaseCNV,JabshipCNV,GromasCNV,RoboticsCNV:TPaletteConversionTable;
 constructor Create(dir:string;First_art:integer);
 Procedure SetConversionTable(var t:TPaletteConversionTable);
 Procedure SetReverseConversionTable(var t:TPaletteConversionTable);
 Function AddDFFile(Fname:TFileName):integer;
 Function ErrorMessage:String;
 Function AddSpecialTiles(Script:TFileName):integer;
 Function GetTileByLogic(logic:string):integer;
 Function  GetAllowTransparent : Boolean;
 procedure SetAllowTransparent(t : Boolean);
 Procedure SetGOBs(textures,sprites:TFileName);
 Procedure SetGRP(Grp:TfileName);
 Procedure SetInDir(Dir:TFileName);
 Function SetLogic2Tile(Logic2Tile:TFileName):integer;
 Function SetDuke_wdf(duke_wdf:TFileName):integer;
 Function SeeInDuke_wdf(Fname:TfileName):Integer;
 Destructor Free;
Private
 Function OpenImage(name:TFileName):integer;
 Procedure InitValues(artn:integer);
 Function CreateArt(num:integer):integer;
 Function CloseArt:integer;
 Function Fwrite(var b;size:integer):integer;
 Function NewTile(bi:TbitmapInfo;animfd:byte):integer;
 Function NewTileAt(bi:TbitmapInfo;Tile:integer):integer;
 Function AddColumn:integer;
 Function GetLastArt:integer;
 Procedure Error(e:string);
 Procedure PaletteConvert(p:pchar;size:word;var cnv:TPaletteConversionTable);
 Procedure LoadCNVs;
{published}
 property LastArt: Integer read GetLastArt;
end;

TDFSounds=class
 blank_voc:array[0..1129] of byte;
 SndGob:TGOBFile;
 buffer:array[0..16384] of byte;
 constructor Create(sounds_gob:TFileName);
 Function Extract(Script,dir:TFileName):integer;
 destructor Free;
end;

Function GetWord(s:string;p:integer;var w:string):integer;

implementation
{$i grptypes.inc}
Type
    Logic2Tile=record
                Logic:string;
                Tile:Integer;
               end;

Function GetArtName(n:integer):string;
begin
 result:='TILES'+Format('%-3.3d',[n])+'.ART';
end;
{$IFNDEF WDF32}
Procedure SetLength(var s:string;len:byte);
begin
 s[0]:=char(len);
end;
Function Trim(s:string):String;
var i:integer;
begin
 i:=1;
 Result:=s;
 While (Result[i]=' ') and (Length(Result)<>0) do Delete(Result,1,1);
 While (Result[Length(Result)]=' ') and (Length(Result)<>0) do SetLength(Result,Length(Result)-1);
end;
{$ENDIF}
Function GetDukeDX(var bi:Tbitmapinfo):integer;
begin
 result:=-(bi.dx+bi.w div 2);
 if result>127 then result:=127;
 if result<-128 then result:=-128;
end;

Function GetWord(s:string;p:integer;var w:string):integer;
var b,e:integer;
begin
 b:=p;
 While (s[b] in [' ',#9]) and (b<=length(s)) do inc(b);
 e:=b;
 While (not (s[e] in [' ',#9])) and (e<=length(s)) do inc(e);
 w:=Copy(s,b,e-b);
 GetWord:=e;
end;

Function GetDukeDY(var bi:Tbitmapinfo):integer;
begin
 result:=-(bi.dy+bi.h);
 if result>127 then result:=127;
 if result<-128 then result:=-128;
end;


Procedure TOriginalTiles.Fread(var b;size:integer);
begin
 FileRead(hgrp,b,size);
end;

Constructor TOriginalTiles.Create(GRP:TFileName);
var gh:TGRP_Header;
    ge:TGRP_Entry;
    fpos:longint;
    tge:TGRP_Entry_info;
    i:integer;
    s:array[0..11] of char;
begin
 Cur_art:=-1;
 Arts:=TstringList.Create;
 hgrp:=FileOpen(GRP,fmOpenRead or fmShareDenyNone);
 if hgrp<0 then raise Exception.CreateFmt('Could not open GRP %s' ,[GRP]);
 FRead(gh,sizeof(gh));
 if gh.sig<>GRP_Sig then raise Exception.CreateFmt('Could not Create GRP %s' ,[GRP]);
 Fpos:=Sizeof(gh)+gh.nentries*sizeof(ge);
 for i:=1 to gh.nentries do
 begin
  FRead(ge,sizeof(ge));
  StrLCopy(s,ge.name,5);
  if StrIComp(s,'Tiles')=0 then
  begin
   StrLCopy(s,ge.name,12);
   StrUpper(s);
   tge:=TGRP_Entry_info.create;
   Tge.fpos:=fpos;
   tge.fsize:=ge.size;
   Arts.AddObject(StrPas(s),tge);
  end;
  inc(fpos,ge.size);
 end;
end;

Procedure TOriginalTiles.SetArt(n:integer);
var
    Tgi:TGRP_Entry_info;
    th:TTileHeader;
    idx:integer;
begin
 idx:=Arts.indexof(GetArtName(n));
 if idx=-1 then exit;
 tgi:=TGRP_Entry_Info(Arts.Objects[idx]);
 curpos:=tgi.fpos;
 cursize:=tgi.fsize;
 FileSeek(hgrp,curpos,0);
 FRead(th,sizeof(th));
 FRead(xs,sizeof(xs));
 FRead(ys,sizeof(ys));
 Fread(anm,sizeof(anm));
end;

Procedure TOriginalTiles.SetTile(N:integer);
var art,ltile:integer; i:integer;
begin
 art:=N div TilesPerArt;
 if art<>cur_art then begin SetArt(art); cur_art:=art; end;
 ltile:=n mod TilesPerArt;
 fpos:=ArtDataStart;
 for i:=0 to ltile-1 do inc(fpos,longint(xs[i])*ys[i]);
 bi.w:=xs[ltile];
 bi.h:=ys[ltile];
 bi.dx:=-(anm[ltile].dx+bi.w div 2);
 bi.dy:=-(anm[ltile].dy+bi.h);
 bi.transparent:=true;
 bi.animated:=false;
end;

Procedure TOriginalTiles.GetInfo(var b:TbitmapInfo);
begin
 b:=bi;
end;

Procedure TOriginalTiles.GetColumn(var b;N:integer);
begin
 FileSeek(hgrp,curpos+fpos+n*bi.h,0);
 Fread(b,bi.h);
end;

Destructor TOriginalTiles.Free;
begin
 Arts.Free;
 If hgrp>0 then FileClose(hgrp);
end;

{------------------------TDukeArtTiles------------------}
Procedure TDukeArtTiles.PaletteConvert(p:pchar;size:word;var cnv:TPaletteConversionTable);
var i:integer;
    Pbuf:^byte;
begin
 Pbuf:=pointer(p);
 for i:=1 to size do
 begin
  Pbuf^:=cnv.cnv[Pbuf^];
  Inc(Pbuf);
 end;
end;

Function TDukeArtTiles.ErrorMessage:String;
begin
 Result:=err_msg;
end;

Procedure TDukeArtTiles.SetConversionTable(var t:TPaletteConversionTable);
begin
 cnv:=t;
end;

Procedure TDukeArtTiles.SetReverseConversionTable(var t:TPaletteConversionTable);
begin
 rcnv:=t;
end;


Procedure TDukeArtTiles.Error(e:String);
begin
 Err_msg:=e;
end;

Function TDukeArtTiles.GetLastArt:integer;
begin
 result:=cur_art;
end;

function TDukeArtTiles.Fwrite(var b;size:integer):integer;
begin
 Result:=FileWrite(fout,b,size);
 if Result<>size then
 begin
  Result:=-1;
  Error('Can''t write file '+GetArtName(cur_art)+'. Disk Full?');
 end;
end;

Function TDukeArtTiles.OpenImage(name:TFileName):integer;
var ext,gob:String;
begin
 Result:=0;
 if Fin.Fopen(name)<>-1 then exit
 else if Fin.Fopen(Indir+name)<>-1 then exit;
 ext:=UpperCase(ExtractFileExt(name));
 if ext='.BM' then gob:='['+textures_gob+']' else gob:='['+sprites_gob+']';
 if Fin.Fopen(gob+name)<>-1 then exit;
 Error('Can''t find or open '+name);  
 Result:=-1;
end;

Procedure TDukeArtTiles.InitValues(artn:integer);
begin
 Tiles:=0;
 Start_tile:=artn*TilesPerArt;
 Start_art:=artn;
 Cur_art:=Start_art;
 Cur_start_tile:=start_tile;
end;

constructor TDukeArtTiles.Create(dir:string; First_art:integer);
var i:integer;
begin
 to_dir:=dir;
 Error('No error or unexpected error');
 ART_open:=false;
 Logics:=TStringList.Create;
 Files:=TStringList.Create;
 Fin:=TDFImage.Create;
 InitValues(First_Art);
 for i:=0 to 255 do rcnv.cnv[i]:=i;
 rcnv.color0:=0;
 for i:=1 to 254 do cnv.cnv[i]:=i;
 cnv.cnv[255]:=32;
 cnv.Color0:=0;
 AllowTransparent:=true;
 SetGOBs('TEXTURES.GOB','SPRITES.GOB');
 SetGRP('DUKE3D.GRP');
 SetInDir('');
end;

Function TDukeArtTiles.CreateArt(num:integer):integer;
var name:string[13];
begin
 result:=-1;
 if Num>15 then begin Error('Too many graphics - all available tiles are used up'); exit; end;
 name:=GetArtName(num);
 FillChar(xs,sizeof(xs),0);
 FillChar(ys,sizeof(ys),0);
 fillChar(anm,sizeof(anm),0);
 fout:=FileCreate(to_dir+name);
 if fout<=0 then begin Error('Can''t create ART file '+to_dir+name); exit; end;
 FileSeek(Fout, ArtDataStart,0);
 ART_Open:=true;
 Result:=0;
end;

Function TDukeArtTiles.CloseArt:integer;
var  Thead:TTileHeader;
begin
Result:=-1;
if not ART_Open then begin Result:=0; exit; end;
With Thead do
 begin
  Version:=1;
  Ntiles:=256;
  First:=Cur_Start_tile;
  Last:=Cur_Start_tile+255;
  Inc(Cur_start_tile,256);
 end;
 FileSeek(fout,0,0);
 FileWrite(Fout,Thead,sizeof(thead));
 FileWrite(Fout,xs,sizeof(xs));
 FileWrite(Fout,ys,sizeof(ys));
 FileWrite(Fout,anm,sizeof(TTileAnims));
 FileClose(fout);
 ART_Open:=false;
 Result:=0;
end;

Function TDukeArtTiles.AddDFFile(Fname:TFileName):integer;
Var i,j:integer;
    bi:TBitmapInfo;
    animfd:byte;
begin
 result:=-1;
 if OpenImage(Fname)=-1 then begin Error('Can''t open '+Fname); exit; end;
 For i:=0 to Fin.Nimages-1 do
 begin
  Fin.SetCurrentImage(i);
  Fin.GetInfo(bi);
  animfd:=0;
  If i=0 then
  begin
   Result:=Start_tile+Tiles;
   if (Fin.Nimages>1) and bi.animated then animfd:=$80+Fin.Nimages-1;
  end;
  if NewTile(bi,animfd)=-1 then exit;
  if bi.h>MaxHeight then begin Error('Height of '+Fname+' is over 6000!'); exit; end;
  for j:=0 to bi.w-1 do
  begin
   Fin.GetColumn(Col,j);
    if bi.transparent then
    if AllowTransparent then cnv.cnv[0]:=255 else cnv.cnv[0]:=cnv.color0;
    PaletteConvert(@col,bi.h,cnv);
   if AddColumn<0 then exit;
  end;
end;
end;

Destructor TDukeArtTiles.Free;
begin
 Logics.Free;
 Files.Free;
 Fin.done;
 CloseArt;
end;

Function TDukeArtTiles.NewTile(bi:TbitmapInfo;animfd:byte):integer;
begin
Result:=-1;
if not ART_Open then if CreateArt(Cur_art)=-1 then exit;
if Tiles=256 then
begin
 CloseArt; Inc(cur_art);
 if CreateArt(cur_art)=-1 then exit;
 Tiles:=0;
end;
If Tiles=0 then Tile_org:=ArtDataStart
else Inc(Tile_org,longint(xs[Tiles-1])*ys[Tiles-1]);
 xs[Tiles]:=bi.w;
 ys[Tiles]:=bi.h;
With anm[Tiles] do
 begin
  anim:=animfd;
  if animfd<>0 then speed:=20 else speed:=0;
  dx:=GetDukeDX(bi);
  dy:=GetDukeDY(bi);
 end;
 Inc(Tiles);
 FileSeek(Fout,Tile_org,0);
 Result:=0;
end;

Function TDukeArtTiles.NewTileAt(bi:TbitmapInfo;Tile:integer):integer;
var lastw,lasth:integer;
    FirstInFile:boolean; {Whether TileN is the first tile to be written in ART}
begin
Result:=-1;
FirstInFile:=Tiles=0;
if Tiles<>0 then
begin
 lastw:=xs[tiles-1];
 lasth:=ys[tiles-1];
end;

if (Tile>=Cur_Start_Tile) and (Tile<=Cur_Start_tile+255) and ART_Open then Tiles:=Tile-Cur_start_tile
else
begin
 CloseArt;
  cur_art:=Tile div 256;
 if CreateArt(cur_art)=-1 then exit;
  Tiles:=Tile mod 256;
  Tile_org:=ArtDataStart;
  Cur_start_tile:=cur_art*256;
  FirstInFile:=true;
end;
If FirstInFile then Tile_org:=ArtDataStart
else Inc(Tile_org,longint(lastw)*lasth);
 xs[Tiles]:=bi.w;
 ys[Tiles]:=bi.h;
With anm[Tiles] do
 begin
  anim:=0;
  speed:=0;
  dx:=GetDukeDX(bi);
  dy:=GetDukeDY(bi);
 end;
 Inc(Tiles);
 FileSeek(Fout,Tile_org,0);
 Result:=0;
end;


Function TDukeArtTiles.AddColumn:integer;
begin
 result:=FWrite(Col,ys[Tiles-1]);
end;

Function TDukeArtTiles.GetAllowTransparent : Boolean;
begin
 result := AllowTransparent;
end;

{Yves}
procedure TDukeArtTiles.SetAllowTransparent(t : Boolean);
begin
 AllowTransparent := t;
end;

Function TDukeArtTiles.SetLogic2Tile(Logic2Tile:TFileName):integer;
Function LoadLogic2Tile:integer;
var TI:Tindex;
    Logic:string;
    t:text;
    s,w:string;
    p:integer;
begin
result:=-1;
AssignFile(t,Logic2Tile);
{$i-}
Reset(t);
if ioresult<>0 then begin Error('Can''t open '+Logic2Tile); exit; end;
while not eof(t) do
begin
 Readln(t,s);
 p:=pos(';',s);
 if p<>0 then SetLength(s,p-1);
 s:=trim(s);
 if s='' then continue;
 ti:=TIndex.Create;
 p:=GetWord(s,1,Logic);
 p:=GetWord(s,p,w);
 ti.index:=StrToIntDef(w,-2);
 Logics.AddObject(UpperCase(logic),ti);
end;
CloseFile(t);
Result:=0;
end;
begin
 result:=LoadLogic2Tile;
end;

Function TDukeArtTiles.AddSpecialTiles(Script:TFileName):integer;
Var
   ct:TSpecialTileRec;
   i,j,k:integer;
   bi:TbitmapInfo;
   t:text;
   sl:TStringList;
   s,fname,w:string;
   p:integer;
   OT:TOriginalTiles;
   LastFailed:Boolean;

Function LoadConversionScript:integer;
var Sr:TSpecialTileRec;
    t:Text;
begin
result:=-1;
 AssignFile(t,Script);
 {$i-}
 Reset(t);
 if ioresult<>0 then begin Error('Can''t open conversion script '+Script+' Make sure you have this file'); exit; end;
while not eof(t) do
begin
 Readln(t,s);
 p:=pos(';',s);
 if p<>0 then SetLength(s,p-1);
 s:=trim(s);
 if s='' then continue;
 sr:=TSpecialTileRec.Create;
 p:=GetWord(s,1,w);
 sr.TileN:=StrToIntDef(w,0);
 p:=GetWord(s,p,Fname);
 p:=GetWord(s,p,w);
 sr.WaxN:=StrToIntDef(w,0);
 Sl.AddObject(Fname,sr);
end;
CloseFile(t);
Result:=0;
end;

Function AddTile:integer;
var i,n:integer;
begin
 result:=-1;
 OT.SetTile(ct.TileN);
 OT.GetInfo(bi);
 if NewTileAt(bi,ct.tileN)=-1 then exit;
 if bi.h>MaxHeight then begin Error('Height of the tile is over 6000!'); exit; end;
 if bi.w>0 then
 for i:=0 to bi.w-1 do
  begin
   OT.GetColumn(Col,i);
   PaletteConvert(@col,bi.h,rcnv);
   if AddColumn<0 then exit;
  end;
Result:=0;
end;

var
    NextTile,Nimgs:integer;
    CurCNV,NewCNV:(Secb,Jabba,Robot,Gromas);
begin
Result:=0;
LastFailed:=false;
LoadCNVs;
SetConversionTable(SecbaseCNV);
CurCNV:=Secb;
sl:=TStringList.Create;
ot:=TOriginalTiles.Create(Duke3D_grp);
if ot=nil then begin Error('Can''t load '+Duke3D_grp); result:=-1; exit; end;
if LoadConversionScript=-1 then begin Result:=-1; exit; end;
if ART_Open then CloseArt;

{Progress:  Init  min=0, max=sl.count}
 ProgressWindow.Show;
 ProgressWindow.Progress1.Update;
 ProgressWindow.Progress1.Caption := 'Building Tiles';
 ProgressWindow.Gauge.MinValue    := 0;
 ProgressWindow.Gauge.MaxValue    := sl.count - 1;
 ProgressWindow.Gauge.Progress    := 0;
 ProgressWindow.Progress2.Caption := 'Adding files...';
 ProgressWindow.Progress2.Update;
 ProgressWindow.Update;
{ }
for k:=0 to sl.count-1 do
begin
 if Result=-1 then break;
 if k=sl.count-1 then NextTile:=256*Integer(start_art) else
 begin
  ct:=TSpecialTileRec(Sl.Objects[k+1]);
  NextTile:=ct.TileN;
 end;

  ct:=TSpecialTileRec(Sl.Objects[k]);
  Fname:=UpperCase(SL.Strings[k]);
{Progress:  Show K=current}
 ProgressWindow.Gauge.Progress := ProgressWindow.Gauge.Progress + 1;
 if Fname<>'-' then
 begin
  if Fname='' then ProgressWindow.Progress2.Caption := 'Adding Original Tiles'
  else ProgressWindow.Progress2.Caption := 'Adding '+Fname;
  ProgressWindow.Progress2.Update;
 end;
{ }


  if Fname='' then
  begin
   if AddTile=-1 then Result:=-2;
   continue;
  end;
  if Fname<>'-' then
  begin
   if (Fname='KELL.WAX') or (Fname='GAMGUARD.WAX') or (Fname[1]='J') or (Fname='GFPIPES1.FME')
      or (Fname='GFVENTDN.FME') or (Fname='GFVENTUP.FME') then NewCNV:=Jabba
   else if Fname[1]='G' then NewCNV:=Gromas
   else if Fname[1]='R' then NewCNV:=Robot
   else NewCNV:=Secb;
    if NewCNV<>CurCNV then
    case NewCNV of
     Gromas: SetConversionTable(GromasCNV);
     Robot: SetConversionTable(RoboticsCNV);
     Secb: SetConversionTable(SecbaseCNV);
     Jabba: SetConversionTable(JabshipCNV);
    end;
    CurCNV:=NewCNV;
  end;
  if Fname<>'-' then
  begin
   if OpenImage(Fname)=-1 then begin Result:=-2; LastFailed:=true; continue; end
  end else if lastfailed then continue;

  if (ExtractFileExt(Fname)='.WAX') or (Fname='-') then
  begin
   Fin.SetWax(ct.waxN);
   SetAllowTransparent(TRUE);
  end;
  LastFailed:=false;
  NImgs:=Fin.NImages;
  if ct.TileN+Nimgs>NextTile then Nimgs:=NextTile-ct.TileN;

 For i:=0 to Nimgs-1 do
 begin
  Fin.SetCurrentImage(i);
  Fin.GetInfo(bi);
  if NewTileAt(bi,ct.tileN+i)=-1 then Begin Result:=-1; break; end;
  if bi.h>MaxHeight then begin Result:=-2; break; end;
  for j:=0 to bi.w-1 do
  begin
   Fin.GetColumn(Col,j);
    if bi.transparent then cnv.cnv[0]:=255 else cnv.cnv[0]:=cnv.color0;
    PaletteConvert(@col,bi.h,cnv);
   if AddColumn<0 then begin Result:=-1; break; end;
  end;
 end;
end;
sl.Free;
OT.Free;
CloseArt;
if result=-2 then Error('Some files were not converted: '+err_msg);
InitValues(start_art);
{Progress: Done}
ProgressWindow.hide;
end;

Procedure TDukeArtTiles.SetGOBs(textures,sprites:TFileName);
begin
 Textures_Gob:=textures;
 Sprites_gob:=sprites;
end;

Procedure TDukeArtTiles.SetGRP(Grp:TfileName);
begin
 Duke3D_grp:=grp;
end;

Procedure TDukeArtTiles.SetInDir(Dir:TFileName);
begin
 InDir:=Dir;
end;

Function TDukeArtTiles.GetTileByLogic(logic:string):integer;
var I:integer;
begin
 i:=Logics.IndexOf(UpperCase(logic));
 if i<>-1 then result:=Tindex(Logics.Objects[i]).index else result:=-1;
end;

constructor TDFSounds.Create(sounds_gob:TFileName);
const
  VOC_HD:array[0..31] of byte=($43,$72,$65,$61,$74,$69,$76,$65,$20,$56,$6F,$69,$63,$65,$20,$46,$69,$6C,$65,$1A,
                               $1A,$00,$0A,$01,$29,$11,$01,$4B,$04,$00,$A6,$00);
begin
 SndGob:=TGOBFile.OpenGob(sounds_gob);
 if SndGob=nil then raise Exception.CreateFmt('Could not create sound GOB %s' ,[sounds_gob]);
 move(VOC_HD,blank_voc,32);
 Fillchar(blank_voc[32],1097,128);
 blank_voc[1129]:=0;
end;

Function TDFSounds.Extract(Script,dir:TFileName):integer;
var
    i,f:integer;
    List:TStringList;

Function CopyFile:integer;
var size:longint;
begin
result:=-1;
size:=SndGob.Fsize;
While size>sizeof(buffer) do
begin
 SndGob.Fread(buffer,sizeof(buffer));
 result:=FileWrite(f,buffer,sizeof(buffer));
 if Result<>sizeof(buffer) then exit;
 Dec(size,sizeof(buffer));
end;
 SndGob.Fread(buffer,size);
 Result:=FileWrite(f,buffer,size);
 if Result=size then Result:=0;
end;

Function LoadScript:integer;
var
   t:Text;
   S:String;
   p:integer;
begin
result:=-1;
List:=TStringList.Create;
if list=nil then exit;
AssignFile(t,Script);
{$i-}
Reset(t);
if ioresult<>0 then exit;
while not eof(t) do
begin
 Readln(t,s);
 p:=pos(';',s);
 if p<>0 then SetLength(s,p-1);
 s:=trim(s);
 if s='' then continue;
 if length(s)>13 then begin result:=-2; continue; end;
 List.Add(s);
end;
CloseFile(t);
result:=0;
end;

begin
result:=-1;
i:=LoadScript;
if i=-1 then exit else if i=-2 then result:=-2;

f:=FileCreate(dir+'blank.voc');
if f<0 then result:=-2 else
begin
 FileWrite(f,blank_voc,sizeof(blank_voc));
 FileClose(f);
end;
{ Progress Init; Min: 0 Max: List.Count }
 ProgressWindow.Show;
 ProgressWindow.Progress1.Update;
 ProgressWindow.Progress1.Caption := 'Extracting VOCs';
 ProgressWindow.Gauge.MinValue    := 0;
 ProgressWindow.Gauge.MaxValue    := List.Count-1;
 ProgressWindow.Gauge.Progress    := 0;
 ProgressWindow.Progress2.Caption := 'Extracting ...';
 ProgressWindow.Progress2.Update;
 ProgressWindow.Update;
{ }
Result:=0;
For i:=0 to List.Count-1 do
begin
 if SndGob.OpenInGob(List.Strings[i])=-1 then begin result:=-2; continue; end;
 f:=FileCreate(dir+List.Strings[i]);
 if f<0 then begin result:=-2; continue; end;
 if CopyFile=-1 then begin Result:=-1; break; end;
 FileClose(f);
 { Progress Show; Current - i }
 ProgressWindow.Gauge.Progress:=ProgressWindow.Gauge.Progress+1;
end;
{ Progress Done }
 ProgressWindow.Hide;
end;

destructor TDFSounds.Free;
begin
 SndGob.Done;
end;

Function TDukeArtTiles.SetDuke_wdf(duke_wdf:TFileName):integer;
var
   t:Text;
   Fname,w,S:String;
   p:integer;
   Sr:TSpecialTileRec;
begin
result:=-1;
 Files.Sorted:=true;
 Files.Duplicates:=dupIgnore;
 AssignFile(t,duke_wdf);
 {$i-}
 Reset(t);
 if ioresult<>0 then begin Error('Can''t open conversion script '+duke_wdf+' Make sure you have this file'); exit; end;
while not eof(t) do
begin
 Readln(t,s);
 p:=pos(';',s);
 if p<>0 then SetLength(s,p-1);
 s:=trim(s);
 if s='' then continue;
 p:=GetWord(s,1,w);
 p:=GetWord(s,p,Fname);
 if (Fname='') or (Fname='-') then continue;
 Fname:=UpperCase(Fname);
 sr:=TSpecialTileRec.Create;
 sr.TileN:=StrToIntDef(w,0);
 Files.AddObject(Fname,sr);
end;
CloseFile(t);
Result:=0;
end;

Function TDukeArtTiles.SeeInDuke_wdf(Fname:TfileName):Integer;
begin
 Result:=Files.IndexOf(UpperCase(Fname));
 if Result<>-1 then
   Result:=TSpecialTileRec(Files.Objects[Result]).TileN;
end;

{$IFDEF WDF32}
Procedure TDukeArtTiles.LoadCNVs;
begin
 SecbaseCNV:=S_CNV;
 JabshipCNV:=J_CNV;
 RoboticsCNV:=R_CNV;
 GromasCNV:=G_CNV;
end;
{$ELSE}
Procedure TDukeArtTiles.LoadCNVs;
Var HRes:Integer;
    pRes:^TPaletteConversionTable;
begin
 HRes:=LoadResource(HInstance,FindResource(HInstance,'SECBASE','CNV'));
 Pres:=LockResource(Hres);
 SecbaseCNV:=PRes^;
 FreeResource(Hres);

 HRes:=LoadResource(HInstance,FindResource(HInstance,'JABSHIP','CNV'));
 Pres:=LockResource(Hres);
 JabshipCNV:=PRes^;
 FreeResource(Hres);

 HRes:=LoadResource(HInstance,FindResource(HInstance,'ROBOTICS','CNV'));
 Pres:=LockResource(Hres);
 RoboticsCNV:=PRes^;
 FreeResource(Hres);

 HRes:=LoadResource(HInstance,FindResource(HInstance,'GROMAS','CNV'));
 Pres:=LockResource(Hres);
 GromasCNV:=PRes^;
 FreeResource(Hres);
end;
{$ENDIF}
end.

