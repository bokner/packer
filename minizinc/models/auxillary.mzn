%% 'node -> set of processes' mapping
include "int_set_channel.mzn";
% Nodes and their content (sets of processes on the node)
array[NODE] of var set of PROCESS: processes_on_node;

constraint int_set_channel(process_placement, processes_on_node);

% Processes connected to node

array[NODE, PROCESS] of var 0..1:  node_incoming_links;
array[NODE, PROCESS] of var 0..1: node_outgoing_links;

%array[NODE] of var set of PROCESS: node_incoming_links;
%array[NODE] of var set of PROCESS: node_outgoing_links;




