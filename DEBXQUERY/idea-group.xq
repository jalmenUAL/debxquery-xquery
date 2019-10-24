
declare function local:orderby($a)
{
  for $x in $a  group by $y := $x/title  return $x
};

<results>
  {
    local:orderby(
    for $a in db:open('bstore1')//book
   
    return $a)
  }
</results> 