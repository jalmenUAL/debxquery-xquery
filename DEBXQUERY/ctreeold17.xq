(: GROUP BY, ORDER BY, OPTIMIZAR  :)

declare function local:For($for,$groupby,$orderby,$where,$return,$context,$static)
{
  
  let $var := $for/Var
  let $path := $for/*[2]
  return
  <For>{$var} 
  <values>{   
  let $count := count(local:exp($path,$context,$static)/values/value/content/node())  
  return     
  if ($count>0) then  
  (   
  for $i in 1 to $count 
  let $return := 
  local:Return($return,
  <context>{
  $context/*
  union <var><name>{$var}</name><path>{$path}</path><context>{$context/*}</context><position>{$i}</position></var>
  }</context>,$static) 
  return
  if (exists($where))
  then
  (
  let $rwhere := local:Where($where,
  <context>{
  $context/*
  union <var><name>{$var}</name><path>{$path}</path><context>{$context/*}</context><position>{$i}</position></var>
  }</context>,$static)
  return
  
  if ($rwhere/values/value/content/text()=true())
   
  then 
      <value>{$return/values/value/content,<path><where>{$rwhere/values/value/path}</where>
      <return>{$return/values/value/path}</return></path>}</value>  
  else 
      <value><content></content><path><where>{$rwhere/values/value/path}</where>
      <return>{$return/values/value/path}</return></path></value>
  ) (:nowhere:)
  else <value>{$return/values/value/content,<path>
      <return>{$return/values/value/path}</return></path>}</value> 
  ) (:nopath:)
  else <value><content></content><path><for>{local:exp($path,$context,$static)/values/path}</for>
  </path></value>
  }</values></For>  
};

declare function local:Let($let,$groupby,$orderby,$where,$return,$context,$static)
{
  let $var := $let/Var
  let $path := $let/*[2]
  return
  <Let>{$var}  
  <values>{   
  let $i := 0 
  let $return := 
  local:Return($return,
  <context>{
  $context/*
  union <var><name>{$var}</name><path>{$path}</path><context>{$context/*}</context><position>{$i}</position></var>
  }</context>,$static) 
  return
  if (exists($where))
  then 
  (let $rwhere := local:Where($where,
  <context>{
  $context/* 
  union <var><name>{$var}</name><path>{$path}</path><context>{$context/*}</context><position>{$i}</position></var>
  }</context>,$static)
  return
  if ($rwhere/values/value/content/text()=true()) 
  then 
         for $content in $return/values/value/content
         return
        <value>{$content,<path><where>{$rwhere/values/value/path}</where>
        <return>{$return/values/value/path}</return></path>}</value>   
  else 
        <value><content></content><path><where>{$rwhere/values/value/path}</where>
        <return>{$return/values/value/path}</return></path></value>
  ) (: nowhere :)
  else  for $content in $return/values/value/content
        return <value>{$content,<path>
        <return>{$return/values/value/path}</return></path>}</value> 
  }</values></Let>
};


declare function local:Where($where,$context,$static)
{
  if (empty($where/*)) then 
                       <Where><values><value>
                       <content>{true()}</content></value></values></Where>  
                       else 
                       let $exp := local:exp($where/*,$context,$static)
                       return
                       <Where>{<values>{$exp/values/value,$exp/values/path}</values>}</Where>  
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
   let $path := string-join(for-each($exp,function($x){local:Path($x,$context,$static)}),"/")
   return
   if (exists(xquery:eval($path))) then  
   <path><values>{for $x in xquery:eval($path) return
   <value><path>{$context,<item>{$exp}</item>,<result>{$x}</result>}</path>
          <content>{$x}</content></value>}</values></path>
   else  
   <path><values>{
   <value><path>{$context,<item>{$exp}</item>,<result></result>}</path>
          <content></content></value>}</values></path>
   
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
local:Let(head($items),local:fgroup(tail($items)),  local:forder(tail($items)),local:fwhere(tail($items)),
                 local:frest(tail($items)),$context,$static)                    
};


declare function local:CElem($query,$context,$static)
{ 
let $exps :=  local:exps(tail($query/*),$context,$static)
return
<CElem>
<values>{<value>{
     $exps/values/value/path}
      <content>{element {data($query/QNm/@value)} 
      {$exps/values/value/content/(node()|@*)}}
      </content></value>
}</values>
</CElem>  
};

declare function local:CAttr($query,$context,$static)
{ 
let $exps := local:exps(tail($query/*),$context,$static)
return
<CAttr>
<values>{<value>{
  $exps/values/value/path}
  <content>{attribute {data($query/QNm/@value)} 
  {data($exps/values/value/content/(node()|@*))}}
  </content></value>
}</values>
</CAttr>
};

declare function local:If($query,$context,$static)
{
let $cond := ($query/*)[1]
let $then := ($query/*)[2]
let $else := ($query/*)[3]
let $bcond := local:exp($cond,$context,$static)
return
if ($bcond/values/value/content/text()=true()) 
then 
let $bthen := local:exp($then,$context,$static)
return
<If>
<values><value>
<path>
<If>{$bcond/values/value/path}</If>
<Then>{$bthen/values/value/path}</Then>
</path>
{$bthen/values/value/content}
</value></values></If> 
else 
let $belse := local:exp($else,$context,$static)
return
<If>
<values><value>
<path>
<If>{$bcond/values/value/path}</If>
<Else>{$belse/values/value/path}</Else>
</path>
{$belse/values/value/content}
</value></values></If> 
};



 
declare function local:Quantifier($quan,$context,$static)
{  
if ($quan/@type="some") then 
                   let $res := local:GFLWOR($quan/*,$context,$static)
                   return 
                   <Quantifier>                          
                   <values><value>{<path><Quantifier>{$res/values/value/path}</Quantifier></path>}
                   <content>{some $r in $res/values/value/content/text() satisfies $r="true"}</content>
                   </value></values></Quantifier>
                   else 
                   let $res := local:GFLWOR($quan/*,$context,$static) 
                   return 
                   <Quantifier>
                   <values><value>{<path><Quantifier>{$res/values/value/path}</Quantifier></path>}
                   <content>{every $r in $res/values/value/content/text() satisfies $r="true"}</content>
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
<values>
{for $x in $gflwor/values/value
return
<value>
{
$x/content,
<path><StaticFuncCall>{$x/path}</StaticFuncCall></path> 
}
</value>
}</values>
</StaticFuncCall>

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
          then string-join(for-each($step/*,function($x){local:Path($x,$context,$static)}),"/")               
   else
   if (name($step)="IterPath") 
          then string-join(for-each($step/*,function($x){local:Path($x,$context,$static)}),"/")   
   else   
   if (name($step)="Union") then   "(" || 
                   string-join(for-each($step/*,function($x){local:Path($x,$context,$static)}),"|") || ")"  
   else
   if (name($step)="InterSect") then   "(" || 
                   string-join(for-each($step/*,function($x){local:Path($x,$context,$static)}),"intersect") || ")"  
   else 
   
   if (name($step)="MixedPath")
                   then
                   local:Path(<CachedPath>{$step/*}</CachedPath>,$context,$static)                  
   else           
   if (name($step)="CachedFilter") 
          then 
          "(" || local:Path(head($step/*),$context,$static) || ")" ||
          string-join(for-each(tail($step/*),function($x){"[" || local:Path($x,$context,$static) || "]"}),"")           
   else
   if (name($step)="IterStep") then 
                "(" || $step/@axis || "::" || $step/@test || ")" ||
                string-join(for-each($step/*,function($x){"[" || local:Path($x,$context,$static) || "]"}),"")
   else 
   if (name($step)="IterPosStep") then 
                $step/@axis || "::" || $step/@test || "[" || data($step/Int/@value) || "]"        
   else  
   if (name($step)="CachedStep") then $step/@axis || "::" || $step/@test || "[" || 
                            string-join(for-each($step/*,function($x){local:Path($x,$context,$static)}),"/") || "]"
   else           
   if (name($step)="FnNot") 
          then "not(" || (if (local:exp($step/*,$context,$static)/values/value/content/text()="true") 
          then "true()" else "false()") || ")"                                          
   else 
   if (substring(name($step),1,2)="Fn") then
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
                 string-join(for-each($step/*,function($x){local:Path($x,$context,$static)})," and ")        
   else 
   if (name($step)="Or") then
           string-join(for-each($step/*,function($x){local:Path($x,$context,$static)})," or ")         
   else    
   if (name($step)="Empty") then "()"
   else  
   if (name($step)="List") then "(" || 
   string-join(for-each($step/*,function($x){local:Path($x,$context,$static)})," , ")   || ")"
   else
   if ($step/@type="xs:string") then  "'" || data($step/@value)|| "'"
   else
   if ($step/@type) then data($step/@value)
   else
   let $exp := local:exp($step,$context,$static)/values/value/content
   return
   if ($exp/text()="true") then "true()"
   else
   if ($exp/text()="false") then "false()"
   else
   serialize(<root>{$exp}</root>, 
   map {'method': 'xml' }) || "/content/node()"
   
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
   (:
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
             $varn   
             else
              "(" || $varn        
             || ")"   || "[" || $position || "]"
   :)    
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
              "(" || local:showPath($path/*,$context)        
             || ")"   || "[" || $position || "]"                    
   else
   if (name($step)="CachedPath") 
          then string-join(for-each($step/*,function($x){local:showPath($x,$context)}),"/")               
   else
   if (name($step)="IterPath") 
          then string-join(for-each($step/*,function($x){local:showPath($x,$context)}),"/")      
   else   
   if (name($step)="Union") then   "(" || 
                   string-join(for-each($step/*,function($x){local:showPath($x,$context)}),"|") || ")"  
   else
   if (name($step)="InterSect") then   "(" || 
                   string-join(for-each($step/*,function($x){local:showPath($x,$context)}),"intersect") || ")"  
   else
   if (name($step)="MixedPath")
                   then
                   local:showPath(<CachedPath>{$step/*}</CachedPath>,$context)                  
   else           
   if (name($step)="CachedFilter") 
          then 
          "(" || local:showPath(head($step/*),$context) || ")" ||
          string-join(for-each(tail($step/*),function($x){"[" || local:showPath($x,$context) || "]"}),"")                  
   else
   if (name($step)="IterStep") then 
                "(" || $step/@axis || "::" || $step/@test || ")" ||
                string-join(for-each($step/*,function($x){"[" || local:showPath($x,$context) || "]"}),"")
   else 
   if (name($step)="IterPosStep") then 
                $step/@axis || "::" || $step/@test || "[" || data($step/Int/@value) || "]"                
   else  
   if (name($step)="CachedStep") then $step/@axis || "::" || $step/@test || "[" || 
                            string-join(for-each($step/*,function($x){local:showPath($x,$context)}),"/") || "]"             else           
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
                 string-join(for-each($step/*,function($x){local:showPath($x,$context)})," and ")        
   else 
   if (name($step)="Or") then
           string-join(for-each($step/*,function($x){local:showPath($x,$context)})," or ")         
   else    
   if (name($step)="Empty") then"()"
   else
   if (name($step)="List") then "(" || 
   string-join(for-each($step/*,function($x){local:showPath($x,$context)})," , ")   || ")"
   else  
   if ($step/@type="xs:string") then  "'" || data($step/@value)|| "'"
   else
   if ($step/@type) then data($step/@value)
   else "()"
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
  local:trace($string_query)/values/value/content/node()
};

declare function local:epaths($string_query)
{
  let $path := local:trace($string_query) (://item/../result[empty(./(node()|@*)) or text()="false"]:)
  return $path
  (:let $context := local:trace($string_query)//item[empty(./node()) and @type=$type]/../context
  return
  if (not(local:showPath($path,$context)="()")) then
                 "Empty path found in '" || 
                 local:showPath($path,$context) || 
                 "' where " || local:print_context($context)
  else "No empty path found":)
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


 

local:epaths("
<bib>
 {
  for $b in db:open('bstore1')/bib/mierda
  where $b/publisher = 'Addison-Wesley' and $b/@year > 1991
  return
    <book year='{ $b/@year }'>
     { $b/title }
    </book>
 }
</bib> ") 



 