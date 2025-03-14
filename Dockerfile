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

# 启用rewrite模块
RUN a2enmod rewrite

# 复制项目文件
COPY . /var/www/html/

# 确保public/.htaccess存在且包含伪静态规则
RUN echo '<IfModule mod_rewrite.c>\n  Options +FollowSymlinks -Multiviews\n  RewriteEngine On\n\n  RewriteCond %{REQUEST_FILENAME} !-d\n  RewriteCond %{REQUEST_FILENAME} !-f\n  RewriteRule ^(.*)$ index.php?s=/$1 [QSA,PT,L]\n</IfModule>' > /var/www/html/public/.htaccess

# 设置Apache根目录为public
RUN sed -i 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/000-default.conf

# 设置目录权限
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# 安装项目依赖
RUN composer install --no-dev --optimize-autoloader

# 创建运行时目录并设置权限
RUN mkdir -p /var/www/html/runtime \
    && chmod -R 777 /var/www/html/runtime \
    && mkdir -p /var/www/html/public/uploads \
    && chmod -R 777 /var/www/html/public/uploads

# 创建默认.env文件(将在entrypoint.sh中处理)
RUN cat > /var/www/html/.env.default << EOF
APP_DEBUG = false
SYSTEM_SALT= YAdmin

[APP]
DEFAULT_TIMEZONE = Asia/Chongqing

[DATABASE]
TYPE = mysql
HOSTNAME = mysql
DATABASE = www_dj_com
USERNAME = root
PASSWORD = root
HOSTPORT = 3306
CHARSET = utf8mb4
DEBUG = false
PREFIX = qf_

[LANG]
default_lang = zh-cn
EOF

# 复制启动脚本
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

# 暴露端口
EXPOSE 80

# 设置启动脚本
ENTRYPOINT ["entrypoint.sh"] 