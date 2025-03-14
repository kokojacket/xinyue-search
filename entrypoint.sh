#!/bin/bash
set -e

echo ">>> 开始初始化应用..."

# 确保.env文件存在
if [ ! -f "/var/www/html/.env" ]; then
    echo ">>> .env文件不存在，使用默认配置..."
    cp /var/www/html/.env.default /var/www/html/.env
    chown www-data:www-data /var/www/html/.env
    chmod 644 /var/www/html/.env
fi

# 确保runtime目录存在且有写权限
if [ ! -d "/var/www/html/runtime" ]; then
    echo ">>> 创建runtime目录..."
    mkdir -p /var/www/html/runtime
fi
chown -R www-data:www-data /var/www/html/runtime
chmod -R 777 /var/www/html/runtime

# 确保uploads目录存在且有写权限
if [ ! -d "/var/www/html/public/uploads" ]; then
    echo ">>> 创建uploads目录..."
    mkdir -p /var/www/html/public/uploads
fi
chown -R www-data:www-data /var/www/html/public/uploads
chmod -R 777 /var/www/html/public/uploads

# 检查web根目录是否为空
if [ -z "$(ls -A /var/www/html/public 2>/dev/null)" ]; then
    echo ">>> 初始化: 目标目录为空，从镜像复制代码..."
    
    # 创建临时目录
    mkdir -p /tmp/app_backup
    
    # 备份镜像中的代码
    cp -a /var/www/html/. /tmp/app_backup/
    
    # 将备份的代码复制到挂载目录
    cp -a /tmp/app_backup/. /var/www/html/
    
    # 清理临时目录
    rm -rf /tmp/app_backup
    
    # 设置权限
    chown -R www-data:www-data /var/www/html
    chmod -R 755 /var/www/html
    chmod -R 777 /var/www/html/runtime
    chmod -R 777 /var/www/html/public/uploads
    
    echo ">>> 初始化完成: 代码已复制到挂载目录"
else
    echo ">>> 检测到现有代码，跳过初始化"
fi

echo ">>> 应用初始化完成"

# 执行原始的Apache启动命令
exec apache2-foreground "$@" 