#AStar Micro Services
##Build Status
[![Circle CI](https://circleci.com/gh/m1ckr1sk/ruby_projects.svg?style=svg)](https://circleci.com/gh/m1ckr1sk/ruby_projects)

##The Idea
The idea of the A* routing micro service is to have a set of services which send the routing service a job.  A job contains an ID, a start position, a target position and a map.  A job buffer will store these componenets until they are all ready and then forward them to the routing service.  The routing service will then post the resulting path to a display service.

![Alt text](https://github.com/m1ckr1sk/ruby_projects/blob/master/astar/images/ms.png "Optional title")

##Design Goals
Below are a set of design goals for each of the services:

1. Each service should have a heartbeat
2. Each service should broadcast any configuration when asked
3. Each service should be configurable
4. Each service should be 'plumbing' agnostic, i.e. not tied to a particular framework such as rabbitmq

##Running RabbitMQ using docker
Once you have docker installed run:

```bash
docker pull rabbitmq
```

This will pull the rabbitmq immage from docker hub.  To run the rabbitmq container for the basic application use:

```bash
docker run -d -p 5672 -e RABBITMQ_NODENAME=my-rabbit --name some-rabbit rabbitmq:3
```

##Running system using docker-compose

###Basic approach

[docker-compose](https://docs.docker.com/compose/) is a convenient way to spin up the entire system within docker containers. Once you have docker-compose installed, go to the main project directory (the one containing docker-compose.yml) and build the docker images by running:

```bash
docker-compose build
```

The system can then be started as follows:

```bash
docker-compose up
```

After each run, clear down the containers:

```bash
docker-compose rm -f
```

(If you forget to do this, subsequent runs will fail).

To send through additional job_detail_sender messages, open a new (boot2docker) terminal and run an individual jobdetailsender:

```bash
docker-compose run --no-deps jobdetailsender ruby ./job_detail_sender/job_detail_sender.rb amqp://rabbit:5672
```

Use docker exec to look inside a running container, e.g:

```bash
docker exec -it astar_routereceiver_1 /bin/bash
```
###Using the web interfaces

The system provides web interfaces for job input and output.

A REST interface on port 4567 is provided for job input. (If using boot2docker, replace "localhost" with the boot2docker ip).

```bash
# Set start point
curl -H "Content-Type: application/json" -X POST -d '{"message":"start_point","job_id":"42","value":"x,0,y,0"}' http://localhost:4567/message

# Set end point
curl -H "Content-Type: application/json" -X POST -d '{"message":"end_point", "job_id":"42","value":"x,9,y,9"}' http://localhost:4567/message

# Set map
curl -H "Content-Type: application/json" -X POST -d '{"message":"map", "job_id":"42","value":"0,0,0,0,0,0,0,0,0,0\n0,0,0,0,0,0,0,0,0,0\n0,0,0,0,0,0,0,0,0,0\n0,0,0,0,0,0,0,0,0,0\n0,0,0,0,0,0,0,0,0,0\n0,0,0,0,0,0,0,0,0,0\n0,0,0,0,0,0,0,0,0,0\n0,0,0,0,0,0,0,0,0,0\n0,0,0,0,0,0,0,0,0,0\n0,0,0,0,0,0,0,0,0,0\n"}' http://localhost:4567/message
```

To examine system output, point a browser to http://localhost:8000 (again adjust "localhost" if using boot2docker).
