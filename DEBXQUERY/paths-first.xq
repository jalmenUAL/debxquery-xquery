(: Bug: $book/author :)

declare function local:rate($b)
{
  let $book := db:open('bstore')/bstore/book[title=$b]
  let $rates := $book/rate
  return local:medium($rates)
};

declare function local:medium($rates)
{
  let $n := count($rates)
  return
  sum($rates) div $n
};

for $book in db:open('mylist')/mylist/*
return 
<book>{
<rate>{local:rate($book)}</rate>,
$book/author
}</book>