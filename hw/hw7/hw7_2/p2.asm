// Write your assembly program for Problem 2 (a) here.
//
// Adam Czech, Pengfei Zhu, Hele Sha
//

// The first branch shows what happens without branch prediction
// and the second branch shows what happens with branch prediction
lbi r1, 1
lbi r2, 2
//Case 1
lbi r3, 1
beqz r3, 0
nop
nop
add r3, r2, r1

//Case 2
lbi r3, 1
beqz r3, 0
add r3, r2, r1

//Case 3
lbi r3, 0
beqz r3, 2
nop
add r3, r2, r1
halt

