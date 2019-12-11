(: IF THEN ELSE, ORDER BY, UNION, LOCAL FUNCTIONS, UNION, NESTED, AGGREGATORS  :)

declare function local:For($for,$where,$items,$context)
{
  let $ncontext := 
  (
  let $var := $for/Var
  let $path := $for/*[2]
  return
  <for><var>{$var}</var><bound>{$path,
  <values>{
  for $x in 
  local:exp($path,$context)//value/(*|text())
  where local:Cond($x,$var,$where,$context)=true()
  return <value>{$x}</value>
  }</values>
  }</bound></for>
  )
  return
  $ncontext union local:QueryPlan($items,$ncontext union $context)
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
  let $x := 
  local:exp($path,$context)//value/(*|text())
  where local:Cond($x,$var,$where,$context)=true()
  return <value>{$x}</value>
  }</values>
  }</bound></let>
  )
  return
  $ncontext union local:QueryPlan($items,$context union $ncontext)
};


declare function local:Cond($value,$var,$where,$context)
{
   if (empty($where)) then true()
   else
   if (empty($where//VarRef[Var/@name=data($var/@name)])) then 
   let $path := "declare variable $xml external; $xml/" || 
   "[" || local:path(<CachedFilter>{<VarRef>{$var}</VarRef>,$where/*}</CachedFilter>,$context) || "]"
   return xquery:eval($path,map{'xml': $value})
   else  
   copy $c := $where
        modify(
          for $x in $c//VarRef[Var/@name=data($var/@name)]
          return
          replace node $x  with ())
  return 
  let $path := "declare variable $xml external; $xml/" || "[" ||
  local:path(<CachedFilter>{<VarRef>{$var}</VarRef>,$c/*}</CachedFilter>,$context) || "]"
  return xquery:eval($path,map{'xml': $value})
};


declare function local:IterPath($query,$context)
{
  if ($query/Root) then 
  let $path :=  
                 "root()"+fold-left(for-each($query/*,function($x){local:path($x,$context)}),"",
                    function($x,$y){$x || "/" || $y})
  return <value>{xquery:eval($path)}</value>
  else
  if ($query/DbOpen) then
            let $path :=  
                 fold-left(for-each($query/*,function($x){local:path($x,$context)}),"",
                    function($x,$y){$x || "/" || $y})
  return <value>{xquery:eval($path)}</value>
  else
  if ($query/FnCollection) then
            let $path :=  
                 fold-left(for-each($query/*,function($x){local:path($x,$context)}),"",
                    function($x,$y){$x || "/" || $y})
  return <value>{xquery:eval($path)}</value>
  else
  if ($query/FnDoc) then
            let $path :=  
                 fold-left(for-each($query/*,function($x){local:path($x,$context)}),"",
                    function($x,$y){$x || "/" || $y})
  return <value>{xquery:eval($path)}</value>
  
  else <errorIterPath/>
};

declare function local:CachedPath($query,$context)
{  
  if ($query/FnDoc) then
                  let $path := "doc('" || data($query/FnDoc/Str/@value) || "')"  
                  || fold-left(for-each(tail($query/*),function($x){local:path($x,$context)}),"",
                  function($x,$y){$x || "/" || $y})
  return <value>{xquery:eval($path)}</value>
  else
  if ($query/FnCollection) then
                  let $path := "collection('" || data($query/FnCollection/Str/@value) || "')"  
                  || fold-left(for-each(tail($query/*),function($x){local:path($x,$context)}),"",
                  function($x,$y){$x || "/" || $y})
  return <value>{xquery:eval($path)}</value>
  else
  if ($query/DbOpen) then
                  let $path := "db:open('" || data($query/DbOpen/Str/@value) || "')"  
                  || fold-left(for-each(tail($query/*),function($x){local:path($x,$context)}),"",
                  function($x,$y){$x || "/" || $y})
  return <value>{xquery:eval($path)}</value>
  else 
  if ($query/CachedFilter) then
                  let $path := "declare variable $xml external; $xml" || 
                  fold-left(for-each(tail($query/*),function($x){local:path($x,$context)}),"",
                  function($x,$y){$x || "/" || $y})
                  for $value in local:CachedFilter($query/CachedFilter,$context)/*
                  return <value>{xquery:eval($path,map { 'xml': $value })}</value>
  else 
  let $var := $query/VarRef/Var/@name   
  let $path := "declare variable $xml external; $xml" || 
                 fold-left(for-each($query/*,function($x){local:path($x,$context)}),"",
                  function($x,$y){$x || "/" || $y})                  
  let $as := $context[var/Var/@name=data($var)][1]/*/values/value/(*|text())
  for $value in xquery:eval($path,map { 'xml': $as })
  return 
  <value>{data($value)}</value>
};
 
declare function local:path($step,$context)
{
  
    if (name($step)="Root") then "root()" 
    else
    if (name($step)="CachedPath") 
          then fold-left(for-each($step/*,function($x){local:path($x,$context)}),".",
                  function($x,$y){$x || "/" || $y})
   else
   if (name($step)="IterPath") 
          then fold-left(for-each($step/*,function($x){local:path($x,$context)}),".",
                  function($x,$y){$x || "/" || $y})    
   else           
   if (name($step)="CachedFilter") 
          then fold-left(for-each($step/*,function($x){local:path($x,$context)}),".",
                  function($x,$y){$x || "/" || $y})           
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
             fold-left(for-each($context[var/Var/@name=data($varn)][1]/*/values/value,
             function($x){local:path($x,$context)}),".",
                  function($x,$y){$x || "/" || $y})
                       
   else
   if (substring(name($step),1,2)="Fn") then
             let $count := count($step/*)
             let $f := function-lookup(QName("http://www.w3.org/2005/xpath-functions",
             substring-before(data($step/@name),"(")),$count) 
             let $args := [for $exp in $step/* return [local:path($exp,$context)]]
             return 
             substring-before(data($step/@name),"(") || "(" || $args || ")" 
   else
   if (name($step)="IterStep") then 
                if ($step/CmpG) then 
                let $cond1 := local:path(($step/CmpG/*)[1],$context)
                let $cond2 := local:path(($step/CmpG/*)[2],$context)
                return $step/@axis || "::" || $step/@test || "[" || $cond1 || $step/CmpG/@op || $cond2 ||"]"  
                else $step/@axis || "::" || $step/@test
   else 
   if (name($step)="CachedStep") then "[" || $step/@axis || "::" || $step/@test || "]"    
   else if (name($step)="CmpG") then
              let $cond1 := local:path(($step/*)[1],$context)
              let $cond2 := local:path(($step/*)[2],$context)
              return "(" || $cond1 || $step/@op || $cond2 || ")"  
   else if (name($step)="And") then
           "(" || local:path(($step/*)[1],$context) || " and " ||   local:path(($step/*)[2],$context) || ")"
   else if (name($step)="Or") then
           "(" || local:path(($step/*)[1],$context) || " or " ||   local:path(($step/*)[2],$context) || ")"          
   else if ($step/@type="xs:string") then  "'" || data($step/@value)|| "'"
             else
             data($step/@value)            
}; 
 
 
 
declare function local:exp($query,$context)
{
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
             $context[var/Var/@name=data($varn)][1]/*/values/value
             }</values>
             }</VarRef> 
             else
             if (name($query)="GFLWOR") then   
             <GFLWOR>{  
             <values>{
             local:GFLWOR($query,(),$context)/*/values/value
             }</values>
             }</GFLWOR>
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
             (:if (name($query)="CmpG") then
             let $op := data($query/@op)
             let $arg1 := ($query/*)[1]
             let $arg2 := ($query/*)[2]        
             for $varg1 in local:exp($arg1,$context)//value/(*|text())
             for $varg2 in local:exp($arg2,$context)//value/(*|text())
             let $vcomp := xquery:eval(
               "declare variable $xml1 external; declare variable $xml2 external; $xml1 " || $op || " $xml2",
             map {'xml1': $varg1, 'xml2':$varg2})
             return <CmpG>{$query/@*,$query/*,
             <values><value>{$vcomp}</value></values>}</CmpG>
             else:)
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
  let $varsome :=  ($filter/GFLWOR/*)[1]/Var
  return
  if (name($filter)="Quantifier") 
  then  
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
  if (name($filter)="GmpG") then
  let $op := data($filter/@op)
  let $arg1 := ($filter/*)[1]
  let $arg2 := ($filter/*)[2] 
  for $vexp in local:exp($exp,$context)//value/(*|text())
  let $let := "declare variable $xml1 external; declare variable $xml2 external; 
  let $ls := $xml1" || fold-left(for-each($arg1,function($x){local:path($x,$context)}),"",
                  function($x,$y){$x || "/" || $y}) || 
  " let $rs := $xml2" || fold-left(for-each($arg2,function($x){local:path($x,$context)}),"",
                  function($x,$y){$x || "/" || $y}) || " return $ls " || $op || " $rs"
  let $vlet := xquery:eval($let,map { 'xml1': $vexp , 'xml2' : $vexp })
  where $vlet
  return <value>{$vexp}</value>
  else  <value>{(local:exp($exp,$context)//values/value/(*|text()))
            [xs:integer(local:exp($filter,$context)//value/(*|text()))]}</value>
};


declare function local:cross($result)
{
if (count($result)=1) then $result else  
let $head := head($result)
let $tail :=  tail($result/*[not(name(.)="For") and not(name(.)="Let") and not(name(.)="Where")])   
let $max := max(for $item in $tail return count($item/values/value))
return 
<values>{
for $i in 1 to $max return 
<value>
<CElem>{$head/*,for $item in $tail return 
element {name($item)} {($item/*[not(name(.)="values")],$item/values/value[$i])}
}</CElem>
</value>
}</values>
};


declare function local:CElem($query,$items,$context)
{  
<CElem>{$query/QNm,local:QueryPlan($query/* union $items, $context)}</CElem>
};

declare function local:GFLWOR($query,$items,$context)
{
<GLFWOR>{local:GFLWORitems($query/* union $items,$context)}</GLFWOR>  
};

declare function local:CAttr($query,$items,$context)
{ 
(<CAttr>{
local:QueryPlan($query/*,$context),local:QueryPlan($query/*,$context)/*/values
}
</CAttr>) union local:QueryPlan($items,$context)   
};

declare function local:If($query,$items,$context)
{
  let $cond := ($query/*)[1],
  $then := ($query/*)[2],
  $else := ($query/*)[3],
  $vthen := local:exp($then,$context),
  $velse := local:exp($else,$context)
  return
   <If>{$query/*,<values>{
  for $vcond in local:exp($cond,$context)//value/(*|text())
  return  
  if (xs:boolean($vcond)) then $vthen//values/value 
              else $velse//values/value
  }</values>}</If> 
  union local:QueryPlan($items,$context)
};

 
declare function local:QueryPlan($query,$context)
{ 
  
  if (name(head($query))="GFLWOR") then 
  local:GFLWOR(head($query),tail($query),$context)
  else if (name(head($query))="For") then 
  local:For(head($query),tail($query)[name(.)="Where"],tail($query),$context)
  else if (name(head($query))="Let") then 
  local:Let(head($query),tail($query)[name(.)="Where"],tail($query),$context)
  else if (name(head($query))="CElem") then 
  local:cross(local:CElem(head($query),tail($query),$context))
  else if (name(head($query))="If") then 
  local:If(head($query),tail($query),$context)
  else if (name(head($query))="CAttr") then 
  local:CAttr(head($query),tail($query),$context)
  else if (name(head($query))="Where") then 
  local:QueryPlan(tail($query),$context)
  else if (name(head($query))="QNm") then 
  local:QueryPlan(tail($query),$context)
  else if (head($query)) then
  (local:exp(head($query),$context) 
  union local:QueryPlan(tail($query),$context))
  else ()
};

declare function local:GFLWORitems($items,$context)
{
  if (name(head($items))="For") then local:For(head($items),tail($items)[name(.)="Where"],tail($items),$context)
                   else if (name(head($items))="Let") then 
                   local:Let(head($items),tail($items)[name(.)="Where"],tail($items),$context)
                   else  
                   if (name(head($items))="CElem") then local:CElem(head($items),tail($items),$context)     
                   else <errorGLWORitems/>   
};

 
let $query :=
xquery:parse("
<bib>
 {
  for $b in db:open('bstore1')/bib/book
  return
  if ($b/publisher = 'Addison-Wesley') then 
  $b/author else $b/title
}  
</bib> 
  ")
return local:QueryPlan($query/QueryPlan/*,())

 