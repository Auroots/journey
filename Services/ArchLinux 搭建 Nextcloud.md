# ArchLinux 搭建 Nextcloud



### 安装软件包

```shell
pacman -S mariadb php nextcloud php-intl php-fpm redis php-redis
```

###  1. 配置数据库

运行数据库

```shell
mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
systemctl enable mariadb
systemctl start mariadb
```

#### 增强安全性

```shell
mysql_secure_installation
```

#### 限制只能本地访问

```shell
sudo vim /etc/my.cnf.d/server.cnf

[mysqld]
bind-address=127.0.0.1
skip-networking
```

#### 自动补全功能

```shell
sudo vim /etc/my.cnf.d/mysql-clients.cnf

[mysql]
auto-rehash
```

#### 配置 Nextcloud 的数据库

```mysql
sudo mysql -u root -p

CREATE DATABASE nextcloud DEFAULT CHARACTER SET 'utf8mb4' COLLATE 'utf8mb4_general_ci';

GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'localhost' IDENTIFIED BY
'<password>';

FLUSH PRIVILEGES;
\q
```

### 2. 配置 php

#### 启用所需要的模块

```shell
sudo vim /etc/php/php.ini

[php]
extension=gd
extension=iconv
extension=intl
extension=mysqli
zend_extension=opcache
extension=pdo_mysql

memory_limit = 512M
upload_max_filesize = 1024M
```



### 3. 配置 Redis 缓存.

```shell
sudo systemctl enable redis
sudo systemctl start redis
```

####  配置 php 扩展

```shell
sudo vim /etc/php/conf.d/redis.ini

extension=redis
```

```shell
sudo vim /etc/php/conf.d/igbinary.ini

[igbinary]
extension=igbinary.so
```

#### 在 nextcloud 的配置文件中启用 redis

```shell
sudo vim /etc/webapps/nextcloud/config.php

'memcache.distributed' => 'OCMemcacheRedis',
'memcache.local' => 'OCMemcacheRedis',
'memcache.locking' => 'OCMemcacheRedis',
'redis' => array(
     'host' => 'localhost',
     'port' => 6379,
     ),
```



### 4. 配置 php-fpm

#### 在 php-fpm 添加 nextcloud 配置

```shell
sudo vim /etc/php/php-fpm.d/nextcloud.conf

[nextcloud]
user = nextcloud
group = nextcloud
listen = /run/nextcloud/nextcloud.sock
env[PATH] = /usr/local/bin:/usr/bin:/bin
env[TMP] = /tmp

; should be accessible by your web server
listen.owner = http
listen.group = http

pm = dynamic
pm.max_children = 15
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
```

#### 运行

```shell
sudo systemctl edit php-fpm.service
```

#### 编辑 php-fpm 服务

```shell
sudo vim /etc/systemd/system/php-fpm.service.d/override.conf

[Service]
# Your data directory
ReadWritePaths=/var/lib/nextcloud/data

# Optional: add if you've set the default apps directory to be writable in config.php
ReadWritePaths=/usr/share/webapps/nextcloud/apps

# Optional: unnecessary if you've set 'config_is_read_only' => true in your config.php
ReadWritePaths=/usr/share/webapps/nextcloud/config

ReadWritePaths=/etc/webapps/nextcloud/config

# Optional: add if you want to use Nextcloud's internal update process
# ReadWritePaths=/usr/share/webapps/nextcloud
```





```text
docker run -d --name nextcloud -v nextcloud:/var/www/html -p 8080:80 nextcloud
```







