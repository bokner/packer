include "memory.mzn";
include "cpu.mzn";
include "declarations.mzn";

%% Node -> processes
include "int_set_channel.mzn";
constraint int_set_channel(process_placement, processes_on_node);
