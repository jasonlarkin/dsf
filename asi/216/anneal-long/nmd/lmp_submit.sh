#!/bin/sh

qsub -l walltime=12:00:00 -l nodes=1:ppn=8 lmp1.sh
qsub -l walltime=12:00:00 -l nodes=1:ppn=8 lmp2.sh
qsub -l walltime=12:00:00 -l nodes=1:ppn=8 lmp3.sh
qsub -l walltime=12:00:00 -l nodes=1:ppn=8 lmp4.sh
qsub -l walltime=12:00:00 -l nodes=1:ppn=8 lmp5.sh
qsub -l walltime=12:00:00 -l nodes=1:ppn=8 lmp6.sh
qsub -l walltime=12:00:00 -l nodes=1:ppn=8 lmp7.sh
qsub -l walltime=12:00:00 -l nodes=1:ppn=8 lmp8.sh
qsub -l walltime=12:00:00 -l nodes=1:ppn=8 lmp9.sh
qsub -l walltime=12:00:00 -l nodes=1:ppn=8 lmp10.sh
