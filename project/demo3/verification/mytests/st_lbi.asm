//
// This is from the stall test in complex_demo2
//
// lbi r2, L.Data1
// nop
// ld  r3, r2, 0      // r3 = 0x005e
// nop
// add r6, r6, r3     // r6 = 0x011a
// 
// lbi r3, L.Data1
// ld  r4, r3, 0      // r4 = 0x005e
// add r6, r6, r4     // r6 = 0x0178
// st r6, r3, -2      // .Data1-1 = 0x0178
// 
// lbi r3, 0
// 

// lbi r2, 0xc
// nop
// ld r3, r2, 0
// nop
// add r6, r6, r3
// 
// lbi r3, 0xc

ld r4, r3, 0
add r6, r6, r4
st r6, r3, -2
lbi r3, 0
halt
