#include <stdio.h>
#include <stdint.h>

#define S(x) ((sizeof(x)/sizeof(0[x])) / ((size_t)(!(sizeof(x) % sizeof(0[x])))))
#define P(x) for (int i = 0; i < S(x); i++) { printf("%d, ", x[i]); } putchar('\n');

int main() {
    extern int rle_enc(void* src, void* cmp, void* lens, size_t size);
    extern int rle_enc2(void* src, void* cmp, void* lens, size_t size);
    extern int rle_enc3(void* src, void* cmp, void* lens, size_t size);

    uint8_t seq[] = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1, 2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
    1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1};
    uint8_t cmps[S(seq)] = {0};
    uint8_t lens[S(seq)] = {0};

    uint64_t a = rle_enc2(seq, cmps, lens, S(seq));

    printf("%ld\n", a);

    P(seq);
    P(cmps);
    P(lens);
}
