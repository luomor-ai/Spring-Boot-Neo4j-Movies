#!/bin/bash

# 请注意
# 本脚本的作用是把本项目编译的结果保存到deploy文件夹中
# 1. 把项目数据库文件拷贝到docker/db/init-sql
# 2. 编译friday-admin
# 3. 编译friday-all模块，然后拷贝到docker/movies

FRIDAY_HOME=/home/movies/git/Spring-Boot-Neo4j-Movies
echo "FRIDAY_HOME $FRIDAY_HOME"
cd $FRIDAY_HOME

sudo -u movies git pull

# 复制数据库
# cat $FRIDAY_HOME/movies-db/sql/friday_schema.sql > $FRIDAY_HOME/docker/db/init-sql/movies.sql
# cat $FRIDAY_HOME/movies-db/sql/friday_table.sql >> $FRIDAY_HOME/docker/db/init-sql/movies.sql
# cat $FRIDAY_HOME/movies-db/sql/friday_data.sql >> $FRIDAY_HOME/docker/db/init-sql/movies.sql
# cat $FRIDAY_HOME/movies-db/sql/friday_chinatower.sql >> $FRIDAY_HOME/docker/db/init-sql/movies.sql

cd $FRIDAY_HOME/movies-admin
cnpm run build:dep

cd $FRIDAY_HOME/movies-vue
cnpm run build:dep

cd $FRIDAY_HOME
mvn clean package
cp -f $FRIDAY_HOME/movies-all/target/movies-all-*-exec.jar $FRIDAY_HOME/docker/movies/movies.jar