# boxedcode/alpine-nginx-php-fpm

FROM alpine:3.4
MAINTAINER boxedcode <hello@boxedcode.com>

# Environment variables
ENV BUILD_PACKAGES="wget tar make gcc g++ zlib-dev openssl-dev pcre-dev fcgi-dev jpeg-dev libmcrypt-dev bzip2-dev curl-dev libpng-dev libxslt-dev postgresql-dev perl-dev file acl-dev libedit-dev" \
    ESSENTIAL_PACKAGES="nginx openssl pcre zlib supervisor sed re2c m4 ca-certificates" \
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
    --disable-cgi \
    --enable-mbstring \
    --enable-mysqlnd \
    --enable-soap \
    --enable-calendar \
    --enable-inline-optimization \
    --enable-sockets \
    --enable-sysvsem \
    --enable-sysvshm \
    --enable-pcntl \
    --enable-mbregex \
    --enable-exif \
    --enable-bcmath \
    --enable-zip \
    --enable-ftp \
    --enable-opcache \
    --enable-fpm \
    --enable-gd-native-ttf \
    --with-pdo-pgsql \
    --with-libedit \
    --with-libxml-dir=/usr \
    --with-curl \
    --with-mcrypt \
    --with-zlib \
    --with-gd \
    --with-pgsql \
    --with-bz2 \
    --with-zlib \
    --with-mhash \
    --with-pcre-regex \
    --with-pdo-mysql \
    --with-jpeg-dir=/usr \
    --with-png-dir=/usr \
    --with-openssl \
    --with-fpm-user=nginx \
    --with-fpm-group=nginx \
    --with-libdir=/usr/lib \
    --with-gettext \
    --with-xmlrpc \
    --with-xsl \
    --with-pear && \
    make && \
    make install && \
    make clean && \
    cd .. && \
    rm -f php-7.0.7.tar.gz && \
    rm -rf php-7.0.7 && \
    mkdir -p /etc/php.d && \
    chmod 755 /etc/php.d

# Copy manifest folder
COPY ./manifest/ /
RUN chmod 755 /entrypoint.sh

# Setup Volume
VOLUME ["/var/www/html"]
VOLUME ["/etc/nginx/ssl"]
VOLUME ["/var/log/nginx"]

# Expose Ports
EXPOSE 443 80

CMD ["/bin/bash", "/entrypoint.sh"]