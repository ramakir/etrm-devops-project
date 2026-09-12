# ==============================
# Stage 1: Build
# ==============================
FROM maven:3.9.16-eclipse-temurin-21 AS build

WORKDIR /build

COPY pom.xml .

COPY src ./src

RUN mvn clean package -DskipTests \
    -Duser.timezone=UTC

# ==============================
# Stage 2: Runtime
# ==============================
FROM eclipse-temurin:21-jre

WORKDIR /app

RUN useradd --create-home --shell /bin/bash appuser

COPY --from=build /build/target/trade-service-0.0.1-SNAPSHOT.jar app.jar

RUN chown appuser:appuser /app/app.jar

USER appuser

EXPOSE 8080

ENTRYPOINT ["java", "-Duser.timezone=UTC", "-jar", "app.jar"]
