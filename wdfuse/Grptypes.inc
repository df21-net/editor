Type
TGRP_Header=record
 sig:array[0..11] of char; {'KenSilverman'}
 Nentries:longint;
end;

TGRP_Entry=record
 name:array[0..11] of char;
 size:longint;
end;

Const
GRP_SIG:array[0..11] of char='KenSilverman';