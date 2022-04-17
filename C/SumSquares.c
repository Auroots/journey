# include <stdio.h>
# include <stdlib.h>

int Operation(void);
int NumberSum(void);
int main(void){
    char Yn;
    do{
        Operation();
        printf("\nDo you still need to calculate? (y/n): ");
        scanf("%c",&Yn);
        getchar();
    }while(Yn=='y'||Yn=='Y');
    return 0;
}
int Operation(void){
    float height,width,number;
    printf("How high is it? : ");
    scanf("%f",&height);
    getchar();
    printf("How wide is it? : ");
    scanf("%f",&width);
    getchar();
    printf("How many sets are there: ");
    scanf("%f",&number);
    getchar();
    printf("Area = %f .\n",((height / 100) * (width / 100)));
    printf("%.0fset of paintings,total area = %.4f .\n",number,((height / 100) * (width / 100)) * number);
    return 0;
}
