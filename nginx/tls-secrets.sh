#!/bin/sh

if [ ! -f dhparam.pem ]; then
    openssl dhparam -out dhparam.pem 2048
fi

kubectl -n jans create secret generic tls-dhparam --from-file=dhparam.pem

if [ ! -f ingress.crt ]; then
    kubectl -n jans get secret jans -o json \
    | grep '"ssl_cert":' \
    | awk -F '"' '{print $4}' \
    | base64 --decode > ingress.crt
fi

if [ ! -f ingress.key ]; then
    kubectl -n jans get secret jans -o json \
    | grep '"ssl_key":' \
    | awk -F '"' '{print $4}' \
    | base64 --decode > ingress.key
fi

kubectl -n jans create secret tls tls-certificate --key ingress.key --cert ingress.crt
