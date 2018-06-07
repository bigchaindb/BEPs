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
	printf "$1,$2,$3,$4,$5,"
	run_tcp_benchmark.sh $1 $2 $3 $4 $5 | tail -n+2 | tr -s ' ' | cut -d ' ' -f 2-4 | tr '\n ' ',' | sed 's/.$//'
	printf "\n"
}

banner

printf "type,time,requests,concurrency,logging,avg(tx/s),stddev(tx/s),max(tx/s),avg(blocks/s),stddev(blocks/s),max(blocks/s)\n"

for mode in "internal" "external"; do
	for logging in "yes" "no"; do
# Specify your parameters here, according to the following pattern. Use as many parameter sets as you like.
#		run ${mode} TIME_IN_SECONDS NUMBER_OF_REQUESTS_PER_SECOND NUMBER_OF_CONCURRENT_REQUESTS ${logging}
        run ${mode} 10 1000 1 ${logging}
	done
done
