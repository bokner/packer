int: num_process_links;
set of int: PROCESS_LINK = 1..num_process_links;
array[PROCESS_LINK] of PROCESS: process_links_from;
array[PROCESS_LINK] of PROCESS: process_links_to;

array[PROCESS_LINK] of var  bool: remote_calls;

constraint forall(c in PROCESS_LINK)(
  remote_calls[c] = 
  (process_placement[process_links_from[c]] != 
  process_placement[process_links_to[c]])
);

% array[PROCESS_LINK] of var  bool: remote_calls;

% % If processes p1 and p2 are required to communicate, they 
% % have to be either on the same node, or on the connected nodes.
% %
% % We also capture particulars for remote links,
% % to use in other parts of the model (bandwidth constraints).

% constraint forall(link in PROCESS_LINK)(
%     let {
%         var PROCESS: p_from = process_links_from[link];
%         var PROCESS: p_to = process_links_to[link];
  
%         var NODE: from_node = process_placement[p_from];
%         var NODE: to_node = process_placement[p_to];
%   } in
% %    remote_calls[link] = (from_node != to_node) /\ topology[from_node,  to_node]
%      if from_node = to_node then 
%        remote_calls[link] = false
%      else topology[from_node,  to_node] /\ 
%        remote_calls[link] = true
%      endif
%   );
                          
    