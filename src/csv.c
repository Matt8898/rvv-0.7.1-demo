#include <stdio.h>
#include <errno.h>
#include <fcntl.h>
#include <stdint.h>
#include <stdio.h>
#include <stdint.h>
#include <sys/time.h>
#define S(x) ((sizeof(x)/sizeof(0[x])) / ((size_t)(!(sizeof(x) % sizeof(0[x])))))

extern void parse_csv(uint8_t* in, uint8_t* out, size_t len, char* orstr);

void parse_sequential(char* str, size_t s, char* strings) {
    int inquotes = 0;
    int q = 0;
    for (int i = 0; i < s-1; i++) {
        if (str[i] == '"') {
            inquotes = !inquotes;
        }

        if (!inquotes && str[i] == ',') {
            strings[q++] = i;
        }
    }
}

int main() {
    char str[] = "a,b,c\",aa,\",d,e,h\"aa,aaaaaa ;asldkgjh;sdalkhg;a;a,,aaaaaa\",asdasdasd,e";
    //currently escape sequences are unsupported, so we manually find quotes here before that is implemented
    uint8_t quotes[S(str)]  = { 0 };
    //array containing the location of every element (minus the initial one)
    uint8_t strings[S(str)] = { 0 };

    for (int i = 0; i < S(str); i++) {
        if (str[i] == '"') {
            quotes[i] = 1;
        }
    }

    parse_sequential(str, S(str), strings);

    for(int i = 0; i < S(str)-1; i++) {
        printf("%d ", strings[i]);
    }

    printf("\n");

    parse_csv(quotes, strings, S(quotes), str);

    for(int i = 0; i < S(str)-1; i++) {
        printf("%d ", strings[i]);
    }
    
    printf("\n");
}
