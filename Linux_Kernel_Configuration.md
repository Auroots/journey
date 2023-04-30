# Linux Kernel Configuration

   ## 写在前面

   ### 参考文献

   1. LINUX 内核技术手册 LINUX KERNEL IN A NUTSHELL
   2. Linux-4.4-x86_64 内核配置选项简介 参阅更多 [金步国作品集](https://endlesspeak.github.io/docs/build/operating-system-configuration/linux-technology-5-4-kernel/www.jinbuguo.com)

   ### 写作动机

   1. 工作应用
      1. 嵌入式实时操作系统需要裁剪内核以获得专用性、适配性和性能
      2. 定制内核是成为 Linux 内核开发者的基本任务
   2. 个人应用
      1. Linux From Scratch
      2. Special Hardware Adjustment

   ## 构建内核

   ### 源码获取

   Gentoo 官方以软件包的形式提供内核源码，因此可用 emerge 直接安装。

   ```shell
     emerge -av sys-kernel/gentoo-source
     emerge -av sys-kernel/gentoo-kernel
     emerge -av sys-kernel/genkernel
   ```

   Arch 官方提供的内核是编译过的，如需获得内核源码，需在 https://wiki.archlinux.org/title/Kernel 处选择版本，然后下载或克隆下来。

   ```shell
     git clone https://github.com/archlinux/linux.git ./src/linux-5.19 --depth=1
   ```

   Gentoo 由于 `eselect` 的存在，可以将源码保存到 `/usr/src` 目录下；而 Arch 由于需要手动克隆，因此建议放到 `~` 下。

   ### 配置

   通过下面的命令配置内核，生成的配置文件为 `.config` 。

   #### 最基本的方法

   使用 `make config` ，内核配置程序将逐步跟踪每一个配置选项并向用户询问，回答方式是 `[y/n/m/?]` y 直接构建为内核一部分； n 不构建； m 构建成模块，按需加载； ? 打印帮助

   #### 使用默认配置选项

   1. `make defconfig` 或 `make ${PLATFORM}_defconfig` 基于某种体系结构的一般性选项。
   2. `make localmodconfig` 针对当前硬件进行适配性优化，可选的组件以模块方式加载。
   3. `make localyesconfig` 对所有可选的组件均构建成为内核的一部分。
   4. `make oldconfig` 根据之前的配置自动回答，仅向用户询问新配置项。

   #### 对所有配置选项统一操作

   1. `make allyesconfig` 尽可能所有配置项均编译进内核
   2. `make allmodconfig` 尽可能所有配置项都以模块方式构建
   3. `make allnoconfig` 尽可能所有配置项都不构建
   4. `make randconfig` 是否选择构建配置项交给天意。
   5. `make tinyconfig` 构建一个可能的最小内核。(除开配置项外还有其他的缩减)

   #### 手动配置

   1. `make menuconfig` 或 `make nconfig` 命令行配置方法，适用于 `tty` 环境，特别地，后者界面中斜体表示选中
   2. `make xconfig` 或 `make gconfig` 图形化配置方法，前者基于 `QT` 后者基于 `GTK`

   ### 构建

   #### 全部构建

   特别地，不应该在 root 权限下构建内核，而应该使用权限代理工具，如 `sudo` 或 `doas`

   ```shell
     make #单线程
     make -j6 #多线程
     make -j6 modules_install #安装构建好的模块
     make install #安装内核映像
   ```

   #### 部分构建

   1. 指明特定的构建位置 `make drivers/usb/serial`
   2. 构建模块 `make M=dirvers/usb/serial`
   3. 链接合并 `make`

   #### 输出位置

   例如，如果源码保存在只读位置上；或需要以普通身份构建内核，而源码在系统目录中，执行下面的命令：~make O=~/Develop/src/linux~

   #### 交叉编译

   交叉编译的意思是编译环境和运行环境不同。 内核的交叉编译特性允许更强大的机器为较小的嵌入式系统构建内核。

   ```shell
     make ARCH=x86_64 defconfig
     make ARCH=arm CROSS_COMPILE=/usr/bin/arm-linux-
   ```

   #### 编译器

   如需选择其他编译器程序，请输入： `make CC="ccache gcc"` `make CC="ccache distcc"`

   ### 清理构建

   1. `make clean` 移除几乎所有生成的文件，但保留配置文件和足够的构建支持以构建外部模块
   2. `make mrproper` 移除所有生成的文件，包括配置文件和一些备份文件
   3. `make distclean` 移除 **所有** 生成的文件，包括任何可能的补丁文件等

   ### 升级构建

   1. 获取新的源代码（可以重新克隆，也可以直接从远程合并） 无论如何，避免以为源码树打 patch 的方式更新。如遇冲突，工作量太大。
   2. `make oldconfig`

   ## 配置驱动

   ### 发行版配置

   各个发行版都提供内核配置文件，它们保存在 `/proc/config.gz` 中。如需以该配置作为基础配置内核，运行下面的命令

   ```shell
     zcat /proc/config.gz > ~/Develop/src/linux
     cp /prco/config.gz ~/Develop/src/linux
     gzip -dv config.gz
   ```

   ### 设备查找

   #### 查找驱动名称

   通过下面的脚本查找硬件设备所依赖的内核驱动的名称。

   ```shell
     #!/bin/sh
     #
     # Find all modules and drivers for a given class device.
     #
   
     if [ $# != "1" ] ; then
         # $# 表示的是传递给脚本或函数的参数个数(argc)
         echo
         echo "Script to display the drivers and modules for a specified sysfs class device"
         echo "usage: $0 <CLASS_NAME>"
         echo
         echo "example usage:"
         echo "      $0 sda"
         # $0 表示的是当前脚本的文件名
         echo "Will show all drivers and modules for the sda block device."
         echo
         exit 1
     fi
   
     DEV=$1
     # $1表示的是传递给脚本或函数的参数(在本脚本中只接受一个参数)
   
     if test -e "$1"; then
         # test -e测试文件是否存在，这里测试是否是当前目录文件
         DEVPATH=$1
     else
         # find sysfs device directory for device
         # 从 /sys/class 目录查找设备
         DEVPATH=$(find /sys/class -name "$1" | head -1)
         # find [path] -name [filename] 根据设备名在对应路径查找
         # 管道 head -1显示的是第一个结果
         test -z "$DEVPATH" && DEVPATH=$(find /sys/block -name "$1" | head -1)
         # test -z当且仅当字符串是0时返回真，否则返回假
         # 当前一条语句顺利执行，则此处短路；前一条语句无结果才继续执行后面
         test -z "$DEVPATH" && DEVPATH=$(find /sys/bus -name "$1" | head -1)
         if ! test -e "$DEVPATH"; then
             echo "no device found"
             exit 1
         fi
     fi
   
     echo "looking at sysfs device: $DEVPATH"
   
     if test -L "$DEVPATH"; then
         # resolve class device link to device directory
         # test -L 检查字符串是否存在且是链接文件
         DEVPATH=$(readlink -f $DEVPATH)
         # readlink 打印解析的符号链接或规范文件名
         # -f 递归跟随给出文件名的所有符号链接以标准化，除最后一个外所有组件必须存在
         echo "resolve link to: $DEVPATH"
     fi
   
     if test -d "$DEVPATH"; then
         # resolve old-style "device" link to the parent device
         # test -d 检查是否是目录类型
         PARENT="$DEVPATH";
         while test "$PARENT" != "/"; do
             if test -L "$PARENT/device"; then
                 DEVPATH=$(readlink -f $PARENT/device)
                 echo "follow 'device' link to parent: $DEVPATH"
                 break
             fi
             PARENT=$(dirname $PARENT)
             # dirname是寻找当前目录的上级目录
         done
     fi
   
     while test "$DEVPATH" != "/"; do
         DRIVERPATH=
         DRIVER=
         MODULEPATH=
         MODULE=
         if test -e $DEVPATH/driver; then
             DRIVERPATH=$(readlink -f $DEVPATH/driver)
             DRIVER=$(basename $DRIVERPATH)
             # basename 是去除路径得到文件名
             echo -n "found driver: $DRIVER"
             if test -e $DRIVERPATH/module; then
                 MODULEPATH=$(readlink -f $DRIVERPATH/module)
                 MODULE=$(basename $MODULEPATH)
                 echo -n " from module: $MODULE"
             fi
             echo
         fi
   
         DEVPATH=$(dirname $DEVPATH)
     done
   ```

   #### 查找内核选项

   通过上面脚本查找到的硬件设备对应的内核驱动名称，到内核的源码树中读取 `Makefile` 并从中找到对应的真正的内核选项名称。

   ```shell
     find -type f -name Makefile | xargs grep "ModulesName"
   ```

   特别地：

   1. 有些选项的内核驱动名是以下划线连接的，而在内核选项名称中是以横线连接，因此寻找时需要尝试。
   2. 有些设备是系统内核自行创建的虚拟设备(逻辑设备)，因此脚本查找不到物理驱动(因为对逻辑设备来说本来就不需要物理驱动)

   查找到内核选项名称后，进入配置界面，通过搜索查看对应需要配置的选项。

   #### 快速查找设备

   通过下面的脚本自动化查找硬件驱动，弊端是会掺杂很多无关的驱动。

   ```shell
     #!/bin/bash
     for i in `find /sys/ -name modalias -exec cat {} \;`; do
         /sbin/modprobe --config /dev/null --show-depends $i ;
     done | rev | cut -f 1 -d '/' | rev | sort -u
   ```

   脚本解释：

   1. 查找 `/sys` 下名称为 `modalias` 的所有文件 `modalias` 是一个 `sysfs` 技巧，它将硬件信息导出到该文件；参考 [Modalias-ArchWiki](https://endlesspeak.github.io/docs/build/operating-system-configuration/linux-technology-5-4-kernel/wiki.archlinux.org/title/Modalias)
   2. 依次查看找到的文件，其中 `{}` 是占位符，表示找到的文件的名字； 其中用转义 `\;` 表示 `-exec` 的结束，因为 `shell` 已使用 `;` 作为命令分隔符；
   3. 调用 `/sbin/modprobe` 检查内核依赖，列出模块的依赖项(包括模块本身)，使用缺省设置
   4. 反转两次字符，在两次反转之间取第一个字段，分隔符是斜杠，目的是得到最后一段字符
   5. 将结果排序输出，=-u= 表示 unqiue ，删除重复行

   ### 添加固件

   Gentoo 和 Arch 支持通过安装软件包组的方式安装固件。安装完成的路径在 `/lib/modules`

   ```shell
     sudo emerge sys-kernel/linux-firmware
     sudo pacman linux-firmware
   ```

   向内核中添加固件的步骤： Device Drivers -> Generic Driver Options -> Firmware loader -> Build named firmware blobs into the kernel binary

   特别地，只需要填写固件名，构建时系统会自动去源码目录下的 `./modules` 下去寻找，需要更改目录为 `/lib/modules` ，同时多个固件之间以空格隔开。

   如果硬件驱动是直接编译进内核，且无法正常工作，则需要将固件编译到内核中。因此硬件不能正常工作时：

   1. 排查问题
      1. `lspci -k` 观察硬件驱动是否正确加载
      2. `sudo dmesg | grep "error"`
   2. 解决办法
      1. 尝试把问题所在的硬件驱动编译成模块重试
      2. 尝试将固件编译进内核，例如 `regulatory.db`
      3. 尝试查找资料，有的硬件需要其他操作 如笔记本 3.5mm 耳机接口需要在 `/etc/modprobe.d/` 中单独编辑配置，参考 [Correctly Detected Microphone](https://wiki.archlinux.org/title/Advanced_Linux_Sound_Architecture#Correctly_detect_microphone_plugged_in_a_4-pin_3.5mm_(TRRS)_jack)

   ## 定制内核

   ### General Setup

   1. Kernel compression mode
      1. LZ4 高压缩比的同时性能最强
      2. XZ 极高压缩比，但性能有损失
   2. POSIX Message Queues
      1. 在 POSIX 消息队列中，每条消息都有一个优先级，它决定了进程接收消息的先后顺序。
      2. 如果你想编译和运行那些使用"mq_*"系统调用的程序，或者需要使用 Docker 容器,就必须开启此选项。
      3. POSIX 消息队列可以作为"mqueue"文件系统挂载以方便用户对队列进行操作。不确定的选"Y".
   3. Enable process_vm_readv/writev syscalls
      1. 提供 `process_vm_readv` 和 `writev syscalls` 系统调用
      2. 允许程序以正确的优先级直接读或写另一进程的地址空间
   4. uselib syscall 建议禁止，因为现在大部分人在用 `glibc` 而不是 `libc5` 或更早
   5. Auditing support
      1. 提供应用于内核子系统的审计基础设施，例如 `SELinux` 等等
      2. 有关审计系统调用的支持包含在支持它的体系结构中
   6. Timers subsystem
      1. Timer tick handling
         1. Periodic timer ticks(constant rate,no dynticks) 强制按固定频率触发时钟中断，最耗电，当然性能最好
         2. Idle dynticks system(tickless idle) 空闲状态不产生不必要的时钟中断，降低处理器能耗
         3. Full dynticks system(tickless) 即使在忙碌状态也尽可能关闭所有时钟中断
      2. High Resolution Timer Support
         1. 高精度定时器(hrtimer)用于取代传统 timer wheel(基于 jiffies 定时器)的时钟子系统
         2. 可以降低与内核其他模块的耦合性,还可以提供比 1 毫秒更高的精度(因为它可以读取 HPET/TSC 等新型硬件时钟源)
         3. 可以更好的支持音视频等对时间精度要求较高的应用，如 pulseAudio 等等，因此建议选"Y"
         4. 特别地，此处"定时器"是指"软件定时器",而不是主板或 CPU 上集成的硬件时钟发生器(ACPI PM Timer/HPET Timer/TSC Timer)
   7. Preemption Model 内核抢占模式
      1. No Forced Preemption 禁止内核抢占，适合服务器、科学计算
      2. Voluntary Kernel Preemption 自愿内核抢占，提高响应速度，对吞吐量有影响
      3. Preemptible Kernel 主动内核抢占，允许抢占所有内核代码，适合实时操作系统、高响应桌面环境，但对吞吐量的影响也更大
   8. CPU/Task time and stats accounting
      1. CPU time accounting
         1. Simple tick based cputime accounting 简单的基于滴答的统计,适用于大多数场合
         2. Full dynticks CPU time accounting
            1. 利用上下文跟踪子系统,通过观察每一个内核与用户空间的边界进行统计
            2. 该选项对性能有显著的不良影响,目前仅用于完全滴答子系统的开发调试
      2. BSD Process Accounting
         1. 用户空间程序可以要求内核将进程的统计信息写入一个指定的文件
         2. 主要包括进程的创建时间/创建者/内存占用等信息
         3. 内核开发者认为这通常是一个好主意，建议选择
   9. Namespaces support 命名空间支持.主要用于支持基于容器的轻量级虚拟化技术
      1. UTS namespace uname()系统调用的命名空间支持
      2. IPC namespace 进程间通信对象 ID 的命名空间支持
      3. User namespace
         1. 允许容器使用 user 命名空间
         2. 建议同时开启 `CONFIG_MEMCG` 和 `CONFIG_MEMCG_KMEM`
         3. systemd 服务单元依赖该项
      4. PID namespaces 进程 PID 命名空间支持
      5. Network namespaces 网络协议栈的命名空间支持，systemd 服务单元依赖该项。
   10. Checkpoint/restore support
       1. 在内核中添加"检查点/恢复"支持 添加一些辅助的代码用于设置进程的 text, data, heap 段,并且在 /proc 文件系统中添加一些额外的条目
       2. 用于检测两个进程是否共享同一个内核资源的 kcmp()系统调用依赖于它
       3. 使用 systemd 建议开启此项
       4. 使用 intel 核显驱动 mesa 建议开启此项
   11. Automatic process group scheduling
       1. 每个 tty 动态地创建任务分组(cgroup)，可以降低高负载情况下的桌面延迟
       2. 桌面用户建议开启，而服务器建议关闭.
   12. Initial RAM filesystem and RAM disk (initramfs/initrd) support 初始内存文件系统，占用额外的容量和性能。
   13. Compiler optimization level 编译优化级别
       1. Optimize for performance O2 级别的优化
       2. Optimize for size
          1. Os 级别的优化，可以得到更小的内核但运行速度更慢
          2. 通常用于专用操作系统，例如嵌入式系统

   ### Processor type and features

   中央处理器(CPU)类型及特性

   1. Symmetric multi-processing support 激活对 SMP(对称多处理器)的支持。如果是多个 CPU(包括多个 CPU 核心)选择此项。
   2. Enable MPS table 仅古董级 SMP 系统需要，64 位系统支持 ACPI，因此可以安全地关闭
   3. x86 CPU resource control support
      1. 启用 x86 CPU 资源控制支持，为 CPU 的系统资源的分配和监控提供支持。
      2. Intel 称之为 Intel 资源控制器技术
      3. AMD 称之为 AMD 平台服务质量
   4. Support for extended (non-PC) x86 platforms
      1. 支持非标准的 PC 平台: Numascale NumaChip, ScaleMP vSMP, SGI Ultraviolet
      2. 绝大多数情况下不会使用这些平台
   5. Intel Low Power Subsystem Support 为 `Intel Lynx Point PCH` 或更高级别芯片提供因特尔低电量子系统支持
   6. Linux guest support 如果该内核在虚拟机中运行，开启本选项，否则就关闭
   7. Processor family 按实际使用的处理器类型进行选择。
      1. Generic-x86-64 表示通用于所有 x86-64 平台
      2. Core 2/newer Xeon 支持 Core2 之后的所有 IntelCPU，包括 I3，I5，I7，I9
      3. Opteron/Athlon64/Hammer/K8 支持 AMD 类型的 CPU
   8. Maximum number of CPUs 支持的最大逻辑 CPU 数量
   9. Multi-core scheduler support
      1. 针对多核 CPU 进行调度策略优化
      2. 会略微增加日常开支
      3. 对计算机不一定会很有用，可能对 CPU 集群更有效
   10. Reroute for broken boot IRQs 对某些(陈旧的)芯片组 bug 的修复功能
   11. Machine Check / overheating reporting
       1. CPU 检测到硬件故障时通知内核，以使内核采取相应的措施
       2. 只需要开启对应 CPU 的支持(Intel or AMD)
   12. Machine check injector support MCE 注入支持，仅用于内核调试
   13. Performance monitor support
       1. 对 CPU 进行性能监控的框架支持
       2. 只需要开启对应 CPU 的支持(Intel or AMD)
   14. IOPERM and IOPL Emulation 提供设置端口权限的系统调用，以获取对端口进行 I/O 操作权限
   15. CPU microcode loading support CPU 的微码支持，提高 CPU 的稳定性
   16. Enable 5-level page tables support
       1. 5 级页表支持仅在使用很大的内存(64TiB 物理地址空间或 256TiB 逻辑地址空间)和极高线程时才建议启用
       2. 开启后支持 4PiB 物理地址空间或 128PiB 逻辑地址空间
       3. 即使是计算机集群或超级计算机，对其中的单个计算机也很少有如此高内存的情况(当然确实存在)
       4. 该选项是对未来大内存地址空间的一种实现目标
   17. NUMA Memory Allocation
       1. 开启 NUMA(Non Uniform Memory Access) 支持
       2. 虽然说集成了内存控制器的 CPU 都属于 NUMA 架构，但对于大多数只有一颗物理 CPU 的个人电脑而言，即使支持 NUMA 架构，也没必要开启此特性.
       3. 可以参考 [SMP/NUMA/MPP 体系结构对比](https://www.cnblogs.com/yubo/archive/2010/04/23/1718810.html)
          1. SMP for Symmetric multi-processor
          2. NUMA for Non Uniform Memory Access
          3. MPP for Massive Parallel Processing
       4. 对于不支持"虚拟 NUMA"或"虚拟 NUMA"被禁用的虚拟机(即使所在的物理机是 NUMA 系统)，应该关闭此项
   18. Check for low memory corruption
       1. 低位内存脏数据检查，可关可不关
       2. 需要该选项与 `memory_corruption_check=1` 内核引导参数配合使用 通过开启 `Set the default setting of memory_corruption_check` 选项设置默认开启上述选项
       3. 该选项的原理是在 BIOS 存在问题时：
          1. 每 60s 扫描一次 扫描周期可通过 `memory_corruption_check_period` 内核参数调整
          2. 扫描范围是 0-64k 内存地址 扫描范围可通过 `memory_corruption_check_size` 内核参数调整
   19. Memory Type Range Register support 存储器类型范围寄存器支持 其下级选项 MTRR cleanup support 是将 MTRR 内存布局由连续转为离散，以利于 X 驱动添加写回条目
       1. MTRR cleanup enable value 建议图形界面用户设为"1"，仅在开启后导致无法正常启动或者显卡驱动不能正常工作的情况下才需要关闭
       2. MTRR cleanup spare reg num 指示内核可供清理或修改的内存段个数(参考 `/proc/mtrr`) 通常保持默认值"1"，修改通常是为了解决某些 MTRR 故障。
   20. Memory Protection Keys 内存保护密钥提供一种用于强制执行基于页面的保护，但在应用程序更改保护域时不需要修改页面表
   21. TSX enable mode
       1. Intel 事务扩展技术是 intel 为旗下的 CPU 开发的一项优化指令集
       2. 存在僵尸负载漏洞（ZombieLoad）
       3. 开启 TSX 后，在编译程序时速度有小幅度的提升
       4. 牺牲内核安全性换取性能
   22. kexec system call
       1. 提供系统调用，允许在运行某内核后关闭它本身并运行另一个内核，即使不是 Linux 内核
       2. 由于其所依赖的硬件接口在快速变化，因此无法给出好的建议
       3. kernel crash dumps 依赖于 kexec 系统调用，因此应对两者作相同的选择

   ### Mitigations for speculative execution vulnerabilities

   缓解或修复推断性执行漏洞的内核补丁

   1. Avoid speculative indirect branches in kernel
      1. CPU 会提前执行 `jmp` 或 `call` 等跳转指令的下一句，原理是将该句存到 `RSB` 栈中
      2. 病毒可能展开 CPU 预测分支执行，因此需要在该句之后添上一端无用的死循环代码，使 CPU 预测分支执行无用化
      3. redpoline 因此而生，显然该补丁会带来性能损失
   2. Enable IBPB on kernel entry 为内核编译 `retbleed=ibpb` 补丁
   3. Enable IBRS on kernel entry 为内核编译 `spectre_v2=ibrs` 补丁

   ### Power management and ACPI options

   1. Suspend to RAM and standby 即休眠到内存。系统休眠后，除了内存之外，其他所有部件都停止工作，重开机之后可以直接从内存中恢复运行状态 通过命令 `echo mem > /sys/power/state` 使用此功能
   2. Hibernation (aka 'suspend to disk') 即休眠到硬盘。其他同上 通过命令 `echo disk > /sys/power/state` 使用此功能，前提是有内核引导参数 `resume=/dev/swappartition`
   3. Opportunistic sleep 激进的休眠方案，来源于安卓。理念是只要不工作，就开始休眠。
   4. ACPI(Advanced Configuration and Power Interface) 高级配置与电源接口，包括了软件和硬件方面的规范,目前已被软硬件厂商广泛支持,并且取代了许多过去的配置与电源管理接口
   5. CPU Idle
      1. 该指令可以让 CPU 在空闲时"打盹"以节约电力和减少发热
      2. 只要是支持 ACPI 的 CPU 就应该开启，又由于所有 64 位 CPU 都已支持 ACPI,所以开启
   6. Cpuidle Driver for Intel Processors
      1. 该选项是专用于 Intel CPU 的 cpuidle 驱动
      2. `CONFIG_CPU_IDLE` 则可用于非 Intel 的 CPU.

   ### Binary Emulations

   1. IA32 Emulation 提供兼容运行 32 位的应用程序支持(multilib)，建议开启。
   2. x32 ABI for 64-bit mode 建议禁止

   ### General architecture-dependent options

   1. Kprobes 主要用于内核调试，允许追踪几乎任何内核地址并执行回调函数
   2. Optimize very unlikely/likely branches
      1. 启用透明的分支优化，使得执行几乎总是正确/错误的分支条件更少；
      2. 某些性能敏感的内核代码都有这样的分支并支持该优化技术 例如跟踪点、调度程序、网络、基于内核的虚拟机(KVM)等
      3. 此技术降低了开销，更多的是对处理器的分支预测施加压力，通常会使内核速度更快，而条件的更新速度则更慢，但这种情况总是非常罕见的
   3. Enable seccomp to safely execute untrusted bytecode
      1. 启用 `seccomp` 安全执行不可信任代码
      2. 仅嵌入式系统应当否决
   4. Use a virtually-mapped stack 该选项使用带保护页的虚拟映射内核堆栈，它的作用是立即捕获内核堆栈溢出而不是在造成难以诊断的损失之后。 开启需要支持一些条件，详见选项说明。

   ### Enable loadable module support

   激活可加载模块支持

   1. Forced module loading 允许使用 `modprobe --force` 命令，它将在不校验版本信息的情况下强制加载模块，建议关闭
   2. Module unloading
      1. 允许卸载已经加载的模块
      2. 如果将模块静态编译进内核中，那么内核的执行效率会更好
      3. 如果代码作为动态模块加载，那么不使用时可以减少内核的内存使用并减少启动的时间，然而内核和模块在内存上相互独立又会影响内核的执行性能
      4. Forced module unloading 允许使用 `rmmod -f` 强制卸载正在使用的模块，建议关闭
   3. Module versioning support 允许当前内核使用为其他内核版本编译的模块,可能会造成系统崩溃，建议关闭

   ### Executable file formats

   可执行文件格式/仿真

   1. Kernel support for ELF binaries ELF 是最常用的跨平台二进制文件格式,支持动态连接,支持不同的硬件平台,支持不同的操作系统.
   2. Write ELF core dumps with partial segments 当打算在此 Linux 上开发应用程序或者帮助调试 bug 时开启
   3. Kernel support for scripts starting with #! 支持以 `#!/path/to/interpreter` 运行的脚本 **务必选 Y，除非你知道你自己在做什么**
   4. Kernel support for MISC binaries
      1. 允许插入二进制封装层到内核中
      2. 理论上允许直接运行 Java,.NET,Python,Emacs-lisp 等等

   ### Enable the block layer

   激活块设备支持

   1. Partition Types 支持不同的磁盘分区格式，务必选择此项
   2. IO Schedulers
      1. 快速响应的实时系统可以选择 `BFQ I/O scheduler` ，即 BFQ 调度器
      2. 在开启了 BFQ 的条件下，可以禁用另外两个调度器

   ### Memory Management options

   1. Support for paging of anonymous memory (swap)
      1. 使内核支持虚拟内存，即交换分区
      2. 仅在 PC 上使用，嵌入式系统不应开启，因为嵌入式系统主要使用 `flash` ，磁盘寿命远大于闪存
   2. SLAB allocator 选择内存分配器
      1. SLAB 该内存分配器在大多数情况下都具有良好的适应性
      2. SLUB
         1. SLUB 与 SLAB 兼容,但通过取消大量的队列和相关开销,简化了 slab 的结构
         2. 在多核时 SLUB 拥有比 SLAB 更好的性能和更好的系统可伸缩性
   3. Low address space to protect from user allocation 建议设置为 65536
   4. Transparent Hugepages support
      1. 允许内核使用大页面和大快表，能够提高应用程序计算性能
      2. 原理是
         1. 加快内存分配期间的缺页中断速度
         2. 减少快表未命中的数量
         3. 加快页表的整体遍历(主要开销是换页而非向下查找)
   5. Enable idle page tracking 此功能允许估计在给定时间段内未触及的用户页面的数量，该信息可用于调整内存 `cgroup` 限制或计算集群内的放置作业。

   ## 检查选项

   ### Basic

   1. CONFIG_FB FB for framebuffer
      1. 帧缓冲设备是对图形硬件的抽象
      2. 它把屏幕上的所有像素点都直接映射到一段线性的内存空间，为软件提供了访问图形硬件的统一接口，软件不需要了解硬件的底层细节(例如寄存器)，只要简单的改变相应内存位置的值，就能改变屏幕上显示的内容(颜色/亮度等)
      3. Xorg 的高度可移植性根源于此，图形界面用户必选
   2. CONFIG_FRAMEBUFFER_CONSOLE
      1. 基于 Framebuffer 的图形模式控制台
      2. KMS 特性依赖于它.CJKTTY 补丁也依赖于它
      3. 桌面用户必选"Y"(使用了 CONFIG_DRM_*的用户必须开启)
      4. 服务器以 UEFI 方式启动的也必选"Y".
   3. CONFIG_FW_LOADER 向内核中编译固件
      1. CONFIG_EXTRA_FIRMWARE
      2. CONFIG_EXTRA_FIRMWARE_DIR

   ### Networking support

   1. CONFIG_PACKET
   2. CONFIG_UNIX
   3. CONFIG_INET
   4. CONFIG_NETFILTER Netfilter 可以对数据包进行过滤和修改,可以作为
      1. 防火墙(packet filter or proxy-based)
      2. 网关 NAT
      3. 代理 proxy
      4. 网桥
   5. NET_REDIRECT
   6. IPTABLES 参考 [GentooWiki-iptables](https://wiki.gentoo.org/wiki/Iptables)
   7. NFTABLES 参考 [GentooWiki-nftables](https://wiki.gentoo.org/wiki/Nftables)
   8. NAT
      1. NETFILTER_XT_NAT
      2. NET_ACT_NAT
      3. NF_NAT
      4. NF_NAT_FTP
      5. NF_NAT_IRC
      6. NF_NAT_MASQUERADE
      7. NF_NAT_REDIRECT 建议搜索 `REDIRECT` ，将所有实现网络透明代理的均选中
      8. NFT_NAT
   9. PPP 参考 [GentooWiki-PPP](https://wiki.gentoo.org/wiki/PPP)

   ### Graphics support

   1. CONFIG_AGP GART(图形地址重映射表)可以看做一种被各种显卡(不只是 AGP 显卡,还包括 PCI-E 显卡与集成显卡以及核心显卡)使用的"伪 IOMMU"(参见 `CONFIG_GART_IOMMU` 选项),它将物理地址不连续的系统内存映射成连续的"显存"供 GPU 使用
      1. CONFIG_AGP_AMD64 提供 AMD 支持
      2. CONFIG_AGP_INTEL 提供 Intel 支持
      3. CONFIG_AGP_SIS 提供 SIS 芯片组支持
      4. CONFIG_AGP_VIA 提供 VIA 芯片组支持
   2. CONFIG_VGA_SWITCHEROO 用于多个显卡之间的切换
   3. CONFIG_DRM Direct Rendering Manager 管理的是 Direct Rendering Infrastructure 主要用于硬件 3D 加速
   4. CONFIG_SYSFB_SIMPLEFB 使用 VESA 和 UEFI 建议选择
   5. CONFIG_DRM_SIMPLEDRM
   6. CONFIG_FRAMERBUFFER_CONSOLE 见前文
   7. CONFIG_LOGO 启动时显示 LOGO
   8. Nvidia 有关英伟达显卡的问题，参阅文档。

   ### Sound Card support

   如果是笔记本，建议以模块形式编译本部分(尤其是 ALSA)