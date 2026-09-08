FROM eclipse-temurin:17-jre

WORKDIR /app

COPY target/database_service_project-2.0.0.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
