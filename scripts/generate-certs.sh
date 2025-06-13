#!/bin/sh
set -e

CERT_DIR=/mosquitto/certs
IP=${BROKER_IP:-$(ip route get 1 | awk '{print $7; exit}')}
CN="mqtt-broker"

echo "Using local IP: $IP"

mkdir -p "$CERT_DIR"

# checks if you've already created a CA key and cert
if [ -f "$CERT_DIR/ca.key" ] && [ -f "$CERT_DIR/ca.crt" ]; then
  echo "Certificate and key already created."
else
  echo "Creating new cert and key..."
  openssl genrsa -out "$CERT_DIR/ca.key" 2048
  openssl req -x509 -new -nodes -key "$CERT_DIR/ca.key" -sha256 -days 365 \
    -out "$CERT_DIR/ca.crt" -subj "/CN=MyRootCA"
fi

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

echo "Broker certificate created for IP: $IP"

chown -R mosquitto:mosquitto "$CERT_DIR"
chmod 600 "$CERT_DIR"/*.key
chmod 644 "$CERT_DIR"/*.crt