#ifndef      STDIO_H
#define      STDIO_H
#include <stdint.h>
extern uint8_t color; 
extern uint32_t video_memory_point;
extern uint32_t Base_address;

static __attribute__((noinline)) uint32_t Server(uint8_t Funcnum){
    uint32_t ret_val;
    __asm__ __volatile__ (
        "movb %%al,%%ah\n"
        "int $0x31\n"
        : "=a"(ret_val)
        : "a"(Funcnum)
        : "ebx","edi","memory"
    );
    return ret_val;
}
volatile static __attribute__((noinline)) __volatile__ void test_colling(){
    video_memory_point = video_memory_point + 0x00000100;
    if(video_memory_point >= 0x00001700){
        video_memory_point = video_memory_point - 0x00000100;
        __asm__ __volatile__ (
        "movb $0x02,%%ah\n"
        "int $0x30\n"
        "movb $0x04,%%ah\n"
        "movl $0x00000016,%%edi\n"
        "int $0x30\n"
        "movb $0x80,%%ah\n"
        "int $0x30\n"
        :
        : 
        : "eax","ebx","ecx","edx","edi","esi","memory"
        );
    }
    return;
}
volatile static __attribute__((noinline)) void print(const char *s){
    test_colling();
    uint32_t len = 0;
    while (s[len])++len;
    __asm__ __volatile__ (
        "movb $0x00,%%ah\n"
        "int $0x30\n"
        "movb $0x80,%%ah\n"
        "int $0x30\n"
        :
        : "S"(s + Base_address),"D"(video_memory_point),"c"(len),"a"(color)
        : "ebx","edx","memory"
    );
    return;
}
volatile static __attribute__((noinline)) void type(char s){
    __asm__ __volatile__ (
        "movb $0x01,%%ah\n"
        "int $0x30\n"
        "movb $0x80,%%ah\n"
        "int $0x30\n"
        :
        : "c"(s),"a"(color)
        : "edi","memory"
    );
    return;
}
static __attribute__((noinline)) void ret(){
    __asm__ __volatile__ (
        "movb $0x80,%%ah\n"
        "int $0x31\n"
        : 
        :
        :
    );
}

#endif