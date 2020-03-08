(: Bug: $book/rates :)


declare function local:rate($b)
{
  let $doc := db:open('bstore')
  let $bstore := $doc/bstore 
  for $book in $bstore/book
  where $book/title=$b
  let $rates := $book/rates
  return local:medium($rates)
};

declare function local:medium($rates)
{
  let $n := count($rates)
  return
  sum($rates) div $n
};

declare function local:author($b)
{
  let $book := db:open('bstore')/bstore/book[title=$b]
  return $book/author
};

declare function local:publisher($b)
{
  let $book := db:open('bstore')/bstore/book[title=$b]
  return $book/publisher
};

for $book in db:open('mylist')/mylist/*
return 
<book>{
local:author($book),
local:publisher($book),
<rate>{local:rate($book)}</rate>
}</book>