#!/bin/bash

#################### public params ####################

USER=
PASSWD=
HOST=localhost
PORT=3306
TIME=
THREAD=
SCRIPT= # ./sysbench_install/share/sysbench/oltp_read_write.lua
CMD=all
LOGFILE=/tmp/sysbench_test.log
NEEDRESET=false

SYSBENCH_INSTALL_DIR=`pwd`/sysbench_install
SYSBENCH_PATH=$SYSBENCH_INSTALL_DIR/bin/sysbench
TEST_DB=testdb
#MYSQL_BIN=/usr/bin/mysql
MYSQL_BIN=mysql


#################### print usage ####################

function print_usage() {
    echo "Usage:"
    echo -e "\t-u|--user mysql-user\t\tmysql user"
    echo -e "\t-p|--password mysql-password\t\tmysql password"
    echo -e "\t-h|--host [mysql-host]\t\tmysql host, default: 127.0.0.1 or localhost"
    echo -e "\t-P|--port [mysql-port]\t\tmysql port, default: 3306"
    echo -e "\t-t|--time number-of-seconds\t\tsysbench max time"
    echo -e "\t-T|--thread thread-numbers\t\tsysbench thread nums"
    echo -e "\t-s|--script lua-path\t\tsysbench script path, for example ./sysbench_install/share/sysbench/oltp_read_write.lua"
    echo -e "\t-c|--cmd sysbench-command\t\tincludes: prepare | run | clean | all , default: all"
    echo -e "\t-l|--logfile [filename]\t\tlog file"
    echo -e "\t-r|--reset\t\tneed to clean log file"
}

#################### parse params ####################

ARGS=`getopt -o "u:p:h:P:t:T:s:l:rc:" -l "user:,password:,host:,port:,time:,thread:,script:,logfile:,reset,cmd:" -n "test.sh" -- "$@"`
eval set -- "${ARGS}"

function parse_params() {
    while true ; do
        case "${1}" in
            -u|--user)
            shift;
            if [[ -n "${1}" ]]; then
                USER=${1}
            fi
            ;;

            -p|--password)
            shift;
            if [[ -n "${1}" ]]; then
                PASSWD=${1}
            fi
            ;;

            -h|--host)
            shift;
            if [[ -n "${1}" ]]; then
                HOST=${1}
            fi
            ;;

            -P|--port)
            shift;
            if [[ -n "${1}" ]]; then
                PORT=${1}
            fi
            ;;

            -t|--time)
            shift;
            if [[ -n "${1}" ]]; then
                TIME=${1}
            fi
            ;;

            -T|--thread)
            shift;
            if [[ -n "${1}" ]]; then
                THREAD=${1}
            fi
            ;;

            -s|--script)
            shift;
            if [[ -n "${1}" ]]; then
                SCRIPT=${1}
            fi
            ;;

            -l|--logfile)
            shift;
            if [[ -n "${1}" ]]; then
                LOGFILE=${1}
            fi
            ;;

            -r|--reset)
            NEEDRESET=true
            ;;

            -c|--cmd)
            shift;
            if [[ -n "${1}" ]]; then
                CMD=${1}
            fi
            ;;

            --)
            shift;
            break;
            ;;
        esac
        shift
    done
}

function check_params() {
    if [ "$USER" == "" ] ; then
        echo "ERROR: --user is null"
    fi
    if [ "$PASSWD" == "" ] ; then
        echo "ERROR: --passwd is null"
    fi
    if [ "$TIME" == "" ] ; then
        echo "ERROR: --time is null"
    fi
    if [ "$THREAD" == "" ] ; then
        echo "ERROR: --thread is null"
    fi
    if [ "$SCRIPT" == "" ] ; then
        echo "ERROR: --script is null"
    fi
    if [ "$CMD" == "" ] ; then
        echo "ERROR: --cmd is null"
    fi
    if [ "$USER" == "" ] || [ "$PASSWD" == "" ] || [ "$TIME" == "" ] || [ "$THREAD" == "" ]  ||
        [ "$SCRIPT" == "" ] || [ "$CMD" == "" ] ; then
        print_usage
        exit 1
    fi
}

#################### log ####################

loglevel=0 #debug:0; info:1; warn:2; error:3

function log {
    local msg;local logtype
    logtype=$1
    msg=$2
    datetime=`date +'%F %H:%M:%S'`
    #使用内置变量$LINENO不行，不能显示调用那一行行号
    #logformat="[${logtype}]\t${datetime}\tfuncname:${FUNCNAME[@]} [line:$LINENO]\t${msg}"
    logformat="[${logtype}]\t${datetime}\tfuncname: ${FUNCNAME[@]/log/}\t[line:`caller 0 | awk '{print$1}'`]\t${msg}"
    #funname格式为log error main,如何取中间的error字段，去掉log好办，再去掉main,用echo awk? ${FUNCNAME[0]}不能满足多层函数嵌套
    {
    case $logtype in
        debug)
            [[ $loglevel -le 0 ]] && echo -e "\033[30m${logformat}\033[0m" ;;
        info)
            [[ $loglevel -le 1 ]] && echo -e "\033[32m${logformat}\033[0m" ;;
        warn)
            [[ $loglevel -le 2 ]] && echo -e "\033[33m${logformat}\033[0m" ;;
        error)
            [[ $loglevel -le 3 ]] && echo -e "\033[31m${logformat}\033[0m" ;;
    esac
    } | tee -a $LOGFILE
}

#################### sysbench cmd ####################

function prepare() {
log info "===========prepare begin============"

log info "${MYSQL_BIN} -u$USER -p$PASSWD -h$HOST -e\"drop database if exists $TEST_DB\""
${MYSQL_BIN} -u$USER -p$PASSWD -h$HOST -e"drop database if exists $TEST_DB" | tee -a $LOGFILE

log info "${MYSQL_BIN} -u$USER -p$PASSWD -h$HOST -e\"create database $TEST_DB\""
${MYSQL_BIN} -u$USER -p$PASSWD -h$HOST -e"create database $TEST_DB" | tee -a $LOGFILE

cmd="${SYSBENCH_PATH} $SCRIPT --mysql-db=$TEST_DB --mysql-user=$USER --mysql-password=$PASSWD --mysql-host=$HOST --mysql-port=$PORT --report-interval=10 --time=$TIME --threads=$THREAD prepare"
log info $cmd
${cmd} | tee -a $LOGFILE

log info "===========prepare end============"
}

function run() {
log info "===========run begin============"

cmd="${SYSBENCH_PATH} $SCRIPT --mysql-db=$TEST_DB --mysql-user=$USER --mysql-password=$PASSWD --mysql-host=$HOST --mysql-port=$PORT --report-interval=10 --time=$TIME --threads=$THREAD run"
log info $cmd
${cmd} | tee -a $LOGFILE

log info "===========run end============"
}

function cleanup() {
log info "===========cleanup begin============"

cmd="${SYSBENCH_PATH} $SCRIPT --mysql-db=$TEST_DB --mysql-user=$USER --mysql-password=$PASSWD --mysql-host=$HOST --mysql-port=$PORT --report-interval=10 --time=$TIME --threads=$THREAD cleanup"
log info $cmd
${cmd} | tee -a $LOGFILE

log info "===========cleanup end============"
}

#################### main ####################

if [ $# == 1 ] ; then
    print_usage
    exit 1
fi

if [ $NEEDRESET ] ; then
    echo > $LOGFILE
fi

parse_params $@
check_params

log info "user=$USER, passwd=$PASSWD, host=$HOST, port=$PORT, time=$TIME, threads=$THREAD, logfile=$LOGFILE, needresetlog=$NEEDRESET, cmd=$CMD, script=$SCRIPT"

if [ $CMD == "prepare" ] || [ $CMD == "all" ] ; then
    prepare
fi

if [ $CMD == "run" ] || [ $CMD == "all" ] ; then
    run
fi

if [ $CMD == "cleanup" ] || [ $CMD == "all" ] ; then
    cleanup
fi