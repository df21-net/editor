unit Q_Utils;

interface
uses Level, SysUtils, StdCtrls, Misc_Utils, Windows;

Type
 TCompAction=(ca_None,ca_Equal,ca_NotEqual,ca_Above,ca_Below,
              ca_In,ca_NotIn);

 TQInt=record
         V:Integer;
         act:TCompAction;
       end;
 TQString=record
         V:String;
         act:TCompAction;
       end;
 TQFlags=record
         V:Longint;
         act:TCompAction;
        end;
 TQDouble=record
           V:Double;
           act:TCompAction;
          end;

 TSectorFindInfo=class
 NVertices:TQInt;
 HexID:TQInt;
 Name:TQString;
 Ambient:TQInt;
 Palette:TQString;
 ColorMap:TQString;
 Friction:TQDouble;
 Gravity: TQDouble;
 Elasticity: TQDouble;
 Velocity_X: TQDouble;
 Velocity_Y: TQDouble;
 Velocity_Z: TQDouble;
 VAdjoin: TQInt;
 Floor_Sound: TQString;
 Floor_Y: TQDouble;
 Floor_TX: TQString;
{ Floor_extra:double;
  Ceiling_Extra:Double;
  F_Overlay_Extra:
  C_Overlay_Extra:Double;
   FloorSlope,
 CeilingSlope:TSlope;
}
 Ceiling_Y: TQDouble;
 Ceiling_TX: TQString;
 F_Overlay_TX: TQString;
 C_Overlay_TX: TQSTring;
 Flags: TQFlags;
 Layer: TQInt;
end;

TWallFindInfo=class
 HexID:TQInt;
 Mid,Top,Bot:TQString;
 OverLay:TQString;
 Adjoin,DAdjoin:TQInt;
 Mirror,DMirror:TQInt;
 Flags:TQFlags;
 Light:TQInt;
end;

TObjectFindInfo=class
 HexID:TQInt;
 Name:TQString;
 Sector:TQInt;
 X,Y,Z:TQDouble;
 PCH,YAW,ROL:TQDouble;
 flags1,Flags2:TQFlags;
end;

TQueryField=class
 CB: TComboBox;
 EB:TEdit;
 vType:Integer;
 P:Pointer;
 Constructor Create(aCB:TComboBox;aEB:TEdit);
 Constructor CreateHex(aCB:TComboBox;aEB:TEdit;var H:TQInt);
 Constructor CreateStr(aCB:TComboBox;aEB:TEdit;var S:TQString);
 Constructor CreateInt(aCB:TComboBox;aEB:TEdit;var I:TQInt);
 Constructor CreateDouble(aCB:TComboBox;aEB:TEdit;var D:TQDouble);
 Constructor CreateFlags(aCB:TComboBox;aEB:TEdit;var F:TQFlags);
 procedure EBChangeHandler(Sender: TObject);
 Procedure CBChangeHandler(Sender: TObject);
end;

Function TestStr(const s1,s2:String;action:TCompAction):Boolean;
Function TestDouble(d1,d2:double;action:TCompAction):Boolean;
Function TestFlags(f1,f2:Longint;action:TCompAction):Boolean;
Function TestInt(const f1,f2:Integer;action:TCompAction):Boolean;

Function SectorMatches(S:TSector;fi:TSectorFindInfo):Boolean;
Function WallMatches(W:TWall;fi:TWallFindInfo):Boolean;
Function ObjectMatches(O:TOB;fi:TObjectFindInfo):Boolean;

Function FindNextSector(L:TLevel;LastSC:Integer;fi:TSectorFindInfo):Integer;
Function FindNextWall(L:TLevel;LastSC,LastWL:Integer;fi:TWallFindInfo;var NewSC:Integer):Integer;
Function FindNextObject(L:TLevel;LastOB:Integer;fi:TObjectFindInfo):Integer;

implementation
const
     vtInt=1;
     vtStr=2;
     vtDouble=3;
     vtFlags=4;
     vtHex=5;

Constructor TQueryField.Create(aCB:TComboBox;aEB:TEdit);
begin
 CB:=aCB;
 EB:=aEB;
 EB.OnChange:=EBChangeHandler;
 CB.OnChange:=CBChangeHandler;
end;

Constructor TQueryField.CreateStr(aCB:TComboBox;aEB:TEdit;var S:TQString);
begin
 Create(aCB,aEB);
 P:=@S;
 VType:=vtStr;
end;

Constructor TQueryField.CreateHex(aCB:TComboBox;aEB:TEdit;var H:TQInt);
begin
 Create(aCB,aEB);
 P:=@H;
 VType:=vtHex;
end;

Constructor TQueryField.CreateInt(aCB:TComboBox;aEB:TEdit;var I:TQInt);
begin
 Create(aCB,aEB);
 P:=@I;
 VType:=vtInt;
end;

Constructor TQueryField.CreateDouble(aCB:TComboBox;aEB:TEdit;var D:TQDouble);
begin
 Create(aCB,aEB);
 P:=@D;
 VType:=vtDouble;
end;

Constructor TQueryField.CreateFlags(aCB:TComboBox;aEB:TEdit;var F:TQFlags);
begin
 Create(aCB,aEB);
 P:=@F;
 VType:=vtFlags;
end;

procedure TQueryField.EBChangeHandler(Sender: TObject);
var s:String;a:Integer;
    l:Longint;
    i:Integer;
    d:Double;
begin
 s:=EB.Text;
 If CB.ItemIndex<=0 then begin CB.ItemIndex:=1; CB.OnChange(nil); end;
 Case vType of
  vtStr: TQString(P^).V:=s;
  vtInt: With TQInt(P^) do
          if ValInt(s,i) then V:=i else
          begin
           if s='-' then exit;
           MsgBox(s+' is not a valid integer','Error',mb_ok);
           EB.Text:=IntToStr(V);
          end;
  vtDouble: With TQDouble(P^) do
          if ValDouble(s,d) then V:=d else
          begin
           if s='-' then exit;
           MsgBox(s+' is not a valid double','Error',mb_ok);
           EB.Text:=FloatToStr(V);
          end;
  vtFlags: With TQInt(P^) do
          if ValDword(s,l) then V:=l else
          begin
           MsgBox(s+' is not a valid dword','Error',mb_ok);
           EB.Text:=DwordToStr(V);
          end;
  vtHex: With TQInt(P^) do
          if ValHex(s,l) then V:=l else
          begin
           MsgBox(s+' is not a valid hex','Error',mb_ok);
           EB.Text:=Format('%x',[V]);
          end;
 end;
end;

procedure TQueryField.CBChangeHandler(Sender: TObject);
var s:String; act:TCompAction;
begin
 s:=UpperCase(CB.Text);
 act:=ca_None;

 if s='' then act:=ca_None
 else if s='=' then act:=ca_Equal
 else if s='>' then act:=ca_Above
 else if s='<' then act:=ca_Below
 else if s='<>' then act:=ca_NotEqual
 else if s='IS' then act:=ca_Equal
 else if s='IS NOT' then act:=ca_NotEqual
 else if s[1] in ['S','C'] then act:=ca_In {'Set' or 'Contains'}
 else if s[1] in ['N','D'] then act:=ca_NotIn; {'Not set' or 'Doesn't contain'}

 case vtype of
  vtStr: TQString(p^).act:=act;
  vtInt,vtHex: TQInt(p^).act:=act;
  vtDouble: TQDouble(p^).act:=act;
  vtFlags: TQFlags(p^).act:=act;
 end;
end;


Function QTestInt(const qi:TQInt;I:Integer):Boolean;
begin
 Result:=TestInt(i,qi.v,qi.act);
end;

Function QTestStr(const qi:TQString;s:String):Boolean;
begin
 Result:=TestStr(qi.v,s,qi.act);
end;

Function QTestFlags(const qi:TQFlags;f:LongInt):Boolean;
begin
 Result:=TestFlags(f,qi.v,qi.act);
end;

Function QTestDouble(const qi:TQDouble;d:double):Boolean;
begin
 Result:=TestDouble(d,qi.v,qi.act);
end;

Function SectorMatches(S:TSector;fi:TSectorFindInfo):Boolean;
begin
 With S do Result:=
     QTestInt(fi.NVertices,Vertices.Count) and
     QTestInt(fi.HexID,HexID) and
     QTestStr(fi.Name,Name) and
     QTestInt(fi.Ambient,Ambient) and
     QTestStr(fi.Palette,Palette) and
     QTestStr(fi.ColorMap,ColorMap) and
     QTestDouble(fi.Friction,Friction) and
     QTestDouble(fi.Gravity,Gravity) and
     QTestDouble(fi.Elasticity,Elasticity) and
     QTestDouble(fi.Velocity_X,Velocity.DX) and
     QTestDouble(fi.Velocity_Y,Velocity.DY) and
     QTestDouble(fi.Velocity_Z,Velocity.DZ) and
     QTestInt(fi.VAdjoin,VAdjoin) and
     QTestStr(fi.Floor_Sound,Floor_Sound) and
     QTestDouble(fi.Floor_Y,Floor_Y) and
     QTestStr(fi.Floor_TX,Floor_Texture.Name) and
     QTestDouble(fi.Ceiling_Y,Ceiling_Y) and
     QTestStr(fi.Ceiling_TX,Ceiling_Texture.Name) and
     QTestStr(fi.F_Overlay_TX,F_Overlay_Texture.Name) and
     QTestStr(fi.C_Overlay_TX,C_Overlay_Texture.Name) and
     QTestFlags(fi.Flags,Flags) and
     QTestInt(fi.Layer,Layer);
end;

Function WallMatches(W:TWall;fi:TWallFindInfo):Boolean;
begin
 With W do
 Result:=QTestInt(fi.HexID,HexID) and
     QTestStr(fi.Mid,Mid.Name) and
     QTestStr(fi.Top,Top.Name) and
     QTestStr(fi.Bot,Bot.Name) and
     QTestStr(fi.Overlay,Overlay.Name) and
     QTestFlags(fi.Flags,Flags) and
     QTestInt(fi.Light,light) and
     QTestInt(fi.Adjoin,Adjoin) and
     QTestInt(fi.DAdjoin, DAdjoin) and
     QTestInt(fi.Mirror,Mirror) and
     QTestInt(fi.DMirror,Dmirror);
end;

Function ObjectMatches(O:TOB;fi:TObjectFindInfo):Boolean;
begin
With O do
 Result:=
     QTestInt(fi.HexID,HexID) and
     QTestStr(fi.Name,Name) and
     QTestFlags(fi.Flags1,Flags1) and
     QTestFlags(fi.Flags2,Flags2) and
     QTestInt(fi.Sector,Sector) and
     QTestDouble(fi.X,X) and
     QTestDouble(fi.Y,Y) and
     QTestDouble(fi.Z,Z) and
     QTestDouble(fi.PCH,PCH) and
     QTestDouble(fi.YAW,YAW) and
     QTestDouble(fi.ROL,ROL);
end;

Function FindNextSector(L:TLevel;LastSC:Integer;fi:TSectorFindInfo):Integer;
var s:Integer;
begin
 Result:=-1;
 For s:=LastSC+1 to L.Sectors.Count-1 do
  if SectorMatches(L.Sectors[s],fi) Then
     begin
      Result:=s;
      exit;
     end;
end;

Function FindNextWall(L:TLevel;LastSC,LastWL:Integer;fi:TWallFindInfo;var NewSC:Integer):Integer;
var s,w:Integer;
begin
Result:=-1;
NewSC:=-1;

for s:=LastSC to L.Sectors.count-1 do
With L.Sectors[s] do
begin
 for w:=LastWL+1 to Walls.Count-1 do
 begin
  if WallMatches(Walls[w],fi) then
     begin
      NewSC:=s;
      Result:=w;
      exit;
     end;
 end;
 LastWL:=-1;
end;
end;

Function FindNextObject(L:TLevel;LastOB:Integer;fi:TObjectFindInfo):Integer;
var o:Integer;
begin
 Result:=-1;
 for o:=LastOB+1 to L.Objects.Count-1 do
 begin
  if ObjectMatches(L.Objects[o],fi) then
     begin
      Result:=o;
      exit;
     end;
 end;
end;

Function TestStr(const s1,s2:String;action:TCompAction):Boolean;
begin
 Case action of
     ca_none: Result:=true;
    ca_Equal: Result:=CompareText(s1,s2)=0;
 ca_NotEqual: Result:=CompareText(s1,s2)<>0;
    ca_Above: Result:=CompareText(s1,s2)>0;
    ca_Below: Result:=CompareText(s1,s2)<0;
       ca_in: Result:=Pos(UpperCase(s1),UpperCase(s2))<>0;
    ca_NotIn: Result:=Pos(UpperCase(s1),UpperCase(s2))=0;
 else Result:=false;
 end;
end;

Function TestDouble(d1,d2:double;action:TCompAction):Boolean;
begin
 Case action of
     ca_none: Result:=true;
    ca_Equal: Result:=d1=d2;
 ca_NotEqual: Result:=d1<>d2;
    ca_Above: Result:=d1>d2;
    ca_Below: Result:=d1<d2;
 else Result:=false;
 end;
end;

Function TestFlags(f1,f2:Longint;action:TCompAction):Boolean;
begin
 Case action of
     ca_none: Result:=true;
    ca_Equal: Result:=f1=f2;
 ca_NotEqual: Result:=f1<>f2;
    ca_Above: Result:=f1>f2;
    ca_Below: Result:=f1<f2;
       ca_in: Result:=f1 and f2<>0;
    ca_NotIn: Result:=f1 and f2=0;
 else Result:=false;
 end;
end;

Function TestInt(const f1,f2:Integer;action:TCompAction):Boolean;
begin
 Case action of
     ca_none: Result:=true;
    ca_Equal: Result:=f1=f2;
 ca_NotEqual: Result:=f1<>f2;
    ca_Above: Result:=f1>f2;
    ca_Below: Result:=f1<f2;
       ca_in: Result:=f1 and f2<>0;
    ca_NotIn: Result:=f1 and f2=0;
 else Result:=false;
 end;
end;


end.
