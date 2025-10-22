% Available memory and process memory requirements
array[NODE] of int: node_bandwidth_out;
array[NODE] of int: node_bandwidth_in;

array[PROCESS] of int: process_message_volume;

array[NODE] of var 0..max(node_bandwidth_out): node_outbound;

%% Outbound 
constraint forall(node in NODE)(
  node_outbound[node] = sum(c in out_node_calls[node])(
    process_message_volume[process_links_from[c]]
  ) 
);

constraint forall(node in NODE)(
  node_outbound[node]
  <= node_bandwidth_out[node]
);

% Inbound
array[NODE] of var 0..max(node_bandwidth_in): node_inbound;

constraint forall(node in NODE)(
  node_inbound[node] = sum(c in in_node_calls[node])(
    process_message_volume[process_links_from[c]]
  ) 
);

constraint forall(node in NODE)(
  node_inbound[node]
  <= node_bandwidth_in[node]
);

% constraint forall(node in NODE)(
%   node_inbound[node] = sum(c in remote_call_set where 
%   process_placement[process_links_to[c]] = node)(
%     process_message_volume[process_links_from[c]]
%   ) 
% );






