for $s in db:open('report')//section[section.title = 'Procedure']
return ($s//instrument)[position()<=2]