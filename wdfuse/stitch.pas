unit Stitch;

{ SuperStitch function }

interface

uses
  SysUtils, WinTypes, WinProcs, Classes, Dialogs,
  M_Global, M_Util, M_MapUt, M_mapfun, M_editor, G_Util;

TYPE TStitchRequest = class(TObject)
  sc, wl   : Integer;
  sc0, wl0 : Integer;
  XOffs    : Real;
  YOffs    : Real;
end;

CONST
  STITCH_DIR_RIGHT = 0;
  STITCH_DIR_LEFT  = 1;

VAR
  STITCH_REQUESTS : TStringList;
  STITCH_TEXTURE  : String[13];
  STITCH_TXSIZEX,
  STITCH_TXSIZEY  : Real;
  STITCH_DIR      : Integer;

procedure SuperStitch(sc, wl, tex, dir : Integer);
procedure SuperStitchAWall;

implementation

{WARNING, although tex is in the parameters, no full support is added to
          start stitching on a TOP or BOT textures.
          Anyway, it is *NOT* necessary, because there is always a
          non adjoined wall in the vicinity...}
procedure SuperStitch(sc, wl, tex, dir : Integer);
var s, w       : Integer;
    TheSector  : TSector;
    TheWall    : TWall;
    TheSReq    : TStitchRequest;
    OffsX,
    OffsY      : Real;
begin
 DO_StoreUndo;
 {first set all the wall marks to zero, we'll use this to mark
  when a wall already has been stitched so no wall is done more than once}
 for s := 0 to MAP_SEC.Count - 1 do
  begin
   TheSector := TSector(MAP_SEC.Objects[s]);
   for w := 0 to TheSector.Wl.Count - 1 do
    begin
     TheWall := TWall(TheSector.Wl.Objects[w]);
     TheWall.Mark := 0;
    end;
  end;

 STITCH_REQUESTS := TStringList.Create;
 STITCH_DIR      := dir; {0 = right; 1 = left}

 TheSector       := TSector(MAP_SEC.Objects[sc]);
 TheWall         := TWall(TheSector.Wl.Objects[wl]);

 case tex of
  0 : {MID}
      begin
       STITCH_TEXTURE := TheWall.Mid.Name;
       OffsX          := TheWall.Mid.f1;
       OffsY          := TheWall.Mid.f2;
      end;
  1 : {TOP}
      begin
       STITCH_TEXTURE := TheWall.Top.Name;
       OffsX          := TheWall.Top.f1;
       OffsY          := TheWall.Top.f2;
      end;
  2 : {BOT}
      begin
       STITCH_TEXTURE := TheWall.Bot.Name;
       OffsX          := TheWall.Bot.f1;
       OffsY          := TheWall.Bot.f2;
      end;
 end;

 (*
 {get the texture dimensions for offsets normalizing}
 {search for texture first in project dir}
 if FileExists(LEVELPath + '\' + STITCH_TEXTURE) then
  begin
   STITCH_TXSIZEX := 0;
   STITCH_TXSIZEY := 0;
  end
 else
  begin
   {else, search in textures.gob}
   if IsResourceInGOB(TEXTURESgob, STITCH_TEXTURE, dummy1, dummy2) then
    begin
     STITCH_TXSIZEX := 0;
     STITCH_TXSIZEY := 0;
    end
   else
    begin
     ShowMessage('Texture not found !');
    end;
  end;
 *)

 {create a special request for the first wall}
 TheSReq       := TStitchRequest.Create;
 TheSreq.sc    := sc;
 TheSreq.wl    := wl;
 TheSreq.sc0   := -1;
 TheSreq.wl0   := -1;
 if STITCH_DIR = 0 then
  TheSreq.XOffs := OffsX
 else
  TheSreq.XOffs := OffsX - GetWLLen(sc, wl);
 TheSReq.YOffs  := OffsY;

 STITCH_REQUESTS.AddObject('1', TheSReq);

 while STITCH_REQUESTS.Count <> 0 do SuperStitchAWall;

 STITCH_REQUESTS.Free;

 MODIFIED := TRUE;
 DO_Fill_WallEditor;
 UpdateShowCase;
end;

procedure SuperStitchAWall;
var s, w, v    : Integer;
    TheSector  : TSector;
    TheSector0 : TSector;
    TOPSector  : TSector;
    TheWall    : TWall;
    TheWall0   : TWall;
    NewWall    : TWall;
    NewWall2   : TWall;
    NewWall3   : TWall;
    NewSector2 : TSector;
    TheSReq    : TStitchRequest;
    NewSReq    : TStitchRequest;
    lvx, rvx,
    wallnum    : Integer;
    curxofs,
    curyofs    : Real;
    wllen,
    wlhei      : Real;
    oldmidx,
    oldtopx,
    oldbotx    : Real;
    TheSector2 : TSector;
begin
 TheSReq       := TStitchRequest(STITCH_REQUESTS.Objects[0]);
 TheSector     := TSector(MAP_SEC.Objects[TheSReq.sc]);
 TheWall       := TWall(TheSector.Wl.Objects[TheSReq.wl]);

 wllen         := GetWLLen(TheSReq.sc, TheSReq.wl);
 wlhei         := GetWLHei(TheSReq.sc, TheSReq.wl);

 {don't do anything if the wall was already handled}
 if TheWall.Mark <> 0 then
  begin
   STITCH_REQUESTS.Delete(0);
   exit;
  end;

 {don't do anything if there is a multisel and the wall is not in it}
 if WL_MULTIS.Count <> 0 then
  if WL_MULTIS.IndexOf(Format('%4d%4d', [TheSReq.sc, TheSReq.wl])) = -1 then
   begin
    STITCH_REQUESTS.Delete(0);
    exit;
   end;

 {do the actual stitching, unless it is the first wall}
 if (TheSReq.sc0 <> -1) then
  begin
   TheSector0    := TSector(MAP_SEC.Objects[TheSReq.sc0]);
   TheWall0      := TWall(TheSector0.Wl.Objects[TheSReq.wl0]);

   {save the original offsets to restore the SIGN relative position later}
   oldmidx       := TheWall.Mid.f1;
   oldtopx       := TheWall.Top.f1;
   oldbotx       := TheWall.Bot.f1;

   curyofs       := TheSReq.YOffs + TheSector.Floor_Alt - TheSector0.Floor_Alt;
   {!!! normalize offset if possible (ie make a "mod" texture size) !!!}
   if STITCH_DIR = STITCH_DIR_RIGHT then
    begin
     {handle horizontal stitching}

     curxofs := TheSReq.Xoffs + wllen;
     {!!! normalize offset if possible (ie make a "mod" texture size) !!!}
     if TheWall.Mid.Name = STITCH_TEXTURE then TheWall.Mid.f1 := TheSReq.Xoffs;
     if TheWall.Adjoin <> -1 then
      begin
       if TheWall.Top.Name = STITCH_TEXTURE then TheWall.Top.f1 := TheSReq.Xoffs;
       if TheWall.Bot.Name = STITCH_TEXTURE then TheWall.Bot.f1 := TheSReq.Xoffs;
      end;
     {handle vertical stitching}
     if TheWall.Mid.Name = STITCH_TEXTURE then
       TheWall.Mid.f2 := curyofs;
     if TheWall.Adjoin <> -1 then
      begin
       if TheWall.Bot.Name = STITCH_TEXTURE then
        TheWall.Bot.f2 := curyofs;
       if TheWall.Top.Name = STITCH_TEXTURE then
        begin
         TOPSector      := TSector(MAP_SEC.Objects[TheWall.Adjoin]);
         TheWall.Top.f2 := TheSReq.YOffs + TOPSector.Ceili_Alt - TheSector.Floor_Alt;
        end;
      end;
    end
   else
    begin
     {handle horizontal stitching}
     curxofs := TheSReq.Xoffs - wllen;
     {!!! normalize offset if possible (ie make a "mod" texture size) !!!}
     if TheWall.Mid.Name = STITCH_TEXTURE then TheWall.Mid.f1 := curxofs;
     if TheWall.Adjoin <> -1 then
      begin
       if TheWall.Top.Name = STITCH_TEXTURE then TheWall.Top.f1 := curxofs;
       if TheWall.Bot.Name = STITCH_TEXTURE then TheWall.Bot.f1 := curxofs;
      end;
     {handle vertical stitching}
     if TheWall.Mid.Name = STITCH_TEXTURE then
       TheWall.Mid.f2 := curyofs;
     if TheWall.Adjoin <> -1 then
      begin
       if TheWall.Bot.Name = STITCH_TEXTURE then
        TheWall.Bot.f2 := curyofs;
       if TheWall.Top.Name = STITCH_TEXTURE then
        begin
         TOPSector      := TSector(MAP_SEC.Objects[TheWall.Adjoin]);
         TheWall.Top.f2 := TheSReq.YOffs + TOPSector.Ceili_Alt - TheSector.Floor_Alt;
        end;
      end;
    end;

   {keep the relative position of the SIGN}
    if (TheWall.Sign.Name <> '') then
     begin
      if TheWall.Adjoin = - 1 then
       begin
        if TheWall.Mid.Name = STITCH_TEXTURE then
         TheWall.Sign.f1 := TheWall.Sign.f1 + TheWall.Mid.f1 - oldmidx;
       end
      else
       begin
        TheSector2 := TSector(MAP_SEC.Objects[TheWall.Adjoin]);
        if TheSector2.Floor_Alt > TheSector.Floor_Alt then
         begin
          {there is a bot tx, so the SIGN is on the bot tx !}
          if TheWall.Bot.Name = STITCH_TEXTURE then
           TheWall.Sign.f1 := TheWall.Sign.f1 + TheWall.Bot.f1 - oldbotx;
         end
        else
         if TheSector2.Ceili_Alt < TheSector.Ceili_Alt then
          begin
          {there is no bot tx, but well a top tx,
           so the SIGN is on the top tx !}
           if TheWall.Top.Name = STITCH_TEXTURE then
            TheWall.Sign.f1 := TheWall.Sign.f1 + TheWall.Top.f1 - oldtopx;
          end
       end;
     end;
  end
 else
  begin
   curxofs := TheSReq.Xoffs + wllen;
   curyofs := TheSReq.YOffs;
   {!!! normalize offset if possible (ie make a "mod" texture size) !!!}
  end;



 TheWall.Mark := 1;

 {find possible other walls to add to STITCH_REQUESTS
  There are only two possibilities :
  1) the next/prev wall in the sector
  2) if the next/prev wall has an adjoin, the next/prev of this adjoin}

 if STITCH_DIR = STITCH_DIR_RIGHT then
  begin
   rvx := TheWall.right_vx;
   if GetWLfromLeftVX(TheSReq.sc, rvx, WallNum) then
    begin
     NewWall := TWall(TheSector.Wl.Objects[WallNum]);
     if (NewWall.Mid.Name = STITCH_TEXTURE) or
        (NewWall.Top.Name = STITCH_TEXTURE) or
        (NewWall.Bot.Name = STITCH_TEXTURE) then
     if NewWall.Mark = 0 then
      begin
       {request TheSReq.sc, wallnum}
       NewSReq       := TStitchRequest.Create;
       NewSReq.sc    := TheSReq.sc;
       NewSReq.wl    := wallnum;
       NewSReq.sc0   := TheSReq.sc;
       NewSReq.wl0   := TheSReq.wl;
       NewSReq.XOffs := curxofs;
       NewSReq.YOffs := curyofs;
       STITCH_REQUESTS.AddObject('R', NewSReq);
      end;

     if NewWall.Adjoin <> - 1 then
      begin
       NewSector2 := TSector(MAP_SEC.Objects[NewWall.Adjoin]);
       NewWall2   := TWall(NewSector2.Wl.Objects[NewWall.Mirror]);
       rvx        := NewWall2.right_vx;
       if GetWLfromLeftVX(NewWall.Adjoin, rvx, WallNum) then
        begin
         NewWall3 := TWall(NewSector2.Wl.Objects[WallNum]);
         if (NewWall3.Mid.Name = STITCH_TEXTURE) or
            (NewWall3.Top.Name = STITCH_TEXTURE) or
            (NewWall3.Bot.Name = STITCH_TEXTURE) then
         if NewWall3.Mark = 0 then
          begin
           {request newall.adjoin, wallnum}
           NewSReq       := TStitchRequest.Create;
           NewSReq.sc    := newwall.adjoin;
           NewSReq.wl    := wallnum;
           NewSReq.sc0   := TheSReq.sc;
           NewSReq.wl0   := TheSReq.wl;
           NewSReq.XOffs := curxofs;
           NewSReq.YOffs := curyofs;
           STITCH_REQUESTS.AddObject('R', NewSReq);
          end;
        end
       else
        begin
         {there is a problem with that wall, stop everything}
         STITCH_REQUESTS.Delete(0);
         exit;
        end;
      end;
    end
   else
    begin
     {there is a problem with that wall, stop everything}
     STITCH_REQUESTS.Delete(0);
     exit;
    end;
  end
 else
  begin
   lvx :=  TheWall.left_vx;
   if GetWLfromRightVX(TheSReq.sc, lvx, WallNum) then
    begin
     NewWall := TWall(TheSector.Wl.Objects[WallNum]);
     if (NewWall.Mid.Name = STITCH_TEXTURE) or
        (NewWall.Top.Name = STITCH_TEXTURE) or
        (NewWall.Bot.Name = STITCH_TEXTURE) then
     if NewWall.Mark = 0 then
      begin
       {request TheSReq.sc, wallnum}
       NewSReq       := TStitchRequest.Create;
       NewSReq.sc    := TheSReq.sc;
       NewSReq.wl    := wallnum;
       NewSReq.sc0   := TheSReq.sc;
       NewSReq.wl0   := TheSReq.wl;
       NewSReq.XOffs := curxofs;
       NewSReq.YOffs := curyofs;
       STITCH_REQUESTS.AddObject('R', NewSReq);
      end;

     if NewWall.Adjoin <> - 1 then
      begin
       NewSector2 := TSector(MAP_SEC.Objects[NewWall.Adjoin]);
       NewWall2   := TWall(NewSector2.Wl.Objects[NewWall.Mirror]);
       lvx :=  NewWall2.left_vx;
       if GetWLfromRightVX(NewWall.Adjoin, lvx, WallNum) then
        begin
         NewWall3 := TWall(NewSector2.Wl.Objects[WallNum]);
         if (NewWall3.Mid.Name = STITCH_TEXTURE) or
            (NewWall3.Top.Name = STITCH_TEXTURE) or
            (NewWall3.Bot.Name = STITCH_TEXTURE) then
         if NewWall3.Mark = 0 then
          begin
           {request newall.adjoin, wallnum}
           NewSReq       := TStitchRequest.Create;
           NewSReq.sc    := newwall.adjoin;
           NewSReq.wl    := wallnum;
           NewSReq.sc0   := TheSReq.sc;
           NewSReq.wl0   := TheSReq.wl;
           NewSReq.XOffs := curxofs;
           NewSReq.YOffs := curyofs;
           STITCH_REQUESTS.AddObject('R', NewSReq);
          end;
        end
       else
        begin
         {there is a problem with that wall, stop everything}
          STITCH_REQUESTS.Delete(0);
          exit;
        end;
      end;
    end
   else
    begin
     {there is a problem with that wall, stop everything}
     STITCH_REQUESTS.Delete(0);
     exit;
    end;
  end;

 STITCH_REQUESTS.Delete(0);
end;

end.
