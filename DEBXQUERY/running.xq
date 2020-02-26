declare function local:min($t)
{
   let $prices := db:open('prices')
   let $p := $prices/prices/book[title = $t]/price
   return min($p)
};

declare function local:store($t,$p)
{
   let $prices := db:open('prices')
   let $p := $prices/prices/book[title = $t and price=$p]
   return $p/source
};


declare function local:min_price($t)
{
      let $min := local:min($t)
      return
      <minprice title='{$t}'>
         {local:store($t,$min)}
         <price>{local:min($t)}</price>
      </minprice>
};

declare function local:rate($rates)
{
 let $n := count($rates)
 return sum($rates) div $n
};

declare function local:data($t)
{
 for $b in db:open('bstore')/bstore/book[title=$t]
 let $mr := local:rate($b/rate)
 where  $mr > 7
        return
        if ($b[editor]) then ($b/editor,$b/publisher,<mrate>{$mr}</mrate>)
        else
          ($b/author[position()<=1],$b/publisher,<mrate>{$mr}</mrate>)
};

<bib>
{

let $mylist := db:open('mylist')
for $t in distinct-values($mylist/mylist/title)
let $d := local:data($t)
where exists($d)
return
<book>{
$d,
local:min_price($t)
}
</book>
}
</bib>