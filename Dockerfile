FROM openjdk:17.0.1-jdk-oracle
WORKDIR /app
COPY spring-demo/*.jar /app.jar
CMD ["java", "-jar", "/app.jar"]
