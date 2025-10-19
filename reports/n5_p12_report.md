## Cluster description

- ### Capacities per node

|node id| memory | load | out-bandwidth | in-bandwidth
|----| ---    | ---  | ------------- | ------------
|  1| 1914 | 953 | 258 | 821 
|  2| 1775 | 953 | 989 | 658 
|  3| 677 | 918 | 978 | 710 
|  4| 1880 | 896 | 745 | 958 
|  5| 1209 | 822 | 141 | 602 


- ### Demand per process

|process id| memory|load|message volume|
|-------| ------|----|--------------
| 1 | 266 | 490 | 129 
| 2 | 364 | 204 | 96 
| 3 | 422 | 184 | 102 
| 4 | 329 | 172 | 59 
| 5 | 453 | 286 | 68 
| 6 | 447 | 209 | 174 
| 7 | 273 | 519 | 51 
| 8 | 453 | 136 | 123 
| 9 | 405 | 314 | 134 
| 10 | 361 | 248 | 131 
| 11 | 427 | 593 | 78 
| 12 | 324 | 565 | 87 


- ### Cluster topology

| | Node 1 | Node 2 | Node 3 | Node 4 | Node 5
|--|--|--|--|--|-- |
| Node 1| .| ✓| ✗| ✓| ✓
| Node 2| ✓| .| ✓| ✓| ✓
| Node 3| ✗| ✓| .| ✓| ✗
| Node 4| ✓| ✓| ✓| .| ✗
| Node 5| ✓| ✓| ✗| ✗| .


- ### Interprocess requirements

	- *process3* -> *process6*
	- *process5* -> *process6*
	- *process6* -> *process10*
	- *process8* -> *process11*
	- *process8* -> *process12*
	- *process11* -> *process12*


## Feasible mapping

|node id| processes | memory used/avail. | load used/avail.| out-bandwidth used/avail.| in-bandwidth used/avail.
|----| --- | ----   | ---  | ------------- | ------------
|  1| {6,8,11} | 1327/1914 | 938/953 | 375/821 | 170/258 
|  2| {5,12} | 777/1775 | 851/953 | 68/658 | 201/989 
|  3| {4,7} | 602/677 | 691/918 | 0/710 | 0/978 
|  4| {1,10} | 627/1880 | 738/896 | 0/958 | 174/745 
|  5| {2,3,9} | 1191/1209 | 702/822 | 102/602 | 0/141 


