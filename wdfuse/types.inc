type
 BM_magic=array[0..3] of char;
 BM_header=record
  magic:BM_magic;
  SizeX,  {if X = 1 then multiple BM in the file - idemy BMs}
	  {sizey=size of file-$20; idemx:=$fffe}
  SizeY,
  idemX,
  idemY:word;
  transparent:byte;     (* 0x36 for normal, 0x3E for transparent *)
  logSizeY:byte;        (*gSizeY = log2(SizeY)             *)
  Compressed:word;   (* 0 = not compressed, 1 = compressed    *)
  DataSize:longint;     (* excluding header                      *)
  filler:array [1..12] of char;
 end;

 BM_mheader=record
  SizeX,  {if X = 1 then multiple BM in the file}
  SizeY,
  idemX,
  idemY:word;
  DataSize:longint;	(* excluding header                      *)
  logSizeY:byte;        (*gSizeY = log2(SizeY)             *)
  z1:array[0..2] of byte;
  ib:byte;
  iw:word;
  z2:array[0..4] of byte;
  transparent:byte;     (* 0x36 for normal, 0x3E for transparent *)
  z3:array[0..2] of byte;
 end;

  BM_multi=record
  speed,
  two:byte;
 end;


       TFrame=record
	xshift,
	yshift,
	flip:longint;
	Cell:longint;         (* this is the absolute adress of header2 *)
	fill:array[1..16] of char;
       end;

       TCell=record
	SizeX,
	SizeY,
	Compressed,
	DataSize:longint;
	fill:array[1..8] of char;
       end;

       Tpal=array[0..255] of record
				red,green,blue:byte;
			       end;
       lfd_pal=record
		 first:byte;
		 last:byte;
		 pal:tpal;
		 z1:byte;
	       end;


       TBITMAP=record
		w,h:word;
		pal:tpal;
		bits:pointer;
	       end;
       FME_details=record
		compressed:boolean;
		xshift,yshift,flip:longint;
		end;
       BM_details=record
		compressed:byte;
		transparent:boolean;
		end;
       Wax_header=record
		   version:longint;
		   nseqs,
		   nframes,
		   ncells:longint;
		   xscale,yscale,xtralight,pad4:longint;
		   waxes:array [0..31] of longint;
		  end;
       twax=record
	     wwidth,wheight:longint;
	     framerate,   {? 8,0}
	     nframes:word;
	     pad1,pad2,pad3,pad4:longint;
	     seqs:array[0..31] of longint;
	    end;
       tseq=record
	     pad1,pad2,pad3,pad4:longint;
	     frames:array[0..31] of longint;
	    end;


       tbuf=array[0..60000] of byte;

 lfd_tag=array[0..3] of char;
 TLFDentry=record
	 tag:lfd_tag;
	 name:array[0..7] of char;
	 size:longint;
	end;
 gob_header=record
	     magic:lfd_tag; {'GOB'#10}
	     pdirectory:longint;
	    end;
 gob_nentries=longint;
 gob_entry=record
	     start,
	     size:longint;
	     name:array[0..12] of byte;
	   end;

     delt_dhead=record
	      SizeAndType,
	      StartX,
	      StartY:word;
	     end;
     delt_head=record
	     OffsX,
	     OffsY,
	     MaxX,
	     MaxY:word;
	    end;
     anim_head=record
		ndelts:integer;
	       end;
     anim_dhead=record
		 delt_size:longint;
		end;
     film_head=record
		 four:integer; {=4}
		 duration:integer; {in 1/10 sec}
		 nblocks:integer; {number of blocks, not including END}
	       end;
     film_block=record
		 typename:array[0..3] of char;	{type}
		 filename:array[0..7] of char;	{file name}
		 fullsize:longint;		{full size of block}
		 blocktype:integer;			{Type id}
		 ncommands:integer;
		 datasize:integer;
		end;
     film_command=record
		   h:record
		      cmd_size:integer;
		      command:integer;
		     end;
		  params: array[0..9] of integer;
		 end;


       pmrecord=record
	sw:string[20];
	swpos:array[0..19] of byte;
	files:array[0..3] of string[80];
       end;

 ext=string[4];
 fstr=record
	handle:word;
	junk:array[0..45] of byte;
	name:array[0..79] of char;
      end;
 fname=string[80];
 name8=string[8];
 ident=string[20];
const
	bt_end=1;
	bt_view=2;
	bt_3=3; {DELT, ANIM, CUST}
	bt_pltt=4;
	bt_voic=5;
	cm_end=2;
	cm_time=3;
	cm_move=4;
	cm_speed=5;
	cm_layer=6;
	cm_frame=7;
	cm_animate=8;
	cm_cue=9;
	cm_var=10;
	cm_window=11;
	cm_switch=13;
	cm_14=14;
	cm_pal=15;
	cm_cut=18;
	cm_loop=20;
	cm_preload=24;
	cm_sound=25;
	cm_stereo=28;
