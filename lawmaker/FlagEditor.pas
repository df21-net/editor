unit FlagEditor;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TFlagEdit = class(TForm)
    Bit0: TCheckBox;
    Bit1: TCheckBox;
    Bit2: TCheckBox;
    Bit3: TCheckBox;
    Bit4: TCheckBox;
    Bit5: TCheckBox;
    Bit6: TCheckBox;
    Bit7: TCheckBox;
    Bit8: TCheckBox;
    Bit9: TCheckBox;
    Bit10: TCheckBox;
    Bit11: TCheckBox;
    Bit12: TCheckBox;
    Bit13: TCheckBox;
    Bit14: TCheckBox;
    Bit15: TCheckBox;
    Bit16: TCheckBox;
    Bit17: TCheckBox;
    Bit18: TCheckBox;
    Bit19: TCheckBox;
    Bit20: TCheckBox;
    Bit21: TCheckBox;
    Bit22: TCheckBox;
    Bit23: TCheckBox;
    Bit24: TCheckBox;
    Bit25: TCheckBox;
    Bit26: TCheckBox;
    Bit27: TCheckBox;
    Bit28: TCheckBox;
    Bit29: TCheckBox;
    Bit30: TCheckBox;
    Bit31: TCheckBox;
    BNOK: TButton;
    BNCancel: TButton;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    Bits:Array[0..31] of TCheckBox;
    Procedure ClearNames;
    Procedure SetName(n:Byte;const Name:String);
    Procedure SetFlags(F:Longint);
    Function GetFlags:Longint;
  public
   Function EditSectorFlags(flags:LongInt):LongInt;
   Function EditWallFlags(flags:LongInt):LongInt;
   Function EditObjectFlags1(flags:LongInt):LongInt;
   Function EditObjectFlags2(flags:LongInt):LongInt;
   Function EditLevelITMFlags(flags:LongInt):LongInt;
   Function EditEventMask(flags:Longint):LongInt;
   Function EditEntityMask(flags:Longint):LongInt;
   Function EditMPModes(flags:Longint):LongInt;
    { Public declarations }
  end;

var
  FlagEdit: TFlagEdit;

implementation

{$R *.DFM}

Function FlagNum(n:Longint):Integer;
var f,i:Integer;
begin
 i:=0;
 f:=1;
 While n<>f do
 begin
  f:=f shl 1;
  inc(i);
 end;
 Result:=i;
end;

procedure TFlagEdit.FormCreate(Sender: TObject);
begin
 ClientWidth:=Bit0.Left+Bit16.Left+Bit16.Width;
 ClientHeight:=Bit0.Top+BNOK.Top+BNOK.Height;
 Bits[0]:=Bit0;
 Bits[1]:=Bit1;
 Bits[2]:=Bit2;
 Bits[3]:=Bit3;
 Bits[4]:=Bit4;
 Bits[5]:=Bit5;
 Bits[6]:=Bit6;
 Bits[7]:=Bit7;
 Bits[8]:=Bit8;
 Bits[9]:=Bit9;
 Bits[10]:=Bit10;
 Bits[11]:=Bit11;
 Bits[12]:=Bit12;
 Bits[13]:=Bit13;
 Bits[14]:=Bit14;
 Bits[15]:=Bit15;
 Bits[16]:=Bit16;
 Bits[17]:=Bit17;
 Bits[18]:=Bit18;
 Bits[19]:=Bit19;
 Bits[20]:=Bit20;
 Bits[21]:=Bit21;
 Bits[22]:=Bit22;
 Bits[23]:=Bit23;
 Bits[24]:=Bit24;
 Bits[25]:=Bit25;
 Bits[26]:=Bit26;
 Bits[27]:=Bit27;
 Bits[28]:=Bit28;
 Bits[29]:=Bit29;
 Bits[30]:=Bit30;
 Bits[31]:=Bit31;
end;

Procedure TFlagEdit.ClearNames;
var i:Integer;
begin
 for i:=0 to 31 do
  Bits[i].Caption:=Format('Unknown/Unused (Flag %d)',[i]);
end;

Procedure TFlagEdit.SetName(n:Byte;const Name:String);
begin
 Bits[n].Caption:=Name;
end;

Procedure TFlagEdit.SetFlags(F:Longint);
var i:Integer;
begin
 For i:=0 to 31 do
 bits[i].Checked:=(F and (1 shl i))<>0;
end;

Function TFlagEdit.GetFlags:Longint;
var i:Integer;
begin
 Result:=0;
 For i:=0 to 31 do
 if bits[i].Checked then Result:=Result or (1 shl i);
end;

Function TFlagEdit.EditMPModes(flags:Longint):LongInt;
begin
 ClearNames;
 SetName(0,'Capture the flag');
 SetName(1,'Tag');
 SetName(2,'Kill fool with chicken');
 SetName(3,'Secret doc');
 SetName(4,'Team Play');
 SetName(5,'Death match');
 SetFlags(flags);
 if ShowModal<>mrOK then Result:=flags else Result:=GetFlags;
end;


Function TFlagEdit.EditEntityMask(flags:Longint):LongInt;
begin
 ClearNames;
 SetName(0,'Enemy');
 SetName(3,'Weapon');
 SetName(31,'Player');
 SetFlags(flags);
 if ShowModal<>mrOK then Result:=flags else Result:=GetFlags;
end;

Function TFlagEdit.EditEventMask(flags:Longint):LongInt;
begin
 ClearNames;
 SetName(0,'Cross from inside');
 SetName(1,'Cross from outside');
 SetName(2,'Enter sector');
 SetName(3,'Leave sector');
 SetName(4,'Nudge from inside');
 SetName(5,'Nudge from outside');
 SetName(6,'Blow up');
{ SetName(7,'Shoot');}
 SetName(8,'Shoot');
 SetName(14,'NWX message');
 SetName(16,'Cutom event 1');
 SetName(17,'Cutom event 2');
 SetName(18,'Cutom event 3');
 SetName(19,'Cutom event 4');
 SetName(20,'Cutom event 5');
 SetName(21,'Cutom event 6');
 SetName(22,'Cutom event 7');
 SetName(23,'Cutom event 8');
 SetName(24,'Cutom event 9');
 SetName(25,'Cutom event 10');
 SetFlags(flags);
 if ShowModal<>mrOK then Result:=flags else Result:=GetFlags;
end;

Function TFlagEdit.EditSectorFlags(flags:LongInt):LongInt;
begin
 if FlagNum(1)=0 then;
 ClearNames;
 SetName(0,'SKY');
 SetName(1,'PIT');
 SetName(2,'SKY Adjoin');
 SetName(3,'PIT Adjoin');
 SetName(4,'No Walls');
 SetName(5,'No sliding on slope');
 SetName(6,'Velocity for floor only');
 SetName(7,'Underwater');
 SetName(8,'Door');
 SetName(9,'Door: reverse');
 SetName(12,'Secret Area');
 SetName(18,'Small Damage');
 SetName(19,'Large Damage');
 SetName(20,'Deadly Damage');
 SetName(21,'Small Floor Damage');
 SetName(22,'Large Floor Damage');
 SetName(23,'Deadly Floor Damage');
 SetName(24,'Dean Wermer Flag');
 SetName(25,'Secret tag');
 SetName(26,'Don''t shade floor');
 SetName(27,'Rail track pull chain');
 SetName(28,'Rail line');
 SetName(29,'Hide on map');
 SetName(30,'Floor sloped');
 SetName(31,'Ceiling sloped');
 SetFlags(flags);
 if ShowModal<>mrOK then Result:=flags else Result:=GetFlags;
end;

Function TFlagEdit.EditWallFlags(flags:LongInt):LongInt;
begin
 ClearNames;
 SetName(0,'Adjoining MID texture');
 SetName(1,'Illuminated sign');
 SetName(2,'Flip texture horizontally');
 SetName(3,'Wall texture anchored');
 SetName(4,'Sign anchored');
 SetName(5,'Tinting');
 SetName(6,'Morph with sector');
 SetName(7,'Scroll TOP texture');
 SetName(8,'Scroll MID texture');
 SetName(9,'Scroll BOT texture');
 SetName(10,'Scroll sign texture');
 SetName(11,'Non-passable');
 SetName(12,'Ignore height check');
 SetName(13,'Bad guys can''t pass');
 SetName(14,'Shatter');
 SetName(15,'Projectile can pass');
 SetName(16,'Not a rail');
 SetName(17,'Don''t show on map');
 SetName(18,'Never show on map');
 SetFlags(flags);
 if ShowModal<>mrOK then Result:=flags else Result:=GetFlags;
end;

Function TFlagEdit.EditObjectFlags1(flags:LongInt):LongInt;
begin
 ClearNames;
 SetName(0,'Sound');
 SetName(3,'3D Object');
 SetName(4,'Move at sector velocity');
 SetFlags(flags);
 if ShowModal<>mrOK then Result:=flags else Result:=GetFlags;
end;

Function TFlagEdit.EditObjectFlags2(flags:LongInt):LongInt;
begin
 ClearNames;
 SetName(21,'Multiple AI');
 SetName(22,'Present in DeathMatch');
 SetName(23,'Present in CTF');
 {SetName(24,'Present in TAG');}
 SetName(25,'Present in KFC');
 {SetName(26,'Present in Secret Doc');}
 SetName(27,'Present in Team Play');
 SetName(28,'Present on Good');
 SetName(29,'Present on Bad');
 {SetName(30,'Present on Advanced');}
 SetName(31,'Present on Ugly');
 SetFlags(flags);
 if ShowModal<>mrOK then Result:=flags else Result:=GetFlags;
end;

Function TFlagEdit.EditLevelITMFlags(flags:LongInt):LongInt;
begin
 ClearNames;
 SetName(0,'Dump weapons');
 SetName(1,'Dump ammo');
 SetName(2,'Dump health');
 SetName(3,'Dump oil');
 SetName(4,'Dump all');
 SetName(5,'Show score');
{ SetName(6,'Drop nonnative');}
 SetFlags(flags);
 if ShowModal<>mrOK then Result:=flags else Result:=GetFlags;
end;


end.
