#AStar Micro Services
##The Idea
The idea of the A* routing micro service is to have a set of services which send the routing service a job.  A job contains an ID, a start position, a target position and a map.  A job buffer will store these componenets until they are all ready and then forward them to the routing service.  The routing service will then post the resulting path to a display service.

![Alt text](https://github.com/m1ckr1sk/ruby_projects/blob/master/astar/images/ms.png "Optional title")