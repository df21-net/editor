Type
	TGOBheader=record
	 magic:array[0..3] of char;
	 index_ofs:longint;
	end;

	TNEntries=longint;

	TGOBEntry=record
	 offs:longint;
	 size:longint;
	 name:array[0..12] of char;
	end;
