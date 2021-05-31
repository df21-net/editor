unit Preview;

interface

uses
  MMSystem,Classes, ExtCtrls, StdCtrls, Files, FileOperations, graph_files,
  Windows,Graphics, SysUtils, Misc_utils, NWX;

type
  TPreviewThread = class(TThread)
  private
    { Private declarations }
    Im:TImage;
    MM:TMemo;
    LB:TLabel;
    Interrupted:boolean;
    NewFile:Boolean;
    Fname:String;
    F:TFile;
    Pcx:TPCX;
    nwx:TNWX;
    bm:TBitmap;
    ptext:PChar;
    pWav:Pointer;
    Msg:String;
    Procedure TerminateProc(Sender:TObject);
    Procedure ShowBM;
    Procedure ShowText;
    Procedure ShowNothing;
    Procedure ExceptionMsg;
  protected
    procedure Execute; override;
  Public
    Constructor Create(aIM:TImage;aMM:TMemo;aLB:TLabel);
    Procedure StartPreview(const Name:String);
    Procedure StopPreview;
  end;

implementation

{ Important: Methods and properties of objects in VCL can only be used in a
  method called using Synchronize, for example,

      Synchronize(UpdateCaption);

  and UpdateCaption could look like,

    procedure TPreviewThread.UpdateCaption;
    begin
      Form1.Caption := 'Updated in a thread';
    end; }

{ TPreviewThread }

Procedure TPreviewThread.ShowBM;
begin
 LB.Visible:=true;
 Im.Visible:=true;
 mm.Visible:=false;
 LB.Caption:=Format('Width %d height %d',[BM.Width,BM.Height]);
 Im.Picture.Bitmap:=bm;
 Bm.Free;
end;

Procedure TPreviewThread.ExceptionMsg;
begin
 PanMessage(mt_Error,Msg);
end;

Procedure TPreviewThread.ShowText;
begin
 Im.Visible:=false;
 LB.Visible:=false;
 MM.Visible:=true;
 Mm.SetTextBuf(Ptext);
 StrDispose(Ptext);
 Ptext:=nil;
end;

Procedure TPreviewThread.ShowNothing;
begin
 Im.Visible:=false;
 MM.Visible:=false;
 LB.Visible:=false;
end;

Constructor TPreviewThread.Create(aIM:TImage;aMM:TMemo;aLB:TLabel);
begin
 IM:=aIM;
 MM:=aMM;
 LB:=aLB;
 Inherited Create(false);
 FreeOnTerminate:=true;
 OnTerminate:=TerminateProc;
end;

Procedure TPreviewThread.StartPreview(const Name:String);
begin
 Fname:=Name;
 NewFile:=true;
 Resume;
end;

Procedure TPreviewThread.StopPreview;
begin
end;

Function GetANIMFromITM(const ITM:String):String;
var t:TLecTextFile;s,w:String;p:integer;
begin
 Result:='';
 t:=TLecTextFile.CreateRead(OpenGameFile(ITM));
 While not t.eof do
 begin
  T.Readln(s);
  p:=GetWord(s,1,w);
  if w<>'ANIM' then Continue;
  GetWord(s,p,Result);
  break;
 end;
 t.FClose;
end;


procedure TPreviewThread.Execute;
var ext,s:string;
    size:integer;
label loopend;
begin
  { Place thread code here }
  ShowNothing;
  Suspend;
Repeat
 if not newfile then goto loopend;
 NewFile:=false;
 ext:=UpperCase(ExtractExt(Fname));
Try
 if ext='.ITM' then
 begin
  s:=GetANIMFromITM(Fname);
  if UpperCase(extractFileExt(s))='.NWX' then
  begin
   FName:=s;
   ext:=UpperCase(extractFileExt(s));
  end;
 end;

 if (ext='.NWX') then
 begin
  f:=OpenGameFile(Fname);
  if f=nil then begin SynChronize(ShowNothing); Raise Exception.Create(Fname+' not found'); end;

  nwx:=TNWX.Create(f);
  bm:=NWX.LoadBitmap(-1,-1);
  NWX.Free;

  Synchronize(ShowBM);
 end
 else if (ext='.PCX') then
 begin
  f:=OpenGameFile(Fname);
  if f=nil then begin SynChronize(ShowNothing); Raise Exception.Create(Fname+' not found'); end;

  Pcx:=TPCX.Create(f);
  bm:=Pcx.LoadBitmap(-1,-1);
  Pcx.Free;
  Synchronize(ShowBM);
 end
 else if (ext='.ATX') or (ext='.ITM') or (ext='.TXT') then
 begin
  f:=OpenGameFile(Fname);
  if f=nil then begin SynChronize(ShowNothing); Raise Exception.Create(Fname+' not found'); end;
  size:=F.Fsize;
  if size>4000 then size:=4000;
  PText:=StrAlloc(size+1);
  F.Fread(Ptext^,size);
  (Ptext+size)^:=#0;
  F.FClose;
  Synchronize(ShowText);
 end
 else
 if ext='.WAV' then
 begin
  if PWav<>nil then
  begin
   PlaySound(Nil,0,SND_NODEFAULT);
   FreeMem(PWav);
   PWav:=nil;
  end;
  f:=OpenGameFile(Fname);
  if f=nil then begin SynChronize(ShowNothing); Raise Exception.Create(Fname+' not found'); end;
  GetMem(PWav,F.Fsize);
  F.Fread(PWav^,F.Fsize);
  F.FClose;
  PlaySound(PWav,0,SND_NODEFAULT or SND_MEMORY or SND_ASYNC);
  Synchronize(ShowNothing);
 end
 else Synchronize(ShowNothing);
Except
 on E:Exception do begin Msg:='Exception in thread: '+E.Message; Synchronize(ExceptionMsg); end
else begin Msg:='Exception in thread: '+ExceptObject.ClassName; Synchronize(ExceptionMsg); end;
end;
loopend:
if not NewFile then Suspend;
Until Terminated;
end;

Procedure TPreviewThread.TerminateProc;
begin
 if PWav<>nil then
 begin
  PlaySound(Nil,0,SND_NODEFAULT);
  FreeMem(PWav);
 end;
end;

end.
