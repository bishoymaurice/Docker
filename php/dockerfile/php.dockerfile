ARG PHP_TAG
FROM php:${PHP_TAG}

ARG WORKDIR=/app
WORKDIR ${WORKDIR}

RUN apt-get update && apt-get install -y --fix-missing \
    default-mysql-client \
    imagemagick \
    graphviz \
    git \
    curl \
    libpng-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libxml2-dev \
    libxslt1-dev \
    libtidy-dev \
    libcurl3-dev \
    libfreetype6-dev \
    libmemcached-dev \
    zip \
    libzip-dev \
    wget \
    linux-libc-dev \
    libyaml-dev \
    zlib1g-dev \
    libicu-dev \
    libpq-dev \
    libssl-dev && \
    rm -r /var/lib/apt/lists/*

RUN docker-php-ext-configure bcmath --enable-bcmath \
    && docker-php-ext-configure pcntl --enable-pcntl \
    && docker-php-ext-configure pdo_mysql --with-pdo-mysql \
    && docker-php-ext-configure mbstring --enable-mbstring \
    && docker-php-ext-configure soap --enable-soap \
    && docker-php-ext-configure gd \
        --with-jpeg-dir=/usr/lib \
        --with-freetype-dir=/usr/include/freetype2 \
    && docker-php-ext-install \
        bcmath \
        curl \
        intl \
        json \
        gd \
        mbstring \
        mysqli \
        opcache \
        pcntl \
        pdo_mysql \
        soap \
        sockets \
        tidy \
        xsl \
        xmlrpc \
        zip \
  && docker-php-ext-enable opcache

# Copy opcache configration
COPY ./config/php/opcache.ini /usr/local/etc/php/conf.d/opcache.ini

# Install composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php --version="1.10.9"
RUN mv composer.phar /usr/local/bin/composer
ENV PATH "/usr/local/bin/composer:$PATH"

RUN /usr/local/bin/composer global require "hirak/prestissimo:^0.3"

# Install xDebug
RUN pecl install xdebug
RUN docker-php-ext-enable xdebug

# Copy xdebug configration for remote debugging
COPY ./config/php/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

# Copy timezone configration
COPY ./config/php/timezone.ini /usr/local/etc/php/conf.d/timezone.ini

# Set timezone
RUN rm /etc/localtime
RUN ln -s /usr/share/zoneinfo/Europe/Paris /etc/localtime
RUN "date"

# Short open tags fix - another Symfony requirements
COPY ./config/php/custom-php.ini /usr/local/etc/php/conf.d/custom-php.ini

RUN sed -i 's/127.0.0.1:9000/0.0.0.0:9000/g' /usr/local/etc/php-fpm.d/www.conf

RUN composer --version && php -v
 
ENV PATH="${COMPOSER_HOME}/vendor/bin:${PATH}"

# Install memcached
RUN apt-get install -y libmemcached-dev
RUN pecl install memcached

# Install mailhog
RUN wget https://github.com/mailhog/mhsendmail/releases/download/v0.2.0/mhsendmail_linux_amd64
RUN chmod +x mhsendmail_linux_amd64
RUN mv mhsendmail_linux_amd64 /usr/bin/mhsendmail

# Add drush to path
ENV PATH="${WORKDIR}/vendor/drush/drush:${PATH}"

# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]
