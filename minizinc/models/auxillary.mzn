%% 'node -> set of processes' mapping
include "int_set_channel.mzn";
% Nodes and their content (sets of processes on the node)
array[NODE] of var set of PROCESS: processes_on_node;

constraint int_set_channel(process_placement, processes_on_node);




