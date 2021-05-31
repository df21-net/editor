unit FieldEdit;

interface
uses Grids, Classes;

{TFieldEdit pseudo control
 For Sector/Wall/Vertex/Object editors
}

type

TVarType=(vtString,vtDouble,vtInteger,vtDword);

TFieldInfo=class
Private
 Grid:TStringGrid;
 row:Integer;
 Function GetS:String;
 Procedure SetS(const s:String);
 Procedure BadValueMsg;
Public
 id:Integer;
 changed:boolean;
 vtype:TVarType;
 Constructor Create(aGrid:TStringGrid;arow:integer);
 Property s:String read GetS write SetS;
 Procedure ReadString(var st:String);
 Procedure ReadInteger(var i:Integer);
 Procedure Read0to31(var b:Byte);
 Procedure ReadDword(var d:longint);
 Procedure ReadDouble(var d:Double);
end;

TFEHandler=Procedure(Fi:TFieldInfo) of object;

TFieldEdit=class
 Private
  grid:TStringGrid;
  fl:TList;
  Function GetField(n:Integer):TFieldInfo;
  Function GetCurField:TFieldInfo;
 Public
  FieldCount:Integer;
  ONDblClick:TFEHandler;
  ONChange:TFEHandler;
  Constructor Create(aGrid:TStringGrid);
  Destructor Destroy;override;
  Procedure Clear;
  Property CurrentField:TFieldInfo read GetCurField;
  Property Fields[n:integer]:TFieldInfo read GetField;
  procedure SelectHandler(Sender: TObject; Col, Row: Longint; var CanSelect: Boolean);
  procedure DblClickHandler(Sender: TObject);
  procedure SetTextHandler(Sender: TObject; ACol, ARow: Longint; const Text: string);
  Procedure AddField(Name:String;ID:Integer;vartype:TVarType);
  Function GetFieldByID(ID:Integer):TFieldInfo;
end;

implementation
uses Misc_Utils, SysUtils, Windows;

Constructor TFieldInfo.Create(aGrid:TStringGrid;arow:integer);
begin
 Grid:=aGrid;
 Row:=arow;
end;

Function TFieldInfo.GetS:String;
begin
 Result:=Grid.Cells[1,row];
end;

Procedure TFieldInfo.SetS(const s:String);
begin
 Changed:=true;
 Grid.Cells[1,row]:=s;
end;

Procedure TFieldInfo.BadValueMsg;
begin
 MsgBox(s+' is not a valid value for '+Grid.Cells[0,row],
             'Field Editor',mb_ok);
end;

Procedure TFieldInfo.ReadString(var st:String);
begin
 st:=s;
end;

Procedure TFieldInfo.ReadInteger(var i:Integer);
var v,a:Integer;
begin
 Val(s,v,a);
 if a=0 then i:=v
 else BadValueMsg;
end;

Procedure TFieldInfo.Read0to31(var b:Byte);
var v,a:Integer;
begin
 Val(s,v,a);
 if (a=0) and (v>=-31) and (v<=31) then b:=v
 else BadValueMsg;
end;

Procedure TFieldInfo.ReadDword(var d:longint);
begin
 Try
  d:=StrToDword(s);
 except
  On EConvertError do BadValueMsg;
 end;
end;

Procedure TFieldInfo.ReadDouble(var d:Double);
var a:Integer;
    v:Double;
begin
 Val(s,v,a);
 if a=0 then d:=v
 else BadValueMsg;
end;

Constructor TFieldEdit.Create(aGrid:TStringGrid);
begin
 grid:=aGrid;
 fl:=TList.Create;
 Grid.OnDblclick:=DblClickHandler;
 Grid.OnSelectCell:=SelectHandler;
 Grid.OnSetEditText:=SetTextHandler;
end;

Destructor TFieldEdit.Destroy;
begin
 Grid.OnDblclick:=nil;
 Grid.OnSelectCell:=nil;
 Clear;
 FL.Free;
end;

Procedure TFieldEdit.Clear;
var i:integer;
begin
 For i:=0 to FieldCount-1 do
 begin
  Grid.Cells[0,i]:='';
  Grid.Cells[1,i]:='';
  Fields[i].Free;
 end;
 FL.Clear;
end;

Function TFieldEdit.GetField(n:Integer):TFieldInfo;
begin
 Result:=TFieldInfo(FL.List[n]);
end;

Function TFieldEdit.GetFieldByID(ID:Integer):TFieldInfo;
var i:Integer;
begin
 Result:=nil;
 for i:=0 to FieldCount-1 do
 if Fields[i].ID=ID then begin Result:=Fields[i]; exit; end;
end;

Function TFieldEdit.GetCurField:TFieldInfo;
begin
 if Grid.Row<>-1 then Result:=TFieldInfo(FL.List[Grid.Row]) else Result:=nil;
end;

procedure TFieldEdit.SelectHandler(Sender: TObject; Col, Row: Longint; var CanSelect: Boolean);
var fi:TFieldInfo;
begin
 if (col<>1) or (row>=FieldCount) then CanSelect:=false
 else
 begin
  fi:=Fields[Row];
  if fi=nil then CanSelect:=false
  else if fi.id=-1 then CanSelect:=false
  else CanSelect:=true;
 end;
end;

procedure TFieldEdit.DblClickHandler(Sender: TObject);
var fi:TFieldInfo;
begin
 With Grid do
 begin
  if (col<>1) or (row>=FieldCount) then exit;
  fi:=Fields[row];
 end;
  if (fi<>nil) and (Assigned(OnDblClick)) then OnDblClick(fi);
end;

Function IsValid(const s:string;vt:TVarType):Boolean;
var a:Integer;
    i:Integer;
    d:Double;
begin
 a:=-1;
 Case vt of
  vtString: a:=0;
  vtInteger: Val(s,i,a);
  vtDouble: Val(s,d,a);
  vtDword: begin
            a:=0;
            Try
            i:=StrToDword(s);
            except
             On EConvertError do a:=-1;
            end;
           end;
 end;
 Result:=a=0;
end;

procedure TFieldEdit.SetTextHandler(Sender: TObject; ACol, ARow: Longint; const Text: string);
var Fi:TFieldInfo;
begin
 if (ACol<>1) or (Arow>=FieldCount) then exit;
 fi:=Fields[aRow];
 if fi<>nil then
 begin
  fi.changed:=true;
  if Assigned(OnChange) then OnChange(fi);
 end;

end;

Procedure TFieldEdit.AddField(Name:String;ID:Integer;vartype:TVarType);
var fi:TFieldInfo;
begin
 fi:=TFieldInfo.Create(Grid,FieldCount);
 fi.id:=ID;
 fi.vtype:=varType;
 Grid.Cells[0,FieldCount]:=Name;
 FL.Add(fi);
 Inc(FieldCount);
 Grid.RowCount:=FieldCount;
end;

end.
