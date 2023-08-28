#!/usr/bin/bash
# Author/Wechat: Auroot
# Script name: Auins (ArchLinux User Installation Scripts) 
# URL GitHub: https://github.com/Auroots/Auins
# URL Gitee : https://gitee.com/auroot/Auins
# set -xe
# set -eu
echo &>/dev/null
export AUINS_SCRIPT_NAME SOURCE_MODULES SOURCE_LOCAL TIME_ARCHISO SCRIPTS_SOURCE
export BOOT_TYPE DISK_TYPE CHROOT_PATTERNS_PRINT START_MODE AUINS_VERSION
export CONFIGURE_SYSTEM config_File info_File 

# @ script source
# auroot  |  gitee  |  github  |  test
SCRIPTS_SOURCE="auroot"
AUINS_VERSION="ArchLinux User Install Scripts v4.7.1" 
# sed -i.bak 's/^aaa=yes/aaa=no/' [file] # 替换并备份

# @脚本初始化
function Auins_Variable_init(){
    Auins_Dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd )
    [ "$Auins_Dir" = "/" ] && Auins_Dir=""
    AUINS_SCRIPT_NAME=auins
    modules_Dir="${Auins_Dir}/modules" 
    local_Dir="${Auins_Dir}/local" 
    config_File="${local_Dir}/profile.conf"  
    info_File="${local_Dir}/auins.info"  
    Mirrorlist_modules="${modules_Dir}/mirrorlist_manage.sh"
    Users_modules="${modules_Dir}/users_manage.sh"
    Partition_modules="${modules_Dir}/partition_disk.sh"
    Desktop_modules="${modules_Dir}/desktop_manage.sh"
    Drive_modules="${modules_Dir}/drive_manage.sh"
    Fonts_modules="${modules_Dir}/fonts_manage.sh"
    Info_modules="${modules_Dir}/info_print.sh"
    Tools_modules="${modules_Dir}/tools_module.sh"
    Blarckarch_modules="${modules_Dir}/blackarch_strap.sh"
    System_Root="/mnt"
    Livecd_Version_Route="/run/archiso/airootfs/version"
    # entries_Boot="/sys/firmware/efi/efivars"  # discern: UEFI
    set +e
    [ ! -d "$local_Dir" ] && mkdir -p "$local_Dir"
    [ ! -d "$modules_Dir" ] && mkdir -p "$modules_Dir"
    [ ! -e "$config_File" ] && touch "$config_File"
    set -e
}

# check for root privilege
function check_priv(){
  if [ "$(id -u)" -ne 0 ]; then
    err(){ echo -e >&2 "\033[1;37m:: $(tput bold; tput setaf 1)[ x Error ] => \033[1;31m${*}\033[0m$(tput sgr0)"; exit 255; } 
    err "Please use command: \033[1;33m\"sudo\"\033[1;31m or user: \033[1;33m\"root\"\033[1;31m to execute.\033[0m"
  fi
}
# modules模块使用方法
# 镜像源配置
function run_update_mirrors(){ 
    # 需要引用: 1:配置文件, 2:信息文件
    bash "$Mirrorlist_modules" "$config_File" "$info_File" "$Tools_modules"
}
# 用户配置
function run_configure_users(){ 
    # 需要引用: 1:配置文件, 2:信息文件
    bash "$Users_modules" "$config_File" "$info_File" "$Tools_modules"
}
# 磁盘分区
function run_configure_partition(){
    # 需要引用: 1:配置文件, 2:信息文件, 3:进程管理模块
    bash "$Partition_modules" "$config_File" "$info_File" "$Tools_modules" || exit 1; 
    bash "${0}"
}
# blackarch配置模块, https://blackarch.org/strap.sh
function run_blarckarch_script(){ 
    bash "$Blarckarch_modules"
}
# 桌面安装与配置
function run_configure_desktop(){ 
    # 需要引用: 1:配置文件, 2:信息文件, 3:local目录地址, 4:信息打印模块,  5:字体安装与配置模块, 6:进程管理模块
    bash "$Desktop_modules" "$config_File" "$info_File" "$local_Dir" \
         "$Tools_modules" "$Info_modules" "$Fonts_modules"
    run_tools "tips_w" "Whether to install Common Drivers? [Y/n]?"
    case $(run_tools read) in
        [Yy]*) run_configure_drive ;;
        [Nn]*) run_tools process stop "$0" ;;
    esac
}
# 桌面安装与配置
function run_configure_drive(){
    # 需要引用: 1:配置文件, 2:信息文件
    bash "$Drive_modules" "$config_File" "$info_File" "$Tools_modules"
}
# 字体安装与配置
function run_configure_fonts(){
    # 需要引用: 1:配置文件, 2:信息文件, 3:local目录地址, 4:信息打印模块, 5:进程管理模块, 6:用户选项,说明:
    # Config_file_install_fonts:   根据配置文件, 安装相应的字体
    # User_options_install_fonts:  根据用户选项, 安装相应的字体, $2 = 用户的选项有: [all] [common] [adobe] [code]
    # Script_Runing_install_fonts: 脚本运行时, 由脚本自动判断, 自动安装配置文件中的选项, 另外询问是否安装其他
    bash "$Fonts_modules" "$config_File" "$info_File" "$local_Dir" \
         "$Tools_modules" "$Info_modules" "$1" "$2"
}
# 小型重复性高的模块调用管理器
function run_tools(){
    # 需要引用: 1:配置文件, 2:信息文件, 主选项, 其他选项1, 其他选项3, 其他选项4, 其他选项5
        # 主选项:
            # warn  警告 [输出信息]
            # run   开始运行 [输出信息]     
            # skip  跳过 [输出信息]
            # err   错误 [输出信息]
            # feed  结果提示, 1:正常结束要显示的信息, 2:非正常结束要显示的信息
            # read  获取用户输入
            # ck_p  检查权限,如果非root,则退出
            # tips_w    提示输入-白 [输出信息]
            # tips_y    提示输入-黄 [输出信息]
            # file_rw   读写文件 [INFO / CONF] [Read / Write] [头部参数] [修改内容(Write)]
            # mt_dir    创建临时目录
            # show_Disk 输出磁盘表及UUID
            # test_Disk 检查磁盘名是否合法 [磁盘名]
            # test_Part 检查分区名是否合法 [分区名]
            # process   进程管理 1:{start|restart|stop}, 2[进程名], 3:[需要输出的错误信息]
            # ip_api    使用api获取信息  [查询信息]:{region | country | country_code | timezone}
            # ipapi     使用api获取信息  [查询信息]:比以上多一个ip,但处于null
            # ipinfo    使用api获取信息(推荐)  [查询信息]:{ip | country_code | timezone}
            # ipify     使用api获取信息, 仅ip
    bash "$Tools_modules" "$config_File" "$info_File" "$local_Dir" "$1" "$2" "$3" "$4" "$5"
}
# 信息打印
function run_print_info(){
    # 需要引用: 1:配置文件, 2:信息文件, 3:用户选项(以下), 4:logos所需1, 5:logos所需2
    # version:    Auins版本信息, 需要接收: auinus版本信息
    # logos:      Script首页信息, 需要接收: 1=Chroot状态(CHROOT_PATTERNS_PRINT) 2=脚本开启模式(START_MODE) 
    # ssh_info:   输出SSH信息
    # auins_usage:      Auins的帮助文档 Auin_help, (无需任何参数)
    # livecd_home_list: LiveCD环境下, 首页会显示的列表, (无需任何参数)
    # normal_home_list: 正常(Normal)环境下, 首页会显示的列表, (无需任何参数)
    # desktop_env_list: 桌面环境的选择列表, (无需任何参数)
    # desktop_manager_list:       桌面管理器的选择列表, (无需任何参数)
    # livecd_system_module_list:  首选项 [4] 的列表, (无需任何参数)
    # install_system_info:        系统安装成功, 直奔加入chroot的提示信息, (无需任何参数)
    # config_system_info:         完成系统配置成功, 可重启的提示信息, (无需任何参数)
    # JetBrainsFira_font_usage:   JetBrainsFira字体安装完成后的使用说明, (无需任何参数)
    bash "$Info_modules" "$config_File" "$info_File" "$Tools_modules" "$1" "$2" "$3"
}

# @install Programs 安装包
function Install_Program() {
    # arch-chroot ${MNT_DIR} bash -c "$COMMAND"
    set +e
    IFS=' '; PACKAGES=("$@");
    for VARIABLE in {1..3}
    do
        local COMMAND="pacman -Syu --noconfirm --needed ${PACKAGES[@]}"
        if ! bash -c "$COMMAND" ; then
            break;
        else
            sleep 1.5; break;
        fi
    done
    echo "$VARIABLE" &> /dev/null
    set -e
}

# @脚本自检
function Script_init(){
    # Read Profile.conf
    CONF_Hostname=$(run_tools file_rw CONF Read Hostname)
    CONF_Password_SSH=$(run_tools file_rw CONF Read Password_SSH)
    CONF_Service_SSH=$(run_tools file_rw CONF Read Service_SSH)

    # 写入Auins版本
    run_tools file_rw INFO Write Auins_version "$AUINS_VERSION"

    # 查询并写入CPU信息
    CPU=$(head -n 5 /proc/cpuinfo | grep "model name" | awk -F ": " '{print $2}')
    lscpu | grep GenuineIntel &>/dev/null && CPU_Vendor="intel";
    lscpu | grep AuthenticAMD &>/dev/null && CPU_Vendor="amd";
    run_tools file_rw INFO Write CPU "$CPU"
    run_tools file_rw INFO Write CPU_Vendor "$CPU_Vendor"

    # 查询并写入GPU信息
    set +e
    not_intercept_gpu_info=$(lspci | grep -i VGA | awk -F ":" '{print $3}' | sed 's/^[ ]*//g')
    intercept_gpu_info=$(lspci  | grep -i VGA | awk -F ":" '{print $3}' | grep -o '\[.*\]')
    Unrecognized=$(echo -e "${white}Unrecognized${suffix}")
    GPU_Info_0="${intercept_gpu_info:-$not_intercept_gpu_info}"
    GPU="${GPU_Info_0:-$Unrecognized}"
    run_tools file_rw INFO Write GPU "$GPU"
    set -e

    Memory=$(($(sed -n '1,1p' /proc/meminfo | awk '{print $2}')/1000))
    run_tools file_rw INFO Write Memory "$Memory"

    # 查询并写入主机环境信息
    lspci | grep -i "virtualbox" &>/dev/null && Host_Environment="VirtualBox";
    lspci | grep -i "vmware" &>/dev/null     && Host_Environment="Vmware"; 
    [[ $Host_Environment == "" ]] && Host_Environment="Computer"; SHOW_Host_Env=""
    run_tools file_rw INFO Write Host_Environment "$Host_Environment";

    # 查询并写入Boot类型
    if [ -d /sys/firmware/efi ]; then
        BOOT_TYPE="UEFI" DISK_TYPE="GPT"
    else
        BOOT_TYPE="BIOS" DISK_TYPE="MBR"
    fi
    run_tools file_rw INFO Write Boot_Type ${BOOT_TYPE}
    run_tools file_rw INFO Write Disk_Type ${DISK_TYPE}
    INFO_Boot_way=$(run_tools file_rw INFO Read "Boot_Type")

    # 查询并写入地区 IP 国家
    CONF_Timezone=$(run_tools file_rw CONF Read Timezone)
    if [ -z "$CONF_Timezone" ] ; then
        # run_tools file_rw INFO Write Country "$(run_tools ipinfo "country")";
        run_tools file_rw INFO Write Timezone "$(run_tools ipinfo timezone)"
    else
        run_tools file_rw INFO Write Timezone "$CONF_Timezone";  
    fi
    # 从api中获取ip，国家，时区信息，写入到info文件，暂时无其他作用
    run_tools file_rw INFO Write Public_IP "$(run_tools ipinfo ip)"
    run_tools file_rw INFO Write Country_Code "$(run_tools ipinfo country_code)"
    # 校准live环境的时间
    ln -sf "/usr/share/zoneinfo/$(run_tools file_rw INFO Read Timezone)" /etc/localtime &>/dev/null && hwclock --systohc --utc
     
     # 查询并写入Chroot模式
    if [ -d /run/archiso/airootfs ]; then 
        rm -rf "$local_Dir/Chroot_ON" &> /dev/null 
        rm -rf "$local_Dir/Not_Configure_System" &> /dev/null  
    else 
        touch "$local_Dir/Chroot_ON" &> /dev/null
    fi
    [ -e "$local_Dir/Chroot_ON" ] && CHROOT_PATTERNS_PRINT="Chroot-ON" || CHROOT_PATTERNS_PRINT="Chroot-OFF"; 

    [ -e "$local_Dir/Not_Configure_System" ] && CONFIGURE_SYSTEM="no" || CONFIGURE_SYSTEM="yes"; 
    run_tools file_rw INFO Write ChrootPatterns "$CHROOT_PATTERNS_PRINT";
    # Chroot-OFF下，才会自动干的事情
    case "$CHROOT_PATTERNS_PRINT" in  
        Chroot-OFF) 
            # 根据配置文件, 判断是否开启SSH远程服务, Chroot下不执行
            case $CONF_Service_SSH in [Yy]*) Open_SSH; esac
    esac
}

# @下载所需的脚本模块
function Update_Share(){     
    # feedback successfully info
    function feed_status(){ 
        if [ $? = 0 ]; then 
            echo -e "\033[1;37m:: $(tput bold; tput setaf 2)=> \033[1;32m${1}\033[0m$(tput sgr0)"; 
        else 
            err "$2"
        fi
    }
    # 根据配置文件选择源, 将其作为脚本的下载源 Module URL: Default settings
    function auins_download_url(){
        case ${1} in
            "gitee"  ) SOURCE="https://gitee.com/auroot/Auins/raw/main" ;;
            "github" ) SOURCE="https://raw.githubusercontent.com/Auroots/Auins/main";;
            "auroot" ) SOURCE="http://auins.auroot.cn" ;;
            "test"   ) SOURCE="http://test.auroot.cn" 
        esac
        SOURCE_MODULES="${SOURCE}/modules"
        SOURCE_LOCAL="${SOURCE}/local"
    }
    # 检查与审核文件是否存在或为空, 1.如果不存在则下载, 2.如果为空则删除, 3,如果本地与云端不一致将自动更新
    function audit_file() {
        local directory=$1; file_path=$2; file_name=$(echo "$file_path" | awk -F"/" '{print $NF}')
        case $directory in 
            [Mm]*) SOURCE_URL="${SOURCE}/modules";;
            [Ll]*) SOURCE_URL="${SOURCE}/local"
        esac
        if [ -z "$(cat "$config_File")" ]; then
            Profile_name=$(echo "$config_File" | awk -F"/" '{print $NF}')
            curl -fsSL "${SOURCE}/local/${Profile_name}" > "$config_File"
            feed_status "Successfully download: [${white} ${Profile_name} ${green}]" "Download failed: [${white} ${Profile_name} ${red}]";
        fi
        if [ ! -e "$file_path" ]; then
            curl -fsSL "${SOURCE_URL}/${file_name}" > "$file_path"  
            feed_status "Successfully download: [${white} $file_name ${green}]" "Download failed: [${white} $file_name ${red}]";
            case $(echo "$file_name" | awk -F"." '{print $NF}') in 
                sh) chmod +x "$file_path" || if [ -z "$(cat "$file_path")" ]; then rm -f "$file_path"; fi
            esac      
        fi
        case $(run_tools file_rw CONF Read Now_update_auins 2>/dev/null) in
            [Yy]*)
                    if [[ $file_name != "$(echo "$info_File" | awk -F"/" '{print $NF}')" ]] \
                    && [[ $file_name != "$(echo "$config_File" | awk -F"/" '{print $NF}')" ]]; then
                        if [[ "$(cat "$file_path")" != "$(curl -fsSL "${SOURCE_URL}/${file_name}")" ]]; then 
                            curl -fsSL "${SOURCE_URL}/${file_name}" > "$file_path"
                            feed_status "Successfully update: [${white} $file_name ${green}]" "Update failed: [${white} $file_name ${red}]";
                        fi
                    fi 
                ;;
        esac 
    }
    # 下载想要脚本模块 
    function download_script(){
        audit_file local "$config_File"
        audit_file local "$info_File"
        audit_file modules "$Tools_modules"
        audit_file modules "$Info_modules"  
        audit_file modules "$Mirrorlist_modules"
        audit_file modules "$Users_modules"
        audit_file modules "$Partition_modules"
        audit_file modules "$Desktop_modules"
        audit_file modules "$Fonts_modules"
        audit_file modules "$Blarckarch_modules"
        audit_file modules "$Drive_modules"
        run_tools file_rw CONF Write modules_source "$SOURCE_MODULES"
        run_tools file_rw CONF Write local_source "$SOURCE_LOCAL"
        # 更新auins
        case $(run_tools file_rw CONF Read Now_update_auins) in
        [Yy]*)
            if [[ "$(cat "$0")" != "$(curl -fsSL "${SOURCE}/${AUINS_SCRIPT_NAME}")" ]]; then 
                curl -fsSL "${SOURCE}/${AUINS_SCRIPT_NAME}" > "$0"
                feed_status "Successfully update: [${white} Auins ${green}]" "Update failed: [${white} Auins ${red}]" && exit 0;
            fi
        esac
    }
    
    case ${1} in
        "auins_download_url") auins_download_url "$2";;
        "download_script") download_script 
    esac
}

# @网络部分集合
function Network(){
    # info_all_nic=$(awk '{if($1>0 && NR > 2) print substr($1, 0, index($1, ":") - 1)}' /proc/net/dev)
    info_all_nic=$(awk '{if($1>0 && NR > 2) print substr($1, 0, index($1, ":") - 1)}' /proc/net/dev | sed '/lo/d' | sed '/vi/d')
    declare -A NET_Interface=()
    declare -A NET_IP=()
    Show_Network(){
        local VARIABLE
        case $1 in 
            WIFI )  Show="^wl*"; 
        ;;  ETHERNET ) Show="^en*|^et*"; 
        esac
        for  ((VARIABLE=1;VARIABLE<=10;VARIABLE++)); do
            if echo "$info_all_nic" | grep -E "$Show" &>/dev/null ; then 
                Temp_name=$(echo "$info_all_nic" | grep -E "$Show" |  sed -n "$VARIABLE,1p" | sed 's/^[ ]*//g') 
                if [[ $Temp_name == "" ]]; then
                    break;
                else
                    LOCAL_IP=$(ip route list | grep "$Temp_name" | cut -d" " -f9 | sed -n '2, 1p')
                fi
                NET_Interface[$VARIABLE]=$Temp_name
                NET_IP[$Temp_name]=$LOCAL_IP
            else  # 当WIFI或Ethrnet其中一个设备不存在时,将输出void,确保完整性
                if [[ $1 == "WIFI" ]]; then
                    NET_Interface=([1]=void)
                    NET_IP=([void]=void)
                else
                    NET_Interface=([1]=void)
                    NET_IP=([void]=void)
                fi
            fi
        done
        # 格式化网卡与IP
        for ((VARIABLE=1;VARIABLE<=8;VARIABLE++)); do 
            NAME_TEMP=${NET_Interface[$VARIABLE]};
            if [[ $NAME_TEMP != "" ]]; then
                if [[ "${NET_IP[$NAME_TEMP]}" != "" ]]; then
                    NET_IP_TEMP=${NET_IP[$NAME_TEMP]};
                else
                    NET_IP_TEMP="void";
                fi 
                echo -n "$NAME_TEMP:${NET_IP_TEMP} | " ;
            else
                break;
            fi
        done; 
    }
    # @获取本机IP地址，并储存到$info_File， Network Variable
    function ethernet_info(){    
        local Temp_name VARIABLE

        function NET_LIST(){
            for ((VARIABLE=1;VARIABLE<=$(echo "$1" | grep -o '|' | wc -l);VARIABLE++)) 
            do 
                list=$(echo "$1" | awk -F'|' '{print $test}' test="$VARIABLE" | sed 's/^[ ]*//g')
                list_ip=$(echo "$list" | awk -F':' '{print $2}')
                if [[ $list_ip != "" ]]; then 
                    PRINT_NET_Interface=$(echo "$list" | awk -F':' '{print $1}')
                    PRINT_NET_IP=$list_ip
                    echo -e "\t${VARIABLE}: ${PRINT_NET_Interface} - ${PRINT_NET_IP}"
                fi 
            done
        }
        
        run_tools file_rw INFO Write Wifi "$(Show_Network WIFI)"
        run_tools file_rw INFO Write Ethernet "$(Show_Network ETHERNET)"

        case $1 in 
            WIFI )  
                    echo -e "\033[1;37m:: $(tput bold; tput setaf 2)\033[1;36mWIFI: \n\033[1;37m$(NET_LIST "$(Show_Network WIFI)")\033[0m$(tput sgr0)"
        ;;  ETHERNET ) 
                    echo -e "\033[1;37m:: $(tput bold; tput setaf 2)\033[1;36mETHERNET: \n\033[1;37m$(NET_LIST "$(Show_Network ETHERNET)")\033[0m$(tput sgr0)"
        ;;  * )
        esac 
    }
    # @配置WIFI，Configure WIFI
    # https://wiki.archlinuxcn.org/wiki/%E7%BD%91%E7%BB%9C%E9%85%8D%E7%BD%AE/%E6%97%A0%E7%BA%BF%E7%BD%91%E7%BB%9C%E9%85%8D%E7%BD%AE
    function configure_wifi() {
        # 显示网卡信息: 1: wlan0 - void(ip)
        run_tools run "Checking the currently available network..."
        echo; Network ethernet_info WIFI; echo;
        # 用户选择网卡
        run_tools tips_w "Please select WiFi interface [1,2,3...]?"
        WIFI_user_number=$(run_tools read)
        Show_Network WIFI &>/dev/null
        WIFI_Interface=${NET_Interface[$WIFI_user_number]}
        [[ $WIFI_Interface == "" ]] && run_tools err "This interface was not found."
        # 打印WIFI列表
        WIFI_INFO=$(iwlist "$WIFI_Interface" scan)
        run_tools feed "[ $WIFI_Interface ] Interface scan successful." 
        # 比较详细的wifi列表
        echo -e "${white}:: ${blue}A detailed WiFi list:${suffix}"
        echo -e "${white}$(echo "$WIFI_INFO" | sed 's/^[ ]*//g' | grep -Ew "^ESSID*|^Frequency*|^Quality*" | \
        sed -e 's/^F/\\n   F/g' -e 's/^E/   E/g' -e 's/^Q/   Q/g')${suffix}\n"
        # 只有wifi名称的列表
        echo -e "${white}:: ${blue}A simple WiFi list:${suffix}\n"
        echo -e "${white}$(echo "$WIFI_INFO" | sed 's/^[ ]*//g' | grep -Ew "^ESSID*" | sed -e 's/^E/   E/g' )${suffix}\n"
        # 用户输入WIFI名称
        run_tools tips_w "Enter wifi name(SSID)?"
        WIFI_ESSID=$(run_tools read)
        # 用户输入WIFI密码
        run_tools tips_w "Wifi Password"
        WIFI_PASSWD=$(run_tools read)
        # 根据用户输入, 尝试连接网络
        iwctl --passphrase "$WIFI_PASSWD" station "$WIFI_Interface" connect "$WIFI_ESSID"
        run_tools feed "Successfully connected to WiFi: [${white} $WIFI_ESSID ${green}]" \
        "Please check if the input is correct: SSID(${white}$WIFI_ESSID${red}) and password (${white}$WIFI_PASSWD${red})."

        ip address show "${WIFI_Interface}"
        if ! ping -c 3 61.166.150.123; then
            run_tools process stop "$0" "Network ping check failed. Cannot continue."
        fi
    }
    # @配置有线网络，Configure Ethernet.
    function configure_ethernet(){
        # 显示网卡信息: 1: enp5s0 - 192.168.101.3(ip)
        run_tools run "Checking the currently available network..."
        Network ethernet_info ETHERNET

        run_tools tips_w "Please select Ethernet interface [1,2,3...]?"
        Ethernet_user_number=$(run_tools read)
        Show_Network ETHERNET &> /dev/null 
        Ethernet_Interface=${NET_Interface[$Ethernet_user_number]}

        run_tools feed ":: One moment please..."
        ip link set "${Ethernet_Interface}" up
        ip address show "${Ethernet_Interface}"
        if ! ping -c 3 61.166.150.123; then
            run_tools process stop "$0" "Network ping check failed. Cannot continue."
        fi
    }
    # @配置网络
    function configure_all(){
        run_tools tips_w "Query Network: Ethernet[1] Wifi[2] Exit[q]?"
        case $(run_tools read) in
            1 ) configure_ethernet ;;
            2 ) configure_wifi ;;
            [Qq]* ) bash "${0}"
        esac
    }
    # Ethernet
    case ${1} in
        ethernet_info ) ethernet_info "$2" ;;
        Conf_wifi) configure_wifi ;;
        Conf_Eth ) configure_ethernet ;;
        Conf_all ) configure_all
    esac
}

# @开启SSH服务， Start ssh service 
function Open_SSH(){
    clear;
    run_tools run "Checking the currently available network..."
    Network ethernet_info WIFI 
    Network ethernet_info ETHERNET
    echo; echo "${USER}:${CONF_Password_SSH}" | chpasswd &>/dev/null 
    systemctl start sshd.service
    run_print_info ssh_info 
}

# @设置root密码 用户 
function Configure_users2passwd(){
    local raw_number
    export INFO_UserName UsersID CheckingID CheckingUsers
    INFO_UserName=$(run_tools file_rw INFO Read "Users")
    INFO_UsersID=$(run_tools file_rw INFO Read "UsersID")
    CheckingUsers=""
    if [ -z "$INFO_UserName" ]; then
        for raw_number in {1..25}; do  
            Query=$(tail -n "${raw_number}" /etc/passwd | head -n 1 | cut -d":" -f3)
            if [ "$Query" -gt 999 ] && [ "$Query" -lt 1020 ]; then
                CheckingID=$(grep "$Query" < /etc/passwd | cut -d":" -f3)
                CheckingUsers=$(id -un "$CheckingID" 2> /dev/null)
                break;
            fi
        done
        if [[ -z "$CheckingUsers" ]] ; then
            run_configure_users
            INFO_UserName=$(run_tools file_rw INFO Read "Users")
            INFO_UsersID=$(run_tools file_rw INFO Read "UsersID")
            printf "${outG} ${green}A normal user already exists, The UserName:${suffix} ${blue}%s${suffix} ${green}ID: ${blue}%s${suffix}.\n"  "${INFO_UserName:-$CheckingUsers}" "${INFO_UsersID:-$CheckingID}"
        fi
    fi
    printf "${outG} ${green}A normal user already exists, The UserName:${suffix} ${blue}%s${suffix} ${green}ID: ${blue}%s${suffix}.\n"  "${INFO_UserName:-$CheckingUsers}" "${INFO_UsersID:-$CheckingID}"
    sleep 1.5
}

# @安装系统、内核、基础包等，Install system kernel / base...
function Install_Archlinux(){    
    CONF_Linux_kernel=$(run_tools file_rw CONF Read "Linux_kernel")
    run_tools run Update the system clock.  # update time
    timedatectl set-ntp true
    run_tools run Install the Kernel base packages.
    case "$CONF_Linux_kernel" in 
        linux    ) pacstrap "$System_Root" base base-devel reflector linux-firmware linux linux-headers linux-api-headers vim unzip  ;;
        linux-lts) pacstrap "$System_Root" base base-devel reflector linux-firmware linux-lts linux-lts-headers vim unzip ;; 
        linux-zen) pacstrap "$System_Root" base base-devel reflector linux-firmware linux-zen linux-zen-headers vim unzip
    esac
    run_tools feed "The installation of the kernel basic package was successful." \
    "The installation of the kernel basic package failed. \n${white}:: Suggest remount the disk or restart the system.${suffix}"

    run_tools run Configure fstab.
    genfstab -U $System_Root >> $System_Root/etc/fstab
    run_tools feed "Fstab configuration successful." "Fstab configuration failed."
    LinuxKernel=$(arch-chroot $System_Root /usr/bin/uname -a | /usr/bin/cut -d"#" -f1  | awk -F " " '{print $3}')
    run_tools file_rw INFO Write LinuxKernel "$LinuxKernel";
    cp -rf "$local_Dir" $System_Root/root/ 
    run_tools feed "$local_Dir directory copy successful." "$local_Dir directory copy failed."
    touch $System_Root/root/local/Chroot_ON
    run_tools feed "Chroot_ON file creation successful." "Chroot_ON file creation failed."
    touch $System_Root/root/local/Not_Configure_System 
    run_tools feed "Not_Configure_System file creation successful." "Not_Configure_System file creation failed."
}

# @Chroot -> $System_Root
function Auins_chroot(){    
    cat "$0" > $System_Root/root/$AUINS_SCRIPT_NAME 
    run_tools feed "$0 copy successful." "$0 copy failed."
    chmod +x $System_Root/root/$AUINS_SCRIPT_NAME 

    cp -f "$local_Dir/profile.conf"  $System_Root/root/local/
    run_tools feed "$local_Dir/profile.conf file copy successful." "$local_Dir/profile.conf file copy failed."

    cp -rf "$modules_Dir" $System_Root/root/ 2> /dev/null
    run_tools feed "$modules_Dir directory copy successful." "$modules_Dir directory copy failed."

    arch-chroot $System_Root /bin/bash -c "/root/$AUINS_SCRIPT_NAME"
}

# @安装 fcitx 输入法
function Configure_fcitx(){
    CONF_PKG_Fcitx=$(run_tools file_rw CONF Read "PKG_Fcitx")
    function install(){
        CONF_Install_Fcitx=$(run_tools file_rw CONF Read "Install_Fcitx")
        function install_fcitx(){
            run_tools run "Installing [ Fcitx ]."
            pacman -Rsc --noconfirm fcitx
            Install_Program "$CONF_PKG_Fcitx" 
            run_tools feed "fcitx installation successfully." "fcitx installation failed."
            Fcitx_Config="
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx"
            echo "$Fcitx_Config" >> /etc/environment
        }

        case $CONF_Install_Fcitx in
            [Yy]* ) install_fcitx;; 
                * ) run_tools tips_w "Whether to install fcitx [Y/n]?"
                    case $(run_tools read) in
                        [Yy]*)  install_fcitx ;;
                            *)  run_tools skip "Install [ Fcitx ]".
                    esac
        esac 
    }
    function remove(){
        # awk '/fcitx/{print NR}' /etc/environment
        sed -i '/fcitx/d' /etc/environment
        pacman -Rsc --noconfirm "$CONF_PKG_Fcitx"
    }
    case $1 in 
        -R) remove; 
            status="flase" ;;
         *) run_tools warn "Input error or the option does not exist."; 
            status="true"
    esac
    [[ ${status} != "true" ]] && install; 
}

# @安装 ibus-rime 输入法
function Configure_ibus_rime() {
    CONF_PKG_Ibus=$(run_tools file_rw CONF Read "PKG_Ibus")
    function install(){
        CONF_Install_Ibus=$(run_tools file_rw CONF Read "Install_Ibus")
        function configure_ibus() {
            if wget -P "$local_Dir" "${SOURCE_LOCAL}/oh-my-rime.zip" ; then
                mkdir -p /home/"$INFO_UserName"/.config/ibus 
                unzip -d /home/"$INFO_UserName"/.config/ibus "${local_Dir}/oh-my-rime.zip"
            fi
            Ibus_Config="
export GTK_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
export QT_IM_MODULE=ibus
ibus-daemon -d -x"
            echo "$Ibus_Config" >> /etc/environment
            echo "$Ibus_Config" >> /etc/profile
        }
        
        case $CONF_Install_Ibus in
            [Yy]*)  run_tools run "Installing [ ibus-rime ]."
                    Install_Program "$CONF_PKG_Ibus" 
                    run_tools feed "ibus-rime installation successfully." "ibus-rime installation failed."
                    configure_ibus;;
                *)  run_tools tips_w "Whether to install ibus-rime. [Y/n]?"
                    case $(run_tools read) in
                        [Yy]*)  run_tools run "Installing [ ibus-rime ]."
                                Install_Program "$CONF_PKG_Ibus" 
                                run_tools feed "ibus-rime installation successfully." "ibus-rime installation failed."
                                configure_ibus;;
                            *) run_tools skip "Install [ ibus-rime ]."
                    esac
        esac 
    }
    function remove(){
        # awk '/ibus/{print NR}' /etc/environment
        sed -i '/ibus/d' /etc/environment
        sed -i '/ibus/d' /etc/profile
        rm -rf "$HOME"/.config/ibus
        pacman -Rsc --noconfirm "$CONF_PKG_Ibus"
    }
    case $1 in 
        -R) remove && status="flase" ;;
        * ) run_tools warn "Input error or the option does not exist." && status="true"
    esac
    [[ ${status} != "true" ]] && install; 
}

# @Pacman multi threaded download [Axel]
function Axel_Configure() {
    Read_Axel_Thread=$(run_tools file_rw CONF Read "Axel_Thread")
    Axel="XferCommand = \/usr\/bin\/axel -n $Read_Axel_Thread -a -o %o %u"
    case $1 in 
        -R) rm -rf /etc/axelrc
            sed -i "s/$Axel/ /g" /etc/pacman.conf
            pacman -R axel
            status="flase"
    ;;
        * ) #run_tools warn "Input error or the option does not exist."
            status="true"
    esac
    if [[ ${status} == true ]]; then
        pacman -S --noconfirm --needed axel
        run_tools feed "axel installation successfully." "axel installation failed."
        echo "alternate_output = 1" > /etc/axelrc
        sed -i "/XferCommand = \/usr\/bin\/curl/i ${Axel}" /etc/pacman.conf
    fi
}

# @Install/Configure Grub, 安装并配置Grub
function Configure_Grub(){
    run_tools run "Install grub tools."
    run_tools run "Your startup mode has been detected as ${green}$INFO_Boot_way${suffix}."   
    CONF_PKG_GRUB_UEFI="$(run_tools file_rw CONF Read "PGK_GRUB_UEFI")"
    CONF_PKG_GRUB_BOOT="$(run_tools file_rw CONF Read "PGK_GRUB_BOOT")"

    case "$INFO_Boot_way" in 
        UEFI)
            Install_Program "$CONF_PKG_GRUB_UEFI"
            run_tools feed "Grub uefi base package installation successfully." "Grub uefi base package installation failed."
            grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id="$CONF_Hostname" --recheck
            echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub
            grub-mkconfig -o /boot/grub/grub.cfg
            if efibootmgr | grep "$CONF_Hostname" &>/dev/null ; then
                run_tools run "Grub installed successfully -=> [${white} $CONF_Hostname ${green}]"  
                echo -e "${white}     $(efibootmgr | grep "$CONF_Hostname")  ${suffix}\n"  
            else
                echo -e "${yellow}     $(efibootmgr)  ${suffix}\n"
                run_tools err "Grub installed failed."
            fi
        ;;
        BIOS)
            Install_Program "$CONF_PKG_GRUB_BOOT"
            run_tools feed "Grub boot base package installation successfully." "Grub boot base package installation failed."
            local INFO_Boot_partition
            INFO_Boot_partition=$(run_tools file_rw INFO Read "Boot_partition") 
            grub-install --target=i386-pc --recheck --force "$INFO_Boot_partition"
            grub-mkconfig -o /boot/grub/grub.cfg
            if echo $? &>/dev/null ; then
                run_tools run "Grub installed successfully -=> [${white} $CONF_Hostname ${green}]" 
            else
                run_tools err "Grub installed failed."
            fi
    esac  
}

# @配置本地化 时区 主机名 语音等  
function Configure_Language(){
    language="LANG=en_US.UTF-8"
        run_tools run "Time zone changed to 'Shanghai'."
    ln -sf /usr/share/zoneinfo/"$(run_tools file_rw INFO Read "Timezone")" /etc/localtime &>/dev/null && hwclock --systohc --utc # 将时区更改为"上海" / 生成 /etc/adjtime
        run_tools run "Set the hostname \"$CONF_Hostname\"." 
    echo "$CONF_Hostname" > /etc/hostname
        run_tools run "Localization language settings."
    sed -i 's/#.*en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
        run_tools run "Write 'en_US.UTF-8 UTF-8' To /etc/locale.gen."
    sed -i 's/#.*zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/' /etc/locale.gen
        run_tools run "Write 'zh_CN.UTF-8 UTF-8' To /etc/locale.gen."
    locale-gen
        run_tools run "Configure local language defaults 'en_US.UTF-8'."; sleep 0.2
    echo "$language" > /etc/locale.conf       # 系统语言 "英文" 默认为英文   
}

# @Install/Configure virtualbox-guest-utils / open-vm-tools, 安装虚拟化插件
function install_virtualization_service(){
    CONF_PKG_VMWARE="$(run_tools file_rw CONF Read "PGK_Vmware")"
    CONF_PKG_VIRTUALBOX="$(run_tools file_rw CONF Read "PGK_VirtualBox")"
    case "$1" in
        Vmware)
            run_tools run "Install VMware workstation pro tools."
            Install_Program "$CONF_PKG_VMWARE"
            run_tools feed "vmware-tools installation successfully." "vmware-tools installation failed."

            systemctl enable vmtoolsd.service
            run_tools feed "vmtoolsd.service enable successfully." "vmtoolsd.service enable failed."

            systemctl enable vmware-vmblock-fuse.service
            run_tools feed "vmware-vmblock-fuse.service enable successfully." "vmware-vmblock-fuse.service enable failed."
            
            systemctl start vmtoolsd.service
            run_tools feed "vmtoolsd.service started successfully." "vmtoolsd.service started failed."
            
            systemctl start vmware-vmblock-fuse.service
            run_tools feed "vmware-vmblock-fuse.service started successfully." "vmware-vmblock-fuse.service started failed."
        ;;
        VirtualBox)
            run_tools run "Install VirtualBox tools."
            Install_Program "$CONF_PKG_VIRTUALBOX"
            run_tools feed "VirtualBox tools installation successfully." "VirtualBox tools installation failed."
            
            systemctl enable vboxservice.service
            run_tools feed "vboxservice.service enable successfully." "vboxservice.service enable failed."
            
            systemctl start vboxservice.service
            run_tools feed "vboxservice.service started successfully." "vboxservice.service started failed."
        ;;
        *) run_tools err "This computer is not virtualized."
    esac
}

# @Archlive update tips 
function Archiso_version_check(){
    Version_Route="${1}"
    TIME_ARCHISO=$(sed 's/\./-/g' "$Version_Route" 2> /dev/null)
    Time_interval=$((($(date +%s) - $(date -d "$TIME_ARCHISO 00:00:00" +%s)) / 2605391 ))
    run_tools file_rw INFO Write Archiso_version "${TIME_ARCHISO:- }";
    case $Time_interval in
        [0])    ;;
        [1])    echo; run_tools warn "Please update as soon as possible archiso ! "
                run_tools warn "Archiso Version: ${white}[ ${TIME_ARCHISO} ]${suffix}"
                ;;
        [2])    echo; run_tools warn "You haven't updated in more than 2 month archiso !" 
                run_tools warn "Archiso Version: ${white}[ ${TIME_ARCHISO} ]${suffix}"
                sleep 3
                ;;
        [3])    echo; run_tools warn "You haven't updated in more than 3 month archiso !"
                run_tools warn "Archiso Version: ${white}[ ${TIME_ARCHISO} ]${suffix}"
                run_tools tips_w "Whether to start the script [Y/n]?"
                    case $(run_tools read) in
                        [Yy]*)  sleep 1 ;;
                            *)  clear; warn "Please update archiso."; exit 30
                    esac ;;
        *)      echo; run_tools warn "Archiso Version: ${white}[ ${TIME_ARCHISO} ]${suffix}"
                run_tools warn "You haven't updated for a long time, Please update your archisoarchiso!!!"
                exit 30
    esac
}

# @安装系统
function Installation_System(){
    INFO_Root_partition=$(run_tools file_rw INFO Read "Root_partition")  
    if [ -n "$INFO_Root_partition" ]; then  # 后续待修改部分
        Install_Archlinux
    else
        run_tools process restart "$0" "${white}The partition is not mounted.${suffix}"
    fi
    run_print_info install_system_info 
    # Chroot到新系统中完成基础配置
    cp -f /etc/pacman.conf $System_Root/etc/pacman.conf 
    cp -f /etc/pacman.d/mirrorlist $System_Root/etc/pacman.d/mirrorlist
    Auins_chroot
}

# @配置系统
function Configure_System(){
    set +e
    Disk_Kernel=$(cat /usr/src/linux/version)
    INFO_Install_Kernel=$(run_tools file_rw INFO Read "LinuxKernel")
    CONF_PGK_Terminal_Tools=$(run_tools file_rw CONF Read "PGK_Terminal_Tools")
    CONF_PKG_SystemctlFile=$(run_tools file_rw CONF Read "PKG_SystemctlFile")
    CONF_PGK_Common_Package=$(run_tools file_rw CONF Read "PGK_Common_Package")
    if [ -n "$INFO_Install_Kernel" ] || [ -n "$Disk_Kernel" ] ; then 
        Configure_Grub
        Configure_users2passwd
        echo;
        Configure_Language
        #---------------------------------------------------------------------------#
        run_tools run "Install the Terminal tools packages."
        Install_Program "$CONF_PGK_Terminal_Tools"
        run_tools feed "Terminal tools packages installation successfully." "Terminal tools packages installation failed."
        
        run_tools run "Install the System file package."
        Install_Program "$CONF_PKG_SystemctlFile"
        run_tools feed "System file package installation successfully." "System file package installation failed."
        
        run_tools run "Install the Other common package."
        Install_Program "$CONF_PGK_Common_Package"
        run_tools feed "Other common package installation successfully." "Other common package installation failed."

        run_tools run "Configure enable Network."
        systemctl enable NetworkManager
        run_tools feed "NetworkManager.service enable successfully." "NetworkManager.service enable failed."
        
        # 删除这个文件，才能进 Normal_Mode
        rm -rf "$local_Dir"/Not_Configure_System 2> /dev/null   
        run_configure_fonts Config_file_install_fonts 

        if [ "$(run_tools file_rw CONF Read "Archlinucn")" = "yes" ]; then Install_Program archlinuxcn-keyring; fi
        run_tools feed "archlinuxcn-keyring installation successfully." "archlinuxcn-keyring installation failed."
    else
        run_tools process restart "$0" "${red}The system is not installed. Exec: 4->2 ${suffix}"
    fi 
    set -e
}

# @删除脚本和缓存
function Auins_delete(){
    run_tools warn "Removing auins and cache!"
    pacman -Scc --clean
    rm -rfv "$modules_Dir"
    rm -rfv "$local_Dir"
    echo -e "\033[1;37m:: $(tput bold; tput setaf 2) ʕ ᵔᴥᵔ ʔ  =>$(tput sgr0) Bye-bye~"
    rm -rf "$0"
}     

# @ Archiso LiveCD 下自动启用
function LiveCD_Mode(){
    run_print_info logos "$CHROOT_PATTERNS_PRINT" "$START_MODE"
    # 检查archiso版本，如果过低，叫提醒更新
    if [[ $CHROOT_PATTERNS_PRINT == "Chroot-OFF" ]]; then
        CONF_Archiso_Version_check=$(run_tools file_rw CONF Read "Archiso_Version_check");
        case $CONF_Archiso_Version_check in [Yy]*) Archiso_version_check "$Livecd_Version_Route"; esac
    fi
    # 输出首页选项列表
    run_print_info livecd_home_list;   
    echo -e "\n${Chroot_status:- }"
    # printf "${outG} ${yellow} Please enter${white}[1,2,3..]${yellow} Exit${white}[${red}Q${white}]${suffix} %s" "$inB"
    run_tools tips_w "Please enter[1,2,3..] Exit[Q]"
    case $(run_tools read) in
        1)  run_update_mirrors ;; # 配置源
        2)  Network Conf_all;; # 配置网络
        3)  Open_SSH ;; # 配置SSH
        4) # 二级列表 隐
            run_print_info livecd_system_module_list;
            echo -e "${input_System_Module_Chroot:- \n}"
            # printf "${outG} ${yellow} Please enter${white}[1,2,3,22..]${yellow} Exit${white}[${red}Q${white}]${suffix} %s" "$inB"
            run_tools tips_w "Please enter[1,2,3,22..] Exit[Q]"
            case $(run_tools read) in
                0)  Auins_chroot ;;
                1)  run_configure_partition ;; # 磁盘分区 隐
                2)  Installation_System ;; # 安装系统 隐 
                3)  # 配置系统 隐
                    # run_update_mirrors
                    Configure_System 
                    sleep 1.5;
                    run_print_info config_system_info ;; 
                4)  Configure_users2passwd ;;
                5)  # 安装桌面
                    Configure_users2passwd
                    run_configure_desktop ;; 
                11) run_configure_drive ;;  # 安装I/O驱动
                22) install_virtualization_service "$Host_Environment"; bash "$0" ;; # 安装Vm tools
            esac ;;
        [Ss]*) bash ;;
        [Qq]* | *) run_tools process stop "$0" 
    esac
}

# @ 安装完Archlinux后 正常可用情况下自动启用
function Normal_Mode(){
    CONF_BlackArch=$(run_tools file_rw CONF Read "BlackArch")
    INFO_BlackArch=$(run_tools file_rw INFO Read "BlackArch")
    [[ $INFO_BlackArch == "" ]] && run_tools file_rw INFO Write BlackArch no
    [[ $CONF_BlackArch == "yes" &&  $INFO_BlackArch == "no" ]] && run_blarckarch_script

    run_print_info logos "$CHROOT_PATTERNS_PRINT" "$START_MODE"
    run_print_info normal_home_list;   
    echo -e "\n${Chroot_status:- }"
    # printf "${outG} ${yellow} Please enter${white}[1,2,3,22..]${yellow} Exit${white}[${red}Q${white}]${suffix} %s" "$inB"
    run_tools tips_w "Please enter[1,2,3,22..] Exit[Q]"
    case $(run_tools read) in
        1)  run_update_mirrors ;; # 配置源
        2)  Network Conf_all;; # 配置网络
        3)  Open_SSH ;; # 配置SSH
        4)  Configure_users2passwd ;;
        5)  # 安装桌面
            Configure_users2passwd
            run_configure_desktop ;;
        6)  run_configure_fonts "Script_Runing_install_fonts" ;;
        11) run_configure_drive;; # 安装I/O驱动
        22) install_virtualization_service "$Host_Environment" ;; # 安装Vm tools
        [Dd]) Auins_delete ;;
        [Ss]*) bash ;;
        [Qq]* | *) run_tools process stop "$0" 
    esac
}

# @Auins的其他选项功能
function Auins_Options(){
    function archiso_version_check_warn(){
        case $1 in 
            enable ) 
                    run_tools file_rw CONF Write Archiso_Version_check "yes" 
                    run_tools feed "Enable: Always check the archiso version." "enable failed." ;;
            disable) 
                    run_tools file_rw CONF Write Archiso_Version_check "no"
                    run_tools feed "Disable: Do not check archiso version." "disable failed." ;;
                    *) 
                    run_tools err "This option was not found $1"
        esac
    }
    function auins_update(){
        case $1 in 
            enable ) 
                    run_tools file_rw CONF Write Now_update_auins "yes" 
                    run_tools feed "Enable: Always Auins update." "enable failed." ;;
            disable) 
                    run_tools file_rw CONF Write Now_update_auins "no"
                    run_tools feed "Disable: Always turn off Auins update." "disable failed." ;;
                    *) 
                    run_tools err "This option was not found $1"
        esac
    }
    case "${1}" in
# Install Commands: ("-S = install", "-R = uninstall")
        font ) 
                run_configure_fonts User_options_install_fonts "$2" 
                exit 0 ;;
        fcitx) 
                Configure_fcitx "$2" 
                exit 0 ;;
        ibus ) 
                Configure_ibus_rime "$2" 
                exit 0 ;;
        axel ) 
                Axel_Configure "$2" 
                exit 0 ;;
        inGpu) 
                run_tools warn "Functional improvement in progress..." 
                exit 0 ;;
        inVmt) 
                install_virtualization_service "$Host_Environment"
                exit 0 ;;
        black) 
                run_blarckarch_script
                exit 0 ;; 
# Settings Options:
        -m | --mirror ) 
                        run_update_mirrors 
                        exit 0 ;;
        -w | --wifi   ) 
                        Network Conf_wifi 
                        exit 0 ;;
        -s | --openssh) 
                        case "$CONF_Service_SSH" in
                            yes) 
                                run_tools skip "activate." ;;
                            *  )  
                                Open_SSH
                        esac
                        exit 0  ;;
# Global Options:
            --update    )   
                            auins_update "$2"
                            exit 0  ;;
            --iso-check )   
                            archiso_version_check_warn "$2"
                            exit 0  ;;
        -e | --edit-conf) 
                            vim "${config_File}" 
                            exit 0 ;;
        -f | --show-conf) 
                            less "${config_File}" 
                            exit 0 ;;
        -i | --show-info) 
                            clear; less "${info_File}" 
                            exit 0 ;;
        -c | --clean-cache) 
                            Auins_delete 
                            exit 0 ;;
        -h | --help     ) 
                            run_print_info auins_usage 
                            exit 0 ;;
        -v | --version  ) 
                            run_print_info version 
                            exit 0 ;;
        [Aa]uins        ) 
                            clear 
                            echo -e "${white}${0##*/}: Thank you for your use. I look forward to not letting you down.${suffix}"; 
                            exit 0 ;;
                        *) 
                            case_return=10 ;;
        # --versions        ) echo "$AUINS_VERSION" | awk -F "v" '{print $NF}' | sed 's/\.//g' | sed 's/-\([a-z][a-z]\+\)//g';
    esac
    if [ "$case_return" = 10 ] && [[ "$1" != "" ]] ; then
        run_print_info auins_usage; run_tools err "This option was not found: $*"
    fi
}

# @该死的颜色
function Set_Color_Variable(){
    # 红 绿 黄 蓝 白 后缀
    red='\033[1;31m'; green='\033[1;32m'  
    yellow='\033[1;33m'; blue='\033[1;36m'  
    white='\033[1;37m'; suffix='\033[0m'     
    #-----------------------------#
    # rw='\033[1;41m'  #--红白
    wg='\033[1;42m'; # ws='\033[1;43m'      #白绿 \ 白褐
    #wb='\033[1;44m'; wq='\033[1;45m'    #白蓝 \ 白紫
    # wa='\033[1;46m';   #白青 \ 
    # bx='\033[1;4;36m'; # 下划线 蓝
    #-----------------------------
    # 提示 绿 黄
    outG="${white}::${green} =>${suffix}"; outY="${white}::${yellow} =>${suffix}"
}

# Start Script | 从这里开始
# >> >> >> >> >> >> >> >> >> >> >> >> 
check_priv
Auins_Variable_init
Set_Color_Variable
Update_Share auins_download_url "$SCRIPTS_SOURCE"  # 锁定脚本下载源
Update_Share download_script        # 下载脚本需要的脚本
Network ethernet_info
Script_init
Auins_Options "$1" "$2" 
# 具体的实现ChrootPatterns
# exec_mode $CHROOT_PATTERNS_PRINT
case "$CHROOT_PATTERNS_PRINT" in 
        Chroot-OFF)
            Chroot_status="${white}::${SHOW_Host_Env} ${green}=> ${yellow}Not Chroot.${suffix}"
            input_System_Module_Chroot="${outY} \t${white}[${yellow}0${white}]${yellow}  arch-chroot ${System_Root}     \t\t${red}**${suffix}\n"
            [ -e $System_Root/root/local/Chroot_ON ] && Auins_chroot 2> /dev/null; 
            START_MODE="LiveCD"
            LiveCD_Mode
        ;;
        Chroot-ON) 
            Chroot_status="${outG}  ${wg}Successfully start: Chroot.${suffix}"
            if [ -e "$local_Dir"/Not_Configure_System ]; then 
                START_MODE="LiveCD"
                LiveCD_Mode
            else 
                START_MODE="Normal"
                Normal_Mode
            fi
    esac
