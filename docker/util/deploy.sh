#!/bin/bash

FRIDAY_HOME=/home/movies/git/Spring-Boot-Neo4j-Movies
echo "FRIDAY_HOME $FRIDAY_HOME"
cd $FRIDAY_HOME

sudo -u movies git pull

cd $FRIDAY_HOME/docker

# create user 'movies'@'%' identified by 'friday123456';
# grant all privileges on movies.* to 'movies'@'%';
# flush privileges;
# mysql -h127.0.0.1 -ufriday -p

sudo docker-compose down
sudo docker-compose build
sudo docker image prune -f
sudo docker-compose up -d
