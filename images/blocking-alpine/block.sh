#!/bin/bash
(while :; do sleep 60; done;) &
pid="$!" 
trap "kill $pid" SIGINT SIGSTOP SIGQUIT SIGABRT
wait
echo received interrupt

