declare function local:min_price($doc,$t)
{
   let $p := $doc//book[title = $t]/price
   return min($p)
};

<results>
  {
    let $doc := db:open('prices')
    for $t in distinct-values($doc//book/title)
     
    return
      <minprice title='{ $t }'>
        <price>{ local:min_price($doc,$t) }</price>
      </minprice>
  }
</results>