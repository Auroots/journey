#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#define SEQ_INIT_SIZE 10;
// #define SEQ_INC_SIZE 2;
typedef int ElemType;
typedef struct
{
    ElemType *data;
    int capacity;
    int cursize; 
}SeqList;

void InSeqList(SeqList *plist)
{
    assert(plist != NULL);
    plist->capacity = SEQ_INIT_SIZE;
    plist->cursize  = 0;
    plist->data = (ElemType*)malloc(sizeof(ElemType)*plist->capacity);
    if(NULL == plist->data)
    {
        printf("ERORR\n");
        exit(EXIT_FAILURE);
    }
}

void PrintSeqList(SeqList *plist)
{
    assert(plist != NULL);
    for(int i = 0; i < plist->cursize; i++)
    {
        printf("%5d", plist->data[i]);
    }
    printf("\n");
}

int FindValua(SeqList *plist, ElemType val)
{
    assert(plist != NULL);
    int pos = plist->cursize -1;

    while (pos >= 0 && plist->data[pos] != val) {
        --pos;
    }
    return pos;
}

int main(){
    SeqList myseq = {};
    InSeqList(&myseq);
    FindValua(&myseq, 5);
    return 0;   
}



