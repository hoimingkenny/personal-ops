# Spring Boot image — requires `./mvnw -B package` (or `verify`) first.
# See docs/ci-cd.md

FROM eclipse-temurin:21-jre-alpine AS runtime

RUN addgroup -g 1000 app && adduser -u 1000 -G app -D app

WORKDIR /app

# spring-boot-maven-plugin repackaged executable JAR
ARG JAR_FILE=target/*-SNAPSHOT.jar
COPY ${JAR_FILE} app.jar

USER app
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
  CMD wget -qO- http://localhost:8080/actuator/health/liveness || exit 1

ENTRYPOINT ["java", "-jar", "app.jar"]
