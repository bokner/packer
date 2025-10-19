## Cluster description (nodes: 5, processes: 8)

- ### Capacities per node

|node id| memory | load | out-bandwidth | in-bandwidth
|----| ---    | ---  | ------------- | ------------
|  1| 1123 | 763 | 654 | 880 
|  2| 1409 | 679 | 379 | 532 
|  3| 1800 | 743 | 610 | 389 
|  4| 1011 | 694 | 289 | 593 
|  5| 1017 | 693 | 801 | 824 


- ### Demand per process

|process id| memory|load|message volume|
|-------| ------|----|--------------
| 1 | 442 | 489 | 141 
| 2 | 421 | 477 | 122 
| 3 | 439 | 557 | 127 
| 4 | 435 | 536 | 111 
| 5 | 364 | 169 | 179 
| 6 | 490 | 294 | 200 
| 7 | 451 | 238 | 59 
| 8 | 395 | 257 | 109 


- ### Cluster topology

| | Node 1 | Node 2 | Node 3 | Node 4 | Node 5
|--|--|--|--|--|-- |
| Node 1| .| ✓| ✓| ✓| ✓
| Node 2| ✓| .| ✗| ✓| ✓
| Node 3| ✓| ✗| .| ✓| ✓
| Node 4| ✓| ✓| ✓| .| ✓
| Node 5| ✓| ✓| ✓| ✓| .


- ### Interprocess requirements

	- *process3* -> *process5*
	- *process3* -> *process7*
	- *process3* -> *process8*
	- *process4* -> *process5*
	- *process6* -> *process7*


## Feasible mapping

|node id| processes | memory used/avail. | load used/avail.| out-bandwidth used/avail.| in-bandwidth used/avail.
|----| --- | ----   | ---  | ------------- | ------------
|  1| {4,5} | 799/1123 | 705/763 | 0/880 | 127/654 
|  2| {6,7} | 941/1409 | 532/679 | 0/532 | 127/379 
|  3| {2,8} | 816/1800 | 734/743 | 0/389 | 127/610 
|  4| {3} | 439/1011 | 557/694 | 381/593 | 0/289 
|  5| {1} | 442/1017 | 489/693 | 0/824 | 0/801 


