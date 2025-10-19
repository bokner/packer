## Cluster description (nodes: 5, processes: 10 )

- ### Capacities per node

|node id| memory | load | out-bandwidth | in-bandwidth
|----| ---    | ---  | ------------- | ------------
|  1| 836 | 927 | 648 | 711 
|  2| 972 | 718 | 309 | 194 
|  3| 1927 | 948 | 610 | 511 
|  4| 1612 | 688 | 407 | 451 
|  5| 1993 | 919 | 276 | 394 


- ### Demand per process

|process id| memory|load|message volume|
|-------| ------|----|--------------
| 1 | 367 | 300 | 68 
| 2 | 477 | 480 | 174 
| 3 | 389 | 340 | 91 
| 4 | 365 | 249 | 75 
| 5 | 461 | 552 | 62 
| 6 | 309 | 562 | 190 
| 7 | 508 | 387 | 181 
| 8 | 447 | 347 | 192 
| 9 | 266 | 104 | 132 
| 10 | 300 | 489 | 135 


- ### Cluster topology

| | Node 1 | Node 2 | Node 3 | Node 4 | Node 5
|--|--|--|--|--|-- |
| Node 1| .| ✓| ✓| ✓| ✓
| Node 2| ✓| .| ✓| ✓| ✓
| Node 3| ✓| ✓| .| ✓| ✓
| Node 4| ✓| ✓| ✓| .| ✓
| Node 5| ✓| ✓| ✓| ✓| .


- ### Process communications

	- *process1* -> *process2*
	- *process2* -> *process9*
	- *process5* -> *process10*
	- *process6* -> *process7*
	- *process6* -> *process10*


## Feasible mapping

|node id| processes | memory used/avail. | load used/avail.| out-bandwidth used/avail.| in-bandwidth used/avail.
|----| --- | ----   | ---  | ------------- | ------------
|  1| {7,10} | 808/836 | 876/927 | 0/711 | 442/648 
|  2| {2,9} | 743/972 | 584/718 | 0/194 | 68/309 
|  3| {6,8} | 756/1927 | 909/948 | 380/511 | 0/610 
|  4| {5} | 461/1612 | 552/688 | 62/451 | 0/407 
|  5| {1,3,4} | 1121/1993 | 889/919 | 68/394 | 0/276 


