FROM php:7.4-fpm

# Arguments defined in docker-compose.yml
ARG user
ARG uid

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    libaio1 \ 
    libaio-dev

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create system user to run Composer and Artisan Commands
RUN useradd -G www-data,root -u $uid -d /home/$user $user   
RUN mkdir -p /home/$user/.composer && \
    chown -R $user:$user /home/$user

COPY ./oracle-client/instantclient-basic-linux.x64-18.5.0.0.0dbru.zip /usr/local
COPY ./oracle-client/instantclient-sdk-linux.x64-18.5.0.0.0dbru.zip /usr/local
COPY ./oracle-client/instantclient-sqlplus-linux.x64-18.5.0.0.0dbru.zip /usr/local

RUN unzip /usr/local/instantclient-basic-linux.x64-18.5.0.0.0dbru.zip -d /usr/local && \
    unzip /usr/local/instantclient-sdk-linux.x64-18.5.0.0.0dbru.zip -d /usr/local && \
    unzip /usr/local/instantclient-sqlplus-linux.x64-18.5.0.0.0dbru.zip -d /usr/local && \
    ln -sf /usr/local/instantclient_18_5 /usr/local/instantclient && \
    ln -sf /usr/local/instantclient/libclntsh.so.* /usr/local/instantclient/libclntsh.so && \
    ln -sf /usr/local/instantclient/lib* /usr/lib && \
    ln -sf /usr/local/instantclient/sqlplus /usr/bin/sqlplus  && \
    php -v

ENV LD_LIBRARY_PATH /usr/local/instantclient/ 

RUN echo 'instantclient,/usr/local/instantclient/' | pecl install oci8-2.2.0 \
    && docker-php-ext-enable oci8 \
    # && docker-php-ext-enable oci8-2.2.0 \
    && docker-php-ext-configure pdo_oci --with-pdo-oci=instantclient,/usr/local/instantclient \
    && docker-php-ext-install pdo_oci

# Set working directory
WORKDIR /var/www

USER $user