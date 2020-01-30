

declare function local:AnimalOwner(){
for $o in db:open('owner')/owners/owner
for $p in db:open('pet')/pets/pet
for $po in db:open('petOwner')/petOwners/petOwner 
where ($o/id = $po/id) and ($p/code = $po/code) 
return <animalOwner>{($o/id, $p/name, $p/species)}</animalOwner>
};

declare function local:LessThan6(){
  for $ao in local:AnimalOwner()
  where $ao/species = 'cat' or $ao/species = 'dog' 
  and count($ao/id) < 6 
  group by $id := $ao/id
  return <lessThan6><id>{$id}</id></lessThan6>
};

declare function local:CatsAndDogsOwner(){
   let $ao := local:AnimalOwner()
   for $ao1 in $ao 
   for $ao2 in $ao 
   where $ao1/id = $ao2/id and $ao1/species = 'dog' and $ao2/species = 'cat' 
   return (<catsAndDogsOwner>{$ao1/id, $ao1/name}</catsAndDogsOwner>,
           <catsAndDogsOwner>{$ao2/id, $ao2/name}</catsAndDogsOwner>)
            
};

declare function local:NoCommonName(){
   let $cado := local:CatsAndDogsOwner()
   let $seq1 := $cado/id 
   let $seq2 := (for $cdo1 in $cado 
                 for $cdo2 in $cado
                 where not($cdo1/id = $cdo2/id) and ($cdo1/name = $cdo2/name)         
                 return $cdo1/id)
   return <noCommonName>
          <id>{distinct-values($seq1[not(. = $seq2)]/text())}</id>
          </noCommonName>
          
};

declare function local:Guest(){
  for $o in  db:open('owner')/owners/owner
  let $c :=  (for $n in local:NoCommonName()
                 for $l in local:LessThan6()
                 where $l/id=$n/id  
                 return $n/id )
  where $o/id  = $c
  return <guest>{$o/id, $o/name}</guest>
};



local:AnimalOwner()