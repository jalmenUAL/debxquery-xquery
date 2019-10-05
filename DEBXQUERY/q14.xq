<figlist>
  {
    for $f in db:open('book')//figure
    return
        <figure>
            { $f/@* }
            { $f/title }
        </figure>
  }
</figlist>