% Available bandwidth (in and out) per node
array[NODE] of int: node_bandwidth_out;
array[NODE] of int: node_bandwidth_in;

%% Message volume per process
array[PROCESS] of int: process_message_volume;

array[NODE] of var 0..max(node_bandwidth_out): node_outbound;
array[NODE] of var 0..max(node_bandwidth_in): node_inbound;


%% Outbound load
constraint forall (node in NODE) (
  node_outbound[node] = sum (c in PROCESS_LINK) (
    let {
    var PROCESS: sender = process_links_from[c];
    var NODE: sender_node = process_placement[sender];
  } in
  process_message_volume[sender] * (remote_calls[c] /\ (sender_node = node)))
);


constraint forall(node in NODE)(
  node_outbound[node]
  <= node_bandwidth_out[node]
);

% Inbound load
constraint forall (node in NODE) (
  node_inbound[node] = sum (c in PROCESS_LINK) (
    let {
    var PROCESS: sender = process_links_from[c];
    var PROCESS: receiver = process_links_to[c];
    var NODE: receiver_node = process_placement[receiver];
  } in
  process_message_volume[sender] * (remote_calls[c] /\ (receiver_node = node)))
);



constraint forall(node in NODE)(
  node_inbound[node]
  <= node_bandwidth_in[node]
);

%% Redundant constraints
constraint sum(node_outbound) = sum(c in PROCESS_LINK)(remote_calls[c] * process_message_volume[process_links_from[c]]);


