#AS build
#FROM maven:3.6.1-jdk-8-slim
#RUN mkdir -p /workspace
#WORKDIR /workspace
#COPY pom.xml /workspace
#COPY src /workspace/src
#RUN mvn -f pom.xml clean package

FROM openjdk:8-alpine
COPY target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT  ["java","-jar","app.jar"]
