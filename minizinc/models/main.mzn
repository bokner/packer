include "declarations.mzn";
include "memory.mzn";
include "cpu.mzn";
include "process_links.mzn";

%% 'node -> set of processes' mapping
include "int_set_channel.mzn";
constraint int_set_channel(process_placement, processes_on_node);
