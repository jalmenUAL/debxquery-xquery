declare function local:min($doc,$t)
{
   let $p := $doc//book[title = $t]/price
   return min($p)
};

declare function local:min_price($doc,$t)
{
      <minprice title='{ $t }'>
        <price>{ local:min($doc,$t) }</price>
      </minprice>
};
declare function local:data($books,$t)
{
 for $b in db:open('bstore1')//book[title=$t]
        return
        if ($b[editor]) then ($b/editor,$b/publisher)
        else
          ($b/author,$b/publisher)
};

<bib>
{
let $prices := db:open('prices')
let $mylist := db:open('mylist')
let $books := db:open('bstore1')
for $t in distinct-values($prices//title)
return
<book>{
local:data($books,$t),
local:min_price($prices,$t)
}
</book>
}
</bib>  