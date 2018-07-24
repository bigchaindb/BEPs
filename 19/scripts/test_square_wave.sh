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
	printf "\n🤞 $(tput setaf 2)run benchmark$(tput sgr0) $1, $2, $3 $4, $5, $6, $7\n\n" >&2
	printf "high_time,low_time,cycles,requests,concurrency,type,logging,\n"
	printf "$1,$2,$3,$4,$5,$6,$7,\n"
	printf "avg(tx/s),stddev(tx/s),max(tx/s),avg(blocks/s),stddev(blocks/s),max(blocks/s),\n"
	./runtest_square_wave.sh $1 $2 $3 $4 $5 $6 $7
	printf "\n"
}

banner

# Control: Reproducing our original result, to make sure everything still works
# 10s burst
run 10 1 1 1000 10 internal yes

# 30s burst
run 30 1 1 1000 10 internal yes

# 100s burst
run 100 1 1 1000 10 internal yes

# 500s burst
run 500 1 1 1000 10 internal yes

# Varying pause length, 10s burst
run 10 1 10 1000 10 internal yes
run 10 2 10 1000 10 internal yes
run 10 5 10 1000 10 internal yes
run 10 10 10 1000 10 internal yes
run 10 20 10 1000 10 internal yes

# Varying pause length, 100s burst
run 100 1 10 1000 10 internal yes
run 100 2 10 1000 10 internal yes
run 100 5 10 1000 10 internal yes
run 100 10 10 1000 10 internal yes
run 100 20 10 1000 10 internal yes

# Varying number of cycles
run 100 100 1 1000 10 internal yes
run 50 50 2 1000 10 internal yes
run 20 20 5 1000 10 internal yes
run 10 10 10 1000 10 internal yes
run 5 5 20 1000 10 internal yes

# Low Tx rate
run 2 2 10 100 10 internal yes
run 2 2 10 100 10 internal yes
run 2 2 10 100 10 internal yes
run 2 2 10 100 10 internal yes
run 2 2 10 100 10 internal yes
run 2 2 10 100 10 internal yes
run 2 2 10 100 10 internal yes
run 2 2 10 100 10 internal yes

# High Tx rate
run 10 10 10 10000 10 internal yes
run 10 10 10 10000 10 internal yes
run 10 10 10 10000 10 internal yes
run 10 10 10 10000 10 internal yes
run 10 10 10 10000 10 internal yes
run 10 10 10 10000 10 internal yes
run 10 10 10 10000 10 internal yes
run 10 10 10 10000 10 internal yes
