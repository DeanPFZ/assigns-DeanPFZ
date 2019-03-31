//
// Tests all instructions except branchs and jumps. This is mostly just to make 
// sure the control signals are correct before we implement stalling/optimizations.
//
//
subi r1, r2, 25
nop
nop
nop
nop
addi r3, r4, -10
nop
nop
nop
nop
addi r2, r4, 5
nop
nop
nop
nop
addi r3, r1, 5
nop
nop
nop
nop
addi r4, r2, -10
nop
nop
nop
nop
addi r5, r3, 10
nop
nop
nop
nop
addi r6, r1, 4
nop
nop
nop
nop
andni r5, r6, 0
nop
nop
nop
nop
xori r1, r2, 0
nop
nop
nop
nop
roli r4, r1, 12
nop
nop
nop
nop
slli r6, r1, 5
nop
nop
nop
nop
rori r4, r4, 2
nop
nop
nop
nop
srli r1, r2, 5
nop
nop
nop
nop
st r1, r2, 4
nop
nop
nop
nop
st r1, r2, 0
nop
nop
nop
nop
ld r1, r2, 4
nop
nop
nop
nop
stu r5, r6, 5
nop
nop
nop
nop
btr r4, r5
nop
nop
nop
nop
add r1, r2, r3
nop
nop
nop
nop
sub r4, r5, r6
nop
nop
nop
nop
xor r1, r2, r3
nop
nop
nop
nop
andn r1, r2, r3
nop
nop
nop
nop
rol r1, r2, r3
nop
nop
nop
nop
sll r1, r2, r3
nop
nop
nop
nop
ror r5, r2, r3
nop
nop
nop
nop
srl r6, r1, r0
nop
nop
nop
nop
seq r1, r2, r3
nop
nop
nop
nop
slt r2, r3, r4
nop
nop
nop
nop
sle r5, r6, r1
nop
nop
nop
nop
sco r1, r2, r3
nop
nop
nop
nop
lbi r1, 100
nop
nop
nop
nop
slbi r1, -128
nop
nop
nop
nop
halt


