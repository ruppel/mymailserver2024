FROM php:8.4-apache

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Install required tools for TYPO3
RUN apt-get update \
  && apt-get install -y \
  unzip \
  git

# Add install-php-extensions command
ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

# Install required PHP extensions for TYPO3
RUN install-php-extensions \
  pdo \
  session \
  filter \
  SPL \
  exif \
  standard \
  pdo_mysql \
  intl \
  xml \
  mbstring \
  tokenizer \
  opcache \
  zip \
  gd \
  imagick \
  fileinfo \
  zlib \
  openssl

# Clean up apt
RUN apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Set recommended PHP settings
COPY php.ini /usr/local/etc/php/

# Install Composer globally
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Add Composer to the PATH
ENV PATH="$PATH:/usr/local/bin"

# Document root
WORKDIR /app

# typo3 needs document root set to public subfolder
ENV APACHE_DOCUMENT_ROOT=/app/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf
