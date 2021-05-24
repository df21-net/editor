unit _3dmath;
{*******************************************************************}
{ _3dmath : VECTOR3, VECTOR4 and MATRIX4 types and routines.        }
{ Copyright (c) 1996 Yves Borckmans                                 }
{*******************************************************************}

{ nota : regarder dumb3d.cpp et dumb3d.cph dans la demo cube de     }
{        WinG. Il y a des regles precises sur le 4 eme element pour }
{        les vecteurs et les points !!!!!                           }
{        Recommencer cette unit en consequence...                   }
{        En fait les objects sont P4, V4 et M4 !                    } 

interface
uses SysUtils;     { for display/debug purposes only                }

CONST
 USE_HOMOGENOUS = TRUE;
                   { This tells that HOMOGENOUS points and vectors  }
                   { are used, and reduces some of the operations   }
 V3_TO_V4_DEFAULT = 0;
                   { This is the default 4th element used in V3 to  }
                   { V4 assignment. Note that the above setting     }
                   { superseeds it if they conflict.                }

TYPE
 MReal     = Real; { You may use Real, Single, Double or Extended   }
                   { Integer types should work too for everything   }
                   { but matrix inversion which involves divisions, }
                   { and of course rotations. Those use trigs, so   }
                   { you'll have to take care of that if needed.    }

 TVECTOR3  = array[0..2] of MReal;
 TVECTOR4  = array[0..3] of MReal;
 TMATRIX4  = array[0..3, 0..3] of MReal;

{* VECTORS *********************************************************}

{V3}
procedure V3_Assign000(VAR v : TVECTOR3);
procedure V3_AssignXYZ(VAR v : TVECTOR3; x,y,z : MReal);
procedure V3_AssignV3(VAR v : TVECTOR3; w : TVECTOR3);
procedure V3_AssignV4(VAR v : TVECTOR3; w : TVECTOR4);
procedure V3_MultiplyByReal(VAR v : TVECTOR4; r : MReal);

function  V3_Is000(v : TVECTOR3) : Boolean;
function  V3_DotProductV3(v, w : TVECTOR3) : MReal;
function  V3_DotProductV4(v : TVECTOR3; w : TVECTOR4) : MReal;

{V4}
procedure V4_Assign0000(VAR v : TVECTOR4);
procedure V4_Assign0001(VAR v : TVECTOR4);
procedure V4_AssignXYZ(VAR v : TVECTOR4; x,y,z : MReal);
procedure V4_AssignXYZT(VAR v : TVECTOR4; x,y,z,t : MReal);
procedure V4_AssignV4(VAR v : TVECTOR4; w : TVECTOR4);
procedure V4_AssignV3(VAR v : TVECTOR4; w : TVECTOR3);
procedure V4_MultiplyByReal(VAR v : TVECTOR4; r : MReal);

function  V4_Is0000(v : TVECTOR4) : Boolean;
function  V4_Is0001(v : TVECTOR4) : Boolean;
function  V4_DotProductV4(v, w : TVECTOR4) : MReal;
function  V4_DotProductV3(v : TVECTOR4; w : TVECTOR3) : MReal;

{* MATRICES ********************************************************}

procedure M4_AssignUnity(VAR m : TMATRIX4);
procedure M4_AssignM4(VAR m : TMATRIX4; n : TMATRIX4);
procedure M4_Transpose(VAR m : TMATRIX4);
procedure M4_MultiplyByReal(VAR m : TMATRIX4; r : MReal);
procedure M4_PreMultiplyByM4(VAR m : TMATRIX4; n : TMATRIX4);
procedure M4_PostMultiplyByM4(VAR m : TMATRIX4; n : TMATRIX4);

function  M4_IsUnity(m : TMATRIX4) : Boolean;
function  M4_Determinant33(m : TMATRIX4; l,c : Integer) : MReal;
function  M4_Determinant(m : TMATRIX4) : MReal;
function  M4_Invert(VAR m : TMATRIX4) : Boolean;

{* internal and debug **********************************************}

function  M4_Determinant33_00(m : TMATRIX4) : MReal;
function  V3_Display(v : TVECTOR3) : String;
function  V4_Display(v : TVECTOR4) : String;
function  M4_DisplayALine(m : TMATRIX4; l : Integer) : String;

{to do

procedure M4_RotateXDeg(VAR m : TMATRIX4; angle : MReal);
procedure M4_RotateYDeg(VAR m : TMATRIX4; angle : MReal);
procedure M4_RotateZDeg(VAR m : TMATRIX4; angle : MReal);
procedure M4_RotateXRad(VAR m : TMATRIX4; angle : MReal);
procedure M4_RotateYRad(VAR m : TMATRIX4; angle : MReal);
procedure M4_RotateZRad(VAR m : TMATRIX4; angle : MReal);

procedure M4_SetTranslateXYZ(VAR m : TMATRIX4; x,y,z : MReal);
procedure M4_SetTranslateV3(VAR m : TMATRIX4; v : TVECTOR3);
procedure M4_SetTranslateV4(VAR m : TMATRIX4; v : TVECTOR4);

procedure M4_TranslateByXYZ(VAR m : TMATRIX4; x,y,z : MReal);
procedure M4_TranslateByV3(VAR m : TMATRIX4; v : TVECTOR3);
procedure M4_TranslateByV4(VAR m : TMATRIX4; v : TVECTOR4);


toutes les fonctions utiles sur les vecteurs
procedure V3_Normalize(VAR v : TVECTOR3);
procedure V4_Normalize(VAR v : TVECTOR4);

procedure V3_CrossProductV3(VAR v : TVECTOR3; w : TVECTOR3);
procedure V4_CrossProductV4(VAR v : TVECTOR4; w : TVECTOR4);

procedure V3_TransformByM4(VAR v : TVECTOR3; m : TMATRIX4);
procedure V4_TransformByM4(VAR v : TVECTOR4; m : TMATRIX4);

etc.
}

implementation

procedure V3_Assign000(VAR v : TVECTOR3);
begin
 v[0] := 0; v[1] := 0; v[2] := 0;
end;

procedure V3_AssignXYZ(VAR v : TVECTOR3; x,y,z : MReal);
begin
 v[0] := x; v[1] := y; v[2] := z;
end;

procedure V3_AssignV3(VAR v : TVECTOR3; w : TVECTOR3);
begin
 v[0] := w[0];
 v[1] := w[1];
 v[2] := w[2];
end;

procedure V3_AssignV4(VAR v : TVECTOR3; w : TVECTOR4);
begin
 v[0] := w[0];
 v[1] := w[1];
 v[2] := w[2];
end;

procedure V3_MultiplyByReal(VAR v : TVECTOR4; r : MReal);
begin
 v[0] := r * v[0];
 v[1] := r * v[1];
 v[2] := r * v[2];
end;

function  V3_Is000(v : TVECTOR3) : Boolean;
begin
 Result := ((v[0] = 0) and (v[1] = 0) and (v[2] = 0));
end;

function  V3_DotProductV3(v, w : TVECTOR3) : MReal;
begin
 Result := v[0] * w[0] + v[1] * w[1] + v[2] * w[2];
end;

function  V3_DotProductV4(v : TVECTOR3; w : TVECTOR4) : MReal;
begin
 Result := v[0] * w[0] + v[1] * w[1] + v[2] * w[2];
end;

{*******************************************************************}

procedure V4_Assign0000(VAR v : TVECTOR4);
begin
 v[0] := 0; v[1] := 0; v[2] := 0; v[3] := 0;
end;

procedure V4_Assign0001(VAR v : TVECTOR4);
begin
 v[0] := 0; v[1] := 0; v[2] := 0; v[3] := 1;
end;

function  V4_Is0000(v : TVECTOR4) : Boolean;
begin
 Result := ((v[0] = 0) and (v[1] = 0) and (v[2] = 0) and (v[3] = 0));
end;

function  V4_Is0001(v : TVECTOR4) : Boolean;
begin
 Result := ((v[0] = 0) and (v[1] = 0) and (v[2] = 0) and (v[3] = 1));
end;

procedure V4_AssignXYZ(VAR v : TVECTOR4; x,y,z : MReal);
begin
 v[0] := x;
 v[1] := y;
 v[2] := z;
 v[3] := 1;
end;

procedure V4_AssignXYZT(VAR v : TVECTOR4; x,y,z,t : MReal);
begin
 v[0] := x;
 v[1] := y;
 v[2] := z;
 v[3] := t;
end;

procedure V4_AssignV4(VAR v : TVECTOR4; w : TVECTOR4);
begin
 v[0] := w[0];
 v[1] := w[1];
 v[2] := w[2];
 if USE_HOMOGENOUS then
  v[3] := 1
 else
  v[3] := w[3];
end;

procedure V4_AssignV3(VAR v : TVECTOR4; w : TVECTOR3);
begin
 v[0] := w[0];
 v[1] := w[1];
 v[2] := w[2];
 if USE_HOMOGENOUS then
  v[3] := 1
 else
  v[3] := V3_TO_V4_DEFAULT;
end;

procedure V4_MultiplyByReal(VAR v : TVECTOR4; r : MReal);
begin
 v[0] := r * v[0];
 v[1] := r * v[1];
 v[2] := r * v[2];
 if not USE_HOMOGENOUS then
  v[3] := r * v[3];
end;

function  V4_DotProductV4(v, w : TVECTOR4) : MReal;
begin
 Result := v[0] * w[0] + v[1] * w[1] + v[2] * w[2];
 if not USE_HOMOGENOUS then
  Result := Result + v[3] * w[3];
end;

function  V4_DotProductV3(v : TVECTOR4; w : TVECTOR3) : MReal;
begin
 Result := v[0] * w[0] + v[1] * w[1] + v[2] * w[2];
end;

{*******************************************************************}

procedure M4_AssignUnity(VAR m : TMATRIX4);
var i,j : Integer;
begin
 for i := 0 to 3 do for j := 0 to 3 do m[i,j] := 0;
 for i := 0 to 3 do m[i,i] := 1;
end;

function  M4_IsUnity(m : TMATRIX4) : Boolean;
var i,j   : Integer;
begin
 Result := TRUE;
 for i := 0 to 3 do
  for j := 0 to 3 do
   if i <> j then
    if m[i,j] <> 0 then
     Result := FALSE;

 for i := 0 to 3 do
  if m[i,j] <> 1 then
     Result := FALSE;
end;

procedure M4_AssignM4(VAR m : TMATRIX4; n : TMATRIX4);
var i,j   : Integer;
begin
 for i := 0 to 3 do for j := 0 to 3 do m[i,j] := n[i,j];
end;

procedure M4_Transpose(VAR m : TMATRIX4);
var i,j   : Integer;
    value : MReal;
begin
 for i := 0 to 3 do
  for j := 0 to 3 do
   if i<>j then
    begin
     value  := m[i,j];
     m[i,j] := m[j,i];
     m[j,i] := value;
    end;
end;

procedure M4_MultiplyByReal(VAR m : TMATRIX4; r : MReal);
var i,j : Integer;
begin
 for i := 0 to 3 do for j := 0 to 3 do m[i,j] := r * m[i,j];
end;

procedure M4_PreMultiplyByM4(VAR m : TMATRIX4; n : TMATRIX4);
var i,j,k : Integer;
    value : MReal;
    El    : array[0..3, 0..3] of MReal;
begin
 for i := 0 to 3 do for j := 0 to 3 do El[i,j] := m[i,j];

 for i := 0 to 3 do
  for j := 0 to 3 do
   begin
    value := 0;
    for k := 0 to 3 do value := value + n[i,k] * El[k,j];
    m[i,j] := value;
   end;
end;

procedure M4_PostMultiplyByM4(VAR m : TMATRIX4; n : TMATRIX4);
var i,j,k : Integer;
    value : MReal;
    El    : array[0..3, 0..3] of MReal;
begin
 for i := 0 to 3 do for j := 0 to 3 do El[i,j] := m[i,j];

 for i := 0 to 3 do
  for j := 0 to 3 do
   begin
    value := 0;
    for k := 0 to 3 do value := value + El[i,k] * n[k,j];
    m[i,j] := value;
   end;
end;

function  M4_Determinant33_00(m : TMATRIX4) : MReal;
begin
 Result :=  m[0,0] * ( m[1,1] * m[2,2] - m[1,2] * m[2,1] )
	  - m[0,1] * ( m[1,0] * m[2,2] - m[1,2] * m[2,0] )
	  + m[0,2] * ( m[1,0] * m[2,1] - m[1,1] * m[2,0] );
end;

function  M4_Determinant33(m : TMATRIX4; l,c : Integer) : MReal;
var i,j,p,q : Integer;
    sgndet  : MReal;
    D       : TMATRIX4;
begin
  M4_AssignUnity(D);
  p := 0;
  q := 0;
  for i := 0 to 3 do
   for j := 0 to 3 do
    if (i <> l) and (j <> c) then
     begin
      D[p,q] := m[i,j];
      Inc(q);
      if q > 2 then begin Inc(p); q := 0; end;
     end;

  if (l+c) mod 2 = 0 then
   Result := M4_Determinant33_00(D)
  else
   Result := -1 * M4_Determinant33_00(D);
end;

function  M4_Determinant(m : TMATRIX4) : MReal;
begin
 Result :=   m[0,0] * M4_Determinant33(m,0,0)
           + m[0,1] * M4_Determinant33(m,0,1)
           + m[0,2] * M4_Determinant33(m,0,2)
           + m[0,3] * M4_Determinant33(m,0,3);
end;

function M4_Invert(VAR m : TMATRIX4) : Boolean;
var i,j   : Integer;
    det   : MReal;
    det_1 : MReal;
    C     : TMATRIX4;
begin
 det := M4_Determinant(m);
 if det = 0 then
  Result := FALSE
 else
  begin
   Result := TRUE;
   det_1 := 1 / det;    {this will have to change if you use an
                          integer type for MReal}
   for i := 0 to 3 do
    for j := 0 to 3 do
     begin
      C[i,j] := det_1 * M4_Determinant33(m,j,i);
     end;
   M4_AssignM4(m, C);
  end;
end;

{*******************************************************************}

function  V3_Display(v : TVECTOR3) : String;
begin
 Result := Format('%10.3f %10.3f %10.3f',
                 [ v[0],  v[1],  v[2] ]);
end;

function  V4_Display(v : TVECTOR4) : String;
begin
 Result := Format('%10.3f %10.3f %10.3f %10.3f',
                 [ v[0],  v[1],  v[2],  v[3] ]);
end;

function  M4_DisplayALine(m : TMATRIX4; l : Integer) : String;
begin
 if (l >= 0) and (l < 4) then
  Result := Format('%10.3f %10.3f %10.3f %10.3f',
                  [ m[l,0], m[l,1], m[l,2], m[l,3] ]);
end;

end.
