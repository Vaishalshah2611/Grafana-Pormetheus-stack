FROM nginx:alpine AS builder
ENV NGINX_VERSION 1.18.0

RUN apk add --no-cache --virtual .build-deps \
gcc \
libc-dev \
make \
openssl-dev \
pcre-dev \
zlib-dev \
linux-headers \
curl \
gnupg \
libxslt-dev \
gd-dev \
geoip-dev

RUN wget "http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" -O nginx.tar.gz && \
tar xf nginx.tar.gz -C /opt/ && \
ls -la /opt/ && \
curl -fSL https://github.com/vozlt/nginx-module-vts/archive/v0.1.18.tar.gz | tar xzf - -C /tmp


RUN CONFARGS=$(nginx -V 2>&1 | sed -n -e 's/^.*arguments: //p') \
cd /opt/nginx-$NGINX_VERSION && \
./configure --with-compat $CONFARGS --add-dynamic-module=/tmp/nginx-module-vts-0.1.18 && \
make && make install

CMD ['/bin/bash']

FROM nginx:1.18.0
COPY --from=builder /usr/local/nginx/modules/ngx_http_vhost_traffic_status_module.so /usr/lib/nginx/modules/ngx_http_vhost_traffic_status_module.so
COPY --from=builder /usr/local/nginx/modules/ngx_http_vhost_traffic_status_module.so /etc/nginx/modules/ngx_http_vhost_traffic_status_module.so

EXPOSE 80
STOPSIGNAL SIGTERM
CMD ["nginx", "-g", "daemon off;"]
