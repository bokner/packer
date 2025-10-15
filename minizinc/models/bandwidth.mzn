% Available memory and process memory requirements
array[NODE] of int: node_bandwidth_out;
array[NODE] of int: node_bandwidth_in;

array[PROCESS] of int: process_message_volume;

array[PROCESS] of var 0..max(process_message_volume): out_process_message_volume;

constraint bin_packing_var_weights(node_bandwidth_out, process_placement, 
    out_process_message_volume);

constraint forall(link in PROCESS_LINK)(
    out_process_message_volume[process_links_from[link]] = 
    if remote_call[link] = 1 then process_message_volume[process_links_from[link]] else 0 endif

);
