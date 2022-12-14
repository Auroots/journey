# Linux小问题指南

#### 创建自定义目录

本地的 `~/.config/user-dirs.dirs` 和全局的 `/etc/xdg/user-dirs.defaults` 配置文件都使用如下的环境变量格式： `XDG_DIRNAME_DIR="$HOME/目录名"`。

```bash
~/.config/user-dirs.dirs
XDG_DESKTOP_DIR="$HOME/桌面"
XDG_DOCUMENTS_DIR="$HOME/文档"
XDG_DOWNLOAD_DIR="$HOME/下载"
XDG_MUSIC_DIR="$HOME/音乐"
XDG_PICTURES_DIR="$HOME/图片"
XDG_PUBLICSHARE_DIR="$HOME/公共"
XDG_TEMPLATES_DIR="$HOME/模板"
XDG_VIDEOS_DIR="$HOME/视频"
```

Linux本地化后目录都会是中文，而我想将其改为英文，故我应该先将`~/.config/user-dirs.dirs`中的内容改为如下形式：

```bash
~/.config/user-dirs.dirs
XDG_DESKTOP_DIR="$HOME/Desktop"
XDG_DOCUMENTS_DIR="$HOME/Documents"
XDG_DOWNLOAD_DIR="$HOME/Downloads"
XDG_MUSIC_DIR="$HOME/Music"
XDG_PICTURES_DIR="$HOME/Pictures"
XDG_PUBLICSHARE_DIR="$HOME/Public"
XDG_TEMPLATES_DIR="$HOME/Templetes"
XDG_VIDEOS_DIR="$HOME/videos"
```

##### 禁用IPV6

一是输入下列三个命令将Linux上的ipv6全部禁用即可。

```bash
$ sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
$ sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1
$ sudo sysctl -w net.ipv6.conf.lo.disable_ipv6=1
```

> 注：这种方法是永久禁用；禁用后开启很简单，把命令的1改为0即可。

第二种禁用IPV6的办法是：写文件以禁用

```bash
$ sudo sh -c 'echo 1 > /proc/sys/net/ipv6/conf/<interface-name>/disable_ipv6'
```

举个例子，你的Linux通过eth0接口访问网络，那么禁用IPv6代码如下:

```bash
$ sudo sh -c 'echo 1 > /proc/sys/net/ipv6/conf/eth0/disable_ipv6'
```

重新启用eth0接口的IPv6：

```bash
$ sudo sh -c 'echo 0 > /proc/sys/net/ipv6/conf/eth0/disable_ipv6'
```

如果你想要将整个系统所有接口包括回环接口禁用IPv6，使用以下命令：

```bash
$ sudo sh -c 'echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6'
```

注：这种方法不是永久禁用IPv6，你一旦重启系统IPv6还是会被启用。

三是在开机的时候传递一个必要的内核参数：

这种实现思路与开源驱动nouveau在开机的时候自动禁用同理。

> Manjaro Linux和Arch Linux在具有独显却未安装独显驱动的时候，需要在boot的时候按`e`，在第一个`quiet`字符串后面输入一串开机神秘代码：`nouveau.modest=0`；或者将之保存到`grub.cfg`文件中。

输入下面的命令编辑文件：

```bash
$ vim /boot/grub/grub.cfg
```

向文件中添加如下内容：

```bash
GRUB_CMDLINE_LINUX="xxxxx ipv6.disable=1"
```

上面的"xxxxx"代表任何已有的内核参数，注意是在它后面添加"ipv6.disable=1"。修改完后，使用下面的命令保存对grub的更改(这应该是可选的)。

```bash
$ sudo update-grub #Debian，Ubuntu，Linux Mint，Arch Linux系统使用该命令
$ sudo grub2-mkconfig -o /boot/grub2/grub.cfg #Fedora、CentOS/RHEL系统：
```

现在只要你重启你的Linux系统，IPv6就会完全被禁用。重新开启的方法也很简单，就是从文件中将此参数删去。

##### http代理

安装privoxy，并查看默认监听端口。

```bash
$ pacman -S privoxy
$ vim /etc/privoxy/config
```

在文件中搜索搜索listen-address，默认为：

```bash
listen-address 127.0.0.1:8118
```

输入下面的命令启动privoxy

```bash
$ systemctl start privoxy
```

然后设置http代理：即在QQ/TIM的登录界面点击右上角的设置，然后选择http代理，输入之前记录下的信息和端口，默认为127.0.0.1和8118。再登录就能看到图片和头像了。









