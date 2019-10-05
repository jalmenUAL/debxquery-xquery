<bib>
  {
    for $b in db:open('bstore1')//book
    where $b/publisher = 'Addison-Wesley' and $b/@year > 1991
    order by $b/title
    return
        <book>
            { $b/@year }
            { $b/title }
        </book>
  }
</bib> 