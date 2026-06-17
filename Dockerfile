FROM nextcloud:fpm

COPY /nginx-reverse-proxy/certs/TCONET-CA.crt /usr/local/share/ca-certificates/

RUN update-ca-certificates