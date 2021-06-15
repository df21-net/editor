unit C_util32;

{conversion utilities}

interface
uses SysUtils, Graphics, WinTypes, WinProcs, StdCtrls, ExtCtrls, Classes,
     G_Util, Forms, Messages, Dialogs, IniFiles,
     _undoc, _files, _strings, M_Global, T_PalOpt;

TYPE
BYTES  = array[0..1000000] of Byte;
PBYTES = ^BYTES;

INTS  = array[0..1000000] of SmallInt;
PINTS = ^INTS;

LONGS  = array[0..1000000] of LongInt;
PLONGS = ^LONGS;


procedure Quantize256(palette1, palette2 : array of Byte;
                      VAR quantize_array : array of Byte);

function ConvertPAL2PLTT(PALname, PLTTname : String) : Boolean;
function ConvertPLTT2PAL(PLTTname, PALname : String) : Boolean;

function ConvertBM2BMP(BMname, PALname, BMPname : String) : Boolean;
function ConvertFME2BMP(FMEname, PALname, BMPname : String) : Boolean;
function ConvertANIMDELT2BMP(DELTname, PLTTname, BMPname : String; Frame : Integer) : Boolean;

function ConvertBMP2BM(BMPname, BMname, PALname : String;
                       UsePalette, IsTransparent  : Boolean) : Boolean;

function ConvertBMP2UnCompressedFME(BMPname, FMEname, PALname : String;
                                    InsX, InsY : LongInt; SelfCalc : Boolean;
                                    IsFlip, UsePalette : Boolean) : Boolean;

function ConvertBMP2CompressedFME(BMPname, FMEname, PALname : String;
                                  InsX, InsY : LongInt; SelfCalc : Boolean;
                                  IsFlip, UsePalette : Boolean) : Boolean;

function ConvertBMP2DELT(BMPname, DELTname, PALname : String;
                         OffsetX, OffsetY : Integer;
                         UsePalette       : Boolean) : Boolean;


function ANIMSplit(ANIMname, OutputDir : String) : Boolean;
function ANIMGroup(ANIMname, InputDir : String; TheFiles : TStrings) : Boolean;

function BMSplit(BMname, OutputDir : String) : Boolean;
function BMGroup(BMname, InputDir : String; TheFiles : TStrings) : Boolean;

function FILMDecompile(FILMName : String; Output : TMemo) : Boolean;
function FILMCompile(FILMName : String; Input : TMemo) : Boolean;

implementation

{ QUANTIZE ****************************************************************}
procedure Quantize256(palette1, palette2 : array of Byte;
                      VAR quantize_array : array of Byte);
var i, j      : Integer;
    Bidon     : LongInt;
    minfound  : LongInt;
    minsq     : Longint;
begin

Bidon := 1;

for i := 0 to 255 do
 begin
   minfound := 999999999;
   for j := 0 to 255 do
    begin
     {palette options}
     if (j = 0) and (TktPalette.ConvertNot0.Checked) then Continue;
     if (j > 0) and (j < 32) and (TktPalette.ConvertNot131.Checked) then Continue;

     minsq := Bidon *
         (palette1[3*i]  -palette2[3*j]  )*(palette1[3*i]  -palette2[3*j]  )
       + (palette1[3*i+1]-palette2[3*j+1])*(palette1[3*i+1]-palette2[3*j+1])
       + (palette1[3*i+2]-palette2[3*j+2])*(palette1[3*i+2]-palette2[3*j+2]);
     if i = j then
      begin
       { so if color i has multiple possible minseqs, it will take the
          one with the same index if possible. This will solve the
          0 20 0  <=> 20 0 0 problem when palettes are the same
       }
       if minsq <= minfound then
        begin
         minfound          := minsq;
         quantize_array[i] := j;
        end;
      end
     else
      begin
       if minsq < minfound then
        begin
         minfound          := minsq;
         quantize_array[i] := j;
        end;
      end;
    end;
  end;

 if TktPalette.ConvertKeepZero.Checked then quantize_array[0] := 0;
end;

{ PALETTES CONVERSIONS ****************************************************}

function ConvertPAL2PLTT(PALname, PLTTname : String) : Boolean;
var buffer : array[0..770] of Byte;
    tmp,
    tmp2   : array[0..100] of char;
    fin,
    fout   : Integer;
    i      : Integer;
begin
 Result := FALSE;
 if not FileExists(PALname) then
  begin
   ShowMessage('Non existent PAL in PAL2PLTT !');
   exit;
  end;
 if FileExists(PLTTname) then
  begin
   strcopy(tmp, 'Overwrite ');
   strcat(tmp, strPcopy(tmp2, PLTTname));
   if Application.MessageBox(tmp, 'WDFUSE Toolkit - PAL2PLTT', mb_YesNo or mb_IconQuestion) =  IDNo
    then exit;
  end;
 Result := TRUE;

 fin  := FileOpen(PALname, fmOpenRead);
 FileRead(fin, buffer[2], 768);
 FileClose(fin);

 buffer[0]   := 0;
 buffer[1]   := 255;
 buffer[770] := 0;

 for i := 2 to 769 do Buffer[i] := 4 * Buffer[i];

 fout := FileCreate(PLTTname);
 FileWrite(fout, buffer, 771);
 FileClose(fout);
end;


function ConvertPLTT2PAL(PLTTname, PALname : String) : Boolean;
var buffer : array[0..770] of Byte;
    tmp,
    tmp2   : array[0..100] of char;
    fin,
    fout   : Integer;
    i      : Integer;
begin
 Result := FALSE;
 if not FileExists(PLTTname) then
  begin
   ShowMessage('Non existent PLTT in PLTT2PAL !');
   exit;
  end;
 if FileExists(PALname) then
  begin
   strcopy(tmp, 'Overwrite ');
   strcat(tmp, strPcopy(tmp2, PALname));
   if Application.MessageBox(tmp, 'WDFUSE Toolkit - PLTT2PAL', mb_YesNo or mb_IconQuestion) =  IDNo
    then exit;
  end;
 Result := TRUE;

 {to handle incomplete pltts}
 for i := 0 to 770 do Buffer[i] := 0;

 fin  := FileOpen(PLTTname, fmOpenRead);
 FileRead(fin, buffer, 771);
 FileClose(fin);

 for i := 2 to 769 do Buffer[i] := Buffer[i] div 4;

 fout := FileCreate(PALname);
 FileWrite(fout, buffer[2], 768);
 FileClose(fout);
end;


{ 2BMP CONVERSIONS *********************************************************}

{ *** BM2BMP ***}

function ConvertBM2BMP(BMname, PALname, BMPname : String) : Boolean;
var tmp,
    tmp2         : array[0..100] of char;
    fin,
    fpal,
    fout         : Integer;
    i,j,k,m,n    : Integer;
    GHBM,
    GHBMP        : THandle;
    GPBM,
    GPBMP        : Pointer;
    OldCursor    : HCursor;
    go           : Boolean;
    BMH          : TBM_HEADER;
    BMP_FH       : TBITMAPFILEHEADER;
    BMP_IH       : TBITMAPINFOHEADER;
    PALbuffer    : array[0..767] of Byte;
    COLtable     : array[0..1023] of Byte;
    Bidon        : LongInt;
    bmp_counter  : LongInt;
    bmp_align    : Integer;

    col_start,
    col_end   : LongInt;
    rle       : Integer;
    colorbyte : Byte;
begin
 Result := FALSE;
 if not FileExists(BMname) then
  begin
   ShowMessage('Non existent BM in BM2BMP !');
   exit;
  end;
 if not FileExists(PALname) then
  begin
   ShowMessage('Non existent PAL in BM2BMP !');
   exit;
  end;

 {will open the input file briefly to get a maximum size to allocate}
 fin  := FileOpen(BMname, fmOpenRead);
 GHBM := GlobalAlloc( GMEM_MOVEABLE or GMEM_ZEROINIT , FileSizing(fin));
 FileClose(fin);
 if GHBM = 0 then
  begin
   Application.MessageBox('Cannot Allocate Buffer', 'WDFUSE Toolkit - BM2BMP', mb_Ok or mb_IconExclamation);
   exit;
  end;

 {This is enough room to create a 800x600x256 BMP}
 GHBMP := GlobalAlloc( GMEM_MOVEABLE or GMEM_ZEROINIT , 10485760);
 if GHBMP = 0 then
  begin
   Application.MessageBox('Cannot Allocate Buffer', 'WDFUSE Toolkit - BM2BMP', mb_Ok or mb_IconExclamation);
   GlobalFree(GHBM);
   exit;
  end;

 if FileExists(BMPname) then
  begin
   strcopy(tmp, 'Overwrite ');
   strcat(tmp, strPcopy(tmp2, BMPname));
   if Application.MessageBox(tmp, 'WDFUSE Toolkit - BM2BMP', mb_YesNo or mb_IconQuestion) =  IDNo
    then
     begin
      GlobalFree(GHBM);
      GlobalFree(GHBMP);
      exit;
     end;
  end;

 Result := TRUE;
 Bidon  := 1;
 OldCursor := SetCursor(LoadCursor(0, IDC_WAIT));

 {read the palette}
 fpal  := FileOpen(PALname, fmOpenRead);
 FileRead(fpal, PALbuffer, 768);
 FileClose(fpal);

 {make the RGBQUADs}
 for i := 0 to 255 do
  begin
   COLtable[4*i+3] := 0;
   COLtable[4*i+2] := 4 * PALbuffer[3*i];
   COLtable[4*i+1] := 4 * PALbuffer[3*i+1];
   COLtable[4*i  ] := 4 * PALbuffer[3*i+2];
  end;

 GPBM  := GlobalLock(GHBM);
 GPBMP := GlobalLock(GHBMP);

 fin  := FileOpen(BMname, fmOpenRead);
 FileRead(fin, BMH, 32);
 IF BMH.Compressed = 0 THEN
  if (BMH.SizeX <> 1) or ((BMH.SizeX = 1) and (BMH.SizeY = 1)) then
   begin
    bmp_align := 4 - BMH.SizeX mod 4;
    if bmp_align = 4 then bmp_align := 0;
    bmp_counter := Bidon * (BMH.SizeX + bmp_align) * BMH.SizeY;
    if BMH.DataSize = 0 then BMH.DataSize := Bidon * BMH.SizeX * BMH.SizeY;
    FileRead(fin, PBytes(GPBM)^, BMH.dataSize);
    for i := 0 to BMH.SizeY-1 do
     begin
      for j := 0 to BMH.SizeX-1 do
       begin
         PBytes(GPBMP)^[(BMH.SizeX + bmp_align) * i + j] :=
          PBytes(GPBM)^[BMH.SizeY * j + i];
       end;
     end;
    go := TRUE;
   end
  else
   begin
    {multiple}
    Application.MessageBox('BM is multiple, use BM Lab !',
                           'WDFUSE Toolkit - BM2BMP', mb_Ok or mb_IconExclamation);
    go := FALSE;
   end
 ELSE
  BEGIN
   {compressed}

   bmp_align := 4 - BMH.SizeX mod 4;
   if bmp_align = 4 then bmp_align := 0;
   bmp_counter := BMH.SizeX + bmp_align * BMH.SizeY;

   FileRead(fin, PBytes(GPBM)^, BMH.dataSize + Bidon * BMH.SizeX * 4);

   for i := 0 to BMH.SizeX-1 do
    begin
     col_start := PLongs(@(PBytes(GPBM)^[BMH.DataSize + i * 4]))^[0];
     if i < BMH.SizeX-1 then
      col_end  := PLongs(@(PBytes(GPBM)^[BMH.DataSize + (i+1) * 4]))^[0]
     else
      col_end   := BMH.DataSize;
     j         := 0;
     k         := 0;
     while (col_start+j < col_end) do
      begin
       if (PBytes(GPBM)^[col_start+j] >= 128) then
        begin
         rle := PBytes(GPBM)^[col_start+j] - 128;

         if BMH.Compressed = 1 then {RLE}
          begin
           {position on color byte}
           Inc(j);
           colorbyte := PBytes(GPBM)^[col_start+j];
           for m :=0 to rle-1 do
            begin
             PBytes(GPBMP)^[(BMH.SizeX + bmp_align) * k + i] :=
              colorbyte;
             Inc(k);
            end;
           Inc(j);
          end
         else {RLE0}
          begin
           for m :=0 to rle-1 do
            begin
             { not needed because GMEM_ZEROINIT and background color is 0
              will have to change if background color choice is offered }
             {
             PBytes(GPBMP)^[(BMH.SizeX + bmp_align) * k + i] := 0;
             }
             Inc(k);
            end;
           Inc(j);
          end;

        end
       else
        begin
         n := PBytes(GPBM)^[col_start+j];
         Inc(j);
         for m:=0 to n-1 do
          begin
           PBytes(GPBMP)^[(BMH.SizeX + bmp_align) * k + i] :=
             PBytes(GPBM)^[col_start+j];
           Inc(k);
           Inc(j);
          end;
        end;
     end;
    end;
   go := TRUE;
  END;
 FileClose(fin);

 if not go then
  begin
   GlobalFree(GHBM);
   GlobalFree(GHBMP);
   exit;
  end;

 BMP_FH.bfType           := 19778;
 BMP_FH.bfSize           := sizeof(BMP_FH) + sizeof(BMP_IH) + 1024 + bmp_counter;
 BMP_FH.bfReserved1      := 0;
 BMP_FH.bfReserved2      := 0;
 BMP_FH.bfOffBits        := sizeof(BMP_FH) + sizeof(BMP_IH) + 1024;

 BMP_IH.biSize           := 40;
 BMP_IH.biWidth          := BMH.SizeX;
 BMP_IH.biHeight         := BMH.SizeY;
 BMP_IH.biPlanes         := 1;
 BMP_IH.biBitCount       := 8;
 BMP_IH.biCompression    := BI_RGB;
 BMP_IH.biSizeImage      := bmp_counter;
 BMP_IH.biXPelsPerMeter  := 0;
 BMP_IH.biYPelsPerMeter  := 0;
 BMP_IH.biClrUsed        := 256;
 BMP_IH.biClrImportant   := 256;

 fout := FileCreate(BMPname);
 FileWrite(fout, BMP_FH,     14);
 FileWrite(fout, BMP_IH,     40);
 FileWrite(fout, COLtable, 1024);
 FileWrite(fout, PBytes(GPBMP)^, bmp_counter);
 FileClose(fout);

 GlobalUnlock(GHBM);
 GlobalFree(GHBM);
 GlobalUnlock(GHBMP);
 GlobalFree(GHBMP);
 SetCursor(OldCursor);
end;

{ *** FME2BMP ***}

function ConvertFME2BMP(FMEname, PALname, BMPname : String) : Boolean;
var tmp,
    tmp2         : array[0..100] of char;
    fin,
    fpal,
    fout         : Integer;
    i,j,k,m,n    : Integer;
    GHBM,
    GHBMP        : THandle;
    GPBM,
    GPBMP        : Pointer;
    OldCursor    : HCursor;
    go           : Boolean;
    FME1         : TFME_HEADER1;
    BMH          : TFME_HEADER2;
    col_start,
    col_end      : LongInt;
    rle          : Integer;
    BMP_FH       : TBITMAPFILEHEADER;
    BMP_IH       : TBITMAPINFOHEADER;
    PALbuffer    : array[0..767] of Byte;
    COLtable     : array[0..1023] of Byte;
    Bidon        : LongInt;
    bmp_counter  : LongInt;
    bmp_align    : Integer;
begin
 Result := FALSE;
 if not FileExists(FMEname) then
  begin
   ShowMessage('Non existent FME in FME2BMP !');
   exit;
  end;
 if not FileExists(PALname) then
  begin
   ShowMessage('Non existent PAL in FME2BMP !');
   exit;
  end;

 {will open the input file briefly to get a maximum size to allocate}
 fin  := FileOpen(FMEname, fmOpenRead);
 GHBM := GlobalAlloc( GMEM_MOVEABLE or GMEM_ZEROINIT , FileSizing(fin));
 FileClose(fin);
 if GHBM = 0 then
  begin
   Application.MessageBox('Cannot Allocate Buffer', 'WDFUSE Toolkit - FME2BMP', mb_Ok or mb_IconExclamation);
   exit;
  end;

 {This is enough room to create a 800x600x256 BMP}
 GHBMP := GlobalAlloc( GMEM_MOVEABLE or GMEM_ZEROINIT , 10485760);
 if GHBMP = 0 then
  begin
   Application.MessageBox('Cannot Allocate Buffer', 'WDFUSE Toolkit - FME2BMP', mb_Ok or mb_IconExclamation);
   GlobalFree(GHBM);
   exit;
  end;

 if FileExists(BMPname) then
  begin
   strcopy(tmp, 'Overwrite ');
   strcat(tmp, strPcopy(tmp2, BMPname));
   if Application.MessageBox(tmp, 'WDFUSE Toolkit - FME2BMP', mb_YesNo or mb_IconQuestion) =  IDNo
    then
     begin
      GlobalFree(GHBM);
      GlobalFree(GHBMP);
      exit;
     end;
  end;

 Result := TRUE;
 Bidon  := 1;
 OldCursor := SetCursor(LoadCursor(0, IDC_WAIT));

 {read the palette}
 fpal  := FileOpen(PALname, fmOpenRead);
 FileRead(fpal, PALbuffer, 768);
 FileClose(fpal);

 {make the RGBQUADs}
 for i := 0 to 255 do
  begin
   COLtable[4*i+3] := 0;
   COLtable[4*i+2] := 4 * PALbuffer[3*i];
   COLtable[4*i+1] := 4 * PALbuffer[3*i+1];
   COLtable[4*i  ] := 4 * PALbuffer[3*i+2];
  end;

 GPBM  := GlobalLock(GHBM);
 GPBMP := GlobalLock(GHBMP);

 fin  := FileOpen(FMEname, fmOpenRead);
 FileRead(fin, FME1, 32);
 FileSeek(fin, FME1.Header2, 0);
 FileRead(fin, BMH, 24);
 if BMH.Compressed = 0 then
  FileRead(fin, PBytes(GPBM)^, Bidon * (BMH.SizeX + bmp_align) * BMH.SizeY)
 else
  FileRead(fin, PBytes(GPBM)^, BMH.DataSize - 24);
 FileClose(fin);

 bmp_align := 4 - BMH.SizeX mod 4;
 if bmp_align = 4 then bmp_align := 0;
 bmp_counter := Bidon * (BMH.SizeX + bmp_align) * BMH.SizeY;

 if BMH.Compressed = 0 then
   begin
    for i := 0 to BMH.SizeX-1 do
     begin
      for j := 0 to BMH.SizeY-1 do
       begin
        if FME1.Flip = 0 then
         PBytes(GPBMP)^[(BMH.SizeX + bmp_align) * j + i] :=
           PBytes(GPBM)^[BMH.SizeY * i + j]
        else
         PBytes(GPBMP)^[(BMH.SizeX + bmp_align) * j + BMH.SizeX-i] :=
           PBytes(GPBM)^[BMH.SizeY * i + j];
       end;
     end;
   end
  else
   begin
    {Compressed}
    for i := 0 to BMH.SizeX-1 do
     begin
      col_start := PLongs(GPBM)^[i] - 24;
      if i < BMH.SizeX-1 then
       col_end   := PLongs(GPBM)^[(i+1)] - 24
      else
       col_end   := BMH.DataSize-24;
      j         := 0;
      k         := 0;
      while (col_start+j < col_end) do
       begin
        if (PBytes(GPBM)^[col_start+j] >= 128) then
         begin
          rle := PBytes(GPBMP)^[col_start+j] - 128;
          for m :=0 to rle-1 do
           begin
            { not needed because GMEM_ZEROINIT and background color is 0
              will have to change if background color choice is offered }
            {
            if FME1.Flip = 0 then
             PBytes(GPBMP)^[BMH.SizeX + bmp_align) * k + i] := 0
            else
             PBytes(GPBMP)^[BMH.SizeX + bmp_align) * k + BMH.SizeX-i] := 0;
            }
            Inc(k);
           end;
          Inc(j);
         end
        else
         begin
          n := PBytes(GPBM)^[col_start+j];
          Inc(j);
          for m:=0 to n-1 do
           begin
            if FME1.Flip = 0 then
             PBytes(GPBMP)^[(BMH.SizeX + bmp_align) * k + i] :=
               PBytes(GPBM)^[col_start+j]
            else
             PBytes(GPBMP)^[(BMH.SizeX + bmp_align) * k + BMH.SizeX-i] :=
               PBytes(GPBM)^[col_start+j];
            Inc(k);
            Inc(j);
           end;
         end;
      end;
     end;
   end;

 BMP_FH.bfType           := 19778;
 BMP_FH.bfSize           := sizeof(BMP_FH) + sizeof(BMP_IH) + 1024 + bmp_counter;
 BMP_FH.bfReserved1      := 0;
 BMP_FH.bfReserved2      := 0;
 BMP_FH.bfOffBits        := sizeof(BMP_FH) + sizeof(BMP_IH) + 1024;

 BMP_IH.biSize           := 40;
 BMP_IH.biWidth          := BMH.SizeX;
 BMP_IH.biHeight         := BMH.SizeY;
 BMP_IH.biPlanes         := 1;
 BMP_IH.biBitCount       := 8;
 BMP_IH.biCompression    := BI_RGB;
 BMP_IH.biSizeImage      := bmp_counter;
 BMP_IH.biXPelsPerMeter  := 0;
 BMP_IH.biYPelsPerMeter  := 0;
 BMP_IH.biClrUsed        := 256;
 BMP_IH.biClrImportant   := 256;

 fout := FileCreate(BMPname);
 FileWrite(fout, BMP_FH,     14);
 FileWrite(fout, BMP_IH,     40);
 FileWrite(fout, COLtable, 1024);
 FileWrite(fout, PBytes(GPBMP)^, bmp_counter);
 FileClose(fout);

 GlobalUnlock(GHBM);
 GlobalFree(GHBM);
 GlobalUnlock(GHBMP);
 GlobalFree(GHBMP);
 SetCursor(OldCursor);
end;

{ *** ANIMDELT2BMP ***}
{ if frame = -1 then DELT, else ANIM }
function ConvertANIMDELT2BMP(DELTname, PLTTname, BMPname : String; Frame : Integer) : Boolean;
var tmp,
    tmp2         : array[0..100] of char;
    fin,
    fpal,
    fout         : Integer;
    i, j         : Integer;
    AHeader      : TDELTH;
    ALine        : TDELTL;
    GHDELT,
    GHBMP        : THandle;
    GPDELT,
    GPBMP        : Pointer;
    OldCursor    : HCursor;
    go           : Boolean;
    BMP_FH       : TBITMAPFILEHEADER;
    BMP_IH       : TBITMAPINFOHEADER;
    PALbuffer    : array[0..767] of Byte;
    COLtable     : array[0..1023] of Byte;
    Bidon        : LongInt;
    bmp_counter  : LongInt;
    bmp_align    : Integer;
    PLTTlow,
    PLTThigh     : Byte;
    PLTTtotal    : Integer;
    skip         : Integer;
    rle          : Integer;
    n            : Byte;
    curpos       : LongInt;
    howmuch      : LongInt;
    DataSize     : LongInt;
    TotFrames    : Integ16;
begin
 Result := FALSE;
 if not FileExists(DELTname) then
  begin
   ShowMessage('Non existent ANIM/DELT in ANIM/DELT2BMP !');
   exit;
  end;
 if not FileExists(PLTTname) then
  begin
   ShowMessage('Non existent PLTT in ANIM/DELT2BMP !');
   exit;
  end;

 {This is enough room to create a 800x600x256 BMP}
 GHBMP := GlobalAlloc( GMEM_MOVEABLE or GMEM_ZEROINIT , 10485760);
 if GHBMP = 0 then
  begin
   Application.MessageBox('Cannot Allocate Buffer', 'WDFUSE Toolkit - ANIM/DELT2BMP', mb_Ok or mb_IconExclamation);
   exit;
  end;

 if FileExists(BMPname) then
  begin
   strcopy(tmp, 'Overwrite ');
   strcat(tmp, strPcopy(tmp2, BMPname));
   if Application.MessageBox(tmp, 'WDFUSE Toolkit - ANIM/DELT2BMP', mb_YesNo or mb_IconQuestion) =  IDNo
    then
     begin
      GlobalFree(GHBMP);
      exit;
     end;
  end;

 fin  := FileOpen(DELTname, fmOpenRead);
 IF Frame = -1 THEN
  BEGIN
   GHDELT := GlobalAlloc( GMEM_MOVEABLE or GMEM_ZEROINIT , FileSizing(fin));
   FileRead(fin, AHeader, SizeOf(TDELTH));
   DataSize := FileSizing(fin)-SizeOf(TDELTH);
  END
 ELSE
  BEGIN
   FileRead(fin, TotFrames, 2);
   if Frame >= TotFrames then
    begin
      Application.MessageBox('Invalid Frame Number', 'WDFUSE Toolkit - ANIM2BMP', mb_Ok or mb_IconExclamation);
      GlobalFree(GHBMP);
      FileClose(fin);
      exit;
    end;
   {now, just walk the embedded DELTs until the one we need}
   for i := 1 to Frame do
    begin
     FileRead(fin, DataSize, 4);
     FileSeek(fin, DataSize, 1);
    end;
   FileRead(fin, DataSize, 4);
   GHDELT := GlobalAlloc( GMEM_MOVEABLE or GMEM_ZEROINIT , DataSize);
   FileRead(fin, AHeader, SizeOf(TDELTH));
  END;

 if GHDELT = 0 then
  begin
   Application.MessageBox('Cannot Allocate Buffer', 'WDFUSE Toolkit - ANIM/DELT2BMP', mb_Ok or mb_IconExclamation);
   GlobalFree(GHBMP);
   FileClose(fin);
   exit;
  end;

 Result := TRUE;
 Bidon  := 1;
 OldCursor := SetCursor(LoadCursor(0, IDC_WAIT));

 GPDELT := GlobalLock(GHDELT);
 GPBMP  := GlobalLock(GHBMP);

 FileRead(fin, PBytes(GPDELT)^, DataSize);
 FileClose(fin);
 curpos := 0;

 {read the palette}
 for i := 0 to 767 do PALbuffer[i] := 0;
 fpal  := FileOpen(PLTTname, fmOpenRead);
 FileRead(fpal, PLTTlow, 1);
 FileRead(fpal, PLTThigh, 1);
 PLTTtotal := (PLTThigh - PLTTlow + 1) * 3;
 FileRead(fpal, PALbuffer[PLTTlow * 3], PLTTtotal);
 FileClose(fpal);

 {make the RGBQUADs}
 for i := 0 to 255 do
  begin
   COLtable[4*i+3] := 0;
   COLtable[4*i+2] := PALbuffer[3*i];
   COLtable[4*i+1] := PALbuffer[3*i+1];
   COLtable[4*i  ] := PALbuffer[3*i+2];
  end;

 Inc(AHeader.SizeX);
 Inc(AHeader.SizeY);

 bmp_align   := 4 - AHeader.SizeX mod 4;
 if bmp_align = 4 then bmp_align := 0;
 bmp_counter := Bidon * (AHeader.SizeX + bmp_align) * AHeader.SizeY;

 while TRUE do
  begin
   Aline.Size := PInts(@(PBytes(GPDELT)^[curpos]))^[0];
   Inc(curpos, 2);

   {check end !}
   if Aline.Size = 0 then break;

   {read X and Y pos}
   Aline.PosX := PInts(@(PBytes(GPDELT)^[curpos]))^[0];
   Inc(curpos, 2);
   Aline.PosY := PInts(@(PBytes(GPDELT)^[curpos]))^[0];
   Inc(curpos, 2);

   if (ALine.Size and 1) = 0 then
    begin
     {normal coding}
     for i := 0 to (ALine.Size shr 1) - 1 do
      begin
       PBytes(GPBMP)^[bmp_counter - (AHeader.SizeX + bmp_align) * ALine.PosY + ALine.PosX + i] :=
        PBytes(GPDELT)^[curpos];
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
       n := PBytes(GPDELT)^[curpos];
       Inc(curpos);

       if (n and 1) = 0 then
        begin
         {Copy}
         Inc(rle, n shr 1);
         for i := 0 to (n shr 1) - 1 do
          begin
           PBytes(GPBMP)^[bmp_counter - (AHeader.SizeX + bmp_align) * ALine.PosY + ALine.PosX + skip] :=
            PBytes(GPDELT)^[curpos];
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
           PBytes(GPBMP)^[bmp_counter - (AHeader.SizeX + bmp_align) * ALine.PosY + ALine.PosX + skip] :=
            PBytes(GPDELT)^[curpos];
           Inc(skip);
          end;
         Inc(curpos);
        end;
      end;
    end;
  end;


 BMP_FH.bfType           := 19778;
 BMP_FH.bfSize           := sizeof(BMP_FH) + sizeof(BMP_IH) + 1024 + bmp_counter;
 BMP_FH.bfReserved1      := 0;
 BMP_FH.bfReserved2      := 0;
 BMP_FH.bfOffBits        := sizeof(BMP_FH) + sizeof(BMP_IH) + 1024;

 BMP_IH.biSize           := 40;
 BMP_IH.biWidth          := AHeader.SizeX;
 BMP_IH.biHeight         := AHeader.SizeY;
 BMP_IH.biPlanes         := 1;
 BMP_IH.biBitCount       := 8;
 BMP_IH.biCompression    := BI_RGB;
 BMP_IH.biSizeImage      := bmp_counter;
 BMP_IH.biXPelsPerMeter  := 0;
 BMP_IH.biYPelsPerMeter  := 0;
 BMP_IH.biClrUsed        := 256;
 BMP_IH.biClrImportant   := 256;

 fout := FileCreate(BMPname);
 FileWrite(fout, BMP_FH,     14);
 FileWrite(fout, BMP_IH,     40);
 FileWrite(fout, COLtable, 1024);
 FileWrite(fout, PBytes(GPBMP)^, bmp_counter);
 FileClose(fout);

 GlobalUnlock(GHDELT);
 GlobalFree(GHDELT);
 GlobalUnlock(GHBMP);
 GlobalFree(GHBMP);
 SetCursor(OldCursor);
end;


{ BMP2 CONVERSIONS *********************************************************}

{ *** BMP2BM ***}

function ConvertBMP2BM(BMPname, BMname, PALname : String;
                       UsePalette, IsTransparent  : Boolean) : Boolean;
var tmp,
    tmp2         : array[0..100] of char;
    Title        : array[0..50] of Char;
    fin,
    fpal,
    fout         : Integer;
    i, j         : Integer;
    GHBM,
    GHBMP        : THandle;
    GPBM,
    GPBMP        : Pointer;
    OldCursor    : HCursor;
    BMH          : TBM_HEADER;
    BMP_FH       : TBITMAPFILEHEADER;
    BMP_IH       : TBITMAPINFOHEADER;
    Bidon        : LongInt;
    bmp_align    : Integer;
begin
 Result := FALSE;
 StrCopy(Title, 'WDFUSE Toolkit - BMP2BM');

 if not FileExists(BMPname) then
  begin
   ShowMessage('Non existent BMP in BMP2BM !');
   exit;
  end;

 if UsePalette and not FileExists(PALname) then
  begin
   ShowMessage('Non existent PAL in BMP2BM !');
   exit;
  end;

 {will open the input file briefly to get a maximum size to allocate}
 fin  := FileOpen(BMPname, fmOpenRead);
 GHBMP := GlobalAlloc( GMEM_MOVEABLE or GMEM_ZEROINIT , FileSizing(fin));
 {read the headers in the process, they are needed to check BMP validity}
 FileRead(fin, BMP_FH,     14);
 FileRead(fin, BMP_IH,     40);
 FileClose(fin);
 if GHBMP = 0 then
  begin
   Application.MessageBox('Cannot Allocate Buffer', Title, mb_Ok or mb_IconExclamation);
   exit;
  end;

 {This is enough room to create a 800x600x256 BM}
 GHBM := GlobalAlloc( GMEM_MOVEABLE or GMEM_ZEROINIT , 10485760);
 if GHBM = 0 then
  begin
   Application.MessageBox('Cannot Allocate Buffer', Title, mb_Ok or mb_IconExclamation);
   GlobalFree(GHBMP);
   exit;
  end;

 {check that the BMP format is correct
  i.e. 1) 256 colors, not compressed
          later handle 16 and 24 bits BMPs (RGB Triples ?)
            but in this case a palette MUST be chosen
       2) SizeY is a power of 2
          in this case, could give the option of extending it
       3) not compressed
 }
 if (BMP_IH.biPlanes <> 1) or (BMP_IH.biBitCount <> 8) then
  begin
   Application.MessageBox('Not a 256 colors BMP', Title, mb_Ok or mb_IconExclamation);
   GlobalFree(GHBM);
   GlobalFree(GHBMP);
   exit;
  end;

 if (BMP_IH.biHeight <>    1) and
    (BMP_IH.biHeight <>    2) and
    (BMP_IH.biHeight <>    4) and
    (BMP_IH.biHeight <>    8) and
    (BMP_IH.biHeight <>   16) and
    (BMP_IH.biHeight <>   32) and
    (BMP_IH.biHeight <>   64) and
    (BMP_IH.biHeight <>  128) and
    (BMP_IH.biHeight <>  256) and
    (BMP_IH.biHeight <>  512) and
    (BMP_IH.biHeight <> 1024) then
  begin
   Application.MessageBox('WARNING : Except for weapons BMP height should be a power of 2',
                          Title, mb_Ok or mb_IconInformation);
   { ** Allow this because of weapons **
   GlobalFree(GHBM);
   GlobalFree(GHBMP);
   exit;
   }
  end;

 if (BMP_IH.biCompression <> BI_RGB) then
  begin
   Application.MessageBox('BMP must not be compressed', Title, mb_Ok or mb_IconExclamation);
   GlobalFree(GHBM);
   GlobalFree(GHBMP);
   exit;
  end;

 if FileExists(BMname) then
  begin
   strcopy(tmp, 'Overwrite ');
   strcat(tmp, strPcopy(tmp2, BMname));
   if Application.MessageBox(tmp, Title, mb_YesNo or mb_IconQuestion) =  IDNo
    then
     begin
      GlobalFree(GHBM);
      GlobalFree(GHBMP);
      exit;
     end;
  end;

 Result := TRUE;
 Bidon  := 1;
 OldCursor := SetCursor(LoadCursor(0, IDC_WAIT));

 GPBM  := GlobalLock(GHBM);
 GPBMP := GlobalLock(GHBMP);

 fin  := FileOpen(BMPname, fmOpenRead);
 FileRead(fin, BMP_FH,     14);
 FileRead(fin, BMP_IH,     40);
 FileRead(fin, COLtable, 1024);

 { biSizeImage  The size, in bytes, of the image.
                It is valid to set this member to zero
                if the bitmap is in the BI_RGB format.
 }
 if BMP_IH.biSizeImage = 0 then
  begin
   bmp_align := 4 - BMP_IH.biWidth mod 4;
   if bmp_align = 4 then bmp_align := 0;
   BMP_IH.biSizeImage := (BMP_IH.biWidth + bmp_align) * BMP_IH.biHeight;
  end;

 FileRead(fin, PBytes(GPBMP)^, BMP_IH.biSizeImage);
 FileClose(fin);

 if UsePalette then
  begin
   {read the palette}
   fpal  := FileOpen(PALname, fmOpenRead);
   FileRead(fpal, PALbuffer, 768);
   FileClose(fpal);

   {convert the BGR Quads to RGB}
   for i := 0 to 255 do
    begin
     BMPpalette[3*i]   := COLtable[4*i+2] div 4;
     BMPpalette[3*i+1] := COLtable[4*i+1] div 4;
     BMPpalette[3*i+2] := COLtable[4*i  ] div 4;
    end;
   {quantize the palette}
   Quantize256(BMPpalette, PALbuffer, quantize);
  end
 else
  begin
   {fill the quantize table with identical value,
    so that the same code may be used afterwards}
   for i:= 0 to 255 do quantize[i] := i;
  end;

 {now, create the BM header}
 with BMH do
  begin
   BM_MAGIC[1] := 'B';
   BM_MAGIC[2] := 'M';
   BM_MAGIC[3] := ' ';
   BM_MAGIC[4] := #30;
   SizeX       := BMP_IH.biWidth;
   SizeY       := BMP_IH.biHeight;
   idemX       := BMP_IH.biWidth;
   idemY       := BMP_IH.biHeight;
   if IsTransparent then
    Transparent := 62
   else
    Transparent := 54;
   case SizeY of
       1 : logSizeY := 0;
       2 : logSizeY := 1;
       4 : logSizeY := 2;
       8 : logSizeY := 3;
      16 : logSizeY := 4;
      32 : logSizeY := 5;
      64 : logSizeY := 6;
     128 : logSizeY := 7;
     256 : logSizeY := 8;
     512 : logSizeY := 9;
    1024 : logSizeY := 10;
    2048 : logSizeY := 11;
    else   logSizeY := 0;
   end;
   Compressed  := 0;
   DataSize    := Bidon * SizeX * SizeY;
   filler      := #0 + #0 + #0 + #0 + #0 + #0 + #0 + #0 + #0 + #0 + #0 + #0;
  end;

 bmp_align := 4 - BMH.SizeX mod 4;
 if bmp_align = 4 then bmp_align := 0;

 for j := 0 to BMH.SizeY-1 do
  begin
   for i := 0 to BMH.SizeX-1 do
    begin
     PBytes(GPBM)^[BMH.SizeY * i + j] :=
       quantize[PBytes(GPBMP)^[(BMH.SizeX + bmp_align) * j + i]];
    end;
  end;

 fout := FileCreate(BMname);
 FileWrite(fout, BMH,  32);
 FileWrite(fout, PBytes(GPBM)^, Bidon * BMH.SizeX * BMH.SizeY);
 FileClose(fout);

 GlobalUnlock(GHBMP);
 GlobalFree(GHBMP);
 GlobalUnlock(GHBM);
 GlobalFree(GHBM);
 SetCursor(OldCursor);
end;


function ConvertBMP2UncompressedFME(BMPname, FMEname, PALname : String;
                                    InsX, InsY : LongInt; SelfCalc : Boolean;
                                    IsFlip, UsePalette : Boolean) : Boolean;
var tmp,
    tmp2         : array[0..100] of char;
    Title        : array[0..50] of Char;
    fin,
    fpal,
    fout         : Integer;
    i, j         : Integer;
    GHBM,
    GHBMP        : THandle;
    GPBM,
    GPBMP        : Pointer;
    OldCursor    : HCursor;
    FME          : TFME_HEADER1;
    BMH          : TFME_HEADER2;
    BMP_FH       : TBITMAPFILEHEADER;
    BMP_IH       : TBITMAPINFOHEADER;
    Bidon        : LongInt;
    bmp_align    : Integer;
begin
 Result := FALSE;
 StrCopy(Title, 'WDFUSE Toolkit - BMP2FME (Uncompressed)');

 if not FileExists(BMPname) then
  begin
   ShowMessage('Non existent BMP in BMP2FME (Uncompressed) !');
   exit;
  end;

 if UsePalette and not FileExists(PALname) then
  begin
   ShowMessage('Non existent PAL in BMP2FME (Uncompressed) !');
   exit;
  end;

 {will open the input file briefly to get a maximum size to allocate}
 fin  := FileOpen(BMPname, fmOpenRead);
 GHBMP := GlobalAlloc( GMEM_MOVEABLE or GMEM_ZEROINIT , FileSizing(fin));
 {read the headers in the process, they are needed to check BMP validity}
 FileRead(fin, BMP_FH,     14);
 FileRead(fin, BMP_IH,     40);
 FileClose(fin);
 if GHBMP = 0 then
  begin
   Application.MessageBox('Cannot Allocate Buffer', Title, mb_Ok or mb_IconExclamation);
   exit;
  end;

 {This is enough room to create a 800x600x256 FME}
 GHBM := GlobalAlloc( GMEM_MOVEABLE or GMEM_ZEROINIT , 10485760);
 if GHBM = 0 then
  begin
   Application.MessageBox('Cannot Allocate Buffer', Title, mb_Ok or mb_IconExclamation);
   GlobalFree(GHBMP);
   exit;
  end;

 {check that the BMP format is correct
  i.e. 1) 256 colors, not compressed
          later handle 16 and 24 bits BMPs (RGB Triples ?)
            but in this case a palette MUST be chosen
       2) not compressed
 }
 if (BMP_IH.biPlanes <> 1) or (BMP_IH.biBitCount <> 8) then
  begin
   Application.MessageBox('Not a 256 colors BMP', Title, mb_Ok or mb_IconExclamation);
   GlobalFree(GHBM);
   GlobalFree(GHBMP);
   exit;
  end;

 if (BMP_IH.biCompression <> BI_RGB) then
  begin
   Application.MessageBox('BMP must not be compressed', Title, mb_Ok or mb_IconExclamation);
   GlobalFree(GHBM);
   GlobalFree(GHBMP);
   exit;
  end;

 if FileExists(FMEname) then
  begin
   strcopy(tmp, 'Overwrite ');
   strcat(tmp, strPcopy(tmp2, FMEname));
   if Application.MessageBox(tmp, Title, mb_YesNo or mb_IconQuestion) =  IDNo
    then
     begin
      GlobalFree(GHBM);
      GlobalFree(GHBMP);
      exit;
     end;
  end;

 Result := TRUE;
 Bidon  := 1;
 OldCursor := SetCursor(LoadCursor(0, IDC_WAIT));

 GPBM  := GlobalLock(GHBM);
 GPBMP := GlobalLock(GHBMP);

 fin  := FileOpen(BMPname, fmOpenRead);
 FileRead(fin, BMP_FH,     14);
 FileRead(fin, BMP_IH,     40);
 FileRead(fin, COLtable, 1024);

 { biSizeImage  The size, in bytes, of the image.
                It is valid to set this member to zero
                if the bitmap is in the BI_RGB format.
 }
 if BMP_IH.biSizeImage = 0 then
  begin
   bmp_align := 4 - BMP_IH.biWidth mod 4;
   if bmp_align = 4 then bmp_align := 0;
   BMP_IH.biSizeImage := (BMP_IH.biWidth + bmp_align) * BMP_IH.biHeight;
  end;

 FileRead(fin, PBytes(GPBMP)^, BMP_IH.biSizeImage);
 FileClose(fin);

 if UsePalette then
  begin
   {read the palette}
   fpal  := FileOpen(PALname, fmOpenRead);
   FileRead(fpal, PALbuffer, 768);
   FileClose(fpal);

   {convert the BGR Quads to RGB}
   for i := 0 to 255 do
    begin
     BMPpalette[3*i]   := COLtable[4*i+2] div 4;
     BMPpalette[3*i+1] := COLtable[4*i+1] div 4;
     BMPpalette[3*i+2] := COLtable[4*i  ] div 4;
    end;
   {quantize the palette}
   Quantize256(BMPpalette, PALbuffer, quantize);
  end
 else
  begin
   {fill the quantize table with identical value,
    so that the same code may be used afterwards}
   for i:= 0 to 255 do quantize[i] := i;
  end;

 {now, create the FME headers}

 with FME do
  begin
   if not SelfCalc then
    begin
     InsertX     := InsX;
     InsertY     := InsY;
    end
   else
    begin
     InsertX     := -Bidon * BMP_IH.biWidth div 2;
     InsertY     := -Bidon * BMP_IH.biHeight;
    end;
   if IsFlip then
    Flip       := 1
   else
    Flip       := 0;
   Header2     := 32;
   UnitWidth   := 0;
   UnitHeight  := 0;
   pad3        := 0;
   pad4        := 0;
  end;

 with BMH do
  begin
   SizeX       := Bidon * BMP_IH.biWidth;
   SizeY       := Bidon * BMP_IH.biHeight;
   Compressed  := 0;
   DataSize    := 0; {because uncompressed!}
   ColOffs     := 0;
   pad1        := 0;
  end;

 bmp_align := 4 - BMH.SizeX mod 4;
 if bmp_align = 4 then bmp_align := 0;

 for j := 0 to BMH.SizeY-1 do
  begin
   for i := 0 to BMH.SizeX-1 do
    begin
     PBytes(GPBM)^[BMH.SizeY * i + j] :=
       quantize[PBytes(GPBMP)^[(BMH.SizeX + bmp_align) * j + i]];
    end;
  end;

 fout := FileCreate(FMEname);
 FileWrite(fout, FME,  32);
 FileWrite(fout, BMH,  24);
 FileWrite(fout, PBytes(GPBM)^, Bidon * BMH.SizeX * BMH.SizeY);
 FileClose(fout);

 GlobalUnlock(GHBMP);
 GlobalFree(GHBMP);
 GlobalUnlock(GHBM);
 GlobalFree(GHBM);
 SetCursor(OldCursor);
end;


function ConvertBMP2CompressedFME(BMPname, FMEname, PALname : String;
                                  InsX, InsY : LongInt; SelfCalc : Boolean;
                                  IsFlip, UsePalette : Boolean) : Boolean;
var tmp,
    tmp2         : array[0..100] of char;
    Title        : array[0..50] of Char;
    fin,
    fpal,
    fout         : Integer;
    i, j, k      : Integer;
    GHBM,
    GHBMP        : THandle;
    GPBM,
    GPBMP        : Pointer;
    OldCursor    : HCursor;
    go           : Boolean;
    FME          : TFME_HEADER1;
    BMH          : TFME_HEADER2;
    BMP_FH       : TBITMAPFILEHEADER;
    BMP_IH       : TBITMAPINFOHEADER;
    Bidon        : LongInt;
    bmp_counter  : LongInt;
    bmp_align    : Integer;
    DataPos      : LongInt;
    obuf         : array[0..300] of Byte;
    optr         : Integer;
    len          : Byte;
    collen       : Integer;
begin
 Result := FALSE;
 StrCopy(Title, 'WDFUSE Toolkit - BMP2FME (Compressed)');

 if not FileExists(BMPname) then
  begin
   ShowMessage('Non existent BMP in BMP2FME (Compressed) !');
   exit;
  end;

 if UsePalette and not FileExists(PALname) then
  begin
   ShowMessage('Non existent PAL in BMP2FME (Compressed) !');
   exit;
  end;

 {will open the input file briefly to get a maximum size to allocate}
 fin  := FileOpen(BMPname, fmOpenRead);
 GHBMP := GlobalAlloc( GMEM_MOVEABLE or GMEM_ZEROINIT , FileSizing(fin));
 {read the headers in the process, they are needed to check BMP validity}
 FileRead(fin, BMP_FH,     14);
 FileRead(fin, BMP_IH,     40);
 FileClose(fin);
 if GHBMP = 0 then
  begin
   Application.MessageBox('Cannot Allocate Buffer', Title, mb_Ok or mb_IconExclamation);
   exit;
  end;

 {This is enough room to create a 800x600x256 FME}
 GHBM := GlobalAlloc( GMEM_MOVEABLE or GMEM_ZEROINIT , 10485760);
 if GHBM = 0 then
  begin
   Application.MessageBox('Cannot Allocate Buffer', Title, mb_Ok or mb_IconExclamation);
   GlobalFree(GHBMP);
   exit;
  end;

 {check that the BMP format is correct
  i.e. 1) 256 colors, not compressed
          later handle 16 and 24 bits BMPs (RGB Triples ?)
            but in this case a palette MUST be chosen
       2) not compressed
 }
 if (BMP_IH.biPlanes <> 1) or (BMP_IH.biBitCount <> 8) then
  begin
   Application.MessageBox('Not a 256 colors BMP', Title, mb_Ok or mb_IconExclamation);
   GlobalFree(GHBM);
   GlobalFree(GHBMP);
   exit;
  end;

 if (BMP_IH.biCompression <> BI_RGB) then
  begin
   Application.MessageBox('BMP must not be compressed', Title, mb_Ok or mb_IconExclamation);
   GlobalFree(GHBM);
   GlobalFree(GHBMP);
   exit;
  end;

 if FileExists(FMEname) then
  begin
   strcopy(tmp, 'Overwrite ');
   strcat(tmp, strPcopy(tmp2, FMEname));
   if Application.MessageBox(tmp, Title, mb_YesNo or mb_IconQuestion) =  IDNo
    then
     begin
      GlobalFree(GHBM);
      GlobalFree(GHBMP);
      exit;
     end;
  end;

 Result := TRUE;
 Bidon  := 1;
 OldCursor := SetCursor(LoadCursor(0, IDC_WAIT));

 GPBM  := GlobalLock(GHBM);
 GPBMP := GlobalLock(GHBMP);

 fin  := FileOpen(BMPname, fmOpenRead);
 FileRead(fin, BMP_FH,     14);
 FileRead(fin, BMP_IH,     40);
 FileRead(fin, COLtable, 1024);

 { biSizeImage  The size, in bytes, of the image.
                It is valid to set this member to zero
                if the bitmap is in the BI_RGB format.
 }
 if BMP_IH.biSizeImage = 0 then
  begin
   bmp_align := 4 - BMP_IH.biWidth mod 4;
   if bmp_align = 4 then bmp_align := 0;
   BMP_IH.biSizeImage := (BMP_IH.biWidth + bmp_align) * BMP_IH.biHeight;
  end;

 FileRead(fin, PBytes(GPBMP)^, BMP_IH.biSizeImage);
 FileClose(fin);

 if UsePalette then
  begin
   {read the palette}
   fpal  := FileOpen(PALname, fmOpenRead);
   FileRead(fpal, PALbuffer, 768);
   FileClose(fpal);

   {convert the BGR Quads to RGB}
   for i := 0 to 255 do
    begin
     BMPpalette[3*i]   := COLtable[4*i+2] div 4;
     BMPpalette[3*i+1] := COLtable[4*i+1] div 4;
     BMPpalette[3*i+2] := COLtable[4*i  ] div 4;
    end;
   {quantize the palette}
   Quantize256(BMPpalette, PALbuffer, quantize);
  end
 else
  begin
   {fill the quantize table with identical value,
    so that the same code may be used afterwards}
   for i:= 0 to 255 do quantize[i] := i;
  end;

 {now, create the FME headers}

 with FME do
  begin
   if not SelfCalc then
    begin
     InsertX     := InsX;
     InsertY     := InsY;
    end
   else
    begin
     InsertX     := -Bidon * BMP_IH.biWidth div 2;
     InsertY     := -Bidon * BMP_IH.biHeight;
    end;
   if IsFlip then
    Flip       := 1
   else
    Flip       := 0;
   Header2     := 32;
   UnitWidth   := 0;
   UnitHeight  := 0;
   pad3        := 0;
   pad4        := 0;
  end;

 with BMH do
  begin
   SizeX       := Bidon * BMP_IH.biWidth;
   SizeY       := Bidon * BMP_IH.biHeight;
   Compressed  := 1;
   DataSize    := 0; {fill later on!}
   ColOffs     := 0;
   pad1        := 0;
  end;

 bmp_align := 4 - BMH.SizeX mod 4;
 if bmp_align = 4 then bmp_align := 0;

 DataPos   := Bidon * BMH.SizeX * 4;

 for i := 0 to BMH.SizeX-1 do
  begin
   j := 0;
   PLongs(GPBM)^[i * 4] := DataPos + 24;
   while j < BMH.SizeY do
    BEGIN
     len := 0;
     if PBytes(GPBMP)^[(BMH.SizeX + bmp_align) * j + i] = 0 then
      begin
       while (len < 127) and
             (j < BMH.SizeY) and
             (PBytes(GPBMP)^[(BMH.SizeX + bmp_align) * j + i] = 0) do
        begin
         Inc(len);
         Inc(j);
        end;
       PBytes(GPBM)^[DataPos] := len + 128;
       Inc(DataPos);
      end
     else
      begin
       while (len < 127) and
             (j < BMH.SizeY) and
             (PBytes(GPBMP)^[(BMH.SizeX + bmp_align) * j + i] <> 0) do
        begin
         Inc(len);
         obuf[len] := PBytes(GPBMP)^[(BMH.SizeX + bmp_align) * j + i];
         Inc(j);
        end;
       obuf[0] := len;
       for k := 0 to len do
        begin
         if k = 0 then
          PBytes(GPBM)^[DataPos] := obuf[k]
         else
          PBytes(GPBM)^[DataPos] := quantize[obuf[k]];
         Inc(DataPos);
        end;
      end;

    END;
  end;

 fout := FileCreate(FMEname);

 {Fill DataSize!}
 BMH.DataSize := DataPos + 24;

 FileWrite(fout, FME,  32);
 FileWrite(fout, BMH,  24);
 FileWrite(fout, PBytes(GPBM)^, BMH.DataSize);
 FileClose(fout);

 GlobalUnlock(GHBMP);
 GlobalFree(GHBMP);
 GlobalUnlock(GHBM);
 GlobalFree(GHBM);
 SetCursor(OldCursor);
end;


function ConvertBMP2DELT(BMPname, DELTname, PALname : String;
                         OffsetX, OffsetY : Integer;
                         UsePalette       : Boolean) : Boolean;
var tmp,
    tmp2         : array[0..100] of Char;
    Title        : array[0..50] of Char;
    fin,
    fpal,
    fout         : Integer;
    i, j         : Integer;
    GHBMP        : THandle;
    GPBMP        : Pointer;
    OldCursor    : HCursor;
    DH           : TDELTH;
    ALine        : TDELTL;
    BMP_FH       : TBITMAPFILEHEADER;
    BMP_IH       : TBITMAPINFOHEADER;
    Bidon        : LongInt;
    deltpos      : LongInt;
    curstart     : Integer;
    len          : Integer;
    v            : Byte;
    n            : Integer;
    obuf         : array[0..320] of Byte;
    optr         : Integer;
    iptr         : Integer;
    bmp_align    : Integer;
    pltt_l,
    pltt_h       : Byte;
begin
 Result := FALSE;
 StrCopy(Title, 'WDFUSE Toolkit - BMP2DELT');

 if not FileExists(BMPname) then
  begin
   ShowMessage('Non existent BMP in BMP2DELT !');
   exit;
  end;

 if UsePalette and not FileExists(PALname) then
  begin
   ShowMessage('Non existent PLTT in BMP2DELT !');
   exit;
  end;

 {will open the input file briefly to get a maximum size to allocate}
 fin  := FileOpen(BMPname, fmOpenRead);
 GHBMP := GlobalAlloc( GMEM_MOVEABLE or GMEM_ZEROINIT , FileSizing(fin));
 {read the headers in the process, they are needed to check BMP validity}
 FileRead(fin, BMP_FH,     14);
 FileRead(fin, BMP_IH,     40);
 FileClose(fin);
 if GHBMP = 0 then
  begin
   Application.MessageBox('Cannot Allocate Buffer', Title, mb_Ok or mb_IconExclamation);
   exit;
  end;

 {check that the BMP format is correct
  i.e. 1) 256 colors, not compressed
          later handle 16 and 24 bits BMPs (RGB Triples ?)
            but in this case a palette MUST be chosen
       2) not compressed
 }
 if (BMP_IH.biPlanes <> 1) or (BMP_IH.biBitCount <> 8) then
  begin
   Application.MessageBox('Not a 256 colors BMP', Title, mb_Ok or mb_IconExclamation);
   GlobalFree(GHBMP);
   exit;
  end;

 if (BMP_IH.biCompression <> BI_RGB) then
  begin
   Application.MessageBox('BMP must not be compressed', Title, mb_Ok or mb_IconExclamation);
   GlobalFree(GHBMP);
   exit;
  end;

 if FileExists(DELTname) then
  begin
   strcopy(tmp, 'Overwrite ');
   strcat(tmp, strPcopy(tmp2, DELTname));
   if Application.MessageBox(tmp, Title, mb_YesNo or mb_IconQuestion) =  IDNo
    then
     begin
      GlobalFree(GHBMP);
      exit;
     end;
  end;

 Result := TRUE;
 Bidon  := 1;

 OldCursor := SetCursor(LoadCursor(0, IDC_WAIT));
 GPBMP  := GlobalLock(GHBMP);

 fin  := FileOpen(BMPname, fmOpenRead);
 FileRead(fin, BMP_FH,     14);
 FileRead(fin, BMP_IH,     40);
 FileRead(fin, COLtable, 1024);

 { biSizeImage  The size, in bytes, of the image.
                It is valid to set this member to zero
                if the bitmap is in the BI_RGB format.
 }
 if BMP_IH.biSizeImage = 0 then
  begin
   bmp_align := 4 - BMP_IH.biWidth mod 4;
   if bmp_align = 4 then bmp_align := 0;
   BMP_IH.biSizeImage := (BMP_IH.biWidth + bmp_align) * BMP_IH.biHeight;
  end;

 FileRead(fin, PBytes(GPBMP)^, BMP_IH.biSizeImage);
 FileClose(fin);

 if UsePalette then
  begin
   {read the PAL or PLTT palette}
   for i := 0 to 767 do PALbuffer[i] := 0;
   fpal  := FileOpen(PALname, fmOpenRead);

   if LowerCase(ExtractFileExt(PALname)) = '.plt' then
    begin
     FileRead(fpal, pltt_l, 1);
     FileRead(fpal, pltt_h, 1);
     FileRead(fpal, PALbuffer[pltt_l*3], Bidon * (pltt_h-pltt_l+1)*3);
    end
   else
    FileRead(fpal, PALbuffer, 768);

   FileClose(fpal);

   {convert the BGR Quads to RGB}
   {!!!!! normalement, il ne faut pas diviser par 4  lorsqu'on traite
       une PLTT, mais ICI il y a un solide bug DELPHi !!!!!
       solution temporaire: si c'est une pltt, diviser aussi
       PALbuffer, comme cela le quantize sera +/- correct

       OK !!
           BMPpalette[3*i]   := 63;
           BMPpalette[3*i+1] := 63;
           BMPpalette[3*i+2] := 63;
       FOIREUX !!
           BMPpalette[3*i]   := 200;
           BMPpalette[3*i+1] := 200;
           BMPpalette[3*i+2] := 200;
  }
   for i := 0 to 255 do
    begin
     BMPpalette[3*i]   := COLtable[4*i+2] div 4;
     BMPpalette[3*i+1] := COLtable[4*i+1] div 4;
     BMPpalette[3*i+2] := COLtable[4*i  ] div 4;
    end;

   if LowerCase(ExtractFileExt(PALname)) = '.plt' then
    for i := 0 to 767 do
     begin
      PALbuffer[i] := PALbuffer[i] div 4;
     end;

   {quantize the palette}
   Quantize256(BMPpalette, PALbuffer, quantize);
  end
 else
  begin
   {fill the quantize table with identical value,
    so that the same code may be used afterwards}
   for i:= 0 to 255 do quantize[i] := i;
  end;

 {now, create the DELT header}
 DH.OffsX   := OffsetX;
 DH.OffsY   := OffsetY;
 DH.SizeX   := BMP_IH.biWidth - 1;  {-1 mandatory !}
 DH.SizeY   := BMP_IH.biHeight - 1; {-1 mandatory !}

 fout := FileCreate(DELTname);
 FileWrite(fout, DH,  SizeOf(TDELTH));

 {come back to the real sizes}
 Inc(DH.SizeX);
 Inc(DH.SizeY);

 bmp_align := 4 - DH.SizeX mod 4;
 if bmp_align = 4 then bmp_align := 0;


 for j := 0 to DH.SizeY-1 do
  begin
   curstart := 0;
   len      := 0;
   i        := 0;
   while i < DH.SizeX do
    begin
     {skip background}
     if PBytes(GPBMP)^[(DH.SizeX+bmp_align) * (DH.SizeY-j-1) + i] = 0 then
      Inc(i)
     else
      begin
       curstart := i;
       len      := 0;
       while (len < 127) and
             (i < DH.SizeX) and
             (PBytes(GPBMP)^[(DH.SizeX+bmp_align) * (DH.SizeY-j-1) + i] <> 0) do
        begin
         Inc(len);
         Inc(i);
        end;
        { now, we have len < 127 bytes, encode them as RLE and see if the
          resulting length is lower than len. Else, code as normal. }
        optr := 0;
        iptr := 0;
        if len <> 0 then
        while iptr < len do
         begin
          v := PBytes(GPBMP)^[(DH.SizeX+bmp_align) * (DH.SizeY-j-1) + curstart + iptr];
          n := 1;
          Inc(iptr);
          while (v = PBytes(GPBMP)^[(DH.SizeX+bmp_align) * (DH.SizeY-j-1) + curstart + iptr])
                and (iptr < len) do
           begin
            Inc(n);
            Inc(iptr);
           end;
          if n = 1 then
           begin
            {copy}
            obuf[optr] := 2;
            Inc(optr);
            obuf[optr] := quantize[v];
            Inc(optr);
           end
          else
           begin
            {rle}
            obuf[optr] := (n shl 1) + 1;
            Inc(optr);
            obuf[optr] := quantize[v];
            Inc(optr);
           end;
         end;
        if len <> 0 then
         if optr < len then
          begin
           {write RLE line header}
           ALine.Size := (len shl 1) + 1;
           ALine.PosY := j;
           ALine.PosX := curstart;
           FileWrite(fout, ALine, SizeOf(TDELTL));
           FileWrite(fout, obuf, optr);
          end
         else
          begin
           {write Normal line header}
           ALine.Size := (len shl 1);
           ALine.PosY := j;
           ALine.PosX := curstart;
           FileWrite(fout, ALine, SizeOf(TDELTL));
           for optr := 0 to len - 1 do
            obuf[optr] := PBytes(GPBMP)^[(DH.SizeX+bmp_align) * (DH.SizeY-j-1) + curstart + optr];
           FileWrite(fout, obuf, len);
          end;
      end;
    end;
  end;

 {add last 2 bytes at 0}
 len := 0;
 FileWrite(fout, len, 2);
 FileClose(fout);

 GlobalUnlock(GHBMP);
 GlobalFree(GHBMP);

 SetCursor(OldCursor);
end;


{ Split/Group functions }

function ANIMSplit(ANIMname, OutputDir : String) : Boolean;
var i         : Integer;
    fin, fout : Integer;
    DataSize  : LongInt;
    TotFrames : Integer;
    Buffer    : array[0..4095] of Byte;
    OldCursor : HCursor;
begin
 Result := TRUE;
 OldCursor := SetCursor(LoadCursor(0, IDC_WAIT));

 fin  := FileOpen(ANIMname, fmOpenRead);
 TotFrames:=0;
 FileRead(fin, TotFrames, 2);
 for i := 0 to TotFrames - 1 do
  begin
    FileRead(fin, DataSize, 4);
    fout := FileCreate(OutputDir + Format('%-3.3d', [i]) + '.dlt');
    while DataSize >= SizeOf(Buffer) do
     begin
      FileRead(fin, Buffer, SizeOf(Buffer));
      FileWrite(fout, Buffer, SizeOf(Buffer));
      DataSize := DataSize - SizeOf(Buffer);
     end;
     FileRead(fin, Buffer, DataSize);
     FileWrite(fout, Buffer, DataSize);
     FileClose(fout);
  end;

 FileClose(fin);
 SetCursor(OldCursor);
end;

function ANIMGroup(ANIMname, InputDir : String; TheFiles : TStrings) : Boolean;
var i         : Integer;
    fin, fout : Integer;
    DataSize  : LongInt;
    TotFrames : Integer;
    Buffer    : array[0..4095] of Byte;
    OldCursor : HCursor;
begin

 if TheFiles.Count <> 0 then
  begin
   OldCursor := SetCursor(LoadCursor(0, IDC_WAIT));
   fout := FileCreate(ANIMname);
   TotFrames := TheFiles.Count;
   FileWrite(fout, TotFrames, 2);
   for i := 0 to TheFiles.Count - 1 do
    begin
     fin := FileOpen(InputDir + TheFiles[i], fmOpenRead);
     DataSize := FileSizing(fin);
     FileWrite(fout, DataSize, 4);
     while DataSize >= SizeOf(Buffer) do
      begin
       FileRead(fin, Buffer, SizeOf(Buffer));
       FileWrite(fout, Buffer, SizeOf(Buffer));
       DataSize := DataSize - SizeOf(Buffer);
      end;
     FileRead(fin, Buffer, DataSize);
     FileWrite(fout, Buffer, DataSize);
     FileClose(fin);
    end;
   FileClose(fout);
   SetCursor(OldCursor);
   Result := TRUE;
  end
 else
  begin
   Application.MessageBox('No DELT found !',
                          'WDFUSE Toolkit - ANIMGroup',
                          mb_Ok or mb_IconExclamation);
   Result := FALSE;
  end;
end;


function BMSplit(BMname, OutputDir : String) : Boolean;
var i         : Integer;
    fin, fout : Integer;
    Bidon     : LongInt;
    DataSize  : LongInt;
    BMH       : TBM_HEADER;
    BMSUBH    : TBM_SUBHEADER;
    Buffer    : array[0..4095] of Byte;
    OldCursor : HCursor;
    FRate     : Byte;
    Transp    : Byte;
    Dummy     : Byte;
    BMini     : TIniFile;
begin
 Result := TRUE;
 OldCursor := SetCursor(LoadCursor(0, IDC_WAIT));
 Bidon := 1;

 fin  := FileOpen(BMname, fmOpenRead);
 FileRead(fin, BMH, SizeOf(TBM_HEADER));

 if (BMH.SizeX <> 1) or ((BMH.SizeX = 1) and (BMH.SizeY = 1)) then
  begin
   Application.MessageBox('BM is NOT multiple !',
                          'WDFUSE Toolkit - BMSplit',
                          mb_Ok or mb_IconExclamation);
   Result := FALSE;
   FIleClose(fin);
   exit;
  end;

 FileRead(fin, FRate, 1);
 FileRead(fin, Dummy, 1);
 Transp := BMH.Transparent;

 {Save the frame Rate}
 BMIni := TIniFile.Create(OutputDir + 'multi_bm.ini');
 BMIni.WriteInteger('MULTI_BM', 'Frame Rate', FRate);
 BMIni.Free;

 {skip the table}
 for i := 0 to BMH.idemY - 1 do
  FileRead(fin, Dummy, 4);

 for i := 0 to BMH.idemY - 1 do
  begin
    FileRead(fin, BMSUBH, SizeOf(TBM_SUBHEADER));
    BMH.SizeX       := BMSUBH.SizeX;
    BMH.SizeY       := BMSUBH.SizeY;
    BMH.idemX       := BMSUBH.idemX;
    BMH.idemY       := BMSUBH.idemY;
    BMH.Transparent := BMSUBH.Transparent;
    BMH.LogSizeY    := BMSUBH.LogSizeY;
    BMH.Compressed  := 0;
    BMH.DataSize    := BMSUBH.DataSize;
    BMH.filler      := #0 + #0 + #0 + #0 + #0 + #0 + #0 + #0 + #0 + #0 + #0 + #0;
    fout := FileCreate(OutputDir + Format('%-3.3d', [i]) + '.bm');
    FileWrite(fout, BMH, SizeOf(TBM_HEADER));
    DataSize := Bidon * BMH.SizeX * BMH.SizeY;
    while DataSize >= SizeOf(Buffer) do
     begin
      FileRead(fin, Buffer, SizeOf(Buffer));
      FileWrite(fout, Buffer, SizeOf(Buffer));
      DataSize := DataSize - SizeOf(Buffer);
     end;
     FileRead(fin, Buffer, DataSize);
     FileWrite(fout, Buffer, DataSize);
     FileClose(fout);
  end;

 FileClose(fin);
 SetCursor(OldCursor);
end;

function BMGroup(BMname, InputDir : String; TheFiles : TStrings) : Boolean;
var i,j       : Integer;
    fin, fout : Integer;
    Bidon     : LongInt;
    DataSize  : LongInt;
    BMH0      : TBM_HEADER;
    BMH       : TBM_HEADER;
    BMSUBH    : TBM_SUBHEADER;
    Buffer    : array[0..4095] of Byte;
    OldCursor : HCursor;
    FRate     : Byte;
    Dummy     : Byte;
    LDummy    : LongInt;
    BMini     : TIniFile;
    BMTable   : LongInt;
    FirstTran : Byte;
    FirstLogS : Byte;
begin
 Bidon := 1;

 if TheFiles.Count <> 0 then
  begin
   OldCursor := SetCursor(LoadCursor(0, IDC_WAIT));
   fout := FileCreate(BMname);
   { prepare and write the header, the frame rate and the BM table }
   BMH0.BM_MAGIC[1] := 'B';
   BMH0.BM_MAGIC[2] := 'M';
   BMH0.BM_MAGIC[3] := ' ';
   BMH0.BM_MAGIC[4] := #30;
   BMH0.SizeX       := 1;
   BMH0.SizeY       := 0; {filled later}
   BMH0.idemX       := -2;
   BMH0.idemY       := TheFiles.Count;
   BMH0.Transparent := 0; {filled later}
   BMH0.logSizeY    := 0; {filled later}
   BMH0.Compressed  := 0;
   BMH0.DataSize    := 0;
   BMH0.filler      := #0 + #0 + #0 + #0 + #0 + #0 + #0 + #0 + #0 + #0 + #0 + #0;
   FileWrite(fout, BMH0, SizeOf(TBM_HEADER));
   BMIni := TIniFile.Create(InputDir + 'multi_bm.ini');
   FRate := BMIni.ReadInteger('MULTI_BM', 'Frame Rate', 0);
   BMIni.Free;
   Dummy := 2;
   FileWrite(fout, FRate, 1);
   FileWrite(fout, Dummy, 1);
   LDummy := 0;
   for j := 0 to TheFiles.Count - 1 do
    FileWrite(fout, LDummy, 4);
   BMTable := Bidon * TheFiles.Count * 4;

   for i := 0 to TheFiles.Count - 1 do
    begin
     fin := FileOpen(InputDir + TheFiles[i], fmOpenRead);

     { update the bm table }
     FileSeek(fout, SizeOf(TBM_HEADER) + 2 + Bidon * i * 4, 0); {SEEK_START}
     FileWrite(fout, BMTable, 4);
     FileSeek(fout, 0, 2); {SEEK_END}
     FileSeek(fin, 0, 0); {SEEK_START}
     { Read, convert and write the header/subheader }
     FileRead(fin, BMH, SizeOf(TBM_HEADER));
     BMSUBH.SizeX       := BMH.SizeX;
     BMSUBH.SizeY       := BMH.SizeY;
     BMSUBH.idemX       := BMH.idemX;
     BMSUBH.idemY       := BMH.idemY;
     BMSUBH.LogSizeY    := BMH.LogSizeY;
     BMSUBH.DataSize    := BMH.DataSize;
     BMSUBH.filler1     := #0 + #0 + #0 + #0 + #0 + #0 + #0 + #0 + #0 + #0 + #0;
     BMSUBH.Transparent := BMH.Transparent;
     BMSUBH.filler2     := #0 + #0 + #0;
     FileWrite(fout, BMSUBH, SizeOf(TBM_SUBHEADER));

     if i = 1 then
      begin
       FirstTran := BMH.Transparent;
       FirstLogS := BMH.LogSizeY;
      end;

     DataSize := BMSUBH.DataSize;
     BMTable  := BMTable + SizeOf(TBM_SUBHEADER) + BMSUBH.DataSize;
     {copy the data}
     while DataSize >= SizeOf(Buffer) do
      begin
       FileRead(fin, Buffer, SizeOf(Buffer));
       FileWrite(fout, Buffer, SizeOf(Buffer));
       DataSize := DataSize - SizeOf(Buffer);
      end;
     FileRead(fin, Buffer, DataSize);
     FileWrite(fout, Buffer, DataSize);
     FileClose(fin);
    end;

   { now, update the main header }
   { Size Y = size of file - 32 }
   BMH0.SizeY := BMTable + 2;
   { logSizeY}
   BMH0.LogSizeY := FirstLogS;
   { transparent}
   BMH0.Transparent := FirstTran;

   FileSeek(fout, 0, 0); {SEEK_START}
   FileWrite(fout, BMH0, SizeOf(TBM_HEADER));

   FileClose(fout);
   SetCursor(OldCursor);
   Result := TRUE;
  end
 else
  begin
   Application.MessageBox('No BM found !',
                          'WDFUSE Toolkit - BMGroup',
                          mb_Ok or mb_IconExclamation);
   Result := FALSE;
  end;

end;

function FILMDecompile(FILMName : String; Output : TMemo) : Boolean;
var
    tmp    : array[0..100] of char;
    fin    : Integer;
    magic  : Integ16;
    durat  : Integ16;
    numobj : Integ16;
    rest   : String;
    resn   : String;
    totlen : LongInt;
    blktyp : Integ16;
    numcmd : Integ16;
    len    : Integ16;

    obj    : Integ16;
    cmd    : Integ16;

    cmdlen : Integ16;
    thecmd : Integ16;
    numpar : Integ16;
    par    : Integ16;
    thepar : Integ16;
    aline  : String;
    OldCursor    : HCursor;
begin
 Result := FALSE;
 if not FileExists(FILMname) then
  begin
   ShowMessage('Non existent FILM in FILMDecompile !');
   exit;
  end;

 OldCursor := SetCursor(LoadCursor(0, IDC_WAIT));
 Result := TRUE;

 Output.Clear;
 Output.Lines.BeginUpdate;
 Output.Lines.Add('# ' + FILMName);
 Output.Lines.Add('# Decompiled by WDFUSE ' + WDFUSE_VERSION + ' Toolkit');

 fin  := FileOpen(FILMname, fmOpenRead);
 FileRead(fin, magic,  2);
 FileRead(fin, durat,  2);
 FileRead(fin, numobj, 2);

 Output.Lines.Add(Format('# Object Count %d', [numobj]));
 Output.Lines.Add(' ');
 Output.Lines.Add(Format('DURATION %d', [durat]));

 for obj := 0 to numobj - 1 do
  begin
   {Resource Type}
   FileRead(fin, tmp, 4);
   tmp[4] := #0;
   rest := StrPas(tmp);
   {Resource Name}
   FileRead(fin, tmp, 8);
   tmp[8] := #0;
   resn := StrPas(tmp);
   Output.Lines.Add(' ');
   Output.Lines.Add(rest + ' ' + resn);

   FileRead(fin, totlen, 4);
   FileRead(fin, blktyp, 2);
   FileRead(fin, numcmd, 2);
   FileRead(fin, len, 2);

   for cmd := 0 to numcmd - 1 do
    begin
     FileRead(fin, cmdlen, 2);
     numpar := (cmdlen - 4) div 2;
     FileRead(fin, thecmd, 2);
     CASE thecmd of
        2: aline := 'END     ';
        3: aline := 'TIME    ';
        4: aline := 'MOVE    ';
        5: aline := 'SPEED   ';
        6: aline := 'LAYER   ';
        7: aline := 'FRAME   ';
        8: aline := 'ANIMATE ';
        9: aline := 'CUE     ';
       10: aline := 'VAR     ';
       11: aline := 'WINDOW  ';
       13: aline := 'SWITCH  ';
       14: aline := 'UNK14   ';
       15: aline := 'PALETTE ';
       18: aline := 'CUT     ';
       20: aline := 'LOOP    ';
       24: aline := 'PRELOAD ';
       25: aline := 'SOUND   ';
       28: aline := 'STEREO  ';
      ELSE aline := Format('??       %4d',[thecmd]);
     END;
     for par := 0 to numpar - 1 do
      begin
       FileRead(fin, thepar, 2);
       aline := aline + ' ' + Format('%4d',[thepar]);
      end;
     Output.Lines.Add('     ' + aline);
    end;
  end;

 FileRead(fin, tmp, 4);
 tmp[4] := #0;
 rest := StrPas(tmp);
 FileRead(fin, tmp, 8);
 tmp[8] := #0;
 resn := StrPas(tmp);

 if rest = 'END' then
  begin
   Output.Lines.Add(' ');
   Output.Lines.Add(rest + '0 ' + resn);
  end
 else
  begin
   Output.Lines.Add(' ');
   Output.Lines.Add('# !!!!! Invalid End of FILM, no END0 found !!!!!');
  end;
 FileClose(fin);
 Output.Lines.EndUpdate;
 SetCursor(OldCursor);
end;

function FILMCompile(FILMName : String; Input : TMemo) : Boolean;
var buffer : array[0..2000] of Integ16;
    tmp,
    tmp2   : array[0..100] of char;
    fout   : Integer;
    i, j   : Integer;

    magic  : Integ16;
    durat  : Integer;
    numobj : Integer;

    rest   : String;
    resn   : String;
    totlen : LongInt;
    blktyp : Integer;
    numcmd : Integer;
    len    : Integer;
    thecmd : Integer;
    par    : Integer;
    thepar : Integer;
    pars   : TStringParser;

    bufcnt : Integer;
    special: Boolean;
    spetyp : Integer;
    code   : Integer;
    OldCursor    : HCursor;
begin
Result := FALSE;

if FileExists(FILMname) then
 begin
  strcopy(tmp, 'Overwrite ');
  strcat(tmp, strPcopy(tmp2, FILMName));
  if Application.MessageBox(tmp, 'WDFUSE Toolkit - FILMCompile', mb_YesNo or mb_IconQuestion) =  IDNo
   then exit;
 end;

OldCursor := SetCursor(LoadCursor(0, IDC_WAIT));
Result := TRUE;

magic  := 4;
durat  := 0;
numobj := 0;

fout := FileCreate(FILMname);
FileWrite(fout, magic,  2);
FileWrite(fout, durat,  2); {updated later}
FileWrite(fout, numobj, 2); {updated later}

bufcnt := 0;
numcmd := 0;
len    := 0;

for i := 0 to Input.Lines.Count - 1 do
  BEGIN
   special := FALSE;

   if Input.Lines[i] <> '' then
    if Trim(Input.Lines[i]) <> '' then
     if Trim(Input.Lines[i])[1] <> '#' then
      BEGIN
       pars := TStringParser.Create(Trim(Input.Lines[i]));
       if pars[1] = 'END' then
        begin
         thecmd := 2;
        end
       else if pars[1] = 'TIME' then
        begin
         thecmd := 3;
        end
       else if pars[1] = 'MOVE' then
        begin
         thecmd := 4;
        end
       else if pars[1] = 'SPEED' then
        begin
         thecmd := 5;
        end
       else if pars[1] = 'LAYER' then
        begin
         thecmd := 6;
        end
       else if pars[1] = 'FRAME' then
        begin
         thecmd := 7;
        end
       else if pars[1] = 'ANIMATE' then
        begin
         thecmd := 8;
        end
       else if pars[1] = 'CUE' then
        begin
         thecmd := 9;
        end
       else if pars[1] = 'VAR' then
        begin
         thecmd := 10;
        end
       else if pars[1] = 'WINDOW' then
        begin
         thecmd := 11;
        end
       else if pars[1] = 'SWITCH' then
        begin
         thecmd := 13;
        end
       else if pars[1] = 'UNK14' then
        begin
         thecmd := 14;
        end
       else if pars[1] = 'PALETTE' then
        begin
         thecmd := 15;
        end
       else if pars[1] = 'CUT' then
        begin
         thecmd := 18;
        end
       else if pars[1] = 'LOOP' then
        begin
         thecmd := 20;
        end
       else if pars[1] = 'PRELOAD' then
        begin
         thecmd := 24;
        end
       else if pars[1] = 'SOUND' then
        begin
         thecmd := 25;
        end
       else if pars[1] = 'STEREO' then
        begin
         thecmd := 28;
        end
       else if pars[1] = 'ANIM' then
        begin
         Special := TRUE;
         SpeTyp  := 3;
        end
       else if pars[1] = 'DELT' then
        begin
         Special := TRUE;
         SpeTyp  := 3;
        end
       else if pars[1] = 'CUST' then
        begin
         Special := TRUE;
         SpeTyp  := 3;
        end
       else if pars[1] = 'PLTT' then
        begin
         Special := TRUE;
         SpeTyp  := 4;
        end
       else if pars[1] = 'VOIC' then
        begin
         Special := TRUE;
         SpeTyp  := 5;
        end
       else if pars[1] = 'VIEW' then
        begin
         Special := TRUE;
         SpeTyp  := 2;
        end
       else if pars[1] = 'END0' then
        begin
         Special := TRUE;
         SpeTyp  := 1;
        end
       else if pars[1] = 'DURATION' then
        begin
         Special := TRUE;
         SpeTyp  := 0;
        end
       else if Copy(pars[1],1,2) = '??' then
        begin
        { other function, read its function number as the first parameter
          and bring the parameters down by 1 to make it 'normal' again}
         if pars.Count > 2 then
          begin
           Val(pars[2], thecmd, code);
           if code <> 0 then
            begin
             thecmd := 2;
             ShowMessage('Invalid New function (??). Replaced by END');
            end;
          end;
         for par := 1 to pars.Count - 2 do
          begin
           pars[par] := pars[par+1];
          end;
         pars.Delete(pars.Count-1);
        end
       else
        begin
        {error !!!}
         Special := TRUE;
         SpeTyp  := -1;
        end;

       if Special then
        begin
         CASE SpeTyp of
         -1: begin {ERROR DETECTED}
              SetCursor(OldCursor);
              ShowMessage(Format('An error occured at line %d', [i+1]));
              pars.free;
              FileClose(fout);
              exit;
             end;
          0: begin {DURATION}
              if pars.Count > 2 then
               begin
                Val(pars[2], durat, code);
                if code <> 0 then durat := 0;
               end;
             end;
          1: begin {END0}
              {write previous one}
              StrPCopy(tmp, rest);
              FileWrite(fout, tmp, 4);
              for j := 0 to 8 do tmp[j] := #0;
              StrPCopy(tmp, resn);
              FileWrite(fout, tmp, 8);
              len    := 2 * bufcnt;
              totlen := len + 22;
              FileWrite(fout, totlen, 4);
              FileWrite(fout, blktyp, 2);
              FileWrite(fout, numcmd, 2);
              FileWrite(fout, len, 2);
              FileWrite(fout, buffer, 2 * bufcnt);
              Inc(numobj);
              {write the end}
              StrPCopy(tmp, 'END');
              FileWrite(fout, tmp, 4);
              for j := 0 to 8 do tmp[j] := #0;
              if pars.Count > 2
               then resn := pars[2]
               else resn := 'UNTITLED';
              StrPCopy(tmp, resn);
              FileWrite(fout, tmp, 8);
              totlen := 18;
              FileWrite(fout, totlen, 4);
              blktyp := 1;
              FileWrite(fout, blktyp, 2);
              pars.free;
              break;
             end;
          2: begin {VIEW}
              rest := 'VIEW';
              if pars.Count > 2
               then resn := pars[2]
               else resn := 'untitled';
              blktyp := 2;
             end;
          ELSE
             begin {ANIM, DELT, CUST, PLTT, VOIC}
              {first write previous one}
              StrPCopy(tmp, rest);
              FileWrite(fout, tmp, 4);
              for j := 0 to 8 do tmp[j] := #0;
              StrPCopy(tmp, resn);
              FileWrite(fout, tmp, 8);
              len    := 2 * bufcnt;
              totlen := len + 22;
              FileWrite(fout, totlen, 4);
              FileWrite(fout, blktyp, 2);
              FileWrite(fout, numcmd, 2);
              FileWrite(fout, len, 2);
              FileWrite(fout, buffer, 2 * bufcnt);
              Inc(numobj);

              {prepare next}
              rest   := pars[1];
              if pars.Count > 2 then
               resn   := pars[2]
              else
               resn   := '';
              blktyp := SpeTyp;
              bufcnt := 0;
              numcmd := 0;
             end;
         END;
        end
       else
        begin
         buffer[bufcnt] := pars.Count * 2; {ie (cmdlen + cmd + params) * 2 bytes}
         Inc(bufcnt);
         buffer[bufcnt] := thecmd;
         Inc(bufcnt);
         for par := 2 to pars.Count - 1 do
          begin
           Val(pars[par], thepar, code);
           if code <> 0 then thepar := 0;
           buffer[bufcnt] := thepar;
           Inc(bufcnt);
          end;
         if bufcnt > 1990 then
          begin
           SetCursor(OldCursor);
           ShowMessage('Function buffer near capacity (4K) ! Aborting compile !');
           pars.free;
           FileClose(fout);
           exit;
          end;
         Inc(numcmd);
        end;
       pars.free;
      END;
  END;

 FileClose(fout);

 { set duration and objnum correctly }
 fout := FileOpen(FILMname, fmOpenWrite);
 FileWrite(fout, magic,  2);
 FileWrite(fout, durat,  2);
 FileWrite(fout, numobj, 2);
 FileClose(fout);

 SetCursor(OldCursor);
 Application.MessageBox('Compile Successful', 'WDFUSE Toolkit - FILMCompile', mb_IconInformation)
end;

end.
