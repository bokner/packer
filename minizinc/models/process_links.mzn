% If processes p1 and p2 are required to communicate, they 
% have to be either on the same node, or on the connected nodes

constraint forall(link in PROCESS_LINK)(
    let {
        var NODE: p1_location = process_placement[process_links_from[link]];
        var NODE: p2_location = process_placement[process_links_to[link]];
  } in
      p1_location == p2_location \/
      topology[p1_location, p2_location]
      );
      
      