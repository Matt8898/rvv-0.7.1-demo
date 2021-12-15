.global rle_enc2
#extern void rle_enc(void* src, void* cmp, void* lens, size_t size);
#                          a0         a1         a2           a3
rle_enc2:
li t3, 0
vsetvli t0, a3, e8
vlb.v v1, (a0)
vext.x.v a5, v1, x0
addi a5, a5, 1
li a4, 0
1:
li a6, 0
vsetvli t0, a3, e8
#save the number of processed elements
mv t6, t0
#set up the mask for later
vmv.v.i v0, 1
vlb.v v1, (a0)

#the start of a run is any element that is not equal to the previous element
#in order to handle the edge case of the first element properly we simply set
#the first element to something that will never be equal to it
addi t0, t0, -1
vext.x.v t2, v1, x0
addi t2, t2, 1
vslide1up.vx v8, v1, t2
vmsne.vv v9, v1, v8
#write all of the run starts to v5
vcompress.vm v5, v1, v9
#now we want to find the end of every run, which is exactly the opposite of a start
#including the edge case
vext.x.v t1, v1, t0
addi t1, t1, 1
vslide1down.vx v7, v1, t1
vmsne.vv v10, v1, v7
#now we can get the start and end index for every run
vid.v v2, v0.t
vcompress.vm v3, v2, v9
vcompress.vm v4, v2, v10
#and the amount we're going to write to the output vector
vmpopc.m t0, v9
vsetvli t0, t0, e8
#subtract the starts from the ends and adjust the values
vsub.vv v4, v4, v3
vadd.vi v4, v4, 1
#this is a somewhat hacky way to account for the first element potentially continuing a run
#from a previous iteration, we extract the first element
vext.x.v t5, v5, x0
sub t5, t5, a5
seqz a6, t5
vmv.s.x v0, a6
vmv.s.x v6, a4
#then if the difference between it and the last element of the previous iteration is 0 we unmask
#the first element for the next addition, which will sum the run lengths
vadd.vv v4, v4, v6, v0.t
#and additionally we shift the two pointers back so we overwrite the old values
sub a1, a1, a6
sub a2, a2, a6
vsb.v v4, (a2)
vsb.v v5, (a1)

mv t5, t0
addi t0, t0, -1
vext.x.v a4, v4, t0
vext.x.v a5, v5, t0

sub a3, a3, t6
#TODO make this a little more generic based on the element size
add a0, a0, t6
add a1, a1, t5
add a2, a2, t5

bnez a3, 1b
ret

