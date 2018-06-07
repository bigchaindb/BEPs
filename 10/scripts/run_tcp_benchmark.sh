#!/bin/bash

export TMHOME=mktemp


init_tendermint () {
	rm -rf ${TMHOME}/*
	tendermint init 1>&2
}

run_benchmark () {
	while : ; do
		tm-bench -T $2 -r $3 -c $4 localhost:46657
	 	if [ $? -eq 0 ]; then
			break
		fi
		BENCH_PID=$!
		sleep 0.5
	done
}

run_internal () {
	tendermint node --proxy_app=kvstore --log_level="$1" 1>&2 &
	TM_PID=$!
}

run_external () {
	tendermint node --log_level="$1" 1>&2 &
	TM_PID=$!
	abci-cli kvstore 1>&2 &
	ABCI_PID=$!
}


if [ "$5" == "no" ];
then
	LOGGING=*:error
else
	LOGGING=main:info,state:info,*:error
fi

case "$1" in
	internal)
		init_tendermint
		run_internal ${LOGGING}
		run_benchmark $1 $2 $3 $4 ${LOGGING}
		kill ${TM_PID}
		;;

	external)
		init_tendermint
		run_external ${LOGGING}
		run_benchmark $1 $2 $3 $4 ${LOGGING}
		kill ${TM_PID} ${ABCI_PID}
		;;
	*)
		echo $"Usage: $0 {internal|external} <time> <requests> <concurrency> <logging>"
		exit 1
esac
