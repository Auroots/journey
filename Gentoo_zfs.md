



## **Gentoo-ZFS**

- 安装中文字体（文泉驿）

```
sudo emerge -av  media-fonts/wqy-bitmapfont media-fonts/wqy-microhei media-fonts/wqy-unibit media-fonts/wqy-zenhei
```



```
fc-list | grep "WenQuanYi"
```



### snapper

```
sudo emerge -av app-backup/snapper app-backup/grub-btrfs
```

### 创建配置文件

```
snapper -c 配置文件名 create-config 分区或子卷的挂载点
```

> 这将根据 `/etc/snapper/config-templates/default` 提供的默认值创建配置文件。

- print configure file list

```
sudo snapper list-configs
```



- print list

```
sudo snapper -c config list
```

- Add "New1" **快照**

```
sudo snapper -c config create -d "New1"
```



```
sudo snapper -c config create --description "System_init" --userdata "auroot=yes"
```



```
sudo snapper -c config delete [NUM]
```



```
sudo rc-update add grub-btrfsd boot
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

#### 比较快照

```
snapper status <第一个快照编号>..<第二个快照编号> //第一个快照的创建时间要早于第二个
```



```
snapper status 161..0 //0 表示当前系统，它不是快照，但你可以认为是比所有快照都新的一个快照。
```



```
snapper diff <第一个快照编号>..<第二个快照编号> 文件名
```







#### 创建您的根 zfs 数据集

```bash
zpool create -f -o ashift=12 -o cachefile= -O compression=lz4 -O xattr=sa -O relatime=on -O acltype=posixacl -O dedup=off -m none -R /mnt/gentoo tank /dev/sda2
```



#### 创建您的根 zfs 数据集

```bash
zfs create tank/gentoo
zfs create -o mountpoint=/ tank/gentoo/os
zfs create -o mountpoint=/home tank/gentoo/home
```

```
GRUB_DISABLE_OS_PROBER=false
```

**检查**

```
zpool status
zfs list # 查看挂载点
```

**挂载EFI**

```bash
mkdir /mnt/gentoo/boot/efi -p
mount /dev/sda1 /mnt/gentoo/boot/efi
cd /mnt/gentoo
# 下载
wget https://mirrors.bfsu.edu.cn/gentoo/releases/amd64/autobuilds/20221205T133149Z/stage3-amd64-openrc-20221205T133149Z.tar.xz
tar vxpf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner

# 复制 zpool
mkdir /mnt/gentoo/etc/zfs
cp /etc/zfs/zpool.cache /mnt/gentoo/etc/zfs
# 创建配置问题
mkdir -p /mnt/gentoo/etc/portage/repos.conf
vim /mnt/gentoo/etc/portage/make.conf
vim /mnt/gentoo/etc/portage/repos.conf/gentoo.conf
```



```bash
# 必须copy，不然没网络
cp --dereference /etc/resolv.conf /mnt/gentoo/etc/

mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev
mount --bind /run /mnt/gentoo/run
mount --make-slave /mnt/gentoo/run

chroot /mnt/gentoo /bin/bash
source /etc/profile
```





```
vim /etc/portage/package.use/ghostscript-gpl
app-test/ghostscript-gpl -l10n_zh-CN
```



```bash
vim /etc/portage/package.use/python
`
*/* PYTHON_TARGETS: -python2_7 # 排除
*/* PYTHON_COMPAT: python3_10 python3_11 # 兼容
`
```



```
blkid -s UUID -o value /dev/sda1
vim /etc/fstab
UUID=A27B-6E06      /boot/efi       vfat         noauto,defaults    1   2

echo " 
UUID=$(blkid -s UUID -o value /dev/sda1)       /boot/efi       vfat         noauto,defaults    1   2" >> /etc/fstab
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



```bash
eselect profile set 19
```

然后就是漫长的更新了

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

如果你使用非ext4文件系统，在编译内核前需要另外安装相应的工具:

```text
emerge --ask sys-fs/e2fsprogs     	# ext2、ext3、ext4
emerge --ask sys-fs/xfsprogs      	# xfs
emerge --ask sys-fs/dosfstools    	# fat32
emerge --ask sys-fs/ntfs3g        	# ntfs
emerge --ask sys-fs/fuse-exfat    	# exfat
emerge --ask sys-fs/exfat-utils   	# exfat
emerge --ask sys-fs/btrfs-progs  	# btrfs
emerge --ask sys-fs/jfsutils 		# jfs
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

这里的UUID通过blkid查看

```bash
UUID=xxxxxxxxxxx   	/boot   vfat    defaults    0 0
UUID=xxxxxxxxxxx    /    	btrfs	defaults    0 0
UUID=xxxxxxxxxxx    none    swap    defaults    0 0
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

rc-update add sysklogd default
rc-update add cronie default

useradd -m -G users,wheel,portage,usb,video 这里换成你的用户名(小写)
sed -i 's/\# \%wheel ALL=(ALL) ALL/\%wheel ALL=(ALL) ALL/g' /etc/sudoers
passwd #是时候设置root密码了
```



**弱密码设置**

```bash
nano /etc/security/passwdqc.conf
"
min=disabled,24,11,8,7
max=72
passphrase=3
match=4
similar=deny
random=47
enforce=everyone  # 改成none
retry=3
"
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



### 编译和安装

```bash
make && make modules_install
make install

emerge --ask sys-kernel/dracut
cd /boot
dracut --hostonly
```



##  -------------------- 省略内核安装 --------------------



### 启用 zfs openrc 服务 - 仅限 Openrc

```bash
emerge sys-fs/zfs-kmod sys-fs/zfs

echo "sys-fs/zfs-kmod ~amd64" >> /etc/portage/package.accept_keywords/zfs-kmod
echo "=sys-fs/zfs-kmod-9999" >> /etc/portage/package.accept_keywords/zfs-kmod
echo "sys-fs/zfs ~amd64" >> /etc/portage/package.accept_keywords/zfs
echo "sys-fs/zfs-9999" >> /etc/portage/package.accept_keywords/zfs

rc-update add zfs-import boot
rc-update add zfs-mount boot
rc-update add zfs-share default
rc-update add zfs-zed default
```

### 生成并验证 zfs 主机标识文件

```
zgenhostid
file /etc/hostid
```

### 安装 gentoo-source 内核二进制文件

```bash
mkdir -p /boot/efi/EFI/Gentoo
cd /boot/efi/EFI/Gentoo
cp /boot/vmlinuz-6.0.11-gentoo  /boot/efi/EFI/Gentoo/vmlinuz-6.0.11-gentoo.efi
```

#### 使用 genkernel initramfs 将 initramfs 文件复制到其正确的位置

```bash
genkernel initramfs --zfs --install --firmware --compress-initramfs --microcode-initramfs --kernel-config=/usr/src/linux/.config

cd /boot/efi/EFI/Gentoo

cp /boot/initramfs-6.0.11-gentoo.img /boot/efi/EFI/Gentoo

```





















### --------------------------------------------------------------------------------------------------

## 安装GRUB并创建用户

#### UEFI:

```bash
nano -w /etc/portage/make.conf:
GRUB_PLATFORMS="efi-64"

emerge --ask sys-boot/grub
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



### make.conf

```bash
# Auroot - Gentoo_make.conf
# file = /etc/portage/make.conf
# These settings were set by the catalyst build script that automatically
# built this stage.
# Please consult /usr/share/portage/config/make.conf.example for a more
# detailed example.
CFLAGS="-march=znver3 -O3 -pipe"
CXXFLAGS="${CFLAGS}"
FCFLAGS="${CFLAGS}"
FFLAGS="${CFLAGS}"
CHOST="x86_64-pc-linux-gnu"

MAKEOPTS="-j33"
LC_MESSAGES=C
LLVM_TARGETS="X86"
LDFLAGS="-Wl,-O3 -Wl,--as-needed"

EMERGE_DEFAULT_OPTS="--ask --alphabetical --color=y --usepkg=y --verbose=y --keep-going --with-bdeps=y"
# FEATURES="${FEATURES} -userpriv -usersandbox -sandbox -test ccache"

# USE
SUPPORT="btrfs git pulseaudio bluetooth wifi mtp sudo networkmanager"
DESKTOP="X emoji cjk -gnome -gnome-keyring -nautilus -gnome-shell"
ELSE="client minizip minimal acpi alsa amd64 bzip2 icu multilib opengl nls nptl ncurses udev zlib"
FUCK="-bindist -doc -nouveau -gtk-doc -man -plymouth -test -dhcpcd -intel -systemd -consolekit"
USE="${SUPPORT} ${DESKTOP} ${ELSE} ${FUCK}"

ABI_X86="64" 
CPU_FLAGS_X86="aes avx avx2 f16c fma3 mmx mmxext pclmul popcnt rdrand sha sse sse2 sse3 sse4_1 sse4_2 sse4a ssse3"
PORTAGE_REPO_DUPLICATE_WARN="0"
ACCEPT_KEYWORDS="~amd64"
ACCEPT_LICENSE="*"

# Language
L10N="en-US zh-CN en zh"
LINGUAS="en_US zh_CN en zh"

GRUB_PLATFORMS="efi-64"
VIDEO_CARDS="nvidia"

RUBY_TARGETS="ruby27"
PYTHON_TARGETS="python3_10 python3_11"
LUA_TARGETS="lua5-1"

# Qemu / Kvm
QEMU_SOFTMMU_TARGETS="alpha aarch64 arm i386 mips mips64 mips64el mipsel ppc ppc64 s390x sh4 sh4eb sparc sparc64 x86_64"
QEMU_USER_TARGETS="alpha aarch64 arm armeb i386 mips mipsel ppc ppc64 ppc64abi32 s390x sh4 sh4eb sparc sparc32plus sparc64"

# Portage
PORTDIR="/var/db/repos/gentoo"
DISTDIR="/var/cache/distfiles"
PKGDIR="/var/cache/packages"
GENTOO_MIRRORS="https://mirrors.bfsu.edu.cn/gentoo"
#FEATURES="${FEATURES} -userpriv -usersandbox -sandbox"
```



### repos.conf/gentoo.conf

```bash
# Directory: /etc/portage/repos.conf/gentoo.conf
# Install: emerge dev-vcs/git
# Install: emerge --oneshot sys-apps/portage
[DEFAULT]
main-repo = gentoo

[gentoo]
# location = /usr/portage
location = /var/db/repos/gentoo

# sync-type = git
sync-type = rsync
sync-uri = rsync://mirrors.bfsu.edu.cn/gentoo-portage
auto-sync = yes
#sync-uri = rsync://mirrors.tuna.tsinghua.edu.cn/gentoo-portage/
#sync-uri = rsync://rsync.mirrors.ustc.edu.cn/gentoo-portage/
#sync-uri=https://mirrors.cqu.edu.cn/git/gentoo-portage.git

sync-rsync-verify-jobs = 1
sync-rsync-verify-metamanifest = yes
sync-rsync-verify-max-age = 24
sync-openpgp-key-path = /usr/share/openpgp-keys/gentoo-release.asc
sync-openpgp-key-refresh-retry-count = 40
sync-openpgp-key-refresh-retry-overall-timeout = 1200
sync-openpgp-key-refresh-retry-delay-exp-base = 2
sync-openpgp-key-refresh-retry-delay-max = 60
sync-openpgp-key-refresh-retry-delay-mult = 4

```

