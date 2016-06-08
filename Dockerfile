# boxedcode/alpine-nginx-php-fpm

FROM alpine:3.4
MAINTAINER boxedcode <hello@boxedcode.com>

# Environment variables
ENV BUILD_PACKAGES="wget tar make gcc g++ zlib-dev openssl-dev pcre-dev fcgi-dev jpeg-dev libmcrypt-dev bzip2-dev curl-dev libpng-dev libxslt-dev postgresql-dev perl-dev" \
    ESSENTIAL_PACKAGES="nginx openssl pcre zlib supervisor sed re2c m4" \
    UTILITY_PACKAGES="bash vim"

# Configure nginx
RUN apk update && \
    apk --no-cache --progress add $ESSENTIAL_PACKAGES $UTILITY_PACKAGES && \
    mkdir -p /run/nginx/ && \
    chmod ugo+w /run/nginx/ && \
    rm -f /etc/nginx/nginx.conf && \
    mkdir -p /etc/nginx/conf.d && \
    mkdir -p /etc/nginx/ssl/ && \
    mkdir -p /var/www/html/ && \
    chmod -R 775 /var/www/ && \
    chown -R nginx:nginx /var/www/

# Replace the default nginx.conf file
COPY ./nginx.conf /etc/nginx/nginx.conf

# tweak nginx config
RUN sed -i -e"s/worker_processes  1/worker_processes 5/" /etc/nginx/nginx.conf && \
    sed -i -e"s/keepalive_timeout\s*65/keepalive_timeout 2/" /etc/nginx/nginx.conf && \
    sed -i -e"s/keepalive_timeout 2/keepalive_timeout 2;\n\tclient_max_body_size 100m/" /etc/nginx/nginx.conf && \
    echo "daemon off;" >> /etc/nginx/nginx.conf

# Build and configure php/php-fpm
RUN apk --no-cache --progress add $BUILD_PACKAGES && \
    wget http://ftp.gnu.org/pub/gnu/gettext/gettext-0.19.tar.gz && \
    tar -zxvf gettext-0.19.tar.gz && \
    cd gettext-0.19 && \
    ./configure && \
    make && \
    make install && \
    make clean && \
    cd .. && \
    rm -f gettext-0.19.tar.gz && \
    rm -rf gettext-0.19 && \
    wget http://ftp.gnu.org/gnu/bison/bison-3.0.4.tar.gz && \
    tar -zxvf bison-3.0.4.tar.gz && \
    cd bison-3.0.4 && \
    ./configure && \
    make && \
    make install && \
    make clean && \
    cd .. && \
    rm -f bison-3.0.4.tar.gz && \
    rm -rf bison-3.0.4 && \
    wget http://de1.php.net/get/php-7.0.7.tar.gz/from/this/mirror -O php-7.0.7.tar.gz && \
    tar -zxvf php-7.0.7.tar.gz && \
    cd php-7.0.7 && \
    ./configure \
    --prefix=/usr \
    --with-config-file-path=/etc \
    --with-config-file-scan-dir=/etc/php.d \
    --with-pdo-pgsql \
    --enable-mbstring \
    --enable-mysqlnd \
    --with-libxml-dir=/usr \
    --enable-soap \
    --enable-calendar \
    --with-curl \
    --with-mcrypt \
    --with-zlib \
    --with-gd \
    --with-pgsql \
    --enable-inline-optimization \
    --with-bz2 \
    --with-zlib \
    --enable-sockets \
    --enable-sysvsem \
    --enable-sysvshm \
    --enable-pcntl \
    --enable-mbregex \
    --enable-exif \
    --enable-bcmath \
    --with-mhash \
    --enable-zip \
    --with-pcre-regex \
    --with-pdo-mysql \
    --with-jpeg-dir=/usr \
    --with-png-dir=/usr \
    --enable-gd-native-ttf \
    --with-openssl \
    --with-fpm-user=nginx \
    --with-fpm-group=nginx \
    --with-libdir=/usr/lib \
    --enable-ftp \
    --with-gettext \
    --with-xmlrpc \
    --with-xsl \
    --with-pear \
    --enable-opcache \
    --enable-fpm && \
    make && \
    make install && \
    make clean && \
    cd .. && \
    rm -f php-7.0.7.tar.gz && \
    rm -rf php-7.0.7 && \
    apk del build-base alpine-sdk

# Supervisor Config
COPY ./supervisord.conf /etc/supervisord.conf

# Entrypoint for triggering supervisord
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh

# Setup Volume
VOLUME ["/var/www/html"]
VOLUME ["/etc/nginx/ssl"]
VOLUME ["/var/log/nginx"]

# Expose Ports
EXPOSE 443 80

CMD ["/bin/bash", "/entrypoint.sh"]