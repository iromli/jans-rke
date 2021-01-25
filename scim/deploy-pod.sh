#!/bin/sh

NGINX_IP=${NGINX_IP:-$(ip route get 8.8.8.8 | awk -F"src " 'NR==1{split($2,a," ");print a[1]}')}

cat scim.yml | sed -s "s@NGINX_IP@$NGINX_IP@g" | kubectl apply -f -
