% Available memory and process memory requirements
array[NODE] of int: node_bandwidth_out;
array[NODE] of int: node_bandwidth_in;

array[PROCESS] of int: process_message_volume;


constraint forall(node in NODE)(
  sum(p in processes_on_node[node] where p in remote_callers)(process_message_volume[p])
  <= node_bandwidth_out[node]
);

constraint forall(node in NODE)(
  sum(p in processes_on_node[node] where p in remote_callees)(process_message_volume[p])
  <= node_bandwidth_in[node]
);

