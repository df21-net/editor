unit V_util32;

{viewers utilities}

interface
uses SysUtils, Graphics, WinTypes, WinProcs, StdCtrls, ExtCtrls, Classes,
     G_Util, Forms, Messages, Dialogs,
     _undoc, _files, _strings, M_Global;

TYPE
BYTES  = array[0..1000000] of Byte;
PBYTES = ^BYTES;

INTS  = array[0..1000000] of SmallInt;
PINTS = ^INTS;

LONGS  = array[0..1000000] of LongInt;
PLONGS = ^LONGS;

VAR
 LastPLTT_Low,
 LastPLTT_High : Byte;

function  LoadPALPalette(PalFile : String) : Boolean;
procedure ReleasePALPalette;
function  LoadPLTTPalette(PalFile : String) : Boolean;
procedure ReleasePLTTPalette;
Procedure SetBitmapPalette(ThePalette : HPalette; Image : TImage);

function  GetNormalHeader(TextureName : String): TBM_HEADER;
function  DisplayBMP     (GraphFile : String; Image : TImage; Info : TMemo) : Boolean;
function  DisplayBMHuge  (GraphFile : String; Image : TImage; Info : TMemo) : Boolean;
function  DisplayFMEHuge (GraphFile : String; Image : TImage; Info : TMemo) : Boolean;
function  DisplayWAXHuge (GraphFile : String; Image : TImage; Info : TMemo) : Boolean;

function  DisplayANIMDELT(GraphFile : String; Image : TImage; Info : TMemo; VAR Frame : Integer) : Boolean;

function  DisplayCMP     (GraphFile : String; Image : TImage; Info : TMemo) : Boolean;
function  DisplayPAL     (GraphFile : String; Image : TImage; Info : TMemo) : Boolean;
function  DisplayPLTT    (GraphFile : String; Image : TImage; Info : TMemo) : Boolean;

function  Display3DO     (GraphFile : String; ResName : String; Image : TImage; Info : TMemo) : Boolean;
function  DisplayFILM    (FilmName  : String; Info : TMemo) : Boolean;

implementation

{$O-}
function LoadPALPalette(PalFile : String) : Boolean;
var i              : Integer;
    pf             : Integer;
    palbuf         : array[0..770] of byte;
    TLPAL          : TLOGPALETTE;
    PALPalette     : array[0..255] of TPALETTEENTRY;
    VGA_Multiplier : Integer;
    value          : Integer;
begin
if FileExists(PalFile) then
  begin
     pf := FileOpen(PalFile, fmOpenRead);
     FileRead(pf, palbuf, 768);
     FileClose(pf);
     TLPAL.palVersion     := $300;
     TLPAL.palnumentries  := 256;
     VGA_Multiplier       := _VGA_MULTIPLIER;
     for i := 0 to 255 do
      begin
       value := VGA_Multiplier * palbuf[3*i];
       if value > 255 then value := 255;
       PALPalette[i].pered        := value;
       value := VGA_Multiplier * palbuf[3*i+1];
       if value > 255 then value := 255;
       PALPalette[i].pegreen      := value;
       value := VGA_Multiplier * palbuf[3*i+2];
       if value > 255 then value := 255;
       PALPalette[i].peblue       := value;
       PALPalette[i].peflags      := 0;
      end;
     HPALPalette := CreatePalette(TLPAL);
     SetPaletteEntries(HPALPalette, 0 , 256, PALPalette);
     LoadPALPalette := TRUE;
   end
 else
   LoadPALPalette := FALSE;
end;

procedure ReleasePALPalette;
begin
  DeleteObject(HPALPalette);
end;

function LoadPLTTPalette(PalFile : String) : Boolean;
var i             : Integer;
    pf            : Integer;
    palbuf        : array[0..770] of byte;
    TLPLTT        : TLOGPALETTE;
    PLTTPalette   : array[0..255] of TPALETTEENTRY;
    Pltt1, Pltt2  : Byte;
    len           : Integer;
    bidon         : Integer;
begin
if FileExists(PalFile) then
  begin
     pf := FileOpen(PalFile, fmOpenRead);
     FileRead(pf, pltt1, 1);
     FileRead(pf, pltt2, 1);

     LastPLTT_Low  := pltt1;
     LastPLTT_High := pltt2;

     bidon := 1;
     len := bidon * (pltt2-pltt1+1) * 3;
     FileRead(pf, palbuf, len);
     FileClose(pf);
     TLPLTT.palVersion     := $300;
     TLPLTT.palnumentries  := 256;
     for i := 0 to 255 do
      begin
       PLTTPalette[i].pered        := 0;
       PLTTPalette[i].pegreen      := 0;
       PLTTPalette[i].peblue       := 0;
       PLTTPalette[i].peflags      := 0;
      end;
     for i := pltt1 to pltt2 do
      begin
       PLTTPalette[i].pered        := palbuf[3*(i-pltt1)];
       PLTTPalette[i].pegreen      := palbuf[3*(i-pltt1)+1];
       PLTTPalette[i].peblue       := palbuf[3*(i-pltt1)+2];
       PLTTPalette[i].peflags      := 0;
      end;
     HPLTTPalette := CreatePalette(TLPLTT);
     SetPaletteEntries(HPLTTPalette, 0 , 256, PLTTPalette);
     LoadPLTTPalette := TRUE;
   end
 else
   LoadPLTTPalette := FALSE;
end;

procedure ReleasePLTTPalette;
begin
  DeleteObject(HPLTTPalette);
end;


Procedure SetBitmapPalette(ThePalette : HPalette; Image : TImage);
begin
   Image.Picture.Bitmap.Palette := ThePalette;
end;
{$O+}

{ BMP ******************************************************************** }
function  DisplayBMP     (GraphFile : String; Image : TImage; Info : TMemo) : Boolean;
var fin      : Integer;
    BMP_FH   : TBITMAPFILEHEADER;
    BMP_IH   : TBITMAPINFOHEADER;
begin
 Result := FALSE;

 {read the BMP headers to get some needed info}
 fin  := FileOpen(GraphFile, fmOpenRead);
 FileRead(fin, BMP_FH, 14);
 FileRead(fin, BMP_IH, 40);
 FileClose(fin);

 if BMP_FH.bfType <> 19778 then
  begin
   Info.Clear;
   Info.Lines.BeginUpdate;
   Info.Lines.Add(GraphFile);
   Info.Lines.Add('');
   Info.Lines.Add('Invalid BMP magic : ' + IntToStr(BMP_FH.bfType));
   Info.Lines.EndUpdate;
   exit;
  end;

 Result := TRUE;

 Image.Picture.LoadFromFile(GraphFile);
 Image.Height := Image.Picture.Graphic.Height;
 Image.Width  := Image.Picture.Graphic.Width;

 Info.Clear;
 Info.Lines.BeginUpdate;
 Info.Lines.Add(GraphFile);
 Info.Lines.Add('');
 Info.Lines.Add('Size X      : ' + IntToStr(BMP_IH.biWidth));
 Info.Lines.Add('Size Y      : ' + IntToStr(BMP_IH.biHeight));
 Info.Lines.Add('');
 Info.Lines.Add('Image Size  : ' + IntToStr(BMP_IH.biSizeImage));
 if BMP_IH.biSizeImage = 0 then
  Info.Lines.Add(' Calculated : ' + IntToStr(BMP_IH.biWidth*BMP_IH.biHeight));
 Info.Lines.Add('');
 Info.Lines.Add('Bit Planes  : ' + IntToStr(BMP_IH.biPlanes));
 Info.Lines.Add('Bit Count   : ' + IntToStr(BMP_IH.biBitCount));
 Info.Lines.Add('');
 CASE BMP_IH.biCompression OF
  0: Info.Lines.Add('Compression : ' + IntToStr(BMP_IH.biCompression) + ' (BI_RGB)');
  1: Info.Lines.Add('Compression : ' + IntToStr(BMP_IH.biCompression) + ' (BI_RLE8)');
  2: Info.Lines.Add('Compression : ' + IntToStr(BMP_IH.biCompression) + ' (BI_RLE4)');
 ELSE
  Info.Lines.Add('Compression : ' + IntToStr(BMP_IH.biCompression) + ' (Unknown, may be invalid!)');
 END;

 Info.Lines.Add('');

 CASE Image.Height OF
  1,2,4,8,16,32,64,128,256,512,1024,2048 : ;
 ELSE
  Info.Lines.Add('WARNING: Size Y is not a power of 2!');
 END;

 if (BMP_IH.biPlanes <> 1) or (BMP_IH.biBitCount <> 8) then
  Info.Lines.Add('WARNING: BMP is not 256 colors!');

 if BMP_IH.biCompression <> 0 then
  Info.Lines.Add('WARNING: BMP is RLE compressed!');

 Info.Lines.EndUpdate;

 with TheRESOURCE do
  begin
   Name   := GraphFile;
   Ext    := '.bmp';
   SizeX  := Image.Width;
   SizeY  := Image.Height;
  end;
end;

{ BM ********************************************************************* }

{ This is a stripped version of DisplayBMHuge to get the Header }
function GetNormalHeader(TextureName : String): TBM_HEADER;
var
  BMH : TBM_HEADER;
  gf : Integer;
  GlobalH   : THandle;
  GlobalP   : Pointer;
  GOBName,
  RESName,
  TheFile   : String;
  IX, LEN   : LongInt;
  OldCursor : HCursor;
begin
 GlobalH := GlobalAlloc( GMEM_MOVEABLE or GMEM_ZEROINIT , 10485760);
 if GlobalH <> 0 then
   begin
     GlobalP := GlobalLock(GlobalH);
     GOBName := TEXTURESgob;
     TheFile := GOBName;

     // Check if it exists in the Textures GOB
     if not IsResourceInGOB(GOBname, TextureName, IX, LEN) then
       begin
         IX := 0;
         TheFile := LEVELPath + '\' + TextureName;
       end;

     OldCursor := SetCursor(LoadCursor(0, IDC_WAIT));
     gf := FileOpen(TheFile, fmOpenRead);
     FileSeek(gf, IX, 0);
     FileRead(gf, BMH, 32);
     FileClose(gf);
     SetCursor(OldCursor);
     GetNormalHeader := BMH;
   end
  else
   begin
     Application.MessageBox('Cannot Allocate Buffer', 'Graphic Viewer Error', mb_Ok);
   end;
  GlobalUnlock(GlobalH);
  GlobalFree(GlobalH);
end;


{ This function also accept files in the form [x:\path\filename.gob]resource.ext             }
function DisplayBMHuge(GraphFile : String; Image : TImage; Info : TMemo) : Boolean;
var gf        : Integer;
    i,j,k,m,n : Integer;
    nbbm      : Integer;
    BMWidth   : Integer;
    BMHDC     : HDC;
    BMH       : TBM_HEADER;
    BMSUBH    : TBM_SUBHEADER;
    tmp       : array[0..127] of Char;
    GOBName   : String;
    RESName   : String;
    IX, LEN   : LongInt;
    TheFile   : String;
    OldCursor : HCursor;
    outstr,
    transp    : String;
    bmtype    : String;
    TheLong   : LongInt;
    Bidon     : LongInt;
    ptr       : PByte;
    bbtmp     : Byte;
    bbi,bbj   : LongInt;

    GlobalH   : THandle;
    GlobalP   : Pointer;
    TheAdrs   : Pointer;

    col_start,
    col_end   : LongInt;
    rle       : Integer;
    colorbyte : Byte;
    GlobalH2  : THandle;
    GlobalP2  : Pointer;
    bmp_align : LongInt;
    bmp_counter : LongInt;
begin
 { up the asset buffer cache to 10 MB }
 GlobalH := GlobalAlloc( GMEM_MOVEABLE or GMEM_ZEROINIT , 10485760);
 if GlobalH <> 0 then
   begin
     GlobalP := GlobalLock(GlobalH);
     if GraphFile[1] = '[' then
       begin
         GOBName := UpperCase(Copy(GraphFile, 2, Pos(']', GraphFile) - 2));
         TheFile := GOBName;
         RESName := UpperCase(Copy(GraphFile, Pos(']', GraphFile) + 1, Length(GraphFile) - Length(GOBName) -2));
         if not IsResourceInGOB(GOBname, RESName, IX, LEN) then
           Application.MessageBox('RES not found in GOB', 'Graphic Viewer Internal Error', mb_ok);
       end
     else
       begin
         IX := 0;
         TheFile := GraphFile;
       end;

     Bidon := 1;

     OldCursor := SetCursor(LoadCursor(0, IDC_WAIT));
     gf := FileOpen(TheFile, fmOpenRead);
     FileSeek(gf, IX, 0);
     FileRead(gf, BMH, 32);

     IF BMH.Compressed = 0 THEN
       if (BMH.SizeX <> 1) or ((BMH.SizeX = 1) and (BMH.SizeY = 1)) then
         begin
           bmtype := 'Type        : Simple';

           Image.Picture.Bitmap.Height := BMH.SizeY;
           Image.Picture.Bitmap.Width  := BMH.SizeX;
           if BMH.DataSize = 0 then BMH.DataSize := Bidon * BMH.SizeX * BMH.SizeY;
           BMHDC  := Image.Picture.Bitmap.Canvas.Handle;
           FileRead(gf, PBytes(GlobalP)^, BMH.dataSize);
           FileClose(gf);

           { *** Works much quicker but palette is semi-trashed,
                 because obviously SetPixel does color matching.
                 Should be good in 65536 colors ?
           GlobalH2 := GlobalAlloc( GMEM_MOVEABLE or GMEM_ZEROINIT , 200000);
           GlobalP2 := GlobalLock(GlobalH2);
           bmp_align := 4 - BMH.SizeX mod 4;
           if bmp_align = 4 then bmp_align := 0;
           bmp_counter := Bidon * (BMH.SizeX + bmp_align) * BMH.SizeY;
           }

           for i := 0 to BMH.SizeY-1 do
            begin
             for j := 0 to BMH.SizeX-1 do
              begin

               SetPixelV(BMHDC, j, BMH.SizeY-i-1 ,
               $1000000 + PBytes(GlobalP)^[BMH.SizeY * j + i]);

               {
               PBytes(GlobalP2)^[(BMH.SizeX + bmp_align) * (BMH.SizeY-i-1) + j] :=
                PBytes(GlobalP)^[BMH.SizeY * j + i];
               }
              end;
            end;

           {
           SetBitmapBits(Image.Picture.Bitmap.Handle, bmp_counter, GlobalP2);
           GlobalUnlock(GlobalH2);
           GlobalFree(GlobalH2);
           }

           Info.Clear;
           Info.Lines.BeginUpdate;
           Info.Lines.Add(GraphFile);
           Info.Lines.Add(' ');
           Info.Lines.Add(bmtype);
           Info.Lines.Add(' ');
           Info.Lines.Add(Format('Size X      : %3d (%5.3f)', [BMH.SizeX, BMH.SizeX/8]));
           Info.Lines.Add(Format('Size Y      : %3d (%5.3f)', [BMH.SizeY, BMH.SizeY/8]));
           Info.Lines.Add(Format('idem X      : %3d', [BMH.idemX]));
           Info.Lines.Add(Format('idem Y      : %3d', [BMH.idemY]));
           if BMH.transparent = 54
            then transp := '(NO)'
            else
             if BMH.transparent = 8
              then transp := '(WEAPON)'
              else transp := '(YES)';
           Info.Lines.Add('Transparent : ' + IntToHex(BMH.transparent,2) +'h '+ transp);
           Info.Lines.Add('logSizeY    : ' + IntToStr(BMH.logSizeY));
           Info.Lines.Add('Compressed  : ' + IntToStr(BMH.Compressed));
           Info.Lines.Add('Data Size   : ' + IntToStr(BMH.DataSize));
           Info.Lines.EndUpdate;

           with TheRESOURCE do
             begin
              Name   := GraphFile;
              Ext    := '.bm';
              SizeX  := BMH.SizeX;
              SizeY  := BMH.SizeY;
              if BMH.transparent = 54
               then Transparent := FALSE
               else Transparent := TRUE;
              Multiple := FALSE;
              Number   := 1;
             end;
         end
       else
         begin
           {Multiple / Animated}
           nbbm := BMH.idemY;
           FileRead(gf, PBytes(GlobalP)^, 1);
           if PByte(GlobalP)^ = 0 then
             begin
               bmtype := 'Type        : Multiple (Switch)';
               FileRead(gf, PBytes(GlobalP)^, 1+2*4);
             end
           else
             begin
               bmtype := 'Type        : Animated (rate = ' + IntToStr(PByte(GlobalP)^) + ')';
               FileRead(gf, PBytes(GlobalP)^, 1 + nbbm*4);
             end;
           Info.Clear;
           Info.Lines.BeginUpdate;
           Info.Lines.Add(GraphFile);
           Info.Lines.Add(' ');
           Info.Lines.Add(bmtype);
           Info.Lines.Add(' ');
           Info.Lines.Add('Main Header');
           Info.Lines.Add(' ');
           Info.Lines.Add(Format('Size X      : %3d (%5.3f)', [BMH.SizeX, BMH.SizeX/8]));
           Info.Lines.Add(Format('Size Y      : %3d (%5.3f)', [BMH.SizeY, BMH.SizeY/8]));
           Info.Lines.Add(Format('idem X      : %3d', [BMH.idemX]));
           Info.Lines.Add(Format('idem Y      : %3d', [BMH.idemY]));
           if BMH.transparent = 54
            then transp := '(NO)'
            else
             if BMH.transparent = 8
              then transp := '(WEAPON)'
              else transp := '(YES)';
           Info.Lines.Add('Transparent : ' + IntToHex(BMH.transparent,2) +'h '+ transp);
           Info.Lines.Add('logSizeY    : ' + IntToStr(BMH.logSizeY));
           Info.Lines.Add('Compressed  : ' + IntToStr(BMH.Compressed));
           Info.Lines.Add('Data Size   : ' + IntToStr(BMH.DataSize));
           Info.Lines.Add(' ');
           Info.Lines.Add('Number of BM: ' + IntToStr(nbbm));
           Info.Lines.Add(' ');

           with TheRESOURCE do
            begin
             Name   := GraphFile;
             Ext    := '.bm';
             SizeX  := BMH.SizeX;
             SizeY  := BMH.SizeY;
             if BMH.transparent = 54
              then Transparent := FALSE
              else Transparent := TRUE;
             Multiple := TRUE;
             Number   := nbbm;
            end;

            for k := 1 to nbbm do
             begin
               FileRead(gf, BMSUBH, SizeOf(TBM_SUBHEADER));
               Info.Lines.Add('Subheader '+ IntToStr(k));
               Info.Lines.Add(' ');
               Info.Lines.Add(Format('Size X      : %3d (%5.3f)', [BMSUBH.SizeX, BMSUBH.SizeX/8]));
               Info.Lines.Add(Format('Size Y      : %3d (%5.3f)', [BMSUBH.SizeY, BMSUBH.SizeY/8]));
               Info.Lines.Add(Format('idem X      : %3d', [BMSUBH.idemX]));
               Info.Lines.Add(Format('idem Y      : %3d', [BMSUBH.idemY]));
               if BMSUBH.transparent = 54
                then transp := '(NO)'
                else
                 if BMSUBH.transparent = 8
                  then transp := '(WEAPON)'
                  else transp := '(YES)';
               Info.Lines.Add('Transparent : ' + IntToHex(BMSUBH.transparent,2) +'h '+ transp);
               Info.Lines.Add('logSizeY    : ' + IntToStr(BMSUBH.logSizeY));
               Info.Lines.Add('Data Size   : ' + IntToStr(BMSUBH.DataSize));
               Info.Lines.Add(' ');
               Image.Picture.Bitmap.Height := BMSUBH.SizeY;
               Image.Picture.Bitmap.Width  := BMSUBH.SizeX * nbbm + 10 * (nbbm - 1);
               BMHDC := Image.Picture.Bitmap.Canvas.Handle;
               if k = 1 then PatBlt(BMHDC, 0, 0, 1000, 1000, BLACKNESS);
               FileRead(gf, PBytes(GlobalP)^, BMSUBH.DataSize);
               for i := 0 to BMSUBH.SizeY do
                 for j := 0 to BMSUBH.SizeX do
                  begin
                   SetPixelV(BMHDC, j+(k-1)*(10+BMSUBH.SizeX), BMSUBH.SizeY-i-1 ,
                            $1000000 + PBytes(GlobalP)^[i + BMSUBH.SizeY*j]);
                  end;
             end;
             Info.Lines.EndUpdate;
             FileClose(gf);
         end
     ELSE
       BEGIN
        {Compressed}
         Image.Picture.Bitmap.Height := BMH.SizeY;
         Image.Picture.Bitmap.Width  := BMH.SizeX;
         BMHDC  := Image.Picture.Bitmap.Canvas.Handle;
         FileRead(gf, PBytes(GlobalP)^, BMH.dataSize + BMH.SizeX * 4);

         for i := 0 to BMH.SizeX-1 do
          begin
           {col_start := PLongs(GlobalP)^[BMH.DataSize + i * 4];}
           col_start := PLongs(@(PBytes(GlobalP)^[BMH.DataSize + i * 4]))^[0];
           if i < BMH.SizeX-1 then
            col_end   := PLongs(@(PBytes(GlobalP)^[BMH.DataSize + (i+1) * 4]))^[0]
           else
            col_end   := BMH.DataSize;
           j         := 0;
           k         := 0;
           while (col_start+j < col_end) do
            begin
             if (PBytes(GlobalP)^[col_start+j] >= 128) then
              begin
               rle := PBytes(GlobalP)^[col_start+j] - 128;

               if BMH.Compressed = 1 then {RLE}
                begin
                 {position on color byte}
                 Inc(j);
                 colorbyte := PBytes(GlobalP)^[col_start+j];
                 for m :=0 to rle-1 do
                  begin
                   SetPixelV(BMHDC, i, BMH.SizeY-k-1 , $1000000 + colorbyte);
                   Inc(k);
                  end;
                 Inc(j);
                end
               else {RLE0}
                begin
                 for m :=0 to rle-1 do
                  begin
                   SetPixelV(BMHDC, i, BMH.SizeY-k-1 , $1000000);
                   Inc(k);
                  end;
                 Inc(j);
                end;

              end
             else
              begin
               n := PBytes(GlobalP)^[col_start+j];
               Inc(j);
               for m:=0 to n-1 do
                begin
                 SetPixelV(BMHDC, i, BMH.SizeY-k-1 ,
                   $1000000 + PBytes(GlobalP)^[col_start+j]);
                 Inc(k);
                 Inc(j);
                end;
              end;
           end;
          end;

        FileClose(gf);

        bmtype := 'Type        : Compressed';
        Info.Clear;
        Info.Lines.BeginUpdate;
        Info.Lines.Add(GraphFile);
        Info.Lines.Add(' ');
        Info.Lines.Add(bmtype);
        Info.Lines.Add(' ');
        Info.Lines.Add(Format('Size X      : %3d (%5.3f)', [BMH.SizeX, BMH.SizeX/8]));
        Info.Lines.Add(Format('Size Y      : %3d (%5.3f)', [BMH.SizeY, BMH.SizeY/8]));
        Info.Lines.Add(Format('idem X      : %3d', [BMH.idemX]));
        Info.Lines.Add(Format('idem Y      : %3d', [BMH.idemY]));
        if BMH.transparent = 54
         then transp := '(NO)'
         else
          if BMH.transparent = 8
           then transp := '(WEAPON)'
           else transp := '(YES)';
        Info.Lines.Add('Transparent : ' + IntToHex(BMH.transparent,2) +'h '+ transp);
        Info.Lines.Add('logSizeY    : ' + IntToStr(BMH.logSizeY));
        if BMH.Compressed = 1 then
         Info.Lines.Add('Compressed  : 1 (RLE)')
        else
         Info.Lines.Add('Compressed  : 2 (RLE0)');
        Info.Lines.Add('Data Size   : ' + IntToStr(BMH.DataSize));
        Info.Lines.EndUpdate;
       END;

     GlobalUnlock(GlobalH);
     GlobalFree(GlobalH);
     SetCursor(OldCursor);
     DisplayBMHuge := TRUE;
   end
 else
   begin
     Application.MessageBox('Cannot Allocate Buffer', 'Graphic Viewer Error', mb_Ok);
     DisplayBMHuge := FALSE;
   end;

end;

{ FME ******************************************************************** }
{ This function also accept files in the form [x:\path\filename.gob]resource.ext             }
function DisplayFMEHuge(GraphFile : String; Image : TImage; Info : TMemo) : Boolean;
var gf        : Integer;
    i,j,k,m,n : Integer;
    BMHDC     : HDC;
    FME1      : TFME_HEADER1;
    BMH       : TFME_HEADER2;
    GOBName   : String;
    RESName   : String;
    IX, LEN   : LongInt;
    TheFile   : String;
    OldCursor : HCursor;
    bmtype    : String;
    GlobalH   : THandle;
    GlobalP   : Pointer;
    col_start,
    col_end   : LongInt;
    rle       : Integer;
begin
 GlobalH := GlobalAlloc( GMEM_MOVEABLE or GMEM_ZEROINIT , 104857600);
 if GlobalH <> 0 then
   begin
     GlobalP := GlobalLock(GlobalH);
     if GraphFile[1] = '[' then
       begin
         GOBName := UpperCase(Copy(GraphFile, 2, Pos(']', GraphFile) - 2));
         TheFile := GOBName;
         RESName := UpperCase(Copy(GraphFile, Pos(']', GraphFile) + 1, Length(GraphFile) - Length(GOBName) -2));
         if not IsResourceInGOB(GOBname, RESName, IX, LEN) then
           Application.MessageBox('RES not found in GOB', 'Graphic Viewer Internal Error', mb_ok);
       end
     else
       begin
         IX := 0;
         TheFile := GraphFile;
       end;

     OldCursor := SetCursor(LoadCursor(0, IDC_WAIT));
     gf := FileOpen(TheFile, fmOpenRead);
     FileSeek(gf, IX, 0);
     FileRead(gf, FME1, 32);
     FileSeek(gf, IX + FME1.Header2, 0);
     FileRead(gf, BMH, 24);

     FileRead(gf, PByte(GlobalP)^, 140000);
     FileClose(gf);

     Image.Picture.Bitmap.Height := BMH.SizeY;
     Image.Picture.Bitmap.Width  := BMH.SizeX;
     BMHDC  := Image.Picture.Bitmap.Canvas.Handle;

     if BMH.Compressed = 0 then
      begin
       bmtype := 'Type        : Simple';
       for i := 0 to BMH.SizeX-1 do
        begin
         for j := 0 to BMH.SizeY-1 do
          begin
           if FME1.Flip = 0 then
            SetPixelV(BMHDC, i, BMH.SizeY-j-1 ,
              $1000000 + PBytes(GlobalP)^[BMH.SizeY * i + j])
           else
            SetPixelV(BMHDC, BMH.SizeX-i-1, BMH.SizeY-j-1 ,
              $1000000 + PBytes(GlobalP)^[BMH.SizeY * i + j]);
          end;
        end;
      end
     else
      begin
       {Compressed}
       bmtype := 'Type        : Compressed';
       for i := 0 to BMH.SizeX-1 do
        begin
         col_start := PLongs(GlobalP)^[i] - 24;
         if i < BMH.SizeX-1 then
          col_end   := PLongs(GlobalP)^[(i+1)] - 24
         else
          col_end   := BMH.DataSize - 24;
         j         := 0;
         k         := 0;
         while (col_start+j < col_end) do
          begin
           if (PBytes(GlobalP)^[col_start+j] >= 128) then
            begin
             rle := PBytes(GlobalP)^[col_start+j] - 128;
             { j++; contrary to BMs, where the next byte is the color }
             for m :=0 to rle-1 do
              begin
               if FME1.Flip = 0 then
                SetPixelV(BMHDC, i, BMH.SizeY-k-1 , $1000000)
               else
                SetPixelV(BMHDC, BMH.SizeX-i-1, BMH.SizeY-k-1 , $1000000);
               Inc(k);
              end;
             Inc(j);
            end
           else
            begin
             n := PBytes(GlobalP)^[col_start+j];
             Inc(j);
             for m:=0 to n-1 do
              begin
               if FME1.Flip = 0 then
                SetPixelV(BMHDC, i, BMH.SizeY-k-1 ,
                 $1000000 + PBytes(GlobalP)^[col_start+j])
               else
                SetPixelV(BMHDC, BMH.SizeX-i-1, BMH.SizeY-k-1 ,
                 $1000000 + PBytes(GlobalP)^[col_start+j]);
               Inc(k);
               Inc(j);
              end;
            end;
         end;
        end;
      end;

     Info.Clear;
     Info.Lines.BeginUpdate;
     Info.Lines.Add(GraphFile);
     Info.Lines.Add(' ');
     Info.Lines.Add(bmtype);
     Info.Lines.Add(' ');
     Info.Lines.Add('Insert X    : ' + IntToStr(FME1.InsertX));
     Info.Lines.Add('Insert Y    : ' + IntToStr(FME1.InsertY));
     Info.Lines.Add('Flipped     : ' + IntToStr(FME1.Flip));
     Info.Lines.Add(' ');
     Info.Lines.Add('Size X      : ' + IntToStr(BMH.SizeX));
     Info.Lines.Add('Size Y      : ' + IntToStr(BMH.SizeY));
     Info.Lines.Add('Compressed  : ' + IntToStr(BMH.Compressed));
     if BMH.Compressed = 0 then
      Info.Lines.Add('Data Size   : ' + IntToStr(BMH.SizeX * BMH.SizeY))
     else
      Info.Lines.Add('Data Size   : ' + IntToStr(BMH.DataSize));
     Info.Lines.EndUpdate;

     with TheRESOURCE do
      begin
       Name   := GraphFile;
       Ext    := '.fme';
       SizeX  := BMH.SizeX;
       SizeY  := BMH.SizeY;
       Compressed := (bmtype = 'Type        : Compressed');
       InsertX    := FME1.InsertX;
       InsertY    := FME1.InsertY;
       Flipped    := (FME1.Flip = 1);
      end;

     GlobalUnlock(GlobalH);
     GlobalFree(GlobalH);
     SetCursor(OldCursor);
     DisplayFMEHuge := TRUE;
   end
 else
   begin
     Application.MessageBox('Cannot Allocate Buffer', 'Graphic Viewer Error', mb_Ok);
     DisplayFMEHuge := FALSE;
   end;
end;

{ WAX ******************************************************************** }
function  DisplayWAXHuge(GraphFile : String; Image : TImage; Info : TMemo) : Boolean;
var gf        : Integer;
    i,j,k,m,n : Integer;
    BMHDC     : HDC;
    FME1      : TFME_HEADER1;
    BMH       : TFME_HEADER2;
    GOBName   : String;
    RESName   : String;
    IX, LEN   : LongInt;
    TheFile   : String;
    OldCursor : HCursor;
    bmtype    : String;
    GlobalH   : THandle;
    GlobalP   : Pointer;

    col_start,
    col_end   : LongInt;
    rle       : Integer;
    firstframe : LongInt;
begin

 GlobalH := GlobalAlloc( GMEM_MOVEABLE or GMEM_ZEROINIT , 10485760);
 if GlobalH <> 0 then
   begin
     GlobalP := GlobalLock(GlobalH);
     if GraphFile[1] = '[' then
       begin
         GOBName := UpperCase(Copy(GraphFile, 2, Pos(']', GraphFile) - 2));
         TheFile := GOBName;
         RESName := UpperCase(Copy(GraphFile, Pos(']', GraphFile) + 1, Length(GraphFile) - Length(GOBName) -2));
         if not IsResourceInGOB(GOBname, RESName, IX, LEN) then
           Application.MessageBox('RES not found in GOB', 'Graphic Viewer Internal Error', mb_ok);
       end
     else
       begin
         IX := 0;
         TheFile := GraphFile;
       end;

     OldCursor := SetCursor(LoadCursor(0, IDC_WAIT));
     gf := FileOpen(TheFile, fmOpenRead);

     { start of 'position' table }
     FileSeek(gf, IX + $000000BC, 0);
     FileRead(gf, firstframe, 4);
     Inc(firstframe, 16);
     FileSeek(gf, IX + firstframe, 0);
     FileRead(gf, firstframe, 4);
     FileSeek(gf, IX + firstframe, 0);

     FileRead(gf, FME1, 32);
     FileSeek(gf, IX + FME1.Header2, 0);
     FileRead(gf, BMH, 24);

     FileRead(gf, PByte(GlobalP)^, 140000);
     FileClose(gf);

     Image.Picture.Bitmap.Height := BMH.SizeY;
     Image.Picture.Bitmap.Width  := BMH.SizeX;
     BMHDC  := Image.Picture.Bitmap.Canvas.Handle;

     if BMH.Compressed = 0 then
      begin
       bmtype := 'Type        : Simple';
       for i := 0 to BMH.SizeX-1 do
        begin
         for j := 0 to BMH.SizeY-1 do
          begin
           SetPixelV(BMHDC, i, BMH.SizeY-j-1 ,
              $1000000 + PBytes(GlobalP)^[BMH.SizeY * i + j]);
          end;
        end;
      end
     else
      begin
       {Compressed}
       bmtype := 'Type        : Compressed';
       for i := 0 to BMH.SizeX-1 do
        begin
         col_start := PLongs(GlobalP)^[i] - 24;
         if i < BMH.SizeX-1 then
          col_end   := PLongs(GlobalP)^[(i+1)] - 24
         else
          col_end   := BMH.DataSize-24;
         j         := 0;
         k         := 0;
         while (col_start+j < col_end) do
          begin
           if (PBytes(GlobalP)^[col_start+j] >= 128) then
            begin
             rle := PBytes(GlobalP)^[col_start+j] - 128;
             { j++; contrary to BMs, where the next byte is the color }
             for m :=0 to rle-1 do
              begin
               SetPixelV(BMHDC, i, BMH.SizeY-k-1 , $1000000);
               Inc(k);
              end;
             Inc(j);
            end
           else
            begin
             n := PBytes(GlobalP)^[col_start+j];
             Inc(j);
             for m:=0 to n-1 do
              begin
               SetPixelV(BMHDC, i, BMH.SizeY-k-1 ,
                $1000000 + PBytes(GlobalP)^[col_start+j]);
               Inc(k);
               Inc(j);
              end;
            end;
         end;
        end;
      end;

     Info.Clear;
     Info.Lines.BeginUpdate;
     Info.Lines.Add(GraphFile);
     Info.Lines.Add(' ');
     Info.Lines.Add(bmtype);
     Info.Lines.Add(' ');
     Info.Lines.Add('Size X      : ' + IntToStr(BMH.SizeX));
     Info.Lines.Add('Size Y      : ' + IntToStr(BMH.SizeY));
     Info.Lines.Add('Compressed  : ' + IntToStr(BMH.Compressed));
     Info.Lines.Add('Data Size   : ' + IntToStr(BMH.SizeX * BMH.SizeY));
     Info.Lines.EndUpdate;

     with TheRESOURCE do
      begin
       Name   := GraphFile;
       Ext    := '.wax';
       SizeX  := BMH.SizeX;
       SizeY  := BMH.SizeY;
       Compressed := (bmtype = 'Type        : Compressed');
      end;

     GlobalUnlock(GlobalH);
     GlobalFree(GlobalH);
     SetCursor(OldCursor);
     DisplayWAXHuge := TRUE;
   end
 else
   begin
     Application.MessageBox('Cannot Allocate Buffer', 'Graphic Viewer Error', mb_Ok);
     DisplayWAXHuge := FALSE;
   end;
end;


{ ANIM and DELT *********************************************************** }
{ Contary to the gob resources, this function will NOT get the res. in a LFD}
function  DisplayANIMDELT(GraphFile : String; Image : TImage; Info : TMemo; VAR Frame : Integer) : Boolean;
var gf        : Integer;
    i         : Integer;
    OldCursor : HCursor;
    AHeader   : TDELTH;
    ALine     : TDELTL;
    skip      : Integer;
    rle       : Integer;
    n         : Byte;
    DHDC      : HDc;
    GlobalH   : THandle;
    GlobalP   : Pointer;
    curpos    : LongInt;
    DataSize  : LongInt;
    TotFrames : Integ16;
begin
 gf := FileOpen(GraphFile, fmOpenRead);

 IF Frame = -1 THEN
  BEGIN
   GlobalH := GlobalAlloc( GMEM_MOVEABLE or GMEM_ZEROINIT , FileSizing(gf));
   FileRead(gf, AHeader, SizeOf(TDELTH));
   DataSize := FileSizing(gf)-SizeOf(TDELTH);
  END
 ELSE
  BEGIN
   FileRead(gf, TotFrames, 2);
   {avoid any possible error here, it will be easier for the viewer also
    because Frame is a VAR parameter}
   if Frame >= TotFrames then Frame := TotFrames - 1;
   {now, just walk the embedded DELTs until the one we need}
   for i := 1 to Frame do
    begin
     FileRead(gf, DataSize, 4);
     FileSeek(gf, DataSize, 1);
    end;
   FileRead(gf, DataSize, 4);
   GlobalH := GlobalAlloc( GMEM_MOVEABLE or GMEM_ZEROINIT , DataSize);
   FileRead(gf, AHeader, SizeOf(TDELTH));
  END;

 if GlobalH = 0 then
  begin
   FileClose(gf);
   DisplayANIMDELT := FALSE;
   Application.MessageBox('Cannot Allocate Buffer', 'Graphic Viewer Error', mb_Ok);
   exit;
  end;

 OldCursor := SetCursor(LoadCursor(0, IDC_WAIT));
 GlobalP := GlobalLock(GlobalH);

 {read all the rest of the DELT in one go}
 FileRead(gf, PByte(GlobalP)^, DataSize);
 FileClose(gf);
 curpos := 0;

 Image.Picture.Bitmap.Width  := AHeader.SizeX+1;
 Image.Picture.Bitmap.Height := AHeader.SizeY+1;

 DHDC := Image.Picture.Bitmap.Canvas.Handle;
 PatBlt(DHDC, 0, 0, AHeader.SizeX+1, AHeader.SizeY+1, BLACKNESS);
 DHDC := Image.Picture.Bitmap.Canvas.Handle; {pq 2* ?}

 while TRUE do
  begin
   Aline.Size := PInts(@(PBytes(GlobalP)^[curpos]))^[0];
   Inc(curpos, 2);

   {check end !}
   if Aline.Size = 0 then break;

   {read X and Y pos}
   Aline.PosX := PInts(@(PBytes(GlobalP)^[curpos]))^[0];
   Inc(curpos, 2);
   Aline.PosY := PInts(@(PBytes(GlobalP)^[curpos]))^[0];
   Inc(curpos, 2);

   if (ALine.Size and 1) = 0 then
    begin
     {normal coding}
     for i := 0 to (ALine.Size shr 1) - 1 do
      begin
       SetPixelV(DHDC, ALine.PosX{-AHeader.OffsX} + i, Aline.PosY{-AHeader.OffsY},
                      $1000000 + PBytes(GlobalP)^[curpos]);
       Inc(curpos);
      end;
    end
   else
    begin
     {Copy or RLE}
     rle  := 0;
     skip := 0;
     while (rle < ALine.Size shr 1) do
      begin
       n := PBytes(GlobalP)^[curpos];
       Inc(curpos);

       if (n and 1) = 0 then
        begin
         {Copy}
         Inc(rle, n shr 1);
         for i := 0 to (n shr 1) - 1 do
          begin
           SetPixelV(DHDC, ALine.PosX{-AHeader.OffsX} + skip, Aline.PosY{-AHeader.OffsY},
                      $1000000 + PBytes(GlobalP)^[curpos]);
           Inc(curpos);
           Inc(skip);
          end;
        end
       else
        begin
         {RLE}
         Inc(rle, n shr 1);
         for i := 0 to (n shr 1) - 1 do
          begin
           SetPixelV(DHDC, ALine.PosX{-AHeader.OffsX} + skip, Aline.PosY{-AHeader.OffsY},
                      $1000000 + PBytes(GlobalP)^[curpos]);
           Inc(skip);
          end;
         Inc(curpos);
        end;
      end;
    end;
  end;

 GlobalUnlock(GlobalH);
 GlobalFree(GlobalH);

 IF Frame = -1 THEN
  BEGIN
   Info.Clear;
   Info.Lines.BeginUpdate;
   Info.Lines.Add(GraphFile);
   Info.Lines.Add(' ');
   Info.Lines.Add('Size X      : ' + IntToStr(AHeader.SizeX+1));
   Info.Lines.Add('Size Y      : ' + IntToStr(AHeader.SizeY+1));
   Info.Lines.Add('Offset X    : ' + IntToStr(AHeader.OffsX));
   Info.Lines.Add('Offset Y    : ' + IntToStr(AHeader.OffsY));
   Info.Lines.Add('Data Size   : ' + IntToStr(DataSize));
   Info.Lines.EndUpdate;

   with TheRESOURCE do
    begin
     Name     := GraphFile;
     Ext      := '.dlt';
     SizeX    := AHeader.SizeX;
     SizeY    := AHeader.SizeY;
     OffsetX  := AHeader.OffsX;
     OffsetY  := AHeader.OffsY;
    end;
  END
 ELSE
  BEGIN
   Info.Clear;
   Info.Lines.BeginUpdate;
   Info.Lines.Add(GraphFile);
   Info.Lines.Add(' ');
   Info.Lines.Add('Frame       : ' + IntToStr(Frame));
   Info.Lines.Add('Frame Range : 0 -> ' + IntToStr(TotFrames - 1));
   Info.Lines.Add(' ');
   Info.Lines.Add('Size X      : ' + IntToStr(AHeader.SizeX+1));
   Info.Lines.Add('Size Y      : ' + IntToStr(AHeader.SizeY+1));
   Info.Lines.Add('Offset X    : ' + IntToStr(AHeader.OffsX));
   Info.Lines.Add('Offset Y    : ' + IntToStr(AHeader.OffsY));
   Info.Lines.Add('Data Size   : ' + IntToStr(DataSize));
   Info.Lines.EndUpdate;

   with TheRESOURCE do
    begin
     Name     := GraphFile;
     Ext      := '.anm';
     SizeX    := AHeader.SizeX;
     SizeY    := AHeader.SizeY;
     OffsetX  := AHeader.OffsX;
     OffsetY  := AHeader.OffsY;
     Number   := TotFrames;
     Current  := Frame;
    end;
  END;

 DisplayANIMDELT := TRUE;
 SetCursor(OldCursor);
end;

{ CMP ******************************************************************** }
function  DisplayCMP     (GraphFile : String; Image : TImage; Info : TMemo) : Boolean;
var i, j      : Integer;
    gf        : Integer;
    OldCursor : HCursor;
    PalDC     : HDC;
    GlobalH   : THandle;
    GlobalP   : Pointer;
    DataSize  : LongInt;
begin
 gf := FileOpen(GraphFile, fmOpenRead);

 DataSize := FileSizing(gf);
 GlobalH := GlobalAlloc( GMEM_MOVEABLE or GMEM_ZEROINIT , DataSize);
 if GlobalH = 0 then
  begin
   FileClose(gf);
   DisplayCMP := FALSE;
   Application.MessageBox('Cannot Allocate Buffer', 'Graphic Viewer Error', mb_Ok);
   exit;
  end;

 DisplayCMP := TRUE; 
 OldCursor := SetCursor(LoadCursor(0, IDC_WAIT));
 GlobalP := GlobalLock(GlobalH);
 FileRead(gf, PByte(GlobalP)^, DataSize);
 FileClose(gf);

 Image.Picture.Bitmap.Width  := rcs*32;
 Image.Picture.Bitmap.Height := rcs*256;

 PalDC := Image.Picture.Bitmap.Canvas.Handle;
 PatBlt(PalDC, 0, 0, rcs*32, rcs*256, BLACKNESS);

 with Image.Picture.Bitmap.Canvas do
  begin
   Pen.Color   := clGray;
   Brush.Style := bsSolid;
   for i := 0 to 255 do
    for j := 0 to 31 do
     begin
      Brush.Color := $1000000 + PBytes(GlobalP)^[i + (31 - j) * 256];
      Rectangle(rcs * j, rcs * i, rcs * j + rcs - 1, rcs * i + rcs - 1);
      FloodFill(rcs * j + 1, rcs * i + 1, clGray, fsBorder);
     end;
  end;

 GlobalUnlock(GlobalH);
 GlobalFree(GlobalH);

 Info.Clear;
 Info.Lines.BeginUpdate;
 Info.Lines.Add(GraphFile);
 Info.Lines.Add(' ');
 Info.Lines.Add('Type        : CMP Colormap');
 Info.Lines.Add(' ');
 Info.Lines.Add('Data Size   : ' + IntToStr(DataSize));
 Info.Lines.EndUpdate;

 SetCursor(OldCursor);
end;




{ PAL ******************************************************************** }
function  DisplayPAL     (GraphFile : String; Image : TImage; Info : TMemo) : Boolean;
var i, j  : Integer;
    OldCursor : HCursor;
    PalDC : HDC;
begin
 OldCursor := SetCursor(LoadCursor(0, IDC_WAIT));
 Image.Picture.Bitmap.Width  := rs*16;
 Image.Picture.Bitmap.Height := rs*16;

 PalDC := Image.Picture.Bitmap.Canvas.Handle;
 PatBlt(PalDC, 0, 0, rs*16, rs*16, BLACKNESS);

 with Image.Picture.Bitmap.Canvas do
  begin
   Pen.Color   := clGray;
   Brush.Style := bsSolid;
   for i := 0 to 15 do
    for j := 0 to 15 do
     begin
      Brush.Color := $1000000 + Byte(i * 16 + j);
      Rectangle(rs * j, rs * i, rs * j + rs - 1, rs * i + rs - 1);
      FloodFill(rs * j + 1, rs * i + 1, clGray, fsBorder);
     end;
  end;

 Info.Clear;
 Info.Lines.BeginUpdate;
 Info.Lines.Add(GraphFile);
 Info.Lines.Add(' ');
 Info.Lines.Add('Type        : PAL Palette');
 Info.Lines.Add('Colors      : 256');
 Info.Lines.Add(' From       : 0');
 Info.Lines.Add(' To         : 255');
 Info.Lines.Add('Data Size   : 768');
 Info.Lines.EndUpdate;

 with TheRESOURCE do
  begin
   Name     := GraphFile;
   Ext      := '.pal';
   Colors   := 256;
   ColFrom  := 0;
   ColTo    := 255;
  end;

 SetCursor(OldCursor);
 DisplayPAL := TRUE;
end;

{ PLTT ******************************************************************* }
function  DisplayPLTT    (GraphFile : String; Image : TImage; Info : TMemo) : Boolean;
var i, j  : Integer;
    OldCursor : HCursor;
    PalDC : HDC;
begin
 OldCursor := SetCursor(LoadCursor(0, IDC_WAIT));
 Image.Picture.Bitmap.Width  := rs*16;
 Image.Picture.Bitmap.Height := rs*16;

 PalDC := Image.Picture.Bitmap.Canvas.Handle;
 PatBlt(PalDC, 0, 0, rs*16, rs*16, BLACKNESS);

 with Image.Picture.Bitmap.Canvas do
  begin
   Pen.Color   := clGray;
   Brush.Style := bsSolid;
   for i := 0 to 15 do
    for j := 0 to 15 do
     begin
      if ((Byte(i * 16 + j) <= LastPLTT_High) and
          (Byte(i * 16 + j) >= LastPLTT_Low)) then
       begin
        Brush.Color := $1000000 + Byte(i * 16 + j);
        Rectangle(rs * j, rs * i, rs * j + rs - 1, rs * i + rs - 1);
        FloodFill(rs * j + 1, rs * i + 1, clGray, fsBorder);
       end;
     end;
  end;

 Info.Clear;
 Info.Lines.BeginUpdate;
 Info.Lines.Add(GraphFile);
 Info.Lines.Add(' ');
 Info.Lines.Add('Type        : PLTT Palette');
 Info.Lines.Add('Colors      : ' + IntToStr(LastPLTT_High - LastPLTT_Low + 1));
 Info.Lines.Add(' From       : ' + IntToStr(LastPLTT_Low));
 Info.Lines.Add(' To         : ' + IntToStr(LastPLTT_High));
 Info.Lines.Add('Data Size   : ' + IntToStr(3*(LastPLTT_High - LastPLTT_Low + 1)));
 Info.Lines.EndUpdate;

 with TheRESOURCE do
  begin
   Name     := GraphFile;
   Ext      := '.plt';
   Colors   := LastPLTT_High - LastPLTT_Low + 1;
   ColFrom  := LastPLTT_Low;
   ColTo    := LastPLTT_High;
  end;

 SetCursor(OldCursor);
 DisplayPLTT := TRUE;
end;


{ 3DO ******************************************************************** }
function  Display3DO(GraphFile : String; ResName : String; Image : TImage; Info : TMemo) : Boolean;
var i,j,n        : Integer;
    OldCursor    : HCursor;
    BMHDC        : HDC;

    f3do         : System.TextFile;
    strin        : string;
    fVERTICES    : Boolean;
    pars         : TStringParser;
    code         : Integer;

    First        : Boolean;
    _3DO         : TStringList;

    The3DOObject : T3DO_Object;
    The3DOVertex : T3DO_Vertex;
    The3DOTriangle : T3DO_Triangle;
    The3DOQuad   : T3DO_Quad;

    minX, maxX,
    minY, maxY,
    minZ, maxZ,
    maxS         : Real;
    Scale3DO     : Real;
begin
 {Extract from gob, or copy file}

 log.Info('Loading 3D ' + ResName, logName);

 SysUtils.DeleteFile(WDFUSEdir + '\WDFGRAPH\' + 'WDF$$$$$.3DO');
 if GraphFile[1] = '[' then
  begin
   GOB_ExtractResource(WDFUSEdir + '\WDFGRAPH\', DARKgob, ResName);
   RenameFile(WDFUSEdir + '\WDFGRAPH\' + ResName, WDFUSEdir + '\WDFGRAPH\' + 'WDF$$$$$.3DO');
  end
 else
  begin
   CopyFile(GraphFile, WDFUSEdir + '\WDFGRAPH\' + 'WDF$$$$$.3DO');
  end;


  if not FileExists(WDFUSEdir + '\WDFGRAPH\' + 'WDF$$$$$.3DO') then
    begin
      Display3DO := FALSE;
      exit;
    end
  else
    begin
     OldCursor := SetCursor(LoadCursor(0, IDC_WAIT));

      _3DO := TStringList.Create;

      First      := TRUE;
      fVERTICES  := TRUE;
      minX := 99999;
      maxX := -99999;
      minY := 99999;
      maxY := -99999;
      minZ := 99999;
      maxZ := -99999;

      AssignFile(f3do, WDFUSEdir + '\WDFGRAPH\' + 'WDF$$$$$.3DO');
      Reset(f3do);
      try
        while not SeekEof(f3do) do
          begin
            Readln(f3do, strin);
            if Pos('#', strin) = 1 then
              begin
              end
            else
            if (Pos('VERTICES', UpperCase(strin)) = 1)  then
              begin
                if fVERTICES then
                 fVERTICES := FALSE
                else
                 begin
                  pars := TStringParser.Create(strin);
                  n    := StrToInt(pars[2]);
                  pars.Free;
                  while n > 0 do
                   begin
                    Readln(f3do, strin);
                    if (strin <> '') and (strin[1] <> '#') then
                     begin
                      The3DOVertex := T3DO_Vertex.Create;
                      with The3DOVertex do
                       begin
                        pars := TStringParser.Create(strin);
                        Val(pars[2], X, code);
                        Val(pars[3], Y, code);
                        Val(pars[4], Z, code);
                        pars.Free;
                        if X < minX then minX := X;
                        if Y < minY then minY := Y;
                        if Z < minZ then minZ := Z;
                        if X > maxX then maxX := X;
                        if Y > maxY then maxY := Y;
                        if Z > maxZ then maxZ := Z;
                        The3DOObject.Vertices.AddObject('V', The3DOVertex);
                       end;
                      Dec(n);
                     end;
                   end;
                 end;
              end
            else
            if Pos('TRIANGLES', UpperCase(strin)) = 1 then
              begin
                pars := TStringParser.Create(strin);
                n    := StrToInt(pars[2]);
                pars.Free;
                while n > 0 do
                 begin
                  Readln(f3do, strin);
                  if (strin <> '') and (strin[1] <> '#') then
                   begin
                    The3DOTriangle := T3DO_Triangle.Create;
                    with The3DOTriangle do
                     begin
                      pars := TStringParser.Create(strin);
                      Val(pars[2], A, code);
                      Val(pars[3], B, code);
                      Val(pars[4], C, code);
                      pars.Free;
                      The3DOObject.Triangles.AddObject('T', The3DOTriangle);
                     end;
                    Dec(n);
                   end;
                 end;
              end
            else
            if Pos('QUADS', UpperCase(strin)) = 1 then
              begin
                pars := TStringParser.Create(strin);
                n    := StrToInt(pars[2]);
                pars.Free;
                while n > 0 do
                 begin
                  Readln(f3do, strin);
                  if (strin <> '') and (strin[1] <> '#') then
                   begin
                    The3DOQuad := T3DO_Quad.Create;
                    with The3DOQuad do
                     begin
                      pars := TStringParser.Create(strin);
                      Val(pars[2], A, code);
                      Val(pars[3], B, code);
                      Val(pars[4], C, code);
                      Val(pars[5], D, code);
                      pars.Free;
                      The3DOObject.Quads.AddObject('Q', The3DOQuad);
                     end;
                    Dec(n);
                   end;
                 end;
              end
            else
            if Pos('OBJECT ', UpperCase(strin)) = 1 then
              begin
                if not First then _3DO.AddObject(The3DOObject.Name, The3DOObject);
                The3DOObject := T3DO_object.Create;
                pars := TStringParser.Create(strin);
                The3DOObject.Name := pars[2];
                pars.Free;
                First := FALSE;
              end
            else ;
          end
    except
        on E : Exception do
          begin
            Log.error('3D Parse Error ' + E.Message + ' error raised, with message : '+E.Message, LogName);
            CloseFile(f3do);
          end
      end;

     { add last }
     _3DO.AddObject(The3DOObject.Name, The3DOObject);
     System.CloseFile(f3do);

     {now, view it !!}
     maxS := -99999;
     if Abs(maxX) +  Abs(minX) > maxS then maxS := Abs(maxX) +  Abs(minX);
     if Abs(maxY) +  Abs(minY) > maxS then maxS := Abs(maxY) +  Abs(minY);
     if Abs(maxZ) +  Abs(minZ) > maxS then maxS := Abs(maxZ) +  Abs(minZ);
     if maxS <> 0 then
      Scale3DO := 100 / maxS
     else
      Scale3DO := 1;

     Image.Picture.Bitmap.Height := 400;
     Image.Picture.Bitmap.Width  := 400;
     BMHDC := Image.Picture.Bitmap.Canvas.Handle;
     PatBlt(BMHDC, 0,0,400,400, BLACKNESS);
     Image.Picture.Bitmap.Canvas.Pen.Color := clLime;
     Image.Picture.Bitmap.Canvas.Font.Color := clLime;
     Image.Picture.Bitmap.Canvas.Brush.Color := clBlack;

     with Image.Picture.Bitmap.Canvas do
      begin
       TextOut(  1,  1, 'X-Y');
       TextOut(  1,201, 'X-Z');
       TextOut(201,  1, 'Z-Y');
      end;

     with Image.Picture.Bitmap.Canvas do
     FOR i := 0 to _3DO.Count - 1 DO
      BEGIN
       The3DOObject := T3DO_Object(_3DO.Objects[i]);

       for j := 0 to The3DOObject.Triangles.Count - 1 do
        begin
         The3DOTriangle := T3DO_Triangle(The3DOObject.Triangles.Objects[j]);
         with The3DOTriangle do
          begin
           MoveTo(100+Round(Scale3DO*T3DO_Vertex(The3DOObject.Vertices.Objects[A]).X),
                  100+Round(Scale3DO*T3DO_Vertex(The3DOObject.Vertices.Objects[A]).Y));
           LineTo(100+Round(Scale3DO*T3DO_Vertex(The3DOObject.Vertices.Objects[B]).X),
                  100+Round(Scale3DO*T3DO_Vertex(The3DOObject.Vertices.Objects[B]).Y));
           LineTo(100+Round(Scale3DO*T3DO_Vertex(The3DOObject.Vertices.Objects[C]).X),
                  100+Round(Scale3DO*T3DO_Vertex(The3DOObject.Vertices.Objects[C]).Y));
           LineTo(100+Round(Scale3DO*T3DO_Vertex(The3DOObject.Vertices.Objects[A]).X),
                  100+Round(Scale3DO*T3DO_Vertex(The3DOObject.Vertices.Objects[A]).Y));

           MoveTo(300+Round(Scale3DO*T3DO_Vertex(The3DOObject.Vertices.Objects[A]).X),
                  100+Round(Scale3DO*T3DO_Vertex(The3DOObject.Vertices.Objects[A]).Z));
           LineTo(300+Round(Scale3DO*T3DO_Vertex(The3DOObject.Vertices.Objects[B]).X),
                  100+Round(Scale3DO*T3DO_Vertex(The3DOObject.Vertices.Objects[B]).Z));
           LineTo(300+Round(Scale3DO*T3DO_Vertex(The3DOObject.Vertices.Objects[C]).X),
                  100+Round(Scale3DO*T3DO_Vertex(The3DOObject.Vertices.Objects[C]).Z));
           LineTo(300+Round(Scale3DO*T3DO_Vertex(The3DOObject.Vertices.Objects[A]).X),
                  100+Round(Scale3DO*T3DO_Vertex(The3DOObject.Vertices.Objects[A]).Z));

           MoveTo(100+Round(Scale3DO*T3DO_Vertex(The3DOObject.Vertices.Objects[A]).Z),
                  300+Round(Scale3DO*T3DO_Vertex(The3DOObject.Vertices.Objects[A]).Y));
           LineTo(100+Round(Scale3DO*T3DO_Vertex(The3DOObject.Vertices.Objects[B]).Z),
                  300+Round(Scale3DO*T3DO_Vertex(The3DOObject.Vertices.Objects[B]).Y));
           LineTo(100+Round(Scale3DO*T3DO_Vertex(The3DOObject.Vertices.Objects[C]).Z),
                  300+Round(Scale3DO*T3DO_Vertex(The3DOObject.Vertices.Objects[C]).Y));
           LineTo(100+Round(Scale3DO*T3DO_Vertex(The3DOObject.Vertices.Objects[A]).Z),
                  300+Round(Scale3DO*T3DO_Vertex(The3DOObject.Vertices.Objects[A]).Y));

          end;
        end;

      for j := 0 to The3DOObject.Quads.Count - 1 do
        begin
         The3DOQuad := T3DO_Quad(The3DOObject.Quads.Objects[j]);
         with The3DOQuad do
          begin
           MoveTo(100+Round(Scale3DO*T3DO_Vertex(The3DOObject.Vertices.Objects[A]).X),
                  100+Round(Scale3DO*T3DO_Vertex(The3DOObject.Vertices.Objects[A]).Y));
           LineTo(100+Round(Scale3DO*T3DO_Vertex(The3DOObject.Vertices.Objects[B]).X),
                  100+Round(Scale3DO*T3DO_Vertex(The3DOObject.Vertices.Objects[B]).Y));
           LineTo(100+Round(Scale3DO*T3DO_Vertex(The3DOObject.Vertices.Objects[C]).X),
                  100+Round(Scale3DO*T3DO_Vertex(The3DOObject.Vertices.Objects[C]).Y));
           LineTo(100+Round(Scale3DO*T3DO_Vertex(The3DOObject.Vertices.Objects[D]).X),
                  100+Round(Scale3DO*T3DO_Vertex(The3DOObject.Vertices.Objects[D]).Y));
           LineTo(100+Round(Scale3DO*T3DO_Vertex(The3DOObject.Vertices.Objects[A]).X),
                  100+Round(Scale3DO*T3DO_Vertex(The3DOObject.Vertices.Objects[A]).Y));

           MoveTo(300+Round(Scale3DO*T3DO_Vertex(The3DOObject.Vertices.Objects[A]).X),
                  100+Round(Scale3DO*T3DO_Vertex(The3DOObject.Vertices.Objects[A]).Z));
           LineTo(300+Round(Scale3DO*T3DO_Vertex(The3DOObject.Vertices.Objects[B]).X),
                  100+Round(Scale3DO*T3DO_Vertex(The3DOObject.Vertices.Objects[B]).Z));
           LineTo(300+Round(Scale3DO*T3DO_Vertex(The3DOObject.Vertices.Objects[C]).X),
                  100+Round(Scale3DO*T3DO_Vertex(The3DOObject.Vertices.Objects[C]).Z));
           LineTo(300+Round(Scale3DO*T3DO_Vertex(The3DOObject.Vertices.Objects[D]).X),
                  100+Round(Scale3DO*T3DO_Vertex(The3DOObject.Vertices.Objects[D]).Z));
           LineTo(300+Round(Scale3DO*T3DO_Vertex(The3DOObject.Vertices.Objects[A]).X),
                  100+Round(Scale3DO*T3DO_Vertex(The3DOObject.Vertices.Objects[A]).Z));

           MoveTo(100+Round(Scale3DO*T3DO_Vertex(The3DOObject.Vertices.Objects[A]).Z),
                  300+Round(Scale3DO*T3DO_Vertex(The3DOObject.Vertices.Objects[A]).Y));
           LineTo(100+Round(Scale3DO*T3DO_Vertex(The3DOObject.Vertices.Objects[B]).Z),
                  300+Round(Scale3DO*T3DO_Vertex(The3DOObject.Vertices.Objects[B]).Y));
           LineTo(100+Round(Scale3DO*T3DO_Vertex(The3DOObject.Vertices.Objects[C]).Z),
                  300+Round(Scale3DO*T3DO_Vertex(The3DOObject.Vertices.Objects[C]).Y));
           LineTo(100+Round(Scale3DO*T3DO_Vertex(The3DOObject.Vertices.Objects[D]).Z),
                  300+Round(Scale3DO*T3DO_Vertex(The3DOObject.Vertices.Objects[D]).Y));
           LineTo(100+Round(Scale3DO*T3DO_Vertex(The3DOObject.Vertices.Objects[A]).Z),
                  300+Round(Scale3DO*T3DO_Vertex(The3DOObject.Vertices.Objects[A]).Y));
          end;
        end;

      END; {FOR all objects}
    
     Info.Clear;
     Info.Lines.BeginUpdate;
     Info.Lines.Add(GraphFile);
     Info.Lines.Add(' ');
     Info.Lines.Add('Objects : ' + IntToStr(_3DO.Count));
     for i := 0 to _3DO.Count - 1 do
      begin
       Info.Lines.Add(Format('.Object #%2d %s', [i, _3DO[i]]));
       The3DOObject := T3DO_Object(_3DO.Objects[i]);
       Info.Lines.Add('..Vertices  : ' + IntToStr(The3DOObject.Vertices.Count));
       Info.Lines.Add('..Triangles : ' + IntToStr(The3DOObject.Triangles.Count));
       Info.Lines.Add('..Quads     : ' + IntToStr(The3DOObject.Quads.Count));
      end;
     Info.Lines.EndUpdate;

     {free all!!}
     for i := 0 to _3DO.Count - 1 do
      begin
       The3DOObject := T3DO_Object(_3DO.Objects[i]);
       for j := 0 to The3DOObject.Vertices.Count - 1 do
        T3DO_Vertex(The3DOObject.Vertices.Objects[j]).Free;
       for j := 0 to The3DOObject.Triangles.Count - 1 do
        T3DO_Triangle(The3DOObject.Triangles.Objects[j]).Free;
       for j := 0 to The3DOObject.Quads.Count - 1 do
        T3DO_Quad(The3DOObject.Quads.Objects[j]).Free;
       The3DOObject.Free;
      end;

     _3DO.Free;

     SetCursor(OldCursor);
     Display3DO := TRUE;
    end;

end;

function  DisplayFILM    (FilmName  : String; Info : TMemo) : Boolean;
var fin    : Integer;
    magic  : Integer;
    durat  : Integer;
    numobj : Integer;
begin
 Result := FALSE;
 if not FileExists(FILMname) then
  begin
   ShowMessage('Non existent FILM in DisplayFILM !');
   exit;
  end;
 Result := TRUE;

 fin  := FileOpen(FILMname, fmOpenRead);
 FileRead(fin, magic,  2);
 FileRead(fin, durat,  2);
 FileRead(fin, numobj, 2);
 FileClose(fin);

 Info.Clear;
 Info.Lines.BeginUpdate;
 Info.Lines.Add(FILMName);
 Info.Lines.Add(' ');
 Info.Lines.Add('Type        : FILM');
 Info.Lines.Add(' ');
 if magic = 4 then
  Info.Lines.Add(Format('Magic       : %3d', [magic]))
 else
  Info.Lines.Add(Format('Magic       : %3d (INCORRECT !)', [magic]));
 Info.Lines.Add(Format('Duration    : %3d', [durat]));
 Info.Lines.Add(Format('Object Cnt  : %3d', [numobj]));
 Info.Lines.EndUpdate;

end;

end.
