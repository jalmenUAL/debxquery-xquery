(: ROOT?,QUANTIFIER, (DOC, COLLECTION), ARRAYS, IF THEN ELSE, ORDER BY, UNION, LOCAL FUNCTIONS, WHERE EVAL :)

declare function local:For($for,$items,$context)
{
  let $ncontext := 
  (
  let $var := $for/Var
  let $path := $for/*[2]
  return
  <for><var>{$var}</var><bound>{$path,
  <values>{
  for $x in 
  local:exp($path,$context)//value/(*|text()) return <value>{$x}</value>
  }</values>
  }</bound></for>
  )
  return
  $ncontext union local:QueryPlan($items,$context union $ncontext)
};

declare function local:Let($let,$items,$context)
{
  let $ncontext := 
  (
  let $var := $let/Var
  let $path := $let/*[2]
  return
  <let><var>{$var}</var><bound>{$path,
  <values>{
  local:exp($path,$context)//value
  }</values>
  }</bound></let>
  )
  return
  $ncontext union local:QueryPlan($items,$context union $ncontext)
};

declare function local:IterPath($query,$context)
{
  if ($query/Root) then 
  let $path :=  
                 "/."+fold-left(for-each($query/*,function($x){local:path($x,$context)}),"",
                    function($x,$y){$x || "/" || $y})
  return <value>{xquery:eval($path)}</value>
  else
  if ($query/DbOpen) then
            let $path :=  
                 fold-left(for-each($query/*,function($x){local:path($x,$context)}),"",
                    function($x,$y){$x || "/" || $y})
  return <value>{xquery:eval($path)}</value>
  else <errorIterPath/>
};

declare function local:CachedPath($query,$context)
{ 
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
  return
  if (name($context[var/Var/@name=data($var)])="for") 
  then
  let $path := "declare variable $xml external; $xml" || 
                 fold-left(for-each($query/*,function($x){local:path($x,$context)}),"",
                  function($x,$y){$x || "/" || $y})
                  
  let $as := $context[var/Var/@name=data($var)]/*/values/value/(*|text())
  for $value in xquery:eval($path,map { 'xml': $as })
  return 
  <value>{$value}</value>
  else
  if (name($context[var/Var/@name=data($var)])="let") 
  then
  let $path := "declare variable $xml external; $xml" || 
                 fold-left(for-each($query/*,function($x){local:path($x,$context)}),"",
                  function($x,$y){$x || "/" || $y})
                
  (:let $as := $context[var/Var/@name=data($var)]/*/values/value/(*|text())
  return 
  <value>{xquery:eval($path,map { 'xml': $as })}</value>:)
   let $as := $context[var/Var/@name=data($var)]/*/values/value/(*|text())
  for $value in xquery:eval($path,map { 'xml': $as })
  return 
  <value>{$value}</value>
  else <errorCachedPath>{$query}</errorCachedPath>
};
 
declare function local:path($step,$context)
{
  
    if (name($step)="Root") then "/." 

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
   if (name($step)="VarRef") then 
             let $varn := $step/Var/@name
             return
             if (name($context[var/Var/@name=data($varn)])="for")
             then
             let $for := 
             fold-left(for-each($context[var/Var/@name=data($varn)]/bound/*,function($x){local:path($x,$context)}),".",
                  function($x,$y){$x || "/" || $y})
             return "(for $x in " || $for || " return $x)"              
             else 
             let $let := 
             fold-left(for-each($context[var/Var/@name=data($varn)]/bound/*,function($x){local:path($x,$context)}),".",
                  function($x,$y){$x || "/" || $y})
             return $let          
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
  else if ($step/@type="xs:string") then  "'" || data($step/@value)|| "'"
             else
             data($step/@value)
}; 
 
 
declare function local:Where($q,$items,$context)
{
  <Where>{
  for $w in $q/* return local:WhereItem($w,$context)
  }</Where> union local:QueryPlan($items,$context)
};

declare function local:WhereItem($q,$context)
{  
  if (name($q)="CmpG") then 
       element {"CmpG"} {$q/@*,for $CmpG in $q/* return local:exp($CmpG,$context)} 
       else 
       if (name($q)="And") then  
             <And>{for $And in $q/* return local:WhereItem($And,$context)}</And>
             else 
             if (name($q)="Or") then 
                      <Or>{for $Or in $q/* return local:WhereItem($Or,$context)}</Or>
                      else <errorWhere/>                        
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
             if (name($query)="VarRef") then 
             let $varn := $query/Var/@name
             return
             <VarRef>{
             $query/*,
             <values>{
             $context[var/Var/@name=data($varn)]/*/values/value
             }</values>
             }</VarRef> 
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
             if ($query/@type="xs:string") then  <values><value>{"'" || data($query/@value)|| "'"}</value></values> 
             else
             <values><value>{data($query/@value)}</value></values>  
                       
};


declare function local:CachedFilter($query,$context)
{
  let $exp := ($query/*)[1]
  let $filter := ($query/*)[2]
  return if (name($filter)="CachedPath") 
  then
  for $vexp in local:exp(<CachedPath>{$exp,$filter/*}</CachedPath>,$context)//value/(*|text())
  return
  <value>{$vexp}</value>
  else let $op := data($filter/@op)
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
  (<CAttr>{$query/QNm, 
   local:QueryPlan($query/*,$context)
   }
   </CAttr>) union local:QueryPlan($items,$context)
   
};

declare function local:QueryPlan($query,$context)
{ 
  
  if (name(head($query))="GFLWOR") then 
  local:GFLWOR(head($query),tail($query),$context)
  else if (name(head($query))="For") then 
  local:For(head($query),tail($query),$context)
  else if (name(head($query))="Let") then 
  local:Let(head($query),tail($query),$context)
  else if (name(head($query))="CElem") then 
  local:CElem(head($query),tail($query),$context)
  else if (name(head($query))="CAttr") then 
  local:CAttr(head($query),tail($query),$context)
   else if (name(head($query))="Where") then 
  local:Where(head($query),tail($query),$context)
  else if (name(head($query))="QNm") then 
  local:QueryPlan(tail($query),$context)
  else if (head($query)) then
  (local:exp(head($query),$context) union local:QueryPlan(tail($query),$context))
  else ()
};

declare function local:GFLWORitems($items,$context)
{
  if (name(head($items))="For") then local:For(head($items),tail($items),$context)
                   else if (name(head($items))="Let") then local:Let(head($items),tail($items),$context)
                   else  
                   if (name(head($items))="Where") then  local:Where(head($items),tail($items),$context)
                   else if (name(head($items))="CElem") then local:CElem(head($items),tail($items),$context)     
                   else <errorGLWORitems/>   
};

 
let $query :=
xquery:parse("
<bib>
 {
  for $b in db:open('bstore1')/bib/book
  where $b/publisher = 'Addison-Wesley' and $b/@year > 1991
  return
    <book year='{ $b/@year }'>
     { $b/title }
    </book>
 }
</bib> 
  ")
return local:QueryPlan($query/QueryPlan/*,()) 

 