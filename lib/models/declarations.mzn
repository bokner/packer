int: num_nodes;
int: num_processes;

set of int: NODES = 1..num_nodes;
set of int: PROCESSES = 1..num_processes;

array[NODES] of int: node_memory;
array[PROCESSES] of int: process_memory;

array[NODES] of int: node_cpu;
array[PROCESSES] of int: process_cpu;

array[PROCESSES] of var NODES: process_placement;

% Nodes and their content (sets of processes on the node)
array[NODES] of var set of PROCESSES: processes_on_node;
