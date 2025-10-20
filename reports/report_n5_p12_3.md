## Cluster description (nodes: 7, processes: 12 )

- ### Capacities per node

|node id| memory | load | out-bandwidth | in-bandwidth
|----| ---    | ---  | ------------- | ------------
|  1| 1245 | 870 | 488 | 587 
|  2| 952 | 869 | 675 | 390 
|  3| 1045 | 774 | 815 | 559 
|  4| 1768 | 948 | 526 | 258 
|  5| 752 | 575 | 976 | 783 
|  6| 1745 | 588 | 377 | 476 
|  7| 1967 | 614 | 466 | 813 


- ### Demand per process

|process id| memory|load|message volume|
|-------| ------|----|--------------
| 1 | 462 | 399 | 166 
| 2 | 475 | 445 | 186 
| 3 | 337 | 366 | 130 
| 4 | 356 | 457 | 145 
| 5 | 338 | 376 | 160 
| 6 | 373 | 462 | 168 
| 7 | 369 | 597 | 70 
| 8 | 391 | 410 | 54 
| 9 | 273 | 442 | 111 
| 10 | 487 | 109 | 110 
| 11 | 412 | 169 | 60 
| 12 | 298 | 226 | 142 


- ### Cluster topology

| | Node 1 | Node 2 | Node 3 | Node 4 | Node 5 | Node 6 | Node 7
|--|--|--|--|--|--|--|-- |
| Node 1| .| ✓| ✓| ✗| ✓| ✓| ✓
| Node 2| ✓| .| ✓| ✗| ✓| ✓| ✓
| Node 3| ✓| ✓| .| ✓| ✓| ✗| ✓
| Node 4| ✗| ✗| ✓| .| ✓| ✓| ✓
| Node 5| ✓| ✓| ✓| ✓| .| ✓| ✓
| Node 6| ✓| ✓| ✗| ✓| ✓| .| ✗
| Node 7| ✓| ✓| ✓| ✓| ✓| ✗| .


- ### Process communications

	- *process1* ⮕ *process4*
	- *process1* ⮕ *process10*
	- *process6* ⮕ *process10*
	- *process6* ⮕ *process12*
	- *process8* ⮕ *process12*
	- *process9* ⮕ *process11*


## Feasible mapping

|node id| processes | memory used/avail. | load used/avail.| out-bandwidth used/avail.| in-bandwidth used/avail.
|----| --- | ----   | ---  | ------------- | ------------
|  1| {6,10,12} | 1158/1245 | 797/870 | 0/587 | 166/488 
|  2| {1,11} | 874/952 | 568/869 | 332/390 | 0/675 
|  3| {3,5} | 675/1045 | 742/774 | 0/559 | 0/815 
|  4| {8,9} | 664/1768 | 852/948 | 0/258 | 0/526 
|  5| {4} | 356/752 | 457/575 | 0/783 | 166/976 
|  6| {2} | 475/1745 | 445/588 | 0/476 | 0/377 
|  7| {7} | 369/1967 | 597/614 | 0/813 | 0/466 


