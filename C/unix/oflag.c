#include <stdio.h>
#include <fcntl.h>


int main(void){
    printf("file = %s\n", open("a",O_WRONLY));
    return 0;
}
