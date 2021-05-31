Procedure TLevel.Load(FName:String);
var
     w1:String;
     sp:TStringParser;
     t:TTextFile;
     Palettes:TStringList;
     Textures:TStringList;
     Cmaps:TStringList;

Function GetTexture(i:Integer):String;
begin
 if i=-1 then result:=''
 else Result:=Textures[i];
end;

Procedure LoadPalettes;
var i,n:Integer;
begin
 n:=StrToInt(sp[1]);
 for i:=0 to n-1 do
 begin
  t.ReadLn(s);
  
  palettes.add(t.parsed[1]);
 end;
end;

Procedure LoadCMAPs;
var i,n:Integer;
begin
 n:=StrToInt(sp[1]);
 for i:=0 to n-1 do
 begin
  t.ReadLine;
  cmaps.add(t.parsed[1]);
 end;
end;

Procedure LoadShades;
var i,n:Integer;
    shade:TShade;
begin
 n:=StrToInt(sp[1]);
 for i:=0 to n-1 do
 begin
  t.ReadLine;
  sp:=t.Parsed;
  Shade:=TShade.Create;
  Shade.r:=StrToInt(sp[2]);
  Shade.g:=StrToInt(sp[3]);
  Shade.b:=StrToInt(sp[4]);
  Shade.b4:=StrToInt(sp[5]);
  Shade.c1:=sp[6][1];
  FShades.add(Shade);
 end;
end;

Procedure LoadTextures;
var i,n:Integer;
begin
 n:=StrToInt(sp[1]);
 for i:=0 to n-1 do
 begin
  t.ReadLine;
  Textures.add(t.parsed[1]);
 end;
end;

Procedure LoadSectors;
var i,n:Integer;
 Sector:TSector;

Function LoadSector:TSector;
begin
 Sector:=TSector.Create;
 Result:=Sector;
Repeat
 T.ReadLine;
 sp:=t.Parsed;
if sp.count=0 then break;
w1:=sp[0];
if w1='NAME' then begin if sp.count>1 then Sector.Name:=sp[1]; end
else if w1='AMBIENT' then Sector.ambient:=StrToInt(sp[1])
else if w1='PALETTE' then Sector.palette:=Palettes[StrToInt(sp[1])]
else if w1='CMAP' then Sector.Colormap:=Cmaps[StrToInt(sp[1])]
else if w1='FRICTION' then Sector.Friction:=StrToInt(sp[1])
else if w1='GRAVITY' then Sector.Gravity:=StrToInt(sp[1])
else if w1='ELASTICITY' then Sector.Elasticity:=StrToDouble(sp[1])
else if w1='VELOCITY' then
begin
 Sector.velocity.dx:=StrToInt(sp[1]);
 Sector.velocity.dy:=StrToInt(sp[2]);
 Sector.velocity.dz:=StrToInt(sp[3]);
end
else if w1='VADJOIN' then Sector.VAdjoin:=StrToInt(sp[1])
else if (w1='FLOOR') and (sp[1]='SOUND') then Sector.Floor_sound:=sp[2]
else if (w1='FLOOR') and (sp[1]='Y') then
begin
 Sector.Floor_Y:=StrToDouble(sp[2]);
 Sector.Floor_texture.Name:=GetTexture(StrToInt(sp[3]));
 Sector.Floor_texture.offsx:=StrToDouble(sp[4]);
 Sector.Floor_texture.offsy:=StrToDouble(sp[5]);
 Sector.Floor_extra:=StrToDouble(sp[6]);
end
else if (w1='CEILING') and (sp[1]='Y') then
begin
 Sector.Ceiling_Y:=StrToDouble(sp[2]);
 Sector.Ceiling_texture.Name:=GetTexture(StrToInt(sp[3]));
 Sector.Ceiling_texture.offsx:=StrToDouble(sp[4]);
 Sector.Ceiling_texture.offsy:=StrToDouble(sp[5]);
 Sector.Ceiling_extra:=StrToDouble(sp[6]);
end
else if w1='F_OVERLAY' then
begin
 Sector.F_Overlay_Texture.Name:=GetTexture(StrToInt(sp[1]));
 Sector.F_OverLay_Texture.offsx:=StrToDouble(sp[2]);
 Sector.F_OverLay_Texture.offsy:=StrToDouble(sp[3]);
 Sector.F_Overlay_extra:=StrToDouble(sp[4]);
end
else if w1='C_OVERLAY' then
begin
 Sector.C_Overlay_Texture.Name:=GetTexture(StrToInt(sp[1]));
 Sector.C_OverLay_Texture.offsx:=StrToDouble(sp[2]);
 Sector.C_OverLay_Texture.offsy:=StrToDouble(sp[3]);
 Sector.C_Overlay_extra:=StrToDouble(sp[4]);
end
else if w1='FLAGS' then Sector.Flags:=StrToLongInt(sp[1])
else if w1='LAYER' then Sector.Layer:=StrToInt(sp[1])
else if w1='SLOPEDFLOOR' then
else if w1='SLOPEDCEILING' then;
Until false;
end;

Procedure LoadWalls;
var i,cw,nw,n:Integer;
    wall:TWall;
begin
 n:=StrToInt(t.Parsed[1]);
 for i:=0 to n-1 do
 begin
  t.ReadLine;
  sp:=t.Parsed;
  nw:=sp.count;
  Wall:=TWall.Create;
  Sector.Walls.Add(Wall);

  cw:=0;
  With Wall do
  While cw<nw do
  begin
   w1:=sp[cw]; Inc(cw);
   if w1='WALL:' then
   else if w1='V1:' then V1:=StrToInt(sp[cw])
   else if w1='V2:' then V2:=StrToInt(sp[cw])
   else if w1='MID:' then
   begin
    MID.Name:=GetTexture(StrToInt(sp[cw]));
    MID.offsx:=StrToDouble(sp[cw+1]);
    MID.offsy:=StrToDouble(sp[cw+2]);
    Inc(cw,2);
   end
   else if w1='TOP:' then
   begin
    TOP.Name:=GetTexture(StrToInt(sp[cw]));
    TOP.offsx:=StrToDouble(sp[cw+1]);
    TOP.offsy:=StrToDouble(sp[cw+2]);
    Inc(cw,2);
   end
   else if w1='BOT:' then
   begin
    BOT.Name:=GetTexture(StrToInt(sp[cw]));
    BOT.offsx:=StrToDouble(sp[cw+1]);
    BOT.offsy:=StrToDouble(sp[cw+2]);
    Inc(cw,2);
   end
   else if w1='OVERLAY:' then
   begin
    Overlay.Name:=GetTexture(StrToInt(sp[cw]));
    Overlay.offsx:=StrToDouble(sp[cw+1]);
    Overlay.offsy:=StrToDouble(sp[cw+2]);
    Inc(cw,2);
   end
   else if w1='ADJOIN:' then
   else if w1='MIRROR:' then
   else if w1='DADJOIN:' then
   else if w1='DMIRROR:' then
   else if w1='FLAGS:' then begin Flags:=StrToLongInt(sp[cw]); inc(cw); end
   else if w1='LIGHT:' then light:=StrToInt(sp[cw]);
   inc(cw);
  end;
 end;
end;

Procedure LoadVertices;
var i,n:Integer;
    Vertex:TVertex;
begin
 n:=StrToInt(t.Parsed[1]);
 for i:=0 to n-1 do
 begin
  t.ReadLine;
  Vertex:=TVertex.Create;
  Sector.Vertices.Add(Vertex);
  Vertex.X:=StrToDouble(t.Parsed[1]);
  Vertex.X:=StrToDouble(t.Parsed[3]);
 end;
end;


begin {LoadSectors}
 n:=StrToInt(sp[1]);
 Progress.Reset(n);
 i:=0;
 While (not t.eof) and (i<=n) do
 begin
  t.ReadLine;
  sp:=t.Parsed;
  if sp.count=0 then continue;

  w1:=sp[0];
  if w1='SECTOR' then begin LoadSector; Sectors.Add(Sector); Progress.Step; Inc(i); end
  else if w1='WALLS' then LoadWalls
  else if w1='VERTICES' then LoadVertices;
 end;
end;

Procedure LoadObjects;
var i,n,cw,nw:Integer;
    aObject:TOB;
begin
 n:=StrToInt(sp[1]);
 For i:=0 to n-1 do
 begin
  t.ReadLine;
  sp:=t.Parsed;
  cw:=0; nw:=sp.count;
  aObject:=TOB.Create;
  Objects.Add(aObject);
  With aObject do
  While cw<nw do
  begin
   w1:=sp[cw]; inc(cw);
   if w1='NAME:' then Name:=sp[cw]
   else if w1='ID:' then
   else if w1='SECTOR:' then
   else if w1='X:' then X:=StrToDouble(sp[cw])
   else if w1='Y:' then Y:=StrToDouble(sp[cw])
   else if w1='Z:' then Z:=StrToDouble(sp[cw])
   else if w1='PCH:' then PCH:=StrToDouble(sp[cw])
   else if w1='YAW:' then YAW:=StrToDouble(sp[cw])
   else if w1='ROL:' then ROL:=StrToDouble(sp[cw])
   else if w1='FLAGS:' then begin inc(cw); Flags:=StrToLongInt(sp[cw]); end;
  end;
 end;
end;

begin {TLEVEL.LOAD}
 t:=TParsedTextFile.CreateRead(OpenFileRead(Fname,0));
 Textures:=TStringList.Create;
 Palettes:=TStringList.Create;
 Cmaps:=TStringList.Create;
 Clear;
 Try
 Try
  While not t.eof do
 begin
  t.ReadLine;
  sp:=t.Parsed;
  if sp.Count=0 then continue;

  w1:=sp[0];
  if w1='LVT' then
  else if w1='LEVELNAME' then Name:=sp[1]
  else if w1='VERSION' then Version:=StrToDouble(sp[1])
  else if w1='PALETTES' then LoadPalettes
  else if w1='MUSIC' then Music:=sp[1]
  else if w1='PARALLAX' then begin Parallax_x:=StrToDouble(sp[1]); Parallax_y:=StrToDouble(sp[2]); end
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
 t:=TParsedTextFile.CreateRead(OpenFileRead(ChangeFileExt(Fname,'.obt'),0));

{ Try
  While not t.eof do
  begin
   t.ReadLine;
   sp:=t.Parsed;
   if sp.count=0 then continue;
   w1:=sp[0];
   if w1='OBT:' then
   else if w1='LEVELNAME' then
   else if w1='OBJECTS' then LoadObjects;
  end;
 Finally
  t.Fclose;
 end;}
end;

Procedure TLevel.Save(FName:String);
var t:TextFile;
    palettes,textures,cmaps:TStringList;
    s,w:integer;
    i:Integer;

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
 AssignFile(t,FName); ReWrite(t);
{ Compile the list of textures, colormaps and palettes}
palettes:=TStringList.Create;
cmaps:=TStringList.Create;
textures:=TStringList.Create;

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

 Try
  {Writing header}
  WriteString('LVT 1.1'); WriteString('');
  WriteString('#This file was created by LawMaker '+VersionString);WriteString('');
  WriteString('VERSION 1535.022197');

  WriteFmt('PALETTES %d',[Palettes.count]);
  For i:=0 to palettes.count-1 do
   WriteString(' PALETTE: '+Palettes[i]);

  WriteFmt('CMAPS %d',[cmaps.count]);
  For i:=0 to cmaps.count-1 do
   WriteString(' CMAPS: '+cmaps[i]);

  WriteString('MUSIC: '+Music);
  WriteFmt('PARALLAX %f %f',[Parallax_X,Parallax_Y]);
  WriteString('LIGHT SOURCE 0.0 0.0 0.0 0.0');
  WriteFmt('SHADES %d',[shades.count]);
  For i:=0 to Shades.count-1 do
  with Shades[i] do
   WriteFmt(' SHADE: %d %d %d %d %s',[r,g,b,b4,c1]);
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
  WriteFmt('SECTOR %x',[HexID]);
  WriteString(' NAME '+Name);
  WriteFmt(' AMBIENT %d',[ambient]);
  WriteFmt(' PALETTE %d',[IPalette]);
  WriteFmt(' CMAP %d',[ICmap]);
  WriteFmt(' FRICTION %f',[friction]);
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
  WriteFmt(' SLOPEDFLOOR %d %d %f',[l1,l2,f1]);
 if IsFlagSet(SECFLAG1_SLOPEDCEILING) then with CeilingSlope do
  WriteFmt(' SLOPEDFLOOR %d %d %f',[l1,l2,f1]);
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
   WriteFmt('  WALL: %x V1: %d V2: %d MID: %d %f %f TOP: %d %f %f BOT: %d %f %f OVERLAY: %d %f %f ADJOIN: %d MIRROR: %d DADJOIN: %d DMIRROR: %d FLAGS: %d %d LIGHT: %d',
                 [HexID,    V1,    V2,
                  IMID,MID.offsx,MID.offsy,
                  ITOP,TOP.offsx,TOP.offsy,
                  IBOT,BOT.offsx,BOT.offsy,
                  IOverlay,Overlay.offsx,Overlay.offsy,
                  Adjoin, Mirror, DAdjoin, DMirror,
                  flags,0,light]);
  end;
   WriteString('');
 end;

 Finally
  CloseFile(t);
  Textures.free;
  cmaps.free;
  palettes.free;
 end;

end;

Procedure TLevel.ImportLEV(FName:String);
var
     w1:String;
     sp:TStringParser;
     t:TTextFile;
     Palettes:TStringList;
     Textures:TStringList;
     Cmaps:TStringList;
begin
 t:=TTextFile.CreateRead(OpenFileRead(FName,0));
 Try
 Finally
 end;
end;

Procedure TLevel.ImportWAD(FName:String);
begin
end;

Procedure TLevel.ImportMAP(FName:String);
begin
end;

