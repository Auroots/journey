# SSH 连接限制脚本

## 限制连接ssh服务失败超过10次的IP

```bash
#!/bin/bash
# Author: Auroot
# Script name：sms (SSH Manager Scripts) 
# Explain: 禁止连接ssh服务失败超过10次的IP;
# Home URL: : https://www.auroot.cn

awk '/Failed/{print $(NF-3)}' < /var/log/secure | sort | uniq -c | awk '{print $2"="$1;}' > /usr/local/bin/black.list
TIME=$(date "+%Y-%m-%d %H:%M:%S")
ip_list=$(cat /usr/local/bin/black.list)
echo "${TIME}: The rejected IP address is as follows. " >> /root/ssh_deny.log # 输出到日志文件中；
for i in $ip_list
do
    IP=$(echo "$i" | awk -F= '{print $1}')
    NUM=$(echo "$i" | awk -F= '{print $2}')
    if [ "${#NUM}" -gt 1 ]; then
        grep "$IP" /etc/hosts.deny > /dev/null
        if [ $? -gt 0 ]; then
            echo "sshd:${IP}:deny" >> /etc/hosts.deny
        fi 
        echo -e "${IP} / ${NUM}" >> /root/ssh_deny.log  # 输出到日志文件中；
    fi
done
echo -e "is denied now.\n\n" >> /root/ssh_deny
echo "Execution complete."
```