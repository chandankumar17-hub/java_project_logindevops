# -------- BUILD STAGE --------
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app

COPY ./pom.xml .
RUN mvn dependency:go-offline

COPY ./src ./src
RUN mvn clean package -DskipTests

# -------- RUNTIME STAGE --------
FROM eclipse-temurin:17-jre
WORKDIR /app

COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080

# Run as non-root user (standard security best practice)
RUN useradd -m appuser
USER appuser

ENTRYPOINT ["java", "-jar", "app.jar"]
