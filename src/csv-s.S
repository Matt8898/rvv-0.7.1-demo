.global parse_csv
#extern void parse_csv(char* in, char* out, size_t len, char* string);
parse_csv:
#"carry" element, signifies wether the last chunk ended with an unmatched quote
li t2, 0
li t3, ','
li t5, 0
1:
vsetvli t0, a2, e8
#last element of the vector
addi t1, t0, -1
vlb.v v8, (a0)
vlb.v v1, (a3)
#iota computes the prefix sum of the lsb of the elements
#leaving odd numbers for all indices in the string that are inside quotes
viota.m v0, v8
vadd.vx v0, v0, t2
vand.vi v0, v0, 0x1
#extract carry
vext.x.v t2, v0, t1
vmnot.m v0, v0
#v0 is now a mask for all elements inside quotes
#identify ","s
vmv.v.i v2, 0
vmseq.vx v2, v1, t3, v0.t
#get index of every element
vmv.v.i v0, 1
vid.v v3, v0.t
#vector of indices that have commas
vcompress.vm v4, v3, v2
#don't over-write
vmpopc.m t4, v2
vsetvli t6, t4, e8
#adjust with index
vadd.vx v4, v4, t5
vsb.v v4, (a1)
add a0, a0, t0
add a1, a1, t4
add a3, a3, t0
add t5, t5, t0
sub a2, a2, t0
bnez a2, 1b
ret
