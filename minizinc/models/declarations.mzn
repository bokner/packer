include "globals.mzn";

int: num_nodes;
int: num_processes;

set of int: NODE = 1..num_nodes;
set of int: PROCESS = 1..num_processes;

% Node topology
array[NODE, NODE] of bool: topology;

% Decisions
array[PROCESS] of var NODE: process_placement;
