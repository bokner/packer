int: num_process_links;
set of int: PROCESS_LINK = 1..num_process_links;
array[PROCESS_LINK] of PROCESS: process_links_from;
array[PROCESS_LINK] of PROCESS: process_links_to;

array[PROCESS_LINK] of var 0..1: remote_call;


var set of array2set(process_links_from): remote_callers;
var set of array2set(process_links_to): remote_callees;



% If processes p1 and p2 are required to communicate, they 
% have to be either on the same node, or on the connected nodes

constraint forall(link in PROCESS_LINK)(
    let {
        var PROCESS: p_from = process_links_from[link];
        var PROCESS: p_to = process_links_to[link];
  
        var NODE: from_node = process_placement[p_from];
        var NODE: to_node = process_placement[p_to];
  } in
    if from_node = to_node then 
      remote_call[link] = 0 %/\ not (p_from in remote_callers) /\ not (p_to in remote_callees)   
    elseif topology[from_node,  to_node] then 
      remote_call[link] = 1 %/\ p_from in remote_callers /\ p_to in remote_callees
    else
      false  
    endif
  );
  
  constraint forall(link in PROCESS_LINK)(
    if remote_call[link] = 1 then 
      (process_links_from[link] in remote_callers)
      /\
      (process_links_to[link] in remote_callees)
    else
      not ((process_links_from[link] in remote_callers)
      \/
      (process_links_to[link] in remote_callees))
    endif  
  );
      
    