unit LECScripts;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  CommCtrl, Menus, StdCtrls, ComCtrls, Files, FileOperations, misc_utils,
  GlobalVars, RichEdit;

Type
    TAssistEvent=Procedure (NLine,NChar:Integer) of object;
    TFIOEvent=Procedure (const name:String) of object;

const
     sc_INF=0;
     sc_ITM=1;
     sc_ATX=2;
     sc_PHY=3;
     sc_RCS=4;
     sc_RCA=5;
     sc_RCM=6;
     sc_CHK=7;
     sc_MSC=8;

     id_unknown=-1;
     atx_Texture=0;
     atx_StartSound=2;
     atx_stop=3;
     atx_goto=4;
     atx_rate=5;
     atx_inst=6;
     atx_atx=7;

     inf_inf=0;
     inf_levelname=1;
     inf_items=2;
     inf_item=3;
     inf_seq=4;
     inf_class=5;
     inf_speed=6;
     inf_angle=7;
     inf_seqend=8;
     inf_stop=9;
     inf_sound=10;
     inf_message=11;
     inf_center=12;
     inf_eventmask=13;
     inf_client=14;
     inf_entitymask=15;
     inf_object=16;
     inf_objectexclude=17;
     inf_master=18;
     inf_slave=19;
     inf_event=20;

     inf_next_stop=0;
     inf_prev_stop=1;
     inf_goto_stop=2;
     inf_done=3;
     inf_master_on=4;
     inf_master_off=5;
     inf_set_bits=6;
     inf_clear_bits=7;
     inf_user_msg=9;
     inf_spawn_level=10;
     inf_end_level=11;
     inf_trigger_movie=12;
     rcp_rcp=0;
     rcp_name=1;
     rcp_modes=2;
     rcp_story=3;
     rcp_begin=4;
     rcp_end=5;
     rcp_level=6;
     rcp_flags=7;
     rcp_movie=8;
     rcp_paths=9;
     rcp_credits=10;
     rcp_text=11;

     itm_Item=0;
     itm_func=1;
     itm_preload=2;
     itm_data=3;
     itm_Float=4;
     itm_int=5;
     itm_str=6;
     itm_anim=7;

str_ACTION_SOUND_1=0;
str_ACTION_SOUND_2=1;
str_ALERT_TAUNTS=2;
str_AMMO=3;
str_AMMO_2=4;
str_BOSS=5;
str_DEAD_ITEM=6;
str_DEFSND_PICKUP=7;
str_DIE_SOUND=8;
str_DROP_ITEM=9;
str_EXPLOSION=10;
str_EXPLODE_SOUND=11;
str_FIRE_SOUND_1=12;
str_FIRE_SOUND_2=13;
str_FUSE_SOUND=14;
str_GENERATE=15;
str_GROUND_ITEM=16;
str_HIT_SOUND=17;
str_ITEM_CLASS=18;
str_ITEM_CLASS1=19;
str_LOS=20;
str_LOS_TAUNTS=21;
str_MASTER=22;
str_NO_AMMO_SOUND_1=23;
str_NO_AMMO_SOUND_2=24;
str_NO_LOS_TAUNTS=25;
str_OPEN1=26;
str_PC_0=27;
str_P_MSG=28;
str_P_MSG_TO=29;
str_PICKUP=30;
str_PICKUP1=31;
str_PICKUP2=32;
str_PICKUP_SOUND=33;
str_PLAYER_WAX=34;
str_PROJECTILE=35;
str_RELOAD_SOUND=36;
str_SCOPE_ITEM=37;
str_SHOOT_SOUND=38;
str_SND_ARMOR1HIT=39;
str_SND_ARMOR2HIT=40;
str_SND_ARMOR3HIT=41;
str_SND_CHOKE=42;
str_SND_CRUNCH=43;
str_SND_CRUSH=44;
str_SND_DIE=45;
str_SND_GASP=46;
str_SND_GOTSHOT=47;
str_SND_HITHEAD=48;
str_SND_JUMP=49;
str_SND_LAND=50;
str_SND_LANDLT=51;
str_SND_LIGHTLAMP=52;
str_SND_SHRIEK=53;
str_SND_SPLASH=54;
str_SND_SPLAT=55;
str_SND_TIRED=56;
str_SND_WATERDIE=57;
str_SOUND_0=58;
str_START_ITEM_1=59;
str_THROW_ITEM=60;
str_TAUNT_TYPE=61;
str_TYPE=62;
str_SND_USE_F=63;
str_SND_USE_S=64;
str_WEAPON=65;
str_WEAPON_1=66;

int_PICKUP_MSG=0;

type
  TKeyWordList=class(TStringList)
   Constructor Create;
   Procedure AddKeyWord(const w:String;id:integer);
   Function Get(const w:String):integer;
  end;

  TScriptEdit = class(TForm)
    MainMenu: TMainMenu;
    FileMenu: TMenuItem;
    Exit1: TMenuItem;
    SaveMenu: TMenuItem;
    OpenMenu: TMenuItem;
    EditMenu: TMenuItem;
    CopyMenu: TMenuItem;
    CutMenu: TMenuItem;
    Pastemenu: TMenuItem;
    TemplatesMenu: TMenuItem;
    N1: TMenuItem;
    AssistMenu: TMenuItem;
    StatusBar1: TStatusBar;
    SaveDialog: TSaveDialog;
    SaveAs: TMenuItem;
    NewMenu: TMenuItem;
    CreateINF: TMenuItem;
    CreateITM: TMenuItem;
    CreateATX: TMenuItem;
    CreatePHY: TMenuItem;
    CreateRCS: TMenuItem;
    CreateRCA: TMenuItem;
    CreateRCM: TMenuItem;
    Syntax: TMenuItem;
    SelectAll: TMenuItem;
    INFClassMenu: TPopupMenu;
    ElevatorsMenu: TMenuItem;
    MOVEFLOOR1: TMenuItem;
    SCROLL1: TMenuItem;
    FindDialog: TFindDialog;
    TriggersMenu: TMenuItem;
    Standard1: TMenuItem;
    Toggle1: TMenuItem;
    InfMessageMenu: TPopupMenu;
    Next_stop: TMenuItem;
    masteron1: TMenuItem;
    N2: TMenuItem;
    prevstop1: TMenuItem;
    Gotostop1: TMenuItem;
    Masteroff1: TMenuItem;
    N3: TMenuItem;
    SpawnLevel1: TMenuItem;
    Usermsg1: TMenuItem;
    Endlevel1: TMenuItem;
    Single1: TMenuItem;
    Switch11: TMenuItem;
    Morph1: TMenuItem;
    Changelight1: TMenuItem;
    Done1: TMenuItem;
    SET_BITS: TMenuItem;
    Clearbits1: TMenuItem;
    Triggermovie1: TMenuItem;
    N4: TMenuItem;
    Velocity1: TMenuItem;
    Floor1: TMenuItem;
    Ceiling1: TMenuItem;
    FloorCeiling1: TMenuItem;
    Scrollfloor2: TMenuItem;
    Ceiling2: TMenuItem;
    Wall1: TMenuItem;
    Move1: TMenuItem;
    Movepush1: TMenuItem;
    Spindontpush1: TMenuItem;
    Spinpush1: TMenuItem;
    ChangeX1: TMenuItem;
    ChangeY1: TMenuItem;
    ChangeZ1: TMenuItem;
    Slope1: TMenuItem;
    Floor2: TMenuItem;
    Ceiling3: TMenuItem;
    ChangeFriction1: TMenuItem;
    N5: TMenuItem;
    Find1: TMenuItem;
    Memo: TRichEdit;
    OptionsMenu: TMenuItem;
    CreateCHK: TMenuItem;
    ITM_Funcs: TPopupMenu;
    BadGuys1: TMenuItem;
    Regular1: TMenuItem;
    BloodEyeTim1: TMenuItem;
    BobGraham1: TMenuItem;
    BuckshotBillMorgan1: TMenuItem;
    MattDrDeathHenryGeorgeBowers1: TMenuItem;
    DynamiteDickClifton1: TMenuItem;
    Marshal1: TMenuItem;
    BloodyMaryNash1: TMenuItem;
    SpittinJackSanchez1: TMenuItem;
    BillMorganHistorical1: TMenuItem;
    TimBloodEyeHistorical1: TMenuItem;
    SanchezHistorical1: TMenuItem;
    DynamiteDickHistorical1: TMenuItem;
    MaryHistorical1: TMenuItem;
    ChubbyRusselSimms1: TMenuItem;
    SlimSamFulton1: TMenuItem;
    ChiefTwoFeathers1: TMenuItem;
    Civilians1: TMenuItem;
    RattlesnakeDickFarmer1: TMenuItem;
    Misc1: TMenuItem;
    Chickens1: TMenuItem;
    FXMineCar1: TMenuItem;
    Generators1: TMenuItem;
    Genericitems1: TMenuItem;
    Groundobjects1: TMenuItem;
    InvGSafeObject1: TMenuItem;
    Sheriffsstar1: TMenuItem;
    Vanishingcream1: TMenuItem;
    Healthitems1: TMenuItem;
    Multiplayer1: TMenuItem;
    Multiplayerchicken1: TMenuItem;
    blueflagbaseitem1: TMenuItem;
    blueflagitem1: TMenuItem;
    Multiplayerdocument1: TMenuItem;
    redflagbase1: TMenuItem;
    redflag1: TMenuItem;
    MPchicken1: TMenuItem;
    MPblueflag1: TMenuItem;
    MPdocument1: TMenuItem;
    healthitems2: TMenuItem;
    MPredflag1: TMenuItem;
    Breakableobjects1: TMenuItem;
    Navnodes1: TMenuItem;
    NULL1: TMenuItem;
    Weapons1: TMenuItem;
    Dyanmite1: TMenuItem;
    Doubleshotgun1: TMenuItem;
    Fist1: TMenuItem;
    GatlingGun1: TMenuItem;
    Knife1: TMenuItem;
    Pistol1: TMenuItem;
    Rifle1: TMenuItem;
    SawedOff1: TMenuItem;
    Shotgun1: TMenuItem;
    Dynamite1: TMenuItem;
    DynamiteandKnife1: TMenuItem;
    Help1: TMenuItem;
    Help2: TMenuItem;
    ITEM_CLASSES: TPopupMenu;
    Ammunition1: TMenuItem;
    Armor1: TMenuItem;
    Badge1: TMenuItem;
    Fuel1: TMenuItem;
    Goldbar1: TMenuItem;
    Goldsack1: TMenuItem;
    Health1: TMenuItem;
    Key1: TMenuItem;
    Puzzle1: TMenuItem;
    Weapons2: TMenuItem;
    Powerup1: TMenuItem;
    Ball1: TMenuItem;
    Flag1: TMenuItem;
    Document1: TMenuItem;
    Taunt_types: TPopupMenu;
    Simms1: TMenuItem;
    Town1: TMenuItem;
    Train1: TMenuItem;
    Cliff1: TMenuItem;
    Mine1: TMenuItem;
    Types_menu: TPopupMenu;
    Item1: TMenuItem;
    Enemy1: TMenuItem;
    Ambientsound1: TMenuItem;
    Pointsound1: TMenuItem;
    Hidenode1: TMenuItem;
    Navnode1: TMenuItem;
    Shoot1: TMenuItem;
    Nudge1: TMenuItem;
    CreateMSC: TMenuItem;
    Ambientsoundindoors1: TMenuItem;
    procedure AssistMenuClick(Sender: TObject);
    procedure OpenMenuClick(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure CutMenuClick(Sender: TObject);
    procedure CopyMenuClick(Sender: TObject);
    procedure PastemenuClick(Sender: TObject);
    procedure SaveMenuClick(Sender: TObject);
    procedure SaveAsClick(Sender: TObject);
    procedure CreateNewScript(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SelectAllClick(Sender: TObject);
    procedure InfClassClick(Sender: TObject);
    procedure InfMsgClick(Sender: TObject);
    procedure Find1Click(Sender: TObject);
    procedure FindDialogFind(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure OptionsMenuClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FuncClick(Sender: TObject);
    procedure Help2Click(Sender: TObject);
    procedure Item_class_click(Sender: TObject);
    procedure taunt_type_click(Sender: TObject);
    procedure types_click(Sender: TObject);
  private
    FirstFind:boolean;
    FOnAssist:TAssistEvent;
    FOnLoad,FOnSave:TFIOEvent;
    Fname:String;
    NewFile:Boolean;
    CurLine:Integer;
    SelectedMenu:TMenuItem;
    scType:Integer;
    {}
    Templates:TStringList;
    INFKeyWords,
    INFMsgs,
    ATXKeyWords,
    RCPKeyWords,
    ITMKeyWords,
    STRKeyWords,
    INTKeyWords:TKeyWordList;
    { Private declarations }
   Property OnAssist:TAssistEvent read FOnAssist write FOnAssist;
   Property OnLoad:TFioEvent read FOnLoad write FOnLoad;
   Function GetSaveFile(var s:String):Boolean;
   Procedure ATXAssist(NLine,NChar:Integer);
   Procedure ATXLoad(const name:String);
   Procedure ITMLoad(const name:String);
   Procedure ITMAssist(NLine,NChar:Integer);
   Procedure INFAssist(NLine,NChar:Integer);
   Procedure INFLoad(const name:String);
   Procedure PHYLoad(const name:String);
   Procedure RCSLoad(const name:String);
   Procedure RCALoad(const name:String);
   Procedure RCMLoad(const name:String);
   Procedure RCPAssist(NLine,NChar:Integer);
   Procedure CHKAssist(NLine,NChar:Integer);
   Procedure CHKLoad(const name:String);
   Procedure MSCLoad(const name:String);
   Procedure ClearTemplates;
   Procedure AddTemplate(const Name,template:string);
   Procedure AddTemplateKey(const Name,template:string;key:TShortCut);
   Procedure TemplateClick(Sender: TObject);
   Procedure SetScriptType(stype:integer);
   Function GetLineStart(n:Integer):Integer;
   Function GetCurLine:Integer;
   Procedure PickFromMenu(mu:TPopupMenu);
   Procedure WMNotify(var Message: TWMNotify); message WM_NOTIFY;
   Procedure EditInfMsgParams(var s:string);
   Procedure ResetMemo;
   Function SavePrevious:Boolean;
   Procedure LoadScript(const Name:String);
   Procedure CreateScript(const Name:String;stype:integer);
   Function LoadTemplates(const Name:String):boolean;
  public
   Procedure OpenScript(const Name:String);
   Procedure NewScript(const Name:String;stype:integer);
   Property OnSave:TFioEvent read FOnSave write FOnSave;
    { Public declarations }
  end;

var
  ScriptEdit: TScriptEdit;


implementation

uses FileDialogs, ResourcePicker, FlagEditor, Mapper, U_Options, Containers,
  MsgPick;

{$R *.DFM}

Constructor TKeyWordList.Create;
begin
 Inherited Create;
 Sorted:=true;
end;

Procedure TKeyWordList.AddKeyWord(const w:String;id:integer);
begin
 AddObject(w,TObject(id));
end;

Function TKeyWordList.Get(const w:String):integer;
begin
 Result:=IndexOf(w);
 if Result<>-1 then Result:=Integer(Objects[Result]);
end;


Function GetScriptType(const name:String):integer;
var ext:String;
begin
 Result:=id_unknown;
 ext:=UpperCase(ExtractExt(Name));
 if ext='.ATX' then Result:=sc_ATX
 else if ext='.PHY' then Result:=sc_PHY
 else if ext='.INF' then Result:=sc_INF
 else if ext='.ITM' then Result:=sc_ITM
 else if ext='.RCS' then Result:=sc_RCS
 else if ext='.RCA' then Result:=sc_RCA
 else if ext='.RCM' then Result:=sc_RCM
 else if ext='.CHK' then Result:=sc_CHK
 else if ext='.MSC' then Result:=sc_MSC;
end;

Function ReplaceWordAt(const s:string;pos:integer;const w:string):String;
var pend:Integer;extra:String;
begin
 if pos>length(s) then extra:=' ' else Extra:='';
 pend:=ScanForSpace(s,pos);
 Result:=Concat(Copy(s,1,pos-1),extra,w,Copy(s,pend,length(s)));
end;

Function ReplaceWord(const s:string;nword:integer;const w:string):String;
var i,p:integer;
begin
 p:=1;
 for i:=1 to nword do
 begin
  p:=ScanForNonSpace(s,p);
  if i<>nword then p:=ScanForSpace(s,p);
 end;
 Result:=ReplaceWordAt(s,p,w);
end;

Function PosToNWord(const s:string;pos:Integer):Integer;
var pb,pe:integer;n:integer;
begin
 pb:=ScanForNonSPace(s,1);
 pe:=ScanForSpace(s,pb);
 if (pb>pos) or ((pos>=pb) and (pos<=pe)) then begin result:=1; exit; end;
 n:=1;

 While pe<Length(s) do
 begin
  pb:=ScanForNonSpace(s,pe);
  if (pos<pb) and (pos>pe) then
  begin
   if (pos-pe)<(pb-pos) then Result:=n else Result:=n+1;
   exit;
  end;
  pe:=ScanForSpace(s,pb);
  inc(n);
  if (pos>=pb) and (pos<=pe) then begin Result:=n; exit; end;
 end;
 Result:=n;
end;

Procedure FindWordAt(Const s:string; p:integer;var StartPos,Len:integer);
var bp,ep:integer;
begin
 StartPos:=1; Len:=0;
 if s='' then exit;

 bp:=ScanForNonSpace(s,p);
 ep:=ScanForNonSpace(s,-p);

 if (bp-p=0) and (p-ep=0) then {in the middle of the word}
 begin
  bp:=ScanForSpace(s,-p);
  ep:=ScanForSpace(s,p);
 end
 else if (bp-p)<=(p-ep) then {Pick word to the right}
 begin
  ep:=ScanForSpace(s,bp);
 end
 else
 begin {pick a word to the left}
  bp:=ScanForSpace(s,-ep);
 end;
StartPos:=bp;
Len:=ep-bp+1;
end;

Procedure TScriptEdit.WMNotify(var Message: TWMNotify);
begin
 With Message.NMHdr^ do
  if (Code=EN_MSGFILTER) and (HwndFrom=Memo.Handle) then
  With PMsgFilter(Message.NMHdr)^ do
  if Msg=WM_LBUTTONDBLCLK then
   AssistMenuClick(Memo);
end;

Procedure TScriptEdit.PickFromMenu(mu:TPopupMenu);
var pt:TPoint;
    xy:longint;
    i:integer;
begin
 {xy:=SendMessage(Memo.Handle,EM_POSFROMCHAR,Memo.SelStart,0);}
 SendMessage(Memo.Handle,Messages.EM_POSFROMCHAR,Longint(@pt),Memo.SelStart);
{ pt.x:=LoWord(xy); pt.y:=hiWord(xy);}
 With ClientToScreen(pt) do
  Mu.PopUp(x,y);
end;

Function TScriptEdit.GetLineStart(n:Integer):Integer;
begin
 Result:=SendMessage(Memo.Handle,EM_LINEINDEX,n,0);
end;

Function TScriptEdit.GetCurLine:Integer;
begin
 Result:=SendMessage(Memo.Handle,EM_LINEFROMCHAR,Memo.SelStart,0);
end;

procedure TScriptEdit.AssistMenuClick(Sender: TObject);
var nLine,LStart,cChar:Integer;
begin
 cChar:=Memo.SelStart;
 nLine:=GetCurLine;
 lStart:=GetLineStart(nLine);
 CurLine:=Nline;
 if Assigned(OnAssist) then OnAssist(nLine,cChar-LStart+1);
end;

Procedure TScriptEdit.CreateScript(const Name:String;stype:integer);
begin
 FName:=Name;
 NewFile:=true;
 Memo.Lines.Clear;
 SetScriptType(stype);
 if Assigned(OnLoad) then OnLoad(Name);
 Caption:='Script Editor - '+Name;
 Memo.SelText:=Templates[0];
 Memo.Color:=clWindow;
 Memo.ReadOnly:=false;
 Memo.Modified:=false;
end;

Procedure TScriptEdit.NewScript(const Name:String;stype:integer);
begin
 if Not SavePrevious then exit;
 CreateScript(Name,stype);
end;

Function TScriptEdit.SavePrevious:Boolean;
begin
 Result:=true;
 if Memo.Modified then
 Case MsgBox('Script modified. Save?','Modified',mb_YesNoCancel) of
  idYes: SaveMenuClick(Nil);
  idCancel: Result:=false;
 end;
end;

Procedure TScriptEdit.LoadScript(const Name:String);
var f:TFile;
    ps:Pchar;
    fSIze:Longint;
begin
 FName:=Name;
 NewFile:=IsInContainer(FName);
 f:=OpenFileRead(Fname,0);
 SetScriptType(GetScriptType(Name));
 Fsize:=F.Fsize;
 if FSize>100000 then FSize:=100000;
 ps:=StrAlloc(FSize+1);
 F.Fread(ps^,FSize);
 f.Fclose;
 (ps+Fsize)^:=#0;
 Memo.SetTextBuf(ps);
 StrDispose(ps);

 if Assigned(OnLoad) then OnLoad(Name);
 Caption:='Script Editor - '+Name;
 Memo.Color:=clWindow;
 Memo.ReadOnly:=false;
 Memo.Modified:=false;
end;

procedure TScriptEdit.OpenMenuClick(Sender: TObject);
begin
 if not SavePrevious then exit;
 GetFileOpen.Filter:=Filter_ScriptFiles;
 GetFileOpen.FileName:='';
 if GetFileOpen.Execute then LoadScript(GetFileOpen.FileName);
end;

procedure TScriptEdit.Exit1Click(Sender: TObject);
begin
 Close;
end;

procedure TScriptEdit.CutMenuClick(Sender: TObject);
begin
 Memo.CutToClipboard;
end;

procedure TScriptEdit.CopyMenuClick(Sender: TObject);
begin
 Memo.CopyToClipboard;
end;

procedure TScriptEdit.PastemenuClick(Sender: TObject);
begin
 Memo.PasteFromClipboard;
end;



Function TScriptEdit.GetSaveFile(var s:String):Boolean;
begin
 Result:=false;
 With SaveDialog do
  begin
   DefaultExt:=ExtractExt(FName);
   if IsInContainer(Fname) then
   begin
    FileName:=ProjectDir+ExtractName(FName);
   end
   else FileName:=Fname;
   Filter:=Filter_ScriptFiles;
   if not Execute then exit;
   s:=FileName;
   Result:=true;
  end;
end;

procedure TScriptEdit.SaveMenuClick(Sender: TObject);
begin
 if NewFile then if not GetSaveFile(FName) then exit;
  Memo.Lines.SaveToFile(FName);
  Caption:='Script Editor - '+FName;
  NewFile:=false;
  Memo.Modified:=false;
end;

procedure TScriptEdit.SaveAsClick(Sender: TObject);
begin
 if not GetSaveFile(FName) then exit;
 Caption:='Script Editor - '+FName;
 Memo.Lines.SaveToFile(FName);
 NewFile:=false;
 Memo.Modified:=false;
end;

procedure TScriptEdit.CreateNewScript(Sender: TObject);
var what:integer;name:String;
begin
 if Sender=CreateINF then what:=sc_INF
 else if Sender=CreateATX then what:=sc_ATX
 else if Sender=CreatePHY then what:=sc_PHY
 else if Sender=CreateITM then what:=sc_ITM
 else if Sender=CreateRCS then what:=sc_RCS
 else if Sender=CreateRCA then what:=sc_RCA
 else if Sender=CreateRCM then what:=sc_RCM
 else if Sender=CreateCHK then what:=sc_CHK
 else if Sender=CreateMSC then what:=sc_MSC;

 Case what of
  sc_INF: Name:='Untitled.inf';
  sc_ATX: name:='Untitled.atx';
  sc_PHY: name:='Untitled.phy';
  sc_ITM: name:='Untitled.itm';
  sc_RCS: name:='Untitled.rcs';
  sc_RCA: name:='Untitled.rca';
  sc_RCM: name:='Untitled.rcm';
  sc_CHK: name:='Untitled.chk';
  sc_MSC: name:='Untitled.msc';
 end;
 NewScript(name,what);
end;

Procedure TScriptEdit.SetScriptType(stype:integer);
begin
 scType:=stype;
 case stype of
  sc_ATX: begin
           OnLoad:=ATXLoad;
           OnAssist:=ATXAssist;
          end;
  sc_PHY: begin
           OnLoad:=PHYLoad;
           OnAssist:=nil;
          end;
  sc_INF: begin
           OnLoad:=INFLoad;
           OnAssist:=INFAssist;
          end;
  sc_ITM: Begin
           OnLoad:=ITMLoad;
           OnAssist:=ITMAssist;
          end;
  sc_RCS: begin
           OnLoad:=RCSLoad;
           OnAssist:=RCPAssist;
          end;
  sc_RCA: begin
           OnLoad:=RCALoad;
           OnAssist:=RCPAssist;
          end; 
  sc_RCM: begin
           OnLoad:=RCMLoad;
           OnAssist:=RCPAssist;
          end;
  sc_CHK: begin
           OnLoad:=CHKLoad;
           OnAssist:=CHKAssist;
          end;
  sc_MSC: begin
           OnLoad:=MSCLoad;
           OnAssist:=nil;
          end;
  else begin
           OnLoad:=Nil;
           OnAssist:=Nil;
           ClearTemplates;
          end;
 end;
end;

Procedure TScriptEdit.ClearTemplates;
var i:integer;
begin
 for i:=TemplatesMenu.Count-1 downto 0 do TemplatesMenu.Delete(i);
 Templates.Clear;
end;

Procedure TScriptEdit.AddTemplateKey(const Name,template:string;key:TShortCut);
var mi:TMenuItem;
begin
 mi:=TMenuItem.Create(TemplatesMenu);
 mi.Caption:=Name;
 mi.tag:=TemplatesMenu.count;
 mi.OnClick:=TemplateClick;
 if Key<>0 then mi.ShortCut:=key;
 TemplatesMenu.Add(mi);
 Templates.Add(template);
end;

Procedure TScriptEdit.AddTemplate(const Name,template:string);
begin
 AddTemplateKey(Name,Template,0);
end;

Procedure TScriptEdit.TemplateClick(Sender: TObject);
var st:Integer;
begin
  st:=GetLineStart(GetCurLine);
  Memo.SelStart:=st;
  Memo.SelText:=Templates[(Sender as TMenuItem).tag]+#13#10;
  Memo.SelStart:=Memo.SelStart-2;
end;

Procedure TScriptEdit.ATXAssist(NLine,NChar:Integer);
var s,w:string;
    i,n:Integer;
begin
 s:=Memo.Lines[Nline];
 GetWord(s,1,w);
 Case ATXKeyWords.Get(w) of
       atx_inst: begin
                  n:=0;
                  For i:=Nline+1 to Memo.Lines.Count-1 do
                  if Memo.Lines[i]<>'' then inc(n);
                  Memo.Lines[NLine]:=ReplaceWord(s,2,IntToStr(n));
                 end;
    atx_texture: Memo.Lines[nLine]:=ReplaceWord(s,2,ResPicker.PickTexture(GetWordN(s,2)));
 atx_startSound: begin
                  w:=ChangeFileExt(GetWordN(s,3),'.wav');
                  w:=ChangeFileExt(ResPicker.PickSound(w),'');
                  Memo.Lines[nLine]:=ReplaceWord(s,3,w);
                 end; 
 id_unknown:;
end;
end;

Procedure TScriptEdit.ATXLoad(const name:String);
begin
 if not LoadTemplates('ATXTEMPL.OLT')
 then begin ClearTemplates; AddTemplate('Simple ATX','ATX 1.0'#13#10#13#10'INST 1'#13#10#9'TEXTURE DEFAULT.PCX'); end;
end;

Procedure TScriptEdit.PHYLoad(const name:String);
begin
 if not LoadTemplates('PHYTEMPL.OLT')
 then begin ClearTemplates;  ClearTemplates;
 AddTemplate('Typical Physics','PHYS 1.0'#13#10+
   'ACCEL X: 200.0 Y: 50.0 Z: 200.0'#13#10+
   'DECEL X: 80.0  Y: 120.0 Z: 80.0'#13#10+
   'MAX_VEL: 30.0'#13#10+
   'JUMP_VEL: 20.0'#13#10+
   'STEP_HEIGHT: 3.0'#13#10+
   'STEP_SPEED: 25.0'#13#10#13#10+
   'BODY_YAW_RATE: 150.0'#13#10+
   'HEAD_YAW_RATE: 500.0'#13#10+
   'HEAD_YAW_LOOK_BACK_RATE: 800.0'#13#10+
   'HEAD_YAW_RETURN_RATE: 300.0'#13#10#13#10+
   'PITCH_RATE: 160.0'#13#10#13#10+
   'OFF_GROUND_ABILITY:  0.2');
 end;
end;


procedure TScriptEdit.FormCreate(Sender: TObject);
begin
 if ScriptOnTop then FormStyle:=fsStayOnTop;
 Templates:=TStringList.Create;
 AtxKeyWords:=TKeyWordList.Create;
With ATXKeyWords do
begin
 AddKeyWord('TEXTURE',atx_texture);
 AddKeyWord('START_SOUND',atx_startSound);
 AddKeyWord('STOP',atx_stop);
 AddKeyWord('GOTO',atx_goto);
 AddKeyWord('RATE',atx_rate);
 AddKeyWord('INST',atx_inst);
 AddKeyWord('ATX',atx_atx);
end;
INFKeyWords:=TKeyWordList.Create;
With INFKeyWords do
begin
 AddKeyWord('INF',inf_inf);
 AddKeyWord('LEVELNAME',inf_levelname);
 AddKeyWord('ITEMS',inf_items);
 AddKeyWord('ITEM:',inf_item);
 AddKeyWord('SEQ',inf_seq);
 AddKeyWord('CLASS:',inf_class);
 AddKeyWord('SPEED:',inf_speed);
 AddKeyWord('ANGLE:',inf_angle);
 AddKeyWord('SEQEND',inf_seqend);
 AddKeyWord('STOP:',inf_stop);
 AddKeyWord('SOUND:',inf_sound);
 AddKeyWord('MESSAGE:',inf_message);
 AddKeyWord('CENTER:',inf_center);
 AddKeyWord('EVENT_MASK:',inf_eventmask);
 AddKeyWord('EVENT:',inf_event);
 AddKeyWord('CLIENT:',inf_client);
 AddKeyWord('ENTITY_MASK:',inf_entitymask);
 AddKeyWord('OBJECT:',inf_object);
 AddKeyWord('OBJECT_EXCLUDE:',inf_objectexclude);
 AddKeyWord('MASTER:',inf_master);
 AddKeyWord('SLAVE:',inf_slave);
 INFMsgs:=TKeyWordList.Create;

 With InfMsgs do
 begin
  AddKeyWord('NEXT_STOP',inf_next_stop);
  AddKeyWord('PREV_STOP',inf_prev_stop);
  AddKeyWord('GOTO_STOP',inf_goto_stop);
  AddKeyWord('DONE',inf_done);
  AddKeyWord('MASTER_ON',inf_master_on);
  AddKeyWord('MASTER_OFF',inf_master_off);
  AddKeyWord('SET_BITS',inf_set_bits);
  AddKeyWord('CLEAR_BITS',inf_clear_bits);
  AddKeyWord('USER_MSG',inf_user_msg);
  AddKeyWord('SPAWN_LEVEL',inf_spawn_level);
  AddKeyWord('END_LEVEL',inf_end_level);
  AddKeyWord('TRIGGER_MOVIE',inf_trigger_movie);
 end;
RCPKeyWords:=TKeyWordList.Create;
With RCPKeyWords do
begin
 AddKeyWord('RCP',rcp_rcp);
 AddKeyWord('NAME:',rcp_name);
 AddKeyWord('MODES:',rcp_modes);
 AddKeyWord('STORY:',rcp_story);
 AddKeyWord('BEGIN',rcp_begin);
 AddKeyWord('END',rcp_end);
 AddKeyWord('LEVEL:',rcp_level);
 AddKeyWord('FLAGS:',rcp_flags);
 AddKeyWord('MOVIE:',rcp_movie);
 AddKeyWord('PATHS:',rcp_paths);
 AddKeyWord('CREDITS:',rcp_credits);
 AddKeyWord('TEXT:',rcp_text);
end;

ITMKeyWords:=TKeyWordList.Create;
With ITMKeyWords do
begin
 AddKeyWord('ITEM',itm_item);
AddKeyWord('FUNC',itm_func);
AddKeyWord('ANIM',itm_anim);
AddKeyWord('PRELOAD:',itm_preload);
AddKeyWord('DATA',itm_data);

AddKeyWord('FLOAT',itm_float);
AddKeyWord('INT',itm_int);
AddKeyWord('STR',itm_str);
end;

STRKeyWords:=TKeyWordList.Create;
With STRKeyWords do
begin
 AddKeyWord('ACTION_SOUND_1',str_ACTION_SOUND_1);
 AddKeyWord('ACTION_SOUND_2',str_ACTION_SOUND_2);
 AddKeyWord('ALERT_TAUNTS',str_ALERT_TAUNTS);
 AddKeyWord('AMMO',str_AMMO);
 AddKeyWord('AMMO_2',str_AMMO_2);
 AddKeyWord('BOSS',str_BOSS);
 AddKeyWord('DEAD_ITEM',str_DEAD_ITEM);
 AddKeyWord('DEFSND_PICKUP',str_DEFSND_PICKUP);
 AddKeyWord('DIE_SOUND',str_DIE_SOUND);
 AddKeyWord('DROP_ITEM',str_DROP_ITEM);
 AddKeyWord('EXPLOSION',str_EXPLOSION);
 AddKeyWord('EXPLODE_SOUND',str_EXPLODE_SOUND);
 AddKeyWord('FIRE_SOUND_1',str_FIRE_SOUND_1);
 AddKeyWord('FIRE_SOUND_2',str_FIRE_SOUND_2);
 AddKeyWord('FUSE_SOUND',str_FUSE_SOUND);
 AddKeyWord('GENERATE',str_GENERATE);
 AddKeyWord('GROUND_ITEM',str_GROUND_ITEM);
 AddKeyWord('HIT_SOUND',str_HIT_SOUND);
 AddKeyWord('ITEM_CLASS',str_ITEM_CLASS);
 AddKeyWord('ITEM_CLASS1',str_ITEM_CLASS1);
 AddKeyWord('LOS',str_LOS);
 AddKeyWord('LOS_TAUNTS',str_LOS_TAUNTS);
 AddKeyWord('MASTER',str_MASTER);
 AddKeyWord('NO_AMMO_SOUND_1',str_NO_AMMO_SOUND_1);
 AddKeyWord('NO_AMMO_SOUND_2',str_NO_AMMO_SOUND_2);
 AddKeyWord('NO_LOS_TAUNTS',str_NO_LOS_TAUNTS);
 AddKeyWord('OPEN1',str_OPEN1);
 AddKeyWord('PC_0',str_PC_0);
 AddKeyWord('P_MSG',str_P_MSG);
 AddKeyWord('P_MSG_TO',str_P_MSG_TO);
 AddKeyWord('PICKUP',str_PICKUP);
 AddKeyWord('PICKUP1',str_PICKUP1);
 AddKeyWord('PICKUP2',str_PICKUP2);
 AddKeyWord('PICKUP_SOUND',str_PICKUP_SOUND);
 AddKeyWord('PLAYER_WAX',str_PLAYER_WAX);
 AddKeyWord('PROJECTILE',str_PROJECTILE);
 AddKeyWord('RELOAD_SOUND',str_RELOAD_SOUND);
 AddKeyWord('SCOPE_ITEM',str_SCOPE_ITEM);
 AddKeyWord('SHOOT_SOUND',str_SHOOT_SOUND);
 AddKeyWord('SND_ARMOR1HIT',str_SND_ARMOR1HIT);
 AddKeyWord('SND_ARMOR2HIT',str_SND_ARMOR2HIT);
 AddKeyWord('SND_ARMOR3HIT',str_SND_ARMOR3HIT);
 AddKeyWord('SND_CHOKE',str_SND_CHOKE);
 AddKeyWord('SND_CRUNCH',str_SND_CRUNCH);
 AddKeyWord('SND_CRUSH',str_SND_CRUSH);
 AddKeyWord('SND_DIE',str_SND_DIE);
 AddKeyWord('SND_GASP',str_SND_GASP);
 AddKeyWord('SND_GOTSHOT',str_SND_GOTSHOT);
 AddKeyWord('SND_HITHEAD',str_SND_HITHEAD);
 AddKeyWord('SND_JUMP',str_SND_JUMP);
 AddKeyWord('SND_LAND',str_SND_LAND);
 AddKeyWord('SND_LANDLT',str_SND_LANDLT);
 AddKeyWord('SND_LIGHTLAMP',str_SND_LIGHTLAMP);
 AddKeyWord('SND_SHRIEK',str_SND_SHRIEK);
 AddKeyWord('SND_SPLASH',str_SND_SPLASH);
 AddKeyWord('SND_SPLAT',str_SND_SPLAT);
 AddKeyWord('SND_TIRED',str_SND_TIRED);
 AddKeyWord('SND_WATERDIE',str_SND_WATERDIE);
 AddKeyWord('SOUND_0',str_SOUND_0);
 AddKeyWord('START_ITEM_1',str_START_ITEM_1);
 AddKeyWord('THROW_ITEM',str_THROW_ITEM);
 AddKeyWord('TAUNT_TYPE',str_TAUNT_TYPE);
 AddKeyWord('TYPE',str_TYPE);
 AddKeyWord('SND_USE_F',str_SND_USE_F);
 AddKeyWord('SND_USE_S',str_SND_USE_S);
 AddKeyWord('WEAPON',str_WEAPON);
 AddKeyWord('WEAPON_1',str_WEAPON_1);
end;

IntKeyWords:=TKeyWordList.Create;
With IntKeyWords do
begin
 AddKeyWord('PICKUP_MSG',int_PICKUP_MSG);
end;

end;

ResetMemo;
end;

procedure TScriptEdit.FormDestroy(Sender: TObject);
begin
 Templates.Free;
 AtxKeyWords.Free;
 INFKeyWords.Free;
 ITMKeyWords.Free;
 RCPKeyWords.Free;
 STRKeyWords.Free;
 GetFont(scFont,Memo.Font);
end;

procedure TScriptEdit.SelectAllClick(Sender: TObject);
var mask:Integer;
begin
 Memo.SelectAll;
end;

Procedure TScriptEdit.INFLoad(const name:String);
begin
 If Not LoadTemplates('INFTEMPL.olt') then
 begin
 ClearTemplates;
 AddTemplate('Simple INF','INF 1.0'#13#10+
             'LEVELNAME UNTITLED'#13#10+
             'ITEMS 100'#13#10+
             'ITEM: SECTOR'#9'NAME: ELEV1'#13#10+
             'SEQ'#13#10+
             #9'CLASS: ELEVATOR MOVE_FLOOR'#13#10+
             #9'SOUND: 1 0'#13#10+
             #9'SOUND: 2 0'#13#10+
             #9'SOUND: 3 0'#13#10+
             #9'EVENT_MASK: 32'#13#10+
             #9'ENTITY_MASK: *'#13#10+
             #9'SPEED: 30'#13#10+
             'SEQEND'#13#10);
 end;
end;

Procedure TScriptEdit.RCSLoad(const name:String);
begin
 If Not LoadTemplates('RCSTEMPL.olt') then
 begin
 ClearTemplates;
 AddTemplate('Simple RCS','RCP 1.0'#13#10+
             'NAME: Outlaws Story'#13#10+
             'FLAGS: 0'#13#10#13#10+
             'STORY:'#13#10+
             'BEGIN'#13#10+
	     ' LEVEL: HIDEOUT'#13#10+
             'END'#13#10#13#10+
             'PATHS:  0');
 end;
end;

Procedure TScriptEdit.RCALoad(const name:String);
begin
 If Not LoadTemplates('RCATEMPL.olt') then
 begin
 ClearTemplates;
 AddTemplate('Simple RCA','RCP 1.0'#13#10+
             'NAME: Marshal Training'#13#10+
             'FLAGS: 0'#13#10#13#10+
             'STORY:'#13#10+
             'BEGIN'#13#10+
	     ' LEVEL: HIDEOUT'#13#10+
             'END'#13#10#13#10+
             'PATHS:  0');
 end;
end;

Procedure TScriptEdit.RCMLoad(const name:String);
begin
 If Not LoadTemplates('RCMTEMPL.olt') then
 begin
 ClearTemplates;
 AddTemplate('Simple RCM','RCP 1.0'#13#10+
             'NAME: Multiplayer level'#13#10+
             'MODES: CKMD'#13#10#13#10+
             'STORY:'#13#10+
             'BEGIN'#13#10+
	     ' LEVEL: HIDEOUT'#13#10+
             'END'#13#10#13#10);
 end;
end;

Procedure TScriptEdit.ITMLoad(const name:String);
begin
 If Not LoadTemplates('ITMTEMPL.olt') then
 begin
 ClearTemplates;
 AddTemplate('Simple ITM','ITEM 1.0'#13#10+
             'NAME Untitled'#13#10+
             'FUNC NULL'#13#10+
             'ANIM cactus01.nwx'#13#10+
             'DATA 1');
 end;
end;

Procedure TScriptEdit.ITMAssist(NLine,NChar:Integer);
var s,w:String;

Procedure ITM_EditSTR;
var p:integer;
begin
w:=GetWordN(s,2);
Case STRKeyWords.Get(w) of
str_ACTION_SOUND_1,
str_ACTION_SOUND_2,
str_DEFSND_PICKUP,
str_EXPLODE_SOUND,
str_FIRE_SOUND_1,
str_FIRE_SOUND_2,
str_FUSE_SOUND,
str_NO_AMMO_SOUND_1,
str_NO_AMMO_SOUND_2,
str_PICKUP_SOUND,
str_RELOAD_SOUND,
str_SOUND_0,
str_SND_USE_F,
str_SND_USE_S: Memo.Lines[NLine]:=ReplaceWord(s,3,ChangeFileExt(ResPicker.PickSound(GetWordN(s,3)),'')); {Sounds - no extension}

str_DIE_SOUND,
str_HIT_SOUND,
str_SHOOT_SOUND,
str_SND_ARMOR1HIT,
str_SND_ARMOR2HIT,
str_SND_ARMOR3HIT,
str_SND_CHOKE,
str_SND_CRUNCH,
str_SND_CRUSH,
str_SND_DIE,
str_SND_GASP,
str_SND_GOTSHOT,
str_SND_HITHEAD,
str_SND_JUMP,
str_SND_LAND,
str_SND_LANDLT,
str_SND_LIGHTLAMP,
str_SND_SHRIEK,
str_SND_SPLASH,
str_SND_SPLAT,
str_SND_TIRED,
str_SND_WATERDIE: Memo.Lines[NLine]:=ReplaceWord(s,3,ResPicker.PickSound(GetWordN(s,3))); {Sounds - extension}

str_ALERT_TAUNTS,
str_LOS_TAUNTS,
str_NO_LOS_TAUNTS:begin
                   p:=ScanForNonSpace(s,1);
                   p:=ScanForSpace(s,p);
                   p:=ScanForNonSpace(s,p);
                   p:=ScanForSpace(s,p);
                   p:=ScanForNonSpace(s,p);
                   w:=Copy(s,p,length(s)-p+1);
                   w:=ResPicker.PickTaunts(w);
                   Memo.Lines[NLine]:=Copy(s,1,p-1)+w;
                  end;
                        {Taunts}

str_AMMO,
str_AMMO_2,
str_GROUND_ITEM,
str_PICKUP,
str_PICKUP1,
str_PICKUP2,
str_SCOPE_ITEM,
str_START_ITEM_1,
str_WEAPON,
str_WEAPON_1,
str_PROJECTILE,
str_PC_0: Memo.Lines[NLine]:=ReplaceWord(s,3,ChangeFileExt(ResPicker.PickItem(GetWordN(s,3)),'')); {ITMs}

str_DEAD_ITEM,
str_THROW_ITEM: Memo.Lines[NLine]:=ReplaceWord(s,3,ResPicker.PickItem(GetWordN(s,3))); {ITM with extension}

str_DROP_ITEM: Memo.Lines[NLine]:=ReplaceWord(s,3,ResPicker.PickDropItem(GetWordN(s,3))); {ITM, NWX}

str_GENERATE: Memo.Lines[NLine]:=ReplaceWord(s,3,ResPicker.PickGeneratee(GetWordN(s,3))); {ITM, NWX, WAV}


str_EXPLOSION,
str_PLAYER_WAX: Memo.Lines[NLine]:=ReplaceWord(s,3,ResPicker.PickNWX(GetWordN(s,3))); {NWX}

str_BOSS,
str_LOS,
str_MASTER:; {TRUE/False}

str_ITEM_CLASS,
str_ITEM_CLASS1: PickFromMenu(item_classes) ; {Classes}
{amo(ammunition), amr(armor),badg(badge -eg: historical marshal),
 fuel(fuel -eg:oil)), gbar(gold bar), gsak(gold sack),
 heal(health -eg: canteen), key(key -eg: brasskey),
 puzz(puzzle -eg: gears), weap(weapons), heal, powr,
 MP: ball, flag, docu, }


str_OPEN1: Memo.Lines[NLine]:=ReplaceWord(s,3,ResPicker.PickMovie(GetWordN(s,3))); {Movie}
str_P_MSG: PickFromMenu(InfMessageMenu); {Message}
str_P_MSG_TO: Memo.Lines[NLine]:=ReplaceWord(s,3,ResPicker.PickSectorName(GetWordN(s,3))); {Sector name}
str_TAUNT_TYPE: PickFromMenu(Taunt_types); {SIMMS,TOWN,TRAIN,CLIFF,MINE}
str_TYPE: PickFromMenu(types_menu);{Gen: ITEM, ENEMY, AMB_SOUND, POINT_SOUND; Node_New: HIDE, NAV; Inv_Object: SHOOT, NUDGE}
end;
end;

Procedure Itm_editINT;
var i,p:integer;
begin
w:=GetWordN(s,2);
Case INTKeyWords.Get(w) of
 int_Pickup_msg: begin
                  ValInt(GetWordN(s,3),i);
                  i:=MsgPicker.PickMsg(i);
                  Memo.Lines[NLine]:=ReplaceWord(s,3,IntToStr(i));
                 end;
end;
end;

begin {ITMAssist}
 s:=Memo.Lines[NLine];
 GetWord(s,1,w);
 Case ITMKeyWords.Get(w) of
  itm_Item:;
  itm_func: PickFromMenu(ITM_Funcs);
  itm_preload: Memo.Lines[NLine]:=ReplaceWord(s,2,ResPicker.PickCHK(GetWordN(s,2)));
  itm_data:;
  itm_Float:;
  itm_int: Itm_editINT;
  itm_str: Itm_EditSTR;
  itm_anim:Memo.Lines[NLine]:=ReplaceWord(s,2,ResPicker.PickANIM(GetWordN(s,2)));
 end;
end;


Procedure TScriptEdit.INFAssist(NLine,NChar:Integer);
var s,w:string;
    f:longint;
    i,n:integer;
    MsgPos:integer;
begin
 s:=Memo.Lines[NLine];
 GetWord(s,1,w);
 Case INFKeyWords.Get(w) of
     inf_inf: Memo.Lines[NLine]:=ReplaceWord(s,2,'1.0');
   {  inf_levelname=1;}
     inf_items: begin
                 n:=0;
                 for i:=0 to Memo.Lines.Count-1 do
                 begin
                  GetWord(Memo.Lines[i],1,w);
                  if w='ITEM:' then Inc(n);
                 end;
                 n:=((n div 100)+1)*100;
                 Memo.Lines[Nline]:=ReplaceWord(s,2,IntToStr(n));
                end;
      inf_item: begin
                 w:=GetWordN(s,4);
                 Memo.Lines[Nline]:=ReplaceWord(s,4,ResPicker.PickSectorName(w));
                end;
 {    inf_seq=4;}
     inf_class: PickFromMenu(InfClassMenu);
{     inf_speed=6;
     inf_angle=7;
     inf_seqend=8;
     inf_stop=9;  }
     inf_sound: Memo.Lines[Nline]:=ReplaceWord(s,3,ResPicker.PickSound(GetWordN(s,3)));
   inf_message: begin
                 s:=Memo.Lines[Nline];
                 if ValInt(GetWordN(s,2),i) then MsgPos:=4 else MsgPos:=2;
                 i:=PosToNWord(s,NChar);
                 if i=MsgPos then PickFromMenu(InfMessageMenu);
                 if (MsgPos=4) and (i=MsgPos-1) then
                 begin
                  w:=GetWordN(s,MsgPos-1);
                  Memo.Lines[NLine]:=ReplaceWord(s,MsgPos-1,ResPicker.PickSectorName(w));
                 end;
                 if i>MsgPos then begin EditInfMsgParams(s); Memo.Lines[NLine]:=s; end;
                end;
{     inf_center=12;}
 inf_eventmask,inf_event:
                begin
                 f:=StrToDword(GetWordN(s,2));
                 Memo.Lines[Nline]:=ReplaceWord(s,2,DwordToStr(FlagEdit.EditEventMask(f)));
                end;
     inf_client,inf_slave: begin
                  w:=GetWordN(s,2);
                  Memo.Lines[NLine]:=ReplaceWord(s,2,ResPicker.PickSectorName(w));
                 end;
 inf_entitymask: begin
                  w:=GetWordN(s,2);
                  if w='*' then f:=-1 else f:=StrToDword(w);
                  f:=FlagEdit.EditEntityMask(f);
                  if f=-1 then w:='*' else w:=DwordToStr(f);
                  Memo.Lines[Nline]:=ReplaceWord(s,2,w);
                 end;
     inf_object,
     inf_objectexclude:
                 begin
                  w:=GetWordN(s,2);
                  Memo.Lines[Nline]:=ReplaceWord(s,2,ResPicker.PickItemID(w));
                 end;

    { inf_master=18;}
end;
end;

procedure TScriptEdit.InfClassClick(Sender: TObject);
var s:String;
begin
 s:=Memo.Lines[CurLine];
 With (Sender as TmenuItem) do
 begin
  if GroupIndex=0 then s:=ReplaceWord(s,2,'ELEVATOR')
  else s:=ReplaceWord(s,2,'TRIGGER');
  s:=ReplaceWord(s,3,Hint);
 end;
 Memo.Lines[CurLine]:=s;
end;

procedure TScriptEdit.InfMsgClick(Sender: TObject);
var s,w:string;
    msgPos,i:Integer;
    f:longint;
begin
With Sender as TMenuItem do
begin
 s:=Memo.Lines[CurLine];

 if scType=sc_ITM then
 begin
  s:=ReplaceWord(s,3,Hint);
  EditInfMSgParams(s);
  Memo.Lines[CurLine]:=s;
  exit;
 end;

 if ValInt(GetWordN(s,2),i) then
 begin
  MsgPos:=4;
  if GroupIndex=1 then s:=ReplaceWord(s,3,'SYSTEM');
 end else MsgPos:=2;
 s:=ReplaceWord(s,MsgPos,Hint);
 EditInfMSgParams(s);
 Memo.Lines[CurLine]:=s;
end;
end;

procedure TScriptEdit.Find1Click(Sender: TObject);
begin
 FindDialog.Execute;
end;

procedure TScriptEdit.FindDialogFind(Sender: TObject);
var pos:integer;
 ts:TSearchTypes;
begin
 ts:=[];
 if frMatchCase in FindDialog.Options then include(ts,stMatchCase);
 pos:=Memo.FindText(FindDialog.FindText,Memo.SelStart+Memo.SelLength,Memo.GetTextLen,ts);
 if pos=-1 then MsgBox('Text not found','Not found',mb_ok)
 else
 begin
  Memo.SelStart:=pos;
  Memo.SelLength:=Length(FindDialog.FindText);
  SendMessage(Memo.Handle,Messages.EM_SCROLLCARET,0,0);
 end;
end;

Procedure TScriptEdit.EditInfMsgParams(var s:string);
var MsgPos,i:integer;
    f:longint;
begin
 if scType=sc_ITM then MsgPos:=3
 else if ValInt(GetWordN(s,2),i) then MsgPos:=4 else MsgPos:=2;

 Case INFMsgs.Get(GetWordN(s,MsgPos)) of
 inf_set_bits,inf_clear_bits:
  begin
   ValDWord(GetWordN(s,MsgPos+2),f);
   If Pos('(',GetWordN(s,MsgPos-1))<>0 then f:=FlagEdit.EditWallFlags(f)
   else f:=FlagEdit.EditSectorFlags(f);
   s:=ReplaceWord(s,MsgPos+1,'1');
   s:=ReplaceWord(s,MsgPos+2,DwordToStr(f));
  end;
 inf_user_msg: begin
                ValInt(GetWordN(s,MsgPos+1),i);
                i:=MsgPicker.PickMsg(i);
                s:=ReplaceWord(s,MsgPos+1,IntToStr(i));;
               end;
 inf_spawn_level: s:=ReplaceWord(s,MsgPos+1,ResPicker.PickLevel(GetWordN(s,MsgPos+1)));
 inf_trigger_movie: s:=ReplaceWord(s,MsgPos+1,ResPicker.PickMovie(GetWordN(s,MsgPos+1)));
 end;
end;

Procedure TScriptEdit.RCPAssist(NLine,NChar:Integer);
var s,w:string;
    i,n:Integer;
    f:longint;
Const
     f_ctf=1;
     f_tag=2;
     f_kfc=4;
     f_doc=8;
     f_team=16;
     f_dm=32;

begin
 s:=Memo.Lines[Nline];
 GetWord(s,1,w);
 Case RCPKeyWords.Get(w) of
  rcp_rcp:;
  rcp_name:;
  rcp_modes:begin
             f:=0;
             w:=UpperCase(GetWordN(s,2));
             if Pos('C',w)<>0 then f:=f or f_ctf;
             if Pos('T',w)<>0 then f:=f or f_tag;
             if Pos('K',w)<>0 then f:=f or f_kfc;
             if Pos('S',w)<>0 then f:=f or f_doc;
             if Pos('M',w)<>0 then f:=f or f_team;
             if Pos('D',w)<>0 then f:=f or f_dm;
             f:=FlagEdit.EditMPModes(f);
             w:='';
             if (f and f_ctf)<>0 then w:=w+'C';
             if (f and f_tag)<>0 then w:=w+'T';
             if (f and f_kfc)<>0 then w:=w+'K';
             if (f and f_doc)<>0 then w:=w+'S';
             if (f and f_team)<>0 then w:=w+'M';
             if (f and f_dm)<>0 then w:=w+'D';
             Memo.Lines[Nline]:=ReplaceWord(s,2,w);
            end;
  rcp_story:;
  rcp_begin:;
  rcp_end:;
  rcp_level:Memo.Lines[Nline]:=ReplaceWord(s,2,ResPicker.PickLevel(GetWordN(s,2)));
  rcp_flags:{ begin
              f:=StrToDword(GetWordN(s,2));
              Memo.Lines[Nline]:=ReplaceWord(s,2,DwordToStr(FlagEdit.EditLevelITMFlags(f)));
             end};
  rcp_movie,rcp_credits: Memo.Lines[Nline]:=ReplaceWord(s,2,ResPicker.PickMovie(GetWordN(s,2)));
  rcp_paths:;
  rcp_text: Memo.Lines[Nline]:=ReplaceWord(s,2,ResPicker.PickTXT(GetWordN(s,2)));

 end;
end;


procedure TScriptEdit.FormShow(Sender: TObject);
begin
 Memo.Modified:=false;
 SetFont(Memo.Font,scFont);
end;

procedure TScriptEdit.OptionsMenuClick(Sender: TObject);
begin
 Options.SetOptions(Options.Misc);
 SetFont(Memo.Font,ScFont);
 if ScriptOnTop then FormStyle:=fsStayOnTop
  else FormStyle:=fsNormal;
 ResetMemo;
end;

Procedure TScriptEdit.ResetMemo;
begin
 SendMessage(Memo.Handle,EM_SETEVENTMASK,0,
  SendMessage(Memo.Handle,EM_GETEVENTMASK,0,0) or ENM_MOUSEEVENTS);
end;

procedure TScriptEdit.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
 SavePrevious;
 CanClose:=true;
end;

Procedure TScriptEdit.OpenScript(const Name:String);
begin
 Show;
 if Not SavePrevious then exit;
 if (not IsInContainer(Name)) and (not FileExists(Name)) then CreateScript(Name,GetScriptType(Name))
 else LoadScript(Name);
end;

Procedure TScriptEdit.CHKAssist(NLine,NChar:Integer);
var s,w1,w2:String;
begin
  s:=Memo.Lines[Nline];
  GetWord(s,GetWord(s,1,w1),w2);
  w2:=ResPicker.PickForCHK(w2);
  s:=ReplaceWord(s,1,DWordToStr(Longint(GetLABResType(w2))));
  Memo.Lines[NLine]:=ReplaceWord(s,2,w2);
end;

Procedure TScriptEdit.CHKLoad(const name:String);
var t:TFile;ps:Pchar;
begin
 ClearTemplates;
 if FileExists(BaseDir+'LmData\usrlevel.chk') then
 t:=OpenFileRead(BaseDir+'LmData\usrlevel.chk',0)
 else t:=OpenFileRead(BaseDir+'usrlevel.chk',0);
 ps:=StrAlloc(t.FSize+1);
 t.Fread(ps^,t.Fsize);
 (ps+t.Fsize)^:=#0;
 t.Fclose;
 AddTemplate('Simple CHK',ps);
 StrDispose(ps);
end;

Procedure TScriptEdit.MSCLoad(const name:String);
begin
 if not LoadTemplates('MSCTEMPL.OLT')
 then begin ClearTemplates;
  AddTemplate('Simple MSC','MSC 1.0'#13#10+
  'FLAGS: 0'#13#10#13#10+
  'START_CUE: 1'#13#10+
  'CUES: 1'#13#10+
  'CUE 1'#13#10+
  'BEGIN'#13#10+
  'CD_TRACK OUTLAWS_1 1'#13#10+
  'GOTO_CUE 1'#13#10+
  'END');
 end;
end;

procedure TScriptEdit.FuncClick(Sender: TObject);
var s:string;
begin
 s:=Memo.Lines[CurLine];
 Memo.Lines[CurLine]:=ReplaceWord(s,2,(Sender as TMenuItem).Hint);
end;

procedure TScriptEdit.Help2Click(Sender: TObject);
begin
 Application.HelpJump('Hlp_Script_Editor');
end;

procedure TScriptEdit.Item_class_click(Sender: TObject);
var s:String;
begin
 s:=Memo.Lines[CurLine];
 Memo.Lines[CurLine]:=ReplaceWord(s,3,(Sender as TMenuItem).Hint);
end;

procedure TScriptEdit.taunt_type_click(Sender: TObject);
var s:String;
begin
 s:=Memo.Lines[CurLine];
 Memo.Lines[CurLine]:=ReplaceWord(s,3,(Sender as TMenuItem).Hint);
end;

procedure TScriptEdit.types_click(Sender: TObject);
var s:String;
begin
 s:=Memo.Lines[CurLine];
 Memo.Lines[CurLine]:=ReplaceWord(s,3,(Sender as TMenuItem).Hint);
end;

Function TScriptEdit.LoadTemplates(const Name:String):boolean;
var t:TextFile;
    s:String;
    sCut,Tname:String;
    Template:String;
    NoTemp:Boolean;
    Send:integer;

Procedure AddLastTemplate;
begin
 if NoTemp then exit;
 if SCut='' then AddTemplate(TName,Template)
 else AddTemplateKey(TName,Template,TextToShortCut(SCut));
end;

begin
Result:=true;
ClearTemplates;
Try
AssignFile(t,FindLMDataFile(Name));
Reset(t);
Try
Template:=''; NoTemp:=true;
While not eof(t) do
begin
 Readln(t,s);
 if (s<>'') and (s[1]='[') then
 begin
  AddLastTemplate;
  Send:=Pos(']',s); if Send=0 then Send:=Length(s) else Dec(Send);
  TName:=Copy(s,2,Send-1); SCut:=Trim(Copy(s,Send+2,Length(s)));
  NoTemp:=False;
  Template:='';
  Continue;
 end;
 if Template='' then Template:=Template+s
 else Template:=Template+#13#10+s;
end;
AddLastTemplate;

finally
 CloseFile(t);
end;
except
 On Exception do Result:=false;
end;

end;

end.
