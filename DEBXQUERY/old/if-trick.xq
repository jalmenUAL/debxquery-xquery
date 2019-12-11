(:<bib>
 {
  for $b in db:open('bstore1')/bib/book
  let $a :=  $b
  return
  $a[publisher = 'Addison-Wesley']/author union $a[not(publisher = 'Addison-Wesley')]/title
}  
</bib> 
:)

(:
<bib>
 {
  for $b in db:open('bstore1')/bib/book
  let $a :=  $b
  return
  if ($b/publisher = 'Addison-Wesley') then 
  $a/author else ()
} 
</bib>  
:)

<bib>
 {
  for $b in db:open('bstore1')/bib/book
  let $a :=  $b/author 
  return
  ($a union ($b/title))[$b/publisher="Addison-Wesley"]
} 
</bib>  
  