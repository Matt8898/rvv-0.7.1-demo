#extern void vadd(float* v1, float* v2, float* res, int len);
#                 a0         a1         a2          a3
#add two 32-bit floating point vectors of 'len' elements
.global vaddf
vaddf:
1:
#set our vector length to min(len, maximum vector size)
#and store the size of our vectors in t0, set the element size to 32 bits
#and use "m8" to merge 8 vector registers together, since we're only using
#2 of them for this
vsetvli t0, a3, e32, m8
#load from the sources
vlw.v v0, (a0)
vlw.v v8, (a1)

#shifts the pointers by the amount we just loaded
#then adjust the amount of work we have left
slli t1, t0, 2
add a0, a0, t1
add a1, a1, t1
sub a3, a3, t0

#perform addition and store to res
vfadd.vv v16, v0, v8
vsw.v v16, (a2)
add a2, a2, t1

bnez a3, 1b

ret

#extern void saxpy(float a, float* v1, float* v2, float* res, int len);
#                  fa0      a0         a1         a2          a3
#perform y = a*x + y
.global saxpy
saxpy:
1:
vsetvli t0, a3, e32, m8
vlw.v v8,  (a0)
vlw.v v16, (a1)
slli t1, t0, 2
add a0, a0, t1
add a1, a1, t1
sub a3, a3, t0
#v16 = (v8 * fa0) + v16
vfmacc.vf v16, fa0, v8
vsw.v v16, (a2)
add a2, a2, t1
bnez a3, 1b
ret

#extern void sscal(float* x, float a, int n);
#                  a0        fa0      a1 
#x = a * x
.global sscal
sscal:
1:
vsetvli t0, a1, e32, m8
vlw.v v0, (a0)
slli t1, t0, 2
sub a1, a1, t0
vfmul.vf v0, v0, fa0
vsw.v v0, (a0)
add a0, a0, t1
bnez a1, 1b
ret

#extern float sdot(float* x, float* y, int n);
#                  a0        a1        a2
#perform the dot product of two vectors
.global sdot
sdot:
vsetvli t0, a2, e32, m8
vmv.v.i v16, 0
vmv.v.i v24, 0
1:
vsetvli t0, a2, e32, m8
vlw.v v0, (a0)
vlw.v v8, (a1)
vfmul.vv v0, v0, v8
vfredosum.vs v0, v0, v16
vfadd.vv v24, v0, v24
slli t1, t0, 2
sub a2, a2, t0
add a0, a0, t1
add a1, a1, t1
bnez a2, 1b
vfmv.f.s fa0, v24
ret

#extern void reducei(int* in, int* res, int len)
#                     a0       a1        a2
#sum elements of a vector
.global reducei
reducei:
vsetvli t0, a2, e32, m8
vmv.v.i v8, 0
vmv.v.i v16, 0
vmv.v.i v24, 0
.Loop1:
vsetvli t0, a2, e32, m8
vlw.v v0,  (a0)
vredsum.vs v8, v0, v16
vadd.vv v24, v24, v8
slli t1, t0, 2
add a0, a0, t1
sub a2, a2, t0
bnez a2, .Loop1
li a0, 0
vext.x.v a0, v24, a0
sw a0, (a1)
ret

