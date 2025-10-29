int: num_process_links;
set of int: PROCESS_LINK = 1..num_process_links;
array[PROCESS_LINK] of PROCESS: process_links_from;
array[PROCESS_LINK] of PROCESS: process_links_to;

%var set of PROCESS_LINK: remote_call_set;
array[PROCESS_LINK] of var bool: remote_calls;

%% What nodes links are at
% array[PROCESS_LINK] of var NODE: out_link_placement;
% array[PROCESS_LINK] of var NODE: in_link_placement;



constraint forall(link in PROCESS_LINK)(
     let {
         var PROCESS: p_from = process_links_from[link];
         var PROCESS: p_to = process_links_to[link];
  
         var NODE: from_node = process_placement[p_from];
         var NODE: to_node = process_placement[p_to];
         var bool: colocated = (process_placement[p_from] = process_placement[p_to])

   } in

  (
   if colocated then
    remote_calls[link] = false
   elseif topology[from_node, to_node] then
    remote_calls[link] = true
    else
      false
    endif
  )  
);

