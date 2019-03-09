//
// Successful test will load 2 into r2
// Failing test will load 1, 2, or 3 into r2
//
lbi r1, 1
beqz r1, .b_not_taken_1
lbi r1, 100
beqz r1, .b_not_taken_2
lbi r1, 255
beqz r1, .b_not_taken_3
lbi r1, 0
beqz r1, .b_taken
halt

// pass
.b_taken:
lbi r2, 0
halt

// fail test 1 
.b_not_taken_1:
lbi r2, 1
halt

// fail test 2 
.b_not_taken_2:
lbi r2, 2
halt

// fail test 3 
.b_not_taken_3:
lbi r2, 3
halt
