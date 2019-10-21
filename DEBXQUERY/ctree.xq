(: ORDER BY, LOCAL FUNCTIONS, AGGREGATORS, XML DOCS  :)

declare function local:For($for,$where,$return,$context)
{
  
  let $var := $for/Var
  let $path := $for/*[2]
  return
  <For>{$var}<path>{local:Path($path,$context)}</path>
  <values>{
  let $count := count(local:exp($path,$context)//values/(*|text()))
  return 
  for $i in 1 to $count 
  where local:Where($where,
  <var><name>{$var}</name><path>{$path}</path><position>{$i}</position></var> union $context)//values/text()=true()
  return
  local:Return($return, 
  <var><name>{$var}</name><path>{$path}</path><position>{$i}</position></var> union $context) 
  }</values></For>
   
};

declare function local:Let($let,$where,$return,$context)
{
  let $var := $let/Var
  let $path := $let/*[2]
  return
  <Let>{$var}<path>{local:Path($path,$context)}</path>
  <values>{
  let $i := 0 
  where local:Where($where,
  <var><name>{$var}</name><path>{$path}</path><position>{$i}</position></var> union $context)//values/text()=true()
  return 
  local:Return($return, 
  <var><name>{$var}</name><path>{$path}</path><position>{$i}</position></var> union $context)//values/(*|text())  
  }</values></Let>
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
   return <path value="{$path}"><values>{xquery:eval($path)}</values></path>
};

 
 
declare function local:Quantifier($quan,$context)
{  
  if ($quan/@type="some") then let $res := local:GFLWOR($quan/*,$context)
                               return 
                               <Quantifier>                          
                                <values>{some $r in $res//values//text() satisfies $r=true()}</values></Quantifier>
  else let $res := local:GFLWOR($quan/*,$context) 
                   return <Quantifier>
                   <values>{every $r in $res//values//text() satisfies $r=true()}</values></Quantifier>
};
 

declare function local:Where($where,$context)
{
  if (empty($where/*)) then <Where><values>{true()}</values></Where>  
  else <Where>{local:exp($where/*,$context)/values}</Where>  
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
             $context[name/Var/@name=data($varn)][1]/path
             let $position := $context[name/Var/@name=data($varn)][1]/position/text()
             return 
             if ($position=0) then local:Path($path/*,$context)
             else local:Path($path/*,$context)  || "[" || $position || "]"
                       
    else
    if (name($step)="CachedPath") 
          then string-join(for-each($step/*,function($x){local:Path($x,$context)}),"/")
                  
   else
   if (name($step)="IterPath") 
          then string-join(for-each($step/*,function($x){local:Path($x,$context)}),"/")
        
   else 
   if (name($step)="MixedPath")
          then let $head := $step/*[not(name(.)="Union")],
                   $union := $step/Union
                   return local:Path(<CachedPath>{$head}</CachedPath>,$context) || "/(" || 
                   string-join(for-each($union/*,function($x){local:Path($x,$context)}),"|") || ")"                    
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
   if (name($step)="CachedStep") then "[" || $step/@axis || "::" || $step/@test || "]"   
   else           
   if (name($step)="FnNot") 
          then "not(" || string-join(for-each($step/*,function($x){local:Path($x,$context)}),"/") || ")"
                                                 
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
   if ($step/@type) then data($step/@value)
   else serialize(<root>{local:exp($step,$context)//values/(*|text())}</root>, map {'method': 'xml' }) || "/*"
}; 
 

declare function local:CElem($query,$context)
{
 <CElem>{$query/QNm,<values>{local:exps(tail($query/*),$context)}</values>}</CElem> 
};

declare function local:CAttr($query,$context)
{ 
 <CAttr>{$query/QNm,<values>{local:exps(tail($query/*),$context)}</values>}</CAttr>
};

declare function local:GFLWOR($query,$context)
{
<GLFWOR>{local:GFLWORitems($query/*,$context)}</GLFWOR>  
};

declare function local:GFLWORitems($items,$context)
{
if (name(head($items))="For") 
then 
local:For(head($items),if (name(tail($items)[1])="Where") then tail($items)[1] else (),
if (name(tail($items)[1])="Where") then tail(tail($items)) else tail($items),$context)
else 
local:Let(head($items),if (name(tail($items)[1])="Where") then tail($items)[1] else (),
if (name(tail($items)[1])="Where") then tail(tail($items)) else tail($items),$context)
                      
};

declare function local:If($query,$context)
{
let $cond := ($query/*)[1]
let $then := ($query/*)[2]
let $else := ($query/*)[3]
return
if (local:exp($cond,$context)//values/text()=true()) then 
    <If><values>{local:exp($then,$context)//values/(*|text())}</values></If> 
    else <If><values>{local:exp($else,$context)//values/(*|text())}</values></If> 
};

declare function local:Union($query,$context)
{
<Union>{<values>{local:exps($query/*,$context)//values/(*|text())}</values>}</Union>
};

declare function local:List($query,$context)
{
<List>{<values>{local:exps($query/*,$context)//values/(*|text())}</values>}</List>
};
  
let $query :=
xquery:parse(
" 
<bib>
 {
  for $b in db:open('bstore1')/bib/book
  
  where some $p in $b/@year satisfies $p >1993
  return 
    <book year='{ $b/@year }'>
     { if ($b/title='TCP/IP Illustrated') then $b/author else $b/publisher }
    </book>
 }
</bib> ")
return local:exps($query/QueryPlan/*,())

 