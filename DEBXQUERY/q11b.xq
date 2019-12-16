declare function local:books()
{
  
        for $b in db:open('bstore1')//book[author]
        return
            <book>
                { $b/title }
                { $b/author }
            </book>

};
declare function local:references()
{
 for $b in db:open('bstore1')//book[editor]
        return
          <reference>
            { $b/title }
            {$b/editor/affiliation}
          </reference>  
};

<bib>
{local:books()}
{local:references()}
</bib>  