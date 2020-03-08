(: Bug: sum($rates) div $n :)


declare function local:rate($b)
{
  let $doc := db:open('bstore')
  let $bstore := $doc/bstore 
  for $book in $bstore/book
  where $book/title=$b
  let $rates := $book/rate
  return local:medium($rates)
};

declare function local:medium($rates)
{
  let $n := count($rates)
  return
  sum($rates)
};

let $book := db:open('mylist')
let $mylist := $book/mylist
for $items in $mylist/* 
return 
<book>{
$items,
<rate>{local:rate($items)}</rate>
}</book>