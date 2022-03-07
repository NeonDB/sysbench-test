#!/bin/bash

#########
dir=$(cd $(dirname $0);pwd)

############# config ##############
#HOST=10.96.3.4
HOST=127.0.0.1
PORT=5000
USER=test
PWD=testpassword
DB=sysbench
THREADS=32
TIME=300
REPORT_INTERVAL=1

SKIP_TRX=0

#LUA=${dir}/src/lua/oltp_read_write.lua
SCRIPT_DIR=${dir}/src/lua
TEST_CASE=oltp_read_write
TABLECOUNT=8
SIZE=10000000
#SIZE=5000000

###################

prepare() {
${dir}/sysbench ${LUA} \
    --time=${TIME} --threads=${THREADS} \
    --mysql-host=${HOST} --mysql-port=${PORT} --mysql-user=${USER} \
    --mysql-password=${PWD} --mysql-db=${DB} \
    --table-size=$SIZE --tables=$TABLECOUNT \
    prepare
    #--create-distribute-table=1 prepare
}

run() {
sh="${dir}/sysbench ${LUA} \
    --report-interval=${REPORT_INTERVAL} --time=${TIME} --threads=${THREADS} \
    --mysql-host=${HOST} --mysql-port=${PORT} --mysql-user=${USER} \
    --mysql-password=${PWD} --mysql-db=${DB} \
    --table-size=$SIZE --tables=$TABLECOUNT \
    run"
    #--create-distribute-table=0 run"
    #--skip-trx=${SKIP_TRX} --db-ps-mode=disable \
echo $sh
eval $sh

}

    #--debug=on --verbosity=5 \
cleanup() {
${dir}/sysbench ${LUA} \
    --time=${TIME} --threads=${THREADS} \
    --mysql-host=${HOST} --mysql-port=${PORT} --mysql-user=${USER} \
    --mysql-password=${PWD} --mysql-db=${DB} \
    --table-size=$SIZE --tables=$TABLECOUNT \
    cleanup
    #--create-distribute-table=0 cleanup
}

while getopts 'h:P:u:p:d:t:m:c:i:' OPT; do
    case $OPT in
        h)
            HOST="$OPTARG";;
        P)
            PORT="$OPTARG";;
        u)
            USER="$OPTARG";;
        p)
            PORT="$OPTARG";;
        d)
            DB="$OPTARG";;
        t)
            THREADS="$OPTARG";;
        m)
            TIME="$OPTARG";;
        c)
            TEST_CASE="$OPTARG";;
        i)
            REPORT_INTERVAL="$OPTARG";;
        ?)
            echo "Usage: `basename $0` [options] (prepare|run|cleanup)"
    esac
done

shift $(($OPTIND - 1))

LUA=${SCRIPT_DIR}/${TEST_CASE}.lua

COMMAND=$1
echo $COMMAND
$COMMAND

