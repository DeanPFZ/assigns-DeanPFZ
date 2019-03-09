//
// Successful test will load 0,1,2,3,4,5,6,7,8 into r1
// A test failure will have the values above out of order or some will be missing
//

	lbi r1, 0
	jal .test1
.test_2:
	lbi r1, 2
	jal .test2
.test_3:
	lbi r1, 4
	jal .test3
.test_4:
	lbi r1, 6
	jal .test4
.test_5:
	lbi r1, 8
	halt
	halt
	halt
	

.test1:
	lbi r1, 1
	jal .test_2
	
.test2:
	lbi r1, 3
	jal .test_3
.test3:
	lbi r1, 5
	jal .test_4
.test4:
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	lbi r1, 7
	jal .test_5
