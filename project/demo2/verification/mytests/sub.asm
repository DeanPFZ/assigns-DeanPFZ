//
// Subtraction Test
//
// r4 = r6 - r5
//

lbi r5, -3
nop
nop
nop
lbi r6, 0x6
nop
nop
nop
nop
sub r4, r5, r6
nop
nop
nop
nop
halt
