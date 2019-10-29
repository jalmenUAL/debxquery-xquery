for $p in db:open('report')//section[section.title = 'Procedure']
where not(some $a in $p//anesthesia satisfies
        $a << ($p//incision)[1] )
return $p