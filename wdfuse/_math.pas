unit _math;

interface

function real_min(a,b : Real) : Real;
function real_max(a,b : Real) : Real;


implementation

function real_min(a,b : Real) : Real;
begin
 if a < b then
  real_min := a
 else
  real_min := b;
end;

function real_max(a,b : Real) : Real;
begin
 if a > b then
  real_max := a
 else
  real_max := b;
end;

end.
 