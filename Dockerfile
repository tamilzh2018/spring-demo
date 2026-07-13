FROM openjdk:17.0.1-jdk-oracle
WORKDIR /app
COPY target/demo-0.0.1-SNAPSHOT.jar /app.jar
CMD ["java", "-jar", "/app.jar"]
