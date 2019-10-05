<bib>
{
        for $b in db:open('bstore1')//book[author]
        return
            <book>
                { $b/title }
                { $b/author }
            </book>
}
{
        for $b in db:open('bstore1')//book[editor]
        return
          <reference>
            { $b/title }
            {$b/editor/affiliation}
          </reference>
}
</bib>  