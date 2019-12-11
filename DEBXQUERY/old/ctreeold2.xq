declare function local:For($for,$items,$context)
{  
   
  if ($for/IterPath) 
  then
  let $ncontext := 
  (
  let $var := $for/Var
  let $path := $for/IterPath
  return
  <for><var>{$var}</var><IterPath>{$path/*,
  <values>{
  for $x in 
  local:IterPath($path,$context) return <value>{$x}</value>
  }</values>
  }</IterPath></for>
  )
  return
  $ncontext union local:QueryPlan($items,$context union $ncontext)
  else 
  if ($for/CachedPath) then
  let $ncontext := 
  (
  let $var := $for/Var
  let $path := $for/CachedPath
  return
  <for><var>{$var}</var><CachedPath>{$path/*,
  <values>{
  for $x in
  local:CachedPath($path,$context) return <value>{$x}</value>
  }</values> 
  }</CachedPath></for>
  )
  return
  $ncontext union local:QueryPlan($items,$context union $ncontext)
  else
  if ($for/DbOpen) then
   let $path := "db:open('" || data($for/DbOpen/Str/@value) || "')"
   let $var := $for/Var
   let $db := $for/DbOpen
   let $ncontext := <for><var>{$var}</var><DbOpen>{$db/*,
   <values>{for $x in xquery:eval($path) return <value><root>{$x
   }</root></value>
   }</values>
   }</DbOpen></for>
   return $ncontext union local:QueryPlan($items,$context union $ncontext)
   else
  if ($for/VarRef) then 
   let $var := $for/Var
   let $varn := $for/VarRef/Var/@name
   let $ncontext :=
   <for><var>{$var}</var><VarRef>{$for/VarRef/*,<values>{
   for $x in $context[var/Var/@name=data($varn)]/(IterPath | CachedPath | DbOpen)/values/value/*
   return <value>{$x}</value>}</values>
   }</VarRef></for>
   return $ncontext union local:QueryPlan($items,$context union $ncontext)
   else
   let $function := $for/*[substring(name(.),1,2)="Fn"]
   let $call := substring-before(data($function/@name),"(")
   return ()
   (:else <errorFor/>:)
   
   
};



declare function local:Let($let,$items,$context)
{  
  if ($let/IterPath)
  then
  let $ncontext := 
  ( 
  let $var := $let/Var
  let $path := $let/IterPath
  return
   <let><var>{$var}</var><IterPath>{$path/*,
   <values>{<value>{
   local:IterPath($path,$context)}</value>
   }</values>
  }</IterPath></let>
  )
  return
  $ncontext union local:QueryPlan($items,$context union $ncontext) 
  else 
  if ($let/CachedPath) then
  let $ncontext := 
  (
  let $var := $let/Var
  let $path := $let/CachedPath
  return
   <let><var>{$var}</var><CachedPath>{$path/*,
   <values>{<value>{
   local:CachedPath($path,$context)}</value>
   }</values>
   }</CachedPath></let>
  )
  return
  $ncontext  union local:QueryPlan($items,$context union $ncontext) 
  else
  if ($let/DbOpen) then
   let $path := "db:open('" || data($let/DbOpen/Str/@value) || "')"
   let $var := $let/Var
   let $db := $let/DbOpen
   let $ncontext := <let><var>{$var}</var><DbOpen>{$db/*,
   <values>{<value><root>{
   xquery:eval($path)}</root></value>
   }</values>
   }</DbOpen></let>
   return
  $ncontext union local:QueryPlan($items,$context union $ncontext)
  else
  if ($let/VarRef) then 
   let $var := $let/Var
   let $varn := $let/VarRef/Var/@name
   let $ncontext :=
   <let><var>{$var}</var><VarRef>{$let/VarRef/*,<values>{
   $context[var/Var/@name=data($varn)]/(IterPath | CachedPath | DbOpen | VarRef)/values/value}</values>
   }</VarRef></let>
   return $ncontext union local:QueryPlan($items,$context union $ncontext)
   else <errorLet/>
};   

declare function local:IterPath($query,$context)
{
  if ($query/DbOpen) then
            let $path := "db:open('" || data($query/DbOpen/Str/@value) || "')"  
                || fold-left(for-each($query/IterStep,function($x){$x/@axis || "::" || $x/@test}),"",
                    function($x,$y){$x || "/" || $y})
  return xquery:eval($path)
  else <errorIterPath/>
};

declare function local:CachedPath($query,$context)

{ 
   
  if ($query/DbOpen) then
                  let $path := "db:open('" || data($query/DbOpen/Str/@value) || "')"  
                  || fold-left(for-each($query/IterStep,function($x){$x/@axis || "::" || $x/@test}),"",
                  function($x,$y){$x || "/" || $y})
  return xquery:eval($path)  
  else 
  let $var := $query/VarRef/Var/@name
  return
  if ($context[var/Var/@name=data($var)]/(IterPath | CachedPath | DbOpen | VarRef)/values/value) 
  then
  let $path := "declare variable $xml external; $xml" || 
                 fold-left(for-each($query/IterStep,function($x){$x/@axis || "::" || $x/@test}),"",
                  function($x,$y){$x || "/" || $y})
                  
  for $value in $context[var/Var/@name=data($var)]/(IterPath | CachedPath | DbOpen | VarRef)/values/value/*
  return 
  xquery:eval($path,map { 'xml': $value })
  else <errorCachedPath/>
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
       element {"CmpG"} {$q/@*,for $CmpG in $q/* return local:CmpGs($CmpG,$context)} 
       else 
       if (name($q)="And") then  
             <And>{for $And in $q/* return local:WhereItem($And,$context)}</And>
             else 
             if (name($q)="Or") then 
                      <Or>{for $Or in $q/* return local:WhereItem($Or,$context)}</Or>
                      else <errorWhere/>                        
};

 

declare function local:Basic($query)
{
  $query/@value
};


declare function local:CmpGs($query,$context)
{       
           if (name($query)="CachedPath") then local:exp($query,$context)
           else if (name($query)="IterPath") then local:exp($query,$context)
            else if (name($query)="DbOpen") then local:exp($query,$context)
             else if (name($query)="VarRef") then local:exp($query,$context)
           else $query       
};

declare function local:exp($query,$context)
{
  if (name($query)="CachedPath") then 
             <CachedPath>{
             $query/*,
             <values>{
             for $x in 
             local:CachedPath($query,$context) return <value>{$x}</value>
             }</values>
             }</CachedPath> 
             else 
             if (name($query)="IterPath") then 
             <IterPath>{
             $query/*,
             <values>{for $x in   
             local:IterPath($query,$context) return <value>{$x}</value>
             }</values>
             }</IterPath> 
             else 
             if (name($query)="DbOpen") then 
             let $path := "db:open('" || data($query/DbOpen/Str/@value) || "')"
             return
             <DbOpen>{
             $query/*,
             <values>{for $x in xquery:eval($path) return <value><root>{$x}</root></value>
             }</values>
             }</DbOpen> else
             if (name($query)="VarRef") then 
             let $varn := $query/VarRef/Var/@name
             return
             <VarRef>{
             $query/*,
             <values>{
             for $x in $context[var/Var/@name=data($varn)]/(IterPath | CachedPath | DbOpen)/values/value/*
             return <value>{$x}</value>}</values>
             }</VarRef> else
             local:Basic($query)
             
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
   else if (name(head($query))="DbOpen") then 
   let $path := "db:open('" || data(head($query)/DbOpen/Str/@value) || "')"
   return
  <DbOpen>{head($query)/*,
  <values>{for $x in xquery:eval($path)return <value><root>{$x}</root></value>
  }</values>}</DbOpen> union local:QueryPlan(tail($query),$context) 
  else
  if (name(head($query))="VarRef") then 
  let $varn := head($query)/Var/@name
  return
  <VarRef>{head($query)/*,
  <values>{
  for $x in $context[var/Var/@name=data($varn)]/(IterPath | CachedPath | DbOpen)/values/value/*
  return <value>{$x}</value>}</values> union local:QueryPlan(tail($query),$context)
  }</VarRef>
  else if (name(head($query))="IterPath") then 
  <IterPath>{head($query)/*,
  <values>{for $x in 
  local:IterPath(head($query),$context) return <value>{$x}</value>
  }</values>}</IterPath> union local:QueryPlan(tail($query),$context)
  else if (name(head($query))="CachedPath") then 
  <CachedPath>{head($query)/*,
  <values>{for $x in
  local:CachedPath(head($query),$context) return <value>{$x}</value>
  }</values>}</CachedPath> union local:QueryPlan(tail($query),$context) 
  else if (name(head($query))="QNm") then local:QueryPlan(tail($query),$context) 
  else () (:<errorQueryPlan>{$query}</errorQueryPlan>:)
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
<results>
  {
    let $a := db:open('bstore1')//author
    for $last in distinct-values($a/last),
        $first in distinct-values($a[last=$last]/first)
    order by $last, $first
    return
        <result>
            <author>
               <last>{ $last }</last>
               <first>{ $first }</first>
            </author>
            {
                for $b in db:open('bstore1')/bib/book
                where some $ba in $b/author 
                      satisfies ($ba/last = $last and $ba/first=$first)
                return $b/title
            }
        </result>
  }
</results>       
  ")
return $query (:local:QueryPlan($query/QueryPlan/*,()):)



 