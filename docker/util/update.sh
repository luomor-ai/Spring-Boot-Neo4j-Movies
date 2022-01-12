#!/bin/bash

# 请注意
# 本脚本的作用是把本项目编译的结果保存到deploy文件夹中
# 1. 把项目数据库文件拷贝到docker/db/init-sql
# 2. 编译friday-admin
# 3. 编译friday-all模块，然后拷贝到docker/movies

MOVIES_HOME=/home/movies/git/Spring-Boot-Neo4j-Movies
echo "MOVIES_HOME $MOVIES_HOME"
cd $MOVIES_HOME

sudo -u movies git pull

# 复制数据库
# cat $MOVIES_HOME/movies-db/sql/friday_schema.sql > $MOVIES_HOME/docker/db/init-sql/movies.sql
# cat $MOVIES_HOME/movies-db/sql/friday_table.sql >> $MOVIES_HOME/docker/db/init-sql/movies.sql
# cat $MOVIES_HOME/movies-db/sql/friday_data.sql >> $MOVIES_HOME/docker/db/init-sql/movies.sql
# cat $MOVIES_HOME/movies-db/sql/friday_chinatower.sql >> $MOVIES_HOME/docker/db/init-sql/movies.sql

cd $MOVIES_HOME/movies-admin
cnpm run build:dep

cd $MOVIES_HOME/movies-vue
cnpm run build:dep

cd $MOVIES_HOME
mvn clean package
cp -f $MOVIES_HOME/movies-all/target/movies-all-*-exec.jar $MOVIES_HOME/docker/movies/movies.jar
cp -f $MOVIES_HOME/movies-all/target/movies-all-*-exec.jar $MOVIES_HOME/docker/movies-fe/movies.jar
cp -f $MOVIES_HOME/docker/movies/Dockerfile $MOVIES_HOME/docker/movies-fe/Dockerfile
cp -f $MOVIES_HOME/docker/movies/application.yml $MOVIES_HOME/docker/movies-fe/application.yml

cd $MOVIES_HOME/docker

sudo docker-compose build
sudo docker-compose up -d movies