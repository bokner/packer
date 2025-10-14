int: num_process_links;
set of int: PROCESS_LINK = 1..num_process_links;
array[PROCESS_LINK] of PROCESS: process_links_from;
array[PROCESS_LINK] of PROCESS: process_links_to;

% If processes p1 and p2 are required to communicate, they 
% have to be either on the same node, or on the connected nodes

constraint forall(link in PROCESS_LINK)(
    let {
        var PROCESS: p_from = process_links_from[link];
        var PROCESS: p_to = process_links_to[link];
  
        var NODE: from_node = process_placement[p_from];
        var NODE: to_node = process_placement[p_to];
  } in
      from_node == to_node \/
      
      (topology[from_node,  to_node] <-> (
        node_outgoing_links[from_node, p_from]  = 1 /\
        node_incoming_links[to_node, p_to]  = 1
        %p_from in node_outgoing_links[from_node] /\
        %p_to in node_incoming_links[to_node]
        )
        )
    
   
      );
      
      