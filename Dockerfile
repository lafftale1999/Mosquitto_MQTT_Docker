FROM eclipse-mosquitto:2.0

# Install open ssl in container
RUN apk add --no-cache openssl

COPY scripts/generate-certs.sh /mosquitto/scripts/generate-certs.sh
RUN chmod +x /mosquitto/scripts/generate-certs.sh