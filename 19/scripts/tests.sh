#!/bin/bash

banner () {
cat << EOF
$(tput setaf 7)
╺┳╸┏━╸┏┓╻╺┳┓┏━╸┏━┓┏┳┓╻┏┓╻╺┳╸
 ┃ ┣╸ ┃┗┫ ┃┃┣╸ ┣┳┛┃┃┃┃┃┗┫ ┃
 ╹ ┗━╸╹ ╹╺┻┛┗━╸╹┗╸╹ ╹╹╹ ╹ ╹ $(tput setaf 1)
           ┏┓ ╻  ┏━┓┏━┓╺┳╸┏━╸┏━┓
           ┣┻┓┃  ┣━┫┗━┓ ┃ ┣╸ ┣┳┛
           ┗━┛┗━╸╹ ╹┗━┛ ╹ ┗━╸╹┗╸$(tput setaf 3)
     ___________________    . , ; .
    (___________________|~~~~~X.;' .
                          ' \`' ' \`
$(tput sgr0)
EOF
} >&2

run () {
	printf "\n🤞 $(tput setaf 2)run benchmark$(tput sgr0) $1, $2, $3, $4, $5\n\n" >&2
	printf  "$1,$2,$3,$4,$5,$6,"
	./runtest.sh $1 $2 $3 $4 $5 $6 | tail -n+2 | tr -s ' ' | cut -d ' ' -f 2-4 | tr '\n ' ',' | sed 's/.$//'
	printf "\n"
}

banner

printf "type,time,requests,concurrency,logging,mempool,avg(tx/s),stddev(tx/s),max(tx/s),avg(blocks/s),stddev(blocks/s),max(blocks/s)\n"

for mode in "internal"; do # "external"; do
	for logging in "yes"; do # "no"; do
		# Testing Performance Degradation at Low Load
  		run ${mode} 1 100 10 ${logging} 100000
 		run ${mode} 2 100 10 ${logging} 100000
 		run ${mode} 5 100 10 ${logging} 100000
 		run ${mode} 10 100 10 ${logging} 100000
 		run ${mode} 20 100 10 ${logging} 100000
 		run ${mode} 50 100 10 ${logging} 100000
 		run ${mode} 100 100 10 ${logging} 100000
 		run ${mode} 200 100 10 ${logging} 100000
 		run ${mode} 500 100 10 ${logging} 100000
 		run ${mode} 1000 100 10 ${logging} 100000
 		run ${mode} 2000 100 10 ${logging} 100000
 		run ${mode} 5000 100 10 ${logging} 100000
		# Testing Performance Degradation at High Load
		run ${mode} 1 10000 10 ${logging} 100000
 		run ${mode} 2 10000 10 ${logging} 100000
 		run ${mode} 5 10000 10 ${logging} 100000
 		run ${mode} 10 10000 10 ${logging} 100000
 		run ${mode} 20 10000 10 ${logging} 100000
 		run ${mode} 50 10000 10 ${logging} 100000
 		run ${mode} 100 10000 10 ${logging} 100000
 		run ${mode} 200 10000 10 ${logging} 100000
 		run ${mode} 500 10000 10 ${logging} 100000
 		run ${mode} 1000 10000 10 ${logging} 100000
 		run ${mode} 2000 10000 10 ${logging} 100000
 		run ${mode} 5000 10000 10 ${logging} 100000
		# Testing Performance Degradation Over Different Mempool Sizes
 		run ${mode} 1 1000 10 ${logging} 10
 		run ${mode} 2 1000 10 ${logging} 10
 		run ${mode} 5 1000 10 ${logging} 10
 		run ${mode} 10 1000 10 ${logging} 10
 		run ${mode} 20 1000 10 ${logging} 10
 		run ${mode} 50 1000 10 ${logging} 10
 		run ${mode} 100 1000 10 ${logging} 10
 		run ${mode} 200 1000 10 ${logging} 10
 		run ${mode} 500 1000 10 ${logging} 10
 		run ${mode} 1000 1000 10 ${logging} 10
 		run ${mode} 2000 1000 10 ${logging} 10
 		run ${mode} 5000 1000 10 ${logging} 10
   		run ${mode} 1 1000 10 ${logging} 1000
   		run ${mode} 2 1000 10 ${logging} 1000
   		run ${mode} 5 1000 10 ${logging} 1000
 		run ${mode} 10 1000 10 ${logging} 1000
 		run ${mode} 20 1000 10 ${logging} 1000
 		run ${mode} 50 1000 10 ${logging} 1000
 		run ${mode} 100 1000 10 ${logging} 1000
 		run ${mode} 200 1000 10 ${logging} 1000
 		run ${mode} 500 1000 10 ${logging} 1000
 		run ${mode} 1000 1000 10 ${logging} 1000
 		run ${mode} 2000 1000 10 ${logging} 1000
 		run ${mode} 5000 1000 10 ${logging} 1000
		run ${mode} 1 1000 10 ${logging} 100000
		run ${mode} 2 1000 10 ${logging} 100000
		run ${mode} 5 1000 10 ${logging} 100000
		run ${mode} 10 1000 10 ${logging} 100000
		run ${mode} 20 1000 10 ${logging} 100000
		run ${mode} 50 1000 10 ${logging} 100000
 		run ${mode} 100 1000 10 ${logging} 100000
 		run ${mode} 200 1000 10 ${logging} 100000
 		run ${mode} 500 1000 10 ${logging} 100000
 		run ${mode} 1000 1000 10 ${logging} 100000
 		run ${mode} 2000 1000 10 ${logging} 100000
 		run ${mode} 5000 1000 10 ${logging} 100000
		run ${mode} 1 1000 10 ${logging} 1000000
		run ${mode} 2 1000 10 ${logging} 1000000
		run ${mode} 5 1000 10 ${logging} 1000000
 		run ${mode} 10 1000 10 ${logging} 1000000
 		run ${mode} 20 1000 10 ${logging} 1000000
 		run ${mode} 50 1000 10 ${logging} 1000000
 		run ${mode} 100 1000 10 ${logging} 1000000
 		run ${mode} 200 1000 10 ${logging} 1000000
 		run ${mode} 500 1000 10 ${logging} 1000000
 		run ${mode} 1000 1000 10 ${logging} 1000000
 		run ${mode} 2000 1000 10 ${logging} 1000000
 		run ${mode} 5000 1000 10 ${logging} 1000000
	done
done
