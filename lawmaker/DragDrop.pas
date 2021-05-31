unit dragdrop;

interface
uses files, OLE2, classes;

Type
 TGiveFiles=class
  data:IDataObject;
  copied:boolean;
  FContainer:TContainerFile;
  Constructor Create(Container:TContainerFile);
  Destructor Destroy;virtual;
  Procedure SelectFiles(files:TStringList);
  Procedure CopyIt; {Copies to clipboard}
  Procedure DragIt; {Drag&drops}
 end;

implementation

uses Windows, OleAuto {for OleCheck}, SysUtils, ShlObj;

type
  TMyDataObject = class(IDataObject)
  private
    RefCount: integer;
    Data: string;

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
    constructor Create(s: string);
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

  public
    function QueryInterface(const iid: TIID; var obj): HResult; override; stdcall;
    function AddRef: Longint; override; stdcall;
    function Release: Longint; override; stdcall;
    function QueryContinueDrag(fEscapePressed: BOOL;
      grfKeyState: Longint): HResult; override; stdcall;
    function GiveFeedback(dwEffect: Longint): HResult; override; stdcall;
  end;


{ TMyDataObject }
constructor TMyDataObject.Create(s: string);
begin
  inherited Create;
  Data := s;
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
  pdf: PDropFiles;
  ps: PChar;
  s:String;
begin
  if Failed(QueryGetData(formatetcIn)) then
    Result := DV_E_FORMATETC
  else begin
    s:='c:\rr\a.txt';
    hdf := GlobalAlloc(GMEM_SHARE, Sizeof(pdf^)+length(s)+2);
    if hdf = 0 then begin
      Result := E_OUTOFMEMORY;
      Exit;
    end;

 pdf:=GlobalLock(hdf);
 with pdf^ do
 begin
  pFiles:=sizeof(pdf^);
  pt.X:=0;
  pt.Y:=0;
  fNC:=true;
  fWide:=false;
 end;
 ps:=pchar(pdf)+sizeof(pdf^);
 StrPCopy(ps,s);
 (ps+length(s)+1)^:=#0;
 GlobalUnlock(hdf);

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

function DragIt(s: string): Integer;
var
  MyData: TMyDataObject;
  MyDrop: TMyDropSource;
  Effect: LongInt;
begin
  Result := 0;
  try
    MyData := TMyDataObject.Create(s);
    MyData.AddRef;
    try
      MyDrop := TMyDropSource.Create;
      MyDrop.AddRef;
      try
        if (DoDragDrop(IDataObject(MyData), IDropSource(MyDrop),
                       DROPEFFECT_COPY, Effect) = DRAGDROP_S_DROP) and
           (Effect = DROPEFFECT_COPY) then
          Result := 1
        else
          Result := -1;
      finally
        MyData.Release;
      end;
    finally
      MyDrop.Release;
    end;
  except
  end;
end;

Constructor TGiveFiles.Create(Container:TContainerFile);
begin
 FContainer:=Container;
end;

Destructor TGiveFiles.Destroy;
begin
 if Copied then;
end;

Procedure TGiveFiles.SelectFiles(files:TStringList);
begin
end;

Procedure TGiveFiles.CopyIt; {Copies to clipboard}
begin
end;

Procedure TGiveFiles.DragIt; {Drag&drops}
begin
end;



{ Startup/Shutdown }

initialization
  OleCheck(OleInitialize(nil));

finalization
  OleUninitialize;
end.
