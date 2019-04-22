#!/bin/bash

mkdir ../verification/results/

wsrun.pl -pipe -list ~sinclair/courses/cs552/spring2019/handouts/testprograms/public/inst_tests/all.list proc_hier_pbench *.v
yes | cp summary.log ../verification/results/simple.summary.log

wsrun.pl -pipe -list ~sinclair/courses/cs552/spring2019/handouts/testprograms/public/complex_demo1/all.list proc_hier_pbench *.v
yes | cp summary.log ../verification/results/complex.summary.log

wsrun.pl -pipe -list ~sinclair/courses/cs552/spring2019/handouts/testprograms/public/rand_simple/all.list proc_hier_pbench *.v
yes | cp summary.log ../verification/results/rand_simple.summary.log

wsrun.pl -pipe -list ~sinclair/courses/cs552/spring2019/handouts/testprograms/public/rand_complex/all.list proc_hier_pbench *.v
yes | cp summary.log ../verification/results/rand_complex.summary.log

wsrun.pl -pipe -list ~sinclair/courses/cs552/spring2019/handouts/testprograms/public/rand_ctrl/all.list proc_hier_pbench *.v
yes | cp summary.log ../verification/results/rand_ctrl.summary.log

wsrun.pl -pipe -list ~sinclair/courses/cs552/spring2019/handouts/testprograms/public/rand_mem/all.list proc_hier_pbench *.v
yes | cp summary.log ../verification/results/rand_mem.summary.log

wsrun.pl -pipe -list ~sinclair/courses/cs552/spring2019/handouts/testprograms/public/complex_demo2/all.list proc_hier_pbench *.v
yes | cp summary.log ../verification/results/complex_demo2.summary.log

wsrun.pl -pipe -list ../verification/mytests/all.list proc_hier_pbench *.v
yes | cp summary.log ../verification/results/mytests.summary.log
