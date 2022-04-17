# Gentoo安装

## 准备:

1. 至少一个人
2. 一双能打字的手
3. 一个能思考的脑袋
4. 俩部电影
5. 至少一台正常的电脑
6. 一个正常的U盘
7. 一个稳定的网络环境
8. 一个稳定的电源
9. 一个已能完美运行的系统.(如果你是Linux系统则不需要下一个)
10. 一个[Ubuntu ISO](http://cdimage.ubuntu.com/)镜像文件（推荐）

如果你是Windows系统:
下载[Rufus](https://rufus.akeo.ie/?locale=zh_CN)刻录Ubuntu镜像
至于UEFI Legacy GPT和MBR等我就不说了,如果不熟悉这些玩Gentoo恐怕困难重重

如果你已有一个正常运行的Linux,恭喜,安装Gentoo会简单很多.
安装完并确定可用之后之后你可以tar打包已安装的系统使用live CD解压过去并修改相关配置

### 本文引用文档

**[Gentoo Linux的安装 - Gentoo Wiki](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/About/zh-cn)**

**[内核配置选项简介 - 金步国](http://www.jinbuguo.com/kernel/longterm-linux-kernel-options.html)**

**[Gentoo安装教程 - YangMame](https://blog.yangmame.org/Gentoo安装教程.html)**





## 需要知道的一些东西

Gentoo有很多好用的工具
这里说下安装过程会遇到的

eselect可以用来配置系统

比如`eselect python set X`可以设置默认的python（`eselect python list`查看可用选项）
`eselect fontconfig enable X`可以启用xxx字体配置（`eselct fontconfig list`查看可用选项）

etc-update可以用来更新or生成配置文件

假如系统更新了软件 有新的配置文件 Gentoo会生成一个临时的配置文件，需要自己手动删除 合并或覆盖 可以通过运行`etc-update`进行

记住，要尽量保证emerge提示无可用更新的配置文件（特别是更新portage的配置文件的时候）

## 准备磁盘

启动到live CD(已有Linux系统忽略这句)
使用你喜欢的工具进行分区(或者直接用gparted)
这里会声明下分区,之后的过程将使用这些变量

#### UEFI(GPT):

```bash
sda1 ---/boot--->vfat                   >=200M     #注意分区设置flags为esp
sda2 ---/--->ext4,btrfs,xfs,jfs.etc     >=20G      #建议至少20G大小
sda3 ---swap--->                        >=2G       #除非你16G内存,即使你8G内存也建议设置2G的swap
```

#### Legacy(MBR):

```bash
sda1 ---/boot--->ext2                   >=200M     #可以不设置此分区
sda2 ---/--->ext4,btrfs,xfs,jfs.etc     >=20G      #建议至少20G大小
sda3 ---swap--->                        >=2G       #除非你16G内存,即使你8G内存也建议设置2G的swap
```

#### 磁盘分区

##### 可用 System File 

```bash
# vfat (boot/efi)
mkfs.vfat [/dev/DISK]
# btrfs (/)
mkfs.btrfs -L [NAME] -f [/dev/DISK]
# ext4  (/)
mkfs.ext4 [/dev/DISK]
# f2fs
mkfs.f2fs [/dev/DISK]
# jfs
mkfs.jfs [/dev/DISK]
# reiserfs
mkfs.reiserfs [/dev/DISK]
```

#### swap

```bash
fallocate -l [SWAP_SIZE] /mnt/swapfile 
chmod 600 /swapfile 
mkswap /swapfile 
swapon /swapfile 
```

创建目录:

```bash
mkdir -v /mnt/gentoo
```

挂载目录:

```bash
mount -v /dev/sda2 /mnt/gentoo
```



## 安装基本文件

在这里你需要选择一个镜像站,在这里列出几个速度比较快的镜像站,请亲自测试选择镜像站:

[USTC](https://mirrors.ustc.edu.cn/)
[TUNA](https://mirrors.tuna.tsinghua.edu.cn/)
[163](http://mirrors.163.com/)

进入镜像站的`/gentoo/releases/amd64/autobuilds/`目录

如果你对systemd没有刚需则进入`current-stage3-amd64/`目录选择最新的`stage3`下载到本地的`/mnt/gentoo`目录,例如:stage3-amd64-20171019.tar.bz2

如果你需要systemd,则进入`current-stage3-amd64-systemd/`目录选择最新的`stage3`下载到本地的`/mnt/gentoo`目录,例如:stage3-amd64-systemd-20171018.tar.bz2

下载完成之后进入gentoo的根目录并解压文件:

```bash
cd /mnt/gentoo
tar vxpf stage3-*.tar.bz2或xz --xattrs-include='*.*' --numeric-owner
```

## 配置`make.conf`和Portage Mirror

#### 编译器自动检测 CPU

##### [如何为选择编译器CPU - Gentoo Wiki](https://wiki.gentoo.org/wiki/Safe_CFLAGS)

**`/etc/portage/make.conf`**

```bash
COMMON_FLAGS="-O2 -pipe -march=native"
CFLAGS="${COMMON_FLAGS}"
CXXFLAGS="${COMMON_FLAGS}"
```

#### Intel 架构

##### Skylake, Kaby Lake, Kaby Lake R, Coffee Lake, Comet Lake

**`/etc/portage/make.conf`**

```bash
COMMON_FLAGS="-march=skylake -O2 -pipe"
```

#### Haswell

**`/etc/portage/make.conf`**

```bash
COMMON_FLAGS="-march=haswell -O2 -pipe"
```

#### Ivy Bridge

**`/etc/portage/make.conf`**

```bash
COMMON_FLAGS="-march=ivybridge -O2 -pipe"
```

以下参数在经过自己调整或选择之后加入到 `/mnt/gentoo/etc/portage/make.conf`

- CFLAGS: 将CFLAGS修改为`CFLAGS="-march=native -O2 -pipe"` 或者你也可以指定 [如何为选择编译器CPU - Gentoo Wiki](https://wiki.gentoo.org/wiki/Safe_CFLAGS)，例如我的Intel CPU是haswell,将native换成haswell就行(不确定就不要指定).你也可以在[这里](https://www.funtoo.org/Subarches)看到所有可以设置的值

- USE: 首先,你可以删掉默认的USE标记，加上`-bindist` (不了解USE的情况下建议如此)
- 
- MAKEOPTS: 根据你的CPU核心数设置MAKEOPTS例如双四线程设置为`MAKEOPTS="-j5"`
- GENTOO_MIRRORS: 设置为`GENTOO_MIRRORS="https://mirrors.ustc.edu.cn/gentoo/"` 请自行选择速度最快的Mirror
- EMERGE_DEFAULT_OPTS: 设置为`EMERGE_DEFAULT_OPTS="--keep-going --with-bdeps=y"`是个不错的选择,keep going意为安装一堆软件时遇到编译错误自动跳过这个软件继续编译安装
- FEATURES: 在这里最好写成`# FEATURES="${FEATURES} -userpriv -usersandbox -sandbox"`,最好在前面加上#注释掉,在你编译软件遇到权限不足时去掉注释即可解决问题（但请务必注意是不是因为`rm -rf /*`等命令权限不足，因为说不定你的ebuild文件被篡改了）
- ACCEPT_KEYWORDS: 如果你想用作桌面/学习/开发系统那就务必加上`ACCEPT_KEYWORDS="~amd64"`，服务器/工作/家/娱乐用可以忽略
- ACCEPT_LICENSE: 加上`ACCEPT_LICENSE="*"`表示此系统接受所有软件许可证,即不论非自由还是自由软件都接受,非商业用户基本不需要考虑
- L10N: 设置为`L10N="en-US zh-CN en zh"`
- LINGUAS: 设置为`LINGUAS="en_US zh_CN en zh"`
- VIDEO_CARDS: 根据你的显卡类型设置假如你是NVIDIA单显卡则设置为`VIDEO_CARDS="nvidia"`(闭源驱动)`VIDEO_CARDS="nouveau"`(开源驱动).还有radeon和intel,但如果你是双显卡例如Intel+NVIDIA则设置为`VIDEO_CARDS="intel i965 nvidia"`(只要不是远古的集成显卡都是用i965)
- GRUB_PLATFORMS: 如果你使用GRUB且使用UEFI启动则添加`GRUB_PLATFORMS="efi-64"`
- Portage Mirror: 这个不是make.conf的选项.`mkdir /mnt/gentoo/etc/portage/repos.conf`创建repos.conf目录并添加如下到/mnt/gentoo/etc/portage/repos.conf/gentoo.conf文件里面(自行选择速度最快的镜像站):

```bash
[gentoo]
location = /usr/portage
sync-type = rsync
#sync-uri = rsync://mirrors.tuna.tsinghua.edu.cn/gentoo-portage/
sync-uri = rsync://rsync.mirrors.ustc.edu.cn/gentoo-portage/
auto-sync = yes
```

- 这里还有个CPU_FLAGS_X86,在后面的步骤`emerge --sync`之后安装`app-portage/cpuid2cpuflags`并配置:

```bash
emerge --ask app-portage/cpuid2cpuflags
cpuid2cpuflags #将输出值改入CPU_FLAGS_X86
```

示例配置（请以实际为标准）：

```bash
# /usr/share/portage/config/make.conf.example

# GCC
CFLAGS="-march=haswell -O2 -pipe"
CXXFLAGS="${CFLAGS}"
CHOST="x86_64-pc-linux-gnu"
CPU_FLAGS_X86="aes avx avx2 fma3 mmx mmxext pclmul popcnt sse sse2 sse3 sse4_1 sse4_2 ssse3"
MAKEOPTS="-j9"

# USE
SUPPORT="pulseaudio btrfs mtp git chromium"
DESKTOP="infinality emoji cjk"
FUCK="-bindist -grub -plymouth -systemd consolekit -modemmanager -gnome-shell -gnome -gnome-keyring -nautilus -modules"
ELSE="client icu sudo python"

USE="${SUPPORT} ${DESKTOP} ${FUCK} ${ELSE}"

# Portage
PORTDIR="/usr/portage"
DISTDIR="${PORTDIR}/distfiles"
PKGDIR="${PORTDIR}/packages"
# GENTOO_MIRRORS="https://mirrors.tuna.tsinghua.edu.cn/gentoo/"
GENTOO_MIRRORS="https://mirrors.ustc.edu.cn/gentoo/"
EMERGE_DEFAULT_OPTS="--ask --verbose=y --keep-going --with-bdeps=y --load-average"
# FEATURES="${FEATURES} -userpriv -usersandbox -sandbox"
PORTAGE_REPO_DUPLICATE_WARN="0"
# PORTAGE_TMPDIR="/var/tmp/notmpfs"

ACCEPT_KEYWORDS="~amd64"
ACCEPT_LICENSE="*"

# Language
L10N="en-US zh-CN en zh"
LINGUAS="en_US zh_CN en zh"

# Else
VIDEO_CARDS="intel i965 nvidia"

RUBY_TARGETS="ruby24 ruby25"

LLVM_TARGETS="X86"

QEMU_SOFTMMU_TARGETS="alpha aarch64 arm i386 mips mips64 mips64el mipsel ppc ppc64 s390x sh4 sh4eb sparc sparc64 x86_64"
QEMU_USER_TARGETS="alpha aarch64 arm armeb i386 mips mipsel ppc ppc64 ppc64abi32 s390x sh4 sh4eb sparc sparc32plus sparc64"
# ABI_X86="64 32"
```

## 进入Chroot环境



复制DNS:

```bash
cp --dereference /etc/resolv.conf /mnt/gentoo/etc/
```

挂载必要文件系统:

```bash
mount -t proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev
```

**如果使用非Gentoo live os 需要执行以下：**

```bash
test -L /dev/shm && rm /dev/shm && mkdir /dev/shm
mount --types tmpfs --options nosuid,nodev,noexec shm /dev/shm
chmod 1777 /dev/shm
```

进入Chroot:

```bash
chroot /mnt/gentoo /bin/bash
source /etc/profile
```

如果你有boot分区则在这里挂载上去:

```bash
mount /dev/sda1 /boot
```

## 选择Profile并更新系统

使用快照更新Portage:

```bash
emerge-webrsync
```

使用rsync同步:

```bash
emerge --sync
```

使用`eselect news read`命令阅读新闻

列出profile:

```bash
eselect profile list
```

如果你使用systemd则需要选上带有systemd字样的选项

如果你不使用systemd则不建议使用GNOME桌面,因为GNOME桌面依赖systemd(辣鸡)

例如不使用systemd且使用KDE桌面则选择19 default/linux/amd64/17.0/desktop/plasma:

```bash
eselect profile set 19
```

然后就是漫长的更新了(有钱人当我没说):

```bash
emerge -auvDN --with-bdeps=y @world
```

如果碰到未满足的xxx或者其它提示:

```bash
emerge -auvDN --with-bdeps=y --autounmask-write @world
etc-update # 然后输入-3就能更新配置,确保再次运行时没有可更新的文件
emerge -auvDN --with-bdeps=y @world
```

***如果以上还是不能解决问题,则进入/etc/portage目录删掉package.use,package.mask和package.unmask文件或目录再次尝试\***

到了这里,你可以去看电影了...

等它跑完了,先别急
运行下这几个命令:

```bash
emerge @preserved-rebuild
perl-cleaner --all
emerge -auvDN --with-bdeps=y @world
```

确定没有更新之后再继续，否则查看输出尝试重复运行

如果你在`emerge -auvDN --with-bdeps=y @world`时提示带有`bindist`字样且你已启用`ACCEPT_KEYWORDS="~amd64"`的话
运行如下命令之后再次重试：

```bash
cd /usr/portage/dev-libs/openssl/
ebuild openssl-1.0.2o-r6.ebuild merge # 这里openssl的版本可能和你的不一样，运行ls命令查看可用版本，替换为版本号带o字母的即可
```

安装必须的文件系统支持，否则无法访问硬盘上的分区！！

```text
emerge --ask sys-fs/e2fsprogs     #ext2、ext3、ext4
emerge --ask sys-fs/xfsprogs      #xfs
emerge --ask sys-fs/dosfstools    #fat32
emerge --ask sys-fs/ntfs3g        #ntfs
emerge --ask sys-fs/fuse-exfat    #exfat
emerge --ask sys-fs/exfat-utils   #exfat
```

如果提示需要更新USE配置

```text
etc-update   #输入“-3”-->回车-->yes-->回车
```



```text
echo "SOLARIZED=true" > /etc/eixrc/99-colour
depmod -a
```

## 配置时区和地区

```bash
echo "Asia/Shanghai" > /etc/timezone
emerge --config sys-libs/timezone-data

echo "en_US.UTF-8 UTF-8
zh_CN.UTF-8 UTF-8" >> /etc/locale.gen

locale-gen

eselect locale list
```

这里建议使用英语易于排错,之后你可以自行换成中文:

```bash
eselect locale set X # X换成上面命令显示的序号
```

## 配置fstab,安装文件系统工具

如果你和我一样懒

可以下载此脚本自动配置fstab(引自Arch的genfstab):

```bash
git clone git://git.ckyln.com/genfstab.git
chmod +x genfstab
#可选 cp genfstab /usr/bin/
./genfstab / > /etc/fstab
nano /etc/fstab #最好检查下此文件,删掉无用挂载点
```

上面的脚本在chroot环境下不能正常使用-U参数在fstab写入分区的UUID

挂载点主要有俩种格式:

```bash
/dev/sda1    /boot    vfat或ext2    defaults    0 0
/dev/sda2    /    ext4或btrfs,jfs,xfs.etc    defaults    0 0
/dev/sda3    none    swap    defaults    0 0
```

这里的UUID通过blkid查看

```bash
UUID=C1B0-EE02   /boot    vfat或ext2    defaults    0 0
UUID=24860058-48db-4015-8866-ecb97866458c    /    ext4或btrfs,jfs,xfs.etc    defaults    0 0
UUID=xxxxxxxxxxx    none    swap    defaults    0 0
```

如果你使用非ext4文件系统则在编译内核前需要另外安装相应的工具:

```bash
btrfs: emerge sys-fs/btrfs-progs
xfs: emerge sys-fs/xfsprogs
jfs: emerge sys-fs/jfsutils
```

## 安装NetworkManager

没错,我很懒,又加上我是KDE桌面用户,所以我选择使用NetworkManager连接网络:

```bash
nano -w /etc/portage/make.conf:
USE=“networkmanager -dhcpcd”

emerge -av networkmanager
```

如果它说有未满足的xxxx或者其它提示:

```bash
emerge --autounmask-write networkmanager
etc-update --automode -3
emerge networkmanager
```

openRC(即非systemd)添加开机服务:

```bash
rc-update add NetworkManager default
```

systemd添加开机服务:

```bash
systemctl enable NetworkManager
```

在/etc/conf.d/hostname内修改主机名,例如:

```bash
echo hostname=\"Test\" > /etc/conf.d/hostname
```

## 安装一些必要工具并配置

```bash
emerge app-admin/sysklogd sys-process/cronie sudo layman grub usbutils kmod
emerge xz-utils
echo 'sys-apps/kmod lzma zlib' > /etc/portage/package.use/kmod

useradd -m -G users,wheel,portage,usb,video 这里换成你的用户名(小写)
sed -i 's/\# \%wheel ALL=(ALL) ALL/\%wheel ALL=(ALL) ALL/g' /etc/sudoers
passwd #是时候设置root密码了
```



如果你是systemd:

```bash
sed -i 's/\# GRUB_CMDLINE_LINUX=\"init=\/usr\/lib\/systemd\/systemd\"/GRUB_CMDLINE_LINUX=\"init=\/usr\/lib\/systemd\/systemd\"/g' /etc/default/grub
ln -sf /proc/self/mounts /etc/mtab
systemd-machine-id-setup
```

非systemd系统:

```bash
rc-update add sysklogd default
rc-update add cronie default
```

## 配置编译安装内核

有以下推荐内核可供选择:

```bash
gentoo-sources
ck-sources
git-sources
```

### 可选：安装固件和微代码

一些驱动需要先在系统上安装附加的固件才能工作。经常网络接口上会使用，特别是无线网络接口。此外，来自 AMD 、 NVidia 和 Intel 等供应商的现代视频芯片在使用开源驱动程序时，通常也需要外部固件文件。大多数固件都打包在 [sys-kernel/linux-firmware](https://packages.gentoo.org/packages/sys-kernel/linux-firmware) 里：

```bash
emerge --ask sys-kernel/linux-firmware
```

### 自动安装内核

如果你不会配置内核或者时间不允许可以先用`genkernel`:

```bash
emerge --ask sys-kernel/genkernel
genkernel --menuconfig all
genkernel --install initramfs
```

**或者你当前运行着一个正常使用的Linux的话也可以：**

```bash
cd /usr/src/linux
make localyesconfig
# 如果询问新选项，一路回车吧，23333
make -jX #将X替换为你想编译时的线程数
make modules_install
make install
genkernel --install initramfs
```

手动配置内核:

```bash
cd /usr/src/linux
make menuconfig
```

#### 关于配置内核

本站有写内核配置的文章

你也可以选择去看[金步国](http://www.jinbuguo.com/kernel/longterm-linux-kernel-options.html)的文章

配置完之后:

```bash
make -jX #将X替换为你想编译时的线程数
make modules_install
make install

```

### 手动安装内核，配置和编译

#### 安装源码

```bash
emerge --ask sys-kernel/gentoo-sources
```

列出所有已安装的内核:

```bash
$ eselect kernel list
	Available kernel symlink targets:
 	 [1]   linux-4.9.16-gentoo
$ eselect kernel set 1 #选择内核
$ ls -l /usr/src/linux
```

#### 手动配置

```bash
emerge --ask sys-apps/pciutils

cd /usr/src/linux

make menuconfig
```

**KERNEL** **启用 Gentoo 特有选项**

```bash
Gentoo Linux --->
  Generic Driver Options --->
    [*] Gentoo Linux support
    [*]   Linux dynamic and persistent device naming (userspace devfs) support
    [*]   Select options required by Portage features
        Support for init systems, system and service managers  --->
          [*] OpenRC, runit and other script based systems and managers
          [*] systemd
```

**KERNEL** **启用 devtmpfs 支持**

```bash
Device Drivers --->
  Generic Driver Options --->
    [*] Maintain a devtmpfs filesystem to mount at /dev
    [*]   Automount devtmpfs at /dev, after the kernel mounted the rootfs
```

验证 SCSI 磁盘支持是否已激活(CONFIG_BLK_DEV_SD):

**KERNEL** **Enabling SCSI disk support**

```bash
Device Drivers --->
   SCSI device support  --->
      <*> SCSI disk support
```

**KERNEL** **选择所需要的文件系统**

```
File systems --->
  <*> Second extended fs support
  <*> The Extended 3 (ext3) filesystem
  <*> The Extended 4 (ext4) filesystem
  <*> Reiserfs support
  <*> JFS filesystem support
  <*> XFS filesystem support
  <*> Btrfs filesystem support
  DOS/FAT/NT Filesystems  --->
    <*> MSDOS fs support
    <*> VFAT (Windows-95) fs support
 
  Pseudo Filesystems --->
    [*] /proc file system support
    [*] Tmpfs virtual memory file system support (former shm fs)
```

**KERNEL** **选择PPPoE所需要的驱动**

```
Device Drivers --->
  Network device support --->
    <*> PPP (point-to-point protocol) support
    <*>   PPP support for async serial ports
    <*>   PPP support for sync tty ports
```

**KERNEL** **激活SMP支持**

```
Processor type and features  --->
  [*] Symmetric multi-processing support
```

**KERNEL** **激活USB输入设备的支持**

```
HID support  --->
    -*- HID bus support
    <*>   Generic HID driver
    [*]   Battery level reporting for HID devices
      USB HID support  --->
        <*> USB HID transport layer
  [*] USB support  --->
    <*>     xHCI HCD (USB 3.0) support
    <*>     EHCI HCD (USB 2.0) support
    <*>     OHCI HCD (USB 1.1) support
```

**KERNEL** **选择处理器类型和功能**

如果要支持32位程序，请确保选择IA32 Emulation(CONFIG_IA32_EMULATION)。Gentoo 默认会安装一个multilib 系统（混合 32 位/ 64 位计算），所以除非使用了一个 no-multilib 配置文件，否则这个选项是必需的。

```
Processor type and features  --->
   [ ] Machine Check / overheating reporting 
   [ ]   Intel MCE Features
   [ ]   AMD MCE Features
   Processor family (AMD-Opteron/Athlon64)  --->
      ( ) Opteron/Athlon64/Hammer/K8
      ( ) Intel P4 / older Netburst based Xeon
      ( ) Core 2/newer Xeon
      ( ) Intel Atom
      ( ) Generic-x86-64
Executable file formats / Emulations  --->
   [*] IA32 Emulation
```

**KERNEL** **启用对GPT的支持**

如果在分区时使用GPT分区标签，则启用对它的支持 (CONFIG_PARTITION_ADVANCED and CONFIG_EFI_PARTITION)：

```
-*- Enable the block layer --->
   Partition Types --->
      [*] Advanced partition selection
      [*] EFI GUID Partition support
```

**KERNEL** **启用对UEFI的支持**

如果使用UEFI来引导系统，则在内核中启用EFI桩支持和EFI变量 (CONFIG_EFI, CONFIG_EFI_STUB, CONFIG_EFI_MIXED, and CONFIG_EFI_VARS)：

```
Processor type and features  --->
    [*] EFI runtime service support 
    [*]   EFI stub support
    [*]     EFI mixed-mode support
 
Firmware Drivers  --->
    EFI (Extensible Firmware Interface) Support  --->
        <*> EFI Variable Support via sysfs
```

### 编译和安装

```bash
make && make modules_install
make install

emerge --ask sys-kernel/dracut
cd /boot
dracut --hostonly
```

### --------------------------------------------------------------------------------------------------

## 安装GRUB并创建用户

#### UEFI:

```bash
nano -w /etc/portage/make.conf:
GRUB_PLATFORMS="efi-64"

emerge --ask sys-boot/grub:2
emerge --ask sys-boot/os-prober

grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=Gentoo
grub-mkconfig -o /boot/grub/grub.cfg
```

如果出现`No space left on device`

请运行：

```bash
mount -t efivarfs efivarfs /sys/firmware/efi/efivars
rm /sys/firmware/efi/efivars/dump-*
```

然后重试（由 @Chara 提议加上）

#### Legacy:

```bash
grub-install --target=i386-pc /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
```



#### OpenRC/openrc-init（谨慎使用)

```bash
# /etc/default/grub
	
#GRUB_CMDLINE_LINUX_DEFAULT=""
GRUB_CMDLINE_LINUX_DEFAULT="init=/sbin/openrc-init"
```





## 显卡驱动

NVIDIA单显卡:

```bash
emerge -av x11-drivers/nvidia-drivers
```

Intel单显卡:

```bash
emerge -av x11-drivers/xf86-video-intel
```

Intel+NVIDIA双显卡请看这篇[文章](https://blog.yangmame.top/Gentoo双显卡安装配置.html)

其它显卡硬件待补坑 欢迎提出

## 检查系统可用性

到了这里你应该可以重启查看系统是否能正常启动,然后在安装桌面

重启前最好检查下的东西:

1. boot目录是否有相应文件
2. GRUB是否正确生成配置并显示内核等文件
3. fstab是否正确无误

## 安装桌面

首先需要确保已安装xorg-server和显卡驱动:

```bash
emerge -av xorg-server
emerge xf86-video-intel #Intel显卡驱动
emerge nvidia-drivers #nvidia显卡驱动
```

如遇需要更新配置则运行`etc-update --automode -3`并再次运行命令

#### KDE:

```bash
emerge -av plasma-desktop plasma-nm plasma-pa sddm konsole
```

如遇需要更新配置则运行`etc-update --automode -3`并再次运行命令

如果你是systemd:

```bash
systemctl enable sddm
```

openrc则编辑`/etc/conf.d/xdm`将`DISPLAYMANAGER`的值改为`sddm`并:

```bash
rc-update add xdm default
```

#### GNOME:

```bash
emerge -av gnome-shell gdm gnome-terminal
systemctl enable gdm
```

如遇需要更新配置则运行`etc-update --automode -3`并再次运行命令

***这里只说明systemd,因为openrc并不能满足GNOME的依赖\***



 Gentoo Linux passwd 密码强度是这样的。首先我们可以查看两个配置文件， `/etc/pam.d/passwd` 和 `/etc/pam.d/system-auth` 大家会注意到后者告诉我们相关配置文件在 `/etc/security/passwdqc.conf` 。所以，我们只需要设置这个配置文件就好了，那么默认的情况大概是这样的（之所以说是大概是因为我忘记默认配置文件了）。

```
min=disabled,24,11,8,7
max=40
passphrase=8
match=4
similar=deny
random=47
enforce=everyone
retry=3
```

我后面修改成：

```
min=3,3,3,3,3
max=8
passphrase=0
match=4
similar=permit
random=47
enforce=everyone
retry=3
```

## 软件安装

### KVM

