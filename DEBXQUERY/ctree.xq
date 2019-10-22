(: ORDER BY, LOCAL FUNCTIONS, AGGREGATORS  :)

declare function local:For($for,$orderby,$where,$return,$context)
{
  
  let $var := $for/Var
  let $path := $for/*[2]
  return
  <For>{$var}  
  <values>{
  let $count := count(local:exp($path,$context)//values/value/(*|@*|text()))
  return 
  for $i in 1 to $count 
  (:order by local:OrderBy($orderby,<var><name>{$var}</name><path>{$path}</path><position>{$i}</position></var> union 
  $context):)
  where local:Where($where,
  <var><name>{$var}</name><path>{$path}</path><position>{$i}</position></var> union $context)//values/value/text()=true()
  and local:Return($return, 
  <var><name>{$var}</name><path>{$path}</path><position>{$i}</position></var> union $context)//values/value
  return 
  <value>{local:Return($return, 
  <var><name>{$var}</name><path>{$path}</path><position>{$i}</position></var> union $context)}</value> 
  }</values></For>
   
};

declare function local:Let($let,$orderby,$where,$return,$context)
{
  let $var := $let/Var
  let $path := $let/*[2]
  return
  <Let>{$var} 
  <values>{
  let $i := 0 
  (:order by local:OrderBy($orderby,<var><name>{$var}</name><path>{$path}</path><position>{$i}</position></var> union $context):)
  where local:Where($where,
  <var><name>{$var}</name><path>{$path}</path><position>{$i}</position></var> union $context)//values/value/text()=true()
   and local:Return($return, 
  <var><name>{$var}</name><path>{$path}</path><position>{$i}</position></var> union $context)//values/value
  return  
  <value>{
  local:Return($return, 
  <var><name>{$var}</name><path>{$path}</path><position>{$i}</position></var> union $context)}</value>
  }</values></Let>
};

 
(: MIXED ASCENDING AND DESCENDING :)
declare function local:OrderBy($order,$context)
{
  <o>
  {for $exp in $order/Key/* return local:exp($exp,$context)//values}
  </o>
};

declare function local:exps($query,$context)
{
 for $exp in $query return local:exp($exp,$context)
};

declare function local:exp($exp,$context)
{
   if (name($exp)="GFLWOR") then  local:GFLWOR($exp,$context) 
   else 
   if (name($exp)="CElem") then local:CElem($exp,$context) 
   else 
   if (name($exp)="CAttr") then local:CAttr($exp,$context)
   else 
   if (name($exp)="Union") then local:Union($exp,$context) 
   else 
   if (name($exp)="List") then local:List($exp,$context) 
   else 
   if (name($exp)="If") then local:If($exp,$context) 
   else
   if (name($exp)="Quantifier") then local:Quantifier($exp,$context) 
   else
   let $path :=  string-join(for-each($exp,function($x){local:Path($x,$context)}),"/")
   return <path value="{$path}"><values>{for $x in xquery:eval($path) return <value>{$x}</value>}</values></path>
};

 
 
declare function local:Quantifier($quan,$context)
{  
  if ($quan/@type="some") then let $res := local:GFLWOR($quan/*,$context)
                               return 
                               <Quantifier>                          
                                <values><value>{some $r in $res//values//value/text() satisfies $r="true"}</value></values></Quantifier>
  else let $res := local:GFLWOR($quan/*,$context) 
                   return <Quantifier>
                   <values><value>{every $r in $res//values//value/text() satisfies $r="true"}</value></values></Quantifier>
};
 

declare function local:Where($where,$context)
{
  if (empty($where/*)) then <Where><values><value>{true()}</value></values></Where>  
  else <Where>{local:exp($where/*,$context)}</Where>  
};

 


declare function local:Return($return,$context)
{
 if (name(head($return))="For" or name(head($return))="Let") then local:exp(<GFLWOR>{$return}</GFLWOR>,$context)
 else local:exp($return,$context) 
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
             let $path := 
             ($context[name/Var/@name=data($varn)])[1]/path
             let $position := ($context[name/Var/@name=data($varn)])[1]/position/text()
             return 
             if ($position=0) then local:Path($path/*,$context)
             else "(" || local:Path($path/*,$context) || ")"  || "[" || $position || "]"
                       
    else
    if (name($step)="CachedPath") 
          then string-join(for-each($step/*,function($x){local:Path($x,$context)}),"/")
                  
   else
   if (name($step)="IterPath") 
          then string-join(for-each($step/*,function($x){local:Path($x,$context)}),"/")
        
   else 
   
   if (name($step)="Union") then   "(" || 
                   string-join(for-each($step/*,function($x){local:Path($x,$context)}),"|") || ")"  
   else
   if (name($step)="MixedPath")
                   then
                   local:Path(<CachedPath>{$step/*}</CachedPath>,$context)                  
   else           
   if (name($step)="CachedFilter") 
          then 
          local:Path(head($step/*),$context) || "[" ||
          string-join(for-each(tail($step/*),function($x){local:Path($x,$context)}),"/")
                   || "]"
    else
   if (name($step)="IterStep") then 
                if ($step/CmpG) then 
                let $cond1 := local:Path(($step/CmpG/*)[1],$context)
                let $cond2 := local:Path(($step/CmpG/*)[2],$context)
                return $step/@axis || "::" || $step/@test || "[" || $cond1 || $step/CmpG/@op || $cond2 ||"]"  
                else $step/@axis || "::" || $step/@test
   else 
   if (name($step)="CachedStep") then $step/@axis || "::" || $step/@test || "[" || 
                            string-join(for-each($step/*,function($x){local:Path($x,$context)}),"/") || "]"
                          
                         (: "[" || $step/@axis || "::" || $step/@test || "]" :)
   else           
   if (name($step)="FnNot") 
          then "not(" || string-join(for-each($step/*,function($x){local:Path($x,$context)}),"/") || ")"
                                                 
   else
   if (substring(name($step),1,2)="Fn") then
             let $count := count($step/*)
             let $f := function-lookup(QName("http://www.w3.org/2005/xpath-functions",
             substring-before(data($step/@name),"(")),$count) 
             let $args := string-join(for $exp in $step/* return [local:Path($exp,$context)],",")
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
   if ($step/@type) then data($step/@value)
   else serialize(<root>{local:exp($step,$context)//values/value/(*|@*|text())}</root>, map {'method': 'xml' }) || "/*"
}; 
 

declare function local:CElem($query,$context)
{
 <CElem>{$query/QNm,local:exps(tail($query/*),$context)}</CElem> 
};

declare function local:CAttr($query,$context)
{ 
 <CAttr>{$query/QNm,local:exps(tail($query/*),$context)}</CAttr>
};

declare function local:GFLWOR($query,$context)
{
<GLFWOR>{local:GFLWORitems($query/*,$context)}</GLFWOR>  
};

declare function local:fwhere ($items)
{
  if (empty($items)) then ()
  else
  if (name(head($items))="For" or name(head($items))="Let") then ()
  else if (name(head($items))="Where") then head($items)
  else local:fwhere(tail($items))
};

declare function local:forder ($items)
{
  if (empty($items)) then ()
  else
  if (name(head($items))="For" or name(head($items))="Let") then ()
  else if (name(head($items))="OrderBy") then head($items)
  else local:forder(tail($items))
};

declare function local:frest ($items)
{
   
  
  if (name(head($items))="OrderBy") then local:frest(tail($items))
  else if (name(head($items))="Where") then local:frest(tail($items))
  else $items
};

declare function local:GFLWORitems($items,$context)
{
if (name(head($items))="For") 
then 
local:For(head($items),
                local:forder(tail($items)),local:fwhere(tail($items)),
                 local:frest(tail($items)) ,$context)
else 
local:Let(head($items),  local:forder(tail($items)),local:fwhere(tail($items)),
                 local:frest(tail($items)),$context)                      
};

declare function local:If($query,$context)
{
let $cond := ($query/*)[1]
let $then := ($query/*)[2]
let $else := ($query/*)[3]
return
if (local:exp($cond,$context)//values/value/text()=true()) then 
    <If>{local:exp($then,$context)}</If> 
    else <If>{local:exp($else,$context)}</If> 
};

declare function local:Union($query,$context)
{
<Union>{local:exps($query/*,$context)}</Union>
};

declare function local:List($query,$context)
{
<List>{local:exps($query/*,$context)}</List>
};
  
let $query :=
xquery:parse(
" 
<bib>
{
    for $book1 in db:open('bstore1')//book,
        $book2 in db:open('bstore1')//book
    let $aut1 := for $a in $book1/author 
                 order by $a/last, $a/first
                 return $a
    let $aut2 := for $a in $book2/author 
                 order by $a/last, $a/first
                 return $a
    where $book1 << $book2
    and not($book1/title = $book2/title)
    and deep-equal($aut1, $aut2) 
    return
        <book-pair>
            { $book1/title }
            { $book2/title }
        </book-pair>
}
</bib>          ")
return local:exps($query/QueryPlan/*,())

 