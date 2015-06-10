#!/bin/bash
    
job_id=`date +"%FT%T"`

curl -H "Content-Type: application/json" -X POST -d '{"message":"start_point","job_id":"'$job_id'","value":"x,0,y,0"}' http://localhost:4567/message

curl -H "Content-Type: application/json" -X POST -d '{"message":"end_point", "job_id":"'$job_id'","value":"x,9,y,9"}' http://localhost:4567/message

curl -H "Content-Type: application/json" -X POST -d '{"message":"map", "job_id":"'$job_id'","value":"0,0,0,0,0,0,0,0,0,0\n0,0,0,0,0,0,0,0,0,0\n0,0,0,0,0,0,0,0,0,0\n0,0,0,0,0,0,0,0,0,0\n0,0,0,0,0,0,0,0,0,0\n0,0,0,0,0,0,0,0,0,0\n0,0,0,0,0,0,0,0,0,0\n0,0,0,0,0,0,0,0,0,0\n0,0,0,0,0,0,0,0,0,0\n0,0,0,0,0,0,0,0,0,0\n"}' http://localhost:4567/message

