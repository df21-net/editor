unit graph_files;

interface
uses Images, Graphics, Files, FileOperations, SysUtils, Misc_Utils;
Type
	TPCXHeader=packed record
	 manuf,
	 hard,
	 encod,
	 bitperpixel:byte;
	 x1,y1,x2,y2,
	 hres,vres:word;
	 palette:array[0..15] of record 	red,green,blue:byte; end;
	 vmode,
	 nplanes:byte;
	 byteperline,
	 palinfo,
	 shres,svres:word;
	 extra:array[0..53] of byte;
	end;

Type
TPCX=class(TImageSource)
 f:TFile;
 ph:TPCXHeader;
 lbuf:array[0..2047] of byte;
 bpos,bsize:Integer;
 Constructor Create(aF:TFile);
 Destructor Destroy;Override;
 procedure GetLine(var buf);override;
end;

implementation

type
TPCXPal=array[0..255] of record r,g,b:byte; end;


Destructor TPCX.Destroy;
begin
 if f<>nil then f.Fclose;
 Inherited Destroy;
end;

Constructor TPCX.Create(aF:TFile);
var
   Pxpal:TPCXPal;
   ptype:byte;
   i:Integer;
begin
 Inherited Create;
 f:=Af;

 f.fread(ph,sizeof(ph));
 if (ph.nPlanes<>1) or (ph.BitPerPixel<>8) then
 begin
  Raise Exception.Create('Not a 256 color PCX');
 end;
 FInfo.width:=ph.x2-ph.x1+1;
 FInfo.height:=ph.y2-ph.y1+1;
 FInfo.StoredAs:=ByLines;

 F.Fseek(F.Fsize-sizeof(pxpal)-sizeof(ptype));
 F.fread(ptype,sizeof(ptype));
 F.fread(pxpal,sizeof(pxpal));

 case ptype of
  10: for i:=0 to 255 do
  with pal[i] do
   begin
    rgbRed:=pxpal[i].r*4;
    rgbGreen:=pxpal[i].g*4;
    rgbBlue:=pxpal[i].b*4;
    rgbReserved:=0;
   end;
  12: for i:=0 to 255 do
  with pal[i] do
   begin
    rgbRed:=pxpal[i].r;
    rgbGreen:=pxpal[i].g;
    rgbBlue:=pxpal[i].b;
    rgbReserved:=0;
   end;
  else Raise Exception.Create('Cannot locate palette');
 end;
 f.Fseek(sizeof(ph));
 bpos:=0;
 bsize:=0;
end;

procedure TPCX.GetLine(var buf);
function GetNextByte:Byte;
begin
 if Bpos>=bsize then
 begin
  bsize:=F.FSize-F.Fpos;
  if bsize>sizeof(lbuf) then bsize:=sizeof(lbuf);
  F.Fread(Lbuf,bsize);
  bpos:=0;
 end;
 Result:=lbuf[bpos];inc(bpos);
end;

var
  cw,bw:Integer;
  c,b1:byte;
  pbuf:^byte;
begin
 bw:=ph.byteperline;
 pbuf:=@buf; cw:=0;
 while cw<bw do
 begin
  c:=getnextbyte;
  if (c and $C0)<>$c0 then begin pbuf^:=c; inc(Pbuf); inc(cw); end
  else
  begin
   b1:=getnextbyte;
   c:=c and 63;
   fillchar(Pbuf^,c,b1);
   inc(pBuf,c); inc(cw,c);
  end;
 end;
   if cw<>bw then PanMessage(mt_Warning,'Warning, bad data in the PCX file');
end;

(*
Function loadPCX(var f:file; var b:tbitmap):integer;
type line=array[0..0] of byte;
var
    h:pcxheader;
    pal:tpal;
    pos:longint;
    ptype:byte; {Palette type 10 - 0..63, 12 - 0..255}
    i:integer; p:pointer;
    bp,cw,bw:integer;
    b1,c:byte;

Function getnextbyte:byte;
var c:byte;
begin
if bp<sizeof(buf) then begin getnextbyte:=buf[bp]; inc(bp); end
    else begin fread(f,buf,sizeof(buf)); bp:=1; getnextbyte:=buf[0]; end;
 if inoutres=0 then if errorcode<>0 then;
end;

begin
 loadpcx:=-1;
 fread(f,h,sizeof(h));
 if (h.manuf<>10) and (h.hard<>5) then begin Fileerror('Only PCX version 5 is supported',f); exit; end;
 if (h.bitperpixel<>8) or (h.nplanes<>1) then begin Fileerror('Not a 256 color PCX',f); exit; end;
 seek(f,filesize(f)-sizeof(pal)-sizeof(ptype));
 fread(f,ptype,sizeof(ptype));
 fread(f,pal,sizeof(pal));
 case ptype of
  10: for i:=0 to 255 do
  with b.pal[i] do
   begin
    red:=pal[i].red*4;
    green:=pal[i].green*4;
    blue:=pal[i].blue*4;
   end;
  12: b.pal:=pal;
  else begin Fileerror('Cannot locate palette',f); exit; end;
 end;

 b.w:=h.x2-h.x1+1;
 b.h:=h.y2-h.y1+1;
 if enoughmem(b.w,b.h,f)=-1 then exit;
 b.bits:=heapptr;
 bw:=h.byteperline;
 seek(f,sizeof(h));
 bp:=sizeof(buf);
 for i:=b.h-1 downto 0 do
  begin
   cw:=0;
   while cw<bw do
   begin
    c:=getnextbyte;
    if (c and $C0)<>$c0 then begin cbuf[cw]:=c; inc(cw); end
    else
    begin
     b1:=getnextbyte;
     c:=c and 63;
     fillchar(cbuf[cw],c,b1);
     inc(cw,c);
    end;
   end;
   move(cbuf,ip(b.bits,b.w*i)^,b.w);
   if cw<>bw then Writeln('Warning, bad data in file ',getname(f));
   {write(cw-bw,'  '#13); seek(f,filepos(f)+(bw-b.w));}
  end;
 if errorcode=0 then loadpcx:=0 else Fileerror('Read fault',f);
end;}

function pcx_compress(ib,ob:pchar;size:word):word;
label _store;
var pi,po:pchar;
    c:char;
    left:word;
    rep:word;
begin
 Left:=size;pi:=ib;po:=ob;
While left>0 do
begin
 c:=pi^;inc(pi); dec(left);
 if (left=0) or (c<>pi^) then
 begin
  if (ord(c) and $C0)<>$C0 then begin po^:=c; inc(po); end
  else begin po^:=#$C1; inc(po); po^:=c; inc(po); end;
 end
 else
 begin
  rep:=2;dec(left);inc(pi);
  While (left>0) and (pi^=c) do begin inc(rep); dec(left); inc(pi); end;
  While rep>63 do begin po^:=#$FF; inc(po); po^:=c; inc(po); Dec(rep,63); end;
  if rep=0 then continue;
  if (rep=1) and ((ord(c) and $C0)<>$C0) then begin po^:=c; inc(po); end
  else begin po^:=chr($C0+rep); inc(po); po^:=c; inc(po); end;
 end;
end;
pcx_compress:=po-ob;
end;

{Function SavePCX(var f:file; var b:tbitmap):integer; {bottom-up bitmap}
type line=array[0..0] of byte;
var
    h:pcxheader;
    pos:longint;
    ptype:byte; {Palette type 10 - 0..63, 12 - 0..255}
    i:integer; p:pointer;
    bw:integer;

begin
 savepcx:=-1;
 h.manuf:=10;
 h.hard:=5;
 h.encod:=1;
 h.bitperpixel:=8;
 h.x1:=0; h.y1:=0;
 h.x2:=b.w-1; h.y2:=b.h-1;
 h.hres:=320;
 h.vres:=200;
 fillchar(h.palette,sizeof(h.palette),0);
 h.vmode:=$13;
 h.nplanes:=1;
 h.byteperline:=b.w;
 h.palinfo:=1;
 h.shres:=300; h.svres:=300;
 fillchar(h.extra,sizeof(h.extra),0);
 fwrite(f,h,sizeof(h));
 for i:=b.h-1 downto 0 do
 begin
  bw:=pcx_compress(ip(b.bits,b.w*i),@cbuf,b.w);
  fwrite(f,cbuf,bw);
 end;
 ptype:=12;
 fwrite(f,ptype,1);
 fwrite(f,b.pal,sizeof(b.pal));
 if errorcode=0 then savepcx:=0 else Fileerror('Write fault',f);
end;} *)


end.

end.
