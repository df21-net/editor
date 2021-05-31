unit MultiSelection;

interface
uses Classes, SysUtils;
Type

TMultiSelection=class(TStringList)
 ApSC,ApWL,ApVX,ApOB:Integer;
 Appended:Boolean;
 Function AddSector(sc:Integer):Integer;
 Function AddWall(sc,wl:Integer):Integer;
 Function AddVertex(sc,vx:Integer):Integer;
 Function AddObject(ob:Integer):Integer;

 Function FindSector(sc:Integer):Integer;
 Function FindWall(sc,wl:Integer):Integer;
 Function FindVertex(sc,vx:Integer):Integer;
 Function FindObject(ob:Integer):Integer;

 Function GetSector(n:Integer):Integer;
 Function GetWall(n:Integer):Integer;
 Function GetVertex(n:Integer):Integer;
 Function GetObject(n:Integer):Integer;

{ Procedure AppendSC(sc:Integer);
 Procedure AppendWL(sc,wl:Integer);
 Procedure AppendVX(sc,vx:Integer);
 Procedure AppendOB(ob:Integer);}
end;



implementation

Function TMultiSelection.AddSector(sc:Integer):Integer;
begin
 Result:=Add(Format('%4d',[sc]));
end;

Function TMultiSelection.AddWall(sc,wl:Integer):Integer;
begin
 Result:=Add(Format('%4d%4d',[sc,wl]));
end;

Function TMultiSelection.AddVertex(sc,vx:Integer):Integer;
begin
 Result:=Add(Format('%4d%4d',[sc,vx]));
end;

Function TMultiSelection.AddObject(ob:Integer):Integer;
begin
 Result:=Add(Format('%4d',[ob]));
end;

Function TMultiSelection.FindSector(sc:Integer):Integer;
begin
 Result:=IndexOf(Format('%4d',[sc]));
end;

Function TMultiSelection.FindWall(sc,wl:Integer):Integer;
begin
 Result:=IndexOf(Format('%4d%4d',[sc,wl]));
end;

Function TMultiSelection.FindVertex(sc,vx:Integer):Integer;
begin
 Result:=IndexOf(Format('%4d%4d',[sc,vx]));
end;

Function TMultiSelection.FindObject(ob:Integer):Integer;
begin
 Result:=IndexOf(Format('%4d',[ob]));
end;

Function TMultiSelection.GetSector(n:Integer):Integer;
begin
 Result:=StrToInt(Copy(Strings[n],1,4));
end;

Function TMultiSelection.GetWall(n:Integer):Integer;
begin
 Result:=StrToInt(Copy(Strings[n],5,4));
end;

Function TMultiSelection.GetVertex(n:Integer):Integer;
begin
 Result:=StrToInt(Copy(Strings[n],5,4));
end;

Function TMultiSelection.GetObject(n:Integer):Integer;
begin
 Result:=StrToInt(Copy(Strings[n],1,4));
end;

end.
