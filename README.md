# sysbench-test

This project was created to avoid beginners who don't know how to use sysbench or redirect output to a file.

instruction guide：

```bash
./build_sysbench.sh

# all 包括prepare、run、cleanup，也可单独指定某一步
./test.sh -uadmin -padmin -h192.168.0.247 -t 10 -T 5 -l /tmp/sysbench.log -s ./sysbench_install/share/sysbench/oltp_read_write.lua -c all 
```

This script can output the log to both terminal and logfile. Examples are as follows:

```prolog
[INFO] 2019-06-20 17:07:38 [ main:line:228 ] user=admin, passwd=admin, host=192.168.0.247, port=3306, time=10, threads=5, logfile=/tmp/sysbench.log, needresetlog=false, cmd=all, script=./sysbench_install/share/sysbench/oltp_read_write.lua
[INFO] 2019-06-20 17:07:38 [ prepare main:line:179 ] ===========prepare begin============
[INFO] 2019-06-20 17:07:38 [ prepare main:line:181 ] mysql -uadmin -padmin -h192.168.0.247 -e"drop database if exists testdb"
mysql: [Warning] Using a password on the command line interface can be insecure.
[INFO] 2019-06-20 17:07:38 [ prepare main:line:184 ] mysql -uadmin -padmin -h192.168.0.247 -e"create database testdb"
mysql: [Warning] Using a password on the command line interface can be insecure.
[INFO] 2019-06-20 17:07:38 [ prepare main:line:188 ] /home/ubuntu/test/sysbench-test/sysbench_install/bin/sysbench
sysbench 1.1.0-faaff4f (using bundled LuaJIT 2.1.0-beta3)

Initializing worker threads...

Creating table 'sbtest1'...
Inserting 10000 records into 'sbtest1'
Creating a secondary index on 'sbtest1'...
[INFO] 2019-06-20 17:07:39 [ prepare main:line:191 ] ===========prepare end============
[INFO] 2019-06-20 17:07:39 [ run main:line:195 ] ===========run begin============
[INFO] 2019-06-20 17:07:39 [ run main:line:198 ] /home/ubuntu/test/sysbench-test/sysbench_install/bin/sysbench
sysbench 1.1.0-faaff4f (using bundled LuaJIT 2.1.0-beta3)

Running the test with following options:
Number of threads: 5
Report intermediate results every 10 second(s)
Initializing random number generator from current time


Initializing worker threads...

Threads started!

[ 10s ] thds: 5 tps: 210.74 qps: 4263.72 (r/w/o: 2990.97/848.37/424.38) lat (ms,95%): 37.56 err/s: 2.40 reconn/s: 0.00
SQL statistics:
    queries performed:
        read:                            29918
        write:                           8489
        other:                           4250
        total:                           42657
    transactions:                        2113   (211.06 per sec.)
    queries:                             42657  (4260.95 per sec.)
    ignored errors:                      24     (2.40 per sec.)
    reconnects:                          0      (0.00 per sec.)

Throughput:
    events/s (eps):                      211.0648
    time elapsed:                        10.0111s
    total number of events:              2113

Latency (ms):
         min:                                   11.31
         avg:                                   23.67
         max:                                   92.24
         95th percentile:                       37.56
         sum:                                50023.56

Threads fairness:
    events (avg/stddev):           422.6000/4.08
    execution time (avg/stddev):   10.0047/0.00

[INFO] 2019-06-20 17:07:49 [ run main:line:201 ] ===========run end============
[INFO] 2019-06-20 17:07:49 [ cleanup main:line:205 ] ===========cleanup begin============
[INFO] 2019-06-20 17:07:49 [ cleanup main:line:208 ] /home/ubuntu/test/sysbench-test/sysbench_install/bin/sysbench
sysbench 1.1.0-faaff4f (using bundled LuaJIT 2.1.0-beta3)

Dropping table 'sbtest1'...
[INFO] 2019-06-20 17:07:49 [ cleanup main:line:211 ] ===========cleanup end============
```
