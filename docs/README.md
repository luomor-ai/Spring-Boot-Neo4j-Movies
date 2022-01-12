```shell
mvn package
java -jar target/Spring-Neo4j-Movie-exec.jar

sudo mkdir -p /home/robot/HanLP/data
sudo chmod -R 777 /home/robot

mkdir -p /home/robot/HanLP/data/question
sudo chmod -R 777 /home/robot

cp src/main/resources/statics/data（csv）/template/* /home/robot/HanLP/data/question/

cd git/docker-neo4j/mnt
cp -r ../../Spring-Boot-Neo4j-Movies/src/main/resources/statics/data（csv）/csv/* .

//导入节点 电影类型  == 注意类型转换
LOAD CSV WITH HEADERS  FROM "file:///genre.csv" AS line
MERGE (p:Genre{gid:toInteger(line.gid),name:line.gname})
	

//导入节点 演员信息	
LOAD CSV WITH HEADERS FROM 'file:///person.csv' AS line
MERGE (p:Person { pid:toInteger(line.pid),birth:line.birth,
death:line.death,name:line.name,
biography:line.biography,
birthplace:line.birthplace})


// 导入节点 电影信息
LOAD CSV WITH HEADERS  FROM "file:///movie.csv" AS line  
MERGE (p:Movie{mid:toInteger(line.mid),title:line.title,introduction:line.introduction,
rating:toFloat(line.rating),releasedate:line.releasedate})


// 导入关系 actedin  电影是谁参演的 1对多
LOAD CSV WITH HEADERS FROM "file:///person_to_movie.csv" AS line 
match (from:Person{pid:toInteger(line.pid)}),(to:Movie{mid:toInteger(line.mid)})  
merge (from)-[r:actedin{pid:toInteger(line.pid),mid:toInteger(line.mid)}]->(to)
	
//导入关系  电影是什么类型 == 1对多
LOAD CSV WITH HEADERS FROM "file:///movie_to_genre.csv" AS line
match (from:Movie{mid:toInteger(line.mid)}),(to:Genre{gid:toInteger(line.gid)})  
merge (from)-[r:is{mid:toInteger(line.mid),gid:toInteger(line.gid)}]->(to)


-- 问：章子怡都演了哪些电影？
match(n:Person)-[:actedin]->(m:Movie) where n.name='章子怡' return m.title

--  删除所有的节点及关系
MATCH (n)-[r]-(b)
DELETE n,r,b
```

```shell
sudo docker-compose build
sudo docker-compose down
sudo docker-compose up
sudo docker-compose up -d

docker-compose logs -f

docker volume ls
docker volume rm volume_name volume_name
docker volume prune
docker volume prune --filter "label!=keep"

local               docker_hadoop_datanode1
local               docker_hadoop_datanode2
local               docker_hadoop_datanode3
local               docker_hadoop_historyserver
local               docker_hadoop_namenode

docker volume rm docker_hadoop_datanode1 docker_hadoop_datanode2 docker_hadoop_datanode3 docker_hadoop_historyserver docker_hadoop_namenode

http://10.2.100.2:50070
http://10.2.100.2:8021/
http://10.2.100.2:8022/

http://localhost:50070
http://localhost:8021/
http://localhost:8022/

docker exec namenode hdfs dfs -mkdir /input \
&& docker exec namenode hdfs dfs -put /input_files/GoneWiththeWind.txt /input

docker exec -it master spark-shell --executor-memory 512M --total-executor-cores 2

sc.textFile("hdfs://namenode:8020/input/GoneWiththeWind.txt").flatMap(line => line.split(" ")).map(word => (word, 1)).reduceByKey(_ + _).sortBy(_._2,false).take(10).foreach(println)

wget https://raw.githubusercontent.com/zq2599/blog_demos/master/sparkdockercomposefiles/sparkwordcount-1.0-SNAPSHOT.jar
mv sparkwordcount-1.0-SNAPSHOT.jar jars/

docker exec -it master spark-submit \
--class com.bolingcavalry.sparkwordcount.WordCount \
--executor-memory 512m \
--total-executor-cores 2 \
/root/jars/sparkwordcount-1.0-SNAPSHOT.jar \
namenode \
8020 \
GoneWiththeWind.txt

docker exec namenode hdfs dfs -cat /output/20190209173023/part-00000
docker exec namenode hdfs dfs -cat /output/20220111150514/part-00000
(4,a)
(1,d)
(1,b)
(1,c)

wget https://raw.githubusercontent.com/zq2599/blog_demos/master/sparkdockercomposefiles/docker-compose.yml \
&& wget https://raw.githubusercontent.com/zq2599/blog_demos/master/sparkdockercomposefiles/hadoop.env \
&& docker-compose up -d

wget https://raw.githubusercontent.com/zq2599/blog_demos/master/files/sparkcluster/docker-compose.yml \
&& wget https://raw.githubusercontent.com/zq2599/blog_demos/master/sparkdockercomposefiles/hadoop.env \
&& docker-compose up -d

```

```shell
wget https://raw.githubusercontent.com/zq2599/blog_demos/master/sparkdockercomposefiles/docker-compose.yml \
&& wget https://raw.githubusercontent.com/zq2599/blog_demos/master/sparkdockercomposefiles/hadoop.env \
&& docker-compose up -d
```

```shell
docker pull centos:centos7
docker images
docker run --name centos7 -itd centos:centos7 /bin/bash
docker attach centos7
yum install -y net-tools which openssh-clients openssh-server iproute.x86_64 wget passwd vim

passwd
sed -i 's/UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config
mkdir /var/run/sshd
systemctl start sshd.service
上述启动的时候会报错，不用担心，正常exit即可。
exit

docker commit centos7 my-ssh-centos7
docker run -tid --privileged  --name test my-ssh-centos /usr/sbin/init
docker exec -it my-ssh-centos /bin/bash
cd ~;ssh-keygen -t rsa -P '' -f ~/.ssh/id_dsa;cd .ssh;cat id_dsa.pub >> authorized_keys

mkdir /var/software
cd /var/software
wget https://mirrors.tuna.tsinghua.edu.cn/apache/hadoop/common/hadoop-2.10.0/hadoop-2.10.0.tar.gz
wget https://mirrors.tuna.tsinghua.edu.cn/apache/spark/spark-2.4.7/spark-2.4.7-bin-without-hadoop.tgz
wget https://downloads.lightbend.com/scala/2.12.3/scala-2.12.3.tgz

docker cp jdk-8u261-linux-x64.tar.gz 834fed0e4a91:/var/software
mkdir /usr/local/java/
tar -zxvf jdk-8u261-linux-x64.tar.gz -C /usr/local/java/

mkdir /usr/local/scala/
tar -zxvf scala-2.12.3.tgz -C /usr/local/scala/

mkdir /usr/local/hadoop/
tar -zxvf hadoop-2.10.0.tar.gz  -C /usr/local/hadoop/  #解压文件至安装目录

mkdir /usr/local/spark/
tar -zxvf spark-2.4.7-bin-without-hadoop.tgz  -C /usr/local/spark/  #解压文件至安装目录

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

source ~/.bashrc

cd $HADOOP_HOME;mkdir tmp;mkdir namenode;mkdir datanode;cd $HADOOP_CONFIG_HOME/

core-site.xml
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

hdfs-site.xml
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

mapred-site.xml
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

yarn-site.xml
<configuration>
    <property>
        <name>yarn.nodemanager.vmem-check-enabled</name>
        <value>false</value>
        <description>Whether virtual memory limits will be enforced for containers</description>
    </property>
</configuration>

hadoop namenode -format

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

exit

docker commit -m "centos7 with spark 2.4.7 hadoop 2.10.0" test centos7:with-spark-hadoop sha256:314265b8d9c9327d8512c651fdd70bdc1051050f8b29d9f2bcc65ed58997d4d9
docker images

docker run -itd -P -p 50070:50070 -p 8088:8088 -p 8080:8080 --privileged --name master -h master --add-host slave01:172.17.0.7 --add-host slave02:172.17.0.8 centos7:with-spark-hadoop /usr/sbin/init
docker run -itd -P --privileged --name slave01 -h slave01 --add-host master:172.17.0.6 --add-host slave02:172.17.0.8 centos7:with-spark-hadoop /usr/sbin/init
docker run -itd -P --privileged --name slave02 -h slave02 --add-host master:172.17.0.6 --add-host slave01:172.17.0.7 centos7:with-spark-hadoop /usr/sbin/init

# 启动hadoop
cd /usr/local/hadoop/hadoop-2.10.0/sbin/;sh start-all.sh 

jps

#启动spark
cd /usr/local/spark/spark-2.4.7-bin-without-hadoop/sbin; sh start-all.sh

vim test.txt
hdfs dfs -put test.txt /
hdfs dfs -ls /
cd /usr/local/hadoop/hadoop-2.10.0/share/hadoop/mapreduce/

hadoop jar hadoop-mapreduce-examples-2.10.0.jar wordcount /test.txt /out
hdfs dfs -ls /out
hdfs dfs -cat /out/part-r-00000
```

```
docker spark
docker-compose spark
neo4j 导入csv
neo4j Couldn't load the external resource
```

```
docker search spark
NAME                               DESCRIPTION                                     STARS     OFFICIAL   AUTOMATED
sequenceiq/spark                   An easy way to try Spark                        453                  [OK]
gettyimages/spark                  A debian:jessie based Spark container           131                  [OK]
mesosphere/spark                   DCOS Spark                                      112
singularities/spark                Apache Spark                                    62                   [OK]
bde2020/spark-master               Apache Spark master for a standalone cluster    49                   [OK]
bde2020/spark-worker               Apache Spark worker for a standalone cluster    27                   [OK]
bde2020/spark-base                 Apache Spark base image                         21                   [OK]
shopkeep/spark                     Docker container with Spark, Scala, SBT, and…   9                    [OK]
bde2020/spark-submit               Apache Spark submit for a standalone cluster    8                    [OK]
gurvin/spark-jupyter-notebook      Jupyter Notebook to be used with Spark in Ku…   6                    [OK]
sparkserver/spark-server           The spark-server is a Node.js REST interface…   4                    [OK]
gradiant/spark                     Spark project                                   3                    [OK]
sparkpos/docker-nginx-php          sparkpos nginx php                              1                    [OK]
adobeapiplatform/spark             Spark executor images                           1
jaegertracing/spark-dependencies   Spark job for dependency links                  0                    [OK]
webgames/spark                     spark                                           0                    [OK]
amorphic/sparkcc-web               SparkCC Website                                 0
telefonica/spark-py-submit         This image contains the spark-submit binary,…   0
amorphic/sparkcc-hq                SparkCC HQ                                      0
duli/spark-mesos                   The docker image for spark jobs to run on a …   0
telefonica/spark-submit            This image contains the spark-submit binary,…   0
telefonica/spark-py                This image contains the Spark-py binaries, c…   0
mesosphere/spark-dev               spark testing                                   0
quidops/spark-cloud                Spark image including hadoop-cloud libs         0
jeffharwell/spark                  Spark docker container - upgrade for gcr.io/…   0                    [OK]
```