# sysbench-test

有的同学刚接触sysbench，不太懂得如何使用，也想不到将输出重定向到文件，为了避免这种情况，特创建本项目。

使用方法：

```bash
./build_sysbench.sh

# all 包括prepare、run、cleanup，也可单独指定某一步
./test.sh -uadmin -padmin -h192.168.0.247 -t 10 -T 5 -l /tmp/sysbench.log -s ./sysbench_install/share/sysbench/oltp_read_write.lua -c all 
```
