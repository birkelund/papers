#!/bin/bash

# run with `./bench.sh <num cores> <channel buffer size>
#
# set channel buffer size to 0 for unbuffered rendezvous-style channels
#

command -v go >/dev/null 2>&1 || { echo >&2 "go not found. please install. https://golang.org"; exit 1; }

# build the benchmark
go build lib.go

CORES=$1
BUFSIZE=$2

# baseline, multiplied by factors of 10
DRIVES=8
CHANGERS=1
CLIENTS=16

echo "running on `hostname`"

TIMEFORMAT=%R
for f in 1 10 100 1000 10000; do
	for i in `seq 1 5`; do
		drives=$(( $f * $DRIVES ))
		changers=$(( $f * $CHANGERS ))
		clients=$(( $f * $CLIENTS ))
		total=$(( $drives + $changers + $clients ))

		c="cores"
		[ $CORES -eq 1 ] && { c="core"; }

		echo -n "running $total processes on $CORES $c (channel bufsize=$BUFSIZE), (run $i): "
		time GOMAXPROCS=$CORES ./lib \
			-drives=$drives \
			-changers=$changers \
			-bufsize=$BUFSIZE \
			-clients=$clients 2> /dev/null
	done

	echo === DONE ===
	echo

done
