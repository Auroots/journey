# kernel 配置

https://github.com/Frogging-Family/linux-tkg.git

### 配置工具

| 命令                  | 描述                                                         |
| :-------------------- | :----------------------------------------------------------- |
| **make config**       | 基于文本的配置。按照选项依次提示。所有的选项都必须回答，并且不能随意访问之前的选项。 |
| **make menuconfig**   | 基于 ncurses 的伪图形化菜单（只能文本化输入）。浏览菜单修改所需的选项。 |
| **make defconfig**    | 生成一个来自 ARCH 提供的 defconfig 文件的默认配置。使用这个选项，使用这个选项可以回到源代码中的默认配置文件。 |
| **make nconfig**      | 基于 ncurses 的伪图形化菜单。需要安装 [sys-libs/ncurses](https://packages.gentoo.org/packages/sys-libs/ncurses)。 |
| **make xconfig**      | 使用 QT5 的图形化菜单。需要安装 [dev-qt/qtwidgets](https://packages.gentoo.org/packages/dev-qt/qtwidgets)。 |
| **make gconfig**      | 使用 GTK 的图形化菜单。需要安装 [x11-libs/gtk+](https://packages.gentoo.org/packages/x11-libs/gtk+)，[dev-libs/glib](https://packages.gentoo.org/packages/dev-libs/glib) 和 [gnome-base/libglade](https://packages.gentoo.org/packages/gnome-base/libglade)。 |
| **make oldconfig**    | 查看内核版本之间的更改，并且为内核更新创建新的 .config。     |
| **make olddefconfig** | 生成一个来自 ARCH 提供的 defconfig 文件的新配置。同时，维持所有之前在 /usr/src/linux/.config 中 .config 文件的选项。这是一种快速安全的升级配置文件方法，它具有硬件支持的所有配置选项，同时获得错误修复和安全补丁。 |
| **make allyesconfig** | 在内核启用所有的配置选项。它将为 `*` 设置为 *all* 内核选项。在使用此选项之前，确保备份了最近的内核配置！ |
| **make allmodconfig** | 在内核中启用所有的模块                                       |

- 打补丁命令

```
cd /usr/src/linux
patch -p1 < xxx.patch 
make menuconfig
```





- 补丁 ([0006-add-acs-overrides_iommu.patch](https://github.com/Frogging-Family/linux-tkg/blob/master/linux-tkg-patches/6.0/0006-add-acs-overrides_iommu.patch))

```
Processor type and features  --->
	Timer frequency (100 HZ)  --->
```

- 编译优化 ( [0013-optimize_harder_O3.patch](https://github.com/Frogging-Family/linux-tkg/blob/master/linux-tkg-patches/6.0/0013-optimize_harder_O3.patch) )

```
General setup  --->
    Compiler optimization level (Optimize for performance (-O2))  --->
        Optimize for performance (-O3) 
```



i915









- **其他内核**

```bash
gentoo-sources
ck-sources
git-sources
```

- **自动安装内核**

```bash
emerge --ask sys-kernel/gentoo-sources
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
make modules_install install
emerge --ask sys-kernel/genkernel
genkernel --install initramfs
```



- ## **手动安装内核**

```bash
# gentoo-sources
emerge --ask sys-kernel/linux-firmware
emerge --ask sys-apps/pciutils
emerge --ask sys-kernel/dracut
emerge --ask sys-devel/clang
emerge --ask sys-devel/ccache
emerge --ask sys-kernel/gentoo-sources
# 其他包
emerge --ask sys-apps/nvme-cli  # nvme支持

# 解压命令 
tar -vxf *linux*.tar.xz

# 编辑 config
CONFIG_CC_VERSION_TESTS="clang version 15.0.6"
CONFIG_GCC_VERSION=0
CONFIG_LD_VERSION=0
CONFIG_CC_IS_CLANG=y
CONFIG_CC_IS_LLD=y
CONFIG_CLANG_VERSION=100001
CONFIG_CC_CAN_LINK=y
CONFIG_CC_CAN_LINK_STATIC=y
CONFIG_CC_HAS_ASM_GOTO=y
CONFIG_TOOLS_SUPPORT_RELR=y
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_TABLE_SORT=y
CONFIG_THREAD_INFO_IN_TASK=y

# 选择内核
eselect kernel list
	Available kernel symlink targets:
 	 [1]   linux-4.9.16-gentoo
 	 
eselect kernel set 1 #选择内核

cd /usr/src/linux
make menuconfig

# 设置完成后
make -jX #将X替换为你想编译时的线程数
make modules_install
make install

cd /boot
dracut --hostonly
```





- 网络环境算法

```bash
#查看可以的算法
sysctl net.ipv4.tcp_available_congestion_control
#查看正在使用的算法
sysctl net.ipv4.tcp_congestion_control
```




```bash
# XanMod Kernel
emerge --ask sys-kernel/linux-firmware
emerge --ask sys-apps/pciutils
emerge --ask sys-kernel/dracut


eselect kernel list
	Available kernel symlink targets:
 	 [1]   linux-4.9.16-gentoo
 	 
eselect kernel set 1 #选择内核

cd /usr/src/linux
make menuconfig

# 设置完成后
make -jX #将X替换为你想编译时的线程数
make modules_install
make install

cd /boot
dracut --hostonly
```



- **选择所需要的文件系统**

```kotlin
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

- **启用 SCSI 磁盘支持**

``` kotlin
Device Drivers  --->
   SCSI device support  --->
      <*> SCSI device support
      <*> SCSI disk support
      <*> SCSI CDROM support
 
      [ ] SCSI low-level drivers  --->
 
   <*> Serial ATA and Parallel ATA drivers (libata)  --->
```

- **激活USB输入设备的支持**

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

- **选择处理器类型和功能**

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
Binary Emulations --->
   [*] IA32 Emulation
```

-  **启用对GPT的支持**

```
-*- Enable the block layer --->
   Partition Types --->
      [*] Advanced partition selection
      [*] EFI GUID Partition support
```

-  **启用对UEFI的支持**

```
Processor type and features  --->
    [*] EFI runtime service support 
    [*]   EFI stub support
    [*]     EFI mixed-mode support
 
Device Drivers
    Firmware Drivers  --->
        EFI (Extensible Firmware Interface) Support  --->
            <*> EFI Variable Support via sysfs
    Graphics support  --->
        Frame buffer Devices  --->
            <*> Support for frame buffer devices  --->
                [*]   EFI-based Framebuffer Support
```

- **内核中启用 evdev**

```
Device Drivers --->
  Input device support --->
  <*>  Event interface
```

- **禁用旧版帧缓冲支持并启用基本控制台 FB 支持**

```
Device Drivers --->
   Graphics support --->
      Frame Buffer Devices --->
         <*> Support for frame buffer devices --->
         ## (Disable all drivers, including VGA, Intel, NVIDIA, and ATI, except EFI-based Framebuffer Support, only if you are using UEFI)
 
      ## (Further down, enable basic console support. KMS uses this.)
      Console display driver support --->
         <*>  Framebuffer Console Support
```

-  **英伟达内核**

```
Device Drivers --->
   Graphics support --->
      <M/*>  Nouveau (NVIDIA) cards
```

- **旧卡：AMD/ATI Radeon settings**

```
## (Setup the kernel to use the radeon-ucode firmware, optional if "ATI Radeon" below is M)
Device Drivers --->
   Generic Driver Options --->
   [*]  Include in-kernel firmware blobs in kernel binary
  ## # ATI card specific, (see Radeon page for details which firmware files to include)
   (radeon/<CARD-MODEL>.bin ...)
  ## # Specify the root directory
   (/lib/firmware/) External firmware blobs to build into the kernel binary
 
## (Enable Radeon KMS support)
Device Drivers --->
   Graphics support --->
   <M/*> Direct Rendering Manager (XFree86 4.1.0 and higher DRI support) --->
   <M/*>    ATI Radeon
   [*]      Enable modesetting on radeon by default
   [ ]      Enable userspace modesetting on radeon (DEPRECATED)
```

- **较新的卡：AMDGPU 设置**

```
## (Setup the kernel to use the amdgpu firmware, optional if "AMD GPU" below is M)
Device Drivers --->
   Generic Driver Options --->
   [*]  Include in-kernel firmware blobs in kernel binary
  ## # AMD card specific, (see AMDGPU page for details which firmware files to include)
   (amdgpu/<CARD-MODEL>.bin ...)
  ## # Specify the root directory
   (/lib/firmware/) External firmware blobs to build into the kernel binary
 
## (Enable Radeon KMS support)
Device Drivers --->
   Graphics support --->
   <M/*> Direct Rendering Manager (XFree86 4.1.0 and higher DRI support) --->
   <M/*> AMD GPU
         [ /*] Enable amdgpu support for SI parts
         [ /*] Enable amdgpu support for CIK parts 
         [*]   Enable AMD powerplay component  
         ACP (Audio CoProcessor) Configuration  ---> 
             [*] Enable AMD Audio CoProcessor IP support (CONFIG_DRM_AMD_ACP)
         Display Engine Configuration  --->
             [*] AMD DC - Enable new display engine
             [ /*] DC support for Polaris and older ASICs
             [ /*] AMD FBC - Enable Frame Buffer Compression
             [ /*] DCN 1.0 Raven family
   <M/*> HSA kernel driver for AMD GPU devices
```

- **Nvme固态支持 Linux 5.x.x**

```
Device Drivers →
  NVME Support →
    <*> NVM Express block device
```

- **Nvme固态支持  其他 GNU/Linux 发行版的默认设置**

```
<*> NVM Express block device
[*] NVMe multipath support
[*] NVMe hardware monitoring
<M> NVM Express over Fabrics FC host driver
<M> NVM Express over Fabrics TCP host driver
<M> NVMe Target support
  [*]   NVMe Target Passthrough support
  <M>   NVMe loopback device support
  <M>   NVMe over Fabrics FC target driver
  < >     NVMe over Fabrics FC Transport Loopback Test driver (NEW)
  <M>   NVMe over Fabrics TCP target support
```



- ZSTD 内核压缩模式

```
General setup  --->
	Kernel compression mode (ZSTD)  --->
		( ) Bzip2
        ( ) LZMA
        ( ) XZ
        ( ) LZO
        ( ) LZ4
        (X) ZSTD 
```



- 低延迟桌面系统优化

```
General setup  --->
	Preemption Model (Preemptible Kernel (Low-Latency Desktop))  --->
		(X) Preemptible Kernel (Low-Latency Desktop)
```



- CPU性能模式

```
Power management and ACPI options
	CPU Frequency scaling  --->
		Default CPUFreq governor (performance)  --->
			(X) performance
```



```
Binary Emulations  --->
	[*] x32 ABI for 64-bit mod
```

- Kvm

```
[*] Virtualization (NEW)  --->
    --- Virtualization
    <*>   Kernel-based Virtual Machine (KVM) support
    <M>     KVM for Intel (and compatible) processors support
    <*>     KVM for AMD processors support
    [*]     Support for Xen hypercall interface 
```

- WIFI -  [WiFi - Gentoo Wiki](https://wiki.gentoo.org/wiki/Wifi)

```bash
[*] Networking support  --->
    [*] Wireless  --->
        <M>   cfg80211 - wireless configuration API
        [ ]     nl80211 testmode command
        [ ]     enable developer warnings
        [ ]     cfg80211 certification onus
        [*]     enable powersave by default
        [ ]     cfg80211 DebugFS entries
        [ ]     support CRDA
        [ ]     cfg80211 wireless extensions compatibility
        <M>   Generic IEEE 802.11 Networking Stack (mac80211)
        [*]   Minstrel
        [*]     Minstrel 802.11n support
        [ ]       Minstrel 802.11ac support
              Default rate control algorithm (Minstrel)  --->
        [ ]   Enable mac80211 mesh networking (pre-802.11s) support
        -*-   Enable LED triggers
        [ ]   Export mac80211 internals in DebugFS
        [ ]   Trace all mac80211 debug messages
        [ ]   Select mac80211 debugging features  ----
```

```


Device Drivers  --->
    [*] Network device support  --->
        [*] Wireless LAN  --->
 
            Select the driver for your Wifi network device, e.g.:
            <M> Broadcom 43xx wireless support (mac80211 stack) (b43)
            [M]    Support for 802.11n (N-PHY) devices
            [M]    Support for low-power (LP-PHY) devices
            [M]    Support for HT-PHY (high throughput) devices
            <M> Intel Wireless WiFi Next Gen AGN - Wireless-N/Advanced-N/Ultimate-N (iwlwifi)
            <M>    Intel Wireless WiFi DVM Firmware support                             
            <M>    Intel Wireless WiFi MVM Firmware support
            <M> Intel Wireless WiFi 4965AGN (iwl4965)
            <M> Intel PRO/Wireless 3945ABG/BG Network Connection (iwl3945)
            <M> Ralink driver support  --->
                <M>   Ralink rt27xx/rt28xx/rt30xx (USB) support (rt2800usb)
 
-*- Cryptographic API --->
    -*- AES cipher algorithms
    -*- AES cipher algorithms (x86_64)
    <*> AES cipher algorithms (AES-NI)
```

```
Device Drivers  --->
    [*] LED Support  --->
        <*>   LED Class Support
 
[*] Networking support  --->
    [*] Wireless  --->
        [*] Enable LED triggers
```

- [iwd - Gentoo Wiki](https://wiki.gentoo.org/wiki/Iwd)

```
Security options  --->
    [*] Enable access key retention support
    [*] Diffie-Hellman operations on retained keys
Networking support  --->
    [*] Wireless  --->
        <M> cfg80211 - wireless configuration API
Cryptographic API  --->
    *** Public-key cryptography ***
    [*] RSA algorithm
    [*] Diffie-Hellman algorithm
    *** Block modes ***
    [*] ECB support
    *** Hash modes ***
    [*] HMAC support
    *** Digest ***
    [*] MD4 digest algorithm
    [*] MD5 digest algorithm
    [*] SHA1 digest algorithm
    [*] SHA1 digest algorithm (SSSE3/AVX/AVX2/SHA-NI)   // AMD64 and SSSE3
    [*] SHA224 and SHA256 digest algorithm
    [*] SHA256 digest algorithm (SSSE3/AVX/AVX2/SHA-NI) // AMD64 and SSSE3
    [*] SHA384 and SHA512 digest algorithms
    [*] SHA512 digest algorithm (SSSE3/AVX/AVX2)        // AMD64 and SSSE3
    *** Ciphers **
    [*] AES cipher algorithms
    [*] AES cipher algorithms (x86_64)                  // AMD64
    [*] AES cipher algorithms (AES-NI)                  // X86_AES
    [*] ARC4 cipher algorithm
    [*] DES and Triple DES EDE cipher algorithms
    [*] Triple DES EDE cipher algorithm (x86-64)        // AMD64
    *** Random Number Generation ***
    [*] User-space interface for hash algorithms
    [*] User-space interface for symmetric key cipher algorithms
    [*] Asymmetric (public-key cryptographic) key type  --->
        [*] Asymmetric public-key crypto algorithm subtype
        [*] X.509 certificate parser
        [*] PKCS#7 message parser
        <M> PKCS#8 private key parser                   // linux kernel 4.20 or higher
```



- **启用蓝牙支持 **   -   [蓝牙 - Gentoo Wiki](https://wiki.gentoo.org/wiki/Bluetooth/zh-cn)

```
[*] Networking support --->
      <M>   Bluetooth subsystem support --->
              [*]   Bluetooth Classic (BR/EDR) features
              <*>     RFCOMM protocol support
              [ ]       RFCOMM TTY support
              < >     BNEP protocol support
              [ ]       Multicast filter support
              [ ]       Protocol filter support
              <*>     HIDP protocol support
              [*]     Bluetooth High Speed (HS) features
              [*]   Bluetooth Low Energy (LE) features
                    Bluetooth device drivers --->
                      <M> HCI USB driver
                      <M> HCI UART driver
      <*>   RF switch subsystem support --->
    Device Drivers --->
          HID support --->
            <*>   User-space I/O driver support for HID subsystem
```

- Networkmanager   -   [NetworkManager - Gentoo Wiki](https://wiki.gentoo.org/wiki/NetworkManager)

```
[*] Networking support  --->
      Networking options  --->
        <*> Packet socket
  [*] Wireless  --->
        <*>   cfg80211 - wireless configuration API
        [*]     cfg80211 wireless extensions compatibility
```

- BBR

```
[*] Networking support  --->
	Networking options  --->
		[*]   TCP: advanced congestion control  --->
            <M>   Binary Increase Congestion (BIC) control
            <*>   CUBIC TCP
            <M>   TCP Westwood+
            <M>   H-TCP
            <M>   High Speed TCP
            <M>   TCP-Hybla congestion control algorithm
            {M}   TCP Vegas
            <M>   TCP NV
            <M>   Scalable TCP
            <M>   TCP Low Priority
            <M>   TCP Veno
            <M>   YeAH TCP
            <M>   TCP Illinois
            <M>   DataCenter TCP (DCTCP)
            <M>   CAIA Delay-Gradient (CDG)
			<*>   BBR TCP
             Default TCP congestion control (BBR)  --->
                 ( ) Cubic
                 (X) BBR
                 ( ) Reno
```





- **多处理支持的内核配置**

```
Processor type and features  --->
 [*] Symmetric multi-processing support
 [*]   SMT (Hyperthreading) aware nice priority and policy support
 [*]   Multi-core scheduler support (NEW)
```

- **处理器系统的内核电源管理**

```
Power management and ACPI options  --->
 [*] ACPI (Advanced Configuration and Power Interface) Support
```

- **在 x86 上启用高内存支持**

```
Processor type and features  --->
 High Memory Support  --->
  ( ) 4GB
  (X) 64GB
```

