unit DragIn;

interface
uses OLE2, Windows;

{Type

 IMyTraget=class(IDropTarget)
  public
    function QueryInterface(const iid: TIID; var obj): HResult; override; stdcall;
    function AddRef: Longint; override; stdcall;
    function Release: Longint; override; stdcall;

    function DragEnter(dataObj: IDataObject; grfKeyState: Longint;
      const pt: TPoint; var dwEffect: Longint): HResult; override; stdcall;
    function DragOver(grfKeyState: Longint; const pt: TPoint;
      var dwEffect: Longint): HResult; override; stdcall;
    function DragLeave: HResult; override; stdcall;
    function Drop(dataObj: IDataObject; grfKeyState: Longint; const pt: TPoint;
      var dwEffect: Longint): HResult; override; stdcall;
  end;}


implementation

end.
