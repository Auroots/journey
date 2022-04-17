#!/bin/bash
# Author: Auroot/BaSierl
# Wechat：Auroot
# URL Blog  : www.auroot.cn 
# URL GitHub: https://github.com/BaSierL
# URL Gitee : https://gitee.com/auroot
# Home URL: : https://www.auroot.cn

 # 脚本 或者 进程
_APP_EXEC_="node"
Process_PID=$(pgrep -f "${_APP_EXEC_}" | awk '{for(i=0;++i<=NF;)a[i]=a[i]?a[i] FS $i:$i}END{for(i=0;i++<NF;)print a[i]}')
function start(){
    export PASSWORD="orange"
    /home/wwwroot/code.auroot.cn/code-server/code-server --port 8088 --host 0.0.0.0 2>&1 &
}
function stop(){
    kill -15 ${Process_PID}
}
function restart(){
    stop 2>&1
    start 2>&1 
}

function Code_Management(){
    Exec_status="${1}"   # 启动 重启 停止

    case ${Exec_status} in
    "start")
        start
    ;;
    "restart")
        restart
    ;;
    "stop")
        stop        
    ;;
    esac    
}
Code_Management "${1}" # 1.状态
