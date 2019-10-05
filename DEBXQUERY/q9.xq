<results>
  {
    for $t in db:open('books')//(chapter | section)/title
    where contains($t/text(), 'XML')
    return $t
  }
</results> 