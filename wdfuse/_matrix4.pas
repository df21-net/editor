unit _matrix4;

{***********************************************************************}
{ MATRIX4 : matrix used for 3D transformations utilities                }
{                                                                       }
{ Copyright (c) 1996 Yves Borckmans                                     }
{***********************************************************************}
{                                                                       }
{ All the matrixes *MUST* be in the form                                }
{                                                                       }
{   a b c d                                                             }
{   e f g h                                                             }
{   i j k l                                                             }
{   0 0 0 1                                                             }
{                                                                       }
{ because of simplifications in the calculations                        }
{***********************************************************************}

interface

TYPE
 MReal     = Real;
 TVECTOR4  = array[0..3] of MReal;
 TMATRIX4  = array[0..3, 0..3] of MReal;

procedure M4_MakeUnity(VAR m : TMATRIX4);
procedure M4_AssignMatrix4(VAR m : TMATRIX4; n : TMATRIX4);
procedure M4_Transpose(VAR m : TMATRIX4);
procedure M4_MultiplyByReal(VAR m : TMATRIX4; r : MReal);
procedure M4_PreMultiplyByMatrix4(VAR m : TMATRIX4; n : TMATRIX4);
procedure M4_PostMultiplyByMatrix4(VAR m : TMATRIX4; n : TMATRIX4);
function  M4_Determinant(m : TMATRIX4) : MReal;
function  M4_Invert(VAR m : TMATRIX4) : Boolean;

{encore a faire

function M4_IsUnity(m : TMATRIX4) : Boolean;

tester que A_1 * A = A * A_1 = unity

procedure M4_RotateXDeg(VAR m : TMATRIX4; angle : MReal);
procedure M4_RotateYDeg(VAR m : TMATRIX4; angle : MReal);
procedure M4_RotateZDeg(VAR m : TMATRIX4; angle : MReal);
procedure M4_RotateXRad(VAR m : TMATRIX4; angle : MReal);
procedure M4_RotateYRad(VAR m : TMATRIX4; angle : MReal);
procedure M4_RotateZRad(VAR m : TMATRIX4; angle : MReal);
procedure M4_TranslateXYZ(VAR m : TMATRIX4; x,y,z : MReal);

procedure M4_TranslateV4(VAR m : TMATRIX4; v : TVECTOR4);

toutes les fonctions utiles sur les vecteurs
V4_Normalize
V4_DotProduct
V4_CrossProduct

etc.
}

implementation

procedure M4_MakeUnity(VAR m : TMATRIX4);
var i,j : Integer;
begin
 for i := 0 to 3 do for j := 0 to 3 do m[i,j] := 0;
 for i := 0 to 3 do m[i,i] := 1;
end;

procedure M4_AssignMatrix4(VAR m : TMATRIX4; n : TMATRIX4);
var i,j   : Integer;
    value : MReal;
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

procedure M4_PreMultiplyByMatrix4(VAR m : TMATRIX4; n : TMATRIX4);
var i,j,k : Integer;
    value : MReal;
    El    : array[0..3, 0..3] of MReal;
begin
 for i := 0 to 3 do for j := 0 to 3 do El[i,j] := m[i,j];

 for i := 0 to 3 do
  for j := 0 to 3 do
   begin
    value := 0;
    for k := 0 to 3 do value := n[i,k] * El[i,j];
    m[i,j] := value;
   end;
end;

procedure M4_PostMultiplyByMatrix4(VAR m : TMATRIX4; n : TMATRIX4);
var i,j,k : Integer;
    value : MReal;
    El    : array[0..3, 0..3] of MReal;
begin
 for i := 0 to 3 do for j := 0 to 3 do El[i,j] := m[i,j];

 for i := 0 to 3 do
  for j := 0 to 3 do
   begin
    value := 0;
    for k := 0 to 3 do value := El[i,k] * n[i,j];
    m[i,j] := value;
   end;
end;

function  M4_Determinant(m : TMATRIX4) : MReal;
begin
 Result :=  m[1,1] * ( m[2,2] * m[3,3] - m[2,3] * m[3,2] )
	  - m[1,2] * ( m[2,1] * m[3,3] - m[2,3] * m[3,1] )
	  + m[1,3] * ( m[2,1] * m[3,2] - m[2,2] * m[3,1] );
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
   det_1 := 1 / det;

   {calculate cofactors matrix:
    C00 := m[0,0]*(m[1,1]*m[2,2]-m[2,1]*m[1,2]);
    C01 := m[0,1]*(m[2,0]*m[1,2]-m[1,0]*m[2,2]);
    C02 := m[0,2]*(m[1,0]*m[2,1]-m[2,0]*m[1,1]);
    C03 := 0;
    C10 := m[1,0]*(m[0,1]*m[2,2]-m[2,1]*m[0,2]);
    C11 := m[1,1]*(m[0,0]*m[2,2]-m[2,0]*m[0,2]);
    C12 := m[1,2]*(m[0,0]*m[2,0]-m[2,0]*m[0,1]);
    C13 := 0;
    C20 := m[2,0]*(m[0,1]*m[1,2]-m[1,1]*m[0,2]);
    C21 := m[2,1]*(m[1,0]*m[0,2]-m[0,0]*m[1,2]);
    C22 := m[2,2]*(m[0,0]*m[1,1]-m[1,0]*m[0,1]);
    C23 := 0;
    C30 := 0;
    C31 := 0;
    C32 := 0;
    C33 := det;

    now transpose cofactor matrix and divide it by det:}
    C[0,0] := det_1 * m[0,0]*(m[1,1]*m[2,2]-m[2,1]*m[1,2]);
    C[1,0] := det_1 * m[0,1]*(m[2,0]*m[1,2]-m[1,0]*m[2,2]);
    C[2,0] := det_1 * m[0,2]*(m[1,0]*m[2,1]-m[2,0]*m[1,1]);
    C[3,0] := 0;
    C[0,1] := det_1 * m[1,0]*(m[0,1]*m[2,2]-m[2,1]*m[0,2]);
    C[1,1] := det_1 * m[1,1]*(m[0,0]*m[2,2]-m[2,0]*m[0,2]);
    C[2,1] := det_1 * m[1,2]*(m[0,0]*m[2,0]-m[2,0]*m[0,1]);
    C[3,1] := 0;
    C[0,2] := det_1 * m[2,0]*(m[0,1]*m[1,2]-m[1,1]*m[0,2]);
    C[1,2] := det_1 * m[2,1]*(m[1,0]*m[0,2]-m[0,0]*m[1,2]);
    C[2,2] := det_1 * m[2,2]*(m[0,0]*m[1,1]-m[1,0]*m[0,1]);
    C[3,2] := 0;
    C[0,3] := 0;
    C[1,3] := 0;
    C[2,3] := 0;
    C[3,3] := 1;

    { Ok, now we just have to put all the stuff back in m matrix }
    M4_AssignMatrix4(m, C);
  end;
end;

end.
