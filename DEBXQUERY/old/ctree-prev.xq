(: GROUP BY, ORDER BY, LITERALS  :)

declare function local:For($for,$groupby,$orderby,$where,$return,$context,$static)
{
  
  let $var := $for/Var
  let $path := $for/*[2]
  return
  <For>{$var}<path>{$path}</path> 
  <values>{
  let $count := count(local:exp($path,$context,$static)/values/value/node())  
  return           
  for $i in 1 to $count 
  let $return := 
  local:Return($return,
  <context>{
   (for $x in $context/* where not($x//@name=$var//@name) return $x) union <var><name>{$var}</name><path>{local:exp($path,$context,$static)/values/value/node()}</path><position>{$i}</position></var>}</context> ,$static) 
  where local:Where($where,<context>{
   (for $x in $context/* where not($x//@name=$var//@name) return $x) union <var><name>{$var}</name><path>{local:exp($path,$context,$static)/values/value/node()}</path><position>{$i}</position></var>}</context>
  ,$static)/values/value/text()=true()
  and $return 
  return     
  <value>{$return/values/value/node()}</value>
  }</values></For>
   
};

declare function local:Let($let,$groupby,$orderby,$where,$return,$context,$static)
{
  let $var := $let/Var
  let $path := $let/*[2]
  return
  <Let>{$var}<path>{$path}</path> 
  <values>{
  let $i := 0 
  let $return := 
  local:Return($return,
  <context>{
   (for $x in $context/* where not($x//@name=$var//@name) return $x) union <var><name>{$var}</name><path>{local:exp($path,$context,$static)/values/value/node()}</path><position>{$i}</position></var>}</context> ,$static) 
  where local:Where($where,
 <context>{
   (for $x in $context/* where not($x//@name=$var//@name) return $x) union <var><name>{$var}</name><path>{local:exp($path,$context,$static)/values/value/node()}</path><position>{$i}</position></var>}</context>,$static)/values/value/text()=true()
   and $return 
  return   
  <value>{$return/values/value/node()}</value>
}</values></Let>
};


 


declare function local:exps($query,$context,$static)
{
 for $exp in $query return local:exp($exp,$context,$static)
};

declare function local:exp($exp,$context,$static)
{
   
   if (name($exp)="GFLWOR") then  local:GFLWOR($exp,$context,$static) 
   else 
   if (name($exp)="CElem") then local:CElem($exp,$context,$static) 
   else 
   if (name($exp)="CAttr") then local:CAttr($exp,$context,$static)
   else 
   if (name($exp)="Union") then local:Union($exp,$context,$static) 
   else 
   if (name($exp)="List") then local:List($exp,$context,$static) 
   else 
   if (name($exp)="If") then local:If($exp,$context,$static) 
   else
   if (name($exp)="Quantifier") then local:Quantifier($exp,$context,$static) 
   else          
    if (name($exp)="StaticFuncCall") then local:StaticFuncCall($exp,$context,$static)
   else
    if (name($exp)="Empty") then <values><value>()</value></values>
   else
   let $path :=  string-join(for-each($exp,function($x){local:Path($x,$context,$static)}),"/")
   return <path value="{$path}"><values>{for $x in xquery:eval($path) return <value>{$x}</value>}</values></path>
};

declare function local:StaticFuncCall($exp,$context,$static) 
{  
let $name := data($exp/@name)
let $args := $exp/*
let $cargs := count($args)
let $staticfun := $static[@name=$name]
return local:GFLWOR(
<GFLWOR>{
(for $i in 0 to $cargs -1
return 
<Let>
<Var name="{'$' || data($staticfun/@*[name(.)=("arg"||$i)])}" />
{$args[$i+1]}
</Let>), 
$staticfun/*
}</GFLWOR>,
$context,  
$static)
};
 
declare function local:Quantifier($quan,$context,$static)
{  
  if ($quan/@type="some") then let $res := local:GFLWOR($quan/*,$context,$static)
                               return 
                               <Quantifier>                          
                                <values><value>{some $r in $res/values/value/text() satisfies $r="true"}</value></values></Quantifier>
  else let $res := local:GFLWOR($quan/*,$context,$static) 
                   return <Quantifier>
                   <values><value>{every $r in $res/values/value/text() satisfies $r="true"}</value></values></Quantifier>
};
 

declare function local:Where($where,$context,$static)
{
  if (empty($where/*)) then <Where><values><value>{true()}</value></values></Where>  
  else <Where>{<values>{local:exp($where/*,$context,$static)/values/value}</values>}</Where>  
};

 


declare function local:Return($return,$context,$static)
{
 if (name(head($return))="For" or name(head($return))="Let") then local:exp(<GFLWOR>{$return}</GFLWOR>,$context,$static)
 else local:exp($return,$context,$static) 
};

declare function local:Path($step,$context,$static)
{  
   if (name($step)="ContextValue") then "."
   else
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
             let $con := $context/*[name/Var/@name=data($varn)]
             let $path := 
             $con/path
             let $position := $con/position/text()
             return   
             if ($position=0) then 
             serialize($path, map {'method': 'xml' }) || "/node()"     
             else
              "(" || serialize($path, map {'method': 'xml' }) || "/node()" 
             
             || ")"   || "[" || $position || "]" 
                       
    else
    if (name($step)="CachedPath") 
          then string-join(for-each($step/*,function($x){local:Path($x,$context,$static)}),"/")
                  
   else
   if (name($step)="IterPath") 
          then string-join(for-each($step/*,function($x){local:Path($x,$context,$static)}),"/")
        
   else 
   
   if (name($step)="Union") then   "(" || 
                   string-join(for-each($step/*,function($x){local:Path($x,$context,$static)}),"|") || ")"  
   else
   if (name($step)="MixedPath")
                   then
                   local:Path(<CachedPath>{$step/*}</CachedPath>,$context,$static)                  
   else           
   if (name($step)="CachedFilter") 
          then 
          local:Path(head($step/*),$context,$static) || 
          for-each(tail($step/*),function($x){"[" || local:Path($x,$context,$static) || "]"})
                   
    else
   if (name($step)="IterStep") then 
                if ($step/CmpG) then 
                let $cond1 := local:Path(($step/CmpG/*)[1],$context,$static)
                let $cond2 := local:Path(($step/CmpG/*)[2],$context,$static)
                return $step/@axis || "::" || $step/@test || "[" || $cond1 || $step/CmpG/@op || $cond2 ||"]"
                else
                if ($step/CmpN) then 
                let $cond1 := local:Path(($step/CmpN/*)[1],$context,$static)
                let $cond2 := local:Path(($step/CmpN/*)[2],$context,$static)
                return $step/@axis || "::" || $step/@test || "[" || $cond1 || $step/CmpN/@op || $cond2 ||"]"  
                else $step/@axis || "::" || $step/@test
   else 
   
   if (name($step)="CachedStep") then $step/@axis || "::" || $step/@test || "[" || 
                            string-join(for-each($step/*,function($x){local:Path($x,$context,$static)}),"/") || "]"
                          
                        
   else           
   if (name($step)="FnNot") 
          then "not(" || string-join(for-each($step/*,function($x){local:Path($x,$context,$static)}),"/") || ")"
    
                                      
   else
   if (substring(name($step),1,2)="Fn") then
             let $count := count($step/*)
             let $f := function-lookup(QName("http://www.w3.org/2005/xpath-functions",
             substring-before(data($step/@name),"(")),$count) 
             let $args := string-join(for $exp in $step/* return [local:Path($exp,$context,$static)],",")
             return 
             substring-before(data($step/@name),"(") || "(" || $args || ")" 
   
   else 
   if (name($step)="CmpG") then
              let $cond1 := local:Path(($step/*)[1],$context,$static)
              let $cond2 := local:Path(($step/*)[2],$context,$static)
              return "(" || $cond1 || $step/@op || $cond2 || ")"  
   else
   if (name($step)="Arith") then
              let $cond1 := local:Path(($step/*)[1],$context,$static)
              let $cond2 := local:Path(($step/*)[2],$context,$static)
              return "(" || $cond1 || $step/@op || $cond2 || ")"            
   else 
   if (name($step)="CmpN") then
              let $cond1 := local:Path(($step/*)[1],$context,$static)
              let $cond2 := local:Path(($step/*)[2],$context,$static)
              return "(" || $cond1 || $step/@op || $cond2 || ")"  
              
   else 
   if (name($step)="And") then
           "(" || local:Path(($step/*)[1],$context,$static) || " and " ||   local:Path(($step/*)[2],$context,$static) || ")"
   else 
   if (name($step)="Or") then
           "(" || local:Path(($step/*)[1],$context,$static) || " or " ||   local:Path(($step/*)[2],$context,$static) || ")"      else    
   if (name($step)="Empty") then"()"
   else  
   if ($step/@type="xs:string") then  "'" || data($step/@value)|| "'"
   else
   if ($step/@type) then data($step/@value)
   else
   if (local:exp($step,$context,$static)/values/value/node()) then
   serialize(<root>{local:exp($step,$context,$static)/values/value/node()}</root>, map {'method': 'xml' }) || "/node()" 
   else "()"
}; 
 

declare function local:CElem($query,$context,$static)
{
 <CElem><values><value>{element {data($query/QNm/@value)} {local:exps(tail($query/*),$context,$static)/values/
 value/(node() | @*)}}
 </value></values></CElem>
(:  
 <CElem>{$query/QNm,<values>{local:exps(tail($query/*),$context,$static)/values/value}</values>}</CElem> 
 :)
};

declare function local:CAttr($query,$context,$static)
{ 
 <CAttr><values><value>{attribute {data($query/QNm/@value)} {data(local:exps(tail($query/*),$context,$static)/values/value/@*)}}
 </value></values></CAttr>
 (:
 <CAttr>{$query/QNm,<values>{local:exps(tail($query/*),$context,$static)/values/value}</values>}</CAttr>:)
};

declare function local:GFLWOR($query,$context,$static)
{
  
(:<GLFWOR>{:)
local:GFLWORitems($query/*,$context,$static)
(:}</GLFWOR>:)
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

declare function local:fgroup ($items)
{
  if (empty($items)) then ()
  else
  if (name(head($items))="For" or name(head($items))="Let") then ()
  else if (name(head($items))="GroupBy") then head($items)
  else local:forder(tail($items))
};

declare function local:frest ($items)
{ 
  if (name(head($items))="OrderBy") then local:frest(tail($items))
  else  if (name(head($items))="GroupBy") then local:frest(tail($items))
  else if (name(head($items))="Where") then local:frest(tail($items))
  else $items
};

declare function local:GFLWORitems($items,$context,$static)
{
if (name(head($items))="For") 
then 
local:For(head($items),local:fgroup(tail($items)),
                local:forder(tail($items)),local:fwhere(tail($items)),
                 local:frest(tail($items)) ,$context,$static)
else 
local:Let(head($items),local:fgroup(tail($items)),  local:forder(tail($items)),local:fwhere(tail($items)),
                 local:frest(tail($items)),$context,$static)                    
};

declare function local:If($query,$context,$static)
{
let $cond := ($query/*)[1]
let $then := ($query/*)[2]
let $else := ($query/*)[3]
return
if (local:exp($cond,$context,$static)/values/value/text()=true()) then 
    <If><values>{local:exp($then,$context,$static)/values/value}</values></If> 
    else <If><values>{local:exp($else,$context,$static)/values/value}</values></If> 
};

declare function local:Union($query,$context,$static)
{
<Union>{local:exps($query/*,$context,$static)}</Union>
};

declare function local:List($query,$context,$static)
{
<List>{local:exps($query/*,$context,$static)}</List>
};
  
let $query :=
xquery:parse(
"
<bib>
  {
    for $b in db:open('bstore1')//book
    where count($b/author) > 0
    return
        <book>
            { $b/title }
            {
                for $a in $b/author[position()<=2]  
                return $a
            }
            {
                if (count($b/author) > 2)
                 then <et-al/>
                 else ()
            }
        </book>
  }
</bib>
 
")
return local:exps($query/QueryPlan/*[not(name(.)="StaticFunc")],<context></context>,$query/QueryPlan/*[name(.)="StaticFunc"]) 