docker下，极速搭建spark集群(含hdfs集群)
搭建spark和hdfs的集群环境会消耗一些时间和精力，处于学习和开发阶段的同学关注的是spark应用的开发，他们希望整个环境能快速搭建好，从而尽快投入编码和调试，今天咱们就借助docker，极速搭建和体验spark和hdfs的集群环境；

实战环境信息
以下是本次实战涉及的版本号：

操作系统：CentOS7
hadoop：2.8
spark：2.3
docker：17.03.2-ce
docker-compose：1.23.2
极速搭建spark集群(含hdfs集群)
在CentOS7机器上建一个文件夹(例如test)，进入此文件夹；
在新建的文件夹内执行如下命令，即可搭建好spark和hdfs集群：
wget https://raw.githubusercontent.com/zq2599/blog_demos/master/sparkdockercomposefiles/docker-compose.yml \
&& wget https://raw.githubusercontent.com/zq2599/blog_demos/master/sparkdockercomposefiles/hadoop.env \
&& docker-compose up -d
没错，执行上面的命令就够了，只要静候命令执行完成，整个spark和hdfs集群环境就搭建好了；

查看环境
接下来检查一下整个环境是否正常，假设当前CentOS电脑的IP地址是192.168.1.101

用浏览器查看hdfs，如下图，可见有三个DataNode，地址是：http://192.168.1.101:50070


用浏览器查看spark，如下图，可见只有一个worker，地址是：http://192.168.1.101:8080



注意：spark的worker数量，以及worker内存的分配，都可以通过修改docker-compose.yml文件来调整；

准备实战数据
登录CentOS7电脑，在刚才执行命令的目录下，发现多了几个文件夹，如下所示，注意input_files和jars这两个，稍后会用到：
[root@hedy 009]# ls -al
总用量 8
drwxr-xr-x.  6 root root  105 2月  10 00:47 .
drwxr-xr-x. 10 root root   94 2月  10 00:47 ..
drwxr-xr-x.  4 root root   34 2月  10 00:47 conf
drwxr-xr-x.  2 root root    6 2月  10 00:47 data
-rw-r--r--.  1 root root 3046 2月  10 00:47 docker-compose.yml
-rw-r--r--.  1 root root 1189 2月  10 00:47 hadoop.env
drwxr-xr-x.  2 root root    6 2月  10 00:47 input_files
drwxr-xr-x.  2 root root    6 2月  10 00:47 jars
稍后的实战是经典的WordCount，也就是将指定文本中的单词出现次数统计出来，因此要先准备一个文本文件，我这里在网上找了个英文版的《乱世佳人》，文件名为GoneWiththeWind.txt，读者您请自行准备一个英文的txt文件，放入input_files文件夹中；
执行以下命令，即可在hdfs上创建/input文件夹，再将GoneWiththeWind.txt上传到此文件夹中：
docker exec namenode hdfs dfs -mkdir /input \
&& docker exec namenode hdfs dfs -put /input_files/GoneWiththeWind.txt /input
您可能会有疑问：txt文件在宿主机上，hdfs是docker容器，怎么能上传上去呢？您看过docker-compose.yml就会发现，宿主机的input_files目录已经挂载到namenode容器上了，所以上面的命令其实就是将容器内的文件上传到hdfs上去；
4. 用浏览器查看hdfs，如下图，可见txt文件已经上传到hdfs上：



spark_shell实战WordCount
在CentOS电脑的命令行输入以下命令，即可创建一个spark_shell：
docker exec -it master spark-shell --executor-memory 512M --total-executor-cores 2
如下所示，已经进入了spark_shell的对话模式：

[root@hedy ~]# docker exec -it master spark-shell --executor-memory 512M --total-executor-cores 2
2019-02-09 17:13:44 WARN  NativeCodeLoader:62 - Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
Setting default log level to "WARN".
To adjust logging level use sc.setLogLevel(newLevel). For SparkR, use setLogLevel(newLevel).
Spark context Web UI available at http://localhost:4040
Spark context available as 'sc' (master = spark://master:7077, app id = app-20190209171354-0000).
Spark session available as 'spark'.
Welcome to
____              __
/ __/__  ___ _____/ /__
_\ \/ _ \/ _ `/ __/  '_/
/___/ .__/\_,_/_/ /_/\_\   version 2.3.0
/_/

Using Scala version 2.11.8 (Java HotSpot(TM) 64-Bit Server VM, Java 1.8.0_131)
Type in expressions to have them evaluated.
Type :help for more information.

scala>
继续输入以下命令，也就是scala版的WordCount：
sc.textFile("hdfs://namenode:8020/input/GoneWiththeWind.txt").flatMap(line => line.split(" ")).map(word => (word, 1)).reduceByKey(_ + _).sortBy(_._2,false).take(10).foreach(println)
稍后控制台就会输出整个txt中出现次数最多的十个单词，以及对应的出现次数，如下：
scala> sc.textFile("hdfs://namenode:8020/input/GoneWiththeWind.txt").flatMap(line => line.split(" ")).map(word => (word, 1)).reduceByKey(_ + _).sortBy(_._2,false).take(10).foreach(println)
(the,18264)                                                                     
(and,14150)
(to,10020)
(of,8615)
(a,7571)
(her,7086)
(she,6217)
(was,5912)
(in,5751)
(had,4502)

scala>
用浏览器查看spark，如下图，可见任务正在执行中(因为shell还没有退出)，地址是：http://192.168.1.101:8080


输入Ctrl+c，退出shell，释放资源；
至此，spark_shell的实战就完成了，如果您是位java开发者，请接着往下看，咱们一起来实战java版spark应用的提交运行；

java实战WordCount
关于接下来的java版的WordCount，本文直接将jar下载下来用，而这个jar对应的源码以及开发过程，请参考文章《第一个spark应用开发详解(java版)》

在docker-compose.yml文件所在目录下，有个jars目录，进入此目录执行以下命令，就会将实战用到的jar文件下载到jars目录：
wget https://raw.githubusercontent.com/zq2599/blog_demos/master/sparkdockercomposefiles/sparkwordcount-1.0-SNAPSHOT.jar
执行以下命令，即可向spark提交java应用执行：
docker exec -it master spark-submit \
--class com.bolingcavalry.sparkwordcount.WordCount \
--executor-memory 512m \
--total-executor-cores 2 \
/root/jars/sparkwordcount-1.0-SNAPSHOT.jar \
namenode \
8020 \
GoneWiththeWind.txt
任务执行过程中，控制台会输出大量信息，其中有类似以下的内容，就是统计结果：
2019-02-09 17:30:32 INFO  WordCount:90 - top 10 word :
the	18264
and	14150
to	10020
of	8615
a	7571
her	7086
she	6217
was	5912
in	5751
had	4502
用浏览器查看hdfs，如下图，可见/output目录下创建了一个子文件夹20190209173023，这个文件夹下有两个文件，其中名为part-00000的就是本次实战输出的结果：


在hdfs的网页上看见/output目录下的子文件夹名称为20190209173023，因此执行以下命令，即可在控制台看到part-00000文件的内容：
docker exec namenode hdfs dfs -cat /output/20190209173023/part-00000
看到的part-00000的内容如下：

[root@hedy jars]# docker exec namenode hdfs dfs -cat /output/20190209173023/part-00000
(18264,the)
(14150,and)
(10020,to)
(8615,of)
(7571,a)
(7086,her)
(6217,she)
(5912,was)
(5751,in)
(4502,had)
以上就是极速搭建spark集群的实战，虽然操作简单，但是整个环境存在以下几处瑕疵：

只有一个worker，并行执行能力较差；
hdfs容器的磁盘空间是在docker的安装路径下分配的，遇到大文件时容器将系统空间占满；
spark master的4040端口没有开放，无法观察应用运行的情况；
worker的8080端口都没有开放， 无法观察worker的运行情况，也不能查看业务运行日志；
针对上述问题，我对docker-compose.yml做了改进，您可以执行以下命令快速搭建整个集群环境，要注意的是下面的命令会启动6个worker，比较消耗内存，如果您的电脑内存低于10G，很可能启动容器失败，此时建议您打开docker-compose.yml文件，对worker的配置做适当删减：

wget https://raw.githubusercontent.com/zq2599/blog_demos/master/files/sparkcluster/docker-compose.yml \
&& wget https://raw.githubusercontent.com/zq2599/blog_demos/master/sparkdockercomposefiles/hadoop.env \
&& docker-compose up -d
如果您想了解更多优化的细节，例如磁盘如何调整，master和worker开放的web端口如何访问，请参考《docker下的spark集群，调整参数榨干硬件》；

至此，docker下的spark集群的搭建和体验我们都快速完成了，希望此文能助您快速搭建环境，聚焦业务开发



使用docker-compose创建spark集群
下载docker镜像
sudo docker pull sequenceiq/spark:1.6.0
创建docker-compose.yml文件
创建一个目录，比如就叫 docker-spark，然后在其下创建docker-compose.yml文件，内容如下：

version: '2'

services:
master:
image: sequenceiq/spark:1.6.0
hostname: master
ports:
- "4040:4040"
- "8042:8042"
- "7077:7077"
- "8088:8088"
- "8080:8080"
restart: always
command: bash /usr/local/spark/sbin/start-master.sh && ping localhost > /dev/null

worker:
image: sequenceiq/spark:1.6.0
depends_on:
- master
expose:
- "8081"
restart: always
command: bash /usr/local/spark/sbin/start-slave.sh spark://master:7077 && ping localhost >/dev/null
其中包括一个master服务和一个worker服务。

创建并启动spark集群
sudo docker-compose up
集群启动后，我们可以查看一下集群状态

sudo docker-compose ps
Name                      Command               State                                                    Ports
----------------------------------------------------------------------
dockerspark_master_1   /etc/bootstrap.sh bash /us ...   Up      ...
dockerspark_worker_1   /etc/bootstrap.sh bash /us ...   Up      ...
默认我们创建的集群包括一个master节点和一个worker节点。我们可以通过下面的命令扩容或缩容集群。

sudo docker-compose scale worker=2
扩容后再次查看集群状态，此时集群变成了一个master节点和两个worker节点。

sudo docker-compose ps
Name                      Command               State                                                    Ports
------------------------------------------------------------------------
dockerspark_master_1   /etc/bootstrap.sh bash /us ...   Up      ...
dockerspark_worker_1   /etc/bootstrap.sh bash /us ...   Up      ...
dockerspark_worker_2   /etc/bootstrap.sh bash /us ...   Up      ...
此时也可以通过浏览器访问 http://ip:8080 来查看spark集群的状态。

运行spark作业
首先登录到spark集群的master节点

sudo docker exec -it <container_name> /bin/bash
然后使用spark-submit命令来提交作业

/usr/local/spark/bin/spark-submit --master spark://master:7077 --class org.apache.spark.examples.SparkPi /usr/local/spark/lib/spark-examples-1.6.0-hadoop2.6.0.jar 1000
停止spark集群
sudo docker-compose down



docker搭建Spark
1.docker的安装请看我的这篇文章:https://blog.csdn.net/qq_33517844/article/details/88146082

2.docker编排工具docker-compose安装

2.1 使用官网指导方式安装（不推荐）https://docs.docker.com/compose/install/

2.2使用国内镜像源安装(推荐)

curl -L https://get.daocloud.io/docker/compose/releases/download/1.22.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
测试是否安装成功

docker-compose --version
出现

docker-compose version 1.22.0, build f46880fe
就安装成功了

3.安装docker的spark镜像singularities/spark:2.2

docker-spark-2.1.0]# docker pull singularities/spark
查看镜像是否安装成功

docker image ls
创建docker-compose.yml

[root@localhost home]# mkdir singularitiesCR
[root@localhost home]# cd singularitiesCR
[root@localhost singularitiesCR]# touch docker-compose.yml
[root@localhost singularitiesCR]# vim docker-compose.yml
编辑

version: "2"

services:
master:
image: singularities/spark
command: start-spark master
hostname: master
ports:
- "6066:6066"
- "7070:7070"
- "8080:8080"
- "50070:50070"
worker:
image: singularities/spark
command: start-spark worker master
environment:
SPARK_WORKER_CORES: 1
SPARK_WORKER_MEMORY: 2g
links:
- master
在刚刚建立docker-compose.yml文件目录下面使用命令

[root@localhost singularitiesCR]# docker-compose up -d
Creating singularitiescr_master_1 ... done
Creating singularitiescr_worker_1 ... done
查看容器运行

[root@localhost singularitiesCR]# docker-compose ps
Name                      Command            State                   Ports
-----------------------------------------------------------------------------------------------------
singularitiescr_master_1   start-spark master          Up      10020/tcp, 13562/tcp, 14000/tcp,      
19888/tcp, 50010/tcp, 50020/tcp,      
0.0.0.0:50070->50070/tcp, 50075/tcp,  
50090/tcp, 50470/tcp, 50475/tcp,      
0.0.0.0:6066->6066/tcp,               
0.0.0.0:7070->7070/tcp, 7077/tcp,     
8020/tcp, 0.0.0.0:8080->8080/tcp,     
8081/tcp, 9000/tcp                    
singularitiescr_worker_1   start-spark worker master   Up      10020/tcp, 13562/tcp, 14000/tcp,      
19888/tcp, 50010/tcp, 50020/tcp,      
50070/tcp, 50075/tcp, 50090/tcp,      
50470/tcp, 50475/tcp, 6066/tcp,       
7077/tcp, 8020/tcp, 8080/tcp,         
8081/tcp, 9000/tcp                    
[root@localhost singularitiesCR]#
查看本机IP

[root@localhost singularitiesCR]# ifconfig
ens33: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
inet 192.168.1.133  netmask 255.255.255.0  broadcast 192.168.1.255
inet6 fe80::6841:cba4:a8ab:6691  prefixlen 64  scopeid 0x20<link>
ether 00:0c:29:53:c7:3e  txqueuelen 1000  (Ethernet)
RX packets 1027788  bytes 1507409925 (1.4 GiB)
RX errors 0  dropped 0  overruns 0  frame 0
TX packets 459275  bytes 36319898 (34.6 MiB)
TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
结果





停止容器

[root@localhost singularitiesCR]# docker-compose stop
删除容器

[root@localhost singularitiesCR]# docker-compose rm