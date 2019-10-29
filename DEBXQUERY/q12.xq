<bib>
{
    for $book1 in db:open('bstore1')//book,
        $book2 in db:open('bstore1')//book
    let $aut1 := for $a in $book1/author 
                  
                 return $a
    let $aut2 := for $a in $book2/author 
                  
                 return $a
    where $book1 << $book2
    and not($book1/title = $book2/title)
    and deep-equal($aut1, $aut2) 
    return
        <book-pair>
            { $book1/title }
            { $book2/title }
        </book-pair>
}
</bib> 