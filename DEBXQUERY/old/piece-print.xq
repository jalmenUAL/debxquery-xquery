 {if (name(($epath/*)[1])="StaticFuncCall") then <sf>{$sc}</sf>
       else 
       if ($context/*[name/Var/@name=data(($epath/*/*)[1]/Var/@name)])
       then
       (<p>{
       local:showCall(<epath>{tail($epath/*/*),$context}</epath>,
       $static)
        }</p>,
       <on>{
       ($context/*[name/Var/@name=data(($epath/*/*)[1]/Var/@name)])
       [last()]/path/node()
       }</on>
       ) else <p>{$sc}</p>}