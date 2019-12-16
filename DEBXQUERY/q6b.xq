declare function local:main_authors($b)
{
  for $a in $b/author[position()<=2]  
                return $a
};


<bib>
  {
    for $b in db:open('bstore1')//book
    where count($b/author) > 0
    return
        <book>
            { $b/title }
            {
             local:main_authors($b)  
            }
            {
                if (count($b/author) > 2)
                 then <et-al/>
                 else ()
            }
        </book>
  }
</bib>