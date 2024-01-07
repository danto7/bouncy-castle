#!/bin/bash
(while :; do sleep 60; done;) &
pid="$!" 
trap "kill $pid" SIGINT
wait
echo received interrupt

