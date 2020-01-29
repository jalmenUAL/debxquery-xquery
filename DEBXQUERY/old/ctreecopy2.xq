(: GROUP BY, ORDER BY  :)
(: PATHS IN BOOLEAN CONDITIONS :)
(: EFFICIENCY :)
 
declare function local:For($for,$groupby,$orderby,$where,$return,$context,$static)
{ 
  let $var := $for/Var
  let $path := $for/*[2]  
  let $values := local:exp($path,$context,$static)/values
  return
  <For>
  <values>{
  <partial type="Bound">{$values}</partial>,   
  let $count := count($values/value/node())  
  return     
  if ($count>0) then  
  (   
  for $i in 1 to $count 
  let $context := <context>{
  $context/*
  union <var><name>{$var}</name>
  <path>{$path}</path>
  <context>{$context/*}</context>
  <position>{$i}</position></var>
  }</context>
  let $return := 
  local:Return($return,
  $context,$static)    
  return
  if (exists($where))
  then
  (
  let $rwhere := local:Where($where,
  $context,$static)
  return
  if ($rwhere/values/value/text()=true())
  then 
      <partial type="For">     
      <partial type="where">{$rwhere/values}</partial>
      <partial type="return">{$return/values}</partial></partial>
      union
      ($return/values/value)
  else 
     <partial type="For"> 
      <partial type="where">{$rwhere/values}</partial>
      <partial type="return"></partial></partial> 
      
  ) (:nowhere:)
  else 
  <partial type="For">
  <partial type="return">{$return/values}</partial>
  </partial> union
  ($return/values/value) 
  (:nopath:)
)
  else (<partial type="For">
  <partial type="return"></partial></partial>) 
  union <value>
  </value>
  }  
  </values></For>  
};

declare function local:Let($let,$groupby,$orderby,$where,$return,$context,$static)
{
  let $var := $let/Var
  let $path := $let/*[2]
  let $values := local:exp($path,$context,$static)/values
  return
  <Let>
  <values>{
  <partial type="Bound">{$values}</partial>,
  let $i := 0 
  let $context := <context>{
  $context/*
  union <var><name>{$var}</name>
  <path>{$path}</path>
  <context>{$context/*}</context>
  <position>{$i}</position></var>
  }</context>
  let $return := 
  local:Return($return,
  $context,$static) 
  return
  if (exists($where))
  then 
  (let $rwhere := local:Where($where,
  $context,$static)
  return
  if ($rwhere/values/value/text()=true())
  then 
         (<partial type="Let">    
        <partial type="where">{$rwhere/values}</partial>
        <partial type="return">{$return/values}</partial>
        </partial>)  union
        ($return/values/value)  
  else 
        (<partial type="Let"> 
        <partial type="where">{$rwhere/values}
        </partial><partial type="return"></partial>
        </partial>) 
        
  ) (: nowhere :)
  else  
        (<partial type="Let">
        <partial type="return">{$return/values}</partial>
       </partial>) union
        ($return/values/value)
  }</values></Let>
};


declare function local:Where($where,$context,$static)
{
  if (empty($where/*)) then 
                       <Where><values><value>
                       {true()}</value></values></Where>  
                       else 
                       let $exp := local:exp($where/*,$context,$static)
                       return
                       <Where>{$exp/values}</Where>  
};

declare function local:Return($return,$context,$static)
{
 if (name(head($return))="For" or name(head($return))="Let") 
               then local:exp(<GFLWOR>{$return}</GFLWOR>,$context,$static)
               else local:exp($return,$context,$static) 
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
   if (name($exp)="If") then local:If($exp,$context,$static) 
   else   
   if (name($exp)="Quantifier") then local:Quantifier($exp,$context,$static) 
   else          
   if (name($exp)="StaticFuncCall") then local:StaticFuncCall($exp,$context,$static)
   else
   let $path := string-join(for-each($exp,
   function($x){local:Path($x,$context,$static)}),"/")
   let $partial :=
   (if (name($exp)="Union" or
        name($exp)="Intersect" or
        name($exp)="CmpG" or
        name($exp)= "CmpN" or
        name($exp)= "Arith" or
         name($exp)= "FnNot" or
        name($exp)= "And" or
        name($exp)= "Or" or
        substring(name($exp),1,2)="Fn" or
        name($exp)= "List") then   
   element {name($exp)} {$exp/@*,for-each($exp/*,
   function($x){local:exp($x,$context,$static)/values})}
   else $exp)
   return
   let $vpath := xquery:eval($path)
   return
   if (exists($vpath)) then  
   <path>
   <values>{
     (<epartial type="Path">{<epath>{$partial,$context}</epath>}</epartial>) 
     union 
     (for $x in $vpath return   <value>{$x}</value>)}
    </values></path>
   else  
   <path><values>{
     <epartial type="Path">{<epath>{$partial,$context}</epath>}</epartial> 
   }
   </values></path>
   
}; 

declare function local:GFLWOR($query,$context,$static)
{
local:GFLWORitems($query/*,$context,$static)
};
   
declare function local:GFLWORitems($items,$context,$static)
{
if (name(head($items))="For") 
then 
local:For(head($items),local:fgroup(tail($items)),
                local:forder(tail($items)),local:fwhere(tail($items)),
                 local:frest(tail($items)) ,$context,$static)
else 
local:Let(head($items),local:fgroup(tail($items)),
                local:forder(tail($items)),local:fwhere(tail($items)),
                 local:frest(tail($items)),$context,$static)                    
};


declare function local:CElem($query,$context,$static)
{ 
let $exps :=  local:exps(tail($query/*),$context,$static)
return
<CElem>
<values>
<partial type="CElem">{$exps/values}</partial>  
 <value>
 {element {data($query/QNm/@value)} 
 {$exps/values/value/(node()|@*)}}
 </value>
 </values>
 </CElem>  
};

declare function local:CAttr($query,$context,$static)
{ 
let $exps := local:exps(tail($query/*),$context,$static)
return
<CAttr>
<values>
<partial type="CAttr">{$exps/values}</partial>  
<value>
 { attribute {data($query/QNm/@value)} 
  {data($exps/values/value/(node()|@*))}}
</value>
</values>
</CAttr>
};

declare function local:If($query,$context,$static)
{
let $cond := ($query/*)[1]
let $then := ($query/*)[2]
let $else := ($query/*)[3]
let $bcond := local:exp($cond,$context,$static)
return
if ($bcond/values/value/text()=true())  
then 
let $bthen := local:exp($then,$context,$static)
return
<If>
<values>
<partial type="If">
<partial type="Cond">{$bcond/values}</partial>
<partial type="Then">{$bthen/values}</partial>
</partial> 
{$bthen/values/value}
</values></If> 
else 
let $belse := local:exp($else,$context,$static)
return
<If>
<values>
<partial type="If">
<partial type="Cond">{$bcond/values}</partial>
<partial type="Else">{$belse/values}</partial>
</partial>
{$belse/values/value}
</values></If> 
};

declare function local:Quantifier($quan,$context,$static)
{  
if ($quan/@type="some") then 
                   let $res := local:GFLWOR($quan/*,$context,$static)
                   return 
                   <Quantifier>                          
                   <values><partial type="Quantifier">{$res/values}
                   </partial><value>
                   {some $r in $res/values/value/text() satisfies $r="true"}
                   </value></values></Quantifier>
                   else 
                   let $res := local:GFLWOR($quan/*,$context,$static) 
                   return 
                   <Quantifier>
                   <values><partial type="Quantifier">{$res/values}
                   </partial><value>
                   {every $r in $res/values/value/text() satisfies $r="true"}
                   </value></values></Quantifier>
};
 
declare function local:StaticFuncCall($exp,$context,$static) 
{  
let $name := data($exp/@name)
let $args := $exp/*
let $cargs := count($args)
let $staticfun := $static[@name=$name]
let $gflwor := 
local:GFLWOR(
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
return 
<StaticFuncCall>
{<values> 
{
<partial type="StaticFuncCall">
{
for-each($exp/*,
function($x){<partial type="arg">{<epath>{$x,$context}</epath>,
local:exp($x,$context,$static)/values}</partial>}),
<epath>{$exp,$context}</epath>,$gflwor/values
}</partial>

union
($gflwor/values/value)
}</values>
}</StaticFuncCall>
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
             let $con := ($context/*[name/Var/@name=data($varn)])[last()]
             let $path := 
             $con/path
             let $context := 
             $con/context
             let $position := $con/position/text()
             return
             if ($position=0) then 
             local:Path($path/*,$context,$static)    
             else
              "(" || local:Path($path/*,$context,$static)        
             || ")"   || "[" || $position || "]"
                       
   else
   if (name($step)="CachedPath") 
          then string-join(for-each($step/*,
          function($x){local:Path($x,$context,$static)}),"/")               
   else
   if (name($step)="IterPath") 
          then string-join(for-each($step/*,
          function($x){local:Path($x,$context,$static)}),"/")   
   else   
   if (name($step)="Union") then   "(" || 
                   string-join(for-each($step/*,
                   function($x){local:Path($x,$context,$static)}),"|") || ")"  
   else
   if (name($step)="InterSect") then   "(" || 
                   string-join(for-each($step/*,
                   function($x){local:Path($x,$context,$static)}),"intersect") || ")"  
   else 
   
   if (name($step)="MixedPath")
                   then
                   local:Path(<CachedPath>{$step/*}</CachedPath>,$context,$static)                  
   else           
   if (name($step)="CachedFilter") 
          then 
          "(" || local:Path(head($step/*),$context,$static) || ")" ||
          string-join(for-each(tail($step/*),
          function($x){"[" || local:Path($x,$context,$static) || "]"}),"")           
   else
   if (name($step)="IterStep") then 
                "(" || $step/@axis || "::" || $step/@test || ")" ||
                string-join(for-each($step/*,
                function($x){"[" || local:Path($x,$context,$static) || "]"}),"")
   else 
   if (name($step)="IterPosStep") then 
                $step/@axis || "::" || $step/@test || "[" || data($step/Int/@value) || "]"        
   else  
   if (name($step)="CachedStep") then $step/@axis || "::" || $step/@test || "[" || 
                            string-join(for-each($step/*,
                            function($x){local:Path($x,$context,$static)}),"/") || "]"
   else           
   if (name($step)="FnNot") 
          then "not(" || (if (local:exp($step/*,$context,$static)/values/value/text()="true") 
          then "true()" else "false()") || ")"                                          
   else 
   if (substring(name($step),1,2)="Fn") then
             let $args := string-join(for $exp in $step/* return 
             [local:Path($exp,$context,$static)],",")
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
                 string-join(for-each($step/*,
                 function($x){local:Path($x,$context,$static)})," and ")        
   else 
   if (name($step)="Or") then
           string-join(for-each($step/*,
           function($x){local:Path($x,$context,$static)})," or ")         
   else    
   if (name($step)="Empty") then "()"
   else  
   if (name($step)="List") then "(" || 
   string-join(for-each($step/*,
   function($x){local:Path($x,$context,$static)}),",")   || ")"
   else
   if ($step/@type="xs:string") then  "'" || data($step/@value)|| "'"
   else
   if ($step/@type) then data($step/@value)
   else
   let $exp := local:exp($step,$context,$static)/values/value
   return
   if ($exp/text()="true") then "true()"
   else
   if ($exp/text()="false") then "false()"
   else
   serialize(<root>{$exp}</root>, 
   map {'method': 'xml' }) || "/value/node()"   
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

declare function local:trace($string_query)
{
  let $query := xquery:parse($string_query)
  return 
  local:exps($query/QueryPlan/*[not(name(.)="StaticFunc")],
  <context></context>,
  $query/QueryPlan/*[name(.)="StaticFunc"])
};

declare function local:exec($string_query)
{
  local:trace($string_query)/values/value/node()
};

declare function local:showPath($step,$context)
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
             let $con := ($context/*[name/Var/@name=data($varn)])[last()]
             let $path := 
             $con/path
             let $context := 
             $con/context
             let $position := $con/position/text()
             return
             if ($position=0) then 
             local:showPath($path/*,$context)   
             else
              "(" ||  local:showPath($path/*,$context)         
             || ")"   || "[" || $position || "]"
       
               
   else
   if (name($step)="CachedPath") 
          then string-join(for-each($step/*,
          function($x){local:showPath($x,$context)}),"/")               
   else
   if (name($step)="IterPath") 
          then string-join(for-each($step/*,
          function($x){local:showPath($x,$context)}),"/")      
   else   
   if (name($step)="Union") then   "(" || 
                   string-join(for-each($step/*,
                   function($x){local:showPath($x,$context)}),"|") || ")"  
   else
   if (name($step)="InterSect") then   "(" || 
                   string-join(for-each($step/*,
                   function($x){local:showPath($x,$context)}),"intersect") || ")"  
   else
   if (name($step)="MixedPath")
                   then
                   local:showPath(<CachedPath>{$step/*}</CachedPath>,$context)                  
   else           
   if (name($step)="CachedFilter") 
          then 
          "(" || local:showPath(head($step/*),$context) || ")" ||
          string-join(for-each(tail($step/*),
          function($x){"[" || local:showPath($x,$context) || "]"}),"") 
   else
   if (name($step)="IterStep") then 
                "(" || $step/@axis || "::" || $step/@test || ")" ||
                string-join(for-each($step/*,
                function($x){"[" || local:showPath($x,$context) || "]"}),"")
   else 
   if (name($step)="IterPosStep") then 
                $step/@axis || "::" || $step/@test || "[" || data($step/Int/@value) || "]"                
   else  
   if (name($step)="CachedStep") then $step/@axis || "::" || $step/@test || "[" || 
                            string-join(for-each($step/*,
                            function($x){local:showPath($x,$context)}),"/") || "]"             
   else           
   if (name($step)="FnNot") 
          then "not(" || local:showPath($step/*,$context) || ")" 
   else
   if (name($step)="Quantifier") 
          then $step/@type || " " || $step/GFLWOR/For/Var/@name || " in " || 
          local:showPath($step/GFLWOR/For/*[2],$context)
          || " satisfies " || local:showPath(($step/GFLWOR)/*[2],
          <context>{
           $context/*
          union <var><name>{$step/GFLWOR/For/Var}</name><path>{$step/GFLWOR/For/*[2]}</path>
          <context>{$context/*}</context><position>{0}</position></var>}</context>)                                   
   else
   if (substring(name($step),1,2)="Fn") then             
             let $args := string-join(for $exp in $step/* return [local:showPath($exp,$context)],",")
             return 
             substring-before(data($step/@name),"(") || "(" || $args || ")"
   else
   if (name($step)="StaticFuncCall")  then 
             let $args := string-join(for $exp in $step/* return [local:showPath($exp,$context)],",")
             return 
             data($step/@name) || "(" || $args || ")"       
   else 
   if (name($step)="CmpG") then
              let $cond1 := local:showPath(($step/*)[1],$context)
              let $cond2 := local:showPath(($step/*)[2],$context)
              return "(" || $cond1 || $step/@op || $cond2 || ")"  
   else
   if (name($step)="Arith") then
              let $cond1 := local:showPath(($step/*)[1],$context)
              let $cond2 := local:showPath(($step/*)[2],$context)
              return "(" || $cond1 || $step/@op || $cond2 || ")"            
   else 
   if (name($step)="CmpN") then
              let $cond1 := local:showPath(($step/*)[1],$context)
              let $cond2 := local:showPath(($step/*)[2],$context)
              return "(" || $cond1 || $step/@op || $cond2 || ")"             
   else 
   if (name($step)="And") then
                 string-join(for-each($step/*,
                 function($x){local:showPath($x,$context)})," and ")        
   else 
   if (name($step)="Or") then
           string-join(for-each($step/*,
           function($x){local:showPath($x,$context)})," or ")         
   else    
   if (name($step)="Empty") then"()"
   else
   if (name($step)="List") then "(" || 
   string-join(for-each($step/*,
   function($x){local:showPath($x,$context)}),",")   || ")"
   else  
   if ($step/@type="xs:string") then  "'" || data($step/@value)|| "'"
   else
   if ($step/@type) then data($step/@value)
   else "()"
}; 

declare function local:print_context($context)
{
  <a>{
  let $count := count($context/var/name)
  for $i in 1 to $count
  return
  data(($context/var/name/Var/@name)[$i]) || 
  "=" || 
  local:showPath(($context/var/path/*)[$i],$context)
  }</a>
};

declare function local:epaths($string_query)
{
  let $trace := local:trace($string_query)
  let $result :=
  (
  for $empty in $trace//values/value[empty(./(node() |@*))]/../partial
  let $path := ($empty/epath/*)[1]
  let $context := ($empty/epath/*)[2]
  let $sp := local:showPath($path,$context)
  let $c := local:print_context($context)
  return 
  if ($sp and not($sp="()")) then  "Empty path found in '" ||  $sp || "'" 
  else ()
  )
  return
  if (not(empty($result))) then $result
  else "Empty path not found"    
};



declare function local:showCall($epath)
{  
   let $step := ($epath/*)[1]
   let $context := ($epath/*)[2]
   return
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
             let $con := ($context/*[name/Var/@name=data($varn)])[last()]
             let $path := 
             $con/path
             let $context := 
             $con/context
             let $position := $con/position/text()
             let $v :=   
                  local:showPath($path/*,$context)         
             return
             if ($position=0) then 
                $v 
             else
              "(" || $v    
             || ")"   || "[" || $position || "]"
       
               
   else
   if (name($step)="CachedPath") 
          then string-join(for-each($step/*,
          function($x){local:showCall(<epath>{$x,$context}</epath>)}),"/")               
   else
   if (name($step)="IterPath") 
          then string-join(for-each($step/*,
          function($x){local:showCall(<epath>{$x,$context}</epath>)}),"/")      
   else   
   if (name($step)="Union") then
   if ($step/values) then
      "(" || 
                   string-join(for-each($step/values/partial/*,
                   function($x){local:showCall($x)}),"|") || ")"  
   else
       "(" || 
                   string-join(for-each($step/*,
                   function($x){<epath>{$x,$context}</epath>}),"|") || ")"
   else
   if (name($step)="InterSect") then 
   if ($step/values) then
   
     "(" || 
                   string-join(for-each($step/values/partial/*,
                   function($x){local:showCall($x)}),"intersect") || ")"  
                   
   else 
    "(" || 
                   string-join(for-each($step/*,
                   function($x){<epath>{$x,$context}</epath>}),"intersect") || ")" 
   else
   if (name($step)="MixedPath")
                   then
                   local:showCall(<epath><CachedPath>{$step/*}</CachedPath>{$context}</epath>)                  
   else           
   if (name($step)="CachedFilter") 
          then 
          "(" || local:showCall(<epath>{head($step/*),$context}</epath>) || ")" ||
          string-join(for-each(tail($step/*),
          function($x){"[" || local:showCall(<epath>{$x,$context}</epath>) || "]"}),"") 
   else
   if (name($step)="IterStep") then 
                "(" || $step/@axis || "::" || $step/@test || ")" ||
                string-join(for-each($step/*,
                function($x){"[" || local:showCall(<epath>{$x,$context}</epath>) || "]"}),"")
   else 
   if (name($step)="IterPosStep") then 
                $step/@axis || "::" || $step/@test || "[" || data($step/Int/@value) || "]"                
   else  
   if (name($step)="CachedStep") then $step/@axis || "::" || $step/@test || "[" || 
                            string-join(for-each($step/*,
                            function($x){local:showCall(<epath>{$x,$context}</epath>)}),"/") || "]"             else           
   if (name($step)="FnNot") then
   if ($step/values)  
  
          then "not(" || local:showCall($step/values/partial/*) || ")" 
   else  "not(" || local:showCall(<epath>{$step/*,$context}</epath>) || ")" 
   else
   if (name($step)="Quantifier") 
          then $step/@type || " " || $step/GFLWOR/For/Var/@name || " in " || 
          local:showCall(<epath>{$step/GFLWOR/For/*[2],$context}</epath>)
          || " satisfies " || local:showCall(<epath>{($step/GFLWOR)/*[2],
          <context>{
           $context/*
          union <var><name>{$step/GFLWOR/For/Var}</name><path>{$step/GFLWOR/For/*[2]}</path>
          <context>{$context/*}</context><position>{0}</position></var>}</context>}</epath>)                                   
   else
   
   if (substring(name($step),1,2)="Fn") then             
             let $args := string-join(for $exp in $step/* return 
             [local:showCall(<epath>{$exp,$context}</epath>)],",")
             return 
             substring-before(data($step/@name),"(") || "(" || $args || ")"
   else
   if (name($step)="StaticFuncCall")  then 
             let $args := string-join(for $exp in $step/* return 
             [local:showCall(<epath>{$exp,$context}</epath>)],",")
             return
             data($step/@name) || "(" || $args || ")" 
               
             
                
   else 
   if (name($step)="CmpG") then
   
              if ($step/values) then
              let $cond1 := local:showCall(($step/values/partial/*)[1])
              let $cond2 := local:showCall(($step/values/partial/*)[2])
              return "(" || $cond1 || " " || $step/@op || " " || $cond2 || ")" 
              else
              let $cond1 := local:showCall(<epath>{($step/*)[1],$context}</epath>)
              let $cond2 := local:showCall(<epath>{($step/*)[2],$context}</epath>)
              return "(" || $cond1 || " " || $step/@op || " " || $cond2 || ")" 
   else
   if (name($step)="Arith") then
              if ($step/values) then
              let $cond1 := local:showCall(($step/values/partial/*)[1])
              let $cond2 := local:showCall(($step/values/partial/*)[2])
              return "(" || $cond1 || " " || $step/@op || " " || $cond2 || ")" 
              else    
              let $cond1 := local:showCall(<epath>{($step/*)[1],$context}</epath>)
              let $cond2 := local:showCall(<epath>{($step/*)[2],$context}</epath>)
              return "(" || $cond1 || " " || $step/@op || " " || $cond2 || ")"       
   else 
   if (name($step)="CmpN") then
              if ($step/values) then
              let $cond1 := local:showCall(($step/values/partial/*)[1])
              let $cond2 := local:showCall(($step/values/partial/*)[2])
              return "(" || $cond1 || " " || $step/@op || " " || $cond2 || ")" 
              else
              let $cond1 := local:showCall(<epath>{($step/*)[1],$context}</epath>)
              let $cond2 := local:showCall(<epath>{($step/*)[2],$context}</epath>)
              return "(" || $cond1 || " " || $step/@op || " " || $cond2 || ")"            
   else 
   if (name($step)="And") then
                 if ($step/values) then
                 string-join(for-each($step/values/partial/*,
                 function($x){local:showCall($x)})," and ")      
                 else 
                 string-join(for-each($step/*,
                 function($x){local:showCall(<epath>{$x,$context}</epath>)})," and ")
   else 
   if (name($step)="Or") then
           if ($step/values) then
           string-join(for-each($step/values/partial/*,
           function($x){local:showCall($x)})," or ")  
           else
           string-join(for-each($step/*,
           function($x){local:showCall(<epath>{$x,$context}</epath>)})," or ")       
   else    
   if (name($step)="Empty") then"()"
   else
   if (name($step)="List") then
             if ($step/values) then
              "(" || 
               string-join(for-each($step/values/partial/*,
               function($x){local:showCall($x)}),",")   || ")" 
             else
             "(" || string-join(for-each($step/*,
             function($x){local:showCall(<epath>{$x,$context}</epath>)}),",")   
             || ")" 
   else  
   if ($step/@type="xs:string") then  "'" || data($step/@value)|| "'"
   else
   if ($step/@type) then data($step/@value)
   else "()"
}; 

declare function local:treecalls($string_query)
{
  let $query := xquery:parse($string_query)
  let $trace := 
  local:exps($query/QueryPlan/*[not(name(.)="StaticFunc")],
  <context></context>,
  $query/QueryPlan/*[name(.)="StaticFunc"])
  let $static := $query/QueryPlan/*[name(.)="StaticFunc"]
  return local:tcalls($trace/values,$static)
};

declare function local:tcalls($trace,$static)
{
  if ($trace/partial/epath) 
  then
  for $p in $trace/partial
  return
  let $epath := ($p/epath)[1]
  return
  if (not(name(($epath/*)[1])="Union") and
      not(name(($epath/*)[1])="Intersect") and
      not(name(($epath/*)[1])="FnNot") and
      not(name(($epath/*)[1])="VarRef") and
      not(name(($epath/*)[1])="Quantifier") and
      not(substring(name(($epath/*)[1]),1,2)="Fn") and
      not(name(($epath/*)[1])="CmpG") and
      not(name(($epath/*)[1])="Arith") and
      not(name(($epath/*)[1])="CmpN") and
      not(name(($epath/*)[1])="And") and
      not(name(($epath/*)[1])="Or") and
      not(name(($epath/*)[1])="Empty") and
      not(name(($epath/*)[1])="List") 
      and not (($epath/*)[1]/@type))
  then
  let $context := $p/epath/context
  let $values :=  
  if ($p/values/value/node()) then string-join(serialize($p/values/value/node()),",")    
  else  string-join($p/values/value/@*,",")
  let $c := local:print_context($context)
  let $sc := local:showCall($epath)
  return
  if (not($sc="()")) then
  <question>{
  "Can be " || $sc || " equal to " || "(" ||  $values || ")" || "?" }
  {
   for-each($trace/partial,
    function($x){local:tcalls($x/partial/values,
    $static)}) union local:tcalls($p/values,$static)
  }
  </question>  
  else ()
  else 
    for-each($trace/partial,
    function($x){local:tcalls($x/values,
    $static)}) union  local:tcalls($p/values,$static)
  else   
  for-each($trace/partial,
    function($x){local:tcalls($x/values,
    $static)}) 
};

(:
declare function local:allcalls($string_query)
{
  let $query := xquery:parse($string_query)
  let $trace := 
  local:exps($query/QueryPlan/*[not(name(.)="StaticFunc")],
  <context></context>,
  $query/QueryPlan/*[name(.)="StaticFunc"])
  let $static := $query/QueryPlan/*[name(.)="StaticFunc"]
  for $p in $trace//values
  let $epath := ($p/partial/epath)[1]
  
  return
   if (not(name(($epath/*)[1])="Union") and
      not(name(($epath/*)[1])="Intersect") and
      not(name(($epath/*)[1])="FnNot") and
      not(name(($epath/*)[1])="VarRef") and
      not(name(($epath/*)[1])="Quantifier") and
      not(substring(name(($epath/*)[1]),1,2)="Fn") and
      not(name(($epath/*)[1])="CmpG") and
      not(name(($epath/*)[1])="Arith") and
      not(name(($epath/*)[1])="CmpN") and
      not(name(($epath/*)[1])="And") and
      not(name(($epath/*)[1])="Or") and
      not(name(($epath/*)[1])="Empty") and
      not(name(($epath/*)[1])="List") 
      and not (($epath/*)[1]/@type))
  then
  let $context := $p/partial/epath/context
  let $values :=  
  if ($p/value/node()) then string-join(serialize($p/value/node()),",")    
  else  string-join($p/value/@*,",")
  let $c := local:print_context($context)
  let $sc := local:showCall($epath)
  return
  if (not($sc="()")) then
  "Can be " || $sc || " equal to " || "(" ||  $values || ")" || "?" 
  else () 
  else ()
   
  
  
};
:)

local:trace("
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

 