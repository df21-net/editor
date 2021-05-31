unit GOBLFD;

interface
Uses Files, Classes, SysUtils;
Type

TGOBheader=packed record
            magic:array[0..3] of char;
	    index_ofs:longint;
	   end;

TNEntries=longint;

TGOBEntry=packed record
	 offs:longint;
	 size:longint;
	 name:array[0..12] of char;
	end;


 TLFDentry=packed record
	 tag:array[0..3] of char;
	 name:array[0..7] of char;
	 size:longint;
	end;


TFInfo=TFileInfo;

TGOBDirectory=class(TContainerFile)
 gh:TGobHeader;
 Procedure Refresh;override;
 Function GetContainerCreator(name:String):TContainerCreator;override;
end;

TFLDDirectory=class(TContainerFile)
 Procedure Refresh;override;
 Function GetContainerCreator(name:String):TContainerCreator;override;
end;

TGOBCreator=class(TContainerCreator)
 pes:TList;
 centry:integer;
 Procedure PrepareHeader(newfiles:TStringList);override;
 Procedure AddFile(F:TFile);override;
 Function ValidateName(name:String):String;override;
 Destructor Destroy;override;
end;

TLFDCreator=class(TContainerCreator)
 pes:TList;
 centry:integer;
 Procedure PrepareHeader(newfiles:TStringList);override;
 Procedure AddFile(F:TFile);override;
 Function ValidateName(name:String):String;override;
 Destructor Destroy;override;
private
 Function ValidateExt(e:string):String;
end;


implementation
Uses FileOperations;

Procedure TGOBCreator.PrepareHeader(newfiles:TStringList);
var i:Integer;
    pe:^TGOBEntry;
    aName:STring;
begin
 pes:=TList.Create;
 cf.FSeek(sizeof(TGOBHeader));
 for i:=0 to newfiles.count-1 do
 begin
  New(pe);
  aName:=ExtractName(Newfiles[i]);
  StrPCopy(Pe^.Name,ValidateName(aName));
  pes.Add(pe);
 end;
 centry:=0;
end;

Procedure TGOBCreator.AddFile(F:TFile);
begin
 with TgobEntry(pes[centry]^) do
 begin
  offs:=cf.Fpos;
  size:=f.Fsize;
 end;
 CopyFileData(F,CF,f.Fsize);
 inc(Centry);
end;

Function TGOBCreator.ValidateName(name:String):String;
var n,ext:String;
begin
 Ext:=ExtractExt(name);
 n:=Copy(Name,1,length(Name)-length(ext));
 if length(Ext)>4 then SetLength(Ext,4);
 if length(N)>8 then SetLength(N,8);
 Result:=N+ext;
end;

Destructor TGOBCreator.Destroy;
var i:integer;
    gh:TGobHeader;
    n:Longint;
begin
if pes<>nil then
begin
 gh.magic:='GOB'#10;
 gh.index_ofs:=cf.Fpos;
 cf.Fseek(0); cf.FWrite(gh,sizeof(gh));
 cf.FSeek(gh.index_ofs);
 n:=pes.count;
 cf.FWrite(n,sizeof(n));
 for i:=0 to pes.count-1 do
 begin
  cf.FWrite(TGOBEntry(pes[i]^),sizeof(TGOBEntry));
  Dispose(pes[i]);
 end;
 pes.Free;
end;
Inherited Destroy;
end;


Procedure TGOBDirectory.Refresh;
var Fi:TFInfo;
    i:integer;
    ge:TGobEntry;
    gn:TNEntries;
    s:string;
    f:TFile;
begin
 ClearIndex;
 f:=OpenFileRead(name,0);
Try
 F.FRead(gh,sizeof(gh));
 if gh.magic<>'GOB'#10 then raise Exception.Create(Name+' is not a GOB file');
 F.FSeek(gh.index_ofs);
 F.FRead(gn,sizeof(gn));
 for i:=0 to gn-1 do
 begin
  F.FRead(ge,sizeof(ge));
  fi:=TFInfo.Create;
  fi.offs:=ge.offs;
  fi.size:=ge.size;
  Files.AddObject(ge.name,fi);
 end;
Finally
 F.FClose;
end;
end;

Function TGOBDirectory.GetContainerCreator(name:String):TContainerCreator;
begin
 Result:=TGOBCreator.Create(Name);
end;

{Procedure TDirectoryFile.RenameFile(Fname,newname:TFileName);
var i:integer;
begin
 i:=Files.IndexOf(Fname);
 if i=-1 then exit;
 Files.Strings[i]:=NewName;
end;}

Procedure TFLDDirectory.Refresh;
var Le:TLFDEntry;
    N:array[0..12] of char;
    E:array[0..5] of char;
    fi:TFInfo;
    f:TFile;
    pos:Longint;
begin
 ClearIndex;
 F:=OpenFileRead(Name,0);
 Try
 While (F.FPos<F.FSize) do
 begin
  F.FRead(le,sizeof(le));
  StrLCopy(n,le.name,sizeof(le.name));
  StrLCopy(e,le.tag,sizeof(le.tag));
  fi:=TFInfo.Create;
  Fi.offs:=F.FPos;
  fi.size:=le.size;
  Fi.offs:=F.Fpos;
  Files.AddObject(Concat(n,'.',e),fi);
  F.Fseek(F.Fpos+le.size);
 end;
Finally
 F.FClose;
end;
end;

Function TFLDDirectory.GetContainerCreator(name:String):TContainerCreator;
begin
 Result:=TLFDCreator.Create(Name);
end;

Procedure TLFDCreator.PrepareHeader(newfiles:TStringList);
var i:Integer;
    pe:^TLFDEntry;
    name,ext,s:string;
begin
 pes:=TList.Create;
 cf.FSeek(sizeof(TLFDEntry)*newfiles.count+sizeof(TLFDEntry));
 for i:=0 to newfiles.count-1 do
 begin
  New(pe);
  name:=ValidateName(ExtractName(Newfiles[i])); {always 4 letter extension}
  ext:=ExtractExt(name);
  Delete(Ext,1,1);
  SetLength(Name,length(Name)-5);
  StrMove(Pe^.Name,Pchar(Name),8);
  StrMove(pe^.tag,Pchar(Ext),4);
  pe^.size:=0;
  pes.Add(pe);
 end;
 centry:=0;
end;

Procedure TLFDCreator.AddFile(F:TFile);
begin
 TLFDEntry(Pes[centry]^).size:=f.Fsize;
 cf.FWrite(TLFDEntry(Pes[centry]^),sizeof(TLFDEntry));
 CopyFileData(f,cf,f.Fsize);
 inc(centry);
end;

Function TLFDCreator.ValidateName(name:String):String;
var n,ext:String;
begin
 Ext:=ExtractExt(name);
 n:=Copy(name,1,length(Name)-length(ext));
 Ext:=ValidateExt(ext);
 n:=LowerCase(n);
 if length(n)>8 then SetLength(n,8);
 Result:=n+ext;
end;

Destructor TLFDCreator.Destroy;
var i:integer;
    le:TLFDEntry;
begin
if pes<>nil then
begin
 cf.Fseek(0);
 le.name:='resource';
 le.tag:='RMAP';
 le.size:=pes.count*sizeof(TLFDEntry);
 cf.FWrite(le,sizeof(le));
 for i:=0 to pes.count-1 do
 begin
  cf.FWrite(TLFDEntry(pes[i]^),sizeof(TLFDEntry));
  Dispose(pes[i]);
 end;
 pes.Free;
end;
Inherited Destroy;
end;

Function TLFDCreator.ValidateExt(e:string):String;
begin
 Result:=UpperCase(e);
 if (result='') or (result='.') then Result:='.DATA'
 else if result='.TXT' then result:='.TEXT'
 else if result='.DLT' then result:='.DELT'
 else if result='.ANM' then result:='.ANIM'
 else if result='.FON' then result:='.FONT'
 else if result='.PLT' then result:='.PLTT'
 else if result='.GMD' then result:='.GMID'
 else if result='.VOC' then result:='.VOIC'
 else if result='.FLM' then result:='.FILM'
 else if length(result)<5 then
  while length(result)<5 do result:=result+'X';
end;

end.
