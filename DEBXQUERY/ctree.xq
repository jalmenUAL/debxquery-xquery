(: PATHS IN BOOLEAN CONDITIONS :)
 
  
declare function local:For($for,$groupby,$orderby,$where,$return,$context,$static)
{ 
  if (exists($groupby) and exists($orderby) and $orderby/Key/@dir="ascending")
  then
  let $var := $for/Var
  let $path := $for/*[2]  
  let $v := local:exp($path,$context,$static)/values
  let $values := $v/value/node()  
  return
  <For>
  <values>{
  <partial type="Bound">{$v}</partial>,
  for $value in $values 
  let $context := <context>{
  $context/*
  union <var><name>{$var}</name>
  <path>{$value}</path>
  </var>
  }</context>
  group by $g := xquery:eval(local:Path(($groupby/Spec/*)[2],$context,$static))
  let $context2 := <context>{
  $context/*
  union <var><name>{($groupby/Spec/*)[1]}</name>
  <path>{$g}</path></var>
  union <var><name>{$var}</name>
  <path>{$value}</path>
  </var>
  }</context>
  order by string-join(for $x in $orderby/Key/* return xquery:eval(local:Path($x,$context,$static)),",") ascending 
  let $where := local:Where($where,
  $context,$static)
  return 
  if ($where/values/value/node()=true()) then 
  let $return := 
  local:Return($return,
  $context2,$static)    
  return       
      <partial type="For">   
      <partial type="where">{$where/values}</partial>
      <partial type="return">{$return/values}</partial></partial>
      union
      ($return/values/value)
   else  ()
       (:<partial type="For">     
      <partial type="where">{$where/values}</partial>
      <partial type="return"></partial></partial> :)  
  }
  </values>
  </For>  
  else
   if (exists($groupby) and exists($orderby) and $orderby/Key/@dir="descending")
  then
  let $var := $for/Var
  let $path := $for/*[2]  
  let $v := local:exp($path,$context,$static)/values
  let $values := $v/value/node()
   
  return
  <For>
  <values>{
  <partial type="Bound">{$v}</partial>,
  for $value in $values 
  let $context := <context>{
  $context/*
  union <var><name>{$var}</name>
  <path>{$value}</path>
  </var>
  }</context>
  group by $g := xquery:eval(local:Path(($groupby/Spec/*)[2],$context,$static))
  let $context2 := <context>{
  $context/*
  union <var><name>{($groupby/Spec/*)[1]}</name>
  <path>{$g}</path></var>
  union <var><name>{$var}</name>
  <path>{$value}</path>
  </var>
  }</context>
  order by string-join(for $x in $orderby/Key/* return xquery:eval(local:Path($x,$context,$static)),",") descending 
  let $where := local:Where($where,
  $context,$static)
  return 
  if ($where/values/value/node()=true()) then 
  let $return := 
  local:Return($return,
  $context2,$static)    
  return
      
      <partial type="For">   
      
      <partial type="where">{$where/values}</partial>
      <partial type="return">{$return/values}</partial></partial>
      union
      ($return/values/value)
   else  ()
       (:<partial type="For">     
      <partial type="where">{$where/values}</partial>
      <partial type="return"></partial></partial> :)  
  }
  </values>
  </For> 
  else
   if (exists($orderby) and $orderby/Key/@dir="ascending")
  then
 let $var := $for/Var
  let $path := $for/*[2]  
  let $v := local:exp($path,$context,$static)/values
  let $values := $v/value/node()
  return
  <For>
  <values>{
  <partial type="Bound">{$v}</partial>,
  for $value in $values 
  let $context := <context>{
  $context/*
  union <var><name>{$var}</name>
  <path>{$value}</path>
  </var>
  }</context>
  order by string-join(for $x in $orderby/Key/* return xquery:eval(local:Path($x,$context,$static)),",") ascending 
  let $where := local:Where($where,
  $context,$static)
  return 
  if ($where/values/value/node()=true()) then 
  let $return := 
  local:Return($return,
  $context,$static)    
  return     
      <partial type="For">       
      <partial type="where">{$where/values}</partial>
      <partial type="return">{$return/values}</partial></partial>
      union
      ($return/values/value)
   else   ()
      (: <partial type="For">     
      <partial type="where">{$where/values}</partial>
      <partial type="return"></partial></partial> :)
  }
  </values>
  </For>  
 else 
  if (exists($orderby) and $orderby/Key/@dir="descending")
  then
  let $var := $for/Var
  let $path := $for/*[2]  
   let $v := local:exp($path,$context,$static)/values
  let $values := $v/value/node()
  return
  <For>
  <values>{
  <partial type="Bound">{$v}</partial>,
  for $value in $values 
  let $context := <context>{
  $context/*
  union <var><name>{$var}</name>
  <path>{$value}</path>
  </var>
  }</context>
  order by string-join(for $x in $orderby/Key/* return xquery:eval(local:Path($x,$context,$static)),",")  descending 
  let $where := local:Where($where,
  $context,$static)
  return 
  if ($where/values/value/node()=true()) then 
  let $return := 
  local:Return($return,
  $context,$static)    
  return
       
      <partial type="For">   
      
      <partial type="where">{$where/values}</partial>
      <partial type="return">{$return/values}</partial></partial>
      union
      ($return/values/value)
   else   ()
       (:<partial type="For">     
      <partial type="where">{$where/values}</partial>
      <partial type="return"></partial></partial> :)  
  }
  </values>
  </For>  
  else
   if (exists($groupby))
  then
  let $var := $for/Var
  let $path := $for/*[2]  
   let $v := local:exp($path,$context,$static)/values
  let $values := $v/value/node()
  return
  <For>
  <values>{
  <partial type="Bound">{$v}</partial>,
  for $value in $values 
  let $context := <context>{
  $context/*
  union <var><name>{$var}</name>
  <path>{$value}</path>
  </var>
  }</context>
  group by $g := xquery:eval(local:Path(($groupby/Spec/*)[2],$context,$static))
  let $context2 := <context>{
  $context/*
  union <var><name>{($groupby/Spec/*)[1]}</name>
  <path>{$g}</path></var>
  union <var><name>{$var}</name>
  <path>{$value}</path>
  </var>
  }</context> 
  let $where := local:Where($where,
  $context,$static)
  return 
  if ($where/values/value/node()=true()) then 
  let $return := 
  local:Return($return,
  $context2,$static)    
  return
     
      <partial type="For">   
      
      <partial type="where">{$where/values}</partial>
      <partial type="return">{$return/values}</partial></partial>
      union
      ($return/values/value)
   else   ()
       (:<partial type="For">     
      <partial type="where">{$where/values}</partial>
      <partial type="return"></partial></partial>  :)
  }
  </values>
  </For>  
  else 
 let $var := $for/Var
  let $path := $for/*[2]  
  let $v := local:exp($path,$context,$static)/values
  let $values := $v/value/node()
  return
  <For>
  <values>{
  <partial type="Bound">{$v}</partial>,
  for $value in $values 
  let $context := <context>{
  $context/*
  union <var><name>{$var}</name>
  <path>{$value}</path>
  </var>
  }</context>
  let $where := local:Where($where,
  $context,$static)
  return 
  if ($where/values/value/node()=true()) then 
  let $return := 
  local:Return($return,
  $context,$static)    
  return
      <partial type="For">    
      <partial type="where">{$where/values}</partial>
      <partial type="return">{$return/values}</partial></partial>
      union
      ($return/values/value)
   else  ()
       (:<partial type="For">     
      <partial type="where">{$where/values}</partial>
      <partial type="return"></partial></partial> :)
  }
  </values>
  </For>  
};

(: EO :)

declare function local:Let($let,$groupby,$orderby,$where,$return,$context,$static)
{
  if (exists($groupby) and exists($orderby) and $orderby/Key/@dir="ascending")
  then
  let $var := $let/Var
  let $path := $let/*[2]  
  let $values := local:exp($path,$context,$static)/values
  return
  <Let>
  <values>{
  <partial type="Bound">{$values}</partial>,
  let $value := $values/value/node()
  let $context := <context>{
  $context/*
  union <var><name>{$var}</name>
  <path>{$value}</path>
  </var>
  }</context>
  group by $g := xquery:eval(local:Path(($groupby/Spec/*)[2],$context,$static))
  let $context2 := <context>{
  $context/*
  union <var><name>{($groupby/Spec/*)[1]}</name>
  <path>{$g}</path></var>
  union <var><name>{$var}</name>
  <path>{$value}</path>
  </var>
  }</context>
  order by string-join(for $x in $orderby/Key/* return xquery:eval(local:Path($x,$context,$static)),",") ascending 
  let $where := local:Where($where,
  $context,$static)
  return 
  if ($where/values/value/node()=true()) then 
  let $return := 
  local:Return($return,
  $context2,$static)    
  return
       <partial type="Bound">{$value}</partial> union
      <partial type="Let">   
     
      <partial type="where">{$where/values}</partial>
      <partial type="return">{$return/values}</partial></partial>
      union
      ($return/values/value)
   else ()
      (:<partial type="Bound">{$value}</partial>  union
      <partial type="Let">   
       
      <partial type="where">{$where/values}</partial>
      <partial type="return"></partial></partial>   :)
  }
  </values>
  </Let>  
  else
   if (exists($groupby) and exists($orderby) and $orderby/Key/@dir="descending")
  then
  let $var := $let/Var
  let $path := $let/*[2]  
  let $values := local:exp($path,$context,$static)/values
  return
  <Let>
  <values>{
  <partial type="Bound">{$values}</partial>,
  let $value := $values/value/node()
  let $context := <context>{
  $context/*
  union <var><name>{$var}</name>
  <path>{$value}</path>
  </var>
  }</context>
  group by $g := xquery:eval(local:Path(($groupby/Spec/*)[2],$context,$static))
  let $context2 := <context>{
  $context/*
  union <var><name>{($groupby/Spec/*)[1]}</name>
  <path>{$g}</path></var>
  union <var><name>{$var}</name>
  <path>{$value}</path>
  </var>
  }</context>
  order by string-join(for $x in $orderby/Key/* return xquery:eval(local:Path($x,$context,$static)),",") descending 
  let $where := local:Where($where,
  $context,$static)
  return 
  if ($where/values/value/node()=true()) then 
  let $return := 
  local:Return($return,
  $context2,$static)    
  return
      <partial type="Bound">{$value}</partial> union
      <partial type="Let">   
     
      <partial type="where">{$where/values}</partial>
      <partial type="return">{$return/values}</partial></partial>
      union
      ($return/values/value)
   else  ()
      (:
      <partial type="Bound">{$value}</partial>  union
      <partial type="Let">   
       
      <partial type="where">{$where/values}</partial>
      <partial type="return"></partial></partial>   :)
  }
  </values>
  </Let> 
  else
   if (exists($orderby) and $orderby/Key/@dir="ascending")
  then
 let $var := $let/Var
  let $path := $let/*[2]  
  let $values := local:exp($path,$context,$static)/values
  return
  <Let>
  <values>{
  <partial type="Bound">{$values}</partial>,
  let $value := $values/value/node()
  let $context := <context>{
  $context/*
  union <var><name>{$var}</name>
  <path>{$value}</path>
  </var>
  }</context>
  order by string-join(for $x in $orderby/Key/* return xquery:eval(local:Path($x,$context,$static)),",") ascending 
  let $where := local:Where($where,
  $context,$static)
  return 
  if ($where/values/value/node()=true()) then 
  let $return := 
  local:Return($return,
  $context,$static)    
  return
      <partial type="Bound">{$value}</partial> union
      <partial type="Let">   
     
      <partial type="where">{$where/values}</partial>
      <partial type="return">{$return/values}</partial></partial>
      union
      ($return/values/value)
   else ()
     (: <partial type="Bound">{$value}</partial>  union
      <partial type="Let">   
       
      <partial type="where">{$where/values}</partial>
      <partial type="return"></partial></partial> :)  
  }
  </values>
  </Let>  
 else 
  if (exists($orderby) and $orderby/Key/@dir="descending")
  then
  let $var := $let/Var
  let $path := $let/*[2]  
  let $values := local:exp($path,$context,$static)/values
  return
  <Let>
  <values>{
  <partial type="Bound">{$values}</partial>,
  let $value := $values/value/node()
  let $context := <context>{
  $context/*
  union <var><name>{$var}</name>
  <path>{$value}</path>
  </var>
  }</context>
  order by string-join(for $x in $orderby/Key/* return xquery:eval(local:Path($x,$context,$static)),",") descending 
  let $where := local:Where($where,
  $context,$static)
  return 
  if ($where/values/value/node()=true()) then 
  let $return := 
  local:Return($return,
  $context,$static)    
  return
      <partial type="Bound">{$value}</partial> union
      <partial type="Let">   
     
      <partial type="where">{$where/values}</partial>
      <partial type="return">{$return/values}</partial></partial>
      union
      ($return/values/value)
   else () 
      (:
      <partial type="Bound">{$value}</partial>  union
      <partial type="Let">   
       
      <partial type="where">{$where/values}</partial>
      <partial type="return"></partial></partial> :)
  }
  </values>
  </Let>  
  else
   if (exists($groupby))
  then
  let $var := $let/Var
  let $path := $let/*[2]  
  let $values := local:exp($path,$context,$static)/values
  return
  <Let>
  <values>{
  <partial type="Bound">{$values}</partial>,
  let $value := $values/value/node()
  let $context := <context>{
  $context/*
  union <var><name>{$var}</name>
  <path>{$value}</path>
  </var>
  }</context>
  group by $g := xquery:eval(local:Path(($groupby/Spec/*)[2],$context,$static))
  let $context2 := <context>{
  $context/*
  union <var><name>{($groupby/Spec/*)[1]}</name>
  <path>{$g}</path></var>
  union <var><name>{$var}</name>
  <path>{$value}</path>
  </var>
  }</context> 
  let $where := local:Where($where,
  $context,$static)
  return 
  if ($where/values/value/node()=true()) then 
  let $return := 
  local:Return($return,
  $context2,$static)    
  return
      <partial type="Bound">{$value}</partial> union
      <partial type="Let">   
     
      <partial type="where">{$where/values}</partial>
      <partial type="return">{$return/values}</partial></partial>
      union
      ($return/values/value)
   else 
       ()
      (:<partial type="Bound">{$value}</partial>  union
      <partial type="Let">   
       
      <partial type="where">{$where/values}</partial>
      <partial type="return"></partial></partial>  :) 
  }
  </values>
  </Let>  
  else 
  let $var := $let/Var
  let $path := $let/*[2]  
  let $values := local:exp($path,$context,$static)/values
  return
  <Let>
  <values>{
  <partial type="Bound">{$values}</partial>,
  let $value := $values/value/node()
  let $context := <context>{
  $context/*
  union <var><name>{$var}</name>
  <path>{$value}</path>
  </var>
  }</context>
  let $where := local:Where($where,
  $context,$static)
  return 
  if ($where/values/value/node()=true()) then 
  let $return := 
  local:Return($return,
  $context,$static)    
  return
      <partial type="Bound">{$value}</partial> union
      <partial type="Let">   
     
      <partial type="where">{$where/values}</partial>
      <partial type="return">{$return/values}</partial></partial>
      union
      ($return/values/value)
   else 
      ()
      (:<partial type="Bound">{$value}</partial>  union
      <partial type="Let">   
       
      <partial type="where">{$where/values}</partial>
      <partial type="return"></partial></partial> :) 
  }
  </values>
  </Let>  
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

 

declare  function local:exps($query,$context,$static)
{
 for $exp in $query return
 local:exp($exp,$context,$static)
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
        name($exp)="InterSect" or
        name($exp)="CmpG" or
        name($exp)= "CmpN" or
        name($exp)= "Arith" or
        name($exp)= "FnNot" or
        name($exp)= "And" or
        name($exp)= "Or"  or
        substring(name($exp),1,2)="Fn"  or
        name($exp)= "List"  ) then   
   element {name($exp)} {$exp/@*,for-each($exp/*,
   function($x){local:exp($x,$context,$static)/values})}
   else $exp) 
   return
   let $vpath := xquery:eval($path)
   return
   if (exists($vpath)) then  
   <path>
   <values>{
     (<partial type="Path">{<epath>{$partial,$context}</epath>}</partial>) 
     union 
     (for $x in $vpath return   <value>{$x}</value>)}
    </values></path>
   else  
   <path><values>{
     <partial type="Path">{<epath>{$partial,$context}</epath>}</partial> 
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
return
if ($cargs=0) then local:exp($staticfun/*,$context,$static)
else
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
<epath>{$exp,$context}</epath>,
$gflwor/values
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
            "<root>{db:open('" || data($step/Str/@value) || "')}</root>"
   else
   if (name($step)="FnDoc") then 
            "<root>{doc('" || data($step/Str/@value) || "')}</root>"
   else
   if (name($step)="FnCollection") then 
            "<root>{collection('" || data($step/Str/@value) || "')}</root>"
   else
   if (name($step)="VarRef") then 
             let $varn := $step/Var/@name
             let $con := ($context/*[name/Var/@name=data($varn)])[last()]
             let $path := 
             $con/path/node()
             return
                
              serialize(<root>{$path}</root>, 
             map {'method': 'xml' }) || "/node()" 
                       
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
           then
           "not(" ||  string-join(for-each($step/*,
                            function($x){local:Path($x,$context,$static)}),"/")
           || ")"                 
           
                                                
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
              return "(" || $cond1 || " " || $step/@op  || " " || $cond2 || ")"            
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
  else local:fgroup(tail($items))
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


declare function local:printPath($epath,$static)
{  
   let $step := ($epath/*)[1]
   let $context := ($epath/*)[2]
   return
   if (name($step)="ContextValue") then <p>{"."}</p>
   else
   if (name($step)="Root") then <p>{"root()"}</p>
   else
   if (name($step)="DbOpen") then 
           <p>{ "db:open('",data($step/Str/@value),"')"}</p>
   else
   if (name($step)="FnDoc") then 
           <p>{ "doc('",data($step/Str/@value),"')"}</p>
   else
   if (name($step)="FnCollection") then 
           <p>{ "collection('",data($step/Str/@value),"')"}</p>
   else
   
   if (name($step)="VarRef") then 
             let $varn := $step/Var/@name
             let $con := ($context/*[name/Var/@name=data($varn)])[last()]
             let $path := 
             $con/path     
             return <p>{$path/node()}</p>
   else
   if (name($step)="CachedPath") 
          then <p>{fold-right($step/*,
(),
                 function($x,$y){local:printPath(<epath>{$x,$context}</epath>,$static)/node(),'/'[exists($y)], $y[exists($y)]})}</p>               
   else
   if (name($step)="IterPath") 
          then <p>{fold-right($step/*,
(),
                 function($x,$y){local:printPath(<epath>{$x,$context}</epath>,$static)/node(),'/'[exists($y)], $y[exists($y)]})}</p>      
   else   
   if (name($step)="Union") then
   if ($step/values) then
      <p>{ fold-right($step/values/partial/*,
                  (),
                 function($x,$y){local:printPath($x,$static)/node(),'|'[exists($y)], $y[exists($y)]}) }</p>
   else
       <p>{ 
                   fold-right($step/*,
                   (),
                 function($x,$y){local:printPath($x,$static)/node(),'|'[exists($y)], $y[exists($y)]})}</p>
   else
   if (name($step)="InterSect") then 
   if ($step/values) then
   
       <p>{ 
                   fold-right($step/values/partial/*,
                   (),
                 function($x,$y){local:printPath($x,$static)/node(),'intersect'[exists($y)], $y[exists($y)]})   
                   }</p>
                   
   else 
   <p>{ 
                   fold-right($step/*,
                   (),
                 function($x,$y){local:printPath($x,$static)/node(),'intersect'[exists($y)], $y[exists($y)]})}</p> 
   else
   if (name($step)="MixedPath")
                   then
  local:printPath(<epath><CachedPath>{$step/*}</CachedPath>{$context}</epath>,$static)                 
   else           
   if (name($step)="CachedFilter") 
          then 
          
     <p>{local:printPath(<epath>{head($step/*),$context}</epath>,$static)/node(),     '[',
     for-each(tail($step/*),
          function($x){local:printPath(<epath>{$x,$context}</epath>,$static)/node(),
      ']'})
     }</p>
   else
   if (name($step)="IterStep") then 
           <p>{$step/@axis || "::" || $step/@test,
           for-each($step/*,
     function($x){('[',local:printPath(<epath>{$x,$context}</epath>,$static)/node(),'',']')})          }</p>
   else 
   if (name($step)="IterPosStep") then 
         <p>{$step/@axis || "::" || $step/@test, '[',
                data($step/Int/@value), ']'     
              }</p>           
   else  
   if (name($step)="CachedStep") then 
           <p>{$step/@axis || "::" || $step/@test, 
            '[',for-each($step/*,
         function($x){(local:printPath(<epath>{$x,$context}</epath>,$static)/node()
         ,'')}),']'}</p>                      
                            
                            else           
   if (name($step)="FnNot") then
   if ($step/values)  
  
          then 
          <p>{"not(" , local:printPath($step/values/partial/*,$static)/node() , ")"
        }</p>
   else  <p>{"not(" , local:printPath(<epath>{$step/*,$context}</epath>,$static)/node() , ")"}</p> 
   else
   if (name($step)="Quantifier") 
          then 
          <p>{
          $step/@type, " ", $step/GFLWOR/For/Var/@name , " in " , 
          local:printPath(<epath>{$step/GFLWOR/For/*[2],$context}</epath>,$static)/node(),
           " satisfies " , local:printPath(<epath>{($step/GFLWOR)/*[2],
          <context>{
           $context/*
          union <var><name>{$step/GFLWOR/For/Var}</name><path
          >{local:exp($step/GFLWOR/For/*[2],$context,$static)/values/value/node()}</path>
          </var>}</context>}</epath>,$static)/node()}</p>                                 
   else
   
   
   if (substring(name($step),1,2)="Fn") then  
             if ($step/../../values) then
             let $args := 
             fold-left(
             for $exp in $step/* return            
             let $nodes := local:exp($exp,$context,$static)/values/value/node() 
             return
             if (empty($nodes)) then ["()"]
             else
             if (count($nodes)=1) then [$nodes]
             else         
             ["(",
             fold-left($nodes,(),
             function($x,$y){
                       if (empty($x)) then $y else ($x,",",$y)}
             ),
             ")"],   
             (),function($x,$y){if (empty($x)) then $y else ($x,",",$y)})
             return 
             <sf>{
             <fun>{substring-before(data($step/@name),"("),"(",$args,")"}</fun>
             /node()
             }</sf>         
             else  
             let $args := fold-left($step/*,(),function($x,$y){
             ([local:printPath(<epath>{$x,$context}</epath>,$static)/node()],',',$y)})
             return 
             <sf>{substring-before(data($step/@name),"(") , "(" , $args , ")" }</sf>
   else
   if (name($step)="StaticFuncCall")  then 
             if ($step/../../values) then
             let $args := 
             fold-left(
             for $exp in $step/* return 
             let $nodes := local:exp($exp,$context,$static)/values/value/node()
             return
             if (empty($nodes)) then ["()"]
             else
             if (count($nodes)=1) then [$nodes]
             else 
             ["(",fold-left($nodes,
             (),function($x,$y){if (empty($x)) then $y else ($x,",",$y)}),")"],   
             (),function($x,$y){if (empty($x)) then $y else ($x,",",$y)})
             return 
              <sf>
               <fun>{data($step/@name)}</fun><args>{$args}</args></sf>
             else 
             let $args := fold-left($step/*,(),function($x,$y){
             ([local:printPath(<epath>{$x,$context}</epath>,$static)/node()],",",$y)})
             return
             <sf>
               <fun>{data($step/@name)}</fun><args>{$args}</args></sf>
              
             
                      
   else 
   if (name($step)="CmpG") then 
              if ($step/values) then
              let $cond1 := local:printPath(($step/values/partial/*)[1],$static)/node()
              let $cond2 := local:printPath(($step/values/partial/*)[2],$static)/node()
              return
              <p>{
               "(" , $cond1 , " " , $step/@op , " " , $cond2 , ")"}
               </p> 
              else
              let $cond1 := local:printPath(<epath>{($step/*)[1],$context}</epath>,$static)/node()
              let $cond2 := local:printPath(<epath>{($step/*)[2],$context}</epath>,$static)/node()
              return 
              <p>{"(" , $cond1 , " " , data($step/@op) , " " , $cond2 , ")"}</p> 
   else
   if (name($step)="Arith") then
               if ($step/values) then
              let $cond1 := local:printPath(($step/values/partial/*)[1],$static)/node()
              let $cond2 := local:printPath(($step/values/partial/*)[2],$static)/node()
              return
              <p>{
               "(" , $cond1 , " " , data($step/@op) , " " , $cond2 , ")"}
               </p> 
              else
              let $cond1 := local:printPath(<epath>{($step/*)[1],$context}</epath>,$static)/node()
              let $cond2 := local:printPath(<epath>{($step/*)[2],$context}</epath>,$static)/node()
              return 
              <p>{"(" , $cond1 , " " , data($step/@op) , " " , $cond2 , ")"}</p>       
   else 
   if (name($step)="CmpN") then
               if ($step/values) then
              let $cond1 := local:printPath(($step/values/partial/*)[1],$static)/node()
              let $cond2 := local:printPath(($step/values/partial/*)[2],$static)/node()
              return
              <p>{
               "(" , $cond1 , " " , data($step/@op) , " " , $cond2 , ")"}
               </p> 
              else
              let $cond1 := local:printPath(<epath>{($step/*)[1],$context}</epath>,$static)/node()
              let $cond2 := local:printPath(<epath>{($step/*)[2],$context}</epath>,$static)/node()
              return 
              <p>{"(" , $cond1 , " " , data($step/@op) , " " , $cond2 , ")"}</p>             
   else 
   if (name($step)="And") then
                 if ($step/values) then
                 <p>{fold-right($step/values/partial/*,
                 (),
                 function($x,$y){(local:printPath($x,$static)/node()," and "[exists($y)], $y[exists($y)])})}</p>      
                 else 
                 <p>{fold-right($step/*,(),
                 function($x,$y){(local:printPath(<epath>{$x,$context}</epath>,$static)/node()," and "[exists($y)], $y[exists($y)])})}</p>
   else 
   if (name($step)="Or") then
            if ($step/values) then
                 <p>{fold-right($step/values/partial/*,
                (),
                 function($x,$y){(local:printPath($x,$static)/node()," or "[exists($y)], $y[exists($y)])})}</p>      
                 else 
                 <p>{fold-right($step/*,
                 (),
                 function($x,$y){(local:printPath(<epath>{$x,$context}</epath>,$static)/node()," or "[exists($y)], $y[exists($y)])})}</p>       
   else    
   if (name($step)="Empty") then <p>{"()"}</p>
   else
   if (name($step)="List") then
             if ($step/values) then
              <p>{"(" , 
               for-each($step/values/partial/*,
               function($x){(local:printPath($x,$static)/node(),",")}), ")"
             }</p> 
             else
             <p>{"(" , for-each($step/*,
             function($x){(local:printPath(<epath>{$x,$context}</epath>,$static)/node(),",")})   
             || ")" }</p> 
   else  
   if ($step/@type="xs:string") then <p>{ "'" , data($step/@value), "'"}</p>
   else
   if ($step/@type) then <p>{data($step/@value)}</p>
   else <p>{"()"}</p>
}; 

declare function local:treecalls($function,$string_query)
{
  let $query := xquery:parse($string_query)
  let $trace := 
  local:exps($query/QueryPlan/*[not(name(.)="StaticFunc")],
  <context></context>,
  $query/QueryPlan/*[name(.)="StaticFunc"])
  let $static := $query/QueryPlan/*[name(.)="StaticFunc"]
  return local:tcalls($function,<partial>{$trace/values}</partial>,
  $static)
};

declare function local:tcalls($function,$trace,$static)
{
  if ($trace/epath) 
  then
  let $epath := $trace/epath 
  let $values := if ($trace/../value/node()) then 
  fn:fold-right($trace/../value/node(),"",
  function($x,$y) { if ($y="") then $x else ($x, "," ,$y)})
  else data($trace/../value/@*)
  return
  if (not(name(($epath/*)[1])="Union") and
      not(name(($epath/*)[1])="InterSect") and
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
  let $context := $epath/context 
  
  let $sc := local:printPath($epath,$static)
  return
      if (not($sc="()")) then
      let $chs :=  $function(for-each($trace/values,
       function($x){local:tcalls($function,$x,
       $static)})) 
       
       return
      <question nc ="{count($chs)+sum($chs/@nc)}">
      {$sc}
      
      { 
      if (not ($values="")) then
      if (count($values)=1 and name($values)="root") then
      <values>{$values/node()}</values>
      else <values>{$values}</values>
      else <values>{$values}</values>
      }
      
       {
       $chs
       }
       
      </question>  
      else ()
  else 
    $function(for-each($epath/*,
    function($x){local:tcalls($function,$x,$static)}))
  else 
  if ($trace/partial) then
      $function(for-each($trace/partial,
     function($x){local:tcalls($function,$x,$static)}))
  else 
  if ($trace/values) then
    $function(for-each($trace/values/partial,
     function($x){local:tcalls($function,$x,$static)}))
  else ()
};


 

declare function local:naive_strategy($query)
{
  local:treecalls(function($x){$x},$query)
};

declare function local:first_small_strategy($query)
{
  local:treecalls(function($x){for $ch in $x order by count($ch/values/node()) 
ascending return $ch},$query)
};

declare function local:first_path_strategy($query)
{
  local:treecalls(function($x){($x[p],$x[not(p)])},$query)
};

declare function local:first_biggest_strategy($query)
{
  local:treecalls(function($x){for $ch in $x order by $ch/@nc descending return $ch  },$query)
};

declare function local:first_small_path_strategy($query)
{
  local:treecalls(function($x){(for $ch in $x where $ch[p] order by 
  count($ch/values/node()) ascending return $ch,for $ch in $x where $ch[not(p)] order by 
  count($ch/values/node()) ascending return $ch)},$query)
};

 

local:treecalls(function($x){$x},"
declare function local:min($t)
{
   let $prices := db:open('prices')
   let $p := $prices/prices/book[title = $t]/price
   return min($p)
};

declare function local:store($t,$p)
{
   let $prices := db:open('prices')
   let $p := $prices/prices/book[title = $t and price=$p]
   return $p/source
};


declare function local:min_price($t)
{
      let $min := local:min($t)
      return
      <minprice title='{$t}'>
         {local:store($t,$min)}
         <price>{local:min($t)}</price>
      </minprice>
};

declare function local:rate($rates)
{
 let $n := count($rates)
 return sum($rates)
};

declare function local:data($t)
{
 for $b in db:open('bstore')/bstore/book[title=$t]
 let $mr := local:rate($b/rate)
 where  $mr > 5
        return
        if ($b[editor]) then ($b/editor,$b/publisher,<mrate>{$mr}</mrate>)
        else
          ($b/author[position()<=1],$b/publisher,<mrate>{$mr}</mrate>)
};

<bib>
{

let $mylist := db:open('mylist')
for $t in distinct-values($mylist/mylist/title)
let $d := local:data($t)
where exists($d)
return
<book>{
$d,
local:min_price($t)
}
</book>
}
</bib>                                    
 "    
  )
 


 