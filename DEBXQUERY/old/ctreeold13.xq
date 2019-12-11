(: UNION OPERATOR, ORDER BY, LOCAL FUNCTIONS, NESTED EXPRESSIONS, AGGREGATORS, XML DOCS  :)

declare function local:For($for,$where,$return,$context)
{
  
  let $var := $for/Var
  let $path := $for/*[2]
  return
  <For>{$var}
  <values>{
  let $count := count(local:exp($path,$context))
  return 
  for $i in 1 to $count 
  where local:Where($where,
  <var><name>{$var}</name><path>{$path}</path><position>{$i}</position></var> union $context) 
  return
  <value> 
  {local:Return($return, 
  <var><name>{$var}</name><path>{$path}</path><position>{$i}</position></var> union $context)}
  </value> 
  }</values></For>
  
};

declare function local:Let($let,$where,$return,$context)
{
  let $var := $let/Var
  let $path := $let/*[2]
  return
  <Let>{$var}
  <values>{
  let $i := 0 
  where local:Where($where,
  <var><name>{$var}</name><path>{$path}</path><position>{$i}</position></var> union $context)
  return 
  <value>{
  local:Return($return, 
  <var><name>{$var}</name><path>{$path}</path><position>{$i}</position></var> union $context)
  }</value>
  }</values></Let>
};

declare function local:exps($query,$context)
{
 <values>{for $exp in $query return <value>{local:exp($exp,$context)}</value>
}</values>};

declare function local:exp($exp,$context)
{
   if (name($exp)="GFLWOR") then local:GFLWOR($exp,$context)
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
   return xquery:eval($path)  
};

 
declare function local:Quantifier($quan,$context)
{
  
  if ($quan/@type="some") then let $res := local:GFLWOR($quan/*,$context)//value/(*|text())
                               return some $r in $res satisfies $r=true()
  else let $res := local:GFLWOR($quan/*,$context)//value/(*|text())
                   return every $r in $res satisfies $r=true()
  
};
 

declare function local:Where($where,$context)
{
  if (empty($where/*)) then true()
  else local:exp($where/*,$context)
};

 


declare function local:Return($return,$context)
{
 local:exp($return,$context)
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
             else "(" || local:Path($path/*,$context) || ")" || "[" || $position || "]"
                       
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
   data($step/@value)            
}; 
 

declare function local:CElem($query,$context)
{
 <CElem>{$query/QNm,<values>{local:exps(tail($query/*),$context)/value}</values>}</CElem> 
};

declare function local:CAttr($query,$context)
{ 
 <CAttr>{$query/QNm,<values>{local:exps(tail($query/*),$context)/value}</values>}</CAttr>
};

declare function local:GFLWOR($query,$context)
{
<GLFWOR>{local:GFLWORitems($query/*,$context)}</GLFWOR>  
};

declare function local:GFLWORitems($items,$context)
{
if (name(head($items))="For") 
then 
local:For(head($items),tail($items)[name(.)="Where"],tail($items)[not(name(.)="Where")],$context)
else 
local:Let(head($items),tail($items)[name(.)="Where"],tail($items)[not(name(.)="Where")],$context)
                      
};

declare function local:If($query,$context)
{
let $cond := ($query/*)[1]
let $then := ($query/*)[2]
let $else := ($query/*)[3]
return
if (local:exp($cond,$context)) then local:exp($then,$context) 
                               else local:exp($else,$context)
};

declare function local:Union($query,$context)
{
<Union>{<values>{local:exps($query/*,$context)/value}</values>}</Union>
};

declare function local:List($query,$context)
{
<List>{<values>{local:exps($query/*,$context)/value}</values>}</List>
};
  
let $query :=
xquery:parse(
"
<bib>
 {
  for $b in db:open('bstore1')/bib/book/title
  return $b
}
</bib>  
")
return local:exps($query/QueryPlan/*,())

 