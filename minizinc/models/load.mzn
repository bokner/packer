% Load capacities and process load demand
array[NODE] of int: node_load;
array[PROCESS] of int: process_load;

constraint bin_packing_capa(node_load, process_placement, process_load);
