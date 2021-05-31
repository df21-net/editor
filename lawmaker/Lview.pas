unit Lview;

interface
uses Windows, Messages, Classes, Controls, CommCtrl, Forms;

type
TLVHandler=Procedure(Item:Integer);

 TLVSortType=(st_Ascending,st_descending);
TSysLview=class
 Handle:Integer;
private
 LVI:TLVITem;
 LVC:TLVColumn;
 FCItem:Integer;
 FText:String;
 FColText:String;
 OldWndProc:pointer;
 Procedure SetText(s:String);
 Procedure SetImage(Img:Integer);
 Procedure SetState(st:Uint);
 Function GetViewStyle:Integer;
 Procedure SetViewStyle(s:Integer);
 Procedure SetColText(s:String);
 Procedure SetColFmt(f:integer);
 Procedure SetColWidth(w:Integer);
Public
 OnClick,
 OnDblClick,
 OnRClick,
 OnEdited:TLVHandler;
 Constructor Create(parent:TForm);
 Destructor Destroy; override;
 Procedure Resize(x,y,w,h:Integer);
 Procedure SetItem(N:Integer);
 Procedure GetItem(N:Integer);
 Procedure InsertItem(N:Integer);
 Procedure SetColumn(N:Integer);
 Procedure GetCoulmn(N:Integer);
 Procedure InsertColumn(n:Integer);
 Procedure Clear;
 Function ItemsCount:Integer;
 Property ViewStyle:Integer read GetViewStyle write SetViewStyle;
 Property ItemText:String read Ftext write SetText;
 Property ItemImage:Integer read LVI.iImage write SetImage;
 Property ItemState:Integer read LVI.State write SetState;
 Property ColumnText:String read FColText write SetColText;
 Property ColumnFormat:Integer read LVC.fmt write SetColFmt;
 Property ColumnWidth:Integer read LVC.cx write SetColWidth;
 Procedure SetSubItem(n,isub:integer;s:string);
 Function GetSubItem(n,iSub:Integer):String;
 {Property OnClick:
  Property OnDblClick:
  Property OnEdited}
end;

implementation

Const LV_FirstID=5000;
    LV_CurID:Integer=LV_FirstID;

Type
 TLRec=record
   LV_ID:integer;
   ParentWindow:Hwnd;
   lv:TSysLView;
 end;

 TLRList=array[0..99] of TLRec;
 PLRList=^TLRList;

TLVList=class {List of all ListViews created}
 FList:PLRList;
 FItemCount:integer;
 FItemAllocated:integer;
 Constructor Create;
 Procedure AddLview(LView:TSysLView;Parent:Hwnd;id:Integer);
 Procedure DeleteLview(Lview:TSysLView);
 Function GetByParent(Parent:Hwnd):TSysLView;
 Function GetByID(ID:Integer):TSysLView;
 Destructor Destroy;override;
end;

Constructor TLVList.Create;
begin
 FItemAllocated:=4;
 GetMem(Flist,FItemAllocated*Sizeof(TLRLIst));
end;

Destructor TLVList.Destroy;
begin
 FreeMem(Flist);
end;

Procedure TLVList.AddLview(LView:TSysLView;Parent:Hwnd;ID:Integer);
begin
 if FItemAllocated=FItemCount then
 begin
  Inc(FItemAllocated,4);
  ReallocMem(Flist,FItemAllocated*sizeof(TLRList));
 end;
 with Flist^[FItemCount] do
 begin
  ParentWindow:=Parent;
  LV:=Lview;
  LV_ID:=ID;
  Inc(FItemCount);
 end;
end;

Function TLVList.GetByID(ID:Integer):TSysLView;
var i:integer;
begin
 Result:=nil;
 For i:=0 to FItemCount-1 do
 with Flist^[i] do
  if LV_ID=ID then
   begin
    Result:=LV; exit;
   end;
end;

Procedure TLVList.DeleteLview(Lview:TSysLView);
var n,i:Integer;
begin
 n:=-1;
 for i:=0 to FItemCount-1 do
 with FList^[i] do
 if LV=Lview then
 begin
  n:=i;
  break;
 end;
if n<>-1 then
begin
 for i:=n to FItemCount-2 do
 FList^[i]:=Flist^[i+1];
 Dec(FItemCount);
end;
end;

Function TLVList.GetByParent(Parent:Hwnd):TSysLView;
var i:integer;
begin
 Result:=nil;
 For i:=0 to FItemCount-1 do
 with Flist^[i] do
  if Parent=ParentWindow then
   begin
    Result:=LV; exit;
   end;
end;

Var
 LVList:TLVList;

Procedure TSysLview.Resize(x,y,w,h:Integer);
begin
 MoveWindow(Handle,x,y,w,h,true);
end;

Const StyleMask=LVS_Icon or LVS_SmallIcon or LVS_Report or
      LVS_List;


Procedure TSysLview.SetViewStyle(s:Integer);
begin
 SetWindowLong(Handle,GWL_STYLE,
  GetWindowLong(Handle,GWL_STYLE) and (-1 xor StyleMask) or s);
end;

Function TSysLview.GetViewStyle:Integer;
begin
 Result:=GetWindowLong(Handle,GWL_STYLE) and StyleMask;
end;

Procedure TSysLview.SetText(s:String);
begin
 LVI.mask:=LVI.mask or LVIF_Text;
 FText:=s;
end;

Procedure TSysLview.SetImage(Img:Integer);
begin
 LVI.mask:=LVI.Mask or LVIF_Image;
 LVI.iImage:=img;
end;

Procedure TSysLview.SetState(st:Uint);
begin
 LVI.mask:=LVI.mask or LVIF_State;
 LVI.State:=st;
end;

Procedure TSysLview.Clear;
begin
 ListView_DeleteAllItems(Handle);
end;

Function LviewHandler(Window : hWnd; Msg,WParam,LParam : Integer) : Integer; StdCall;
var
    Lv:TSysLView;
    LVH:PNMListView absolute LParam;

Procedure HandleLVNotification;
begin
With LV do
case LVH^.hdr.code of
 NM_CLick: if Assigned(OnClick) then OnClick(LVH^.iItem);
 NM_Dblclk: if Assigned(OnDblClick) then OnDblClick(LVH^.iItem);
 NM_RClick: if Assigned(OnRClick) then OnRClick(LVH^.iItem);
 LVN_EndLabelEdit: if Assigned(OnEdited) then OnEdited(LVH^.iItem);
end;
end;

begin
 result:=1;
 if msg=WM_NOTIFY then
 begin
  LV:=LVList.GetByID(Wparam);
  if LV<>Nil then HandleLVNotification;
 end;
 LV:=LVList.GetByParent(Window);
 Result:=CallWindowProc(LV.OldWndProc,window,msg,wparam,lparam);
end;


Constructor TSysLview.Create;
var r:TRect;
np:Pointer;
begin
  InitCommonControls;
  GetClientRect(Parent.handle,r);
  handle := CreateWindowEx( 0,
		WC_LISTVIEW,
		'',
		WS_VISIBLE or WS_CHILD or WS_BORDER or
  LVS_NOLABELWRAP or LVS_SORTASCENDING or
  LVS_ICON or LVS_EDITLABELS or LVS_NOLABELWRAP,
                r.left, r.top,
                r.right-r.left, r.bottom-r.top,
		Parent.handle,
		LV_CurID,
		hInstance,
		Nil );
ShowWindow(Handle,sw_show);
OldWndProc:=Pointer(GetWindowLong(Parent.handle,GWL_WNDPROC));
LVList.AddLview(Self,Parent.Handle,LV_CurID);
Inc(LV_CurID);
SetWindowLong(Parent.handle,GWL_WNDPROC,longint(@LViewHandler));
end;

Destructor TSysLview.Destroy;
begin
 LVList.DeleteLview(Self);
end;

Procedure TSysLview.SetSubItem(n,isub:integer;s:string);
var b:LongBool;
begin
 b:=ListView_SetItemText(Handle,n,isub,pchar(s));
 if b then;
end;

Function TSysLview.GetSubItem(n,iSub:Integer):String;
var buf:array[0..255] of char;
    b:Integer;
begin
 b:=ListView_GetItemText(Handle,n,isub,buf,sizeof(buf));
 if b=-1 then Result:=buf else Result:='';
end;

Procedure TSysLview.SetItem(N:Integer);
begin
 LVI.iItem:=n;
 LVI.iSubItem:=0;
 if LVI.mask and LVIF_Text<>0 then
 begin
  LVI.pszText:=Pchar(Ftext);
 end;
 ListView_SetItem(Handle,LVI);
end;

Procedure TSysLview.InsertItem(N:Integer);
begin
 LVI.iItem:=n;
 LVI.iSubItem:=0;
 if LVI.mask and LVIF_Text<>0 then
 begin
  LVI.pszText:=Pchar(Ftext);
 end;
 ListView_InsertItem(Handle,LVI);
 LVI.mask:=0;
end;

Procedure TSysLview.GetItem(N:Integer);
var buf:array[0..255] of char;
begin
 LVI.iItem:=n;
 LVI.iSubItem:=0;
 LVI.Mask:=LVIF_TEXT or LVIF_IMAGE or LVIF_PARAM or LVIF_STATE;
 LVI.pszText:=@buf;
 LVI.cchTextMax:=sizeof(buf);
 ListView_GetItem(Handle,LVI);
 FText:=buf;
 LVI.Mask:=0;
end;

Function TSysLview.ItemsCount:Integer;
begin
 Result:=ListView_GetItemCount(Handle);
end;

Procedure TSysLview.SetColText(s:String);
begin
 FColText:=s;
 LVC.Mask:=LVC.Mask or LVCF_TEXT;
end;

Procedure TSysLview.SetColFmt(f:integer);
begin
 LVC.fmt:=f;
 LVC.Mask:=LVC.Mask or LVCF_FMT;
end;

Procedure TSysLview.SetColWidth(w:Integer);
begin
 LVC.cx:=w;
 LVC.Mask:=LVC.Mask or LVCF_WIDTH;
end;

Procedure TSysLview.SetColumn(N:Integer);
begin
 LVC.Mask:=LVC.Mask or LVCF_SUBITEM;
 LVC.iSubItem:=N;
 if LVC.Mask and LVCF_TEXT<>0 then
 begin
  LVC.pszText:=PChar(FColText);
  LVC.cchTextMax:=Length(FColText);
 end;
 ListView_SetColumn(Handle,N,LVC);
 LVC.Mask:=0;
end;

Procedure TSysLview.GetCoulmn(N:Integer);
var buf:Array[0..255] of char;
begin
 LVC.Mask:=LVCF_FMT or LVCF_SUBITEM or LVCF_TEXT or LVCF_WIDTH;
 LVC.pszText:=buf;
 LVC.cchTextMax:=sizeof(Buf);
 ListView_GetColumn(Handle,n,LVC);
 FColText:=buf;
 LVC.Mask:=0;
end;

Procedure TSysLview.InsertColumn(n:Integer);
begin
 LVC.Mask:=LVC.Mask or LVCF_SUBITEM;
 LVC.iSubItem:=N;
 if LVC.Mask and LVCF_TEXT<>0 then
 begin
  LVC.pszText:=PChar(FColText);
  LVC.cchTextMax:=Length(FColText);
 end;
 ListView_InsertColumn(Handle,N,LVC);
 LVC.Mask:=0;
end;

Initialization
 LVList:=TLVList.create;

Finalization
 LVList.Free;

end.
