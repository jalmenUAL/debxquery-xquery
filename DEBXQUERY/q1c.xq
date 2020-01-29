declare function local:boolean($b)
{
  $b/publisher = 'Addison-Wesley' and $b/@year > 1991
};

<bib>
 {
  for $b in db:open('bstore1')/bib/book
  where local:boolean($b)
  return
    <book year='{ $b/@year }'>
     { $b/title }
    </book>
 }
</bib> 