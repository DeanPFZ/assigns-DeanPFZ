//
// Successful test will load r3 with 0,1,2,3,4 in order
// 
	lbi r1, 0
	lbi r3, 0
	jalr r1, .test1
	halt
	lbi r3, 1
	lbi r1, 2
	jalr r1, .test2
	halt
	lbi r3, 2
	lbi r1, 10
	jalr r1, .test3
	halt
	lbi r3, 3
	lbi r1, 0
	jalr r1, .test4
	halt
	lbi r3, 4
	halt

.test1:
	jalr r7, 2
	halt
	halt
	halt
	halt
	halt
	halt
	halt

.test2:
	halt
	jalr r7, 2
	halt
	halt
	halt
.test3:
	halt
	halt
	halt
	halt
	halt
	jalr r7, 2
	halt
	halt
	halt
	halt
	halt
	halt
	halt
	halt
	halt
	halt
	halt
	halt
	halt
	halt
	halt
	halt
	halt
	halt
	halt
	halt
	halt
	halt
	halt
.test4:
	jalr r7, 2	
	halt
	halt
