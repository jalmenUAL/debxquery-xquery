<results>
{
    for $b in db:open('bstore1')/bib/book
    return
        <result>
            { $b/title }
            { $b/author  }
        </result>
}
</results> 