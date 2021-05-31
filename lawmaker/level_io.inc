Procedure TLevel.Load(FName:String);
var
     s,w1,w2:String;
     a,p:Integer;
     t:TLECTextFile;
     Palettes:TStringList;
     Textures:TStringList;
     Cmaps:TStringList;

Procedure FScanf(const s:string;const format:String;const Vals:array of pointer);
begin
 if not SScanf(s,format,vals) then
  PanMessage(mt_Error,SysUtils.Format('Conversion error at line %d in file %s',[t.CurrentLine,t.GetFullName]));
end;

Function ReadInt(const s:string):Integer;
begin
 if not ValInt(s,Result) then
  PanMessage(mt_Error,Format('Invalid integer at line %d in file %s: %s',[t.CurrentLine,t.GetFullName,s]));
end;

Function ReadDouble(const s:string):Double;
begin
 if not ValDouble(s,Result) then
  PanMessage(mt_Error,Format('Invalid float at line %d in file %s: %s',[t.CurrentLine,t.GetFullName,s]));
end;

Function ReadDword(const s:string):Longint;
begin
 if not ValDword(s,Result) then
  PanMessage(mt_Error,Format('Invalid dword at line %d in file %s: %s',[t.CurrentLine,t.GetFullName,s]));
end;


Function GetTexture(i:Integer):String;
begin
 if i=-1 then result:=''
 else Result:=Textures[i];
end;

Procedure LoadPalettes;
var i,n:Integer;
begin
 n:=StrToInt(w2);
 for i:=0 to n-1 do
 begin
  t.ReadLn(s);
  FScanf(s,'PALETTE: %s',[@w1]);
  palettes.add(w1);
 end;
end;

Procedure LoadCMAPs;
var i,n:Integer;
begin
 n:=StrToInt(w2);
 for i:=0 to n-1 do
 begin
  t.ReadLn(s);
  FScanf(s,'CMAP: %s',[@w1]);
  cmaps.add(w1);
 end;
end;

Procedure LoadShades;
var i,n:Integer;
    shade:TShade;
    dummy:Byte;
begin
 n:=StrToInt(w2);
 for i:=0 to n-1 do
 begin
  t.ReadLn(s);
  Shade:=TShade.Create;
  With Shade do
   FScanf(s,'SHADE: %b %b %b %b %b %c',[@dummy,@r,@g,@b,@b4,@c1]);
   FShades.add(Shade);
 end;
end;

Procedure LoadTextures;
var i,n:Integer;
begin
 n:=StrToInt(w2);
 for i:=0 to n-1 do
 begin
  t.ReadLn(s);
  FScanf(s,'TEXTURE: %s',[@w1]);
  Textures.add(w1);
 end;
end;

Procedure LoadSectors;
var i,n:Integer;
 Sector:TSector;

Function LoadSector:TSector;
begin
 Sector:=TSector.Create;
 Result:=Sector;
 Sector.HexID:=StrToLongInt('$'+w2);
Repeat
 T.ReadLn(s);
 p:=GetWord(s,1,w1);
 p:=GetWord(s,p,w2);
if w1='' then break;
if w1='NAME' then Sector.Name:=w2
else if w1='AMBIENT' then Sector.ambient:=ReadInt(w2)
else if w1='PALETTE' then Sector.palette:=Palettes[ReadInt(w2)]
else if w1='CMAP' then Sector.Colormap:=Cmaps[ReadInt(w2)]
else if w1='FRICTION' then Sector.Friction:=ReadDouble(w2)
else if w1='GRAVITY' then Sector.Gravity:=ReadDouble(w2)
else if w1='ELASTICITY' then Sector.Elasticity:=ReadDouble(w2)
else if w1='VELOCITY' then
begin
 With Sector.Velocity do FScanf(s,'VELOCITY %f %f %f',[@dx,@dy,@dz]);
end
else if w1='VADJOIN' then Sector.VAdjoin:=ReadInt(w2)
else if (w1='FLOOR') and (w2='SOUND') then FScanf(s,'FLOOR SOUND %s',[@Sector.Floor_sound])
else if (w1='FLOOR') and (w2='Y') then
begin
With Sector do
 FScanf(s,'FLOOR Y %f %d %f %f %f',
 [@Floor_Y,@IFloor_TX,@Floor_texture.offsx,@Floor_texture.offsy,@Sector.Floor_extra]);
 Sector.Floor_texture.Name:=GetTexture(Sector.IFloor_TX);
end
else if (w1='CEILING') and (w2='Y') then
begin
With Sector do
 FScanf(s,'CEILING Y %f %d %f %f %f',
 [@Ceiling_Y,@IFloor_TX,@Ceiling_texture.offsx,@Ceiling_texture.offsy,@Ceiling_extra]);
 Sector.Ceiling_texture.Name:=GetTexture(Sector.IFloor_TX);
end
else if w1='F_OVERLAY' then
begin
 With Sector do
 FScanf(s,'F_OVERLAY %d %f %f %f',
 [@IFOVR_TX,@F_OverLay_Texture.offsx,@F_OverLay_Texture.offsy,@F_Overlay_extra]);
 Sector.F_Overlay_Texture.Name:=GetTexture(Sector.IFOVR_TX);
end
else if w1='C_OVERLAY' then
begin
 With Sector do
 FScanf(s,'C_OVERLAY %d %f %f %f',
 [@ICOVR_TX,@C_OverLay_Texture.offsx,@C_OverLay_Texture.offsy,@C_Overlay_extra]);
 Sector.C_Overlay_Texture.Name:=GetTexture(Sector.ICOVR_TX);
end
else if w1='FLAGS' then Sector.Flags:=ReadDword(w2)
else if w1='LAYER' then begin Sector.Layer:=Round(ReadDouble(w2)); break; end
else if w1='SLOPEDFLOOR' then
begin
 With Sector.FloorSlope do
  FScanf(s,'SLOPEDFLOOR %u %u %f',[@sector,@wall,@angle]);
end
else if w1='SLOPEDCEILING' then
begin
 With Sector.CeilingSlope do
  FScanf(s,'SLOPEDCEILING %u %u %f',[@sector,@wall,@angle]);
end;
Until false;
end;

Procedure LoadWalls;
var i,cw,nw,n:Integer;
    wall:TWall;
begin
 n:=StrToInt(w2);
 for i:=0 to n-1 do
 begin
  t.ReadLn(s);
  Wall:=TWall.Create;
  With Wall do
  begin
   FScanf(s,'WALL: %x V1: %d V2: %d MID: %d %f %f TOP: %d %f %f BOT: %d %f %f OVERLAY: %d %f %f ADJOIN: %d MIRROR: %d DADJOIN: %d DMIRROR: %d FLAGS: %s %u LIGHT: %d',
                 [@HexID,    @V1,    @V2,
                  @IMID,@MID.offsx,@MID.offsy,
                  @ITOP,@TOP.offsx,@TOP.offsy,
                  @IBOT,@BOT.offsx,@BOT.offsy,
                  @IOverlay,@Overlay.offsx,@Overlay.offsy,
                  @Adjoin, @Mirror, @DAdjoin, @DMirror,
                  @w2,@a,@light]);
   MID.Name:=GetTexture(IMID);
   TOP.Name:=GetTexture(ITOP);
   BOT.Name:=GetTexture(IBOT);
   Flags:=ReadDword(w2);
   Overlay.Name:=GetTexture(IOverlay);
  end;
  Sector.Walls.Add(Wall);
 end; 
end;

Procedure LoadVertices;
var i,n:Integer;
    Vertex:TVertex;
begin
 n:=StrToInt(w2);
 for i:=0 to n-1 do
 begin
  t.ReadLn(s);
  Vertex:=TVertex.Create;
  Sector.Vertices.Add(Vertex);
  With Vertex do
  FScanf(s,'X: %f Z: %f',[@X,@Z]);
 end;
end;


begin {LoadSectors}
 n:=StrToInt(w2);
 Progress.Reset(n);
 Progress.Msg:='Loading Sectors...';
 i:=0;
 While (not t.eof) and (i<=n) do
 begin
  t.ReadLn(s);
  p:=GetWord(s,1,w1);
  p:=GetWord(s,p,w2);
  if w1='' then continue;

  if w1='SECTOR' then begin  Sector:=LoadSector; Sectors.Add(Sector); Progress.Step; Inc(i); end
  else if w1='WALLS' then LoadWalls
  else if w1='VERTICES' then LoadVertices;
 end;
end;

Procedure LoadObjects;
var i,n,cw,nw:Integer;
    aObject:TOB;
begin
 n:=StrToInt(w2);
 For i:=0 to n-1 do
 begin
  t.ReadLn(s);
  aObject:=TOB.Create;
  With aObject do
  begin
   FScanf(s,'NAME: %s ID: %x SECTOR: %x X: %f Y: %f Z: %f PCH: %f YAW: %f ROL: %f FLAGS: %s %s',
   [@Name,@HexID,@a,@X,@Y,@Z,@PCH,@YAW,@ROL,@w1,@w2]);
   flags1:=ReadDword(w1);
   flags2:=ReadDword(w2);
   Sector:=GetSectorByID(a);
  end;
  Objects.Add(aObject);
 end;
end;

begin {TLEVEL.LOAD}
 Try
 t:=TLECTextFile.CreateRead(OpenFileRead(Fname,0));
 Textures:=TStringList.Create;
 Palettes:=TStringList.Create;
 Cmaps:=TStringList.Create;
 Clear;
 Try
 Try
  While not t.eof do
 begin
  t.ReadLn(s);
  p:=GetWord(s,1,w1);
  p:=GetWord(s,p,w2);

  if w1='' then continue;
  if w1='LVT' then
  else if w1='LEVELNAME' then Name:=w2
  else if w1='VERSION' then Version:=ReadDouble(w2)
  else if w1='PALETTES' then LoadPalettes
  else if w1='MUSIC' then Music:=w2
  else if w1='PARALLAX' then
  begin
   FScanf(s,'PARALLAX %f %f',[@Parallax_x,@Parallax_y]);
  end
  else if w1='CMAPS' then LoadCMAPs
  else if w1='SHADES' then LoadShades
  else if w1='TEXTURES' then LoadTextures
  else if w1='NUMSECTORS' then LoadSectors;
 end;
 Except
  On E:EConvertError do
   Raise Exception.CreateFmt('File %s: Error at line %d: %s',[Fname,t.CurrentLine,E.Message]);
 end;
 Finally
  textures.free;
  palettes.free;
  Cmaps.Free;
  t.Fclose;
  Progress.Hide;
 end;

 Except
  On E:EInOutError do PanMessage(mt_error,E.Message+' '+FName);
  On E:Exception do PanMessage(mt_error,E.Message);
 end;

 Try
 t:=TLECTextFile.CreateRead(OpenFileRead(ChangeFileExt(Fname,'.obt'),0));
 Try
 Try
  While not t.eof do
  begin
   t.ReadLn(s);
   p:=GetWord(s,1,w1);
   p:=GetWord(s,p,w2);
   if w1='' then continue;
   if w1='OBT' then
   else if w1='LEVELNAME' then
   else if w1='OBJECTS' then LoadObjects;
  end;
 Except
  On E:EConvertError do
   Raise Exception.CreateFmt('File %s: Error at line %d: %s',[Fname,t.CurrentLine,E.Message]);
 end;
 Finally
  t.Fclose;
 end;
 Except
  On E:EInOutError do PanMessage(mt_error,E.Message+' '+ChangeFileExt(Fname,'.obt'));
  On E:Exception do PanMessage(mt_error,E.Message);
 end;

end;

Procedure TLevel.Save(FName:String);
var t:TextFile;
    palettes,textures,cmaps:TStringList;
    s,w:integer;
    i:Integer;
    SecID:Longint;

Procedure WriteString(const s:String);
begin
 Writeln(t,s);
end;

Procedure WriteFmt(const fmt:String;const args:array of const);
begin
 Writeln(t,Format(fmt,args));
end;

Function sl_Add(sl:TStringList;const s:String):Integer;
var i:integer;
begin
 if s='' then begin result:=-1; exit; end;
 i:=sl.IndexOf(s);
 if i=-1 then Result:=sl.Add(s) else result:=i;
end;


begin
 DecimalSeparator:='.';
 AssignFile(t,FName); ReWrite(t);
{ Compile the list of textures, colormaps and palettes}
palettes:=TStringList.Create;
cmaps:=TStringList.Create;
textures:=TStringList.Create;
Progress.Reset(Sectors.Count+1);
Progress.Msg:='Compiling list of textures...';
for s:=0 to Sectors.Count-1 do
begin
 With Sectors[s] do
 begin
  IPalette:=sl_Add(Palettes,Palette);
  ICmap:=sl_Add(Cmaps,ColorMap);
  IFloor_TX:=sl_Add(Textures,Floor_Texture.Name);
  ICeiling_TX:=sl_Add(Textures,Ceiling_Texture.Name);
  IFOVR_TX:=sl_Add(Textures,F_Overlay_Texture.Name);
  ICOVR_TX:=sl_Add(Textures,C_Overlay_Texture.Name);
  for w:=0 to Walls.count-1 do
  With Walls[w] do
  begin
    IMID:=sl_Add(Textures,MID.Name);
    ITOP:=sl_Add(Textures,TOP.Name);
    IBOT:=sl_Add(Textures,BOT.Name);
    IOverlay:=sl_Add(Textures,Overlay.Name);
  end;
 end;
end;
Progress.Step;
Progress.Msg:='Writing Sectors...';
 Try
  {Writing header}
  WriteString('LVT 1.1'); WriteString('');
  WriteString('#This file was created by LawMaker '+VersionString);WriteString('');
  WriteString('LEVELNAME '+Name);
  WriteString('VERSION 1535.022197');

  WriteFmt('PALETTES %d',[Palettes.count]);
  For i:=0 to palettes.count-1 do
   WriteString(' PALETTE: '+Palettes[i]);

  WriteFmt('CMAPS %d',[cmaps.count]);
  For i:=0 to cmaps.count-1 do
   WriteString(' CMAP: '+cmaps[i]);

  WriteString('MUSIC '+Music);
  WriteFmt('PARALLAX %f %f',[Parallax_X,Parallax_Y]);
  WriteString('LIGHT SOURCE 0.0 0.0 0.0 0.0');
  WriteFmt('SHADES %d',[shades.count]);
  For i:=0 to Shades.count-1 do
  with Shades[i] do
   WriteFmt(' SHADE: %d %d %d %d %d %s',[i+1,r,g,b,b4,c1]);
  WriteString('');

 WriteFmt('TEXTURES %d',[textures.count]);
 For i:=0 to textures.count-1 do
  WriteString(' TEXTURE: '+textures[i]);
 WriteString('');

 {Writing sectors}
 WriteFmt('NUMSECTORS %d',[sectors.count]);
 WriteString('');

 For s:=0 to sectors.count-1 do
 with sectors[s] do
 begin
  Progress.Step;
  WriteFmt('SECTOR %x # %d',[HexID,s]);
  WriteString(' NAME '+Name);
  WriteFmt(' AMBIENT %d',[ambient]);
  WriteFmt(' PALETTE %d',[IPalette]);
  WriteFmt(' CMAP %d',[ICmap]);
  WriteFmt(' FRICTION %f',[friction]);
  WriteFmt(' GRAVITY %g',[gravity]);
  WriteFmt(' ELASTICITY %f',[elasticity]);
  WriteFmt(' VELOCITY %f %f %f',[velocity.dx,velocity.dy,velocity.dz]);
  WriteFmt(' VADJOIN %d',[VAdjoin]);
  WriteString(' FLOOR SOUND '+Floor_Sound);
 with Floor_Texture do
  WriteFmt(' FLOOR Y %f %d %f %f %f',[Floor_Y,IFloor_TX,offsx,offsy,Floor_Extra]);
 With Ceiling_Texture do
  WriteFmt(' CEILING Y %f %d %f %f %f',[Ceiling_Y,ICeiling_TX,offsx,offsy,Ceiling_Extra]);
 With F_Overlay_Texture do
  WriteFmt(' F_OVERLAY %d %f %f %f',[IFOVR_TX,offsx,offsy,F_Overlay_Extra]);
 With C_Overlay_Texture do
  WriteFmt(' C_OVERLAY %d %f %f %f',[ICOVR_TX,offsx,offsy,C_Overlay_Extra]);
  WriteString(' FLOOR OFFSETS 0');
  WriteFmt(' FLAGS %d 0',[flags]);
 if IsFlagSet(SECFLAG1_SLOPEDFLOOR) then with FloorSlope do
  WriteFmt(' SLOPEDFLOOR %s %s %f',[DwordToStr(sector),DWordTOStr(wall),angle]);
 if IsFlagSet(SECFLAG1_SLOPEDCEILING) then with CeilingSlope do
  WriteFmt(' SLOPEDCEILING %s %s %f',[DwordToStr(sector),DWordTOStr(wall),angle]);
  WriteFmt(' LAYER %d',[layer]);
  WriteString('');

  WriteFmt(' VERTICES %d',[vertices.count]);
  For i:=0 to vertices.count-1 do
  With Vertices[i] do
   WriteFmt('  X: %f Z: %f',[X,Z]);
  WriteString('');

  WriteFmt(' WALLS %d',[walls.count]);
  For w:=0 to walls.count-1 do
  With walls[w] do
  begin
   WriteFmt('  WALL: %x V1: %d V2: %d MID: %d %f %f TOP: %d %f %f BOT: %d %f %f OVERLAY: %d %f %f ADJOIN: %d MIRROR: %d DADJOIN: %d DMIRROR: %d FLAGS: %s 0 LIGHT: %d',
                 [HexID,    V1,    V2,
                  IMID,MID.offsx,MID.offsy,
                  ITOP,TOP.offsx,TOP.offsy,
                  IBOT,BOT.offsx,BOT.offsy,
                  IOverlay,Overlay.offsx,Overlay.offsy,
                  Adjoin, Mirror, DAdjoin, DMirror,
                  DwordToStr(flags),light]);
  end;
   WriteString('');
 end;

 Finally
  CloseFile(t);
  Textures.free;
  cmaps.free;
  palettes.free;
 end;
 AssignFile(t,ChangeFileExt(FName,'.obt')); ReWrite(t);
 Try
  WriteString('OBT 1.0');
  WriteString('');
  WriteString('#This file was created by LawMaker '+VersionString);
  WriteString('');
  WriteString('LEVELNAME '+ExtractFileName(Name));
  WriteString('');
  WriteFmt('OBJECTS %d',[objects.count]);

  For i:=0 to Objects.Count-1 do
  With Objects[i] do
  begin
   If Sector=-1 then SecID:=0 else SecID:=Sectors[Sector].HexID;
   WriteFmt(' NAME: %s ID: %x SECTOR: %x X: %f Y: %f Z: %f PCH: %f YAW: %f ROL: %f FLAGS: %s %s',
       [Name,HexID,SecID,X,Y,Z,PCH,YAW,ROL,DwordToStr(flags1),DWordToStr(flags2)]);
  end;
 Finally
  CloseFile(t);
  Progress.Hide;
 end;
end;

Procedure TLevel.ImportLEV(FName:String);
var
     w1,w2:String;
     t:TLECTextFile;
     Textures:TStringList;
     Sector:TSector;
     i,p:Integer;
     s:String;

Procedure FScanf(const s:string;const format:String;const Vals:array of pointer);
begin
 if not SScanf(s,format,vals) then
  PanMessage(mt_Error,SysUtils.Format('Conversion error at line %d in file %s',[t.CurrentLine,t.GetFullName]));
end;

Function ReadInt(const s:string):Integer;
begin
 if not ValInt(s,Result) then
  PanMessage(mt_Error,Format('Invalid integer at line %d in file %s: %s',[t.CurrentLine,t.GetFullName,s]));
end;

Function ReadDouble(const s:string):Double;
begin
 if not ValDouble(s,Result) then
  PanMessage(mt_Error,Format('Invalid float at line %d in file %s: %s',[t.CurrentLine,t.GetFullName,s]));
end;

Function ReadDword(const s:string):Longint;
begin
 if not ValDword(s,Result) then
  PanMessage(mt_Error,Format('Invalid dword at line %d in file %s: %s',[t.CurrentLine,t.GetFullName,s]));
end;

Function ConvertSecFlags(f:Longint):LongInt;
begin
 Result:=0;
 if f and 1<>0 then Result:=Result or SECFLAG1_EXTCEILING
 else if f and 128<>0    then Result:=Result or SECFLAG1_EXTFLOOR
 else if f and 8<>0      then Result:=Result or SECFLAG1_EXTTOPADJOIN
 else if f and 256<>0    then Result:=Result or SECFLAG1_EXTBTMADJOIN
 else if f and 1024<>0   then Result:=Result or SECFLAG1_NOWALLS
 else if f and 256<>0    then Result:=Result or SECFLAG1_DOOR
 else if f and 2048<>0   then Result:=Result or SECFLAG1_SECDAMAGE_SML
 else if f and 4096<>0   then Result:=Result or SECFLAG1_SECDAMAGE_LGE
 else if f and 524288<>0 then Result:=Result or SECFLAG1_SECRET_TAG;
end;

Function ConvertWallFlags(f1,f2:Longint):LongInt;
begin
 Result:=0;
 if f1 and 1<>0 then Result:=Result or WALLFLAG1_MIDTEX
 else if f1 and 2<>0      then Result:=Result or WALLFLAG1_LITSIGN
 else if f1 and 4<>0      then Result:=Result or WALLFLAG1_HFLIP
 else if f1 and 16<>0     then Result:=Result or WALLFLAG1_ANCHOR
 else if f1 and 4096<>0   then Result:=Result or WALLFLAG1_ANCHORSIGN
 else if f1 and 32<>0     then Result:=Result or WALLFLAG1_MOVE
 else if f1 and 64<>0     then Result:=Result or WALLFLAG1_SCROLLTOP
 else if f1 and 128<>0    then Result:=Result or WALLFLAG1_SCROLLMID
 else if f1 and 256<>0    then Result:=Result or WALLFLAG1_SCROLLBOTTOM
 else if f1 and 512<>0    then Result:=Result or WALLFLAG1_SCROLLSIGN
 else if f1 and 1024<>0   then Result:=Result or WALLFLAG1_NOSHOW
 else if f2 and 1<>0      then Result:=Result or WALLFLAG1_FORCEPASS
 else if f2 and 2<>0      then Result:=Result or WALLFLAG1_NOPASS
 else if f2 and 4<>0      then Result:=Result or WALLFLAG1_FENCE;
end;

Procedure LoadTextures;
var i,n:Integer;
begin
 n:=StrToInt(W2);
 For i:=0 to n-1 do
 begin
  t.ReadLn(s);
  FScanf(s,'TEXTURE: %s',[@W1]);
  if Lev_Textures=lev_toPCX then
   w1:=ChangeFileExt(w1,'.PCX');
  Textures.Add(w1);
 end;
end;

Function GetTexture(i:Integer):String;
begin
 if i=-1 then Result:=''
 else if lev_textures=lev_default then Result:='DEFAULT.PCX'
 else if (i<0) or (i>=Textures.Count) then Result:='DEFAULT.PCX'
 else Result:=Textures[i];
end;

Procedure LoadSectors;
var i,n:Integer;

Procedure LoadVertices;
var i,n:Integer;
    Vertex:TVertex;
begin
 n:=StrToInt(w2);
 For i:=0 to n-1 do
 begin
  Vertex:=TVertex.Create;
  Sector.Vertices.Add(Vertex);
  t.ReadLn(s);
  With Vertex do
   FScanf(s,'X: %f Z: %f',[@X,@Z]);
 end;
end;

Procedure LoadWalls;
var i,n,sign:Integer;
    Wall:TWall;
    IMid,ITop,IBot:Integer;
begin
 n:=STrToInt(w2);
 i:=0;
 While (not t.eof) and (i<n) do
 begin
   {Loading wall}
   T.ReadLn(s);
   if trim(s)='' then continue;
   inc(i);
  Wall:=TWall.Create;
  With Wall do
  begin
   {Setting defaults}
   HexID:=GetNewWallID;
   MID.Name:='DEFAULT.PCX';
   BOT.Name:='DEFAULT.PCX';
   TOP.Name:='DEFAULT.PCX';
   Overlay.Name:='';
   DAdjoin:=-1; Dmirror:=-1;

   FScanf(s,'WALL LEFT: %d RIGHT: %d MID: %d %f %f TOP: %d %f %f BOT: %d %f %f SIGN: %d %f %f ADJOIN: %d MIRROR: %d FLAGS: %s 0 %s LIGHT: %d',
            [@V1,@V2,@IMid,@MID.OffsX,@MID.OffsY,@ITop,@TOP.OffsX,@Top.OffsY,@IBot,@Bot.OffsX,@Bot.OffsY,@Sign,@Overlay.OffsX,@Overlay.OffsY,@Adjoin,@Mirror,@w1,@w2,@light]);
   if sign<>-1 then Overlay.Name:='DEFAULT.PCX';
{   Mid.OffsY:=-MID.OffsY;
   BOT.OffsY:=-BOT.OffsY;
   TOP.OffsY:=-TOP.OffsY;
   Overlay.OffsY:=-Overlay.OffsY;}
   MID.Name:=GetTexture(IMid);
   TOP.Name:=GetTexture(ITop);
   BOT.Name:=GetTexture(IBot);
   Flags:=ConvertWallFlags(ReadInt(w1),ReadInt(w2));
  end;
  Sector.Walls.Add(Wall);
 end;
end;

Function LoadSector:TSector;
var a:integer;
begin
 Result:=TSector.Create;

 With Result do
 begin
 {Setting defaults}
  HexID:=GetNewSectorID;
  Palette:='RANCH';
  ColorMap:='RANCH';
  Friction:=1;
  Gravity:=-60;
  Elasticity:=0.3;
  With Velocity do begin dx:=0; dy:=0; dz:=0; end;
  VAdjoin:=-1;
  Floor_Sound:='NULL';
  Floor_Texture.Name:='DEFAULT.PCX';
  Ceiling_Texture.Name:='DEFAULT.PCX';
  F_Overlay_texture.Name:='';
  C_Overlay_texture.Name:='';

  {Loading sector}

 Repeat
  t.Readln(s);
  p:=GetWord(s,1,w1);
  p:=GetWord(s,p,w2);
  if w1='' then break;

  if w1='NAME' then Result.Name:=UpperCase(w2)
  else if w1='AMBIENT' then ambient:=ReadInt(w2)
  else if (w1='FLOOR') and (w2='ALTITUDE') then begin FScanf(s,'FLOOR ALTITUDE %f',[@Floor_Y]); Floor_Y:=-Floor_Y; end
  else if (w1='CEILING') and (w2='ALTITUDE') then begin FScanf(s,'CEILING ALTITUDE %f',[@Ceiling_Y]); Ceiling_Y:=-Ceiling_Y; end
  else if (w1='FLOOR') and (w2='TEXTURE') then
  begin
   FScanf(s,'FLOOR TEXTURE %d %f %f',[@a,@Floor_Texture.OffsX,@Floor_Texture.OffsY]);
   Floor_Texture.Name:=GetTexture(a);
  end
  else if (w1='CEILING') and (w2='TEXTURE') then
  begin
   FScanf(s,'CEILING TEXTURE %d %f %f',[@a,@Ceiling_Texture.OffsX,@Ceiling_Texture.OffsY]);
   Ceiling_Texture.Name:=GetTexture(a);
  end 
  else if w1='FLAGS' then
  begin
   flags:=ConvertSecFlags(ReadDWord(w2));
   if flags and 16<>0 then Friction:=0;
  end
  else if w1='LAYER' then begin Layer:=ReadInt(w2); break; end;

 Until false;
 end;
end;

begin {LoadSectors}
 n:=StrToInt(w2);
 i:=0;
 Progress.Reset(n);
 Progress.Msg:='Loading Sectors...';
 While (not t.eof) and (i<=n) do
 begin
  t.Readln(s);
  p:=GetWord(s,1,w1);
  p:=GetWord(s,p,w2);
  if w1='' then continue;

  if w1='SECTOR' then begin inc(i); Sector:=LoadSector; Sectors.Add(Sector); Progress.Step; end
  else if w1='VERTICES' then LoadVertices
  else if w1='WALLS' then LoadWalls;

 end;
end;

Procedure LoadObjects;
var i,n:Integer;
    a:Integer;dif:Integer;
    TheObject:TOB;
begin
 n:=StrToInt(w2);
 i:=0;
 While (not t.eof) and (i<n) do
 begin
  t.Readln(s);
  p:=GetWord(s,1,w1);
  p:=GetWord(s,p,w2);
  if w1='' then continue;

  if w1='CLASS:' then
  begin
   if (w2='SPIRIT') or (w2='SAFE') then
   begin
    TheObject:=NewObject;
    With TheObject do
    FScanf(s,'CLASS: %s DATA: %d X: %f Y: %f Z: %f PCH: %f YAW: %f ROL: %f DIFF: %d',
             [@w1, @a, @x, @y, @z, @pch, @Yaw, @Rol, @Dif]);
    TheObject.Y:=-TheObject.Y;
    if W2='SPIRIT' then TheObject.Name:='PLAYER'
    else if W2='SAFE' then TheObject.Name:='STARTPOS';
    Objects.Add(TheObject);
   end;
  end;

 end;
end;

begin {TLevel.ImportLev}
 Try
 t:=TLECTextFile.CreateRead(OpenFileRead(FName,0));
 Textures:=TStringList.Create;
 Clear;

 Try
 Try
   {Filling the unused values with defaults}
   Music:='NULL';
   Version:=1535.022197;
   SetDefaultShades;
 {Reading file}
  While not t.eof do
  begin
   t.readln(s);
   p:=GetWord(s,1,w1); {w1 - first word, w2 - second}
   p:=GetWord(s,p,w2);
   if w1='' then continue;

   if w1='LEV' then
   else if w1='LEVELNAME' then Name:=w2
   else if w1='TEXTURES' then LoadTextures
   else if w1='PARALLAX' then FScanf(s,'PARALLAX %f %f',[@Parallax_x,@Parallax_y])
   else if w1='NUMSECTORS' then LoadSectors;
  end;

 Except
  On E:EConvertError do
   Raise Exception.CreateFmt('File %s: Error at line %d: %s',[Fname,t.CurrentLine,E.Message]);
 end;
 
 Finally
  t.Fclose;
  textures.free;
 end;

 Except
  On E:EInOutError do PanMessage(mt_error,E.Message+' '+Fname);
  On E:Exception do PanMessage(mt_error,E.Message);
 end;

Try
t:=TLECTextFile.CreateRead(OpenFileRead(ChangeExt(FName,'.O'),0));
Try
Try
  While not t.eof do
  begin
   t.readln(s);
   p:=GetWord(s,1,w1); {w1 - first word, w2 - second}
   p:=GetWord(s,p,w2);
   if w1='' then continue;

   if w1='O' then
   else if w1='LEVENAME' then
   else if w1='PODS' then
   else if w1='SPRS' then
   else if w1='FMES' then
   else if w1='SOUNDS' then
   else if w1='OBJECTS' then LoadObjects;
  end;
 Except
  On E:EConvertError do
   Raise Exception.CreateFmt('File %s: Error at line %d: %s',[Fname,t.CurrentLine,E.Message]);
 end;

finally
 T.Fclose;
 Progress.Hide;
end;

 Except
  On E:EInOutError do PanMessage(mt_error,E.Message+' '+ChangeExt(FName,'.O'));
  On E:Exception do PanMessage(mt_error,E.Message);
end;



end;

Procedure TLevel.ImportWAD(FName:String);
begin
end;

Procedure TLevel.ImportMAP(FName:String);
begin
end;

