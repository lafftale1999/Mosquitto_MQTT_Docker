#!/bin/bash
set -e

CERT_DIR=/mosquitto/certs
IP=$(hostname -I | awk '{print $1}')
CN="mqtt-broker"

echo "➡️ Använder lokal IP: $IP"

# Skapa SAN-config dynamiskt
cat > "$CERT_DIR/san.cnf" <<EOF
[req]
distinguished_name=req
prompt=no
req_extensions=req_ext

[req_distinguished_name]
CN=${CN}

[req_ext]
subjectAltName=@alt_names

[alt_names]
IP.1=${IP}
EOF

# Generera ny nyckel och certifikat
openssl genrsa -out "$CERT_DIR/broker.key" 2048
openssl req -new -key "$CERT_DIR/broker.key" -out "$CERT_DIR/broker.csr" -config "$CERT_DIR/san.cnf"
openssl x509 -req -in "$CERT_DIR/broker.csr" -CA "$CERT_DIR/ca.crt" -CAkey "$CERT_DIR/ca.key" -CAcreateserial \
  -out "$CERT_DIR/broker.crt" -days 365 -sha256 -extensions req_ext -extfile "$CERT_DIR/san.cnf"

echo "✅ Broker-certifikat skapades för IP $IP"