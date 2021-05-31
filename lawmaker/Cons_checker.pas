unit Cons_checker;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Level, Level_Utils, misc_utils, GlobalVars, Buttons;

type
  TConsistency = class(TForm)
    Errors: TListBox;
    Panel: TPanel;
    BNClose: TButton;
    BNGoto: TButton;
    BNCheck: TButton;
    BNOptions: TButton;
    SBHelp: TSpeedButton;
    procedure ErrorsDblClick(Sender: TObject);
    procedure BNCloseClick(Sender: TObject);
    procedure BNCheckClick(Sender: TObject);
    procedure BNGotoClick(Sender: TObject);
    procedure ErrorsClick(Sender: TObject);
    procedure BNOptionsClick(Sender: TObject);
    procedure SBHelpClick(Sender: TObject);
  private
    { Private declarations }
    Procedure ClearErrors;
    Function L:TLevel;
  public
   MapWindow:TForm;
   Procedure Check;
    { Public declarations }
  end;

implementation
Uses Mapper, U_Options;
Const
     et_none=0;
     et_sector=1;
     et_wall=2;
     et_object=3;
Type
 TConsistencyError=class
  etype:Integer;
  ID:Longint;
  ScID:Longint;
 end;

{$R *.DFM}

Function TConsistency.L:TLevel;
begin
 Result:=TMapWindow(MapWindow).Level;
end;

procedure TConsistency.ErrorsDblClick(Sender: TObject);
begin
 BNGoto.Click;
end;

procedure TConsistency.BNCloseClick(Sender: TObject);
begin
 Close;
end;

Procedure TConsistency.ClearErrors;
var i:Integer;
begin
 for i:=0 to Errors.Items.Count-1 do Errors.Items.Objects[i].Free;
 Errors.Items.Clear;
end;

{Assumes the sector has 2 walls at each vertex, all vertex references valid}
Function ArrangeVertices(L:TLevel;sc:integer):boolean;
var i,j:integer;
    TheSector:TSector;
    TheWall:TWall;
    nwall,cvx:integer;
    wln,vxn,vxs,wls:TList;
    revwls:TList;
    cyclebase:integer;

Procedure vx_add(n:Integer);
begin
 vxn.Add(Pointer(n));
 vxs.Add(TheSector.Vertices[n]);
end;

Procedure wl_add(n:Integer);
begin
 wln.Add(Pointer(n));
 wls.Add(TheSector.Walls[n]);
end;

Procedure AdjustWLRef(var aSC,aWl:integer);
var w:integer;
begin
 if aSc<>sc then exit;
 w:=wln.IndexOf(Pointer(aWL));
 if w<>-1 then aWl:=w else begin aSC:=-1; aWL:=-1; end;
end;

Procedure AdjustVXRef(var aVX:Integer);
var v:integer;
begin
 V:=vxn.IndexOf(Pointer(aVX));
 if V=-1 then V:=0;
 aVX:=V;
end;

begin {Arrangevertices}
 Result:=false;
 TheSector:=L.Sectors[sc];
 With TheSector do
begin
 for i:=0 to vertices.count-1 do Vertices[i].Mark:=0;
 for i:=0 to walls.count-1 do
 with Walls[i] do
 begin
  Mark:=0;
  if Vertices[V1].Mark=1 then exit;
  Vertices[V1].Mark:=1;
 end;
 vxs:=TList.Create;vxn:=TList.Create;
 wls:=TList.Create;wln:=TList.Create;
 Result:=true;
 Repeat
  nwall:=-1;
  for i:=0 to Walls.count-1 do if Walls[i].Mark=0 then begin nwall:=i; break; end;
  if nwall=-1 then break;
  TheWall:=Walls[nwall];
  TheWall.Mark:=1;
  cyclebase:=TheWall.V1;
  wl_add(nwall);
  vx_add(TheWall.V1);
  vx_add(TheWall.V2);
  cvx:=TheWall.V2;

  Repeat
   nwall:=-1;
   for i:=0 to walls.count-1 do
   With Walls[i] do
   if (Mark=0) and (V1=cvx) then
    begin
     nwall:=i;
     Mark:=1;
     wl_add(nwall);
     cvx:=V2;
     if cvx=cyclebase then nwall:=-1 else vx_add(V2);
     break;
    end;
 until nwall=-1;
until false;
{Change wall references}
for i:=0 to L.Sectors.Count-1 do
With L.Sectors[i] do
begin
 AdjustWLRef(FloorSlope.Sector,FloorSlope.Wall);
 AdjustWLRef(CeilingSlope.Sector,CeilingSlope.Wall);
 for j:=0 to Walls.Count-1 do
 With Walls[j] do
 begin
  AdjustWLRef(Adjoin,Mirror);
  AdjustWLRef(DAdjoin,DMirror);
 end;
end;
{Rearrange walls}
for i:=0 to wls.Count-1 do Walls[i]:=TWall(wls[i]);
{Change vertex references}
for i:=0 to Walls.Count-1 do
With Walls[i] do
begin
 AdjustVXRef(V1);
 AdjustVXRef(V2);
end;
{Rearrange vertices}
for i:=0 to vxs.Count-1 do Vertices[i]:=TVertex(vxs[i]);
wls.free;wln.free;
vxs.free;vxn.free;
end;
end;

Procedure TConsistency.Check;
var i,s,w,v,o:Integer;
    Lev:TLevel;
    TheSector,Sec:TSector;
    TheWall,cWall:TWall;
    NotClosed:Boolean;
    tmp:Integer;
    Players,
    startpos,
    flagstars,
    ballstars:Integer;
    PF,
    SPF,
    FSF,
    BSF:Longint;
    oname:String;
    BadVX:Boolean;
    BadVXOrder:Boolean;
    TwoWLPerVX:Boolean;
    fixOrder:boolean;
    Cyclebase,CycleCount:Integer;

Const
     AdjoinedFlags=WALLFLAG1_MIDTEX or WALLFLAG1_NOPASS or
     WALLFLAG1_FORCEPASS or WALLFLAG1_FENCE or WALLFLAG1_SHATTER or
     WALLFLAG1_PROJECTILE_OK;

Procedure AddError(Const Text:String;etype:Integer;ID:longint);
var ce:TConsistencyError;
begin
 ce:=TConsistencyError.Create;
 ce.etype:=etype;
Case eType of
 et_Sector,et_Object: ce.ID:=ID;
 et_Wall: begin ce.ID:=ID; ce.scID:=Sec.HexID; end;
 et_none: begin ce.free; ce:=nil; end;
end;
 if etype=et_none then Errors.Items.AddObject(Text,ce)
 else Errors.Items.AddObject(Format('%s ID: %x',[Text,ID]),ce);
end;

Function FixError(const Text:String;etype:Integer;ID:longint):Boolean;
begin
 Case cc_FixErrors of
  cc_Fix:Result:=true;
  cc_NeverFix: Result:=false;
  cc_Ask: Result:=MsgBox(Text+' Fix?','Fix confirmation',MB_YesNo)=IDYes;
 end;
 if Result then AddError(Text+'(Fixed)',etype,ID)
 else AddError(Text,etype,ID);
end;


Function SCInvalid(SC:Integer):Boolean;
begin
 Result:=(SC<-1) or (SC>=Lev.Sectors.Count);
end;

Function WLInvalid(SC,WL:Integer):Boolean;
begin
 Result:=True;
 If SCInvalid(SC) then exit;
 if (SC<>-1) and (WL=-1) then exit;
 if SC=-1 then begin Result:=false; exit; end;
 Result:=(WL<-1) or (WL>=Lev.Sectors[SC].Walls.Count);
end;

Procedure CheckTX(var tx:String;const text:String;etype:integer;ID:Longint);
begin
 if tx='' then
  if FixError(text,etype,ID) then tx:='DEFAULT.PCX';
end;

Procedure CheckFlags(var f:longint; corFlag,ID:longint);
begin
 If (f<>corFlag) then
  if FixError('Incorrect flags on player start',et_object,ID) then f:=corFlag;
end;

begin
if Not Visible then Show;
ClearErrors;
Lev:=l;
if Length(TMapWindow(MapWindow).LevelName)>8 then AddError('Level name is more than 8 characters long',et_none,0);
if Trim(Lev.Music)='' then
begin
 if FixError('No MUSIC in the level header',et_none,0) then L.Music:='NULL';
end;
With L do
begin
for s:=Sectors.Count-1 downto 0 do
With Sectors[s] do
begin
Sec:=Sectors[s];
 {Sector checks}
 for i:=1 to length(Name) do
 if Name[i] in ['a'..'z'] then
 begin
  if FixError('Sector name in lowercase',et_sector,HexID) then
  Name:=UpperCase(Name);
  break;
 end;

 If Floor_Y>Ceiling_Y Then AddError('Floor is higher than ceiling',et_sector,HexID);
 if SCInvalid(VADJOIN) then AddError('VADJOIN out of range',et_sector,HexID);
 if (Friction<0) or (Friction>1) then AddError('Friction invalid',et_sector,HexID);
 if (Elasticity<0) or (Elasticity>4) then AddError('Elasticity invalid',et_sector,HexID);
 With FloorSlope do If WLInvalid(Sector,Wall) then AddError('Invalid floor slope',et_sector,HexID);
 With CeilingSlope do If WLInvalid(Sector,Wall) then AddError('Invalid ceiling slope',et_sector,HexID);

 CheckTX(Floor_Texture.Name,'Empty floor texture',et_sector,HexID);
 CheckTX(Ceiling_Texture.Name,'Empty ceiling texture',et_sector,HexID);

 if (Vertices.Count=0) or (Walls.Count=0) then
  if FixError('Empty sector',et_sector,HexID) then begin DeleteSector(Lev,s); continue; end;

 if Walls.Count<3 then
  if FixError('Less than 3 walls in sector',et_sector,HexID) then begin DeleteSector(Lev,s); continue; end;

 if Walls.Count<>Vertices.Count then AddError('Warning: Number of Walls<>Number of vertices',et_sector,HexID);

 {Clear vertex marks}
 for v:=0 to Vertices.Count-1 do Vertices[v].Mark:=0;

 {Checking walls}
 For w:=Walls.Count-1 downto 0 do
 With Walls[w] do
 begin
  cWall:=Walls[w];
  CheckTX(MID.Name,'Empty MID texture',et_wall,cWall.HexID);
  CheckTX(BOT.Name,'Empty BOT texture',et_wall,cWall.HexID);
  CheckTX(TOP.Name,'Empty TOP texture',et_wall,cWall.HexID);
  {Check wall flags}
  if (Adjoin=-1) and (DAdjoin=-1) and (Flags and AdjoinedFlags<>0) then
   if FixError('Unadjoined wall has adjoined flags set',et_wall,cWall.HexID) then
    Flags:=Flags and (not AdjoinedFlags);

  {Check if Adjoin=-1 and Dadjoin<>-1}
  if (Adjoin=-1) and (DAdjoin<>-1) then
   if FixError('Second adjoin exists while first doesn''t',et_wall,cWall.HexID) then
   begin
    Adjoin:=Dadjoin;
    Mirror:=Dmirror;
    DAdjoin:=-1;
    DMirror:=-1;
   end;
  {Check if Adjoin=DAdjoin}
  if (Adjoin<>-1) and (DADJOIN<>-1) and (Adjoin=DAdjoin) and (Mirror=DMirror) then
   if FixError('Second adjoin is the same as first',et_wall,cWall.HexID) then
    begin DAdjoin:=-1; DMirror:=-1; end;

  if (V1<0) or (V1>=Vertices.Count) then
  begin
   AddError('Invalid Wall vertex',et_wall,cWall.HexID);
   BadVX:=true;
  end
  else Inc(Vertices[V1].Mark);

  if (V2<0) or (V2>=Vertices.Count) then
  begin
   AddError('Invalid Wall vertex',et_wall,Walls[w].HexID);
   BadVX:=true;
  end
  else Inc(Vertices[V2].Mark);

  if BadVX then continue;

  {Check adjoin}
  if WLInvalid(ADJOIN,MIRROR) then AddError('Invalid adjoin',et_wall,cWall.HexID)
  else if WLInvalid(DADJOIN,DMIRROR) then AddError('Invalid Dadjoin',et_wall,cWall.HexID)
  else
  begin
   if not ReverseAdjoinValid(Lev,s,w) then AddError('Invalid reverse adjoin',et_wall,cWall.HexID);
   {Check double adjoin}
   if (Adjoin<>-1) and (DAdjoin<>-1) then
    if Sectors[DAdjoin].Floor_Y>Sectors[Adjoin].Floor_Y then
     if FixError('Adjoin and DAdjoin are in incorrect order',et_Wall,cWall.HexID) then
      begin
       Tmp:=Adjoin; Adjoin:=DAdjoin; DAdjoin:=tmp;
       tmp:=Mirror; Mirror:=DMirror; DMirror:=tmp;
      end;

    if V1=V2 then
     AddError('Wall starts and ends at the same vertex!',et_wall,Walls[w].HexID);
    if GetWLLen(Lev,s,w)=0 then
     if FixError('Zero length wall',et_wall,Walls[w].HexID) then DeleteWall(Lev,s,w);
 end;
end; {For w:=o to walls.count-1}

{Check Vertex Order}
Cyclebase:=0; Cyclecount:=0; BadVXOrder:=false;
For w:=0 to Walls.Count-1 do
With Walls[w] do
begin
 if V1<>w then begin BadVXOrder:=true; break; end;
 if V2=w+1 then inc(CycleCount)
 else if V2=CycleBase then
 begin
  Inc(CycleCount);
  CycleBase:=w+1;
  if CycleCount<3 then AddError('Cycle of less than 3 vertices in sector',et_sector,Sec.HexID);
  cycleCount:=0;
 end
 else begin BadVXOrder:=true; break; end;
end;
{Check vertex references}
 NotClosed:=false;
 TwoWLPerVX:=true;
 For v:=Vertices.Count-1 downto 0 do
 With Vertices[v] do
 case Mark of
  0: if FixError('Orphan vertex',et_sector,HexID) then DeleteVertex(Lev,s,v) else TwoWLPerVX:=false;
  1: begin NotClosed:=true; TwoWLPerVX:=false; end;
  2: ;
 else
 begin
  TwoWLPerVX:=false;
  if Mark And 1<>0 then AddError('Uneven number of walls meet at one vertex',et_sector,HexID);
 end;
 end;

 {Fix bad vertex order, if possible}
 if BadVXOrder then
 if not TwoWLPerVX then AddError('Bad vertex order - can''t fix',et_sector,HexID)
 else
 begin
  FixOrder:=true;
  if DoConfirm(c_VXOrderFix) then FixOrder:=
   MsgBox(Pchar(Format('Bad Vertex Order SC %x. Fix?',[HexID])),'Confirm',mb_YesNo)=idYes;
  if FixOrder then
  begin
   ArrangeVertices(L,s);
   AddError('Bad Vertex Order(fixed)',et_sector,HexID);
  end
  else AddError('Bad Vertex Order',et_sector,HexID);
 end;

 if NotClosed then AddError('Sector not closed',et_sector,HexID);
end; {End for s:=0 to Sectors.count-1}

Players:=0;
startpos:=0;
flagstars:=0;
ballstars:=0;

PF:=0;
SPF:=0;
FSF:=0;
BSF:=0;

for o:=Objects.Count-1 downto 0 do
With Objects[o] do
begin
 if Name='' then AddError('Empty object name',et_object,HexID);
 if Sector=-1 then
  AddError('Object not in sector',et_object,HexID);
 oname:=UpperCase(Name);
 if oname='PLAYER' then begin inc(players); PF:=PF or Flags2; end
 else if oName='STARTPOS' then begin inc(startpos); CheckFlags(Flags2,$F0000000,HexID); end
 else if oName='FLAGSTAR' then begin inc(flagstars); CheckFlags(Flags2,$F0800000,HexID); end
 else if oName='BALLSTAR' then begin inc(ballstars); CheckFlags(Flags2,$F2000000,HexID); end;
end;

if PF and $B0000000<>$B0000000 then AddError('PLAYER object doesn''t exist on all difficulties!',et_none,0);
if Startpos<7 then AddError('Less than 7 STARTPOS objects',et_none,0);
if flagstars<8 then AddError('Less than 8 FLAGSTAR objects',et_none,0);
if ballstars<8 then AddError('Less than 8 BALLSTAR objects',et_none,0);

end; {End with L do}
if Errors.ItemIndex<=0 then Errors.ItemIndex:=0 else Errors.OnClick(nil);
end;

procedure TConsistency.BNCheckClick(Sender: TObject);
begin
 Check;
end;

procedure TConsistency.BNGotoClick(Sender: TObject);
var Index:Integer;
    ce:TConsistencyError;
    sc,wl,ob:Integer;
begin
 Index:=Errors.ItemIndex;
 if Index<0 then exit;
 ce:=TConsistencyError(Errors.Items.Objects[Index]);
 if ce=nil then exit;
 Case ce.Etype of
  et_sector: begin
              sc:=L.GetSectorByID(ce.ID);
              if sc=-1 then
              begin MsgBox('No sector with this ID','Error',mb_OK); exit; end;
              TMapWindow(MapWindow).Goto_Sector(SC);
             end;
  et_wall:   begin
              sc:=L.GetSectorByID(ce.ScID);
              if sc=-1 then
              begin MsgBox('No sector with this ID','Error',mb_OK); exit; end;
              wl:=L.Sectors[SC].GetWallByID(ce.ID);
              if wl=-1 then MsgBox('No wall with this ID','Error',mb_OK);
              TMapWindow(MapWindow).Goto_Wall(Sc,Wl);
             end;
  et_Object: begin
              OB:=L.GetObjectByID(ce.ID);
              if ob=-1 then
              begin MsgBox('No Object with this ID','Error',mb_OK); exit; end;
              TMapWindow(MapWindow).Goto_Object(OB);

             end;
  end;
end;

procedure TConsistency.ErrorsClick(Sender: TObject);
var Index:Integer;
    ce:TConsistencyError;
begin
 Index:=Errors.ItemIndex;
 if Index=-1 then begin BNGoto.Enabled:=false; exit; end;
 ce:=TConsistencyError(Errors.Items.Objects[Index]);
 if ce=nil then BNGoto.Enabled:=false
 else BNGoto.Enabled:=true;
end;

procedure TConsistency.BNOptionsClick(Sender: TObject);
begin
 Options.SetOptions(Options.Misc);
end;

procedure TConsistency.SBHelpClick(Sender: TObject);
begin
 Application.HelpJump('Hlp_Consistency_Checker');
end;

end.
