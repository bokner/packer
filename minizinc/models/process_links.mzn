int: num_process_links;
set of int: PROCESS_LINK = 1..num_process_links;
array[PROCESS_LINK] of PROCESS: process_links_from;
array[PROCESS_LINK] of PROCESS: process_links_to;

var set of PROCESS_LINK: remote_call_set;

%% By-node sets
%array[NODE, PROCESS_LINK] of var  bool: out_node_calls;
%array[NODE, PROCESS_LINK] of var  bool: in_node_calls;

array[NODE] of var set of PROCESS_LINK: out_node_calls;
array[NODE] of var set of PROCESS_LINK: in_node_calls;


constraint forall(link in PROCESS_LINK)(
     let {
         var PROCESS: p_from = process_links_from[link];
         var PROCESS: p_to = process_links_to[link];
  
         var NODE: from_node = process_placement[p_from];
         var NODE: to_node = process_placement[p_to];
   } in

  
  
  
  
  if (process_placement[p_from] != 
    process_placement[p_to]) /\ topology[from_node, to_node]
  then 
    link in remote_call_set /\
      (link in out_node_calls[from_node]  
      /\ link in in_node_calls[to_node])
   else
      not(link in remote_call_set) /\  
      not (link in out_node_calls[from_node] \/
      link in in_node_calls[to_node])
    endif
     
);

    