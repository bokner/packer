include "bin_packing.mzn";

constraint bin_packing_capa(node_cpu, process_placement, process_load);
