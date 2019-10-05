let $i2 := (db:open('report')//incision)[2]
for $a in (db:open('report')//action)[. >> $i2][position()<=2]
return $a//instrument 