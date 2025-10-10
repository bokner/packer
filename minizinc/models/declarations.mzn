int: num_nodes;
int: num_processes;

set of int: NODE = 1..num_nodes;
set of int: PROCESS = 1..num_processes;

% Available memory and process memory requirements
array[NODE] of int: node_memory;
array[PROCESS] of int: process_memory;

% Load capacities and process load demand
array[NODE] of int: node_cpu;
array[PROCESS] of int: process_load;

% Node topology
array[NODE, NODE] of bool: topology;
% Process communication (what process pairs need to communicate)
% If process_link[p1, p2] = true, 
% then p1 and p2 have to be either on the same node, or on the connected nodes.
array[PROCESS, PROCESS] of bool: process_link;

% Decisions
array[PROCESS] of var NODE: process_placement;

% Nodes and their content (sets of processes on the node)
array[NODE] of var set of PROCESS: processes_on_node;
