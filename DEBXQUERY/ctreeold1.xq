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
  local:IterPath($path,$context)
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
  local:CachedPath($path,$context)
  }</values> 
  }</CachedPath></for>
  )
  return
  $ncontext union local:QueryPlan($items,$context union $ncontext)
  else <errorFor/>
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
   <values>{
   local:IterPath($path,$context)
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
   <values>{
   local:CachedPath($path,$context)
   }</values>
   }</CachedPath></let>
  )
  return
  $ncontext  union local:QueryPlan($items,$context union $ncontext) 
  else <errorLet/>
};

declare function local:IterPath($query,$context)
{
  if ($query/DbOpen) then
            let $path := "db:open('" || data($query/DbOpen/Str/@value) || "')"  
                || fold-left(for-each($query/IterStep,function($x){$x/@axis || "::" || $x/@test}),"",
                    function($x,$y){$x || "/" || $y})
  return <value>{xquery:eval($path)}</value> 
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
  if ($context[name(.)="for"]/var/Var/@name=data($var))
  then 
  for $value in $context[var/Var/@name=data($var)]/(IterPath | CachedPath)/values/*
  return 
  <value>{
  let $path := "declare variable $xml external; $xml" || 
                 fold-left(for-each($query/IterStep,function($x){$x/@axis || "::" || $x/@test}),"",
                  function($x,$y){$x || "/" || $y})
  return xquery:eval($path,map { 'xml': $value }) 
  }</value>
  else 
  let $value := $context[var/Var/@name=data($var)]//(IterPath | CachedPath)/values/*
  let $path := "declare variable $xml external; $xml" || 
                 fold-left(for-each($query/IterStep,function($x){$x/@axis || "::" || $x/@test}),"",
                  function($x,$y){$x || "/" || $y})
  return <value>{xquery:eval($path,map { 'xml': $value })}</value>
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
           else $query       
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
             else local:Basic($query)
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
  else if (name(head($query))="IterPath") then 
  <IterPath>{head($query)/*,
  <values>{
  local:IterPath(head($query),$context)
  }</values>}</IterPath>
  else if (name(head($query))="CachedPath") then 
  <CachedPath>{head($query)/*,
  <values>{
  local:CachedPath(head($query),$context)
  }</values>}</CachedPath>
  else if (name(head($query))="QNm") then
  local:QueryPlan(tail($query),$context)
  else <errorQueryPlan>{$query}</errorQueryPlan>
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
  let $b := db:open('bstore1')/bib
  for $a in $b/book
  where $a/publisher = 'Addison-Wesley' and $a/@year > 1991
  return
    <book year='{ $a/@year }'>
     { $a/title }
    </book>
 }
</bib>       
  ")
return local:QueryPlan($query/QueryPlan/*,())



 