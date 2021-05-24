unit I_util;

interface
uses SysUtils, WinTypes, WinProcs, Messages, Classes,
     StdCtrls, FileCtrl, Forms,
     _Strings, _Files, M_Global;

procedure FillINFSectorNames;
function  INFItemsToMemo(SC, WL : Integer; VAR Memo : TMemo) : Boolean;
function  MemoToINFItems(SC, WL : Integer; VAR Memo : TMemo) : Boolean;
function  ParseINFItemsSCWL(SC, WL : Integer; INFList : TStringList; VAR errmsg : String) : Integer;
function  ParseINFItems(TheINFItems, INFList : TStringList; VAR errmsg : String) : Integer;
function  FreeINFList(INFList : TStringList) : Boolean;
function  INFListToMemo(INFList : TStringList; VAR Memo : TMemo; Spruce, Comments : Boolean) : Boolean;
function  INFListToMemoByItem(INFList : TStringList; Num : Integer; VAR Memo : TMemo; Spruce, Comments : Boolean) : Boolean;
function  ComputeINFClasses(SC, WL : Integer) : Boolean;

implementation
uses InfEdit2, M_Editor;

procedure FillINFSectorNames;
var s         : Integer;
    TheSector : TSector;
begin
 INFWindow2.CBSectors.Clear;
 for s := 0 to MAP_SEC.Count - 1 do
  begin
   TheSector := TSector(MAP_SEC.Objects[s]);
   if TheSector.Name <> '' then INFWindow2.CBSectors.Items.Add(TheSector.Name);
  end;
 if INFWindow2.CBSectors.Items.Count <> 0 then
  INFWindow2.CBSectors.ItemIndex := 0;

 INFWindow2.CBAdjoinSC1.Items.Clear;
 INFWindow2.CBAdjoinSC1.Items.AddStrings(INFWindow2.CBSectors.Items);
 INFWindow2.CBAdjoinSC2.Items.Clear;
 INFWindow2.CBAdjoinSC2.Items.AddStrings(INFWindow2.CBSectors.Items);
 INFWindow2.CBMessageSC.Items.Clear;
 INFWindow2.CBMessageSC.Items.AddStrings(INFWindow2.CBSectors.Items);
 INFWindow2.CBChuteTarget.Items.Clear;
 INFWindow2.CBChuteTarget.Items.AddStrings(INFWindow2.CBSectors.Items);
 INFWindow2.LBTrigClients.Items.Clear;
 INFWindow2.LBTrigClients.Items.AddStrings(INFWindow2.CBSectors.Items);
 INFWindow2.LBElevSlaves.Items.Clear;
 INFWindow2.LBElevSlaves.Items.AddStrings(INFWindow2.CBSectors.Items);
 INFWindow2.CBStopValue.Items.Clear;
 INFWindow2.CBStopValue.Items.AddStrings(INFWindow2.CBSectors.Items);
 INFWindow2.CBTexture.Clear;
 INFWindow2.CBTexture.Items.AddStrings(INFWindow2.CBSectors.Items);
end;

function INFItemsToMemo(SC, WL : Integer; VAR Memo : TMemo) : Boolean;
var TheSector : TSector;
    TheWall   : TWall;
begin
Result := TRUE;
if WL = -1 then {sector}
 begin
  TheSector := TSector(MAP_SEC.Objects[SC]);
  Memo.Clear;
  Memo.Lines.AddStrings(TheSector.InfItems);
 end
else {wall}
 begin
  TheSector := TSector(MAP_SEC.Objects[SC]);
  TheWall := TWall(TheSector.Wl.Objects[WL]);
  Memo.Clear;
  Memo.Lines.AddStrings(TheWall.InfItems);
 end;
end;

function MemoToINFItems(SC, WL : Integer; VAR Memo : TMemo) : Boolean;
var TheSector : TSector;
    TheWall   : TWall;
begin
Result := TRUE;
if WL = -1 then {sector}
 begin
  TheSector := TSector(MAP_SEC.Objects[SC]);
  TheSector.InfItems.Clear;
  TheSector.InfItems.AddStrings(Memo.Lines);
 end
else {wall}
 begin
  TheSector := TSector(MAP_SEC.Objects[SC]);
  TheWall := TWall(TheSector.Wl.Objects[WL]);
  TheWall.InfItems.Clear;
  TheWall.InfItems.AddStrings(Memo.Lines);
 end;
end;

{ This function returns a TStringList containing the sequences
  of the INF items, those contain the classes, etc.
  The Integer return value is
   -2 if nothing to do (ie no INF action exists)
   -1 if parsing is ok
   0..linenumber is the line number of the error in parsing}

{
 NOTE: the syntax is checked, but not the values like
       sector name, wall name, voc name, text number in MSG file, etc
       Those are accepted "as is".
       This should become a separate routine for the consistancy
       checks, the routine acting on the already parsed items
       (easier, cleaner and allowing different level (and duration!)
       of checking)

       The wall *NAMES* should be computed in the first loading
       of the INF, and a mini parsing will still have to be done.
}

function ParseINFItemsSCWL(SC, WL  : Integer;
                           INFList : TStringList;
                           VAR errmsg : String) : Integer;
var TheSector    : TSector;
    TheWall      : TWall;
    TheINFItems  : TStringList;
begin
 TheINFItems := TStringList.Create;
 if WL = -1 then {sector}
  begin
   TheSector := TSector(MAP_SEC.Objects[SC]);
   TheINFItems.AddStrings(TheSector.INFItems);
  end
 else {wall}
  begin
   TheSector := TSector(MAP_SEC.Objects[SC]);
   TheWall := TWall(TheSector.Wl.Objects[WL]);
   TheINFItems.AddStrings(TheWall.INFItems);
  end;

 if TheINFItems.Count = 0 then
  Result := -2
 else
  Result := ParseINFItems(TheINFItems, INFList, errmsg);

 TheINFItems.Free;
end;

function ParseINFItems(TheINFItems : TStringList;
                       INFList : TStringList;
                       VAR errmsg : String) : Integer;
var TmpComments  : TStringList;
    TheINFSeq    : TINFSequence;
    TheINFCls    : TINFCls;
    TheINFStop   : TINFStop;
    TheINFAction : TINFAction;
    SeqBegun     : Boolean;
    ClassBegun   : Boolean;
    CurClsTyp    : Integer;
    i,j,k        : Integer;
    Comment      : Boolean;
    pars         : TStringParserWithColon;
    strin        : string;
    TheLong      : LongInt;
    TheReal      : Real;
    code         : Integer;
    addon        : Integer;
    elevok       : Boolean;
    elevskip     : Integer;
    msgok        : Boolean;
    tmpstopnum   : LongInt;
    tmpscwl      : String;
    tmpMsgType,
    tmpMsgParam1,
    tmpMsgParam2 : String[15];
begin
Result := -1;

if TheINFItems.Count = 0 then
 begin
  Result := -2;
  exit;
 end;

errmsg  := '';
Comment := FALSE;
TmpComments := TStringList.Create;
SeqBegun    := FALSE;
ClassBegun  := FALSE;
addon       := -1;

for i := 0 to TheINFItems.Count - 1 do
  begin
     strin := LTrim(TheINFItems[i]);

     if strin = '' then continue;

     if Pos('/*', strin) = 1 then
       begin
         TmpComments.Add(strin);
         if Pos('*/', strin) = 0 then Comment := TRUE;
       end
     else
     if Pos('*/', strin) <> 0 then
       begin
         TmpComments.Add(strin);
         Comment := FALSE;
       end
     else
     if Comment then
       begin
        TmpComments.Add(strin);
       end
     else
     if Pos('class:', LowerCase(strin)) = 1 then
       begin
        if not SeqBegun then
         begin
          errmsg := 'seq expected before class:';
          Result := i;
          TmpComments.Free;
          exit; { must not continue class, because of GPF if no seq allocated!}
         end;

        if ClassBegun then
         begin
          if addon = 0 then
           begin
            {ERROR }
            errmsg := 'addon: 1 not found';
           end;
          addon := -1;
          TheINFSeq.Classes.AddObject('CL', TheINFCls);
         end;

        TheINFCls := TINFCls.Create;
        with TheINFCls do
         begin
          Master      := '';
          Sound1      := '';
          Sound2      := '';
          Sound3      := '';
          Flags       := '';
          event       := '';
          event_mask  := '';
          entity_mask := '';
          key         := '';
          key1        := '';
          speed       := '';
          speed1      := '';
          angle       := '';
          centerX     := '';
          centerZ     := '';
         end;

        ClassBegun := TRUE;

        pars := TStringParserWithColon.Create(strin);
        if pars.Count > 2 then
         begin
          if pars[2] = 'elevator' then
           begin
            if pars.Count = 4 then
             begin
               if not (
                  (pars[3] = 'basic') or
                  (pars[3] = 'change_light') or
                  (pars[3] = 'change_wall_light') or
                  (pars[3] = 'door') or
                  (pars[3] = 'door_mid') or
                  (pars[3] = 'inv') or
                  (pars[3] = 'morph_move1') or
                  (pars[3] = 'morph_move2') or
                  (pars[3] = 'morph_spin1') or
                  (pars[3] = 'morph_spin2') or
                  (pars[3] = 'move_ceiling') or
                  (pars[3] = 'move_fc') or
                  (pars[3] = 'move_floor') or
                  (pars[3] = 'move_offset') or
                  (pars[3] = 'rotate_wall') or
                  (pars[3] = 'scroll_ceiling') or
                  (pars[3] = 'scroll_floor') or
                  (pars[3] = 'scroll_wall')) then
               begin
                {ERROR }
                errmsg := 'Invalid elevator type';
               end;
              with TheINFCls do
               begin
                ClsType := 0;
                ClsName := pars[3];
               end;
              CurClsTyp := 0;
             end
            else
             begin
              {ERROR }
              errmsg := 'Invalid elevator INF construction';
             end;
           end
          else
          if pars[2] = 'trigger' then
           begin
            if pars.Count = 3 then pars.Add('');
            if not (
                  (pars[3] = '') or
                  (pars[3] = 'single') or
                  (pars[3] = 'standard') or
                  (pars[3] = 'switch1') or
                  (pars[3] = 'toggle')) then
               begin
                {ERROR }
                errmsg := 'Invalid trigger type';
               end
            else
             begin
              with TheINFCls do
               begin
                ClsType := 1;
                ClsName := pars[3];
               end;
              CurClsTyp := 1;
             end;
           end
          else
          if pars[2] = 'teleporter' then
           begin
            if pars.Count = 4 then
             begin
              if pars[3] = 'chute' then
               begin
                with TheINFCls do
                 begin
                  ClsType := 2;
                  ClsName := 'chute';
                 end;
                CurClsTyp := 2;
               end
              else
               begin
                {ERROR }
                errmsg := 'Invalid teleporter chute INF construction';
               end;
             end
            else
             begin
              {ERROR }
              errmsg := 'Invalid teleporter chute INF construction';
             end;
           end
          else
           begin
            {ERROR }
            errmsg := 'class: must be elevator, trigger or teleporter chute';
           end;
         end
        else
         begin
          {ERROR }
          errmsg := 'Incomplete class INF construction';
         end;
        pars.Free;
       end
     else
     if Pos('master:', LowerCase(strin)) = 1 then
       begin
        CASE CurClsTyp OF
         0,1 : begin
                pars := TStringParserWithColon.Create(strin);
                if pars.Count = 3 then
                 begin
                  if (pars[2] = 'off') or (pars[2] = 'on') then
                   begin
                    TheINFCls.Master := pars[2];
                   end
                  else
                   begin
                    {ERROR }
                    errmsg := 'master: argument must be on or off';
                   end;
                 end
                else
                 begin
                  {ERROR }
                  errmsg := 'Invalid master: INF construction ';
                 end;
                pars.Free;
               end;
         2   : begin
                {ERROR  }
                errmsg := 'master: not allowed in teleporter chute';
               end;
        END;
       end
     else
     if Pos('event_mask:', LowerCase(strin)) = 1 then
       begin
        if CurClsTyp <> 2 then
         begin
          pars := TStringParserWithColon.Create(strin);
          if pars.Count = 3 then
           begin
            Val(pars[2], TheLong, code);
            if code = 0 then
             begin
              TheINFCls.event_mask := IntToStr(TheLong);
             end
            else
             begin
              {ERROR }
              errmsg := 'Value of event_mask: must be numeric';
             end;
           end
          else
           begin
            {ERROR }
            errmsg := 'Invalid event_mask: INF construction';
           end;
          pars.Free;
         end
        else
         begin
          {ERROR  }
          errmsg := 'event_mask: not allowed in teleporter chute';
         end;
       end
     else
     if Pos('event:', LowerCase(strin)) = 1 then
       begin
        if CurClsTyp = 1 then
         begin
          pars := TStringParserWithColon.Create(strin);
          if pars.Count = 3 then
           begin
            Val(pars[2], TheLong, code);
            if code = 0 then
             begin
              TheINFCls.event := IntToStr(TheLong);
             end
            else
             begin
              {ERROR }
              errmsg := 'Value of event: must be numeric';
             end;
           end
          else
           begin
            {ERROR }
            errmsg := 'Invalid event: INF construction';
           end;
          pars.Free;
         end
        else
         begin
          {ERROR  }
          errmsg := 'event: not allowed in elevator and teleporter chute';
         end;
       end
     else
     if Pos('entity_mask:', LowerCase(strin)) = 1 then
       begin
        if CurClsTyp <> 2 then
         begin
          pars := TStringParserWithColon.Create(strin);
          if pars.Count = 3 then
           begin
            if pars[2] = '*' then
             begin
              TheINFCls.entity_mask := '*';
             end
            else
             begin
              Val(pars[2], TheLong, code);
              if code = 0 then
               begin
                TheINFCls.entity_mask := IntToStr(TheLong);
               end
              else
               begin
                if (pars[2] = '2147483649') or
                   (pars[2] = '2147483656') or
                   (pars[2] = '2147483648') then
                 begin
                  {those values are acceptable}
                  TheINFCls.entity_mask := pars[2];
                 end
                else
                {ERROR }
                errmsg := 'Value of entity_mask: must be valid numeric or *';
               end;
             end;
           end
          else
           begin
            {ERROR }
            errmsg := 'Invalid entity_mask: INF construction';
           end;
          pars.Free;
         end
        else
         begin
          {ERROR  }
          errmsg := 'entity_mask: not allowed in teleporter chute';
         end;
       end
     else
     if Pos('speed:', LowerCase(strin)) = 1 then
       begin
        if CurClsTyp = 0 then
         begin
          pars := TStringParserWithColon.Create(strin);
          if pars.Count = 3 then
           begin
            Val(pars[2], TheReal, code);
            if code = 0 then
             begin
              if addon <> 1 then
               TheINFCls.speed := pars[2]
              else
               TheINFCls.speed1 := pars[2];
             end
            else
             begin
              {ERROR }
              errmsg := 'Value of speed: must be numeric';
             end;
           end
          else
           begin
            {ERROR }
            errmsg := 'Invalid speed: INF construction';
           end;
          pars.Free;
         end
        else
         begin
          {ERROR  }
          errmsg := 'speed: only allowed in elevators';
         end;
       end
     else
     if Pos('angle:', LowerCase(strin)) = 1 then
       begin
        if CurClsTyp = 0 then
         begin
          pars := TStringParserWithColon.Create(strin);
          if pars.Count = 3 then
           begin
            Val(pars[2], TheReal, code);
            if code = 0 then
             begin
              TheINFCls.angle := pars[2];
             end
            else
             begin
              {ERROR }
              errmsg := 'Invalid angle: value';
             end;
           end
          else
           begin
            {ERROR }
            errmsg := 'Invalid angle: INF construction';
           end;
          pars.Free;
         end
        else
         begin
          {ERROR }
          errmsg := 'angle: only allowed in elevators';
         end;
       end
     else
     if Pos('center:', LowerCase(strin)) = 1 then
       begin
        if CurClsTyp = 0 then
         begin
          pars := TStringParserWithColon.Create(strin);
          if pars.Count = 4 then
           begin
            Val(pars[2], TheReal, code);
            if code = 0 then
             begin
              TheINFCls.centerX := pars[2];
             end
            else
             begin
              {ERROR }
              errmsg := 'Invalid center: X value';
             end;
            Val(pars[3], TheReal, code);
            if code = 0 then
             begin
              TheINFCls.centerZ := pars[3];
             end
            else
             begin
              {ERROR }
              errmsg := 'Invalid center: Z value';
             end;
           end
          else
           begin
            {ERROR }
            errmsg := 'Invalid center: INF construction';
           end;
          pars.Free;
         end
        else
         begin
          {ERROR }
          errmsg := 'center: only allowed in elevators';
         end;
       end
     else
     if Pos('key:', LowerCase(strin)) = 1 then
       begin
        if CurClsTyp = 0 then
         begin
          pars := TStringParserWithColon.Create(strin);
          if pars.Count = 3 then
           begin
            if (pars[2] = 'blue') or (pars[2] = 'red') or (pars[2] = 'yellow') then
             begin
              if addon <> 1 then
               TheINFCls.key := pars[2]
              else
               TheINFCls.key1 := pars[2];
             end
            else
             begin
              {ERROR }
              errmsg := 'key: value must be blue, red or yellow';
             end;
           end
          else
           begin
            {ERROR }
            errmsg := 'Invalid key: INF construction';
           end;
          pars.Free;
         end
        else
         begin
          {ERROR }
          errmsg := 'key: only allowed in elevators';
         end;
       end
     else
     if Pos('sound:', LowerCase(strin)) = 1 then
       begin
        if CurClsTyp <> 2 then
         begin
          pars := TStringParserWithColon.Create(strin);
          if CurClsTyp = 0 then
           begin
            {elvator syntax}
            if pars.Count = 4 then
             begin
              if (pars[2] = '1') or (pars[2] = '2') or (pars[2] = '3') then
               begin
                if pars[2] = '1' then TheINFCls.Sound1 := pars[3];
                if pars[2] = '2' then TheINFCls.Sound2 := pars[3];
                if pars[2] = '3' then TheINFCls.Sound3 := pars[3];
               end
              else
               begin
                {ERROR }
                errmsg := 'sound: number must be 1, 2 or 3';
               end;
             end
            else
             begin
              {ERROR }
              errmsg := 'invalid elevator sound: INF construction';
             end;
           end
          else
           begin
            {trigger syntax}
            if pars.Count = 3 then
             begin
              TheINFCls.Sound1 := pars[2];
             end
            else
             begin
              {ERROR }
              errmsg := 'Invalid trigger sound: INF construction';
             end;
           end;
          pars.Free;
         end
        else
         begin
          {ERROR }
          errmsg := 'sound: not allowed in teleporter chute';
         end;
       end
     else
     if Pos('addon:', LowerCase(strin)) = 1 then
       begin
        if (CurClsTyp = 0) and (TheINFCls.ClsName = 'door_mid') then
         begin
          pars := TStringParserWithColon.Create(strin);
          if pars.Count = 3 then
           begin
            if (pars[2] = '0') or (pars[2] = '1') then
             begin
              if (pars[2] = '1') and (addon = -1) then
               begin
                {ERROR }
                errmsg := 'addon: 1 missing or before addon: 0';
               end
              else
               begin
                if pars[2] = '0' then
                 addon := 0
                else
                 addon := 1;
               end;
             end
            else
             begin
              {ERROR }
              errmsg := 'addon: number must be 0 or 1';
             end;
           end
          else
           begin
            {ERROR }
            errmsg := 'Invalid addon: INF Wording';
           end;
          pars.Free;
         end
        else
         begin
          {ERROR }
          errmsg := 'addon: only allowed in elevator door_mid';
         end;
       end
     else
     if Pos('flags:', LowerCase(strin)) = 1 then
       begin
        if CurClsTyp = 0 then
         begin
          pars := TStringParserWithColon.Create(strin);
          if pars.Count = 3 then
           begin
            Val(pars[2], TheLong, code);
            if code = 0 then
             begin
              TheINFCls.flags := IntToStr(TheLong);
             end
            else
             begin
              {ERROR }
              errmsg := 'Value of flags: must be numeric';
             end;
           end
          else
           begin
            {ERROR }
            errmsg := 'Invalid flags: INF Wording';
           end;
          pars.Free;
         end
        else
         begin
          {ERROR }
          errmsg := 'flags: can only be used with elevators';
         end;
       end
     else
     if Pos('slave:', LowerCase(strin)) = 1 then
       begin
        if CurClsTyp = 0 then
         begin
          pars := TStringParserWithColon.Create(strin);
          if pars.Count = 3 then
           begin
            TheINFCls.SlaCliTgt.Add(pars[2]);
           end
          else
           begin
            {ERROR }
            errmsg := 'Invalid slave: INF construction';
           end;
          pars.Free;
         end
        else
         begin
          {ERROR }
          errmsg := 'slave: can only be used with elevators';
         end;
       end
     else
     if Pos('client:', LowerCase(strin)) = 1 then
       begin
        if CurClsTyp = 1 then
         begin
          pars := TStringParserWithColon.Create(strin);
          if pars.Count = 3 then
           begin
            TheINFCls.SlaCliTgt.Add(pars[2]);
           end
          else
           begin
            {ERROR }
            errmsg := 'Invalid client: INF construction';
           end;
          pars.Free;
         end
        else
         begin
          {ERROR }
          errmsg := 'client: can only be used with triggers';
         end;
       end
     else
     if Pos('target:', LowerCase(strin)) = 1 then
       begin
        if CurClsTyp = 2 then
         begin
          pars := TStringParserWithColon.Create(strin);
          if pars.Count = 3 then
           begin
            if TheINFCls.SlaCliTgt.Count = 0 then
             begin
              TheINFCls.SlaCliTgt.Add(pars[2]);
             end
            else
             begin
              {ERROR }
              errmsg := 'teleporter chute allows only 1 target:';
             end;
           end
          else
           begin
            {ERROR }
            errmsg := 'Invalid target: INF construction';
           end;
          pars.Free;
         end
        else
         begin
          {ERROR }
          errmsg := 'target: can only be used with teleporter chutes';
         end;
       end
     else
     if Pos('stop:', LowerCase(strin)) = 1 then
       begin
        if CurClsTyp = 0 then
         begin
          pars := TStringParserWithColon.Create(strin);
          if pars.Count = 4 then
           begin
            TheINFStop := TINFStop.Create;
            if pars[2][1] = '@' then
             begin
              TheINFStop.IsAtStop := TRUE;
              TheINFStop.Value := Copy(pars[2],2,30);
             end
            else
             begin
              TheINFStop.IsAtStop := FALSE;
              TheINFStop.Value := Pars[2];
             end;
            {test Value : forget that now, because it could be a sector name too}
            {in case the test is made and false, don't forget to free TheINFStop}
            Val(pars[3], TheReal, code);
            if (pars[3] = 'hold') or
               (pars[3] = 'terminate') or
               (pars[3] = 'complete') or
               (code = 0) then
             begin
              {add the stop if ok}
              TheINFStop.DHT := pars[3];
              TheINFCls.Stops.AddObject('S', TheINFStop);
             end
            else
             begin
              {ERROR }
              errmsg := 'Invalid stop: delay';
              {but must delete it if an error occured!}
              TheINFStop.Free;
             end;
           end
          else
           begin
            {ERROR }
            errmsg := 'Invalid stop: INF construction';
           end;
          pars.Free;
         end
        else
         begin
          {ERROR }
          errmsg := 'stop: can only be used with elevators';
         end;
       end
     else
     if Pos('adjoin:', LowerCase(strin)) = 1 then
       begin
        if CurClsTyp = 0 then
         begin
          pars := TStringParserWithColon.Create(strin);
          if pars.Count = 7 then
           begin
            {check and handle the stopnum parameter}
            Val(pars[2], TheLong, code);
            if code = 0 then
             begin
              if (TheLong >= 0) and (TheLong < TheINFCls.Stops.Count) then
               begin
                TheINFAction := TINFAction.Create;
                with TheINFAction do
                 begin
                  ActName := 'adjoin:';
                  Value   := '';
                  {no checks on those here}
                  sc1     := pars[3];
                  wl1     := pars[4];
                  sc2     := pars[5];
                  wl2     := pars[6];
                 end;
                TheINFCls.Actions.AddObject(IntToStr(TheLong), TheINFAction);
               end
              else
               begin
                {ERROR }
                errmsg := 'adjoin: undefined stopnum';
               end;
             end
            else
             begin
              {ERROR }
              errmsg := 'adjoin: stopnum must be numeric';
             end;
           end
          else
           begin
            {ERROR }
            errmsg := 'Invalid adjoin: INF construction';
           end;
          pars.Free;
         end
        else
         begin
          {ERROR }
          errmsg := 'adjoin: can only be used with elevators';
         end;
       end
     else
     if Pos('texture:', LowerCase(strin)) = 1 then
       begin
        if CurClsTyp = 0 then
         begin
          pars := TStringParserWithColon.Create(strin);
          if pars.Count = 5 then
           begin
            {check and handle the stopnum parameter}
            Val(pars[2], TheLong, code);
            if code = 0 then
             begin
              if (TheLong >= 0) and (TheLong < TheINFCls.Stops.Count) then
               begin
                TheINFAction := TINFAction.Create;
                with TheINFAction do
                 begin
                  ActName := 'texture:';
                  Value   := '';
                  {no checks on those here}
                  sc1     := pars[3]; {flag }
                  sc2     := pars[4]; {donor }
                 end;
                TheINFCls.Actions.AddObject(IntToStr(TheLong), TheINFAction);
               end
              else
               begin
                {ERROR }
                errmsg := 'texture: undefined stopnum';
               end;
             end
            else
             begin
              {ERROR }
              errmsg := 'texture: stopnum must be numeric';
             end;
           end
          else
           begin
            {ERROR }
            errmsg := 'Invalid texture: INF construction';
           end;
          pars.Free;
         end
        else
         begin
          {ERROR }
          errmsg := 'texture: can only be used with elevators';
         end;
       end
     else
     if Pos('message:', LowerCase(strin)) = 1 then
       begin
        {elev and trig only}
        if CurClsTyp <> 2 then
         begin
          elevok   := TRUE;
          elevskip := 0;
          if CurClsTyp = 0 then
           begin
            {check the strictly elev part ie stopnum and target sector/line
             set elevskip to 2 if everything correct, so we'll refer to
             pars[n+elevok afterwards, so only one check is needed
             set elevok to false if an error happens}
             pars := TStringParserWithColon.Create(strin);
             if pars.Count >= 4 then
              begin
               {check and handle the stopnum parameter}
                Val(pars[2], TheLong, code);
                if code = 0 then
                 begin
                  if (TheLong >= 0) and (TheLong < TheINFCls.Stops.Count) then
                   begin
                    tmpstopnum := TheLong;
                    tmpscwl    := pars[3];
                    elevskip := 2;
                   end
                  else
                   begin
                    {ERROR }
                    elevok := FALSE;
                    errmsg := 'message: undefined stopnum';
                   end;
                 end
                else
                 begin
                  elevok := FALSE;
                  errmsg := 'message: stopnum must be numeric';
                 end;
              end
             else
              begin
               elevok := FALSE;
               errmsg := 'Invalid message: INF construction';
              end;
             pars.Free;
           end;
          {now, in both cases (unless an error occured) we have an ok action
           ready, so create it and really parse the message: }
          if elevok then
           begin
            msgok := TRUE;

            tmpMsgType   := '';
            tmpMsgParam1 := '';
            tmpMsgParam2 := '';

            pars := TStringParserWithColon.Create(strin);
            {now, really get to it}

            if pars.Count - elevskip = 2 then
             begin
              {NULL message this exists in elev so we'll allow it for
               triggers too...
               Anyway, as all the fields are cleaned up, there is no
               further handling needed}
             end
            else
             begin
              {here at least the message type is present}
              {no parameter}
              if (pars[2+elevskip] = 'done') or
                 (pars[2+elevskip] = 'wakeup') or
                 (pars[2+elevskip] = 'lights') then
               begin
                if pars.Count - elevskip = 3 then
                 begin
                  tmpMsgType := pars[2 + elevskip];
                 end
                else
                 begin
                  errmsg := 'Invalid message: ' + pars[2 + elevskip] + ' Wording';
                  msgok := FALSE;
                 end;
               end
              else
              {one optional parameter}
              if (pars[2+elevskip] = 'master_on') or
                 (pars[2+elevskip] = 'master_off') or
                 (pars[2+elevskip] = 'next_stop') or
                 (pars[2+elevskip] = 'prev_stop') or
                 (pars[2+elevskip] = 'm_trigger') then
               begin
                {simple construct without optional parameter}
                if pars.Count - elevskip = 3 then
                 begin
                  tmpMsgType := pars[2 + elevskip];
                 end
                else
                 begin
                  {more complex construct with optional parameter}
                  if pars.Count - elevskip = 4 then
                   begin
                    Val(pars[3 + elevskip], TheLong, code);
                    if code = 0 then
                     begin
                      tmpMsgType   := pars[2 + elevskip];
                      tmpMsgParam1 := pars[3 + elevskip];
                     end
                    else
                     begin
                      errmsg := 'message: ' + pars[2 + elevskip] + ' event value must be numeric';
                      msgok := FALSE;
                     end;
                   end
                  else
                   begin
                    errmsg := 'Invalid message: ' + pars[2 + elevskip] + ' Wording';
                    msgok := FALSE;
                   end;
                 end;
               end
              else
              {one mandatory parameter}
              if (pars[2+elevskip] = 'complete') then
               begin
                if pars.Count - elevskip = 4 then
                 begin
                  Val(pars[3 + elevskip], TheLong, code);
                  if code = 0 then
                   begin
                    tmpMsgType   := pars[2 + elevskip];
                    tmpMsgParam1 := pars[3 + elevskip];
                   end
                  else
                   begin
                    errmsg := 'message: ' + pars[2 + elevskip] + ' value must be numeric';
                    msgok := FALSE;
                   end;
                 end
                else
                 begin
                  errmsg := 'Invalid message: ' + pars[2 + elevskip] + ' Wording';
                  msgok := FALSE;
                 end;
               end
              else
              {one mandatory parameter and one optional}
              if (pars[2+elevskip] = 'goto_stop') then
               begin
                if (pars.Count - elevskip = 4) or (pars.Count - elevskip = 5) then
                 begin
                  Val(pars[3 + elevskip], TheLong, code);
                  if code = 0 then
                   begin
                    if (pars.Count - elevskip = 5) then
                     begin
                      {test optional parameter}
                      Val(pars[4 + elevskip], TheLong, code);
                      if code = 0 then
                       begin
                        tmpMsgType   := pars[2 + elevskip];
                        tmpMsgParam1 := pars[3 + elevskip];
                        tmpMsgParam2 := pars[4 + elevskip];
                       end
                      else
                       begin
                        errmsg := 'message: ' + pars[2 + elevskip] + ' event value must be numeric';
                        msgok := FALSE;
                       end;
                     end
                    else
                     begin
                      tmpMsgType   := pars[2 + elevskip];
                      tmpMsgParam1 := pars[3 + elevskip];
                     end;
                   end
                  else
                   begin
                    errmsg := 'message: ' + pars[2 + elevskip] + ' value must be numeric';
                    msgok := FALSE;
                   end;
                 end
                else
                 begin
                  errmsg := 'Invalid message: ' + pars[2 + elevskip] + ' Wording';
                  msgok := FALSE;
                 end;
               end
              else
              {two mandatory parameters}
              if (pars[2+elevskip] = 'clear_bits') or
                 (pars[2+elevskip] = 'set_bits') then
               begin
                if pars.Count - elevskip = 5 then
                 begin
                  if (pars[3 + elevskip] = '1') or
                     (pars[3 + elevskip] = '2') or
                     (pars[3 + elevskip] = '3') then
                   begin
                    Val(pars[4 + elevskip], TheLong, code);
                    if code = 0 then
                     begin
                      tmpMsgType   := pars[2 + elevskip];
                      tmpMsgParam1 := pars[3 + elevskip];
                      tmpMsgParam2 := pars[4 + elevskip];
                     end
                    else
                     begin
                      errmsg := 'message: ' + pars[2 + elevskip] + ' bits must be numeric';
                      msgok := FALSE;
                     end;
                   end
                  else
                   begin
                    errmsg := 'message: ' + pars[2 + elevskip] + ' flagnum must be 1, 2 or 3';
                    msgok := FALSE;
                   end;
                 end
                else
                 begin
                  errmsg := 'Invalid message: ' + pars[2 + elevskip] + ' Wording';
                  msgok := FALSE;
                 end;
               end
              else
               begin
                errmsg := 'Invalid message: type';
                msgok  := FALSE;
               end;
             end;

            pars.Free;

            if msgok then
             begin
              TheINFAction := TINFAction.Create;
              with TheINFAction do
               begin
                ActName   := 'message:';
                MsgType   := tmpMsgType;
                MsgParam1 := tmpMsgParam1;
                MsgParam2 := tmpMsgParam2;
                if CurClsTyp = 0 then
                 begin
                  {handle sector(wall) construct. It is stored in tmpscwl for now}
                  sc1 := tmpscwl;
                 end;
               end;
              if CurClsTyp = 0 then
               TheINFCls.Actions.AddObject(IntToStr(tmpstopnum), TheINFAction)
              else
               TheINFCls.Actions.AddObject('0', TheINFAction);
             end;
           end;
         end
        else
         begin
           errmsg := 'message: not allowed in teleporter chute';
         end;
       end
     else
     if Pos('page:', LowerCase(strin)) = 1 then
       begin
        if CurClsTyp = 0 then
         begin
          pars := TStringParserWithColon.Create(strin);
          if pars.Count = 4 then
           begin
            {check and handle the stopnum parameter}
            Val(pars[2], TheLong, code);
            if code = 0 then
             begin
              if (TheLong >= 0) and (TheLong < TheINFCls.Stops.Count) then
               begin
                TheINFAction := TINFAction.Create;
                with TheINFAction do
                 begin
                  ActName := 'page:';
                  {no check on the .VOC here}
                  Value   := pars[3];
                 end;
                TheINFCls.Actions.AddObject(IntToStr(TheLong), TheINFAction);
               end
              else
               begin
                errmsg := 'page: undefined stopnum';
               end;
             end
            else
             begin
              errmsg := 'page: stopnum must be numeric';
             end;
           end
          else
           begin
            errmsg := 'Invalid page: Wording';
           end;
          pars.Free;
         end
        else
         begin
          errmsg := 'page: can only be used with elevators';
         end;
       end
     else
     if Pos('text:', LowerCase(strin)) = 1 then
       begin
        if CurClsTyp = 1 then
         begin
          pars := TStringParserWithColon.Create(strin);
          if pars.Count = 3 then
           begin
            Val(pars[2], TheLong, code);
            if code = 0 then
             begin
              TheINFAction := TINFAction.Create;
              with TheINFAction do
               begin
                ActName := 'text:';
                Value   := pars[2];
               end;
              TheINFCls.Actions.AddObject('0', TheINFAction);
             end
            else
             begin
              errmsg := 'Value of text: must be numeric';
             end;
           end
          else
           begin
            errmsg := 'Invalid text: Wording';
           end;
          pars.Free;
         end
        else
         begin
          errmsg := 'text: can only be used with triggers';
         end;
       end
     else
     if Pos('start:', LowerCase(strin)) = 1 then
       begin
        if CurClsTyp = 0 then
         begin
          pars := TStringParserWithColon.Create(strin);
          if pars.Count = 3 then
           begin
            Val(pars[2], TheLong, code);
            if code = 0 then
             begin
              if (TheLong >= 0) and (TheLong < TheINFCls.Stops.Count) then
               TheINFCls.start := pars[2]
              else
               begin
                {ERROR }
                errmsg := 'start: undefined stopnum';
               end;
             end
            else
             begin
              {ERROR }
              errmsg := 'Value of start: must be numeric';
             end;
           end
          else
           begin
            {ERROR }
            errmsg := 'Invalid start: Wording';
           end;
          pars.Free;
         end
        else
         begin
          {ERROR  }
          errmsg := 'start: only allowed in elevators';
         end;
       end
     else
     if Pos('seqend', LowerCase(strin)) = 1 then
       begin
        if ClassBegun then
         begin
          TheINFSeq.Classes.AddObject('CL', TheINFCls);
          ClassBegun := FALSE;
         end
        else
         begin
          {ERROR }
          errmsg := 'seq/seqend without class:';
         end;
        if SeqBegun then
         begin
          if TmpComments.Count <> 0 then
           TheINFSeq.Comments.AddStrings(TmpComments);
          TmpComments.Clear;
          INFList.AddObject('SQ', TheINFSeq);
          SeqBegun := FALSE;
          if addon = 0 then
           begin
            {ERROR }
            errmsg := 'addon: 1 not found';
           end;
          addon := -1;
         end
        else
         begin
          {ERROR }
          errmsg := 'seqend without seq';
         end;
       end
     else
     {must be AFTER !!! seqend, else seqend is never found !!!}
     if Pos('seq', LowerCase(strin)) = 1 then
       begin
        if SeqBegun then
         begin
          {ERROR }
          errmsg := 'Previous seq without seqend';
         end;

        TheINFSeq := TINFSequence.Create;
        SeqBegun := TRUE;
       end
     else
       begin
        errmsg := 'Unrecognized command';
       end;

   if errmsg <> '' then
    begin
     {no cleanup of allocated things like seqs and classes etc.
      the calling function allocated it so IT frees it }
     Result := i;
     TmpComments.Free;
     exit;
    end;

  end;

 if SeqBegun then
  begin
   Result := TheINFItems.Count - 1;
   errmsg := 'Missing seqend';
   TmpComments.Free;
  end;


end;


function FreeINFList(INFList : TStringList) : Boolean;
var i,j,k        : Integer;
    TheINFSeq    : TINFSequence;
    TheINFCls    : TINFCls;
    TheINFStop   : TINFStop;
    TheINFAction : TINFAction;
begin
 Result := TRUE;
 for i := 0 to INFList.Count - 1 do
  begin
   TheINFSeq := TINFSequence(INFList.Objects[i]);
   for j := 0 to TheINFSeq.Classes.Count - 1 do
    begin
     TheINFCls := TINFCls(TheINFSeq.Classes.Objects[j]);

     for k := 0 to TheINFCls.Stops.Count - 1 do
      begin
       TINFStop(TheINFCls.Stops.Objects[k]).Free;
      end;

     for k := 0 to TheINFCls.Actions.Count - 1 do
      begin
       TINFAction(TheINFCls.Actions.Objects[k]).Free;
      end;

     TINFCls(TheINFSeq.Classes.Objects[j]).Free;
    end;
  end;
 INFList.Free;
end;

{This one outputs a spruced result if asked}
function INFListToMemo(INFList : TStringList; VAR Memo : TMemo; Spruce, Comments : Boolean) : Boolean;
var i : Integer;
begin
 Result := TRUE;

 Memo.Clear;
 Memo.Lines.BeginUpdate;

 for i := 0 to INFList.Count - 1 do
  INFListToMemoByItem(INFList, i, Memo, Spruce, Comments);

 Memo.Lines.EndUpdate;
end;

{this one does the above, 1 item at a time
 (easier to be able to separate the items for save time)}
function INFListToMemoByItem(INFList : TStringList; Num : Integer; VAR Memo : TMemo; Spruce, Comments : Boolean) : Boolean;
var i,j,k,l      : Integer;
    TheINFSeq    : TINFSequence;
    TheINFCls    : TINFCls;
    TheINFStop   : TINFStop;
    TheINFAction : TINFAction;
    Id           : String;
begin
 Result := TRUE;

 if Spruce then
  id := '  '
 else
  id := '';

 i := num;
  begin
   TheINFSeq := TINFSequence(INFList.Objects[i]);
   if Comments then
    Memo.Lines.AddStrings(TheINFSeq.Comments);
   Memo.Lines.Add('seq');
   for j := 0 to TheINFSeq.Classes.Count - 1 do
    begin
     TheINFCls := TINFCls(TheINFSeq.Classes.Objects[j]);
     with TheINFCls do
      begin
       CASE ClsType OF
        0 : Memo.Lines.Add(id + 'class: elevator ' + ClsName);
        1 : Memo.Lines.Add(id + 'class: trigger ' + ClsName);
        2 : Memo.Lines.Add(id + 'class: teleporter chute');
       END;

       if master      <> '' then Memo.Lines.Add(id+id+id + 'master: ' + master);
     {  if event_mask  <> '' then Memo.Lines.Add(id+id+id + 'event_mask: ' + event_mask);
      moved to below for door_mid  }
       if entity_mask <> '' then Memo.Lines.Add(id+id+id + 'entity_mask: ' + entity_mask);
       if event       <> '' then Memo.Lines.Add(id+id+id + 'event: ' + event);
       if flags       <> '' then Memo.Lines.Add(id+id+id + 'flags: ' + flags);
       if sound1      <> '' then
        if ClsType = 0 then
         Memo.Lines.Add(id+id+id + 'sound: 1 ' + sound1)
        else
         Memo.Lines.Add(id+id+id + 'sound: ' + sound1);
       if sound2      <> '' then Memo.Lines.Add(id+id+id + 'sound: 2 ' + sound2);
       if sound3      <> '' then Memo.Lines.Add(id+id+id + 'sound: 3 ' + sound3);

       if angle       <> '' then Memo.Lines.Add(id+id+id + 'angle: ' + angle);
       if centerX     <> '' then Memo.Lines.Add(id+id+id + 'center: ' + centerX + ' ' + centerZ);

       {now, be careful with the addon: keyword here !}
       if ClsName <> 'door_mid' then
        begin
         if key       <> '' then Memo.Lines.Add(id+id+id + 'key: ' + key);
         if speed     <> '' then Memo.Lines.Add(id+id+id + 'speed: ' + speed);
         {add event_mask to both halves of door _mid DLnov/96}
         if event_mask  <> '' then Memo.Lines.Add(id+id+id + 'event_mask: ' + event_mask);
        end
       else
        begin
         if (key1 <> '') or (speed1 <> '') then
          begin
           Memo.Lines.Add(id+id+'addon: 0');
           if key       <> '' then Memo.Lines.Add(id+id+id + 'key: ' + key);
           if speed     <> '' then Memo.Lines.Add(id+id+id + 'speed: ' + speed);
           {added event_mask for door_mid DL NOv/96}
            if event_mask  <> '' then Memo.Lines.Add(id+id+id + 'event_mask: ' + event_mask);
           Memo.Lines.Add(id+id+'addon: 1');
           if key1      <> '' then Memo.Lines.Add(id+id+id + 'key: ' + key1);
           if speed1    <> '' then Memo.Lines.Add(id+id+id + 'speed: ' + speed1);
           {added event_mask for door_mid DL NOv/96}
            if event_mask  <> '' then Memo.Lines.Add(id+id+id + 'event_mask: ' + event_mask); 
          end;
        end;

       if ClsType = 0 then
        begin
         for k := 0 to TheINFCls.Stops.Count - 1 do
          begin
           TheINFStop := TINFStop(TheINFCls.Stops.Objects[k]);
           if TheINFStop.IsAtStop then
            Memo.Lines.Add(id+id+'stop: @' + TheINFStop.Value + ' ' + TheINFStop.DHT)
           else
            Memo.Lines.Add(id+id+'stop: ' + TheINFStop.Value + ' ' + TheINFStop.DHT);

           {now, write the actions corresponding to this stop}
           for l := 0 to TheINFCls.Actions.Count - 1 do
            begin
             if TheInfCls.Actions[l] = IntToStr(k) then
              begin
               TheINFAction := TINFAction(TheINFCls.Actions.Objects[l]);
               if TheINFAction.ActName = 'adjoin:' then
                begin
                 with TheINFAction do
                 Memo.Lines.Add(id+id+id+'adjoin: ' + IntToStr(k) +
                                ' ' + sc1 + ' ' + wl1 + ' ' + sc2 + ' ' + wl2);
                end
               else
               if TheINFAction.ActName = 'texture:' then
                begin
                 with TheINFAction do
                 Memo.Lines.Add(id+id+id+'texture: ' + IntToStr(k) +
                                ' ' + sc1 + ' ' + sc2);
                end
               else
               if TheINFAction.ActName = 'message:' then
                begin
                 with TheINFAction do
                 Memo.Lines.Add(id+id+id+'message: ' + IntToStr(k) +
                                ' ' + sc1 + ' ' + MsgType +  ' ' +
                                MsgParam1 + ' ' + MsgParam2);
                end
               else
               if TheINFAction.ActName = 'page:' then
                begin
                 with TheINFAction do
                 Memo.Lines.Add(id+id+id+'page: ' + IntToStr(k) +
                                ' ' + Value);
                end;
              end;
            end;
          end;
         if Start <> '' then Memo.Lines.Add(id+id + 'start: ' + Start);
        end;

       if ClsType = 1 then
        for l := 0 to TheINFCls.Actions.Count - 1 do
         begin
          TheINFAction := TINFAction(TheINFCls.Actions.Objects[l]);
          if TheINFAction.ActName = 'message:' then
           begin
            with TheINFAction do
            Memo.Lines.Add(id+id+id+'message: ' +
                           MsgType +  ' ' + MsgParam1 + ' ' + MsgParam2);
           end
          else
          if TheINFAction.ActName = 'text:' then
           begin
            with TheINFAction do
            Memo.Lines.Add(id+id+id+'text: ' + Value);
           end;
         end;

       CASE ClsType OF
        0 : for k := 0 to SlaCliTgt.Count - 1 do Memo.Lines.Add(id+id + 'slave: ' + SlaCliTgt[k]);
        1 : for k := 0 to SlaCliTgt.Count - 1 do Memo.Lines.Add(id+id + 'client: ' + SlaCliTgt[k]);
        2 : if SlaCliTgt.Count > 0 then Memo.Lines.Add(id+id + 'target: ' + SlaCliTgt[0]);
       END;
      end;
    end;
   Memo.Lines.Add('seqend');
  end;
end;

{these are used for the draw color
 The function will also be used when committing an item in the
 INF Editor, so the "draw classes" are kept updated }
function ComputeINFClasses(SC, WL : Integer) : Boolean;
var
   i,j,k       : Integer;
   TheSector   : TSector;
   TheWall     : TWall;
   TheInfClass : TInfClass;
   TheINFItems : TStringList;
   TheINFSeq   : TINFSequence;
   TheINFCls   : TINFCls;
   ret         : Integer;
   INFList     : TStringList;
   msg         : String;
begin
 Result := TRUE;

{First, clear the classes and compute the secrets and flag doors}
 if WL = -1 then
  begin
   {sector}
   TheSector := TSector(MAP_SEC.Objects[SC]);
   TheSector.Elevator := FALSE;
   TheSector.Trigger := FALSE;
   if (TheSector.Flag1 and 524288) <> 0 then
    TheSector.Secret := TRUE
   else
    TheSector.Secret := FALSE;

   for j := 0 to TheSector.InfClasses.Count - 1 do
    begin
     TInfClass(TheSector.InfClasses.Objects[j]).Free;
    end;
   TheSector.InfClasses.Clear;

   if (TheSector.Flag1 and 2) <> 0 then
    begin
     TheInfClass := TInfClass.Create;
     TheInfClass.IsElev := TRUE;
     TheInfClass.Name := 'E. FLAG Door';
     TheSector.InfClasses.AddObject('D', TheInfClass);
     TheSector.Elevator := TRUE;
    end;

   if (TheSector.Flag1 and 64) <> 0 then
    begin
     TheInfClass := TInfClass.Create;
     TheInfClass.IsElev := TRUE;
     TheInfClass.Name := 'E. FLAG Exploding';
     TheSector.InfClasses.AddObject('X', TheInfClass);
     TheSector.Elevator := TRUE;
    end;
  end
 else
  begin
   {wall}
   TheSector := TSector(MAP_SEC.Objects[SC]);
   TheWall := TWall(TheSector.Wl.Objects[WL]);
   TheWall.Elevator := FALSE;
   TheWall.Trigger  := FALSE;

   for j := 0 to TheWall.InfClasses.Count - 1 do
    begin
     TInfClass(TheWall.InfClasses.Objects[j]).Free;
    end;
   TheWall.InfClasses.Clear;
  end;

{Now, add the real classes computed by completely parsing the items}
 TheINFItems := TStringList.Create;
 if WL = -1 then {sector}
  TheINFItems.AddStrings(TheSector.INFItems)
 else {wall}
  TheINFItems.AddStrings(TheWall.INFItems);

 if TheINFItems.Count = 0 then exit;

 INFList := TStringList.Create;
 Ret := ParseINFItems(TheINFItems, INFList, msg);


 if Ret = -1 then
  begin
   {parsing is ok, just split the classes now}
   for i := 0 to INFList.Count - 1 do
    begin
     TheINFSeq := TINFSequence(INFList.Objects[i]);
     for j := 0 to TheINFSeq.Classes.Count - 1 do
      begin
       TheINFCls := TINFCls(TheINFSeq.Classes.Objects[j]);
       TheInfClass := TInfClass.Create;
       with TheINFCls do
        begin
         CASE ClsType OF
         0 : begin
              TheInfClass.IsElev := TRUE;
              TheInfClass.Name   := 'E. ' + ClsName;
              for k := 0 to SlaCliTgt.Count - 1 do TheInfClass.SlaCli.Add(SlaCliTgt[k]);
              TheSector.Elevator := TRUE;
             end;
         1 : begin
              TheInfClass.IsElev := FALSE;
              if ClsName <> '' then
               TheInfClass.Name   := 'T. ' + ClsName
              else
               TheInfClass.Name   := 'T. (trigger)';
              for k := 0 to SlaCliTgt.Count - 1 do TheInfClass.SlaCli.Add(SlaCliTgt[k]);
              if WL = -1 then
               TheSector.Trigger := TRUE
              else
               TheWall.Trigger := TRUE;
             end;
         2 : begin
             {set teleporter chute as elevators.
              This isn't strictly true, but now they will be hilited
              and their target shown}
              TheInfClass.IsElev := TRUE;
              TheInfClass.Name   := 'teleporter chute';
              if SlaCliTgt.Count > 0 then TheInfClass.SlaCli.Add(SlaCliTgt[0]);
              TheSector.Elevator := TRUE;
             end;
         END;
        end;
       {add the class to the sector/wall}
       if WL = -1 then
        TheSector.InfClasses.AddObject('S', TheInfClass)
       else
        TheWall.InfClasses.AddObject('W', TheInfClass);
      end;
    end;
  end
 else
  begin
   Result := FALSE;
  end;

 TheINFItems.Free;
 FreeINFList(INFList);

 if WL = -1 then
  DO_Fill_SectorEditor
 else
  DO_Fill_WallEditor;
end;

end.
