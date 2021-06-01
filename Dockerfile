FROM openjdk:11
MAINTAINER "Madhu Aila"
COPY target/my-test-app*.jar .
CMD java -jar ./my-test-app*.jar
EXPOSE 8888
