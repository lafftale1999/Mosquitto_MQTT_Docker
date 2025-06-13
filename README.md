# MOSQUITTO MQTT BROKER DOCKER SETUP
This is a lightweight implementation for a Mosquitto MQTT Broker placed in a Docker container.

## Features
* Automatically installs the Mosquitty Broker in the container.
* Generates all needed certificates and keys for the broker.
* Listens on three ports:
    * `1883` (for testing)
    * `8883` (for TLS two-way authentication)
    * `9001` (for websockets, not TLS yet).

## Dependencies

### Docker
Container tool needed to build the project.
[Docker Installation](<https://www.docker.com/products/docker-desktop/>)

### Means of communication
To be able to communicate with the broker you can either:

* Install Mosquitto MQTT
* Create a program using a MQTT library like `paho-mqtt`

## Build

### 1. Change to correct IP-address
Open `docker-compose.yaml` and change `BROKER_IP` to your current IP-address. This is important for generating correct broker certificates.

### 2. Connection settings
The following settings are configured in `/MOSQUITTO_MQTT_DOCKER/config/mosquitto.conf`.

#### PORT 1883
This port accepts all MQTT connections without any validations. 

`allow_anonymous true`

#### Port 8883
Requires client certificate and key for TLS. The client certificate must:

- Be signed by the same CA as the `broker.crt`
- Have a Common Name matching a user in `/MOSQUITTO_MQTT_DOCKER/config/pwfile`

If you are using DNS you will need to add it under `[alt_names]` in `generate_certs.sh`

`allow_anonymous false` `require_certificate true` `use_identity_as_username true`

#### Port 9001
This port requires the client to provide a username and password that matches a pair in `MOSQUITTO_MQTT_DOCKER/config/pwfile`. This particular Port is set for websocket connections like browsers.

`allow_anonymous false` `protocol websockets`

### 3. Build the project
Navigate to the root of this directory `/MOSQUITTO_MQTT_DOCKER` and run the following command:

`docker compose up --build -d`

#### To use Port 8883 or 9001
You will need to add some credentials to the pwfile. This is accomplished by following these instructions when the container is running:

1. Navigate to `/MOSQUITTO_MQTT_DOCKER/config/mosquitto.conf`
2. Change `CLIENT_NAME`and `CLIENT_PASSWORD`
3. If you want to generate client certificates and keys - set `GEN_CLIENT` to `1`

*The container will generate new broker and client credentials every time its run, but as long as the certificate's are signed by the same CA and the client certificates CN exists in `config/pwfile`, the connection will still work. As long a there is a ca.crt and ca.key in `config/certs` a new CA will not be generated.*

### 4. Test the connection
To test the connection you can open another terminal and use this command:

`mosquitto_sub -h localhost -p 1883 -t /test`

and then from another terminal do:

`mosquitto_pub -h localhost -p 1883 -t /test -m "Hello World"`

#### For port 8883
You need to add your certificates and keys. The command would then we

`mosquitto_sub -h localhost -p 8883 --cafile path/ca.crt --cert path/client.crt --key path/client.key -t /test`

#### For port 9001
You need to add your username and password.

`mosquitto_sub -h localhost -p 9001 -u username -P password123 -t /test`

### 5. Check logs
If you want to check the logs of how the build went you can use this command:

`docker logs mosquitto`

### 6. Close container
When you are finished you only need to enter:

`docker compose down -v`

## Author
My name is Carl and I'm studying IoT and embedded systems. If you have any questions regarding this project - feel free to reach out!