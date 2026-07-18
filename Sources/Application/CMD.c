#include <stdio.h>
const char PressCommand[] = "Press Command - >";
uint32_t Base_address,video_memory_point = 0x00000000,key_status,cmd_char_num = 17,line_char_num = 17,line_num = 0;
uint8_t color = 0x07;
char key,command[127] = {0};
volatile static __attribute__((noinline)) void enter(){
    print(PressCommand);
    cmd_char_num = 17;
    line_char_num = 17;
    line_num = 0;
    for(int i = 0;i < 127;i++){
            command[i] = 0;
    }
    return;
}
volatile static __attribute__((noinline)) void back_space(){
    if(cmd_char_num <= 17){
        return;
    }
    __asm__ __volatile__ (
        "movb $0x03,%%ah\n"
        "int $0x30\n"
        "movb $0x80,%%ah\n"
        "int $0x30\n"
        :
        : "a"(color)
        : "edi","ebx","edx","memory"
    );
    cmd_char_num = cmd_char_num - 1;
    line_char_num = line_char_num - 1;
    if(line_char_num <= 0){
        video_memory_point = video_memory_point - 0x00000100;
        line_num = line_num - 1;
        line_char_num = line_char_num = 79;
    }
    return;
}
volatile static __attribute__((noinline)) void have_key(){
    __asm__ __volatile__ ("": "=c"(key): :);
    if(key == 0x1C){
        enter();
        key_status = 0x00000000;
        return;
    }
    else if(key == 0x0E){
        back_space();
        key_status = 0x00000000;
        return;
    }
    type(key);
    cmd_char_num = cmd_char_num + 1;
    line_char_num = line_char_num + 1;
    if(line_char_num >= 80){
        test_colling();
        line_num = line_num + 1;
        line_char_num = 0;
    }
    command[cmd_char_num - 17] = key;
    key_status = 0x00000000;
    return;
}
volatile __attribute__((section(".entry"), naked))
void main_func(){
    Base_address = Server(0);
    print("OpenFerain Command Shell @ 1.1.26.7.1");
    video_memory_point = video_memory_point + 0x00000100;
    print(PressCommand);
    for(;;){
        __asm__ __volatile__ ("" : "=a"(key_status): :"ecx","memory");
        if(key_status == 0x00000001){
            have_key();
        }
    }
    ret();
}