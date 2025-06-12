#!/bin/sh
set -e

CERT_DIR=/mosquitto/certs
IP=${BROKER_IP:-$(ip route get 1 | awk '{print $7; exit}')}
CN="mqtt-broker"

echo "Using local IP: $IP"

cat > "$CERT_DIR/san.cnf" <<EOF
[req]
distinguished_name = req_distinguished_name
prompt = no
req_extensions = req_ext

[req_distinguished_name]
CN = ${CN}

[req_ext]
subjectAltName = @alt_names

[alt_names]
IP.1 = ${IP}
DNS.1 = localhost
EOF

openssl genrsa -out "$CERT_DIR/broker.key" 2048
openssl req -new -key "$CERT_DIR/broker.key" -out "$CERT_DIR/broker.csr" -config "$CERT_DIR/san.cnf"
openssl x509 -req -in "$CERT_DIR/broker.csr" -CA "$CERT_DIR/ca.crt" -CAkey "$CERT_DIR/ca.key" -CAcreateserial \
  -out "$CERT_DIR/broker.crt" -days 365 -sha256 -extensions req_ext -extfile "$CERT_DIR/san.cnf"

echo "✅ Broker-certifikat skapades för IP $IP"