# Gentoo Linux 物理机安装与配置

 2022-08-18

 18分钟阅读时长

## Note

Gentoo Linux 是一个快速、现代化的元发行版，它的设计简洁、灵活。

### Motivation

1. 自由 高度自由的选择，用户可以选择自己想要的组件
2. 性能 通过编译期优化和链接期优化获得更好的使用体验，更差的安装体验
3. 开放 大部分软件均以源码的形式发布，编译和安装，不对用户隐藏细节
4. 稳定 滚动更新，但是是在保证稳定的基础上，除非破坏，否则基本不会崩溃

### Reference Additional

1. Gentoo Installtion ISO 并非不能使用
   1. `mount` 操作步骤确实比其他发行版更复杂
   2. `fstab` 可下载 gentoo 官方提供的 `genfstab` ，不必手动生成
2. init 系统的选择
   1. Systemd 是目前主流的 init 系统，相当多的发行版正在使用，这包括 `debian` , `redhat`, `arch`, `nixos` 等等。
   2. openRC 是 Gentoo 官方推荐的 init 系统
      1. 优点是可移植（移植到 freeBSD 或其他 unix 系统上）
      2. 缺点是管理的内容没有 systemd 丰富，需要设置更多的内容。

### Requirement

1. Hardware 由于绝大多数软件均需要通过源码编译，因此硬件不能过低。 我的配置是 Core I5-8250U,Mem 8GiB,Disk 120GiB
2. Psychological expectation 不可避免地，源码编译会消耗大量的时间和精力，优化软件亦然。 因此确保：
   1. 你是狂热的开源软件爱好者/Linux 爱好者；
   2. 编译和优化所消耗的时间在你的承受范围内。

## Start

### Network

Gentoo 从软件仓库下载所有软件的源码（当然，基本的安装和编译环境仍由 gentoo 提供）因此连接互联网是必须的步骤

1. 有线网 `dhcpcd` 即可联网，否则参见 **Reference** 中的详细步骤。 建议尽量使用有线网络而非无线网络，因为内核中可能没有无线网卡驱动。
2. 无线网 `iw dev` 或者 `iwctl` 配置无线网络。 最推荐的是 `nmtui` ，该命令属于 `NetworkManager` 软件包。
3. 测试网络 使用 `ping` 命令，注意该命令发送的是 ICMP 报文，只能确保存在本机到远端的物理通路，但是仍然有可能无法连接互联网。

### PreInstallation

#### Installation media

安装介质的选择通常是 U 盘，特别地， **镜像写入方式没有明确限制** ，推荐使用 ISO 镜像。

1. Linux 上可以选择 `DD` 镜像方式写入

   ```shell
     dd if=<iso文件> of=/dev/<device> bs=1M status=progress
   ```

2. Windows 上可以选择 `Rufus` 或者 `UltraISO`

#### User Account

安装介质进入的 liveCD 系统通常不需要额外添加用户，但是如果需要使用额外的服务除外。

```shell
  passwd # 修改root用户密码
  useradd -m -G wheel leesin # 添加用户，带有home目录，且在wheel用户组中
  passwd leesin # 修改添加的账户的密码
```

由于 Gentoo Linux 的安全设置，设置的密码很可能因不够复杂而被系统拒绝，可以手动修改复杂程度规范，也可以在系统主机中设置 `use` 变量

```shell
  nano -w /etc/security/passwdqc.conf
```

说明：

1. gentoo 的 livecd 默认只带有 nano
2. arch 的 livecd 带有 vim，因此使用 arch 的 livecd 安装 gentoo 是一个好选择

#### Service

1. 安装时需要查看文档
   1. 切换到 `tty2` ，使用 root 或刚刚创建的用户登录。
   2. 使用 `links` ，访问 gentoo 的安装 wiki 。
2. 安装时需要 `SSH` 远程登录
   1. 编辑 `/etc/ssh/sshd_config` 确保 `PermitRootLogin yes`
   2. `ss -ntlp` 查看 port 是否启用默认的 22 端口，也可以开启其他端口
   3. IP 地址确认
      1. 如果是虚拟机，例如 VirtualBox：
         1. 依次点选 设置 端口转发，新增端口转发规则
         2. 主机端口只需要不和已有的端口冲突
         3. 子系统端口选择默认的 22，也可以设置其他的端口
      2. 如果是物理机，则需要额外的一台计算机：
         1. 连接到同一局域网
         2. 系统主机通过 `ip address` 查看 IP 地址
         3. 工具主机通过该地址连接
   4. `SSH` 连接 假设 IP 地址为 192.168.2.1
      1. `ssh root@192.168.2.1/24`
      2. `ssh -p 22 root@192.168.2.1/24`

### Partition

首先观察硬盘上所有的块设备。

```shell
  fdisk -l
  lsblk
```

然后判断电脑的引导方式和分区表类型。 引导模式分为 BIOS 和 UEFI 两种；分区表类型分为 MBR 和 GPT 两种。

1. Windows 下

   1. 判断电脑的引导模式 在运行对话框中输入 `msinfo32` 在弹出的系统信息(或在控制面板 */ 系统与安全* / 管理工具 / 系统信息)中寻找到 BIOS 模式项，观察是否是 UEFI。
   2. 判断磁盘的分区类型 右击我的电脑 / 管理 / 右击磁盘管理 / 属性，在弹出的对话框中会显示磁盘分区形式

2. Linux 下 判断电脑的 BIOS 引导模式及分区类型

   1. 法一，通过内核暴露的环境信息验证

      ```shell
        ls /sys/firmware/efi/efivars
      ```

   2. 法二，通过磁盘上的分区格式验证

      ```shell
        fdisk -l
      ```

      检查是否有 `EFI` 分区格式，是否有 gpt 字样。

#### MBR

什么?你居然还在用 `MBR` ，哦我的天哪，我建议你立刻停止这种行为，除非你愿意去看看官方 wiki!

#### GPT

一般地，分区需要指定至少 2 个挂载点，即 `/boot` 和 `/` 对于拥有一块固态硬盘，一块机械硬盘的电脑来说，挂载点通常如下：

| 挂载点  | 文件系统 | 挂载位置(块设备) | 挂载用途                  | 大小   |
| ------- | -------- | ---------------- | ------------------------- | ------ |
| `/`     | ext4     | /dev/sda6        | 根分区 记录几乎所有的内容 | 120GiB |
| `/boot` | fat32    | /dev/nvme0n1p1   | 引导分区 引导进入系统     | 300MiB |

分区命令 `cfdisk /dev/nvme0n1` 和 `cfdisk /dev/sda` 格式化命令

1. `mkfs.fat -F 32 /dev/nvme0n1p1`
2. `mkfs.ext4 /dev/sda6`

开启交换文件(也可以设置交换分区)

```shell
  dd if=/dev/zero of=/mnt/gentoo/swapfile bs=1M count=8192 status=progress
  cd /mnt/gentoo
  chmod 600 ./swapfile
  mkswap ./swapfile
  swapon ./swapfile
  swapon --show
```

在完成安装后记得检查 `/etc/fstab`

```conf
  /swapfile none swap defaults 0 0
```

#### Mount

依次挂载。 特别地，如果 `/dev/nvme0n1p1` 带有 windows boot manager，一定要备份！

```shell
  mkdir --parents /mnt/gentoo/boot
  mount /dev/sda6 /mnt/gentoo
  mount /dev/nvme0n1p1 /mnt/gentoo/boot
```

#### Stage

从镜像站中下载一个 stage 包。

1. 使用 `links`
2. 使用 `lynx`
3. wget curl

推荐地址 https://mirrors.tuna.tsinghua.edu.cn/gentoo/releases/amd64/autobuilds/

```shell
  tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner
```

说明：

1. xattrs: 开启扩展属性支持。
2. xattrs-include: 通过规则（通常是正则表达式的方式）指定需要开启扩展属性支持的文件。

## Optimize

Gentoo 需要指定编译参数，合适的优化能带来更强的使用体验。

由于篇幅有限，不可能介绍所有的优化选项；特别地，优化标志不是越多越好，激进的在系统范围上使用的优化标志会伤害应用程序，因此三思而后行。

有关 `make.conf` 的全部内容可以通过 `man 5 make.conf` 查找，这里仅介绍一些比较常用的配置。

输入 `vim /mnt/gentoo/etc/portage/make.conf`

```conf
  # 为所有语言设置编译标志
  COMMON_FLAGS="-march=native -O2 -pipe"
  # 为两个变量使用相同的设置
  CFLAGS="${COMMON_FLAGS}"
  CXXFLAGS="${COMMON_FLAGS}"
```

### COMMON_FLAGS

1. `-march=native` CPU 指令集
   - 不同的 CPU 支持不同的指令集，执行代码的方式也不相同。
   - 该选项指明了编译器应该为系统的处理器架构生成何种代码。
   - 通过 `gcc -c -Q -march=native --help=target` 或 `cat /proc/cpuinfo` 返回的结果填写本机需要的处理器架构，也可以直接使用默认值 `-march=native`
2. -O2 该选项指明的 gcc 的优化级别标志，每提高一个优化等级都将激活大量的优化标志。主要有以下等级：
   1. `-O0` 完全关闭优化 不启用优化将导致某些程序无法正常工作，仅调试
   2. `-O1` 最基本的优化
   3. `-O2` 推荐的优化级别 推荐在系统范围内开启此项优化，并开启 `-O3` 中一些比较安全的选项。
   4. `-O3` 可能的最高优化级别
      1. 特别需要注意，提高优化级别并不意味着性能一定随之提高，事实上过高的优化将导致汇编语言完全不可执行，从而使程序无法正常运行。
      2. 高优化级别将占用大量的内存。
   5. `-Os` 优化代码大小 基于 `-O2` 且激活了在该级别上不会增加代码生成大小的选项，在小磁盘或小缓存机器上使用。
   6. `-Og` 该选项是在 `-O0` 的级别上进行的优化 一般用于快速编译和调试，提供合理水平的运行时性能，禁用了可能干扰调试的优化
   7. `-Ofast` 基于 `-O3` 并增加了额外的优化选项 此优化等级违反了严格的标准合规性，不建议使用。
   8. `-O4?` 现实是高于 3 的级别没有效果，编译器可以接受这些标志，但实际上没有做 `-O3` 以外的任何事情。
3. -pipe 该选项用于提高编译速度，在编译的不同阶段使用管道而不是临时文件，代价是占用更多的内存。如果内存小于 4GB (当然小于 4GB 不推荐使用 gentoo)应当关闭该选项。
4. -fomit-frame-pointer 该选项将不把 `frame pointer` （栈帧指针）保存在寄存器中，旨在减少生成的代码大小。使用该选项将会使程序调试变得困难或几乎不可能。 该选项在 `-O2` 时开启。
5. -finline-functions 允许编译器选择某些简单的函数在其被调用处展开，比较安全的选项，特别是在 CPU 二级缓存较大时建议使用。 该选项在 `-O3` 时开启。
6. -funswitch-loops 将循环体中不改变值的变量移动到循环体之外。该选项可能导致问题。 该选项在 `-O3` 时开启。
7. -fgcse-after-reload 为了清除多余的溢出，在重载之后执行一个额外的载入消除步骤。 该选项在 `-O3` 时开启。
8. -fgraphite-identity 该选项可开启 gcc 编译时的 Graphite 优化，而且不会干扰 gcc 本身在编译程序时的优化判断。建议开启。 开启条件：在 `use` 中指定 `graphite` 后重新编译 `gcc`
9. -floop-nest-optimize 启用基于 isl 的循环嵌套优化器。这是一个基于 Pluto 优化算法的通用循环嵌套优化器。它计算针对数据局部性和并行性优化的循环结构。 **这个选项是实验性的。**
10. -fno-math-errno 任何 `-O` 选项都不会启用此选项，因为它可能导致依赖于 IEEE 或 ISO 数学函数规则/规范的精确实现的程序输出不正确。 然而，对于不需要这些规范保证的程序，它可能会产生更快的代码。
11. -fno-trapping-math 假设浮点运算不生成用户可见的陷阱的情况下编译代码。这些陷阱包括除零、溢出、下溢、不精确结果和无效操作。 此选项要求 `-fno` 信号 NAN 有效。例如，如果依赖于“不间断”的 IEEE 算法，设置此选项可能允许更快的代码。 任何 `-O` 选项都不应启用此选项，因为它可能会导致依赖于 IEEE 或 ISO 数学函数规则/规范的精确实现的程序输出错误。
12. -fno-align-functions 通过设置 **函数不对齐** 提高编译速度。 函数对齐是指将函数的开头与大于或等于 n 的下一个二次幂对齐，最多跳过 m-1 个字节，以确保 CPU 至少可以获取函数的前 m 个字节，而不会越过 n 字节对齐边界。
13. -fno-align-loops 通过设置 **循环不对齐** 提高编译速度。 循环对齐是指将循环对齐到二次幂边界。
14. -fno-align-jumps 通过设置 **跳跃时循环不对齐** 提高编译速度。 跳跃时循环对齐是指将分支目标与二次方边界对齐，用于只能通过跳跃到达目标的分支目标。
15. -fno-align-labels 通过设置 **标签不对齐** 提高编译速度。 标签对齐是指将所有分支目标对齐到二次幂边界。
16. -fno-stack-protector 禁用 **堆栈保护检查** 以提高编译速度。这是以牺牲程序安全性为代价换取性能的设置。与 `use="-ssp"` 配合使用。 堆栈保护检查是生成额外的代码来检查缓冲区溢出，例如堆栈粉碎攻击等。 该选项在 gcc 手册上仅解释了非 no 选项，默认开启。
17. -fno-semantic-interposition 禁用 **动态链接器插入符号** ，以使得编译器能够执行过程间传播、内联和其他优化。 该选项在 gcc 手册上仅解释了非 no 选项，默认不开启。
18. -fno-common 要求编译器直接为变量分配空间。 -fcommon 要求编译器将变量放置在“公共”存储中。
19. -fipa-pta 进行过程间指针分析和过程间修改和参考分析。 此选项可能会导致在大型编译单元上使用过多的内存和编译用时。 因此默认情况下，它在任何优化级别都不会启用。
20. -fno-plt 不要将 PLT 用于与位置无关的代码中的外部函数调用。 此选项可能会导致生成更高效的代码，但也有可能导致编译出错。

### Other FLAGS

1. RUST_FLAGS 使用 `-C` 向 Rust 传递编译优化选项

   ```conf
     RUST_FLAGS="-C opt-level=2 -C target-cpu=skylake"
   ```

2. LD_FLAGS 使用 `-Wl,` 向链接器传递选项

   ```conf
     LDFLAGS="-Wl,-O2 -Wl,--as-needed -Wl,--hash-style=gnu -Wl,--sort-common -Wl,--strip-all"
   ```

   1. –as-needed 链接器会检查所有的依赖库，没有实际被引用的库，不写入可执行文件头。

   2. –hash-style=gnu

      - 设置链接器哈希表的类型。默认是 `sysv` ，可以设置成 `gnu` ，也可以设置成 `both` 。
      - `DT_HASH` 是 `ELF` (Linux 可执行程序的文件类型)中的一个 sections，保存了用于查找符号的散列表，以支持符号表的访问，提高符号的搜索速度。
      - `gnu.hash` 提供了与 hash 段相同的功能；但是与 hash 相比，增加了某些限制（附加规则），带来了 50% 的动态链接性能提升，代价是不兼容。

   3. –sort-common 把全局公共符号按照大小排序后放到适当的输出节，以防止符号间因为排布限制而出现间隙。

   4. –strip-all 从输出文件中忽略所有符号信息。

   5. –static 不链接共享库（推迟到运行时）以提高链接速度，降低运行速度。

   6. 可以选用其他链接器如 `lld` 或 `gold` 替代默认的 `bfd` 链接器，这可以适当加快链接速度。

      但是这样做可能导致在编译大型程序或底层程序时出错，例如 `gcc` ， `glibc` ， `webkit` ， `qtwebengine`

      设置方法：

      ```shell
        emerge -av lld
        LD_FLAGS="-fuse-ld=lld"
        LD=/usr/bin/lld
      ```

   7. –export-dynamic 此标志告诉链接器将所有符号添加到动态符号表中。

   8. –whole-archive 将在其后面出现的静态库包含的函数和变量输出到动态库中。这通常用于将存档文件转换为共享库，强制将每个对象包含在生成的共享库中。

   9. -ljemalloc 特别不推荐在全局范围内使用 `-ljemalloc` （需要额外安装 `jemalloc` ),可能导致问题。

3. MAKEOPTS 该选项设置并行编译的数量。

   1. `-jX` 指代并行编译的数量 建议每个 job 至少有 2 GiB RAM （所以 8 GiB 内存最多设置 `-j4` ）。 避免内存溢出，根据可用内存降低 job 数量；如果内存足够，那么设置值一般在 `CPUs+1` 到 `2*CPUs+1` 之间。
   2. `-lX` 指代平均并行编译的数量（保证不会超载）

4. GENTOO_MIRRORS 设置 gentoo 源。

   ```conf
     GENTOO_MIRRORS="https://mirrors.ustc.edu.cn/gentoo https://mirrors.tuna.tsinghua.edu.cn/gentoo"
   ```

   注意 gentoo 源不是必须的，因为 gentoo portage 源提供的 `ebuild` 会指示软件源码的下载地址。 但是仍然推荐加入 gentoo 源，以缓解上游镜像仓库的压力，同时也能加快关键软件源码下载的速度。

5. USE

   1. 如何知道一个软件包有哪些 use 选项？

      ```shell
        emerge -av app-portage/gentoolkit
      ```

   2. lto pgo graphite 为编译器开启三项优化 特别地，为了防止在全局开启上述优化选项导致程序不可用，将该部分单独配置。 输入 `vim /etc/portage/package.use/gcc` 并输入以下内容，注意后面几项是可选的。

      ```conf
        sys-devel/gcc lto pgo graphite objc objc++ valgrind -ssp
        emerge -av gcc
      ```

   3. X xorg 在编译软件时增加 `X` 和 `xorg` 支持，如果使用 `xorg` 环境建议全局开启。

   4. wayland 在编译软件时增加 `wayland` 支持，该项可以不开启。

   5. 其他可选项

      1. 最小化推荐的选项 `use="systemd dbus"`
      2. 窗口管理器推荐的选项 `use="alsa pulseaudio policykit"`
      3. 桌面环境推荐的选项 `use="udev kde gnome gtk qt4 qt5"`
      4. 使用文件管理器 `use="udisks archive"`
      5. 图形渲染器 `use="gles2 opengl glx vulkan nvidia"`
      6. 中文支持 `use="cjk"`
      7. 音视频可选支持 `use="ffmpeg"`
      8. 远程登录可选支持 `use="openssl"`
      9. 禁用复杂密码策略 `use="-passwdqc"`

   6. 查看全局 USE 选项

      ```shell
        emerge --info | grep ^USE
      ```

6. ACCEPT_KEYWORDS 一般支持的是 `amd64` ，更加激进的选项是 `~amd64` 。 注意后者表示软件版本尚未接受稳定性测试或软件表现不稳定。

7. ACCEPT_LICENSE 设置支持的开源协议。可以根据其授权协议接受或拒绝安装软件。 设置成 `ACCEPT_LICENSE="*"` ，会少很多麻烦。

8. GRUB_PLATFORMS 如果使用 GRUB ，那么可以设置成 `GRUB_PLATFORMS=efi-64`

9. EMERGE_DEFAULT_OPTS 为 emerge 加入默认选项，这样就不必每次输入命令的时候都加入这些选项。

   1. –keep-going 即使某一个软件或软件依赖安装出错，也尽可能向下执行（以继续安装其他软件或该软件的其他依赖）
   2. –with-bdeps <y|n> 在依赖项计算中，引入不严格要求的构建时依赖项
   3. –jobs –load-average 这些选项与 **MAKEOPTS** 同时使用时，有效的 job 数量可以指数式加速

10. L10N 指示计算机的语言支持。

    ```conf
      L10N="en-US zh-CN en zh"
    ```

11. VIDEO_CARDS 指示计算机的显卡支持。例如 UHD Graphics 630 属于 Gen8-Gen9。[1](https://endlesspeak.github.io/docs/build/operating-system-installation/linux-technology-3-3-gentoo-linux-installation/#footnote-1)

    ```conf
      VIDEO_CARDS="intel nvidia"
    ```

12. ALSA_CARDS 指示计算机的声卡支持。

    ```conf
      ALSA_CARDS="hda-intel"
    ```

13. INPUT_DEVICES 指示计算机的输入设备支持。

    ```conf
      INPUT_DEVICES="libinput synaptics"
    ```

14. LLVM_TARGETS 如果你不知道 `LLVM` 是什么，那么略过此步骤。

    ```conf
      LLVM_TARGETS="X86 NVPTX" #nvidia可开启NVPTX而A卡可开启AMDGPU
    ```

15. ABI_X86 如果不知道 `wine-staging` 和 `lutris` ，那么略过此步骤。

    ```conf
      ABI_X86="64 32"
    ```

16. FEATURES 仅介绍 `ccache` ，用于编译时出现错误或意外中断，下次编译时 ccache 可以直接命中缓存，节约编译时间。 在安装 `emerge -av dev-util/ccache` 之前不要加入下列内容。

    ```conf
      FEATURES="ccache"
      CCACHE_DIR="/var/cache/ccache"
    ```

    修改文件夹的属主和权限

    ```shell
      mkdir -p /var/cache/ccache
      chown -R root:portage /var/cache/ccache
      chmod -R 2775 /var/cache/ccache
    ```

    作一些基本配置，具体可参见 wiki 上的描述[2](https://endlesspeak.github.io/docs/build/operating-system-installation/linux-technology-3-3-gentoo-linux-installation/#footnote-2)。 `vim /var/cache/ccache/ccache.conf`

    ```conf
      max_size = 2G
      umask = 002
      cache_dir_depth = 3
    ```

17. CPU_FLAGS_X86 可以在这里直接加入计算机 CPU 的指令集，以达到优化的目的。 需要先安装软件包 `cpuid2cpuflags` ，输入命令： `emerge --ask app-portage/cpuid2cpuflags` 执行 `cpuid2cpuflags` ，将获得的 CPU 指令集填写到 `make.conf` 中。

一切都修改完成，完成 chroot 且同步软件仓库后：

1. 重装 `gcc` 也可以额外装 `gcc` 版本
2. 下载一个编辑器 比如说 `vim` 或 `neovim` 或 `emacs` ，否则就等着 `chroot` 之后用 `nano`

## Chroot

### Software Source

建立软件源文件夹并拷贝默认配置。

```shell
  mkdir --parents /mnt/gentoo/etc/portage/repos.conf
  cp /mnt/gentoo/usr/share/portage/config/repos.conf /mnt/gentoo/etc/portage/repos.conf/gentoo.conf
```

注意同步方式的区别：

1. rsync

   1. rsync 是文件同步程序，能够高效地进行文件传输和目录同步。
   2. 默认在新安装的 Gentoo 系统上开启，可开启 `rsyncd` 守护进程。
   3. rsync 的缺点是同步时镜像服务器压力较大，而且自建的 overlay 通过 rsync 部署较困难。
   4. 特别地，如果重建 glibc 后 rsync 停止工作，需要重建 rsync

   ```shell
     emerge -av --oneshot net-misc/rsync
   ```

2. git

   1. git 是 overlay 的主流同步方式。
   2. 同步过程中可以记录提交历史，有助于在软件遇到问题时及时回退软件仓库。
   3. 由于 github/gitlab 等网站可便捷地提供 git 远程服务，因此 git 同步是自建 overlay 的主流同步方式。
   4. 由于记录了较多的提交历史，在使用一段时间后 git 仓库会变的特别大，而且提交历史大部分对用户是无价值的。

首先用 rsync 同步 Gentoo Portage 源的 Gentoo Overlay 编辑 `vim /etc/portage/repos.conf/gentoo.conf` 关于该文件，可以 `man portage` 查找配置选项。

```conf
  [DEFAULT]
  main-repo = gentoo

  [gentoo]
  location = /var/db/repos/gentoo
  sync-type = rsync
  sync-uri = rsync://rsync.gentoo.org/gentoo-portage
  auto-sync = yes
  sync-depth = 2
```

**在同步软件仓库之后** 可以下载 git。 如需使用 git 同步，删除 `/var/db/repos/gentoo` 然后将同步方式改为 git 重新同步。 特别地，同步软件仓库需要在挂载和 chroot 之后进行。

```conf
  sync-type = git
  sync-uri = https://mirrors.tuna.tsinghua.edu.cn/git/gentoo-portage.git
```

### DNS

```shell
  cp --dereference /etc/resolv.conf /mnt/gentoo/etc/
--dereference` 保证复制的是真正的文件内容而不是符号链接。 事实上我的电脑只添加了 `nameserver 192.168.1.1
```

### Mount

```shell
  mount --types=proc /proc /mnt/gentoo/proc
  mount --rbind /sys /mnt/gentoo/sys
  mount --rbind /dev /mnt/gentoo/dev
  mount --bind /run /mnt/gentoo/run
  mount --make-rslave /mnt/gentoo/sys
  mount --make-rslave /mnt/gentoo/dev
  mount --make-slave /mnt/gentoo/run
  mount --types tmpfs --options nosuid,nodev,noexec shm /dev/shm
  chmod 1777 /dev/shm /run/shm
```

说明：

1. mount –types

   - 提供的文件系统可以在 `/proc/filesystems` 和 `/lib/modules/$(uname -r)/kernel/fs` 中找到。
   - 一般来说提供下列文件系统: ext2 ext3 ext4 xfs btrfs vfat sysfs proc nfs cifs
   - 我理解的需要通过文件系统来绑定 `/proc` 的原因：

   `/proc` 是内核暴露信息的位置，stage3 安装的内核和 livecd 中的内核不同，如果采用绑定方式，则后续无法从 `/proc` 中获取到当前内核的信息。

2. mount –bind

   - bind 是绑定，即从 livecd 中将指定的文件绑定到指定位置
   - 可从用户层面理解为硬链接，但原理不同，首先链接关系存在于内存（即临时的），其次被挂载的位置的下级目录将被暂时隐藏

   1. mount –bind 仅绑定一级目录
   2. mount –rbind 可以递归的绑定子目录(r for recursive)
   3. 我理解的绑定方式不同的原因
      1. `/run` 是临时文件系统，用于启动系统的守护进程并存储系统的临时运行时文件，livecd 系统和后续安装的系统的运行时文件可能不同
      2. `/dev` 和 `/sys` 包含的是系统信息（如设备文件等等），通常这些信息不会发生变化，因此直接递归绑定

3. mount –make-slave 是设置从属挂载；–make-rslave 是设置递归从属挂载

   - 目前支持标记挂载及其子装载为共享、私有、从属或不可绑定。

   1. 共享挂载提供了创建该挂载的镜像的能力，例如在任何镜像中的装载和卸载将传播到另一个镜像。
   2. 从属挂载即从其主挂载中接收传播的动作，但反过来不行。
   3. 私有挂载不携带传播能力。
   4. 不可绑定的挂载是专用挂载，它不能通过绑定操作克隆。

```shell
  chroot /mnt/gentoo /bin/bash
  source /etc/profile #这是最重要的一步
  export PS1="(chroot) ${PS1}"
```

## Portage

### Update portage datebase

在本步进行之后才可进行 **安装任何软件** 的操作。

```shell
  emerge-webrsync #速度快，rsync
  emerge --sync #更新更新
```

### Read News

```shell
  eselect news list
  eselect news read
  eselect news purge
```

### Select Profile

推荐使用 desktop profile，注意应和选择的 init 系统保持一致。 当然也可以使用最小化的 profile，这就意味着需要自己处理很多 use 选项和软件问题。

```shell
  eselect profile list
  eselect profile set X #选择恰当的profile
```

### Software source

gentoo 提供软件安装的仓库 overlay，如果需要添加某些软件，应当先将其所在的 overlay 添加到本地。

官方建议选用的添加软件仓库的工具是 eselect-repository，而 layman 目前不被建议使用。

建议添加的 overlay: `gentoo-zh` `guru` `benzene-overlay`

```shell
  emerge -av dev-vcs/git app-eselect/eselect-repository doas sudo
  eselect repository list
  eselect repository enable X
  emerge --sync gentoo-zh
```

### Upgrade System

在更新系统之前，可考虑是否需要从 stage1 开始重建至 stage3。（见下节）

```shell
  emerge --ask --verbose --update --deep --newuse @world
  emerge -avuDN @world
```

在以后每次更新系统都可以使用上面的命令，也可以用下面的命令

```shell
  emerge --ask --verbose --update --deep --changed-use @world
  emerge -avuDU @world
```

区别：

1. newuse 检查包括当前系统使用的所有 use 选项以及 ebuild 文件中 use 选项的变化，而后对所有变动项所在的软件进行安装
2. changed-use 检查当前系统使用的所有 use 选项的变化，对变动项所在的软件进行安装。

每次运行完更新之后，推荐运行

```shell
  emerge --depclean 
  emerge --ask --verbose --emptytree --with-bdeps=y @world
```

### Systemd

```shell
  ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
  vim /etc/locale.gen
  locale-gen
  eselect locale list
  eselect locale set X
  env-update && source /etc/profile && export PS1="(chroot) ${PS1}"
```

## BootStrap

**特别注意，本部分是可选的，供参阅。** 本部分用于从头开始构建所有的内容，类似 `linux from stratch` 这可能需要相当长的一段时间。整个过程的重点是 **保证二进制文件的完整性** 。

### stage

1. stage 1
   1. 从第 1 阶段的 tarball 开始，必须使用现有的（二进制）主机系统工具链；
   2. 在/var/db/repos/gentoo/scripts/bootstrap.sh 脚本的指导下构建基本工具链（GCC、标准 C 库等）这会产生：
2. stage 2 在这里，需要使用新工具链来构建（构建）核心@world 包集。这会产生：
3. stage 3
   1. 其中工具链已被引导，重要的系统二进制文件和库已使用它编译。
   2. 现在，Gentoo 发行版的默认部分提供了这样一个 stage 3 系统目录的 tarball（stage 1 和 stage 2 tarball 不再可供最终用户使用）。

### stage1 to stage2

切换到 bootstrap 目录，然后进行虚拟运行以查看提供的 bootstrap.sh 脚本将要做什么。

```shell
  eselect locale set X #必须设置成C
  cd /var/db/repos/gentoo/scripts
  ./bootstrap.sh --pretend
```

目前 `bootstrap.sh` 的问题在于：

1. 将要重建的 `libc` 属于虚拟包

   1. 虚拟包即本身无任何内容，但是依赖其他包，安装虚拟包事实上就是安装其所依赖的包

   2. 重建虚拟包将不会对已安装的被实际依赖的包做任何操作

   3. 为了重建已安装的被实际依赖的包做如下操作

      ```conf
        -[[ -z ${ myLIBC } ]]  &&  myLIBC = " $( portageq expand_virtual / virtual/libc ) " 
        +[[ -z ${ myLIBC } ]]  ;  myLIBC = " $( portageq expand_virtual / virtual/libc ) "
      ```

      去掉&&使得以下语句无条件执行，加入分号使得其他部分不受影响。

2. 将要重建的 `gcc` 应当具有现代特征 `openmp`

   ```conf
     export USE="-* bootstrap ${ALLOWED_USE} ${BOOTSTRAP_USE} openmp"
   ```

3. `!!! CONFIG_PROTECT is empty` 警告说，如果要安装的任何包试图覆盖它们，引导过程将不会保留可能已修改的任何配置文件。 这主要包括两个文件 `/etc/locale.gen` 和 `/etc/conf.d/keymap` (如果有的话）

   ```shell
     cp -v /etc/locale.gen{,.bak}
   ```

说明：由于 `bootstrap.sh` 文件作为 Gentoo ebuild 主存储库的一部分存在，因此任何更改将在下次同步时被覆盖。然而因为我们现在只想重建我们的系统，所以这不是问题（但你当然可以在此时复制修改后的 bootstrap.sh 文件，如果你愿意的话。

一切就绪，开始执行 `./bootstrap.sh` 该命令将重建 `portage` ，如果没有报错，将重建 `gcc` 和 `zlib` 等。

若未重建 `gcc` ，根据警告提示补全当前系统里缺少的 use 选项： 特别地，对 gcc 的 use 选项在 `/etc/portage/package.use/gcc` 中单独修改。

然后重建整个交叉编译工具链（即 bootstrap 中提示需要安装的软件）。

若已重建 `gcc` ，检查 `gcc` 的配置，验证是否重建 `gcc`

```shell
  gcc-config --list-profiles
```

如果这一步提示当前配置无效，执行下面的命令：

```shell
  gcc-config 1
  env-update && source /etc/profile && export PS1="(chroot) $PS1"
```

上一步的环境更新完成后，手动重建交叉编译工具链，结束后重新运行一次检测

```shell
  emerge -av --oneshot sys-devel/libtool binutils llvm clang libc glibc
  ./bootstrap.sh
```

### stage2 to stage3

当上一阶段提示系统已经成功 `bootstraped` 后，执行下面的命令

```shell
  emerge -e @system 
  emerge -avuDN @world
```

所有的工作做完之后，还原文件

```shell
  mv -v /etc/locale.gen{.bak,} 
  locale-gen
  eselect locale list
  eselect locale set X
```

## Kernel

### firmeware

相当多的设备需要先在系统上安装附加的固件才能正常运行，因此 `sys-kernel/linux-firmware` 几乎是必须的。 另外可能还需要安装微码(为 CPU 提供的固件更新)，因此 `sys-firmware/intel-microcode` 需要安装（AMD 的微码包含在固件中）。

### kernel

gentoo-source genkernel initramfs vanill-kernel xanmod-kernel 我强烈推荐第一次安装的 Linux 爱好者 **先装二进制内核** ，原因如下：

1. 如果你第一次配置自己的内核，你可能将它弄的一团糟；
2. 如果在 1 小时，1天甚至一周的时间内你仍然没有获得一个可用的内核，你的信心会受到巨大的打击；
3. 如果在新系统上有某些功能不可用，你无法排除是否属于内核的原因。 `vim /etc/portage/package.use/kernel` sys-kernel/gentoo-kernel-bin -initramfs

```shell
  emerge -av sys-kernel/gentoo-kernel-bin
```

尽管你可能不知道如何配置内核，但是如果你想体验一下如何编译它，具体的配置选用官方定义好的版本，这是可以的：

```shell
  emerge -av sys-kernel/gentoo-kernel
  eselect kernel list
  eselect kernel set 1
  cd /usr/src/linux
  make mrproper #类似 make clean 
  make -jX && make -jX modules_install
  make install
```

## System

### fstab

建议使用 UUID 而不是 Label 定义以确保唯一性。

```shell
  emerge -av sys-fs/genfstab
  genfstab -U / >> /etc/fstab
  genfstab -U /mnt/gentoo >> /mnt/gentoo/etc/fstab # arch自带的genfstab从ISO生成可能不行
```

### hostname

```shell
  hostnamectl hostname LeeSin
  echo 'LeeSin' > /etc/hostname
  vim /etc/hosts
```

### Network

介绍两种网络配置办法。

#### NetworkManager

```shell
  emerge -av net-misc/dhcpcd
  systemctl enable --now dhcpcd
  emerge -av net-misc/networkmanager
```

需要为 `networkmanager` 开启一些 use 选项，否则在后续使用中可能遇到代理等问题。 输入 `vim /etc/portage/package.use/network`

```conf
  net-misc/networkmanager concheck dhcpcd gnutls gtk-doc introspection iptables nftables policykit ppp systemd tools wext wifi
```

为 `networkmanager` 安装前端软件，如 `nm-applet` 等。（KDE 或 gnome 提供了前端组件）

#### Networkd & Iwd

Networkd 适用 systemd 系统。

```shell
  emerge -av net-wireless/iwd net-misc/dhcpcd
  systemctl enable iwd dhcpcd systemd-networkd
```

##### Networkd

查看以太网接口名称，可用 `ip link` 或 `networkctl list` 查看。 输入 `vim /etc/systemd/network/20-wired.network`

```shell
  [Match]
  Name=enp4s0 # 替换为前述命令得到的接口名
  
  [Network]
  DHCP=ipv4
```

如需配置静态 IP 或者其他高级配置，参见 ArchWiki[3](https://endlesspeak.github.io/docs/build/operating-system-installation/linux-technology-3-3-gentoo-linux-installation/#footnote-3)

##### Iwd

输入 `iwctl` 进入交互式命令行。（退出可用 `C-d` 发出 `EOF` 信号）

1. help 查看帮助
2. device list 列出所有设备
3. station list 列出所有无线设备
4. station device scan 扫描网络
5. station device get-networks 列出可用网络
6. station device connect SSID 连接指定网络

详细内容参阅 ArchWiki[4](https://endlesspeak.github.io/docs/build/operating-system-installation/linux-technology-3-3-gentoo-linux-installation/#footnote-4)

特别地，若无设备列出，考虑以下原因：

1. `rfkill list` 检查无线设备是否被禁用，若被禁用，~rfkill unlock wifi~ 启用该设备。
2. `lspci -k` 检查无线设备是否有驱动

### Systemd setup

设置 `machine-id` 对于使用 `systemd-boot` 的用户有帮助

```shell
  systemd-firstboot --prompt --setup-machine-id
  systemd preset-all
```

### SSHD

```shell
  systemctl enable sshd
```

### Time

1. Linux 将系统时钟视为 UTC，并将当前时间设置为 UTC+8
2. Windows 则将系统时钟视为 RTC，并将当前时间设置为该时间。
3. 可以设置 Linux 系统使用 RTC 硬件时钟，也可以设置 windows 将硬件时钟视为 UTC

```shell
  timedatectl set-rtc true
  systemctl enable systemd-timesyncd
```

### User

```shell
  passwd
  useradd -m -G users,wheel,audio,video -s /bin/bash leesin
  passwd leesin
```

## Boot

检查一下你的计算机是否有启动引导器，即开机的时候尝试按 ESC 键。如果有启动引导器，事情会好办很多。

### Grub

```shell
  emerge -av sys-boot/grub
  grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=gentoo
  grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=gentoo
  emerge -av sys-boot/os-prober
```

输入 `vim /etc/default/grub`

```conf
  GRUB_DISABLE_OS_PROBER="false"
  GRUB_CMDLINE_LINUX="init=/usr/lib/systemd/systemd loglevel=5 nowatchdog"
  # 如果不需要debug,可以启用quiet
  # nowatchdog 可以显著提升关机速度
  grub-mkconfig -o /boot/grub/grub.cfg
```

### Other

1. LILO
2. efibootmgr
3. systemd-boot
4. syslinux

### Exit and Reboot

```shell
  exit
  cd /
  umount -lRv /mnt/gentoo
  reboot
  rm /stage3-*.tar.*
```

1. -l 指的是懒卸载，比较安全
2. -R 指的是递归卸载
3. -v 指的是显示卸载内容

## Reference

1. https://wiki.gentoo.org/wiki/Handbook:Main_Page/zh-cn/
2. https://bitbili.net/gentoo-linux-installation-and-usage-tutorial.html
3. https://blog.bugsur.xyz/gentoo-handbook-installation
4. [Sakaki Bootstrap](https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki's_EFI_Install_Guide/Building_the_Gentoo_Base_System_Minus_Kernel)

## Footnotes

------

[1](https://endlesspeak.github.io/docs/build/operating-system-installation/linux-technology-3-3-gentoo-linux-installation/#footnote-reference-1)

[Intel处理器及图形显卡](https://wiki.gentoo.org/wiki/Intel)

[2](https://endlesspeak.github.io/docs/build/operating-system-installation/linux-technology-3-3-gentoo-linux-installation/#footnote-reference-2)

[Ccache配置](https://wiki.gentoo.org/wiki/Ccache)

[3](https://endlesspeak.github.io/docs/build/operating-system-installation/linux-technology-3-3-gentoo-linux-installation/#footnote-reference-3)

[Systemd-networkd 配置](https://wiki.archlinux.org/title/Systemd-networkd)

[4](https://endlesspeak.github.io/docs/build/operating-system-installation/linux-technology-3-3-gentoo-linux-installation/#footnote-reference-4)

[Iwd配置](https://wiki.archlinux.org/title/Iwd)