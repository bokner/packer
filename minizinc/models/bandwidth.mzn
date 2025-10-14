% Available memory and process memory requirements
array[NODE] of int: node_bandwidth_out;
array[NODE] of int: node_bandwidth_in;

array[PROCESS] of int: process_message_volume;

array[PROCESS] of var int: out_process_message_volume;

constraint bin_packing_var_weights(node_bandwidth_out, process_placement, 
    out_process_message_volume);

constraint forall(p in PROCESS)(
    out_process_message_volume[p] = 
    if remote_caller[p] = 1 then process_message_volume[p] else 0 endif

);