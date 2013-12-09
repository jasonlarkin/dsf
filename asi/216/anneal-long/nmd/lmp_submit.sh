#!/bin/sh

qsub -l walltime=12:00:00 -l nodes=1:ppn=1 lmp1.sh
qsub -l walltime=12:00:00 -l nodes=1:ppn=1 lmp2.sh
qsub -l walltime=12:00:00 -l nodes=1:ppn=1 lmp3.sh
qsub -l walltime=12:00:00 -l nodes=1:ppn=1 lmp4.sh
qsub -l walltime=12:00:00 -l nodes=1:ppn=1 lmp5.sh
qsub -l walltime=12:00:00 -l nodes=1:ppn=1 lmp6.sh
qsub -l walltime=12:00:00 -l nodes=1:ppn=1 lmp7.sh
qsub -l walltime=12:00:00 -l nodes=1:ppn=1 lmp8.sh
qsub -l walltime=12:00:00 -l nodes=1:ppn=1 lmp9.sh
qsub -l walltime=12:00:00 -l nodes=1:ppn=1 lmp10.sh
