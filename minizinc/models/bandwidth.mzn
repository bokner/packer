% Available memory and process memory requirements
array[NODE] of int: node_bandwidth_out;
array[NODE] of int: node_bandwidth_in;

array[PROCESS] of int: process_message_volume;

array[NODE] of var 0..max(node_bandwidth_out): total_outbound;
array[NODE] of var 0..max(node_bandwidth_in): total_inbound;


%% Outbound 
constraint forall(node in NODE)(
  total_outbound[node] = sum(c in PROCESS_LINK where remote_call[c] = 1 /\ process_links_from[c] in processes_on_node[node])(process_message_volume[process_links_from[c]]) 
);

constraint forall(node in NODE)(
  total_outbound[node]
  <= node_bandwidth_out[node]
);

% Inbound
constraint forall(node in NODE)(
  total_inbound[node] = sum(c in PROCESS_LINK where remote_call[c] = 1 /\ process_links_to[c] in processes_on_node[node])
  (process_message_volume[process_links_from[c]]) 

% Alternative (create `node_calls` as calls made from the nodes.
%total_inbound[node] = sum(c in PROCESS_LINK)(if in_node_calls[node, c] = 1 then process_message_volume[process_links_from[c]] else 0 endif) 
);

constraint forall(node in NODE)(
  total_inbound[node]
  <= node_bandwidth_out[node]
);

