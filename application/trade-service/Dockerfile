FROM eclipse-temurin:21-jre

WORKDIR /app

RUN rm -f /usr/bin/pebble \
    && useradd --create-home --shell /bin/bash appuser

COPY target/trade-service-0.0.1-SNAPSHOT.jar app.jar

RUN chown appuser:appuser /app/app.jar

USER appuser

EXPOSE 8080

ENTRYPOINT ["java", "-Duser.timezone=UTC", "-jar", "app.jar"]