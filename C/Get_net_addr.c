#include <stdio.h>
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <string.h>
#include <net/if.h>
#include <sys/ioctl.h>
#include <netinet/in.h>
// #include <sys/types.h>
// #include <sys/socket.h>
// #include <net/if_arp.h>
// #include <arpa/inet.h>
// #include <errno.h>
// #include <ifaddrs.h>
//Linux 获取网络地址 - 待完善
#define MAX_LENGTH 254

int obtain_Interface_name2mac(void)
{
    struct ifreq ifr;
    struct ifconf ifc;
    char buf[2048];
    int success = 0;
 
     int sock = socket(AF_INET, SOCK_DGRAM, IPPROTO_IP);
    if (sock == -1) {
        printf("socket error\n");
        return -1;
    }
 
    ifc.ifc_len = sizeof(buf);
    ifc.ifc_buf = buf;
    if (ioctl(sock, SIOCGIFCONF, &ifc) == -1) {
        printf("ioctl error\n"); 
        return -1;
    }
 
    struct ifreq* it = ifc.ifc_req;
    const struct ifreq* const end = it + (ifc.ifc_len / sizeof(struct ifreq));
    char szMac[64];
    int count = 0;
    for (; it != end; ++it) {
        strcpy(ifr.ifr_name, it->ifr_name);
        if (ioctl(sock, SIOCGIFFLAGS, &ifr) == 0) {
            if (! (ifr.ifr_flags & IFF_LOOPBACK)) { // don't count loopback
                if (ioctl(sock, SIOCGIFHWADDR, &ifr) == 0) {
                    count ++ ;
                    unsigned char * ptr ;
                    ptr = (unsigned char  *)&ifr.ifr_ifru.ifru_hwaddr.sa_data[0];
                    snprintf(szMac,64,"%02X:%02X:%02X:%02X:%02X:%02X",*ptr,*(ptr+1),*(ptr+2),*(ptr+3),*(ptr+4),*(ptr+5));
                    // printf("$%s\t$%s\n",  ifr.ifr_name, szMac);
                }
            }
        }else{
            printf("NULL\n");  // get mac info error
            return -1;
        }
        printf("%s\t\t$%s\n",  ifr.ifr_name, szMac);
    }
}

int obtain_Interface_ip(void)
{
       char ipAddr[MAX_LENGTH];

    ipAddr[0] = '\0';

    struct ifaddrs * ifAddrStruct = NULL;
    void * tmpAddrPtr = NULL;

    if (getifaddrs(&ifAddrStruct) != 0)
    {
        //if wrong, go out!
        printf("NULL \n");  // Somting is Wrong!
        return -1;
    }

    struct ifaddrs * iter = ifAddrStruct;

    while (iter != NULL) {
        if (iter->ifa_addr->sa_family == AF_INET) { //if ip4
            // is a valid IP4 Address
            tmpAddrPtr = &((struct sockaddr_in *)iter->ifa_addr)->sin_addr;
            char addressBuffer[INET_ADDRSTRLEN];
            inet_ntop(AF_INET, tmpAddrPtr, addressBuffer, INET_ADDRSTRLEN);
            if (strlen(ipAddr) + strlen(addressBuffer) < MAX_LENGTH - 1)
            {
                if (strlen(ipAddr) > 0)
                {
                     strcat(ipAddr, "\n");
                     
                }
                strcat(ipAddr, addressBuffer);
            }
            else
            {
                printf("NULL\n"); //Too many ips!
                break;
            }
        }
        iter = iter->ifa_next;
    }
    printf("%s \n",ipAddr);
    return 0;
}

int main(void)
{
//     char sss = obtain_Interface_name2mac();
//    char aaa = obtain_Interface_ip();
    obtain_Interface_name2mac();
    printf("@\n");
    obtain_Interface_ip();
//      printf( sss,  aaa );
    return 0;
}
