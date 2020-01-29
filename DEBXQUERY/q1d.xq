

<bib>
 {
  for $b in db:open('bstore1')/bib/book
  [some $x in . satisfies $x/publisher = 'Addison-Wesley' and $x/@year > 1991]
  return
    <book year='{ $b/@year }'>
     { $b/title }
    </book>
 }
</bib> 