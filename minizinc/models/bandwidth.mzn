%include "bin_packing_var_weights.mzn";

% Available memory and process memory requirements
array[NODE] of int: node_bandwidth_out;
array[NODE] of int: node_bandwidth_in;

array[PROCESS] of int: process_message_volume;

array[NODE] of var 0..max(node_bandwidth_out): node_outbound;
array[NODE] of var 0..max(node_bandwidth_in): node_inbound;

array[PROCESS_LINK] of var 0..max(process_message_volume): remote_message_volume = [remote_calls[c] * process_message_volume[process_links_from[c]] | c in PROCESS_LINK];

%var 0..sum(process_message_volume): total_remote_message_volume = sum(remote_message_volume);

%constraint sum(node_outbound) = sum(node_inbound); 

  %/\ 
  %sum(node_inbound) = total_remote_message_volume;


%% Outbound load
% constraint forall(node in NODE)(
%   node_outbound[node] = sum(c in links_from_node[node] where remote_calls[c])(
%     remote_message_volume[c]
%   ) 
% );

constraint forall (node in NODE) (
  node_outbound[node] = sum (c in PROCESS_LINK) (
  remote_message_volume[c] * (process_placement[process_links_from[c]] = node))
);

%constraint bin_packing_var_weights(node_bandwidth_out, out_link_placement, remote_message_volume);

constraint forall(node in NODE)(
  node_outbound[node]
  <= node_bandwidth_out[node]
);

% Inbound load
% constraint forall(node in NODE)(
%   node_inbound[node] = sum(c in links_to_node[node] where remote_calls[c])(
%     process_message_volume[process_links_from[c]]
%   ) 
% );

constraint forall (node in NODE) (
  node_inbound[node] = sum (c in PROCESS_LINK) (
  remote_message_volume[c] * (process_placement[process_links_to[c]] = node))
);


%constraint bin_packing_var_weights(node_bandwidth_in, in_link_placement, remote_message_volume);


constraint forall(node in NODE)(
  node_inbound[node]
  <= node_bandwidth_in[node]
);



