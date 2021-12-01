/*
 * Simple math functions to illustrate basic rvv capabilities
 */

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>
#define S(x) sizeof(x)/sizeof(int)

extern void vaddf(float* v1, float* v2, float* res, int len);
extern void saxpy(float a, float* v1, float* v2, float* res, int len);
extern void reducei(int* in, int* res, int len);
extern void sscal(float* x, float a, int n);
extern float sdot(float* x, float* y, int n);

void vaddf_scalar(float* v1, float* v2, float* res, int len) {
    for (int i = 0; i < len; i++) {
        res[i] = v1[i] + v2[i];
    }
}

void saxpy_sequential(float a, float* v1, float* v2, float* res, int len) {
    for (int i = 0; i < len; i++) {
        res[i] = a * v1[i] + v2[i];
    }
}

int main() {
    srand((unsigned int)time(NULL));

    float* m1 = malloc(sizeof(float) * 100 * 100);
    float* m2 = malloc(sizeof(float) * 100 * 100);
    float* r  = malloc(sizeof(float) * 100 * 100);
    float* r2 = malloc(sizeof(float) * 100 * 100);

    for (int i = 0; i < 100 * 100; i++) {
        m1[i] = ((float)rand()/(float)(RAND_MAX)) * 3.0;
        m2[i] = ((float)rand()/(float)(RAND_MAX)) * 3.0;
    }

    vaddf(m1, m2, r, 100 * 100);
    vaddf_scalar(m1, m2, r2, 100 * 100);

    printf("%f %f\n", r[0], r2[0]);
    int c = 1;
    for (int i = 0; i < 100 * 100; i++) {
        c &= r[i] == r2[i];
        if(r[i] != r2[i]) {
            printf("error at %d %f %f %f %f\n", i, r[i], r2[i], m1[i], m2[i]);
            return 1;
        }
    }

    printf("vaddf success: %x\n", c);

    saxpy(3.0, m1, m2, r, 100 * 100);
    saxpy_sequential(3.0, m1, m2, r2, 100 * 100);

    printf("%f %f\n", r[0], r2[0]);

    int a[128] = {0};

    for (int i = 0; i < 100; i++) {
        a[i] = rand()%((10+1)-1) + 1;
    }

    int ri  = 0;
    int ri2  = 0;

    for (int i = 0; i < S(a); i++) {
        ri2 += a[i];
    }
    reducei(a, &ri, S(a));

    printf("reduction success: %i %i\n", ri, ri2);
    
    printf("m1 before: %f\n", m1[0]);

    sscal(m1, 3.0, 10);

    printf("m1 after: %f\n", m1[0]);

    float da[] = {1.f, 3.f, -5.f};
    float db[] = {4.f, -2.f, -1.f};

    float res = sdot(da, db, 3);
    
    printf("dot: %f\n", res);
}
