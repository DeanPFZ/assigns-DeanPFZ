// Write your assembly program for Problem 2 (a) here.
//
// John Adam Czech, Pengfei Zhu, Hele Sha
lbi r1, 1
lbi r2, 2
slt r3, r1, r2 //will set r3 to 1
beqz r3, .Here0
nop
nop
.Here0
addi r3, r2, r1
slt r3, r1, r2 //will set r3 to 1
beqz r3, .Here1
.Here1
addi r3, r2, r1
halt
