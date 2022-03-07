#!/bin/bash
path=`pwd`/sysbench_install/bin/sysbench
user=test
pass=passfortest
host=127.0.0.1
port=13306
db=sbtest

threads=32 # prepare 时会影响表数量
run_time=1200
report_interval=10
tables=64
table_size=1000 # 1000
#table_size=10000000 # 1000w
oltp_common=`pwd`/sysbench_install/share/sysbench/oltp_common.lua
script=`pwd`/sysbench_install/share/sysbench/select_random_ranges.lua

mysqlpath=/home/wslu/mysql/mysql80-install/bin

function print_usage() {
  echo "Usage: ./$0 [ prepare | run | cleanup ]"
}

function prepare() {
  echo "---- prepare start_time: `date +%s` ----"

  # prepare database
  $mysqlpath/mysql -u$user -p$pass -h$host -P$port -e"drop database if exists $db"
  $mysqlpath/mysql -u$user -p$pass -h$host -P$port -e"create database if not exists $db"

  # prepare tables
  $path --mysql-user=$user --mysql-password=$pass --mysql-host=$host --mysql-port=$port --mysql-db=$db \
  --threads=$threads ${oltp_common}  prepare

  echo "---- prepare stop_time: `date +%s` ----"
}

function run() {
  echo "---- run start_time: `date +%s` ----"

  $path --mysql-user=$user --mysql-password=$pass --mysql-host=$host --mysql-port=$port --mysql-db=$db \
  --threads=$threads --time=${run_time} --report-interval=${report_interval}  $script run

  echo "---- run stop_time: `date +%s` ----"
}

function cleanup() {
  echo "---- cleanup start_time: `date +%s` ----"

  $path --mysql-user=$user --mysql-password=$pass --mysql-host=$host --mysql-port=$port --mysql-db=$db \
  --threads=$threads ${oltp_common} cleanup

  # clean database
  $mysqlpath/mysql -u$user -p$pass -h$host -P$port -e"drop database if exists $db"

  echo "---- cleanup stop_time: `date +%s` ----"
}

if [ "x$1" == "x" ];then
  print_usage
  exit 1
fi

if [ "$1" == "prepare" ] ; then
  prepare
elif [ "$1" == "run" ] ; then
  run
elif [ "$1" == "cleanup" ] ; then
  cleanup
else
  print_usage
  exit 1
fi
