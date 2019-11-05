(:insort [] = []
insort (x:xs) = insert x (insort xs) 

insert x [] = [x]
insert x (y:ys) = if x >= y then (x:y:ys)else (y: (insert x ys))
:)


declare function local:insert($x,$seq)
{
  if (empty($seq)) then ($x)
  else if ($x >= head($seq)) then ($x,$seq) else (head($seq),local:insert($x,tail($seq)))
};

declare function local:insort($seq)
{
  if (empty($seq)) then ()
  else
  local:insert(head($seq),local:insort(tail($seq)))
};

local:insort((2,1,3))