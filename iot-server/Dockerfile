FROM maven:3.5.0-jdk-8-alpine AS builder
COPY settings.xml /root/.m2/
WORKDIR /usr/src/app
ADD . /usr/src/app
RUN ["mvn", "package"]

FROM java:8-jre-alpine
WORKDIR /usr/app
COPY --from=builder /usr/src/app/target/iot-server-1.0.0-jar-with-dependencies.jar .
CMD ["java", "-jar", "/usr/app/iot-server-1.0.0-jar-with-dependencies.jar"]
