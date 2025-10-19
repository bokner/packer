## Cluster description (nodes: 5, processes: 12 )

- ### Capacities per node

|node id| memory | load | out-bandwidth | in-bandwidth
|----| ---    | ---  | ------------- | ------------
|  1| 832 | 935 | 652 | 831 
|  2| 1284 | 626 | 813 | 760 
|  3| 1056 | 990 | 981 | 799 
|  4| 1958 | 969 | 346 | 945 
|  5| 927 | 960 | 496 | 180 


- ### Demand per process

|process id| memory|load|message volume|
|-------| ------|----|--------------
| 1 | 398 | 449 | 158 
| 2 | 313 | 242 | 65 
| 3 | 409 | 190 | 62 
| 4 | 386 | 452 | 164 
| 5 | 394 | 240 | 60 
| 6 | 286 | 230 | 188 
| 7 | 421 | 508 | 114 
| 8 | 462 | 185 | 166 
| 9 | 386 | 379 | 57 
| 10 | 295 | 246 | 171 
| 11 | 380 | 329 | 197 
| 12 | 470 | 133 | 128 


- ### Cluster topology

| | Node 1 | Node 2 | Node 3 | Node 4 | Node 5
|--|--|--|--|--|-- |
| Node 1| .| ✓| ✗| ✓| ✗
| Node 2| ✓| .| ✓| ✗| ✓
| Node 3| ✗| ✓| .| ✓| ✓
| Node 4| ✓| ✗| ✓| .| ✓
| Node 5| ✗| ✓| ✓| ✓| .


- ### Interprocess requirements

	- *process1* -> *process5*
	- *process2* -> *process6*
	- *process3* -> *process5*
	- *process4* -> *process5*
	- *process4* -> *process11*
	- *process5* -> *process7*
	- *process5* -> *process10*
	- *process6* -> *process12*
	- *process8* -> *process11*


## Feasible mapping

|node id| processes | memory used/avail. | load used/avail.| out-bandwidth used/avail.| in-bandwidth used/avail.
|----| --- | ----   | ---  | ------------- | ------------
|  1| {3,4} | 795/832 | 642/935 | 390/831 | 0/652 
|  2| {5,10} | 689/1284 | 486/626 | 60/760 | 384/813 
|  3| {2,7} | 734/1056 | 750/990 | 65/799 | 60/981 
|  4| {6,8,11,12} | 1598/1958 | 877/969 | 0/945 | 229/346 
|  5| {1,9} | 784/927 | 828/960 | 158/180 | 0/496 


