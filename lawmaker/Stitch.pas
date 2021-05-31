unit Stitch;

interface
uses Level, Level_Utils, MultiSelection;

procedure StitchHorizontal(L:TLevel; WSel:TMultiSelection; Mid, Top, Bot : Boolean);
procedure StitchHorizontalInvert(L:TLevel;WSel:TMultiSelection; Mid, Top, Bot : Boolean);
procedure StitchVertical(L:TLevel;WSel:TMultiSelection;Mid, Top, Bot : Boolean);

implementation

procedure StitchHorizontal(L:TLevel; WSel:TMultiSelection; Mid, Top, Bot : Boolean);
var TheSector  : TSector;
    TheSector2 : TSector;
    TheWall    : TWall;
    Mofs       : Double;
    Tofs       : Double;
    Bofs       : Double;
    m          : Integer;
    Len        : Double;
begin
 TheSector  := L.Sectors[WSel.GetSector(0)];
 TheWall    := TheSector.Walls[WSel.GetWall(0)];

 Len        := GetWLLen(L,WSel.GetSector(0),WSel.GetWall(0));
 Mofs       := TheWall.Mid.OffsX + Len;
 Tofs       := TheWall.Top.OffsX + Len;
 Bofs       := TheWall.Bot.OffsX + Len;

 for m := 1 to WSel.Count - 1 do
  begin
    TheSector  := L.Sectors[WSel.GetSector(m)];
    TheWall    := TheSector.Walls[WSel.GetWall(m)];

(*    {keep the relative position of the SIGN}
    if (TheWall.Overlay.Name <> '') then
     begin
      if TheWall.Adjoin = - 1 then
       begin
        if Mid then
         TheWall.Sign.f1 := TheWall.Sign.f1 + MOfs - TheWall.Mid.f1;
       end
      else
       begin
        TheSector2 := TSector(MAP_SEC.Objects[TheWall.Adjoin]);
        if TheSector2.Floor_Alt > TheSector.Floor_Alt then
         begin
          {there is a bot tx, so the SIGN is on the bot tx !}
          if Bot then
           TheWall.Sign.f1 := TheWall.Sign.f1 + BOfs - TheWall.Bot.f1;
         end
        else
         if TheSector2.Ceili_Alt < TheSector.Ceili_Alt then
          begin
          {there is no bot tx, but well a top tx,
           so the SIGN is on the top tx !}
           if Top then
            TheWall.Sign.f1 := TheWall.Sign.f1 + TOfs - TheWall.Top.f1;
          end
       end;
     end; *)

    if Mid then TheWall.Mid.OffsX := MOfs;
    if Top then TheWall.Top.OffsX := TOfs;
    if Bot then TheWall.Bot.OffsX := BOfs;

    Len        := GetWLLen(L,WSel.GetSector(m),WSel.GetWall(m));
    Mofs       := Mofs + Len;
    Tofs       := Tofs + Len;
    Bofs       := Bofs + Len;
  end;

end;


procedure StitchHorizontalInvert(L:TLevel;WSel:TMultiSelection; Mid, Top, Bot : Boolean);
var TheSector  : TSector;
    TheSector2 : TSector;
    TheWall    : TWall;
    Mofs       : Double;
    Tofs       : Double;
    Bofs       : Double;
    m          : Integer;
    Len        : Double;
begin
 TheSector  :=L.Sectors[WSel.GetSector(WSel.Count-1)];
 TheWall    :=TheSector.Walls[WSel.GetWall(WSel.Count-1)];

 Mofs       := TheWall.Mid.OffsX;
 Tofs       := TheWall.Top.OffsX;
 Bofs       := TheWall.Bot.OffsX;

 for m := WSel.Count - 2 downto 0 do
  begin
    TheSector  := L.Sectors[WSel.GetSector(m)];
    TheWall    := TheSector.Walls[WSel.GetWall(m)];
    Len        := GetWLLen(L,WSel.GetSector(m), WSel.GetWall(m));
    Mofs       := Mofs - Len;
    Tofs       := Tofs - Len;
    Bofs       := Bofs - Len;

(*    {keep the relative position of the SIGN}
    if (TheWall.Sign.Name <> '') then
     begin
      if TheWall.Adjoin = - 1 then
       begin
        if Mid then
         TheWall.Sign.f1 := TheWall.Sign.f1 + MOfs - TheWall.Mid.f1;
       end
      else
       begin
        TheSector2 := TSector(MAP_SEC.Objects[TheWall.Adjoin]);
        if TheSector2.Floor_Alt > TheSector.Floor_Alt then
         begin
          {there is a bot tx, so the SIGN is on the bot tx !}
          if Bot then
           TheWall.Sign.f1 := TheWall.Sign.f1 + BOfs - TheWall.Bot.f1;
         end
        else
         if TheSector2.Ceili_Alt < TheSector.Ceili_Alt then
          begin
          {there is no bot tx, but well a top tx,
           so the SIGN is on the top tx !}
           if Top then
            TheWall.Sign.f1 := TheWall.Sign.f1 + TOfs - TheWall.Top.f1;
          end
       end;
     end;*)

    if Mid then TheWall.Mid.OffsX := MOfs;
    if Top then TheWall.Top.OffsX := TOfs;
    if Bot then TheWall.Bot.OffsX := BOfs;
  end;

end;


procedure StitchVertical(L:TLevel;WSel:TMultiSelection;Mid, Top, Bot : Boolean);
var TheSector : TSector;
    TheWall   : TWall;
    Mofs      : Double;
    Tofs      : Double;
    Bofs      : Double;
    m         : Integer;
    Floor     : Double;
begin
 TheSector  := L.Sectors[WSel.GetSector(0)];
 Floor      := TheSector.Floor_Y;
 TheWall    := TheSector.Walls[WSel.GetWall(0)];

 Mofs       := TheWall.Mid.OffsY;
 Tofs       := TheWall.Top.OffsY;
 Bofs       := TheWall.Bot.OffsY;

 for m := 1 to WSel.Count - 1 do
  begin
    TheSector  := L.Sectors[WSel.GetSector(m)];
    TheWall    := TheSector.Walls[WSel.GetWall(m)];
    if Mid then TheWall.Mid.OffsY := MOfs + TheSector.Floor_Y - Floor;
    if Top then TheWall.Top.OffsY := TOfs + TheSector.Floor_Y - Floor;
    if Bot then TheWall.Bot.OffsY := BOfs + TheSector.Floor_Y - Floor;
  end;
end;

end.
