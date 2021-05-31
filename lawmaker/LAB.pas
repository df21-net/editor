unit LAB;

interface
Uses Files, SysUtils, Classes;

Type
TResType=array[0..3] of char;

TLABDirectory=class(TContainerFile)
 Procedure Refresh;override;
 Function GetContainerCreator(name:String):TContainerCreator;override;
end;

 TLABHeader=packed record
   Magic:array[0..3] of char; {'LABN'}
   Version:Longint; {65536}
   NFiles:Longint;
   NamePoolSize:Longint;
 end;

TLABEntry=packed record
 Nameoffset:longint; // from the beginning of the name pool
 offset:Longint;	//absolute from the beginning of the file
 size:longint;
 ResType:TResType;
end;

TLABCreator=class(TContainerCreator)
 pes:TList;
 centry:integer;
 lh:TLABHeader;
 Procedure PrepareHeader(newfiles:TStringList);override;
 Procedure AddFile(F:TFile);override;
 Function ValidateName(name:String):String;override;
 Destructor Destroy;override;
Private
 Function GetResType(const Name:String):TResType;
end;

implementation

uses FileOperations;
Type
TLABFileInfo=class(TFileInfo)
 resType:TResType;
end;

Procedure TLABDirectory.Refresh;
var f:TFile;
    Lh:TLabHeader;
    Le:TLabEntry;
    PNpool:pchar;
    Fi:TLABFileInfo;
    i:integer;
    s:string;
begin
 ClearIndex;
 f:=OpenFileRead(name,0);
Try
 F.FRead(lh,sizeof(lh));
 if (lh.magic<>'LABN') then raise Exception.Create(Name+' is not a LAB file');
 F.Fseek(lh.NFiles*sizeof(le)+sizeof(lh));
 GetMem(PNPool,lh.NamePoolSize);
 F.Fread(PNPool^,lh.NamePoolSize);
 F.Fseek(sizeof(lh));
 for i:=0 to lh.nFiles-1 do
 begin
  F.FRead(le,sizeof(le));
  fi:=TLABFileInfo.Create;
  fi.offs:=le.offset;
  fi.size:=le.size;
  fi.resType:=le.ResType;
  Files.AddObject((PNPool+le.NameOffset),fi);
 end;
Finally
 F.FClose;
 FreeMem(PnPool);
end;
end;

Function TLABDirectory.GetContainerCreator(name:String):TContainerCreator;
begin
 Result:=TLABCreator.Create(Name);
end;

Procedure TLABCreator.PrepareHeader(newfiles:TStringList);
var i:integer;
    buf:Array[0..255] of char;
    len:Integer;
    ple:^TLabEntry;
    aName:String;
begin
 pes:=TList.Create;
 Lh.magic:='LABN';
 lh.Version:=65536;
 lh.NFiles:=newfiles.count;
 lh.NamePoolSize:=0;
 cf.Fseek(sizeof(lh)+lh.NFiles*sizeof(TLABEntry));
 for i:=0 to newfiles.count-1 do
 begin
  aName:=ExtractName(newfiles[i]);
  StrPCopy(buf,aName);
  len:=Length(aName);
  cf.FWrite(buf,len+1);
  new(ple);
  with ple^ do
  begin
   NameOffset:=lh.NamePoolSize;
   size:=0;
   offset:=0;
   resType:=GetResType(aName);
  end;
  inc(lh.NamePoolSize,len+1);
  pes.Add(ple);
 end;
 Centry:=0;
end;

Function TLabCreator.GetResType(const Name:String):TResType;
var ext:String;
begin
 ext:=UpperCase(ExtractExt(Name));
 if ext='.PCX' then Result:='MTXT'
 else if ext='.ITM' then Result:='METI'
 else if ext='.ATX' then Result:='FXTA'
 else if ext='.NWX' then Result:='FXAW'
 else if ext='.WAV' then Result:='DVAW'
 else if ext='.PHY' then Result:='SYHP'
 else if ext='.RCS' then Result:='BPCR'
 else if ext='.MSC' then Result:='BCSM'
 else if ext='.LAF' then Result:='TNFN'
 else if ext='.LVT' then Result:='FTVL'
 else if ext='.OBT' then Result:='FTBO'
 else if ext='.INF' then Result:='FFNI'
 else Result:=#0#0#0#0;
end;

Procedure TLABCreator.AddFile(F:TFile);
begin
 with TLABEntry(pes[centry]^) do
 begin
   offset:=cf.Fpos;
   size:=f.Fsize;
 end;
 CopyFileData(f,cf,f.Fsize);
 inc(centry);
end;

Function TLABCreator.ValidateName(name:String):String;
begin
 Result:=name;
end;

Destructor TLABCreator.Destroy;
var i:integer;
begin
 cf.Fseek(0);
 cf.FWrite(lh,sizeof(lh));
 for i:=0 to pes.count-1 do
 begin
  cf.FWrite(TLABEntry(pes[i]^),sizeof(TLABEntry));
  Dispose(pes[i]);
 end;
Inherited Destroy;
end;

end.
