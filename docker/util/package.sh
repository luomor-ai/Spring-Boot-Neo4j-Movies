#!/bin/bash

# 请注意
# 本脚本的作用是把本项目编译的结果保存到deploy文件夹中
# 1. 把项目数据库文件拷贝到docker/db/init-sql
# 2. 编译friday-admin
# 3. 编译friday-all模块，然后拷贝到docker/movies

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
cd $DIR/../..
MOVIES_HOME=$PWD
echo "MOVIES_HOME $MOVIES_HOME"

# 复制数据库
# cat $MOVIES_HOME/movies-db/sql/friday_schema.sql > $MOVIES_HOME/docker/db/init-sql/movies.sql
# cat $MOVIES_HOME/movies-db/sql/friday_table.sql >> $MOVIES_HOME/docker/db/init-sql/movies.sql
# cat $MOVIES_HOME/movies-db/sql/friday_data.sql >> $MOVIES_HOME/docker/db/init-sql/movies.sql
# cat $MOVIES_HOME/movies-db/sql/friday_chinatower.sql >> $MOVIES_HOME/docker/db/init-sql/movies.sql

cd $MOVIES_HOME/movies-admin
# 安装阿里node镜像工具
npm install -g cnpm --registry=https://registry.npm.taobao.org
# 安装node项目依赖环境
cnpm install
cnpm run build:dep

cd $MOVIES_HOME
mvn clean package
cp -f $MOVIES_HOME/movies-all/target/movies-all-*-exec.jar $MOVIES_HOME/docker/movies/movies.jar