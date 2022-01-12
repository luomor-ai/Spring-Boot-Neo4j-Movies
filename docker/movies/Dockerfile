FROM openjdk:8-jre
RUN fc-cache
RUN fc-list
RUN mkdir -p /home/robot/HanLP/data
RUN chmod 777 /home/robot/HanLP/data
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN echo 'Asia/Shanghai' > /etc/timezone
COPY application.properties application.properties
COPY Spring-Neo4j-Movie-exec.jar Spring-Neo4j-Movie-exec.jar
ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","Spring-Neo4j-Movie-exec.jar"]