FROM openjdk:11
MAINTAINER "Madhu Aila"
COPY target/bootcamp*.jar .
CMD java -jar ./bootcamp*.jar
EXPOSE 8888
