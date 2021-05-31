unit DragOut;

interface
uses files, OLE2, classes, clipbrd, fileoperations;

Type
 TGiveFiles=class
  data:IDataObject;
  copied:boolean;
  FContainer:TContainerFile;
  Files:TStringList;
  extracted:boolean;
  Constructor Create(Container:TContainerFile);
  Destructor Destroy;override;
  Procedure Clear;
  Procedure AddFile(Name:String;fi:TFileInfo);
  Procedure CopyIt; {Copies to clipboard}
  Procedure DragIt; {Drag&drops}
  Procedure ExtractFiles;
 end;

implementation

uses Windows, OleAuto {for OleCheck}, SysUtils, ShlObj;

var TempDir:String;

type
  TMyDataObject = class(IDataObject)
  private
    RefCount: integer;
    Data: TStringList;
  public
    function QueryInterface(const iid: TIID; var obj): HResult; override; stdcall;
    function AddRef: Longint; override; stdcall;
    function Release: Longint; override; stdcall;
    function GetData(var formatetcIn: TFormatEtc; var medium: TStgMedium):
      HResult; override; stdcall;
    function GetDataHere(var formatetc: TFormatEtc; var medium: TStgMedium):
      HResult; override; stdcall;
    function QueryGetData(var formatetc: TFormatEtc): HResult;
      override; stdcall;
    function GetCanonicalFormatEtc(var formatetc: TFormatEtc;
      var formatetcOut: TFormatEtc): HResult; override; stdcall;
    function SetData(var formatetc: TFormatEtc; var medium: TStgMedium;
      fRelease: BOOL): HResult; override; stdcall;
    function EnumFormatEtc(dwDirection: Longint; var enumFormatEtc:
      IEnumFormatEtc): HResult; override; stdcall;
    function DAdvise(var formatetc: TFormatEtc; advf: Longint;
      advSink: IAdviseSink; var dwConnection: Longint): HResult; override; stdcall;
    function DUnadvise(dwConnection: Longint): HResult; override; stdcall;
    function EnumDAdvise(var enumAdvise: IEnumStatData): HResult;
      override; stdcall;
    constructor Create(sl: TStringList);
  end;

  TMyEnum = class(IEnumFormatEtc)
  private
    RefCount: integer;
    Index: integer;

  public
    function QueryInterface(const iid: TIID; var obj): HResult; override; stdcall;
    function AddRef: Longint; override; stdcall;
    function Release: Longint; override; stdcall;
    function Next(celt: Longint; var elt;
      pceltFetched: PLongint): HResult; override; stdcall;
    function Skip(celt: Longint): HResult; override; stdcall;
    function Reset: HResult; override; stdcall;
    function Clone(var enum: IEnumFormatEtc): HResult; override; stdcall;
  end;

  TMyDropSource = class(IDropSource)
  private
    RefCount: integer;
    dobj:TMyDataObject;
  public
    Constructor Create(obj:TMyDataObject);
    function QueryInterface(const iid: TIID; var obj): HResult; override; stdcall;
    function AddRef: Longint; override; stdcall;
    function Release: Longint; override; stdcall;
    function QueryContinueDrag(fEscapePressed: BOOL;
      grfKeyState: Longint): HResult; override; stdcall;
    function GiveFeedback(dwEffect: Longint): HResult; override; stdcall;
  end;


Function Slist2Hdrop(sl:TStringList):HGlobal;
var
  pdf: PDropFiles;
  ps, ps1: PChar;
  lentdir,len:Integer;
  i:integer;
begin
  len:=0;
  lentdir:=Length(TempDir);
  For i:=0 to sl.Count-1 do
   inc(len,Length(sl[i])+1+Lentdir);
  Result := GlobalAlloc(GMEM_SHARE, Sizeof(pdf^)+len+2);
    if Result = 0 then exit;

 pdf:=GlobalLock(Result);
 with pdf^ do
 begin
  pFiles:=sizeof(pdf^);
  pt.X:=0;
  pt.Y:=0;
  fNC:=true;
  fWide:=false;
 end;
 ps:=pchar(pdf)+sizeof(pdf^);
 ps1:=ps;
 ps^:=#0;
 for i:=0 to sl.Count-1 do
 begin
  ps:=StrEcopy(ps,pchar(TempDir));
  ps:=StrECopy(ps,Pchar(sl[i]))+1;
 end;
 ps^:=#0;
 if ps1=nil then;
 GlobalUnlock(Result);
end;

{ TMyDataObject }
constructor TMyDataObject.Create(sl: TStringList);
begin
  inherited Create;
  Data := sl;
end;

function TMyDataObject.QueryInterface(const iid: TIID; var obj): HResult; stdcall;
begin
  if IsEqualIID(iid, IID_IUnknown) or IsEqualIID(iid, IID_IDataObject) then begin
    Pointer(obj) := self;
    AddRef;
    Result := S_OK;
  end else begin
    Pointer(obj) := nil;
    Result := E_NOINTERFACE;
  end;
end;

function TMyDataObject.AddRef: Longint; stdcall;
begin
  Inc(RefCount);
  Result := RefCount;
end;

function TMyDataObject.Release: Longint; stdcall;
begin
  Dec(RefCount);
  Result := RefCount;
  if RefCount = 0 then
    Free;
end;

function TMyDataObject.GetData(var formatetcIn: TFormatEtc; var medium: TStgMedium):
      HResult; stdcall;
var
  hdf: HGlobal;
begin
  if Failed(QueryGetData(formatetcIn)) then
    Result := DV_E_FORMATETC
  else begin
  hdf:=sList2HDrop(data);
   if hdf=0 then
   begin
    Result := E_OUTOFMEMORY;
    Exit;
   end;

    with medium do begin
      tymed := TYMED_HGLOBAL;
      hGlobal:=hdf;
      unkForRelease := nil;
    end;

    Result := S_OK;
  end;
end;

function TMyDataObject.GetDataHere(var formatetc: TFormatEtc; var medium: TStgMedium):
      HResult; stdcall;
begin
  Result := E_NOTIMPL;
end;

function TMyDataObject.QueryGetData(var formatetc: TFormatEtc): HResult; stdcall;
begin
  with formatetc do begin
    if cfFormat <> CF_HDROP then
      Result := DV_E_FORMATETC
    else if (tymed and TYMED_HGLOBAL) = 0 then
      Result := DV_E_TYMED
    else
      Result := S_OK;
  end;
end;

function TMyDataObject.GetCanonicalFormatEtc(var formatetc: TFormatEtc;
      var formatetcOut: TFormatEtc): HResult; stdcall;
begin
  Result := E_NOTIMPL;
end;

function TMyDataObject.SetData(var formatetc: TFormatEtc; var medium: TStgMedium;
      fRelease: BOOL): HResult; stdcall;
begin
  Result := E_NOTIMPL;
end;

function TMyDataObject.EnumFormatEtc(dwDirection: Longint; var enumFormatEtc:
      IEnumFormatEtc): HResult; stdcall;
begin
  if dwDirection = DATADIR_GET then begin
    enumFormatEtc := TMyEnum.Create;
    enumFormatEtc.AddRef;
    Result := S_OK;
  end else begin
    enumFormatEtc := nil;
    Result := E_NOTIMPL;
  end;
end;

function TMyDataObject.DAdvise(var formatetc: TFormatEtc; advf: Longint;
      advSink: IAdviseSink; var dwConnection: Longint): HResult; stdcall;
begin
  Result := E_NOTIMPL;
end;

function TMyDataObject.DUnadvise(dwConnection: Longint): HResult; stdcall;
begin
  Result := E_NOTIMPL;
end;

function TMyDataObject.EnumDAdvise(var enumAdvise: IEnumStatData): HResult; stdcall;
begin
  Result := E_NOTIMPL;
end;


{ TMyEnum }

function TMyEnum.QueryInterface(const iid: TIID; var obj): HResult; stdcall;
begin
  if IsEqualIID(iid, IID_IUnknown) or IsEqualIID(iid, IID_IEnumFormatEtc) then begin
    Pointer(obj) := self;
    AddRef;
    Result := S_OK;
  end else begin
    Pointer(obj) := nil;
    Result := E_NOINTERFACE;
  end;
end;

function TMyEnum.AddRef: Longint; stdcall;
begin
  Inc(RefCount);
  Result := RefCount;
end;

function TMyEnum.Release: Longint; stdcall;
begin
  Dec(RefCount);
  Result := RefCount;
  if RefCount = 0 then
    Free;
end;

function TMyEnum.Next(celt: Longint; var elt;
      pceltFetched: PLongint): HResult; stdcall;
begin
  Result := S_FALSE;
  if (Index = 0) and (celt > 0) then begin
    Inc(Index);
    with TFormatEtc(elt) do begin
      cfFormat := CF_HDROP;
      ptd := nil; // not sure I should do this!
      dwAspect := DVASPECT_ICON;
      lindex := -1;
      tymed := TYMED_HGLOBAL;
    end;

    if pceltFetched <> nil then pceltFetched^ := 1;
    if celt = 1 then Result := S_OK;
  end else begin
    if pceltFetched <> nil then pceltFetched^ := 0;
  end;
end;

function TMyEnum.Skip(celt: Longint): HResult; stdcall;
begin
  Inc(Index, celt);
  if Index > 1 then Result := S_FALSE else Result := S_OK;
end;

function TMyEnum.Reset: HResult; stdcall;
begin
  Index := 0;
  Result := S_OK;
end;

function TMyEnum.Clone(var enum: IEnumFormatEtc): HResult; stdcall;
begin
  enum := TMyEnum.Create;
  enum.AddRef;
  TMyEnum(enum).Index := Index;
  Result := S_OK;
end;


{ TMyDropDSource }

Constructor TMyDropSource.Create(obj:TMyDataObject);
begin
 dobj:=obj;
end;

function TMyDropSource.QueryInterface(const iid: TIID; var obj): HResult; stdcall;
begin
  if IsEqualIID(iid, IID_IUnknown) or IsEqualIID(iid, IID_IDropSource) then begin
    Pointer(obj) := self;
    AddRef;
    Result := S_OK;
  end else begin
    Pointer(obj) := nil;
    Result := E_NOINTERFACE;
  end;
end;

function TMyDropSource.AddRef: Longint; stdcall;
begin
  Inc(RefCount);
  Result := RefCount;
end;

function TMyDropSource.Release: Longint; stdcall;
begin
  Dec(RefCount);
  Result := RefCount;
  if RefCount = 0 then
    Free;
end;

function TMyDropSource.QueryContinueDrag(fEscapePressed: BOOL;
      grfKeyState: Longint): HResult; stdcall;
begin
  if fEscapePressed then
    Result := DRAGDROP_S_CANCEL
  else if (grfKeyState and MK_LBUTTON) = 0 then
    Result := DRAGDROP_S_DROP
  else
    Result := NOERROR;
end;

function TMyDropSource.GiveFeedback(dwEffect: Longint): HResult; stdcall;
begin
  Result := DRAGDROP_S_USEDEFAULTCURSORS;
end;


{ Global Function }

Constructor TGiveFiles.Create(Container:TContainerFile);
begin
 FContainer:=Container;
 files:=TStringList.Create;
end;

Destructor TGiveFiles.Destroy;
begin
 Clear;
 files.free;
end;

Procedure TGiveFiles.AddFile(Name:String;fi:TFileInfo);
begin
 Files.AddObject(Name,Fi);
end;

Procedure TGiveFiles.Clear;
var clp:TClipBoard;
    i:integer;
begin
 clp:=Clipboard;
 if clp.HasFormat(CF_HDROP) then Clp.Clear;
 if extracted then
 for i:=0 to files.count-1 do
   DeleteFile(TempDir+files[i]);
 extracted:=false;
 Files.Clear;
end;

Procedure TGiveFiles.CopyIt; {Copies to clipboard}
var  hdf:Hglobal;
     clp:TClipBoard;
begin
 ExtractFiles;
 hdf:=sList2HDrop(files);
 clp:=Clipboard;
 clp.SetAsHandle(CF_HDROP,hdf);
end;

Procedure TGiveFiles.ExtractFiles;
var i:integer;
    f,fout:TFile;
begin
 if extracted then exit;
 for i:=0 to Files.Count-1 do
 begin
  f:=FContainer.OpenFileByFI(TFileInfo(Files.Objects[i]));
  fout:=OpenFileWrite(TempDir+files[i],0);
  CopyFileData(f,fout,f.fsize);
  f.Fclose;
  fout.Fclose;
 end;
 extracted:=true;
end;


Procedure TGiveFiles.DragIt; {Drag&drops}
var
  MyData: TMyDataObject;
  MyDrop: TMyDropSource;
  Effect: LongInt;
begin
 ExtractFiles;
  try
    MyData := TMyDataObject.Create(files);
    MyData.AddRef;
{    OleSetClipBoard(MyData);
    exit;}
    try
      MyDrop := TMyDropSource.Create(MyData);
      MyDrop.AddRef;
      try
        DoDragDrop(IDataObject(MyData), IDropSource(MyDrop),
                       DROPEFFECT_COPY, Effect);

      finally
        MyData.Release;
      end;
    finally
      MyDrop.Release;
    end;
  except
  end;
end;



{ Startup/Shutdown }
var s:array[0..255] of char;

initialization
begin
  OleCheck(OleInitialize(nil));
  GetTempPath(256,s);
  TempDir:=s;
end;

finalization
  OleUninitialize;
end.
