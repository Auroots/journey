## OpenRC使用逻辑

OpenRC在`/etc/init.d`维护每个service的控制脚本

1. 通过`/etc/init.d/<service> <start|stop|restart|zap>`的方式控制服务开启、关闭、重启。

2. 使用`rc-service <service> <start|stop|restart|zap>`进行控制。

OpenRC中的不同的runlevel表示计算机启动到关机的不同阶段，由`/etc/runlevel`目录管理，常用的default阶段就是系统初始化后进入到多multi-user阶段的阶段。将service放置在某运行级别`runlevel`对应的目录中，则表示这个`service`会在这个`runlevel`启动。

`rc-update`用于管理`runlevel`，命令格式为`rc-update <add|delete> <service> <runlevel>`，可以方便的将`service`移入移出`runlevel`。

`rc-status`用于查看service的状态，如果遇到service的状态为`clash`，则需要手动`stop`和`start`。而当处于无法`stop`也无法`start`的情况时`zap`就起作用了，执行`rc-service <service> zap`在重启service即可修复。

OpenRC的配置文件位于`/etc/rc.conf`，详细阅读会发现很多有用功能，如`rc_logger`和`rc_parallel`。需要小心`rc_parallel`让服务并行启动的同时存在死锁的风险。

每个service都可以有它独立的配置文件，`/etc/conf.d`目录维护了每个脚本的配置文件，可以在其中为每个脚本设置单独的变量。



- 增删开机启动服务：`rc-update [ add | delete ] [ service ]`

| rc-update 选项（简写） | rc-update 选项（全写） | 选项说明               |
| ---------------------- | ---------------------- | ---------------------- |
| -a                     | --all                  | 处理所有运行级别       |
| -s                     | --stack                | 堆叠运行级别而不是服务 |
| -u                     | --update               | 强制更新依赖关系树     |
| -h                     | --help                 | 显示帮助输出           |
| -C                     | --nocolor              | 禁止彩色输出           |
| -V                     | --version              | 显示软件版本信息       |
| -v                     | --verbose              | 显示执行过程的详细信息 |
| -q                     | --quiet                | 不输出执行过程的信息   |
|                        |                        |                        |



- 查询服务状态：`rc-status  [ -a 显示所有运行服务 ]`

| 选项（简写） | 选项（全写）  | 选项说明                             |
| ------------ | ------------- | ------------------------------------ |
| -a           | --all         | 显示所有运行级别的服务               |
| -c           | --crashed     | 显示崩溃的服务                       |
| -f           | --format      | 格式状态为可解析（当前arg必须为ini） |
| -l           | --list        | 显示运行级别列表                     |
| -m           | --manual      | 显示手动启动的服务                   |
| -r           | --runlevel    | 显示当前运行级别的名称               |
| -s           | --servicelist | 显示服务列表                         |
| -S           | --supervised  | 显示监督服务                         |
| -u           | --unused      | 显示服务未分配给任何运行级别         |
| -h           | --help        | 显示帮助信息                         |



- **服务启停管理(1)：**`rc-service [ service ] [ start | stop | restart | zap ]`

- **服务启停管理(2)：**`/etc/init.d/[ service ]  [ start | stop | restart | zap ]`

| 选项（简写） | 选项（全写） | 选项说明                   |
| ------------ | ------------ | -------------------------- |
| -i           | --ifexists   | 如果服务存在，则运行命令   |
| -e           | --exists     | 测试服务是否存在           |
| -l           | --list       | 列出所有可用的服务         |
| -r           | --resolve    | 将服务名称解析为初始化脚本 |

```bash
rc-service sshd start #启动一个服务
rc-service sshd stop  #停止一个服务
rc-service sshd restart #重启一个服务
```



-  **openrc 用于管理不同的运行级：**

| 选项（简写） | 选项（全写） | 选项说明                   |
| ------------ | ------------ | -------------------------- |
| -n           | --no-stop    | 不停止任何服务             |
| -s           | --service    | 运行使用其余参数指定的服务 |
| -S           | --sys        | 输出RC系统类型             |

Alpine Linux可用的运行级: default、sysinit、boot、single、reboot、shutdown.



## Runit使用逻辑

类似OpenRC，Runit的模式也是"在一个文件夹为何service,链接到特定文件夹启动service"。`/etc/runit/sv/*`文件夹中保存了Runit所有可用service，每个service以文件夹的形式呈现，文件夹中不同名称的程序表示不同接口。

启动一个service：创建一个软链接。一般使用runit的linux发行版将启动的服务链接到`/var/service`或`/service`，但在Artix Linux中需要链接到`/run/runit/service`

```text
ln -s /etc/runit/sv/service_name /run/runit/service
```

停用一个service：在service文件夹中创建一个down文件。`touch /path/to/service down`

之后可以使用`sv <up|down|restart|reload|status> <service_name>`控制service

每个service文件夹中至少有一个`run`程序。

- `run`程序可以是直接的可执行文件，也可以是最终会exec进去的启动脚本
- `run`程序不能后台运行，否则runit无法进行追踪

service文件夹也可以包含`finish`和`check`程序以及配置文件`conf`。

- service结束后执行`finish`;
- `check`则是执行`sv check`或`sv status`时调用
- `conf`需要在脚本中显式source，故用其他名称也可

service文件夹中的log文件夹用于处理该service的日志，相当于该service的log service。runit将service文件夹的run程序输出pipe到log文件夹run程序的输入。

service的依赖问题需要在`run`脚本中显式地判断，如`sv check dbus > /dev/null || exit 1`dbus未启动则退出。

Runit的runlevel由`/etc/runit/runsvdir/`文件夹管理，默认有`default`和`single`两个runlevel，可通过创建文件夹自行添加新的runlevel，将service链接到一个runlevel则可以启用service。

当runit启动后还有创建一个`current`runlevel，这是一个软链接，表示当前处在的runlevel。`/run/runit/service`就是`current`的软链接。

```text
/run/runit/service --> /etc/runit/runsvdir/current --> /etc/runit/runsvdir/<runlevel>
```

可以使用`runsvchdir <runlevel>`改变当前runlevel，这会启动该runlevel中的service，但不会停止已启动的service。

更多用法:

- `sv`
- `chpst`
- `runsv`
- `svlogd`
- `runsvchdir`
- `runsvdir`