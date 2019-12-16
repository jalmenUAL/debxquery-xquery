declare function local:title($last,$first)
{
   for $b in db:open('bstore1')/bib/book
                where some $ba in $b/author 
                      satisfies ($ba/last = $last and $ba/first=$first)
                return $b/title
};

<results>
  {
    let $a := db:open('bstore1')//author
    for $last in distinct-values($a/last),
        $first in distinct-values($a[last=$last]/first)
    order by $last, $first
    return
        <result>
            <author>
               <last>{ $last }</last>
               <first>{ $first }</first>
            </author>
            {
               local:title($last,$first)
            }
        </result>
  }
</results> 