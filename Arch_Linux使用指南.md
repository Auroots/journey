# Arch Linux + Desktop 攻略

![脚本截图信息](https://gitee.com/auroot/arch_wiki/raw/master/Img/archlinux/img1.png?raw=true)



#### 连引导都进不去？ 

>  进入grub菜单后，选择启动项，按e进入启动参数设置，搜索第一个`quiet`并在后面加入以下需要的一列，可以每条都试试： 

```shell
nouveau.modeset=0    # 屏蔽开源 对独显有效
acpi_osi=! acpi_osi="Windows 2009"  # 欺骗BIOS以Windows 2009启动，对ACPI错误有效
driver=intel acpi_osi=! acpi_osi='Windows 2009'    
```
## **自动安装**

> Git链接： [Gitee](https://gitee.com/auroot/Auins)   |    [Github](https://github.com/Auroots/Auins)

```bash
# auroot.cn (推荐)
curl -fsSL http://auins.auroot.cn > auin.sh  
#Gitee
curl -fsSL https://gitee.com/auroot/Auins/raw/master/auin.sh > auin.sh
# Github
curl -fsSL https://raw.githubusercontent.com/Auroots/Auins/main/auin.sh > auin.sh
# 执行
chmod +x auin.sh && bash auin.sh
```


## **手动安装**

[ArchLinux_Wiki - 安装教程](https://wiki.archlinux.org/index.php/Installation_guide_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))

### 一、验证启动模式

```shell
ls /sys/firmware/efi/efivars  
```

### 二、检查网络

[ArchLinux_Wiki - Network](https://wiki.archlinux.org/index.php/Network_configuration_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))

``` Shell
ip link                     #查看网卡设备
ip link set [网卡] up       #开启网卡设备
systemctl start dhcpcd      #开启DHCP服务
wifi-menu                   #连接wifi

```

### 三、配置源

- **默认镜像源**

```bash
vim /etc/pacman.d/mirrorlist

## China
Server = https://mirrors.bfsu.edu.cn/archlinux/$repo/os/$arch
Server = https://mirrors.sjtug.sjtu.edu.cn/archlinux/$repo/os/$arch
Server = https://mirrors.nju.edu.cn/archlinux/$repo/os/$arch
Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/$repo/os/$arch
Server = https://mirrors.aliyun.com/archlinux/$repo/os/$arch
Server = https://repo.huaweicloud.com/archlinux/$repo/os/$arch
Server = https://mirrors.163.com/archlinux/$repo/os/$arch
Server = http://mirrors.163.com/archlinux/$repo/os/$arch
Server = http://mirrors.tuna.tsinghua.edu.cn/archlinux/$repo/os/$arch
```

- **Archlinuxcn镜像源**

> 一般国区软件，都会在这个源里。

``` shell
vim /etc/pacman.conf
# 写入
[archlinuxcn]
SigLevel = Never #或者Optional TrustedOnly
Include = /etc/pacman.d/archlinuxcn
#==========================================================================

# 编辑archlinuxcn源
vim /etc/pacman.d/archlinuxcn
# 写入
## 浙江大学 (浙江杭州) (ipv4, ipv6, http, https)
## Added: 2017-06-05[archlinuxcn]
Server= https://mirrors.zju.edu.cn/archlinuxcn/$arch
## 中国科学技术大学 (ipv4, ipv6, http, https)[archlinuxcn]
Server= https://mirrors.ustc.edu.cn/archlinuxcn/$arch
## 上海科技大学 (上海) (ipv4, http, https)
## Added: 2016-04-07[archlinuxcn]
Server= https://mirrors-wan.geekpie.org/archlinuxcn/$arch
## 重庆大学 (ipv4, http)[archlinuxcn]
Server= http://mirrors.cqu.edu.cn/archlinuxcn/$arch
#==========================================================================

# 最后
pacman -S archlinux-keyring #安装源密钥
pacman -S archlinuxcn-keyring #安装CN密钥
sudo pacman -Sy
```

> 可能遇到**Unable to lock database**错误，执行下面的命令作为解决方案：
>
> ```bash
> rm /var/lib/pacman/db.lck
> ```



### 四、磁盘分区和挂载

##### 磁盘分配推荐

- **UEFI with [GPT](https://wiki.archlinux.org/title/GPT)**

| **挂载目录**  | **硬盘分区**    | [分区类型](https://en.wikipedia.org/wiki/GUID_Partition_Table#Partition_type_GUIDs) | **分配大小**              |
| ------------- | --------------- | ------------------------------------------------------------ | ------------------------- |
| /mnt/boot/efi | `/dev/sdX[0-9]` | [EFI 引导](https://wiki.archlinux.org/title/EFI_system_partition) | 300 至 512 MiB            |
| [SWAP]        | `/dev/sdX[0-9]` | Swap虚拟内存                                                 | 实际内存 / 2              |
| /mnt          | `/dev/sdX[0-9]` | 根分区                                                       | 剩下所有的，或者40 - 60GB |

> 注：内存超过16GB以上，分配Swap的意义不大，也可以给小一点4G；
>
> ​		如果是Gentoo，超过64GB，分配Swap的意义不大；

- **BIOS with [MBR](https://wiki.archlinux.org/title/MBR)** 

| **挂载目录** | **硬盘分区**    | [分区类型](https://en.wikipedia.org/wiki/Partition_type) | **分配大小**              |
| ------------ | --------------- | -------------------------------------------------------- | ------------------------- |
| [SWAP]       | `/dev/sdX[0-9]` | Linux swap                                               | 实际内存 / 2              |
| /mnt         | `/dev/sdX[0-9]` | Linux                                                    | 剩下所有的，或者40 - 60GB |

##### **分区和格式化**
>  [ArchLinux_Wiki - fdisk(分区工具)](https://wiki.archlinux.org/index.php/Fdisk_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))
>
> [ArchLinux_Wiki - File systems(文件系统)](https://wiki.archlinux.org/index.php/File_systems_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))

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

##### 挂载分区

```shell
swapon /dev/sd[a-z][0-9]         # 挂着swap 卸载:swapoff
mount /dev/sd[a-z][0-9] /mnt     # 挂着根目录
mkdir -p /mnt/boot/EFI           # 创建efi引导目录
mount /dev/sda1 /mnt/boot/EFI    # 挂着efi分区
```



### 五、安装系统

```shell
pacstrap /mnt base base-devel linux linux-firmware ntfs-3g networkmanager os-prober net-tools
```

```shell
genfstab -U /mnt >> /mnt/etc/fstab     # 创建fstab分区表，记得检查
arch-chroot /mnt /bin/bash             # chroot 进入创建好的系统
```

### 六、配置系统

**设置时区**

```shell
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime     # 上海

hwclock --systohc --utc       #运行 hwclock 以生成 /etc/adjtime
```

**本地化**

```shell
sed  -i "24i en_US.UTF-8 UTF-8" /etc/locale.gen
sed  -i "24i zh_CN.UTF-8 UTF-8" /etc/locale.gen

locale-gen             # 生成 locale
```

**系统语言** 

```shell
echo "LANG=en_US.UTF-8" > /etc/locale.conf       # 英文
echo "LANG=zh_CN.UTF-8" > /etc/locale.conf       # 中文
```

**主机名**

```shell
echo "Archlinux" > /etc/hostname  #主机名
passwd                 #给root设置密码
mkinitcpio -p linux    
```

**创建用户**

```shell
useradd -m -g users -G wheel -s /bin/bash [用户名]
passwd [用户名]           #给用户设置密码
```

**需要开启的服务**

```
systemctl enable NetworkManager    #网络服务，不开没网
systemctl start NetworkManager

systemctl enable sshd.service      #SSH远程服务，随意
systemctl start sshd.service
```

**配置GRUB**

> [ArchLinux_Wiki - GRUB](https://wiki.archlinux.org/index.php/GRUB_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))
>
> 执行passwd 给root设置一个密码。
> 安装grub工具，到这一步，一定要看清楚。

```shell
pacman -S vim grub efibootmgr
# 最后
#  UEFI分区
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=Archlinux
#  Boot 分区
grub-install --target=i386-pc /dev/sdX(Boot分区地址)
# 以上二选一后,执行下面的命令!
grub-mkconfig -o /boot/grub/grub.cfg

# 弄完重启
exit
swapoff /dev/sd[a-z][0-9]      #卸载swap
umount -R /mnt && reboot now   #卸载 根分区、efi分区
```

-------------------------------------------------------------------------------



## 安装驱动

**intel 显示驱动**
[ArchLinux_Wiki - Intel显卡](https://wiki.archlinux.org/index.php/Intel_graphics_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))

```shell
pacman -S xf86-video-intel mesa-libgl libva-intel-driver libvdpau-va-gl
```

**触摸板驱动**

```shell
sudo pacman -S xf86-input-libinput xf86-input-synaptics 
```

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

- 所有Video 驱动:

```
xf86-video-amdgpu                   
xf86-video-ati                      
xf86-video-dummy                    
xf86-video-fbdev                    
xf86-video-intel                    
xf86-video-nouveau                  
xf86-video-openchrome               
xf86-video-sisusb                   
xf86-video-vesa                     
xf86-video-vmware                   
xf86-video-voodoo                   
xf86-video-qxl
```

**安装I\O驱动**

```shell
sudo pacman -S xf86-input-keyboard xf86-input-mouse xf86-input-synaptics
```

- 其他I\O驱动

```
xf86-input-elographics                     
xf86-input-evdev                           
xf86-input-libinput                        
xf86-input-synaptics    
xf86-input-vmmouse      (VMWare)           
xf86-input-void                            
xf86-input-wacom                           
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

#### **Nvidia 显示驱动**

- [Optimus-switch - 解决方案](https://github.com/dglt1)

- [Optimus-manager-qt - 解决方案(自用推荐)](https://github.com/Shatur95/optimus-manager-qt)

- 可能需要开启AUR源 
- 可能需要开启软件源 [multilib]

```
pacman -S nvidia
```

如果是使用NVIDIA闭源驱动，则使用下列命令编辑启动管理器的脚本：

```bash
sudo vim /usr/share/sddm/scripts/Xsetup
# 写入
xrandr --setprovideroutputsource modesetting NVIDIA-0
xrandr --auto
```

输入下列命令获知本机的显卡型号及PCI地址：

```bash
lspci -k | grep -A 2 -E "(VGA|3D)"
```

在该文件(没有会自动创建一个)中输入下列内容：

```bash
sudo vim /etc/X11/xorg.conf
# 写入
Section "Module"
	Load "modesetting"
EndSection

Section "Device"
	Indentifier "nvidia"
	Driver "nvidia"
	BusID "1:0:0" #填入刚才获得的显卡PCI地址，注意每部分均为个位数
	Option "AllowEmptyInitialConfiguration"
EndSection
```

配置以上部分，重启之后Arch Linux应该就能顺利进入`sddm`登录管理器了。

**问题：配备`intel`集成显卡和`NVIDIA`独立显卡的机器登入图形界面时机器挂起/关机**

首先，需要注明的是，这是Linux对于`NVIDIA`显卡驱动支持不完善的问题引起的。但硬件驱动支持不完善是典型的**上游错误**(NVIDIA显卡没有发挥它的作用是NVIDIA团队的问题，而不是Arch开发者的责任)。

如果不启动图形界面，只用`tty`，是没有问题的。

解决方法：

- 如果你将你的`Display Manager`加入了守护进程(即每次会自动登入`Display Manager`)，那么我目前能想到的方法是使用`Live CD`，将你的Arch Linux挂载在`Live CD`上，然后使用`arch-chroot`操作。
- 如果你开机进入的是`tty`(即你每次都是手动启动图形界面)，那么就按照平时在终端中的操作来进行操作即可。
- 操作如下：

```bash
$ sudo pacman -S bumblebee   # 安装bumblebee
$ sudo nano /etc/modprobe.d/modprobe.conf
#在文件中添加“options nvidia NVreg_Mobile=1”，然后保存退出，重启机器
```

**安装测试软件  在图形界面下**

```
[auroot@Arch ~]# sudo pacman -S virtualgl
[auroot@Arch ~]# optirun glxspheres64

#查看NVIDIA显卡是否已经启动
[auroot@Arch ~]# nvidia-smi
```



## 桌面安装

### Deepin [Xorg]

>  [ArchLinux_Wiki - DEEPIN](https://wiki.archlinux.org/index.php/Deepin_Desktop_Environment_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))

```bash
sudo pacman -S xorg xorg-server xorg-xinit mesa	# 安装Xorg 
sudo pacman -S deepin deepin-extra	#安装桌面环境
sudo pacman -S lightdm	# 显示管理器

# 配置管理器
vim /etc/lightdm/lightdm.conf
  greeter-session=example-gtk-gnome       # 用VIM 找到这个
  greeter-session=lightdm-deepin-greeter  # 替换为这个
  
# 配置Xinitrc
cp /etc/X11/xinit/xinitrc $HOME/.xinitrc
echo "exec startdde" >> $HOME/.xinitrc

# 开启服务
sudo systemctl enable lightdm  	# 加入开启启动
sudo systemctl start lightdm	# 立即启动
```

-------------------------------------------------------------------------------



### Kde  [ Xorg]

> [ArchLinux_Wiki - KDE](https://wiki.archlinux.org/index.php/KDE_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))  

```bash
# 安装桌面环境
sudo pacman -S xorg xorg-server xorg-xinit mesa	# 安装Xorg  
sudo pacman -S plasma kde-applications-meta #完整包（不推荐）
sudo pacman -S plasma-desktop plasma-meta konsole #简包（推荐）
sudo pacman -S sddm sddm-kcm  # 显示管理器

# 配置Xinitrc
cp /etc/X11/xinit/xinitrc $HOME/.xinitrc
echo "exec startkde" >> $HOME/.xinitrc

# 开启服务
sudo systemctl enable sddm	   # 加入开机自启 
sudo systemctl start sddm	   # 加入开机自启 
```

-------------------------------------------------------------------------------



### Gnome  [ Xorg]

> [ArchLinux_Wiki - GNOME](https://wiki.archlinux.org/index.php/GNOME_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))

```bash
sudo pacman -S xorg xorg-server xorg-xinit mesa	# 安装Xorg  
sudo pacman -S mesa gnome gdm	# 安装桌面

# 配置Xinitrc
cp /etc/X11/xinit/xinitrc $HOME/.xinitrc
echo "exec gnome=session" >> $HOME/.xinitrc

# 开启服务
sudo systemctl enable gdm	   # 加入开机自启 
sudo systemctl start gdm	   # 加入开机自启 
```

> 进入登录界面后，设置为以 GNOME no Xorg模式登入（推荐）

```bash
美化地址：https://www.pling.com/s/Gnome
         https://www.opencode.net/explore/projects
安装插件需要的软件：
sudo pacman -S gnome-tweaks gnome-shell-extensions
```

> **Gnome 插件**
>
> Arch Linux Updates Indicator    archlinux软件更新检测插件,需要配合pacman-contrib使用
> Caffeine                        防止自动挂起
> Clipboard Indicator             一个剪贴板
> Coverflow Alt-Tab               更好的窗口切换
> Dash to Dock                    把dash栏变为一个dock
> Dynamic Top Bar                 顶栏透明化
> Extension Update Notifier       gnome插件更新提示
> GnomeStatsPro                   一个系统监视器
> system-monitor                  又一个系统监视器
> Night Light Slider              调节gnome夜间模式的亮度情况
> OpenWeather                     天气插件
> Proxy Switcher                  代理插件
> Random Wallpaper                自动切换壁纸,
> Simple net speed                网速监测
> Sound Input & Output Device Chooser 声音设备选择
> Status Area Horizontal Spacing  让顶栏更紧凑
> Suspend Button                  添加一个休眠按钮
> TopIcons Plus                   把托盘图标放到顶栏
> Window Is Ready - Notification Remover      去除烦人的window is ready提醒



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



### DWM  [ Xorg]

> [Repositories (suckless.org)](https://git.suckless.org/)
>
> [software that sucks less | suckless.org software that sucks less](https://suckless.org/)



```bash
sudo pacman -S xorg xorg-server xorg-xinit mesa	# 安装Xorg  
sudo pacman -S feh udisks2 udeskie pcmanfm
```



```bash
sudo emerge -av x11-base/xorg-server x11-base/xorg-apps x11-base/xorg-drivers
sudo emerge -av sys-fs/udisks sys-fs/udiskie 
sudo emerge -av x11-misc/pcmanfm media-gfx/feh
```



```bash
# 配置Xinitrc
cp /etc/X11/xinit/xinitrc $HOME/.xinitrc
# 删除
- if [ -n "$failsafe" ]; then
- 	twm &
-	xclock -geometry 50x50-1+1 &
-	xterm -geometry 80x50+494+51 &
-	xterm -geometry 80x20+494-0 &
-	exec xterm -geometry 80x66+0+0 -name login
- else
-	exec $command
- fi

# 添加
exec dwm
```



```bash
git clone https://git.suckless.org/dwm
git clone https://git.suckless.org/dmenu
git clone https://git.suckless.org/st
git clone https://git.suckless.org/slstatus
```



```bash
cd ./dwm
sudo make clean install
```



```bash
xrandr -q  # 查看当前显示模式信息

xrandr --output [输出地址] --mode 1920x1080 --rate 60.00
```



### Sway  [ Wayland ]

>   -   [Sway](https://swaywm.org/) 一个平铺式窗口管理器。
>   -   [Waybar](https://github.com/Alexays/Waybar) 一个与 [Polybar](https://github.com/polybar/polybar) 非常相似的状态条。
>   -   [Wofi](https://hg.sr.ht/~scoopta/wofi) 一个纯 GTK（也就是 Wayland）的可定制应用程序启动器。
>   -   [Alacritty](https://github.com/alacritty/alacritty) 一个现代化的终端，”又不是不能用”。

```bash
# 安装 
sudo pacman -S wlroots sway qt5-wayland glfw-wayland waybar wofi
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
sudo pacman -S qbittorrent					# qBittorrent BT下载工具
sudo pacman -S gparted 							# Gparted 磁盘无损分区工具
sudo pacman -S acpi 								# 电池状况监控工具
sudo pacman -S xarchiver 						# Xarchiver 图形化的解压缩软件
sudo pacman -S virtualbox           # virtualbox 虚拟机
sudo pacman -S vmware-workstation   # vmware 虚拟机
sudo pacman -S virtualbox-guest-utils # VirtualBox 拓展
sudo pacman -S qview	 							# 超简洁看图软件
sudo pacman -S flameshot 						# 截图工具
sudo pacman -S redshift							# 护眼工具，需要额外配置
sudo pacman -S wqy-microhei 				# 开源中文字体
sudo pacman -S ttf-wps-fonts 				# 中文办公软件WPS的字体包, 安装WPS必须安装的包
sudo pacman -S foxitreader 					# 福昕PDF阅读软件
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

-------------------------------------------------------------------------------

### **TIM - KDE**

**1、安装TIM**

```shell
sudo pacman -S deepin.com.qq.office 
```

**2、第二个包很重要**

```shell
sudo pacman -S gnome-settings-daemon
```

**3、打开TIM，自启gsd-xsettings （推荐），只对TIM有效。**

**方法一**

```shell
sudo vim /usr/share/applications/deepin.com.qq.office.desktop

注释： Exec=“/opt/deepinwine/apps/Deepin-TIM/run.sh” -u %u
加入：Exec=/usr/lib/gsd-xsettings || /opt/deepinwine/apps/Deepin-TIM/run.sh
```



**方法二** @ [Geogra](https://gitee.com/geogra) 
使用方法一 gnome-settings-daemon 会破坏KDE的字体设置和更改KDE的文件选择框什么的。
所以建议使用 xsettingsd 替代 gnome-settings-daemon
使用方式和使用 gnome-settings-daemon 的方式一样，但推荐将 xsettingsd 添加到开机启动项里。

```shell
ln -s /usr/bin/xsettingsd .config/autostart-scripts/
```

**TIM无法显示图片**

```
sudo vim /etc/sysctl.conf

# IPv6 disabled
net.ipv6.conf.all.disable_ipv6 =1
net.ipv6.conf.default.disable_ipv6 =1
net.ipv6.conf.lo.disable_ipv6 =1

sudo sysctl -p
重新打开TIM
```

-------------------------------------------------------------------------------

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
>全部安装：'MesloLGS NF', 'monospace', monospace dd

```bash
# Emoji安装
sudo pacman -S ttf-linux-libertine ttf-inconsolata ttf-joypixels ttf-twemoji-color noto-fonts-emoji ttf-liberation ttf-droid   
# 中文字体
sudo pacman -S wqy-bitmapfont wqy-microhei wqy-microhei-lite wqy-zenhei adobe-source-han-mono-cn-fonts adobe-source-han-sans-cn-fonts adobe-source-han-serif-cn-fonts ttf-dejavu 
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



**安装搜狗输入法及其依赖**

```shell
sudo pacman -S fcitx fcitx-im fcitx-configtool fcitx-qt4 fcitx-configtool 
sudo pacman -S fcitx-libpinyin kcm-fcitx fcitx-sogoupinyin

    # 这是一个很重要的包，如果没有，你的搜狗输入法无法使用。
git clone https://gitee.com/auroot/arch_config.git
cd arch_config
sudo pacman -U qtwebkit-2.3.4-7-x86_64.pkg.tar.xz
sudo pacman -U qtwebkit-bin-2.3.4-9-x86_64.pkg.tar.xz  # 覆盖
sudo pacman -U fcitx-qt4-4.2.9.6-1-x86_64.pkg.tar.xz
-----------------------------------------------------------------------------------
如果执行完上面的，加了配置环境，还是不行，就执行下面的
yay -S qtwebkit-bin  # 如果发现下载很慢的时候，就终止，下载下面的包
cp -rf ./qtwebkit-2.3.4-7-x86_64.pkg.tar.xz ~/.cache/yay/qtwebkit-bin/
cp -rf ./qtwebkit-bin-2.3.4-9-x86_64.pkg.tar.xz ~/.cache/yay/qtwebkit-bin/
yay -S qtwebkit-bin # 在执行这条命令
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

## 终端常用软件

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

### Fish Shell

#### 安装Fish Shell

```bash
$ sudo pacman -S fish
$ which fish #查看fish Shell的安装位置
$ chsh -l #列出当前可用的终端(另一种命令方式)
$ chsh -s /usr/bin/fish #为当前用户切换终端
```

#### 安装Oh-my-fish

```bash
$ git clone https://github.com/oh-my-fish/oh-my-fish
$ cd oh-my-fish
$ bin/install --offline
$ fish_config #Colors:Dracula Prompt:Terlar 完成后点选set theme和set prompt
#最后回车得到fish和oh-my-fish
```

#### 配置Oh-my-fish

```bash
$ omf install wttr #安装fish shell下的天气显示插件
$ alias c clear #定义快捷命令
$ funcsave c #记录快捷命令到配置文件
$ alias l "ls -la" 
$ funcsave l
```

**注意！**如果不小心定义了错误的快捷命令，可能会导致严重的后果。最典型的例子就是定义循环的命令，例如输入`alias A B` 和`alias B A`(A和B分别代表一条命令)，然后再输入A或者B，那么计算机可能会输出大量function错误，也可能直接崩溃宕机关闭。

如果已经定义了错误的命令，如`alias fuck ls`,有以下两种修复办法：

1. 在`~/.config/fish/functions`中查找之前定义的别名的文件，本例中文件名为`fuck.fish`，删除之即可。
2. 再定义一次命令，将`fuck`转义回原来的语义。输入`alias fuck fuck`即可。

### Z Shell

#### 安装Z shell

```bash
sudo pacman -S zsh
```

#### 安装Oh-my-zsh

```bash
#方法一，通过curl下载安装
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" 
#方法二，通过wget下载安装
sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

由于诸位都懂的原因， 使用`curl`和`wget`从github上下载的安装方式通常可能报错port 443拒绝访问。这个时候就需要使用 ~~工具云托管平台~~ 码云托管平台了。

在码云极速下载这个镜像账号中找到oh-my-zsh的仓库，链接如下：https://gitee.com/mirrors/oh-my-zsh

**方法一**：更改脚本中的克隆位置，运行脚本：

在tools文件夹中复制install.sh的全部内容到Linux下的任一编辑器。GVIM、NeoVim和Emacs等终端下编辑器需要使用`Ctrl+Shift+C/V`或`"+p`粘贴。其他如Kate，Gedit，VScode等则不用改变键位。

修改该文件的Default settings部分：

```text
- # Default settings
- ZSH=${ZSH:-~/.oh-my-zsh}
- REPO=${REPO:-mirrors/oh-my-zsh}
- REMOTE=${REMOTE:-https://gitee.com/${REPO}.git}
- BRANCH=${BRANCH:-master}

+ # Default settings
+ ZSH=${ZSH:-~/.oh-my-zsh}
+ REPO=${REPO:-mirrors/oh-my-zsh}
+ REMOTE=${REMOTE:-https://gitee.com/${REPO}.git}
+ BRANCH=${BRANCH:-master}
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

#### 配置Oh-my-zsh

##### 修改Oh-my-zsh的主题

```bash
vim  ~/.zshrc
ZSH_THEME="robbyrussel"
```

##### 自动提示与命令补全

```bash
git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
```

打开 `~/.zshrc` 文件，找到插件设置命令，修改为

```text
- plugins=(git)
+ plugins=(zsh-autosuggestions git)
```

##### 语法高亮

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

##### 自动补全incr (不推荐)

```bash
https://mimosa-pudica.net/zsh-incremental.html
chmod 777 ～/.oh-my-zsh/plugins/incr/incr-0.2.zsh
source ~/.oh-my-zsh/plugins/incr/incr-0.2.zsh
```

#####  快速切换路径

插件使你能够快速切换路径，再也不需要逐个敲入目录，只需敲入目标目录，就可以迅速切换目录。

```bash
git clone https://github.com/wting/autojump.git
./install.py  
# 在～/.zshrc文件中加入此句
[[ -s ~/.autojump/etc/profile.d/autojump.sh ]] && . ~/.autojump/etc/profile.d/autojump.sh  
```

##### 加强zsh的补全功能实现tab自动纠错

```bash
vim ~/.oh-my-zsh/lib/completion.zsh
zstyle ':completion:incremental:*' completer _complete _correct
zstyle ':completion:*' completer _complete _prefix _correct _prefix _match _approximate
```

##### 使配置生效

```bash
$ source ~/.zshrc
```



## 其他小问题指南

#### 网易云音乐无法输入中文的问题：

[下载地址](http://t.cn/A6wYa0Cr) T:```arch```

```shell
unzip netease-data.zip
sudo pacman -U qcef-1.1.6-1-x86_64.pkg.tar.xz
sudo pacman -U netease-cloud-music-1.2.1-2-x86_64.pkg.tar.xz
```

-------------------------------------------------------------------------------

#### 隐藏grub引导菜单

如果使用了其他引导，可以隐藏linux的grub引导菜单，修改下面文件：

```
sudo vim /etc/default/grub
```

```bash
GRUB_DEFAULT=0
GRUB_HIDDEN_TIMEOUT=0
GRUB_HIDDEN_TIMEOUT_QUIET=true
GRUB_TIMEOUT=0
GRUB_DISTRIBUTOR=`lsb_release -i -s 2> /dev/null || echo Debian`
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"
GRUB_CMDLINE_LINUX=""
GRUB_DISABLE_OS_PROBER=true
```

更新grub：

```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

#### rEFInd 引导双系统

如果你的电脑支持UEFI启动引导又嫌弃默认的启动界面丑，你可以使用rEFInd来管理你的启动项，推荐一个主题Minimal. 引导设置可参考rEFInd引导Win10+Ubuntu14双系统.
我的启动界面截图：

```bash
rEFInd：https://github.com/EvanPurkhiser/rEFInd-minimal
rEFInd引导Win10+Ubuntu：https://www.cnblogs.com/shishiteng/p/5760345.html
```

-------------------------------------------------------------------------------

#### Fstab配置文件

```bash
# Static information about the filesystems.
# See fstab(5) for details.

# <file system> <dir> <type> <options> <dump> <pass>

# /dev/sdb2
UUID=ID     /               ext4        rw,relatime     0   1

# /dev/sdb1
UUID=ID     /boot/efi       vfat         rw,relatime,fmask=0022,dmask=0022,codepage=437,iocharset=iso8859-1,shortname=mixed,utf8,errors=remount-ro   0   2

# /dev/sdb3
UUID=ID     none            swap        defaults        0   0

#/dev/nvme0n1p2  Windows file ntfs 
UUID=ID     /mnt/c          ntfs,ntfs-3g        defaults,auto,uid=1000,gid=985,umask=002,iocharset=utf8     0   0

#/dev/sda3  Win D file  ntfs  
UUID=ID     /mnt/d          ntfs,ntfs-3g        defaults,auto,uid=1000,gid=985,umask=002,iocharset=utf8     0   0
```

#### V2raya



#### 命令行代理（git，yay）

**[proxychains ](https://github.com/haad/proxychains )** 

[proxychains-ng](https://github.com/rofl0r/proxychains-ng)

我们需要`proxychains`，`ssr（github) 

**Qv2ray V2.70** 

``` bash
# 这里我使用的是 Qv2ray-v2.7.0-linux-x64.AppImage
# https://github.com/Qv2ray/Qv2ray
# 使用前需要一个依赖
sudo pacman -S libxcrypt-compat

# Qv2ray 代理地址
    `socks5://127.0.0.1:1089`
    `http://127.0.0.1:8889`
```

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

`yay`还不能走代理，github上有对应的  **[issue](https://github.com/Jguer/yay/issues/951)**

solution：

```bash
yay -S gcc-go (replace go)yay -S yay (or yay-git)
# 以后直接
proxychains yay -S package
```

```
proxychains git clone https://xxxxxxx.git
```

**浏览器代理插件**

[proxy switchyOmega插件](https://microsoftedge.microsoft.com/addons/detail/proxy-switchyomega/fdbloeknjpnloaggplaobopplkdhnikc?hl=zh-CN)

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



#### 禁用UTC解决双系统时间问题

>   Windows双系统时间不统一在于时间表示有两个标准：localtime 和 UTC(Coordinated Universal Time) 。UTC 是与时区无关的全球时间标准。尽管概念上有差别，UTC 和 GMT (格林威治时间) 是一样的。localtime 标准则依赖于当前时区。
>
>   时间标准由操作系统设定，Windows 默认使用 localtime，Mac OS 默认使用 UTC 而 UNIX 系列的操作系统两者都有。使用 Linux 时，最好将硬件时钟设置为 UTC 标准，并在所有操作系统中使用。这样 Linux 系统就可以自动调整夏令时设置，而如果使用 localtime 标准那么系统时间不会根据夏令时自动调整。

-   通过如下命令检查当前设置

```bash
timedatectl status | grep local
```

-   硬件时间可以用 hwclock 命令设置，将硬件时间设置为 localtime（解决双系统时间问题）

```bash
timedatectl set-local-rtc true
```

-   硬件时间设置成 UTC（如果要恢复默认设置）：

```bash
timedatectl set-local-rtc false
```



#### Pacman 常见使用方法

-   安装包

```bash
pacman -S 	Package_Name		# 安装软件
pacman -Syu 						 		# 对整个系统进行更新
pacman -Sy 	Package_Name		# 同步远程的仓库，并安装软件包
pacman -Sv 	Package_Name		# 在显示一些操作信息后执行安装。
pacman -U 	Package_Name		# 安装本地包,其扩展名为 pkg.tar.gz。
```

-   卸载包

```bash
pacman -R 	Package_Name		# 该命令将只删除包,不包含该包的依赖。
pacman -Rs 	Package_Name		# 在删除包的同时,也将删除其依赖。
pacman -Rd 	Package_Name		# 在删除包时不检查依赖。
pacman -Rcn Package_Name		# 
pacman -Rsn Package_Name 		# 加上-s参数来删除当前无用的依赖
pacman -Sc 	Package_Name 		# 清理当前未被安装软件包的缓存(/var/cache/pacman/pkg):
pacman -Scc Package_Name 		# 完全清理包缓存
```

-   搜索包

```bash
pacman -Ss 	Package_Name # 这将搜索含关键字的包。
pacman -Qi 	Package_Name # 查看有关包的信息。
pacman -Ql 	Package_Name # 列出该包的文件。
pacman -Qo 	Package_Name # 通过查询数据库获知目前你的文件系统中某个文件是属于哪个软件包
pacman -Qdt	Package_Name # 罗列所有不再作为依赖的软件包(孤立orphans)
```

-   其他用法

```bash
pacman -Sw Package_Name	# 只下载包,不安装。
pacman -Sc  	# 清理位于/var/cache/pacman/pkg/目录未安装的包文件,。
pacman -Scc 	# 清理所有的缓存文件。
```

-   `/etc/pacman.conf`配置文件

    >   不希望升级某个软件包，跳过升级软件包，可以加入内容如下： 

```bash
IgnorePkg = 软件包名
```

>    跳过升级软件包组
>   和软件包一样，你也可以象这样跳过升级某个软件包组：

```bash
IgnoreGroup = gnome
```



\# NOTE: You must run 'pacman-key --init' before first using pacman; the local

\# keyring can then be populated with the keys of all official Arch Linux

\# packagers with 'pacman-key --populate archlinux'.

