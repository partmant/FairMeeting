FROM openjdk:21-jdk

COPY target/fair_meetting-0.0.1-SNAPSHOT.jar app.jar

ENTRYPOINT ["java", "-jar", "app.jar"]

