% Load capacities and process load demand
array[NODE] of int: node_cpu;
array[PROCESS] of int: process_load;

constraint bin_packing_capa(node_cpu, process_placement, process_load);
