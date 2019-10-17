(: IF THEN ELSE, UNION OPERATOR, ORDER BY, LOCAL FUNCTIONS, NESTED EXPRESSIONS, UNION OF QUERIES, AGGREGATORS, XML DOCS, CONTEXT  :)

declare function local:For($for,$where,$items,$context)
{
  let $ncontext := 
  (
  let $var := $for/Var
  let $path := $for/*[2]
  return
  <for><var>{$var}</var><bound>{$path,
  <values>{
  for $value in 
  local:exp($path,$context)//value/(*|text())
  where local:Where($value,$var,$where,$context)
  return <value>{$value}</value>
  }</values>
  }</bound></for>
  )
  return
  $ncontext union local:exps($items,$ncontext union $context)
};

declare function local:Let($let,$where,$items,$context)
{
  let $ncontext := 
  (
  let $var := $let/Var
  let $path := $let/*[2]
  return
  <let><var>{$var}</var><bound>{$path,
  <values>{
  let $value := 
  local:exp($path,$context)//value/(*|text())
  where local:Where($value,$var,$where,$context)
  return <value>{$value}</value>
  }</values>
  }</bound></let>
  )
  return
  $ncontext union local:exps($items,$context union $ncontext)
};


declare function local:Where($value,$var,$where,$context)
{
 if (empty($where)) then true()
   else
   if (empty($where//VarRef[Var/@name=data($var/@name)])) then 
   let $path := "declare variable $xml external; $xml" ||  
   "[" || local:Path($where/*,$context) || "]"
   return xquery:eval($path,map{'xml': $value})
   else  
   copy $c := $where
        modify(
          for $x in $c//VarRef[Var/@name=data($var/@name)]
          return
          replace node $x  with ())
  return 
  let $path := "declare variable $xml external; $xml" || 
  "[" || local:Path($c/*,$context) || "]"
  return xquery:eval($path,map{'xml': $value})
};


declare function local:IterPath($query,$context)
{  
  let $exp := head($query/*)
  let $steps := tail($query/*)
  for $vexp in local:exp($exp,$context)//value/(*|text())
  let $path :=  
          fold-left(for-each($steps,function($x){local:Path($x,$context)}),"",
          function($x,$y){$x || "/" || $y})
  let $let := "declare variable $xml external; $xml/" || $path        
  return <value>{xquery:eval($let,map{'xml':$vexp})}</value> 
};

declare function local:CachedPath($query,$context)
{  

  let $exp := head($query/*)
  let $steps := tail($query/*)
  for $vexp in local:exp($exp,$context)//value/(*|text())
  let $path :=  
          fold-left(for-each($steps,function($x){local:Path($x,$context)}),"",
          function($x,$y){$x || "/" || $y})
  let $let := "declare variable $xml external; $xml/" || $path        
  return <value>{xquery:eval($let,map{'xml':$vexp})}</value> 
};
 
declare function local:Path($step,$context)
{
  
    if (name($step)="Root") then "root()" 
     else
   if (name($step)="DbOpen") then 
            "db:open('" || data($step/Str/@value) || "')"
   else
   if (name($step)="FnDoc") then 
            "doc('" || data($step/Str/@value) || "')"
   else
    if (name($step)="FnCollection") then 
            "collection('" || data($step/Str/@value) || "')"
     else
   if (name($step)="VarRef") then 
             let $varn := $step/Var/@name
             return
             fold-left(for-each($context[var/Var/@name=data($varn)][1]/bound/*,function($x){local:Path($x,$context)}),".",
                  function($x,$y){$x || "/" || $y})           
    else
    if (name($step)="CachedPath") 
          then fold-left(for-each($step/*,function($x){local:Path($x,$context)}),".",
                  function($x,$y){$x || "/" || $y})
   else
   if (name($step)="IterPath") 
          then fold-left(for-each($step/*,function($x){local:Path($x,$context)}),".",
                  function($x,$y){$x || "/" || $y})    
   else           
   if (name($step)="CachedFilter") 
          then 
          local:Path(head($step/*),$context) || "[" ||
          fold-left(for-each(tail($step/*),function($x){local:Path($x,$context)}),".",
                  function($x,$y){$x || "/" || $y}) || "]"
    else
   if (name($step)="IterStep") then 
                if ($step/CmpG) then 
                let $cond1 := local:Path(($step/CmpG/*)[1],$context)
                let $cond2 := local:Path(($step/CmpG/*)[2],$context)
                return $step/@axis || "::" || $step/@test || "[" || $cond1 || $step/CmpG/@op || $cond2 ||"]"  
                else $step/@axis || "::" || $step/@test
   else 
   if (name($step)="CachedStep") then "[" || $step/@axis || "::" || $step/@test || "]"   
   else           
   if (name($step)="FnNot") 
          then "not(" || fold-left(for-each($step/*,function($x){local:Path($x,$context)}),".",
                  function($x,$y){$x || "/" || $y}) || ")"                               
   else
   if (substring(name($step),1,2)="Fn") then
             let $count := count($step/*)
             let $f := function-lookup(QName("http://www.w3.org/2005/xpath-functions",
             substring-before(data($step/@name),"(")),$count) 
             let $args := [for $exp in $step/* return [local:Path($exp,$context)]]
             return 
             substring-before(data($step/@name),"(") || "(" || $args || ")" 
   
   else 
   if (name($step)="CmpG") then
              let $cond1 := local:Path(($step/*)[1],$context)
              let $cond2 := local:Path(($step/*)[2],$context)
              return "(" || $cond1 || $step/@op || $cond2 || ")"  
   else 
   if (name($step)="And") then
           "(" || local:Path(($step/*)[1],$context) || " and " ||   local:Path(($step/*)[2],$context) || ")"
   else 
   if (name($step)="Or") then
           "(" || local:Path(($step/*)[1],$context) || " or " ||   local:Path(($step/*)[2],$context) || ")"          
   else 
   if (name($step)="Empty") then 
      "()"
   else
   if ($step/@type="xs:string") then  "'" || data($step/@value)|| "'"
   else
   data($step/@value)            
}; 
 
 
 
declare function local:exp($query,$context)
{ (:IterStep and CachedStep are part of Iter-Cached-Paths:)
  
  if (name($query)="Root") then "root()"
  else
  if (name($query)="DbOpen") then 
  let $path := "db:open('" || data($query/Str/@value) || "')"
  return
  <DbOpen>{
  $query/*,
  <values>{<value><root>{xquery:eval($path)}</root></value>
  }</values>
  }</DbOpen> else
  if (name($query)="FnDoc") then 
  let $path := "doc('" || data($query/Str/@value) || "')"
  return
  <FnDoc>{
  $query/*,
  <values>{<value><root>{xquery:eval($path)}</root></value>
  }</values>
  }</FnDoc> else
  if (name($query)="FnCollection") then 
  let $path := "collection('" || data($query/Str/@value) || "')"
  return
  <FnCollection>{
  $query/*,
  <values>{<value><root>{xquery:eval($path)}</root></value>
  }</values>
  }</FnCollection> else
  if (name($query)="VarRef") then 
  let $varn := $query/Var/@name
  return
  <VarRef>{
  $query/*,
  <values>{
  $context[var/Var/@name=data($varn)][1]//value
  }</values>
  }</VarRef> 
  else
  if (name($query)="CachedPath") then 
  <CachedPath>{
  $query/*,
  <values>{      
  local:CachedPath($query,$context)  
  }</values>
  }</CachedPath> 
  else 
  if (name($query)="IterPath") then 
  <IterPath>{
  $query/*,
  <values>{   
  local:IterPath($query,$context) 
  }</values>
  }</IterPath> 
  else  
  if (name($query)="CachedFilter") then 
  <CachedFilter>{
  $query/*,
  <values>{   
  local:CachedFilter($query,$context) 
  }</values>
  }</CachedFilter> 
  else 
  if (name($query)="FnNot") then
  <FnNot>{
  $query/*,
  <values>{   
  for $value in
  local:exp($query/*,$context)//value/(*|text())
  return <value>not($value)</value>
  }</values> 
  }</FnNot>
  else 
  if (substring(name($query),1,2)="Fn") then 
  let $count := count($query/*)
  let $f := function-lookup(QName("http://www.w3.org/2005/xpath-functions",
  substring-before(data($query/@name),"(")),$count) 
  let $args := [for $exp in $query/* return [local:exp($exp,$context)//value/(*|text())]]
  return 
  element {name($query)} {
  $query/*, 
  <values><value>{apply($f,$args)}</value></values>
  }      
  else
  if  (name($query)="CmpG") then
  let $cond1 := local:exp(($query/*)[1],$context)//value/(*|text())
  let $cond2 := local:exp(($query/*)[2],$context)//value/(*|text())
  return <values><value>{xquery:eval("'"|| $cond1 || $query/@op || $cond2 || "'" )}</value></values> 
  else
  if (name($query)="And") then
  local:exp(($query/*)[1],$context)//value/(*|text()) and local:exp(($query/*)[2],$context)//value/(*|text())
  else
  if (name($query)="Or") then
  local:exp(($query/*)[1],$context)//value/(*|text()) or local:exp(($query/*)[2],$context)//value/(*|text())
  else
  if (name($query)="Empty") then 
  element {name($query)} {<values><value>()</value></values>}
  else 
  element {name($query)} {$query/@*,$query/*,<values><value>{data($query/@value)}</value></values>}                       
};


declare function local:CachedFilter($query,$context)
{
  let $exp := ($query/*)[1]
  let $filter := ($query/*)[2]
  return   
  if (name($filter)="CachedPath") 
  then
  for $vexp in 
  local:exp(<CachedPath>{$exp,$filter/*}</CachedPath>,$context)//value/(*|text())
  return
  <value>{$vexp}</value>
  else 
  if (name($filter)="Quantifier") 
  then  
  let $varsome :=  ($filter/GFLWOR/*)[1]/Var
  return
  copy $c := ($filter/GFLWOR/*)[2]
  modify(
  for $x in $c//VarRef[Var/@name=data($varsome/@name)]
  return
  replace node $x  with ($filter/GFLWOR/*)[1]/CachedPath/*
        )
  return 
  if ($filter/@type="some") then 
  local:exp(<CachedFilter>{$exp,$c}</CachedFilter>,$context)
  else 
  local:exp(<CachedFilter>{$exp,
  <FnNot><Quantifier type="some"><GFLWOR>{($filter/GFLWOR/*)[1]}
  <FnNot>{($filter/GFLWOR/*)[2]}</FnNot></GFLWOR></Quantifier>
  </FnNot>}</CachedFilter>,$context)   
  else 
  if (name($filter)="FnNot") then 
  let $arg := $filter/*
  for $vexp in local:exp($exp,$context)//value/(*|text())  
  where not(some $c in local:exp(<CachedFilter>{$exp,$arg}</CachedFilter>,$context)//value/(*|text()) satisfies $c=$vexp) 
  return <value>{$vexp}</value>
  else
  if (name($filter)="CmpG") then
  let $op := data($filter/@op)
  let $arg1 := ($filter/*)[1]
  let $arg2 := ($filter/*)[2] 
  for $vexp in local:exp($exp,$context)//value/(*|text())
  let $let := "declare variable $xml1 external; declare variable $xml2 external; 
  let $ls := $xml1" || fold-left(for-each($arg1,function($x){local:Path($x,$context)}),"",
                  function($x,$y){$x || "/" || $y}) || 
  " let $rs := $xml2" || fold-left(for-each($arg2,function($x){local:Path($x,$context)}),"",
                  function($x,$y){$x || "/" || $y}) || " return $ls " || $op || " $rs"
  let $vlet := xquery:eval($let,map { 'xml1': $vexp , 'xml2' : $vexp })
  where $vlet
  return <value>{$vexp}</value>
  else  
  <value>{(local:exp($exp,$context)//value/(*|text()))
            [xs:integer(local:exp($filter,$context)//value/(*|text()))]}</value>
};

declare function local:crossCElem($result)
{
if (count($result)=1) then $result else  
let $max := max(for $item in $result return count($item//values/value))
return 
<values>{
for $i in 1 to $max return 
<value>
{
for $item in $result return 
(element {name($item)} {$item/*[not(name(.)="values")],$item//values/value[$i]})
}
</value>
}</values>

};


declare function local:crossUnion($result)
{
if (count($result)=1) then $result else  
let $max := max(for $item in $result return count($item//values/value))
return 
<Union>
<values>{
for $i in 1 to $max return 
<value>
{
for $item in $result return 
element {name($item)} {($item/*[not(name(.)="values")],$item//values/value[$i])}
}
</value>
}</values>
</Union>
};

declare function local:crossList($result)
{
if (count($result)=1) then $result else  
let $max := max(for $item in $result return count($item//values/value))
return 
<List>
<values>{
for $i in 1 to $max return 
<value>
{
for $item in $result return 
element {name($item)} {($item/*[not(name(.)="values")],$item//values/value[$i])}
}
</value>
}</values>
</List>
};

 
declare function local:CElem($query,$items,$context)
{
<CElem>{$query/QNm,local:crossCElem(local:exps($query/*,$context))}</CElem> union local:exps($items,$context)
};

declare function local:GFLWOR($query,$items,$context)
{
<GLFWOR>{local:GFLWORitems($query/* union $items,$context)}</GLFWOR>  
};

declare function local:CAttr($query,$items,$context)
{ 
(<CAttr>{
local:exps($query/*,$context),local:exps($query/*,$context)//values
}</CAttr>) 
union local:exps($items,$context)   
};

declare function local:If($query,$items,$context)
{
let $cond := ($query/*)[1]
let $then := ($query/*)[2]
let $else := ($query/*)[3]
return
local:exp(<Union><CachedFilter>{$then,$cond}</CachedFilter>
<CachedFilter>{$then,<FnNot>{$cond}</FnNot>}</CachedFilter></Union>,$context)
union local:exps($items,$context)
};

declare function local:Union($query,$items,$context)
{
local:crossUnion(local:exps($query/*,$context)) union local:exps($items,$context)
};

declare function local:List($query,$items,$context)
{
local:crossList(local:exps($query/*,$context)) union local:exps($items,$context)
};
 
 
declare function local:exps($query,$context)
{ 
if (name(head($query))="GFLWOR") then 
local:GFLWOR(head($query),tail($query),$context)
else if (name(head($query))="For") then 
local:For(head($query),tail($query)[name(.)="Where"],tail($query),$context)
else if (name(head($query))="Let") then 
local:Let(head($query),tail($query)[name(.)="Where"],tail($query),$context)
else if (name(head($query))="CElem") then 
local:CElem(head($query),tail($query),$context)
else if (name(head($query))="CAttr") then 
local:CAttr(head($query),tail($query),$context)
else if (name(head($query))="Union") then 
local:Union(head($query),tail($query),$context)
else if (name(head($query))="List") then 
local:List(head($query),tail($query),$context)
else if (name(head($query))="If") then 
local:If(head($query),tail($query),$context) 
else if (name(head($query))="Where") then 
local:exps(tail($query),$context)
else if (name(head($query))="QNm") then 
local:exps(tail($query),$context)
else if (head($query)) then
(local:exp(head($query),$context) union local:exps(tail($query),$context))
else ()
};


declare function local:GFLWORitems($items,$context)
{
if (name(head($items))="For") then local:For(head($items),tail($items)[name(.)="Where"],tail($items),$context)
else if (name(head($items))="Let") then local:Let(head($items),tail($items)[name(.)="Where"],tail($items),$context)
else local:CElem(head($items),tail($items),$context)                      
};

 
let $query :=
xquery:parse(
"<bib>
 {
  for $b in db:open('bstore1')/bib/book 
  where $b/publisher='Addison-Wesley' 
  return
  $b/title
 }
</bib> 
")
return local:exps($query/QueryPlan/*,())

 