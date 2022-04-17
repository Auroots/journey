#!/bin/bash
# Author: Auroot
# Script name：sms (SSH Manager Scripts) 
# Explain: 禁止连接ssh服务失败超过10次的IP;
# Home URL: : https://www.auroot.cn

awk '/Failed/{print $(NF-3)}' < /var/log/secure | sort | uniq -c | awk '{print $2"="$1;}' > /usr/local/bin/black.list
TIME=$(date "+%Y-%m-%d %H:%M:%S")
ip_list=$(cat /usr/local/bin/black.list)
echo -e "\n${TIME}: The rejected IP address is as follows. \n" >> /root/ssh_deny
for i in ${ip_list}; do
    IP=$(echo "$i" | awk -F= '{print $1}')
    NUM=$(echo "$i" | awk -F= '{print $2}')
    if [ "${#NUM}" -gt 1 ]; then
        grep "$IP" /etc/hosts.deny > /dev/null
        if [ $? -gt 0 ]; then
            echo "sshd:${IP}:deny" >> /etc/hosts.deny
        fi
        echo -e "${IP}/${NUM} \n\c" >> /root/ssh_deny
    fi
done
echo "is denied now."
