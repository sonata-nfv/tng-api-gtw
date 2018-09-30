#!/bin/bash
sed -e "s/{DOMAIN}/$DOMAIN/g" /default-no-ssl-template.conf > /default-no-ssl.conf
sed -e "s/{DOMAIN}/$DOMAIN/g" /default-ssl-template.conf > /default-ssl.conf

if [ -f /etc/nginx/cert/sonata.crt ] && [ -f /etc/nginx/cert/sonata.key ]
then
   echo "Starting 5GTANGO (V&V or Service) Platform" > /dev/stdout
   ln -s /default-ssl.conf /etc/nginx/conf.d/default-ssl.conf
   ln -s -f /default.conf /etc/nginx/conf.d/default.conf
else
   echo "NO CERTIFICATES AVAILABLE" > /dev/stdout
   echo "/etc/nginx/cert/sonata.crt AND /etc/nginx/cert/sonata.key Should exists" > /dev/stdout
   echo "Running 5GTANGO (V&V or Service) Platform without HTTPS" > /dev/stdout
   ln -s -f /default-no-ssl.conf /etc/nginx/conf.d/default.conf
fi

exec $(which nginx) -c /etc/nginx/nginx.conf -g "daemon off;"

