declare function local:price_entry($title)
{
 for $a in db:open('bstore2')//entry
 where $a/title=$title
 return $a/price/text()  
};

<books-with-prices>
  {
    for $b in db:open('bstore1')//book
    return
    let $price_entry := local:price_entry($b/title)
    return 
    if (exists($price_entry)) then
        <book-with-prices>
            { $b/title }
            <price-bstore2>{ $price_entry }</price-bstore2>
            <price-bstore1>{ $b/price/text() }</price-bstore1>
        </book-with-prices>
   else ()
  }
</books-with-prices>