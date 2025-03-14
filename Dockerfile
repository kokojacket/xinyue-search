FROM php:7.2-apache

# 设置工作目录
WORKDIR /var/www/html

# 安装依赖
RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libzip-dev \
    unzip \
    git \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-install mysqli \
    && docker-php-ext-install zip \
    && docker-php-ext-install bcmath

# 安装Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 设置Apache配置
RUN a2enmod rewrite
COPY ./public/.htaccess /var/www/html/.htaccess

# 复制项目文件
COPY . /var/www/html/

# 设置目录权限
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# 设置Apache根目录为public
RUN sed -i 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/000-default.conf

# 安装项目依赖
RUN composer install --no-dev --optimize-autoloader

# 设置环境变量
ENV APP_DEBUG=false
ENV SYSTEM_SALT=YAdmin
ENV APP_DEFAULT_TIMEZONE=Asia/Chongqing
ENV DATABASE_TYPE=mysql
ENV DATABASE_HOSTNAME=mysql
ENV DATABASE_DATABASE=www_dj_com
ENV DATABASE_USERNAME=root
ENV DATABASE_PASSWORD=root
ENV DATABASE_HOSTPORT=3306
ENV DATABASE_CHARSET=utf8mb4
ENV DATABASE_DEBUG=false
ENV DATABASE_PREFIX=qf_
ENV LANG_DEFAULT_LANG=zh-cn

# 暴露端口
EXPOSE 80

# 启动Apache
CMD ["apache2-foreground"] 