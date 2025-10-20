# Packer 

**Experiments with resource optimization for network cluster**

Given the description of the cluster and processes, find the distribution of the processes
across the cluster that satisfies the constraints imposed by resources available and processing demands. 

## Method

Constraint programming, bin packing with side constraints. 
[MiniZinc models](https://github.com/bokner/packer/tree/main/minizinc/models)

## Small example ([more examples](https://github.com/bokner/packer/tree/main/reports)) 

Below is an instance of a 4-node cluster configuration, with 8 processes we'd like to place on cluster nodes, such that
the demand for resources required by processes would be satisfied.

The node resources consist of
- available memory
- available load
- network bandwidth (in and out)
  
The process demand consists of 
- memory;
- load;
- volume of the payload sent over the network to peer processes;

Additionally:
- The topology of the cluster describes how the nodes are connected;
- The process communication requirements describe the connectivity between processes.

### Cluster description (nodes: 4, processes: 8 )

- #### Capacities per node

|node id| memory | load | out-bandwidth | in-bandwidth
|----| ---    | ---  | ------------- | ------------
|  1| 1930 | 966 | 268 | 392 
|  2| 2007 | 808 | 844 | 159 
|  3| 535 | 952 | 563 | 161 
|  4| 1010 | 986 | 515 | 667 


- #### Demand per process

|process id| memory|load|message volume|
|-------| ------|----|--------------
| 1 | 412 | 419 | 50 
| 2 | 460 | 141 | 102 
| 3 | 503 | 582 | 125 
| 4 | 446 | 258 | 121 
| 5 | 395 | 230 | 151 
| 6 | 272 | 105 | 190 
| 7 | 263 | 368 | 139 
| 8 | 376 | 361 | 169 


- #### Cluster topology

| | Node 1 | Node 2 | Node 3 | Node 4
|--|--|--|--|-- |
| Node 1| .| ✓| ✓| ✓
| Node 2| ✓| .| ✓| ✓
| Node 3| ✓| ✓| .| ✓
| Node 4| ✓| ✓| ✓| .


- #### Process communications

	- *process1* ⮕ *process3*
	- *process1* ⮕ *process8*
	- *process2* ⮕ *process7*



### The solution

The following placement of processes onto the cluster nodes satisfies the requirements
described above:

|node id| processes | memory used/avail. | load used/avail.| out-bandwidth used/avail.| in-bandwidth used/avail.
|----| --- | ----   | ---  | ------------- | ------------
|  1| {1,2,8} | 1248/1930 | 921/966 | 152/392 | 0/268 
|  2| {3,6} | 775/2007 | 687/808 | 0/159 | 50/844 
|  3| {7} | 263/535 | 368/952 | 0/161 | 102/563 
|  4| {4,5} | 841/1010 | 488/986 | 0/667 | 0/515 

