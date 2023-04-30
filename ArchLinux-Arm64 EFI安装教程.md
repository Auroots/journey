# ArchLinux-Arm64 安装教程

**参考资料**

-   [中科大 Arch Linux ARM 软件源](http://mirrors.ustc.edu.cn/help/archlinuxarm.html) 收录架构 ARMv5, ARMv6, ARMv7, AArch64

-   [Archboot Homepage 镜像下载及教程](https://pkgbuild.com/~tpowa/archboot/web/archboot.html#introduction)

-   [ArchLinux_Wiki - 安装教程](https://wiki.archlinux.org/index.php/Installation_guide_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))

-   [ArchLinux_Wiki - Network](https://wiki.archlinux.org/index.php/Network_configuration_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))

## 自动安装

> Git链接： [Gitee](https://gitee.com/auroot/Auins)   |    [Github](https://github.com/Auroots/Auins)

```bash
# auroot.cn (推荐)
curl -fsSL http://auins.auroot.cn > auin-arm64.sh  
#Gitee
curl -fsSL https://gitee.com/auroot/Auins/raw/master/auin-arm64.sh  > auin-arm64.sh 
# 执行
chmod +x auin.sh && bash auin-arm64.sh 
```



## 手动安装

### 一、验证是否为 UEFI 模式

```shell
ls /sys/firmware/efi/efivars  
```



### 二、检查网络

#### 1. 有线连接

``` Shell
ip link                     #查看网卡设备
ip link set [网卡] up       #开启网卡设备
systemctl start dhcpcd      #开启DHCP服务
wifi-menu                   #连接wifi
```



#### 2. 无线连接

```bash
iwctl                           #执行iwctl命令，进入交互式命令行
device list                     #列出设备名，比如无线网卡看到叫 wlan0
station wlan0 scan              #扫描网络
station wlan0 get-networks      #列出网络 比如想连接YOUR-WIRELESS-NAME这个无线
station wlan0 connect YOUR-WIRELESS-NAME #进行连接 输入密码即可
exit                            #成功后exit退出
```

>   **如果**随后看到类似`Operation not possible due to RF-kill`的报错，继续尝试`rfkill`命令来解锁无线网卡。
>
>   ```bash
>   rfkill unblock wifi
>   ```



### 三、配置源

- **默认镜像源**

```bash
vim /etc/pacman.d/mirrorlist

# 添加以下
Server = https://mirrors.ustc.edu.cn/archlinuxarm/$arch/$repo
```

-   **更新镜像源**

```bash
pacman -Sy
```

> 可能遇到**Unable to lock database**错误，执行下面的命令作为解决方案：
>
> ```bash
> rm /var/lib/pacman/db.lck
> ```



### 四、磁盘分区和挂载

#### 磁盘分配推荐

- **UEFI with [GPT](https://wiki.archlinux.org/title/GPT)**

| **挂载目录**  | **硬盘分区**    | [分区类型](https://en.wikipedia.org/wiki/GUID_Partition_Table#Partition_type_GUIDs) | **分配大小**              |
| ------------- | --------------- | ------------------------------------------------------------ | ------------------------- |
| /mnt/boot/efi | `/dev/sdX[0-9]` | [EFI 引导](https://wiki.archlinux.org/title/EFI_system_partition) | 300 至 512 MiB            |
| [SWAP]        | `/dev/sdX[0-9]` | Swap虚拟内存                                                 | 实际内存 / 2              |
| /mnt          | `/dev/sdX[0-9]` | 根分区                                                       | 剩下所有的，或者40 - 60GB |

> 注：内存超过16GB以上，分配Swap的意义不大，也可以给小一点4G；
>
> 		如果是Gentoo，超过64GB，分配Swap的意义不大；

- **BIOS with [MBR](https://wiki.archlinux.org/title/MBR)** 

| **挂载目录** | **硬盘分区**    | [分区类型](https://en.wikipedia.org/wiki/Partition_type) | **分配大小**              |
| ------------ | --------------- | -------------------------------------------------------- | ------------------------- |
| [SWAP]       | `/dev/sdX[0-9]` | Linux swap                                               | 实际内存 / 2              |
| /mnt         | `/dev/sdX[0-9]` | Linux                                                    | 剩下所有的，或者40 - 60GB |



#### **分区和格式化**

>  [ArchLinux_Wiki - fdisk(分区工具)](https://wiki.archlinux.org/index.php/Fdisk_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))
>
>  [ArchLinux_Wiki - File systems(文件系统)](https://wiki.archlinux.org/index.php/File_systems_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))

```shell
cfdisk /dev/sda  # 指定磁盘

mkfs.vfat  /dev/sdX[0-9]   # efi/esp  fat32  # 指定分区
mkfs.ext4 /dev/sda[0-9]    # ext4     # 指定分区
mkfs.ext3 /dev/sda[0-9]    # ext3     # 指定分区
mkswap /dev/sda[0-9]       # swap     # 指定分区

# 如果你想用其他 File System
# btrfs (/)  需要安装这个包：btrfs-progs
mkfs.btrfs -L [NAME] -f [/dev/DISK]
# f2fs 需要安装这个包：f2fs-tools
mkfs.f2fs [/dev/DISK]
# jfs 需要安装这个包：jfsutils
mkfs.jfs [/dev/DISK]
# reiserfs 需要安装这个包：reiserfsprogs
mkfs.reiserfs [/dev/DISK]
```



#### 挂载分区

```shell
swapon /dev/sd[a-z][0-9]         # 挂着swap 卸载:swapoff
mount /dev/sd[a-z][0-9] /mnt     # 挂着根目录
mkdir -p /mnt/boot/EFI           # 创建efi引导目录
mount /dev/sda1 /mnt/boot/EFI    # 挂着efi分区
```



### 五、安装系统

#### 安装基础包

```shell
pacstrap /mnt base base-devel linux linux-headers linux-firmware
```



#### 生成fstab文件

```shell
genfstab -U /mnt >> /mnt/etc/fstab     # 创建fstab分区表，记得检查
arch-chroot /mnt /bin/bash             # chroot 进入创建好的系统
```



### 六、配置系统

#### 设置时区

```shell
# 设置合适的时区创建符号连接
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime     # 上海

# 将当前的正确 UTC 时间写入硬件时间。
hwclock --systohc       #运行 hwclock 以生成 /etc/adjtime
```



#### 设置Locale进行本地化

```shell
sed  -i "24i en_US.UTF-8 UTF-8" /etc/locale.gen
sed  -i "24i zh_CN.UTF-8 UTF-8" /etc/locale.gen

locale-gen             # 生成 locale
```



#### 系统语言

```shell
echo "LANG=en_US.UTF-8" > /etc/locale.conf       # 英文
echo "LANG=zh_CN.UTF-8" > /etc/locale.conf       # 中文
```



#### 主机名

```shell
echo "Archlinux" > /etc/hostname  #主机名
```

- 在/etc/hosts设置与其匹配的条目
```bash
vim /etc/hosts
# 加入如下内容
127.0.0.1   localhost
::1         localhost
127.0.1.1   myarch
```



#### 创建用户

```shell
useradd -m -g users -G wheel -s /bin/bash [用户名]

passwd [用户名]  #给用户设置密码
passwd root 		# 给root用户设置密码
```

-   **修改sudoers配置文件**

>   大部分情况，如果你不修改sudoers文件，在你进入新系统后，叫无法使用sudo提权，安装软件，或增删改查用户目录以外的文件，当然有root用户密码的话，进入新系统，也可以修改。
>
>   `%wheel ALL=(ALL:ALL) ALL`  指允许`wheel`组的用户使用管理员权限，但每次都需要输入密码；
>
>   `%wheel ALL=(ALL:ALL) NOPASSWD: ALL`  指`wheel`组的用户无需输入密码，就能使用管理员权限；

```bash
vim /etc/sudoers

# 找到以下，并取消注释，
————————————————————————————————————
# %wheel ALL=(ALL:ALL) ALL
————————————————————————————————————
# 或以下，只能选其一
————————————————————————————————————
# %wheel ALL=(ALL:ALL) NOPASSWD: ALL
————————————————————————————————————
```



#### 必须的功能性软件

```bash
pacman -S dhcpcd iwd vim bash-completion networkmanager net-tools
```

>   如果有不需要的，请在安装前自行删除，但有几项是必须安装的，如下：
>
>   `networkmanager`，`dhcpcd`，`vim`，如果你的电脑需要无线连接WIFI，请安装`iwd`



#### 需要开启的服务

```
systemctl enable NetworkManager    #网络服务，不开没网
systemctl start NetworkManager

systemctl enable sshd.service      #SSH远程服务，随意
systemctl start sshd.service
```



#### 配置GRUB

> [ArchLinux_Wiki - GRUB](https://wiki.archlinux.org/index.php/GRUB_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))
>安装grub工具，到这一步，一定要看清楚。

```shell
pacman -S grub efibootmgr

# UEFI分区
grub-install --target=arm64-efi --efi-directory=/boot/efi --bootloader-id=Archlinux

# 生成 GRUB 所需的配置文件
grub-mkconfig -o /boot/grub/grub.cfg

# 弄完重启
exit
reboot now
```

>   编辑/etc/default/grub 文件，去掉`GRUB_CMDLINE_LINUX_DEFAULT`一行中最后的 quiet 参数，同时把 log level 的数值从 3 改成 5。这样是为了后续如果出现系统错误，方便排错。同时在同一行加入 nowatchdog 参数，这可以显著提高开关机速度。



## 七、桌面安装

### Kde Plasma - [ X11 ]

> [ArchLinux_Wiki - KDE](https://wiki.archlinux.org/index.php/KDE_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))  

```bash
# 安装Xorg服务
sudo pacman -S xorg xorg-server xorg-xinit mesa

# 安装桌面环境
sudo pacman -S plasma-desktop plasma-meta konsole sddm sddm-kcm

# 配置Xinitrc
cp /etc/X11/xinit/xinitrc $HOME/.xinitrc
echo "exec startkde" >> $HOME/.xinitrc

# 开启服务
sudo systemctl enable sddm	   # 加入开机自启 
sudo systemctl start sddm	   # 加入开机自启 
```



### Sway - [ Wayland ]

```bash
# 安装 
sudo pacman -S wlroots sway qt5-wayland glfw-wayland
# tty中执行
sway
# sway的配置
cp /etc/sway/config ~/.config/sway/
vim ~/.config/sway/config
	# 设置屏幕和桌面壁纸
	output * bg <你自己的桌面壁纸图片路径> fill
```

**兼容 X11**

```bash
xwayland enabled
# 安装 Xwayland
sudo pacman -S xorg-xwayland 
# 检测 XWayland
sudo pacman -S xorg-xlsclients
> xlsclients
```

**使用vulkan做渲染后端**

```bash
sudo pacman -S vulkan-validation-layers
# 设置启动环境(如果不设置可以用，可以不用设置，我没设置)
vim ~/.pam_environment
	WLR_RENDERER=vulkan
# tty中执行 进入sway(vulkan)桌面
sway
# 如果使用vulkan中遇到问题可以试试这个
vim ~/.pam_environment
	WLR_RENDERER=gles2
```

**免密码登录 service**

```bash
sudo mkdir /etc/systemd/system/getty@tty1.service.d

sudo vim /etc/systemd/system/getty@tty1.service.d/override.conf :
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin <你的用户名> --noclear %I $TERM
Type=idle
```



```bash
vim ~/.config/sway/config ：
    ### Key bindings
    bindsym $mod+p exec wofi --show run
    # bindsym $mod+p exec bemenu-run
```
**firefox**

```
vim ~/.pam_environment ：
	MOZ_ENABLE_WAYLAND=1
```
**fcitx5输入法**

```bash
vim ~/.config/sway/config ：
### Auto start
exec --no-startup-id fcitx5 -d
vim ~/.pam_environment ：

GTK_IM_MODULE DEFAULT=fcitx
QT_IM_MODULE  DEFAULT=fcitx
XMODIFIERS    DEFAULT=@im=fcitx
INPUT_METHOD  DEFAULT=fcitx
SDL_IM_MODULE DEFAULT=fcitx
```
**mpv播放器**

```bash
vim .config/mpv/mpv.conf ：

vo=gpu
gpu-api=vulkan（或opengl）
gpu-context=waylandvk（或wayland）
spirv-compiler=shaderc
vulkan-swap-mode=fifo
vulkan-async-transfer=yes
vulkan-async-compute=yes
```
**屏幕亮度、音量调节**

```bash
sudo pacman -S acpilight（用于Intel核显）
sudo pacman -S alsa-utils alsa-plugins
```
 **配置**
 ```bash
vim ~/.config/sway/config ：
# Set Volumn
bindsym $mod+F1 exec amixer -qM set Speaker toggle
bindsym $mod+F2 exec amixer -qM set Master 2%- unmute
bindsym $mod+F3 exec amixer -qM set Mater 2%+ unmute
bindsym $mod+F4 exec amixer -qM set Headphone toggle

# Set Backlight
bindsym $mod+F5 exec xbacklight -dec 1
bindsym $mod+F6 exec xbacklight -inc 1
 ```
**状态栏waybar，类似于X11下的polybar**

```bash
sudo pacman -S waybar otf-font-awesome

vim ~/.config/sway/config :
bar {
    position top
    swaybar_command waybar
        
    #status_command while date +'%Y-%m-%d %I:%M:%S %p'; do sleep 1; done

    #colors {
        #statusline #ffffff
        #background #323232
        #inactive_workspace #32323200 #32323200 #5c5c5c
    #}
}

```

**启动应用的软件(二选一)**

```bash
sudo pacman -S wofi 			# xorg	 启动应用的软件
sudo pacman -S bemenu-wayland   # wayland启动应用的软件
```



### I3 WM  [ Xorg]


```bash
$ sudo pacman -S i3 #默认回车即可。由于i3-gaps和i3-wm冲突，因此最后实际安装的是i3-gaps，而这正是我所需要的。
$ sudo pacman -S alacritty
$ sudo pacman -S lxappearance
$ sudo pacman -S feh #安装设置壁纸的软件
lxappearance #打开外观配置
feh --bg-fill /this/path/to/your/picture
```

#### 配置i3wm：

输入命令:`xmodmap -pke > ~/.Xmodmap`

> 注：该命令是将键盘布局生成可阅读的文本文件并保存到家目录下。

输入命令:`vim ~/.config/i3/config`，在配置文件中添加下面的内容。

```bash
exec --no-startup-id xrandr -s 1920x1080 #可选项，修改屏幕分辨率
exec xmodmap ~/.Xmodmap #载入当前键盘布局配置文件
bindsym $mod+d exec rofi -show run
bindsym $mod+d exec rofi -show window #该条与上条任选其一
new window 1pixel #窗口仅有1像素单位的边框
gaps inner 15 #窗口边框距离屏幕边缘距离15个单位
```

> 注1：
>
> bindsym表示使用快捷键执行；$mod表示i3下的Super键；
>
> exec表示执行程序；-show run指定为运行程序，-show window指定为显示打开的窗口。故有些情形下两个参数可以混用。
>
> 注2：
>
> 更多其他配置敬请自行探索。我本人的Dotfiles已上传到代码托管平台。

#### 安装窗口渲染器

我安装的是自行编译的compton,为顺利安装compton,先安装系统可能缺少的依赖，命令如下：

```bash
$ sudo pacman -S libconfig asciidoc make #安装相关的依赖
```

不过现在已经出现了`picom`，`Xcompmgr`，而`compton`已经不再维护，有需要的完全可以通过官方库安装它们。

```bash
$ git clone https://github.com/tryone144/compton.git
$ cd /path/to/compton #切换到克隆的compton库文件夹中
$ make #可能会有一些警告，忽略
$ make docs #这是可选的，制作帮助文档，使用man compton获取。
$ make clean install #clean是可选参数，可以不加
```

在克隆的`compton`库中有一份配置文件模版，将之拷贝到用户个人的配置文件夹里，并在编译成功之后即可配置该文件：

```bash
$ cp compton.sample.conf ~/.config/compton.conf
$ vim ~/.config/compton.conf
```

#### 安装自定义计算机状态栏

我使用的是polybar，如果你喜欢i3status，可以不安装polybar。

```bash
$ sudo pacman -S cmake git python python2 pkg-config wireless_tools 
#安装polybar构建所需的依赖
$ yay -S polybar
```

下面是最重要也是最困难的部分：安装字体。

```bash
$ yay -S tty-unifont siji-git
```

> 此处的困难是对于网络而不是技术层面上来说的，由于软件包取自AUR，速度极慢，极易失败。

新安装的polybar需要拷贝一份配置文件，然后自行修改polybar的配置文件进行配置。

```bash
$ cd ~/.config
$ mkdir polybar
$ cp /usr/share/doc/polybar/config ~/.config/polybar/ #将配置文件拷贝到用户当前目录下
```

默认polybar的名称为example，载入polybar的命令为：

```bash
$ polybar example
```

默认在i3wm中设置自动启动的办法：

```bash
$ exec_always polybar example &
```



## 安装驱动

**蓝牙**
[ArchLinux_Wiki - 蓝牙](https://wiki.archlinux.org/index.php/Bluetooth_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))

```shell
sudo pacman -S bluez bluez-utils blueman  bluedevil

sudo systemctl start bluetooth.service
sudo systemctl enable bluetooth.service
```

**音频**

```shell
sudo pacman -S pulseaudio-bluetooth alsa-utils
sudo vim /etc/pulse/system.pa

load-module module-bluetooth-policy
load-module module-bluetooth-discover                     
```

#### 打印机驱动

[ArchLinux_Wiki - CUPS](https://wiki.archlinux.org/index.php/CUPS_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))

CUPS 是苹果公司为Mac OS® X 和其他类 UNIX® 的操作系统开发的基于标准的、开源的打印系统.
首先要安装这5个包```sudo pacman -S cups ghostscript gsfonts gutenprint cups-usblp```

- ```samba```        如果系统用的 Samba 使用网络打印机，或者要作为打印服务器向其它windows客户端提供服务，你还需要安装
- ```cups```         就是传说中的CUPS软件```
- ```ghostscript```  Postscript语言的解释器```
- ```gsfonts```      Ghostscript标准Type1字体```
- ```hpoj```         HP Officejet, 你应该再安装这个包```

#### 手机文件系统支持

```
sudo pacman -S mtpaint mtpfs libmtp 
Gnome ： gvfs-mtp 
Kde ：kio-extras
```

-------------------------------------------------------------------------------

### 安装电池选项

TLP，提供优秀的 Linux 高级电源管理功能,不需要你了解所有的技术细节。默认配置已经对电池使用时间进行了优化，只要安装即可享受更长的使用时间。除此之外，TLP 也是高度可配置的，可以满足各种特定需求。

参考[官方文档](https://endlesspeak.github.io/docs/build/operating-system-configuration/linux-technology-5-1-desktop-config/gitHub.com/linrunner/TLP)，等待补充。

```bash
$ sudo pacman -S tlp
```



## 常用软件

```bash
sudo pacman -S vim git wget zsh  dosfstools man-pages-zh_cn create_ap p7zip file-roller unrar neofetch openssh linux-headers
sudo pacman -S paru					# AUR包管理器
sudo paru -S google-chrome        	# 谷歌浏览器
sudo pacman -S chromium				# 谷歌浏览器
sudo pacman -S firefox              # 火狐浏览器
sudo pacman -S xpdf                 # 安装pdf阅读器
sudo pacman -S cowsay               # 牛的二进制图形（/usr/share/cows）
sudo pacman -S deepin-movie         # 深度影院
sudo pacman -S deepin-screenshot    # Deepin 截图
sudo pacman -S deepin-image-viewer  # Deepin 图片浏览器      
sudo pacman -S netease-cloud-music  # 网易云音乐
sudo pacman -S iease-music          # 第三方网易云音乐
sudo pacman -S remmina              # 好用远程工具
sudo pacman -S filelight            # 可视化 磁盘使用情况
sudo pacman -S wine-wechat        	# Wine集成的Windows平台的微信
sudo pacman -S wine-mono 			# wine-wechat可能需要安装wine-mono字体
sudo pacman -S transmission-qt    	# 基于Qt的图形化界面的Transmission
sudo pacman -S transmission-gtk   	# 基于GTK的图形化界面的Transmission
sudo pacman -S qbittorrent			# qBittorrent BT下载工具
sudo pacman -S gparted 				# Gparted 磁盘无损分区工具
sudo pacman -S acpi 				# 电池状况监控工具
sudo pacman -S xarchiver 			# Xarchiver 图形化的解压缩软件
sudo pacman -S virtualbox           # virtualbox 虚拟机
sudo pacman -S vmware-workstation   # vmware 虚拟机
sudo pacman -S virtualbox-guest-utils # VirtualBox 拓展
# AUR
paru -S vundle-git           # 安装vim的插件管理器
paru -S deepin.com.qq.office # TIM
paru -S deepin.com.qq.im	 # QQ
paru -S deepin-wechat        # 微信
paru -S electronic-wechat    # 基于Electron的微信，本质上是网页版的微信
paru -S wps-office           # wps
paru bash-complete-alias     # 增强自动补全功能

https://github.com/xtuJSer/CoCoMusic/releases   # QQ音乐  CoCoMusic
sudo mandb                          	# 中文的man手册，更新关键词搜索需要的缓存
```



### 安装中文输入法

[ArchLinux_Wiki - Fcitx](https://wiki.archlinux.org/index.php/Fcitx_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))

如果安装的是中州韵、谷歌拼音、sun拼音、cloud拼音等非搜狗输入法，具体命令如下：

```bash
sudo pacman -S fcitx fcitx-im fcitx-configtool #输入法框架及管理器
sudo pacman -S fcitx-rime #中州韵输入法
sudo pacman -S fcitx-cloudpinyin #cloud拼音输入法
```

> 注：可以用这些输入法组合搜狗输入法的词库，相比直接使用搜狗拼音输入法来说，稳定性更好。

注：据说Gnome(GTK)用户要安装fcitx-qt5，其可选依赖于fcitx-configtool；而KDE(QT)用户则需要安装软件包kcm-fcitx；该包中包含qt5；如果完全根据情境安装，非常复杂，我的建议是：小孩子才做选择，大人我全都要。遇到软件包冲突后再根据提示进行卸载操作。

编辑相关文档：

```bash
$ vim /home/<username>/.xprofile #激活fcitx和桌面环境语言设定
```

编辑内容如下：

```bash
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS="@im=fcitx"
```

> 注1：`.xprofile`文件生成后需要注销或重启级别的操作才能生效。未生成该文件或该文件未生效，则中文输入法不会出现汉字候选框。
>
> 注2：如果提示搜狗拼音输入法出现问题，请按提示删除`~/.config/sogouPY*`两个文件夹后重启`fcitx`。

### 安装中文字体包及emoji

> [ArchLinux_Wiki -  字体](https://wiki.archlinux.org/index.php/Fonts_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))
>
> 全部安装：'MesloLGS NF', 'monospace', monospace dd

```bash
# Emoji安装
sudo pacman -S ttf-linux-libertine ttf-inconsolata ttf-joypixels ttf-twemoji-color noto-fonts-emoji ttf-liberation ttf-droid   
# 中文字体
sudo pacman -S wqy-bitmapfont wqy-microhei wqy-microhei-lite wqy-zenhei adobe-source-han-sans-cn-fonts adobe-source-han-serif-cn-fonts ttf-dejavu 
# noto 字体
sudo pacman -S noto-fonts noto-fonts-extra noto-fonts-emoji noto-fonts-cjk 
# code 字体
sudo pacman -S ttf-fira-code ttf-fira-mono ttf-fira-sans woff-fira-code woff2-fira-code
# Ubuntu 字体 
sudo pacman -S ttf-ubuntu-font-family
git clone https://gitee.com/auroot/ubuntu-mono-powerline-ttf.git ~/.fonts/ubuntu-mono-powerline-ttf
fc-cache -vf
# WPS 中文字体
sudo pacman -S wps-office-mui-zh-cn
```

- 配置环境 把下面的加入到`/.xporfile

```shell
sudo vim /etc/profile 

export GTK2_RC_FILES="$HOME/.gtkrc-2.0"
export LC_CTYPE=zh_CN.UTF-8
export XMODIFIERS=@im=fcitx
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
fcitx -d -r --enable sogou-qimpanel
```

```shell
sudo vim /etc/environment
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
```

- 终端运行qtconfig-qt4找到interface选项,在下面的 Defult Input Method 改为fcitx然后保存退出 ` source /etc/profile` 重启。

#### 终端常用软件

关于它们各自的配置以后会提到，这些工具都是完全自定义化的，首先应该参考它们的官方文档。

1. 文件管理器`Ranger`
2. 系统硬件查看器`neofetch`或`screenfetch`
3. 系统资源查看工具`htop`
4. 使用图形渲染的终端模拟器`alacritty`
5. 展示目录下的文件工具`tree`
6. 展示本地或远程的包的结构工具`pactree`
7. 解压缩软件`zip`
8. 将终端输出的内容重定向到剪切板工具`xsel`
9. 终端下的`Todo List`工具`task`
10. 终端命令代理`privoxy`或`proxychains`
11. 来自`Suckless`社区中`X`下的极简终端模拟器st

```bash
$ sudo pacman -S ranger neofetch htop alacritty tree pactree zip task privoxy
$ git clone https://git.suckless.org/st   # 克隆源代码的仓库
$ cd st/
$ sudo make clean install                 # 编译安装
```



##### Z Shell

###### 安装Z shell

```bash
sudo pacman -S zsh
```

然后在终端中运行命令：

```bash
cd /path/to/install.sh  #注意先切换到文件存放位置
./install.sh #再运行安装脚本，即可从码云镜像站下载oh-my-zsh的源代码。
```

**方法二**：先克隆整个项目到~/.config/oh-my-zsh。克隆命令如下：

```bash
 git clone -c core.eol=lf -c core.autocrlf=false \
	 -c fsck.zeroPaddedFilemode=ignore \
     -c fetch.fsck.zeroPaddedFilemode=ignore \
	 -c receive.fsck.zeroPaddedFilemode=ignore \
	 --depth=1 --branch "master" https://gitee.com/mirrors/oh-my-zsh ~/.oh-my-zsh
```

然后对仓库中的install.sh脚本进行修改：删去main函数中调用setup_oh-my-zsh函数的行。

```bash
cd /path/to/install.sh  #注意先切换到文件存放位置
./install.sh #再运行安装脚本，即可从码云镜像站下载oh-my-zsh的源代码。
```

###### 配置Oh-my-zsh



**修改Oh-my-zsh的主题**

```bash
vim  ~/.zshrc
ZSH_THEME="robbyrussel"
```



**自动提示与命令补全**

```bash
git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
```

打开 `~/.zshrc` 文件，找到插件设置命令，修改为

```text
- plugins=(git)
+ plugins=(zsh-autosuggestions git)
```



**语法高亮**

```bash
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting

- plugins=( [plugins...])
+ plugins=( [plugins...] zsh-syntax-highlighting) 
```

如果语法高亮不生效，则考虑zsh-syntax-highlighting放置在插件列表的最后以解决问题。以下是官方文档说明：

> **Why must `zsh-syntax-highlighting.zsh` be sourced at the end of the `.zshrc` file?**
>
> `zsh-syntax-highlighting.zsh` wraps ZLE widgets. It must be sourced after all custom widgets have been created (i.e., after all `zle -N`calls and after running `compinit`). Widgets created later will work, but will not update the syntax highlighting.

> 另一个魔改版：命令正确绿色高亮,错误红色高亮
>
> ``` bash
> git clone https://github.com/jimmijj/zsh-syntax-highlighting $ZSH_CUSTOM/plugins/zsh-syntax-highlighting



**快速切换路径**

插件使你能够快速切换路径，再也不需要逐个敲入目录，只需敲入目标目录，就可以迅速切换目录。

```bash
git clone https://github.com/wting/autojump.git
./install.py  
# 在～/.zshrc文件中加入此句
[[ -s ~/.autojump/etc/profile.d/autojump.sh ]] && . ~/.autojump/etc/profile.d/autojump.sh  
```



**加强zsh的补全功能实现tab自动纠错**

```bash
vim ~/.oh-my-zsh/lib/completion.zsh
zstyle ':completion:incremental:*' completer _complete _correct
zstyle ':completion:*' completer _complete _prefix _correct _prefix _match _approximate
```

**使配置生效**

```bash
$ source ~/.zshrc
```



#### 命令行代理

**[proxychains ](https://github.com/haad/proxychains )** 

[proxychains-ng](https://github.com/rofl0r/proxychains-ng)

**安装配置 proxychains**

```bash
sudo pacman -S proxychains

# 配置文件 
vim /etc/proxychains.conf
# 最后一行改为, 后面那个数字要和本地端口一致
	[ProxyList]
    socks4 	127.0.0.1 1089
    http	127.0.0.1 8889
```



#### Backarch源

- ###  清华

```
echo '' >> /etc/pacman.conf
echo '[blackarch]' >> /etc/pacman.conf
echo 'SigLevel = Optional TrustAll' >> /etc/pacman.conf
echo 'Server = https://mirrors.tuna.tsinghua.edu.cn/blackarch/$repo/os/$arch' >> /etc/pacman.conf
```

```
    sudo pacman -Syu yaourt yay
    sudo pacman -Syu archlinuxcn-keyring
```

-------------------------------------------------------------------------------