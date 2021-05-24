unit _3doCNV;

interface
Procedure Convert3DO2ASC(Name,AscName:String);

implementation

uses Classes,SysUtils,_3dotasc;

Function GetWord(s:string;p:integer;var w:string):integer;
var b,e:integer;
begin
 if s='' then begin w:=''; result:=1; exit; end;
 b:=p;
 While (s[b] in [' ',#9]) and (b<=length(s)) do inc(b);
 e:=b;
 While (not (s[e] in [' ',#9])) and (e<=length(s)) do inc(e);
 w:=Copy(s,b,e-b);
 GetWord:=e;
end;

Type
    TQuad=class
     v1,v2,v3,v4:integer;
    end;
    TTriangle=class
     v1,v2,v3:integer;
    end;

    Tvertex=class
      x,y,z:single;
    end;

    T3DOObject=class
        Oname:String;
        vertices:TStringList;
        quads:TStringList;
        triangles:TStringList;
        Constructor Create;
        Destructor Destroy;override;
    end;
Constructor T3DOObject.Create;
begin
 Inherited Create;
 vertices:=TStringList.Create;
 quads:=TStringList.Create;
 Triangles:=TStringList.Create;
end;
Destructor T3DOObject.Destroy;
begin
 vertices.free;
 quads.free;
 triangles.free;
end;
type
    T3DO=Record
      name:String;
      nvertices,
      npolygons:Integer;
      Objects:TStringList;
    end;

{$Ifndef WIN32} 
Procedure SetLength(var s:string;l:byte);
begin
 s[0]:=chr(l);
end;
{$endif}



Procedure Convert3DO2ASC(Name,AscName:String);
var t:text;
    s,w:string;
    i,j,k,n,a,npos:integer;
    a3DO:T3DO;
    aObject:T3DOObject;
    aVertex:Tvertex;
    aQuad:TQuad;
    aTriangle:TTriangle;
    Header:boolean;
    First:boolean;
begin
 Assign(t,name);
 Reset(t);
 FillChar(a3DO,sizeof(a3DO),0);
 a3DO.Objects:=TStringList.Create;
 Header:=true;
While not eof(t) do
begin
 Readln(t,s);
 npos:=Pos('#',s);
 if npos<>0 then SetLength(s,npos-1);
 if s='' then continue;
 npos:=GetWord(s,1,w);
 w:=UpperCase(w);
 if first then
 begin
  if w<>'3DO' then begin close(t); exit; end;
  first:=false;
 end;
 if w='3DONAME' then
 begin
  getWord(s,npos,a3DO.name);
 end
 else if w='OBJECT' then
 begin
  getWord(s,npos,w);
  Delete(w,1,1);
  Delete(w,Length(w),1);
  aObject:=T3DOObject.Create;
  aObject.Oname:=w;
  a3DO.Objects.AddObject(w,aObject);
 end
 else if w='VERTICES' then
 begin
   if Header then begin Header:=false; continue; end;
   getWord(s,npos,w);
   n:=StrToInt(w);
   Readln(t,s);
   for i:=1 to n do
   begin
    inc(a3DO.nvertices);
    aVertex:=Tvertex.Create;
    Readln(t,s);
    npos:=GetWord(s,1,w);
    npos:=GetWord(s,npos,w);
    Val(w,aVertex.x,a);
    npos:=GetWord(s,npos,w);
    Val(w,aVertex.y,a);
    npos:=GetWord(s,npos,w);
    Val(w,aVertex.z,a);
    aObject.vertices.AddObject('',aVertex);
   end;
 end
 else if w='QUADS' then
 begin
   getWord(s,npos,w);
   n:=StrToInt(w);
   Readln(t,s);
   for i:=1 to n do
   begin
    inc(a3DO.npolygons);
    aQuad:=TQuad.Create;
    Readln(t,s);
    npos:=GetWord(s,1,w);
    npos:=GetWord(s,npos,w);
    aQuad.v1:=StrToInt(w);
    npos:=GetWord(s,npos,w);
    aQuad.v2:=StrToInt(w);
    npos:=GetWord(s,npos,w);
    aQuad.v3:=StrToInt(w);
    npos:=GetWord(s,npos,w);
    aQuad.v4:=StrToInt(w);
    aObject.quads.addObject('',aQuad);
   end;
 end
 else if w='TRIANGLES' then
 begin
  getWord(s,npos,w);
   n:=StrToInt(w);
   Readln(t,s);
   for i:=1 to n do
   begin
    inc(a3DO.npolygons);
    aTriangle:=TTriangle.Create;
    Readln(t,s);
    npos:=GetWord(s,1,w);
    npos:=GetWord(s,npos,w);
    aTriangle.v1:=StrToInt(w);
    npos:=GetWord(s,npos,w);
    aTriangle.v2:=StrToInt(w);
    npos:=GetWord(s,npos,w);
    aTriangle.v3:=StrToInt(w);
    aObject.Triangles.addObject('',aTriangle);
   end;
 end;
end;
Close(t);

{Converting all Quads to triangles}
For i:=0 to a3DO.objects.count-1 do
begin
 aObject:=T3DOObject(a3DO.Objects.objects[i]);
 for j:=0 to aObject.Quads.count-1 do
 begin
  aQuad:=TQuad(aObject.Quads.Objects[j]);
  aTriangle:=TTriangle.Create;
  aTriangle.v1:=aQuad.v1;
  aTriangle.v2:=aQuad.v2;
  aTriangle.v3:=aQuad.v3;
  aObject.triangles.addObject('',aTriangle);
  aTriangle:=TTriangle.Create;
  aTriangle.v1:=aQuad.v1;
  aTriangle.v2:=aQuad.v3;
  aTriangle.v3:=aQuad.v4;
  aObject.triangles.addObject('',aTriangle);
  Inc(a3DO.npolygons);
 end;
end;


{Saving to .ASC}

Assign(t,AscName);
Rewrite(t);
Writeln(t,'Ambient light color: Red=1.0 Green=1.0 Blue=1.0'#13#10);

For i:=0 to a3DO.objects.count-1 do
begin
 aObject:=T3DOObject(a3DO.objects.objects[i]);
 Writeln(t,'Named object: ','"',aObject.oname,'"');
 Writeln(t,'Tri-mesh, Vertices: ',aObject.vertices.count,' Faces: ',aObject.triangles.count);
 Writeln(t,'Vertex List:');
  CNV3do2asc.Gauge1.MaxValue :=aObject.vertices.count;
 For j:=0 to aObject.vertices.count-1 do
 begin
  aVertex:=TVertex(aObject.vertices.objects[j]);
  Writeln(t,'Vertex ',j,':  X:',aVertex.x:1:6,'    Y:',aVertex.y:1:6,
          '    Z:',aVertex.z:1:6);

    CNV3do2asc.Gauge1.Progress := aObject.vertices.count;
 end;

 Writeln(t,'Face list:');
 for j:=0 to aObject.triangles.count-1 do
 begin
  aTriangle:=TTriangle(aObject.triangles.objects[j]);
  Writeln(t,'Face ',j,': A:',aTriangle.v1,' B:',aTriangle.v2,' C:',aTriangle.v3,
              ' AB:1 BC:1 CA:1');
   Writeln(t,'Material:"r',ScrollRed,'g',ScrollGreen,'b',ScrollBlue,'a100"');
   Writeln(t,'Smoothing: 1');
 end;
end;
 CNV3do2asc.Gauge1.Progress := 0;
a3DO.objects.Free;
Close(t);
end;

end.
