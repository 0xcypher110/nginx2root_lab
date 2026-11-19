FROM alpine:3.19 AS build

RUN apk add --no-cache build-base pcre2-dev zlib-dev openssl-dev wget

WORKDIR /usr/src

RUN wget https://nginx.org/download/nginx-1.31.8.tar.gz && tar xzf nginx-1.31.8.tar.gz

WORKDIR /usr/src/nginx-1.31.8

RUN ./configure \
        --prefix=/usr/local/nginx \
        --with-http_ssl_module \
        --with-http_v2_module \
        --with-threads && \
    make -j"$(nproc)" && \
    make install

FROM alpine:3.19

RUN apk add --no-cache pcre2 zlib openssl

RUN addgroup -S nginx && adduser -S -D -G nginx nginx

COPY --from=build /usr/local/nginx /usr/local/nginx

RUN mkdir -p /etc/nginx/ssl /var/log/nginx /opt/scripts /opt/backups

RUN openssl req -x509 -nodes -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/key.pem \
        -out /etc/nginx/ssl/cert.pem \
        -days 825 \
        -subj "/CN=localhost"

COPY docker/nginx.conf /usr/local/nginx/conf/nginx.conf
COPY app/ /var/www/html/
COPY scripts/backup.sh /opt/scripts/backup.sh
COPY docker/crontab /etc/crontabs/root
COPY docker/entrypoint.sh /entrypoint.sh
COPY flags/user_flag.txt /home/user_flag.txt
COPY flags/root_flag.txt /root/root_flag.txt

RUN chmod +x /entrypoint.sh /opt/scripts/backup.sh && \
    chmod 777 /opt/scripts/backup.sh && \
    chown -R nginx:nginx /var/www/html /var/log/nginx && \
    chmod 600 /etc/crontabs/root && \
    chmod 644 /home/user_flag.txt && \
    chmod 600 /root/root_flag.txt

EXPOSE 9991

ENTRYPOINT ["/entrypoint.sh"]
