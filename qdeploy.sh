#!/bin/bash


n1=$@
n2=()

qdeploy | grep "show this help message and exit" > /dev/null
if [ $? != 0 ]; then
    qdeploy
    exit 1
fi



while true; do
    echo deploy: ${n1[@]}
    qdeploy ${n1[@]} > deploy_output
    for n in `cat deploy_output|grep -E "Deploy successful"|cut -d "|" -f 2|cut -d ] -f 1`; do
	echo $n, successful
	n2+=($n)
    done;
    ntmp=()
    echo success: ${n2[@]}
    for i in ${n1[@]}; do
        t=0
        for j in ${n2[@]}; do
            if [ $i == $j ]; then
                t=1
            fi
        done;
        if [ ${t} == 0 ]; then
            ntmp+=($i)
        fi
    done;
    echo fail: ${ntmp[@]}
    if [ ${#ntmp[@]} != 0 ]; then
	n1=${ntmp[@]};
	n2=();
	continue;
    fi
    echo "success!"
    break
done;
