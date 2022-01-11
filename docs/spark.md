利用docker搭建spark测试集群
利用docker搭建spark测试集群
参考csdn等文章，利用docker安装spark。用虚拟化容器模拟出三个节点。

主要参考:

docker+centos7启动spark2.4.5+hadoop2.10.0集群 for macOS
blog.csdn.net/xiaoQL520/article/details/105406219

使用Docker搭建Hadoop集群(伪分布式与完全分布式) - coder、 - 博客园
www.cnblogs.com/rmxd/p/12051866.html


安装容器
$ # 在linux上预先安装docker，docker pull centos7镜像(8以上测试失败)
[root@VM-237-78-centos ~]$ docker pull centos:centos7

[root@VM-237-78-centos ~]$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
centos              centos7             7e6257c9f8d8        2 months ago        203MB

# 启动一个名字叫centos7的container
$ docker run --name centos7 -itd centos:centos7 /bin/bash

# 进入该容器
$ docker attach centos7
进入容器后，进行下列操作。

# 安装必要软件
$ yum install -y net-tools which openssh-clients openssh-server iproute.x86_64 wget passwd vim

# 更改root的密码
$ passwd

$ sed -i 's/UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config
$ mkdir /var/run/sshd
$ systemctl start sshd.service
# 上述启动的时候会报错，不用担心，正常exit即可。
$ exit
回到linux主机上，将之前的更改固化下来。生成新镜像，此处取名为my-ssh-centos7

[root@VM-237-78-centos ~]$  docker commit centos7 my-ssh-centos7

# 启动容器(--privileged=true 和后面的 /sbin/init 必须要有，以特权模式启动容器，否则无法使用systemctl启动服务)
[root@VM-237-78-centos ~]$ docker run -tid --privileged  --name test my-ssh-centos /usr/sbin/init

# 进入容器
[root@VM-237-78-centos ~]$ docker exec -it my-ssh-centos /bin/bash
再度进入容器后，执行下列操作，设置ssh免密登录

[root@834fed0e4a91] $ cd ~;ssh-keygen -t rsa -P '' -f ~/.ssh/id_dsa;cd .ssh;cat id_dsa.pub >> authorized_keys
安装jdk,spark,hadoop,scala
[root@834fed0e4a91 software]# mkdir /var/software
[root@834fed0e4a91 software]# cd /var/software
[root@834fed0e4a91 software]# wget https://mirrors.tuna.tsinghua.edu.cn/apache/hadoop/common/hadoop-2.10.0/hadoop-2.10.0.tar.gz
[root@834fed0e4a91 software]# wget https://mirrors.tuna.tsinghua.edu.cn/apache/spark/spark-2.4.7/spark-2.4.7-bin-without-hadoop.tgz
[root@834fed0e4a91 software]# wget https://downloads.lightbend.com/scala/2.12.3/scala-2.12.3.tgz
jdk 从oracle官网进行下载，复制相应下载链接.我是在本地下载后上传到linux上，再docker cp到容器里.在linux上命令如下

[root@VM-237-78-centos ]# docker cp jdk-8u261-linux-x64.tar.gz 834fed0e4a91:/var/software
# 安装java，scala，Hadoop，spark
[root@834fed0e4a91 software]# mkdir /usr/local/java/
[root@834fed0e4a91 software]# tar -zxvf jdk-8u261-linux-x64.tar.gz -C /usr/local/java/

[root@834fed0e4a91 software]# mkdir /usr/local/scala/
[root@834fed0e4a91 software]# tar -zxvf scala-2.12.3.tgz -C /usr/local/scala/

#创建安装目录
[root@834fed0e4a91 software]# mkdir /usr/local/hadoop/

[root@834fed0e4a91 software]# tar -zxvf hadoop-2.10.0.tar.gz  -C /usr/local/hadoop/  #解压文件至安装目录

[root@834fed0e4a91 software]# mkdir /usr/local/spark/
[root@834fed0e4a91 software]# tar -zxvf spark-2.4.7-bin-without-hadoop.tgz  -C /usr/local/spark/  #解压文件至安装目录


#设置环境变量
# ~/.bashrc中添加
# JAVA
export JAVA_HOME=/usr/local/java/jdk1.8.0_261
export JRE_HOME=$JAVA_HOME/jre
export PATH=$JAVA_HOME/bin:$PATH:$JRE_HOME/bin

# scala
export SCALA_HOME=/usr/local/scala/scala-2.12.3
export PATH=$PATH:$SCALA_HOME/bin

# hadoop
export HADOOP_HOME=/usr/local/hadoop/hadoop-2.10.0
export HADOOP_CONFIG_HOME=$HADOOP_HOME/etc/hadoop
export PATH=$PATH:$HADOOP_HOME/bin

export PATH=$PATH:$HADOOP_HOME/sbin
export SPARK_DIST_CLASSPATH=$(hadoop classpath)
#使环境变量生效
[root@834fed0e4a91 ~]# source ~/.bashrc
创建hadoop集群的相关目录

cd $HADOOP_HOME;mkdir tmp;mkdir namenode;mkdir datanode;cd $HADOOP_CONFIG_HOME/
修改core-site.xml

<configuration>
    <property>
            <name>hadoop.tmp.dir</name>
            <value>/usr/local/hadoop/hadoop-2.10.0/tmp</value>
            <description>A base for other temporary directories.</description>
    </property>

    <property>
            <name>fs.default.name</name>
            <value>hdfs://master:9000</value>
            <final>true</final>
            <description>The name of the default file system. 
            A URI whose scheme and authority determine the 
            FileSystem implementation. The uri's scheme 
            determines the config property (fs.SCHEME.impl) 
            naming the FileSystem implementation class. The 
            uri's authority is used to determine the host,
            port, etc. for a filesystem.        
            </description>
    </property>
</configuration>
配置hdfs-site.xml,设置副本数和NameNode、DataNode的目录路径

<configuration>
    <property>
        <name>dfs.replication</name>
        <value>2</value>
        <final>true</final>
        <description>Default block replication.
        The actual number of replications can be specified when the file is created.
        The default is used if replication is not specified in create time.
        </description>
    </property>

    <property>
        <name>dfs.namenode.name.dir</name>
        <value>/usr/local/hadoop/hadoop-2.10.0/namenode</value>
        <final>true</final>
    </property>

    <property>
        <name>dfs.datanode.data.dir</name>
        <value>/usr/local/hadoop/hadoop-2.10.0/datanode</value>
        <final>true</final>
    </property>
</configuration>
配置mapred-site.xml

<configuration>
    <property>
        <name>mapred.job.tracker</name>
        <value>master:9001</value>
        <description>The host and port that the MapReduce job tracker runs
        at.  If "local", then jobs are run in-process as a single map
        and reduce task.
        </description>
    </property>
</configuration>
配置yarn-site.xml

<configuration>
    <property>
        <name>yarn.nodemanager.vmem-check-enabled</name>
        <value>false</value>
        <description>Whether virtual memory limits will be enforced for containers</description>
    </property>
</configuration>
格式化datanode

hadoop namenode -format
安装spark

#~/spark.env.sh中添加
export SCALA_HOME=/usr/local/scala/scala-2.12.3
export JAVA_HOME=/usr/local/java/jdk1.8.0_231
export HADOOP_HOME=/usr/local/hadoop/hadoop-2.10.0
export HADOOP_CONFIG_DIR=$HADOOP_HOME/etc/hadoop
export SPARK_DIST_CLASSPATH=$(hadoop classpath)
SPARK_MASTER_IP=master
SPARK_LOCAL_DIR=/usr/local/spark/spark-2.4.5-bin-without-hadoop
SPACK_DRIVER_MEMORY=1G
#~/slaves中添加
slave01
slave02
保存镜像：

$ exit # 退出容器
[root@VM-237-78-centos ~]# docker commit -m "centos7 with spark 2.4.7 hadoop 2.10.0" test centos7:with-spark-hadoop sha256:314265b8d9c9327d8512c651fdd70bdc1051050f8b29d9f2bcc65ed58997d4d9
[root@VM-237-78-centos ~]# docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
centos7             with-spark-hadoop   314265b8d9c9        13 seconds ago      1.83GB
my-ssh-centos7      latest              e6a113f3d64d        About an hour ago   361MB
centos              v2                  066f7b749867        19 hours ago        2.32GB
centos              centos7             7e6257c9f8d8        2 months ago        203MB
centos              <none>              0d120b6ccaa8        2 months ago        215MB
配置集群
[root@VM-237-78-centos ~]# docker run -itd -P -p 50070:50070 -p 8088:8088 -p 8080:8080 --privileged --name master -h master --add-host slave01:172.17.0.7 --add-host slave02:172.17.0.8 centos7:with-spark-hadoop /usr/sbin/init
bfe96dd2f9d968d3c7e148f39c482224c7a847a91a567d4d630f912672b7bf9e
[root@VM-237-78-centos ~]# docker run -itd -P --privileged --name slave01 -h slave01 --add-host master:172.17.0.6 --add-host slave02:172.17.0.8 centos7:with-spark-hadoop /usr/sbin/init
c675ced497faabe484e3799a47b9a11d484c7f09a92017505f605b584848b8ac
[root@VM-237-78-centos ~]# docker run -itd -P --privileged --name slave02 -h slave02 --add-host master:172.17.0.6 --add-host slave01:172.17.0.7 centos7:with-spark-hadoop /usr/sbin/init
8e92b363fa95440d1235f231613a918b4570d36ffe915096074f8251402a0a32
进入master节点

# 启动hadoop
cd /usr/local/hadoop/hadoop-2.10.0/sbin/;sh start-all.sh
#查看启动项
[root@master software]# jps
3921 DataNode
4306 ResourceManager
6451 Jps
4435 NodeManager
5316 Master
3766 NameNode
5432 Worker
4124 SecondaryNameNode

#启动spark
cd /usr/local/spark/spark-2.4.7-bin-without-hadoop/sbin; sh start-all.sh
测试wordcount
[root@master var]# vim test.txt

hello hadoop
hello spark
hello flink

[root@master var]# hdfs dfs -put test.txt /


[root@master var]# hdfs dfs -ls /
Found 1 items
-rw-r--r--   2 root supergroup         37 2020-10-28 06:17 /test.txt

[root@master var]# cd /usr/local/hadoop/hadoop-2.10.0/share/hadoop/mapreduce/

[root@master mapreduce]# hadoop jar hadoop-mapreduce-examples-2.10.0.jar wordcount /test.txt /out

# 查看结果
[root@master mapreduce]# hdfs dfs -ls /out
Found 2 items
-rw-r--r--   2 root supergroup          0 2020-10-28 06:18 /out/_SUCCESS
-rw-r--r--   2 root supergroup         33 2020-10-28 06:18 /out/part-r-00000
[root@master mapreduce]# hdfs dfs -cat /out/part-r-00000
flink   1
hadoop  1
hello   3
spark   1
参考
OpenSSH fails to start in LXC container with error "Failed to seed from getrandom: Function not implemented"
bugzilla.redhat.com/show_bug.cgi?id=1812120
Docker Hub
hub.docker.com/_/centos?tab=tags


docker+centos7启动spark2.4.5+hadoop2.10.0集群 for macOS
blog.csdn.net/xiaoQL520/article/details/105406219

使用Docker搭建Hadoop集群(伪分布式与完全分布式) - coder、 - 博客园
www.cnblogs.com/rmxd/p/12051866.html
