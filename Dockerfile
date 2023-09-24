# Stage 1 (to create a "build" image, ~360MB)
FROM openjdk:17-alpine AS builder
# smoke test to verify if java is available
RUN java -version

COPY . /app/
WORKDIR /app/
RUN apk add maven \
    # smoke test to verify if maven is available
    && mvn --version
RUN mvn package

# Stage 2 (to create a downsized "container executable", ~180MB)
FROM openjdk:17-alpine
RUN apk add ca-certificates
WORKDIR /root/
COPY --from=builder /app/target/api-gateway.jar .

EXPOSE 8080
ENTRYPOINT ["java", "-Xmx512m", "-jar", "./api-gateway.jar"]