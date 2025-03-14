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
RUN echo 'APP_DEBUG = false' > /var/www/html/.env.default \
    && echo 'SYSTEM_SALT= YAdmin' >> /var/www/html/.env.default \
    && echo '' >> /var/www/html/.env.default \
    && echo '[APP]' >> /var/www/html/.env.default \
    && echo 'DEFAULT_TIMEZONE = Asia/Chongqing' >> /var/www/html/.env.default \
    && echo '' >> /var/www/html/.env.default \
    && echo '[DATABASE]' >> /var/www/html/.env.default \
    && echo 'TYPE = mysql' >> /var/www/html/.env.default \
    && echo 'HOSTNAME = mysql' >> /var/www/html/.env.default \
    && echo 'DATABASE = www_dj_com' >> /var/www/html/.env.default \
    && echo 'USERNAME = root' >> /var/www/html/.env.default \
    && echo 'PASSWORD = root' >> /var/www/html/.env.default \
    && echo 'HOSTPORT = 3306' >> /var/www/html/.env.default \
    && echo 'CHARSET = utf8mb4' >> /var/www/html/.env.default \
    && echo 'DEBUG = false' >> /var/www/html/.env.default \
    && echo 'PREFIX = qf_' >> /var/www/html/.env.default \
    && echo '' >> /var/www/html/.env.default \
    && echo '[LANG]' >> /var/www/html/.env.default \
    && echo 'default_lang = zh-cn' >> /var/www/html/.env.default

# 复制启动脚本
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

# 暴露端口
EXPOSE 80

# 设置启动脚本
ENTRYPOINT ["entrypoint.sh"] 