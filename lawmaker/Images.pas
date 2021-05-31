unit Images;

interface
uses Windows,Graphics, SysUtils, Classes;

Type
    TStoredAs=(ByLines,ByCols);
    TImageInfo=class
      StoredAs:TStoredAs;
      width,height:word;
    end;

TImageSource=class
Protected
 FInfo:TImageInfo;
Public
 Pal:Array[0..255] of TRGBQuad;
 Property Info:TImageInfo read FInfo;
 Function LoadBitmap(bw,bh:Integer):TBitmap;
 procedure GetLine(var buf);virtual;abstract;
 Procedure GetCol(var buf);virtual;abstract;
Protected
 Constructor Create;
Private
 Function LoadByLines(w,h:Integer):TBitmap;
 Function LoadByCols(w,h:Integer):TBitmap;
 Procedure WriteHeader(f:TStream);
 Destructor Destroy;override;
end;

implementation

Constructor TImageSource.Create;
begin
 Finfo:=TImageInfo.Create;
end;

Destructor TImageSource.Destroy;
begin
 FInfo.Free;
end;

Function TImageSource.LoadBitmap(bw,bh:Integer):TBitmap;
begin
 if (bw=-1) then bw:=Info.Width;
 if (bh=-1) then bh:=Info.Height;
 case Info.StoredAs of
  byLines: Result:=LoadByLines(bw,bh);
   byCols: Result:=LoadByCols(bw,bh);
 end;
end;

Procedure TImageSource.WriteHeader(f:TStream);
var
   Bi:TBitmapInfoHeader;
   Bfh:TBitmapFileHeader;
   bw,bh,bw4:Integer;
begin
 bw:=Info.Width;
 bh:=Info.Height;
 if bw and 3=0 then bw4:=bw else bw4:=bw and $FFFFFFFC+4;

 With Bfh do
 begin
  bfType:=$4D42; {'BM'}
  bfOffBits:=sizeof(bfh)+sizeof(bi)+sizeof(TRGBQuad)*256;
  bfReserved1:=0;
  bfReserved2:=0;
  bfSize:=bfOffBits+bh*bw4;
 end;

FillChar(Bi,Sizeof(bi),0);

 With BI do
 begin
  biSize:=sizeof(BI);
  biWidth:=bw;
  biHeight:=bh;
  biPlanes:=1;
  biBitCount:=8;
end;
f.Write(bfh,sizeof(bfh));
f.Write(bi,sizeof(bi));
f.Write(Pal,sizeof(Pal));
end;

Function TImageSource.LoadByLines(w,h:Integer):TBitmap;
var
   i:Integer;
   Ms:TMemoryStream;
   pLine:Pchar;
   pos:Longint;
   bw,bh,bw4:Integer;
begin
Result:=nil;
bw:=Info.Width;
bh:=Info.Height;
if bw and 3=0 then bw4:=bw else bw4:=bw and $FFFFFFFC+4;
GetMem(Pline,bw4);

ms:=TMemoryStream.Create;
WriteHeader(ms);
 Try
  Pos:=ms.Position;
  for i:=Bh-1 downto 0 do
  begin
   GetLine(Pline^);
   ms.Position:=Pos+i*bw4;
   ms.Write(PLine^,bw4);
  end;
  ms.Position:=0;
  Result:=TBitmap.Create;
  Result.LoadFromStream(ms);
  Ms.Free;
  
 finally
  FreeMem(pLine);
 end;
end;

Function TImageSource.LoadByCols(w,h:Integer):TBitmap;
Const HeaderSize=sizeof(TBitmapInfoHeader)+sizeof(TBitmapFileHeader)+256*sizeof(TRGBQuad);
var
   i,j:Integer;
   Ms:TMemoryStream;
   pCol,pc:Pchar;
   pos:Longint;
   bw,bh,bw4:Integer;
   pbits,pb:pchar;
begin
Result:=nil;
bw:=Info.Width;
bh:=Info.Height;
if bw and 3=0 then bw4:=bw else bw4:=bw and $FFFFFFFC+4;
GetMem(PCol,bh);
ms:=TMemoryStream.Create;
ms.SetSize(HeaderSize+bw4*bh);
WriteHeader(ms);
 Try
  Pos:=ms.Position;
  pBits:=ms.Memory;
  pBits:=PBits+Pos;
  for i:=0 to bw-1 do
  begin
   GetCol(PCol^);
   pc:=pCol;
   pb:=PBits+i;
   for j:=0 to bh-1 do
   begin
    PB^:=pc^; inc(pc); inc(pb,bw4);
   end; 
  end;
  ms.Position:=0;
  Result:=TBitmap.Create;
  Result.LoadFromStream(ms);
  Ms.Free;
  
 finally
  FreeMem(PCol);
 end;
end;


end.
