## OpenStack

- 用户名和密码分配

![20200118174739956](C:\Users\Auroot\Desktop\20200118174739956.jpg)

https://blog.csdn.net/weixin_41977332/article/details/104019892?utm_medium=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-1.compare&depth_1-utm_source=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-1.compare



### 安装基础组件和安装源

```shell
yum install ntp -y
yum install yum-plugin-priorities -y
yum install http://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/e/epel-release-7-12.noarch.rpm -y
yum install https://repos.fedorapeople.org/repos/openstack/openstack-queens/rdo-release-queens-0.noarch.rpm -y
yum upgrade
yum install openstack-selinux -y
```

#### 停止各个节点的防火墙服务

```shell
systemctl stop firewalld.service
systemctl disable firewalld.service
```

### 数据库组件的安装

控制节点的数据库和消息队列组件的安装配置

1. 安装mariadb

```shell
yum install mariadb mariadb-server MySQL-python -y
```

2. 备份配置文件（修改配置文件之前都要记得备份）以及配置文件的修改

```shell
cp /etc/my.cnf /etc/my.cnf.bak
vim /etc/my.cnf

[mysqld]
symbolic-links=0
bind-address=controller
default-storage-engine=innodb
innodb_file_per_table
collation-server=utf8_general_ci
init-connect='SET NAMES utf8'
character-set-server=utf8

!includedir /etc/my.cnf.d
```

3. 启动数据库服务

```shell 
systemctl enable mariadb.service
systemctl start mariadb.service
```

4. 配置数据库服务安全参数，设置root密码

```shell
mysql_secure_installation
```

### 消息队列组件rabbitmq安装配置

1.安装

```shell
yum install rabbitmq-server -y
```

2. 启动消息队列服务

```shell
systemctl enable rabbitmq-server.service
systemctl start rabbitmq-server.service
```

3. 添加用户，并允许远程访问

```shell
rabbitmqctl add_user openstack wwwwww
rabbitmqctl set_permissions openstack ".*" ".*" ".*"
```

4. 验证数据库服务和消息队列服务

```shell
mysql -uroot -pwwwwww
rabbitmqctl status
```

### keystone组件简介和安装配置

​	keystone是Openstack中提供认证服务的一个组件，主要负责项目管理、用户管理，用户鉴权，用户信息认证等。keystone租件安装配置在控制节点上，为了实现可伸缩性，此配置部署Fernet令牌和ApacheHTTP服务器来处理请求，步骤如下所示：

#### 在数据库中创建keystone的表

```shell
mysql -uroot -pwwwwww
create database keystone;
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY 'keystone';
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY 'keystone';
```

#### 安装keystone的组件

```shell
yum install openstack-keystone httpd mod_wsgi python-openstackclient memcached python-memcached -y 
```

其中memcached 是一个开源的、高性能的分布式内存对象缓存系统。通过在内存中缓存数据和对象来减少读取数据库的次数，从而提高网站访问速度，加速动态WEB应用、减轻数据库负载。keystone利用Memcached来缓存租户的Token等身份信息，从而在用户登陆验证时无需查询存储在MySQL后端数据库中的用户信息，这在数据库高负荷运行下的大型openstack集群中能够极大地提高用户的身份验证过程。
启动memcached服务：

```shell
systemctl enable memcached.service
systemctl start memcached.service
```

#### 修改keystone配置文件

```shell
cp /etc/keystone/keystone.conf /etc/keystone/keystone.conf.bak
vim /etc/keystone/keystone.conf

[database]
...
connection = mysql://keystone:keystone@localhost/keystone
...
[memcache]
...
servers = localhost:11211
...
[token]
....
provider = fernet
...
```

#### 同步数据库

```shell
su -s /bin/sh -c "keystone-manage db_sync" keystone
```

此时在mysql中的keystone库下已经创建成功多张表，进入数据库中查看并验证

#### 设置keystone的用户和组
设置一个查看keystone时候从组里的用户查找

```shell
keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
keystone-manage credential_setup --keystone-user keystone --keystone-group keystone
```

#### 设置keystone的Endpoint

```shell
keystone-manage bootstrap --bootstrap-password wwwwww --bootstrap-admin-url http://controller:35357/v3/ --bootstrap-internal-url http://controller:5000/v3/  --bootstrap-public-url http://controller:5000/v3/ --bootstrap-region-id RegionOne
```

其中设置三种endpoint，管理（admin）、内部（internal）以及公共（public）url

#### 配置keystone的httpd服务
修改apache服务的配置文件

```shell
cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.bak
vim /etc/httpd/conf/httpd.conf
...
ServerName 控制节点对应的主机名
...
```

软连接keystone到httpd

```shell
ln -s /usr/share/keystone/wsgi-keystone.conf /etc/httpd/conf.d/
```

启动httpdServer

```shell
systemctl enable httpd.service
systemctl start httpd.service
systemctl status httpd.service
```

#### 配置系统环境变量
在~/目录中创建文件openrc，内容如下所示

```shell
export OS_USERNAME=admin
export OS_PASSWORD=wwwwww
export OS_PROJECT_NAME=admin
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_AUTH_URL=http://controller:5000/v3
export OS_IDENTITY_API_VERSION=3
```

每次打开系统之后，在命令行中通过source openrc即可登陆admin用户，在命令行中进行openstack相关的操作

#### 创建项目、用户、角色等信息
创建项目

```shell
openstack project create --description "Admin Project" admin
```

为项目admin创建用户：admin

```shell
openstack user create --password-prompt admin
```

创建角色：admin

```shell
openstack role create admin
```

将角色admin授权给用户admin

```shell
openstack role add --project admin --user admin admin
```

keystone官方安装文档：https://docs.openstack.org/keystone/train/install/keystone-install-rdo.html

#### glance组件简介和安装配置
glance组件是为openstack中其他组件提供镜像服务的组件。glance的镜像服务包括：镜像发现、镜像注册，拉取虚拟机镜像等。本教程的glance组件安装配置在控制节点，镜像存储于控制节点本地文件系统中

#### 数据库，服务凭证和endpoint的配置
登陆mysql并创建glance数据库

```shell
mysql -uroot -pwwwwww

CREATE DATABASE glance;
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY 'glance';
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY 'glance';
```

创建glance用户并添加 admin 角色到 glance 用户和 service 项目上

```shell
openstack user create --password-prompt glance
openstack role add --project service --user glance admin
```

创建glance服务实体

```shell
openstack service create --name glance --description “OpenStack Image” image
```

创建镜像服务的endpoint

```shell
openstack endpoint create --region RegionOne image public http://控制节点主机名:9292
openstack endpoint create --region RegionOne image internal http://控制节点主机名:9292
openstack endpoint create --region RegionOne image admin http://控制节点主机名:9292
```

#### 安装并配置glance组件

```shell
yum install openstack-glance -y
```

编辑glance-api配置文件 /etc/glance/glance-api.conf

```shell
cp /etc/glance/glance-api.conf /etc/glance/glance-api.conf.bak
vim /etc/glance/glance-api.conf以下是glance-api.conf中应该配置的内容
```

```shell
[database]
...
connection = mysql://glance:glance@localhost/glance
...

[keystone_authtoken]
...
auth_uri = http://控制节点主机名:5000
auth_url = http://控制节点主机名:35357
memcached_servers = controller:11211
auth_type = password
project_domain_name = Default
user_domain_name = Default
project_name = service
username = glance
password = glance
...
[paste_deploy]
 ...
flavor = keystone
...
[glance_store]
...
stores = file,http
default_store = file
filesystem_store_datadir = /var/lib/glance/images/
```

编辑glance-registry配置文件 /etc/glance/glance-registry.conf

```shell
cp /etc/glance/glance-registry.conf /etc/glance/glance-registry.conf.bak
vim /etc/glance/glance-registry.conf
```

以下是glance-registry.conf中应该配置的内容

```shell
[database]
 ...
connection = mysql://glance:glance@localhost/glance

[keystone_authtoken]

auth_uri = http://控制节点主机名:5000
auth_url = http://控制节点主机名:35357
memcached_servers = controller:11211
auth_type = password
project_domain_name = Default
user_domain_name = Default
project_name = service
username = glance
password = glance

[paste_deploy]
...
flavor = keystone
```

写入镜像服务数据库

```shell
su -s /bin/sh -c “glance-manage db_sync” glance
```

进入glance数据库验证是否已经出现15张表

#### 启动glance服务并验证

```shell
systemctl enable openstack-glance-api.service openstack-glance-registry.service
systemctl start openstack-glance-api.service openstack-glance-registry.service
systemctl status openstack-glance-api.service openstack-glance-registry.service
```



从官网上下载镜像cirros进行测试

```shell
wget http://download.cirros-cloud.net/0.4.0/cirros-0.4.0-x86_64-disk.img
```

验证能否上传镜像

```shell
openstack image create "cirros" \
                --file cirros-0.4.0-x86_64-disk.img \
                --disk-format qcow2 --container-format bare \
                --public
```
















