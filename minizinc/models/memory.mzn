include "bin_packing.mzn";

% Available memory and process memory requirements
array[NODE] of int: node_memory;
array[PROCESS] of int: process_memory;

constraint bin_packing_capa(node_memory, process_placement, process_memory);

