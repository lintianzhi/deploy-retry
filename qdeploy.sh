#!/bin/bash


n1=($@)
n1pool=()
n2=()
log_file=".deploy_output"

qdeploy | grep "show this help message and exit" > /dev/null
while [ $? != 0 ]; do
    qdeploy
    sleep 1
    qdeploy | grep "show this help message and exit" > /dev/null
done

reArrange()
{
    all=()
    all=("${n1[@]}" "${n1pool[@]}")
    n1=()
    n1pool=()
    if [ ${#all[@]} > 10 ]; then
        n1=(${all[@]:0:10})
        n1pool=(${all[@]:10})
    else
        n1=(${all[@]})
        n1pool=()
    fi
}

while true; do
    reArrange;
    echo len: ${#n1[@]} list: ${n1[@]}
    echo remain: ${n1pool[@]}
    qdeploy ${n1[@]} | tee $log_file
# should code 1 exit?
    if [ $? == 130 ]; then
        echo receive ctrl+c, exit code 130;
        exit 130;
    fi
    for n in `cat $log_file|grep -E "Deploy successful"| cut -d "|" -f 2|cut -d ] -f 1`; do
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
        n1=(${ntmp[@]});
	n2=();
        continue;
    fi
    echo "success!"
    break
done;
