FROM eclipse-mosquitto:2.0

RUN apt-get update && apt-get install -y openssl && rm -rf /var/lib/apt/lists/*

COPY certs/generate-broker-cert.sh /generate-broker-cert.sh
RUN chmod +x /generate-broker-cert.sh

ENTRYPOINT ["/bin/sh", "-c", "/generate-broker-cert.sh && mosquitto -c /mosquitto/config/mosquitto.conf"]