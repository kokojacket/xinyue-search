# 心悦搜索 Docker 镜像

这是"心悦搜索"项目的官方Docker镜像，基于PHP 7.2构建。

## 支持的标签

- `latest`: 最新稳定版
- `v{版本号}`: 例如`v2.1`、`v2.0`等特定版本
- `{分支名}`: 例如`main`、`develop`等分支的最新构建
- `sha-{hash}`: 特定提交的构建版本

## 快速开始

1. 创建docker-compose.yml文件：

```yaml
version: '3'

services:
  app:
    image: ghcr.io/用户名/xinyue-search:latest
    ports:
      - "80:80"
    depends_on:
      - mysql
    environment:
      DATABASE_HOSTNAME: mysql
      DATABASE_USERNAME: root
      DATABASE_PASSWORD: root
    networks:
      - xinyue-network
    restart: always

  mysql:
    image: mysql:5.7
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: www_dj_com
    volumes:
      - mysql-data:/var/lib/mysql
      - ./data.sql:/docker-entrypoint-initdb.d/data.sql
    networks:
      - xinyue-network
    restart: always

networks:
  xinyue-network:

volumes:
  mysql-data:
```

2. 启动服务：

```bash
docker-compose up -d
```

3. 访问应用：

- 前台: http://localhost
- 后台: http://localhost/qfadmin (默认账号: admin, 密码: 123456)

## 环境变量

可以通过环境变量自定义配置：

| 环境变量 | 描述 | 默认值 |
|---------|------|-------|
| APP_DEBUG | 是否开启调试模式 | false |
| DATABASE_HOSTNAME | 数据库主机名 | mysql |
| DATABASE_DATABASE | 数据库名 | www_dj_com |
| DATABASE_USERNAME | 数据库用户名 | root |
| DATABASE_PASSWORD | 数据库密码 | root |
| DATABASE_HOSTPORT | 数据库端口 | 3306 |

## 镜像信息

- 基础镜像: php:7.2-apache
- 已安装PHP扩展: gd, pdo_mysql, mysqli, zip, bcmath
- 已启用Apache模块: mod_rewrite

## 多架构支持

此镜像支持以下架构：

- linux/amd64 (x86_64)
- linux/arm64 (aarch64)

## 项目地址

GitHub: [https://github.com/用户名/xinyue-search](https://github.com/用户名/xinyue-search)

## 许可证

Apache-2.0 