FROM eclipse-mosquitto:2.0

# Install open ssl in container
RUN apk add --no-cache openssl