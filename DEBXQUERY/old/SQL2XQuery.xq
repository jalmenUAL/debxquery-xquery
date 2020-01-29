

declare function local:AnimalOwner(){
for $o in db:open('owner')/owners/owner
for $p in db:open('pet')/pets/pet
for $po in db:open('petOwner')/petOwners/petOwner
where ($o/id = $po/id) and ($p/code = $po/code) 
return <animalOwner>{($o/id, $p/name, $p/species)}</animalOwner>
};

declare function local:LessThan6(){
  for $ao in (for $ao in local:AnimalOwner()
              where $ao/species = 'cat' or $ao/species = 'dog' 
              return <aux>{$ao/id}</aux>)
  where count($ao/id) < 6 
  group by $id := $ao/id
  return <lessThan6><id>{$id}</id></lessThan6>
};

declare function local:CatsAndDogsOwner(){
   for $ao1 in local:AnimalOwner()
   for $ao2 in local:AnimalOwner()
   where $ao1/id = $ao2/id and $ao1/species = 'dog' and $ao2/species = 'cat' 
   return (<catsAndDogsOwner>{$ao1/id, $ao1/name}</catsAndDogsOwner>,
           <catsAndDogsOwner>{$ao2/id, $ao2/name}</catsAndDogsOwner>)
            
};

declare function local:NoCommonName(){
   let $seq1 := local:CatsAndDogsOwner()/id 
   let $seq2 := (for $cdo1 in local:CatsAndDogsOwner() 
                 for $cdo2 in local:CatsAndDogsOwner()
                 where not($cdo1/id = $cdo2/id) and ($cdo1/name = $cdo2/name)         
                 return $cdo1/id)
   return <noCommonName>
          <id>{distinct-values($seq1[not(. = $seq2)]/text())}</id>
          </noCommonName>
          
};

declare function local:Guest(){
  for $o in  db:open('owner')/owners/owner
  where $o/id  = (for $n in local:NoCommonName()
                 for $l in local:LessThan6()
                 where $n/id = $l/id  (: Primer inner join:)
                 return $n/id )
  return <guest>{$o/id, $o/name}</guest>
};



local:Guest()