unit NWX;

interface
uses Images, Files, SysUtils, misc_utils;

Type
TNWXHeader=packed record
magic:array[0..3] of char; {'WAXF'}
long2, {=2}
Long1:longint; {=1}
LongUn,longUn1:longint; {both 00 00 80 3F}
CELT_offs,
FRMT_offs,
CHOT_offs:longint;
end;

TCELLHeader=packed record
ID:longint;
cCELLSize:longint;
width,height:longint;
Flags:longint; {bit 1 - rotate 90?}
{array [0..dim2-1] of longint; - offsets to ? from beginning of CELT+$20}
end;

TCELTHeader=packed record
magic:array[0..3] of char; {CELT}
nCELLs:longint;
size:longint; {size of CELT}
end;

TNWX=class(TImageSource)
 f:TFile;
 cbuf:array[0..2047] of byte;
 offs:array[0..2047] of longint;
 nh:TNWXHeader;
 ch:TCELTHeader;
 ih:TCEllHeader;
 CCellStart:Longint;
 nline:integer;
 Constructor Create(aF:TFile);
 Destructor Destroy;Override;
 procedure GetLine(var buf);override;
 Procedure getCol(var buf);Override;
end;

implementation

const defpal:array[0..255] of record
 red,green,blue:byte;
 end=(
(red:255;green:0;blue:255),
(red:255;green:0;blue:255),
(red:255;green:0;blue:255),
(red:255;green:0;blue:255),
(red:255;green:0;blue:255),
(red:255;green:0;blue:255),
(red:255;green:0;blue:255),
(red:255;green:0;blue:255),
(red:255;green:0;blue:255),
(red:255;green:0;blue:255),
(red:255;green:0;blue:255),
(red:255;green:0;blue:255),
(red:255;green:0;blue:255),
(red:255;green:0;blue:255),
(red:255;green:0;blue:255),
(red:255;green:0;blue:255),
(red:255;green:243;blue:55),
(red:255;green:167;blue:35),
(red:255;green:83;blue:15),
(red:255;green:0;blue:15),
(red:251;green:251;blue:251),
(red:235;green:235;blue:235),
(red:223;green:223;blue:223),
(red:211;green:211;blue:211),
(red:195;green:195;blue:195),
(red:183;green:183;blue:183),
(red:171;green:171;blue:171),
(red:159;green:159;blue:159),
(red:143;green:143;blue:143),
(red:131;green:131;blue:131),
(red:119;green:119;blue:119),
(red:103;green:103;blue:103),
(red:91;green:91;blue:91),
(red:79;green:79;blue:79),
(red:63;green:63;blue:63),
(red:51;green:51;blue:51),
(red:39;green:39;blue:39),
(red:23;green:23;blue:23),
(red:11;green:11;blue:11),
(red:0;green:0;blue:0),
(red:255;green:247;blue:235),
(red:247;green:235;blue:219),
(red:239;green:223;blue:207),
(red:231;green:215;blue:191),
(red:223;green:203;blue:179),
(red:215;green:195;blue:167),
(red:207;green:183;blue:155),
(red:203;green:175;blue:143),
(red:195;green:163;blue:131),
(red:187;green:155;blue:119),
(red:179;green:147;blue:111),
(red:171;green:135;blue:99),
(red:163;green:127;blue:91),
(red:155;green:119;blue:83),
(red:147;green:111;blue:75),
(red:143;green:103;blue:67),
(red:135;green:91;blue:59),
(red:127;green:87;blue:51),
(red:119;green:79;blue:43),
(red:111;green:71;blue:39),
(red:103;green:63;blue:31),
(red:95;green:55;blue:27),
(red:87;green:51;blue:23),
(red:83;green:43;blue:19),
(red:75;green:39;blue:15),
(red:67;green:31;blue:11),
(red:59;green:27;blue:7),
(red:51;green:23;blue:7),
(red:43;green:15;blue:0),
(red:35;green:11;blue:0),
(red:27;green:7;blue:0),
(red:23;green:7;blue:0),
(red:255;green:171;blue:171),
(red:219;green:123;blue:123),
(red:183;green:87;blue:87),
(red:147;green:55;blue:55),
(red:115;green:31;blue:31),
(red:79;green:15;blue:15),
(red:43;green:0;blue:0),
(red:11;green:0;blue:0),
(red:255;green:131;blue:0),
(red:219;green:111;blue:0),
(red:183;green:95;blue:0),
(red:151;green:75;blue:0),
(red:115;green:59;blue:0),
(red:83;green:39;blue:0),
(red:47;green:23;blue:0),
(red:15;green:7;blue:0),
(red:243;green:191;blue:127),
(red:211;green:155;blue:95),
(red:179;green:123;blue:67),
(red:147;green:91;blue:43),
(red:115;green:67;blue:23),
(red:83;green:43;blue:11),
(red:51;green:23;blue:0),
(red:19;green:7;blue:0),
(red:179;green:175;blue:103),
(red:159;green:143;blue:75),
(red:139;green:115;blue:55),
(red:119;green:87;blue:39),
(red:99;green:63;blue:23),
(red:79;green:39;blue:11),
(red:59;green:19;blue:0),
(red:39;green:7;blue:0),
(red:211;green:183;blue:0),
(red:183;green:143;blue:0),
(red:155;green:107;blue:0),
(red:131;green:79;blue:0),
(red:103;green:55;blue:0),
(red:79;green:35;blue:0),
(red:51;green:19;blue:0),
(red:27;green:7;blue:0),
(red:227;green:227;blue:251),
(red:191;green:191;blue:219),
(red:155;green:159;blue:187),
(red:123;green:131;blue:155),
(red:95;green:103;blue:127),
(red:47;green:67;blue:95),
(red:15;green:39;blue:67),
(red:0;green:23;blue:39),
(red:239;green:215;blue:215),
(red:207;green:179;blue:175),
(red:175;green:143;blue:139),
(red:143;green:115;blue:107),
(red:111;green:87;blue:79),
(red:79;green:59;blue:51),
(red:47;green:35;blue:23),
(red:15;green:11;blue:7),
(red:255;green:251;blue:207),
(red:247;green:239;blue:171),
(red:243;green:231;blue:143),
(red:239;green:215;blue:111),
(red:235;green:203;blue:79),
(red:231;green:187;blue:51),
(red:227;green:171;blue:23),
(red:223;green:155;blue:0),
(red:199;green:131;blue:0),
(red:175;green:111;blue:0),
(red:151;green:91;blue:0),
(red:127;green:75;blue:0),
(red:103;green:59;blue:0),
(red:79;green:43;blue:0),
(red:55;green:27;blue:0),
(red:31;green:15;blue:0),
(red:255;green:191;blue:175),
(red:239;green:171;blue:151),
(red:223;green:155;blue:131),
(red:211;green:139;blue:115),
(red:195;green:123;blue:99),
(red:183;green:111;blue:83),
(red:167;green:99;blue:67),
(red:155;green:87;blue:55),
(red:139;green:75;blue:43),
(red:123;green:63;blue:31),
(red:111;green:55;blue:23),
(red:95;green:47;blue:15),
(red:83;green:39;blue:11),
(red:67;green:31;blue:7),
(red:55;green:23;blue:0),
(red:43;green:19;blue:0),
(red:227;green:227;blue:251),
(red:199;green:199;blue:235),
(red:175;green:179;blue:223),
(red:151;green:159;blue:207),
(red:127;green:139;blue:191),
(red:107;green:123;blue:179),
(red:87;green:107;blue:163),
(red:71;green:95;blue:151),
(red:55;green:83;blue:135),
(red:43;green:71;blue:123),
(red:31;green:63;blue:107),
(red:19;green:55;blue:95),
(red:11;green:43;blue:79),
(red:7;green:35;blue:67),
(red:0;green:31;blue:51),
(red:0;green:23;blue:39),
(red:231;green:255;blue:163),
(red:219;green:239;blue:143),
(red:211;green:223;blue:123),
(red:199;green:207;blue:103),
(red:191;green:191;blue:87),
(red:179;green:171;blue:75),
(red:163;green:151;blue:59),
(red:147;green:127;blue:47),
(red:131;green:107;blue:39),
(red:115;green:87;blue:27),
(red:103;green:71;blue:19),
(red:87;green:55;blue:11),
(red:71;green:39;blue:7),
(red:55;green:23;blue:0),
(red:39;green:15;blue:0),
(red:27;green:7;blue:0),
(red:215;green:255;blue:255),
(red:199;green:251;blue:255),
(red:187;green:247;blue:255),
(red:175;green:243;blue:255),
(red:163;green:235;blue:255),
(red:147;green:231;blue:255),
(red:135;green:219;blue:255),
(red:123;green:211;blue:255),
(red:107;green:199;blue:255),
(red:95;green:187;blue:255),
(red:83;green:175;blue:255),
(red:71;green:159;blue:255),
(red:55;green:143;blue:255),
(red:43;green:127;blue:255),
(red:31;green:107;blue:255),
(red:19;green:91;blue:255),
(red:255;green:247;blue:223),
(red:255;green:235;blue:191),
(red:255;green:219;blue:159),
(red:255;green:203;blue:131),
(red:235;green:183;blue:115),
(red:219;green:167;blue:99),
(red:199;green:151;blue:87),
(red:183;green:135;blue:71),
(red:163;green:119;blue:63),
(red:147;green:103;blue:51),
(red:127;green:87;blue:39),
(red:111;green:71;blue:31),
(red:91;green:59;blue:23),
(red:75;green:47;blue:15),
(red:55;green:35;blue:11),
(red:39;green:23;blue:7),
(red:255;green:0;blue:255),
(red:255;green:0;blue:255),
(red:255;green:0;blue:255),
(red:255;green:0;blue:255),
(red:255;green:0;blue:255),
(red:255;green:0;blue:255),
(red:255;green:0;blue:255),
(red:255;green:0;blue:255),
(red:255;green:0;blue:255),
(red:255;green:0;blue:255),
(red:255;green:0;blue:255),
(red:255;green:0;blue:255),
(red:255;green:0;blue:255),
(red:255;green:0;blue:255),
(red:255;green:0;blue:255),
(red:255;green:0;blue:255),
(red:255;green:0;blue:255),
(red:255;green:0;blue:255),
(red:255;green:0;blue:255),
(red:255;green:0;blue:255),
(red:255;green:0;blue:255),
(red:255;green:0;blue:255),
(red:255;green:0;blue:255),
(red:255;green:0;blue:255),
(red:255;green:0;blue:255),
(red:255;green:0;blue:255),
(red:255;green:0;blue:255),
(red:255;green:0;blue:255),
(red:255;green:0;blue:255),
(red:255;green:0;blue:255),
(red:255;green:0;blue:255),
(red:255;green:0;blue:255));

Function NWXDecode(var ib,ob;ibs,obs:word):word;
var pi,po:pchar;
    ip,op:integer;
    cb,cc:byte;
begin
  pi:=@ib; po:=@ob;
  ip:=0;op:=0;
  while (ip<ibs) and (op<obs) do
  begin
   cb:=byte((pi+ip)^);inc(ip);
   cc:=cb shr 1+1;
   if cb and 1=0 then
   begin
    Move((pi+ip)^,Po^,cc);
    Inc(ip,cc); inc(op,cc); po:=po+cc;
   end
   else
   begin
    FillChar(po^,cc,(pi+ip)^);
    inc(ip);
    inc(op,cc);
    po:=Po+cc;
   end;
  end;
 NWXDecode:=op;
end;



Destructor TNWX.Destroy;
begin
 if f<>nil then f.Fclose;
 Inherited Destroy;
end;

Constructor TNWX.Create(aF:TFile);
var
   i:Integer;
begin
 Inherited Create;
 f:=Af;

 f.fread(nh,sizeof(nh));
 if nh.magic<>'WAXF' then Raise Exception(af.GetFullName+' is not an NWX file');

 f.Fseek(nh.Celt_offs);
 F.FRead(ch,sizeof(ch));
 f.FRead(ih,sizeof(ih));
 CCellStart:=F.FPos;

 FInfo.width:=ih.Width;
 FInfo.height:=ih.Height;
 if ih.Flags and 1=0 then
 begin
  FInfo.StoredAs:=ByLines;
  F.Fread(Offs,ih.height*4);
  offs[ih.height]:=ih.cCELLSize-1;
 end
 else
 begin
  FInfo.StoredAs:=ByCols;
  F.Fread(Offs,ih.width*4);
  offs[ih.width]:=ih.cCELLSize-1;
 end;

 for i:=0 to 255 do
  with pal[i] do
   begin
    rgbRed:=defpal[i].red;
    rgbGreen:=defpal[i].green;
    rgbBlue:=defpal[i].blue;
    rgbReserved:=0;
   end;
end;

procedure TNWX.GetLine(var buf);
var
  sz:Integer;
begin
  f.Fseek(Offs[nline]+CCellStart);
  sz:=Offs[nline+1]-Offs[nline];
  f.FRead(cbuf,sz);
  NWXDecode(cbuf,buf,sz,FInfo.Width);
   inc(nline);
end;

procedure TNWX.GetCol(var buf);
var
  sz:Integer;
begin
  f.Fseek(Offs[nline]+CCellStart);
  sz:=Offs[nline+1]-Offs[nline];
  f.FRead(cbuf,sz);
  NWXDecode(cbuf,buf,sz,FInfo.Height);
   inc(nline);
end;

end.
