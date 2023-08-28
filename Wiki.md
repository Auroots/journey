# 腾讯云 VPS系统重装Archlinux

```bash
 #下载镜像至根目录
 cd /
 wget https://mirrors.tuna.tsinghua.edu.cn/archlinux/iso/latest/archlinux-2020.02.01-x86_64.iso
 #重命名为 arch.iso
 mv arch* arch.iso
 #编辑GRUB配置文件，加入 arch.iso 启动项（部分系统的该文件路径为 /boot/grub2/grub.cfg ）
 #编辑 /boot/grub/grub.cfg，在与下面结构类似的第一个 menuentry 前，添加下面的内容。（搜索“menuentry（空格）”的第一个匹配项）
 vim /boot/grub/grub.cfg
 #配置600秒的GRUB等待时长，“vda1”项根据主机“fdisk -l”命令查看，视情况更改
 #花括号内的缩进为一个Tab键
```

```bash
set timeout=20
menuentry 'ArchISO' --class iso {
  set isofile=/archlinux-2021.08.01-x86_64.iso
  loopback loop0 $isofile
  linux (loop0)/arch/boot/x86_64/vmlinuz-linux archisolabel=ARCH_202108 img_dev=/dev/vda1 img_loop=$isofile
  initrd (loop0)/arch/boot/x86_64/initramfs-linux.img
}
```



```bash
 #如果提示“insmod”无法识别，进入原系统在GRUB配置文件中，使用Tab键重新缩进
 #配置 arch live 环境
 #设置密码
 passwd
 #自动分配IP
 dhcpcd
 #开启 ssh 服务
 systemctl start sshd
 #使用 ssh 连接，摆脱不好用的 VNC 界面
 #用户名 root，密码为 passwd 所设置的
 #重设磁盘 vda1 的读写权限
 mount -o rw,remount /dev/vda1
 #进入 vda1 挂载目录 /run/archiso/img_dev
 cd /run/archiso/img_dev
 #删除原系统文件（除了arch.iso）
 rm -rf [b-z]*
 #重新挂载 vda1 至 /mnt
 mount /dev/vda1 /mnt
```



```
sudo pacman -S xorg-server xorg-apps xorg-xinit
sudo pacman -S neofetch unrar unzip p7zip zsh vim git 
sudo pacman -S wqy-microhei wqy-zenhei ttf-dejavu ttf-ubuntu-font-family noto-fonts noto-fonts-extra noto-fonts-emoji noto-fonts-cjk ttf-dejavu ttf-liberation ttf-wps-fonts
```

# ArchLinux 修改主目录为英文

```bash
sudo pacman -S xdg-user-dirs-gtk
export LANG=en_US
xdg-user-dirs-gtk-update
 #然后会有个窗口提示语言更改，更新名称即可
export LANG=zh_CN.UTF-8
 #然后重启电脑如果提示语言更改，保留旧的名称即可
```

# ArchLinux Xrdp远程配置

```bash
sudo pacman -S xrdp xorgxrdp
echo "allowed_users=anybody" >> /etc/X11/Xwrapper.config
sudo systemctl enable xrdp.service
sudo systemctl enable xrdp-sesman.service
sudo systemctl start xrdp.service
sudo systemctl start xrdp-sesman.service
```

[Info]    2021-08-15 09:40:35 初始管理员账号：admin@cloudreve.org
[Info]    2021-08-15 09:40:35 初始管理员密码：8WZIoZC1
