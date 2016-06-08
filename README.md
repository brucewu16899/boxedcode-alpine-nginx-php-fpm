# Introduction

This is a set of build files including a Dockerfile to build a container image for nginx(with http2 support) and php-fpm based on Alpine Linux to keep the size of the container small, and inspired by the work done by [Ric Harvey](https://github.com/ngineered/nginx-php-fpm). The container can also use environment variables to configure your web application using the templating detailed in the special features section.

# Git repository

The source files for this project can be found here: [https://gitlab.com/boxedcode/alpine-nginx-php-fpm](https://gitlab.com/boxedcode/alpine-nginx-php-fpm)

If you have any improvements please submit a pull request.

# Docker hub repository

The Docker hub build can be found here: [https://hub.docker.com/r/boxedcode/alpine-nginx-php-fpm/](https://hub.docker.com/r/boxedcode/alpine-nginx-php-fpm/)

# Nginx versions

* v1.0.0: 1.11.1
* Latest: 1.11.1

# PHP FPM versions

* v1.0.0: 7.0.7
* Latest: 7.0.7