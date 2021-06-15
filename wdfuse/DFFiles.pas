unit DFFiles;

interface
uses Wintypes,WinProcs,SysUtils;
{$i gbtypes.inc}
{$i types.inc}
const fmOpenRead=0;
      fmShareDenyNone=$40;
Type
	TBitmapInfo=record
	 w,h:word;
         dx,dy:Integer;
         Transparent,animated:boolean;
	end;

	TShortFname=string[12];
	TGOBFile=Class
	 gh:TGOBHeader;
	 Nfiles:TNEntries;
	 Gobh:integer;
	 hindex:Thandle;
	 Pindex:^TGOBEntry;
	 cfile:integer;
	 cstart,csize:longint;
	 Constructor OpenGob(GobName:TFileName);
	 Function OpenInGob(name:TShortFname):integer;
	 Function FRead(var b;size:integer):integer;
	 Procedure Fseek(Pos:longint);
	 Function Fsize:longint;
	 Destructor Done;
	end;

Type
	TDFFile=Class
	 fh:Integer;
	 Gob:TGobFile;
	 GobName:TfileName;
	 FileName:TShortFname;
	 GobOpen:boolean;
	 ExtFileOpen:boolean;
	 InGob:boolean;
	 Constructor Create;
	 Function FOpen(Name:TFileName):integer;
	 Function FRead(var b;size:integer):integer;
	 Procedure Fseek(Pos:longint);
	 Function Fsize:longint;
	 Destructor done;
	end;

        TDFImage=Class(TDFFile)
         NImgs:integer;
         {BM data}
         bmh:BM_header;
         bmmh:BM_Mheader;
         bmm:BM_Multi;
         bm_multiple:boolean;
         {FME data}
         fh1:TFrame;
         fh2:TCell;
         bi:TBitmapInfo;
         {WAX Data}
         wh:wax_header;
         hwaxstruct:Thandle;
         Pws:pchar;
         Cwax,waxes,nviews,nframes:integer;
         Coding:(DF_RAW,DF_RLE0,DF_RLE);
         F_type:(DF_BM,DF_FME,DF_WAX);
         col_ofs:array[0..5999] of longint;
         cbuf:array[0..5999] of byte;
         flipit:boolean;
         Constructor Create;
         Function Fopen(Name:TfileName):integer;
         Function Nimages:integer;
         Procedure SetCurrentImage(n:integer);
         Procedure GetInfo(var b:TbitmapInfo);
         Procedure GetColumn(var b; n:integer);
         Function NWaxes:integer;
         Procedure SetWax(N:integer);
         Destructor done;
        Private
         Function HowManyWaxes:integer;
         Function BM_init:integer;
         Function FME_init:integer;
         Function WAX_init:integer;
         Function BM_Nimages:integer;
         Function WAX_Nimages:integer;
         Procedure BM_SetCI(n:integer);
         Procedure WAX_SetCI(n:integer);
        end;

implementation

function DFRLE0_uncompress(ibuf,obuf:pchar; size:word):word;
var	ip,op:pchar;
	c:integer;
begin
 ip:=ibuf;op:=obuf;
while ip<(ibuf+size) do
begin
 c:=ord(ip^); inc(ip);
 if c<128 then begin Move(ip^,op^,c); inc(ip,c); inc(op,c); end
 else begin dec(c,128); Fillchar(op^,c,0); inc(op,c); end;
end;
 result:=op-obuf;
end;

function DFRLE_uncompress (ibuf,obuf:pchar; size:word):word;
var	ip,op:pchar;
	c:byte;
begin
 ip:=ibuf;op:=obuf;
while ip<(ibuf+size) do
begin
 c:=ord(ip^); inc(ip);
 if c<127 then begin Move(ip^,op^,c); inc(ip,c); inc(op,c); end
 else begin dec(c,128); Fillchar(op^,c,ip^); inc(op,c); inc(ip); end;
end;
 result:=op-obuf;
end;


Constructor TGOBFile.OpenGob(GobName:TFileName);
begin
 Gobh:=FileOpen(GobName,fmOpenRead or fmShareDenyNone);
 if gobh=-1 then raise Exception.CreateFmt('Could not open Gob %s' ,[GobName]);
 FileRead(gobh,gh,sizeof(gh));
 if gh.magic<>'GOB'#10 then
    FileClose(gobh);
    raise Exception.CreateFmt('Wrong Magic # in Gob %s' ,[GobName]);
 FileSeek(gobh,gh.index_ofs,0);
 FileRead(gobh,nfiles,sizeof(nfiles));
 hindex:=GlobalAlloc(GMEM_MOVEABLE,nfiles*sizeof(TGOBEntry));
 pindex:=GlobalLock(hindex);
 FileRead(gobh,pindex^,nfiles*sizeof(TGOBEntry));
 GlobalUnlock(hindex);
 cfile:=0;
end;

Destructor TGOBFile.Done;
begin
 FileClose(gobh);
 GlobalFree(hindex);
end;

Function TGOBFile.OpenInGob(name:TShortFname):integer;
var i:integer;
	tmp:array[0..12] of char;
begin
 OpenInGob:=-1;
 for i:=1 to length(name) do name[i]:=upcase(name[i]);
 Pindex:=GlobalLock(hindex);
 StrPcopy(tmp,name);
 for i:=0 to nfiles-1 do
 begin
  if StrComp(tmp,Pindex^.name)=0 then
  begin
   cfile:=i;
   csize:=Pindex^.size;
   cstart:=Pindex^.offs;
   FileSeek(gobh,cstart,0);
   OpenInGob:=0;
   break;
  end;
 Inc(Pindex);
 end;
 GlobalUnlock(hindex);
end;

Function TGOBFile.FRead(var b;size:integer):integer;
begin
 Fread:=FileRead(gobh,b,size);
end;

Procedure TGOBFile.Fseek(Pos:longint);
begin
 FileSeek(gobh,cstart+pos,0);
end;

Function TGOBFile.Fsize:longint;
begin
 Fsize:=csize;
end;

Constructor TDFFile.Create;
begin
 GobName:='';
 GobOpen:=false;
 ExtFileOpen:=false;
 InGob:=false;
end;

Destructor TDFFile.done;
begin
 if GobOpen then Gob.done;
 if ExtFileOpen then FileClose(fh);
end;

Function TDFFile.FOpen(Name:TFileName):integer;
var	NewGob:TFileName;
	NewFile:TShortFname;
Function ParseName:boolean;
var ps:integer;
begin
 ParseName:=true;
 ps:=pos(']',Name);
 if ps=0 then ParseName:=false
 else
 begin
  NewGob:=Copy(Name,2,ps-2);
  NewFile:=Copy(Name,ps+1,length(Name)-ps);
 end;
end;

begin
 Fopen:=-1;
 if Name[1]='[' then
 begin
  If not ParseName then exit;

  if GobName<>NewGob then
  begin
   GobName:=NewGob;
   if GobOpen then begin GobOpen:=false; Gob.done; end;
   Gob:=TGOBFile.OpenGob(GobName);
   if Gob=Nil then exit;
  end;

  If Gob.OpenInGob(NewFile)=-1 then begin FileName:=NewFile; exit; end;
  GobOpen:=true;
  InGob:=true;
  Fopen:=0;
 end
 else
 begin
  if ExtFileOpen then begin FileClose(fh); ExtFileOpen:=false; end;
  Fh:=FileOpen(Name,fmOpenRead or fmShareDenyNone); if fh<0 then exit;
  FileName:=Name;
  ExtFileOpen:=true;
  InGob:=false;
  Fopen:=0;
 end;
end;

Function TDFFile.FRead(var b;size:integer):integer;
begin
 if InGob then Fread:=Gob.Fread(b,size)
 else Fread:=FileRead(fh,b,size);
end;

Procedure TDFFile.Fseek(Pos:longint);
begin
 if InGob then Gob.Fseek(pos)
 else FileSeek(fh,pos,0);
end;

Function TDFFile.Fsize:longint;
var cpos:longint;
begin
if InGob then Fsize:=Gob.Fsize
else
begin
 cpos:=FileSeek(fh,1,0);
 Fsize:=FileSeek(fh,0,2);
 FileSeek(fh,cpos,0);
end;
end;


Function TDFImage.Fopen(Name:TfileName):integer;
var ext:string[4];
begin
 Result:=-1;
 if Inherited Fopen(Name)=-1 then exit;
 ext:=LowerCase(ExtractFileExt(Name));
 if ext='.bm' then f_type:=DF_BM
 else if ext='.fme' then f_type:=DF_FME
 else if ext='.wax' then F_type:=DF_WAX
 else exit;
 Case F_type of
  df_bm: if BM_init=-1 then exit;
  df_fme: if FME_init=-1 then exit;
  df_wax: if WAX_init=-1 then exit;
 end;
 Result:=0;
end;

Function TDFImage.Nimages:integer;
begin
 Result:=NImgs;
end;

Procedure TDFImage.SetCurrentImage(n:integer);
begin
 Case f_type of
  df_bm: BM_SetCI(n);
  df_wax: WAX_SetCI(n);
 end;
end;

Procedure TDFImage.GetInfo(var b:TbitmapInfo);
begin
 b:=bi;
end;

Procedure TDFImage.GetColumn(var b; n:integer);
var i,ncol:integer; P1,p2:Pchar;c:char; size:integer;
begin
 if flipit then ncol:=bi.w-n-1 else ncol:=n;
 FSeek(col_ofs[ncol]);
 case Coding of
  DF_RAW:Fread(b,bi.h);
  DF_RLE0:begin
           Fread(cbuf,col_ofs[ncol+1]-col_ofs[ncol]);
           DFRLE0_uncompress(@cbuf,@b,col_ofs[ncol+1]-col_ofs[ncol]);
          end;
  DF_RLE:begin
           Fread(cbuf,col_ofs[ncol+1]-col_ofs[ncol]);
           DFRLE_uncompress(@cbuf,@b,col_ofs[ncol+1]-col_ofs[ncol]);
          end;
 end;

 p1:=@b; p2:=p1+bi.h-1;
 for i:=0 to bi.h div 2-1 do
 begin
  c:=p1^;
  p1^:=p2^;
  P2^:=c;
  Inc(p1);
  dec(p2);
 end;
end;
{BM procedures}
Function TDFImage.BM_init:integer;
begin
 Result:=-1;
 Nimgs:=1;
 Fread(bmh,sizeof(bmh));
 if bmh.magic<>'BM'#32#30 then exit;
 bm_multiple:=false;
 if (bmh.sizex=1) and (bmh.datasize<>1) then
 begin
  NImgs:=bmh.idemy;
  Fread(bmm,sizeof(bmm));
  bm_multiple:=true;
 end;
 case bmh.compressed of
  0: coding:=DF_RAW;
  1: coding:=DF_RLE;
  2: coding:=DF_RLE0;
 end;
 Result:=0;
end;

Function TDFImage.BM_Nimages:integer;
begin
 Result:=1;
end;

Procedure TDFImage.BM_SetCI(n:integer);
var i:word; l:longint;
const
     BMM_Start=sizeof(BM_Header)+sizeof(bm_multi);
begin
 if not bm_multiple then
 begin
  bi.w:=bmh.sizex;
  bi.h:=bmh.sizey;
  bi.dx:=-(bi.w div 2);
  bi.dy:=-bi.h;
  bi.transparent:=bmh.transparent and 8<>0;
  bi.animated:=false;
  if coding=DF_RAW then for i:=0 to bi.w-1 do col_ofs[i]:=longint(i)*bi.h+sizeof(bmh)
  else
  begin
   Fseek(bmh.datasize+sizeof(bmh));
   FRead(col_ofs,bi.w*4);
   for i:=0 to bi.w-1 do inc(col_ofs[i],sizeof(bmh));
   col_ofs[bi.w]:=bmh.datasize+sizeof(bmh);
  end;
  flipit:=false;
  exit;
 end;
 Fseek(BMM_Start+n*4);
 Fread(l,sizeof(l));
 Fseek(l+BMM_Start);
 Fread(bmmh,sizeof(bmmh));
 bi.w:=bmmh.sizex;
 bi.h:=bmmh.sizey;
 bi.dx:=-(bi.w div 2);
 bi.dy:=-bi.h;
 bi.transparent:=bmmh.transparent and 8<>0;
 bi.animated:=false;
 for i:=0 to bi.w-1 do col_ofs[i]:=longint(i)*bi.h+sizeof(bmmh)+BMM_Start+l;
 flipit:=false;
end;

{FME Procedure}

Function TDFImage.FME_init:integer;
var i:word;
begin
 result:=-1;
 Fread(fh1,sizeof(fh1));
 Fseek(fh1.Cell);
 Fread(fh2,sizeof(fh2));
 with bi do
 begin
  w:=fh2.sizex;
  h:=fh2.sizey;
  dx:=fh1.xshift;
  dy:=fh1.yshift;
  transparent:=true;
  animated:=false;
 end;

 if fh2.compressed=0 then
 begin
  Coding:=DF_RAW;
  for i:=0 to bi.w-1 do col_ofs[i]:=longint(i)*bi.h+fh1.Cell+sizeof(fh2);
 end
 else
 begin
  Coding:=DF_RLE0;
  Fread(Col_ofs,bi.w*4);
  for i:=0 to bi.w-1 do inc(col_ofs[i],fh1.Cell);
  Col_ofs[bi.w]:=fh2.datasize+fh1.Cell;
 end;
 flipit:=fh1.flip<>0;
 Nimgs:=1;
 Result:=0;
end;

{WAX Procedures}
Constructor TDFImage.Create;
begin
 Inherited Create;
 HWaxStruct:=GlobalAlloc(GMEM_MOVEABLE, 10485760);
 if HWaxStruct=0 then raise Exception.Create('Could not allocate memory for Wax')
end;

Destructor TDFImage.done;
begin
 GlobalFree(HWaxStruct);
 Inherited Done;
end;

Function TDFImage.WAX_init:integer;
var ws_size:integer;
begin
 result:=-1;
 NImgs:=0;
 Fread(wh,sizeof(wh));
 if (wh.version<>$11000) and (wh.version<>$10000) then exit;
 waxes:=HowManyWaxes;
 ws_size:=waxes*sizeof(twax)+sizeof(tseq)*wh.nseqs+sizeof(tframe)*wh.nframes;
 if ws_size>32000 then exit;
 Pws:=GlobalLock(HwaxStruct);
  Fread(PWS^,ws_size);
 GlobalUnlock(HwaxStruct);

 SetWax(0);
 Result:=0;
end;

Function TDFImage.NWaxes:integer;
begin
 Result:=waxes;
end;

Function TDFImage.HowManyWaxes:integer;
var N:integer;
begin
 Result:=-1;
 if f_type<>DF_WAX then exit;
 N:=0;
 While (N<32) and (wh.waxes[n]<>0) do inc(N);
 if N=31 then exit;
 Result:=N;
end;

Procedure TDFImage.SetWax(N:integer);
var pwax:^Twax;
    pseq:^Tseq;
begin
if f_type<>DF_WAX then exit;
if N>waxes-1 then exit;
Pws:=GlobalLock(HwaxStruct);
 Cwax:=N;
 pwax:=pointer(pws-sizeof(wh)+wh.waxes[cwax]);
 if pwax^.seqs[0]=pwax^.seqs[8] then nviews:=1 else nviews:=5;
 pseq:=pointer(pws-sizeof(wh)+pwax^.seqs[0]);
 nframes:=0;
 while (nframes<32) and (pseq^.frames[nframes]<>0) do inc(nframes);
 nImgs:=nviews*nframes;
 GlobalUnlock(HWaxStruct);
end;

Function TDFImage.WAX_Nimages:integer;
begin
 Result:=nviews*nframes;
end;

Procedure TDFImage.WAX_SetCI(n:integer);
var pwax:^twax;
    pseq:^tseq;
    pframe:^Tframe;
    cell:Tcell;
    cseq,cframe:integer;
    i:integer;
    l:longint;
begin
cseq:=(n mod nviews)*4;
cframe:=n div nviews;
PWS:=GlobalLock(HWaxStruct);
pwax:=pointer(PWS-sizeof(wh)+wh.waxes[cwax]);
pseq:=pointer(PWS-sizeof(wh)+pwax^.seqs[cseq]);
pframe:=pointer(PWS-sizeof(wh)+pseq^.frames[cframe]);
FSeek(pframe^.cell);
Fread(cell,sizeof(cell));
 with bi do
 begin
  w:=cell.sizex;
  h:=cell.sizey;
  dx:=pframe^.xshift;
  dy:=pframe^.yshift;
  transparent:=true;
  animated:=true;
 end;

 if cell.compressed=0 then
 begin
  Coding:=DF_RAW;
  for i:=0 to bi.w-1 do col_ofs[i]:=longint(i)*bi.h+Pframe^.Cell+sizeof(Tcell);
 end
 else
 begin
  Coding:=DF_RLE0;
  Fread(Col_ofs,bi.w*4);
  for i:=0 to bi.w-1 do inc(col_ofs[i],pframe^.Cell);
  Col_ofs[bi.w]:=cell.datasize+pframe^.cell;
 end;
 flipit:=pframe^.flip<>0;
end;

end.
