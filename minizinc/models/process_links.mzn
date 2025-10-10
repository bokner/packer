% If processes p1 and p2 are required to communicate, they 
% have to be either on the same node, or on the connected nodes

constraint forall(p1, p2 in PROCESS where p1 < p2)(
    let {
        var NODE: p1_location = process_placement[p2];
        var NODE: p2_location = process_placement[p2];
  } in
    process_link[p1, p2] ->
    p1_location = p2_location
    \/ 
    topology[p1_location, p2_location]     
);