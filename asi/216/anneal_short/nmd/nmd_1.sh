#!/bin/bash
cd $PBS_O_WORKDIR
module load openmpi-psm-gcc

RUNPATH=~/dsf/asi/216/anneal_short/nmd/
EXEPATH=/opt/mcgaugheygroup/matlab_R2011a/bin

mpirun -np `cat $PBS_NODEFILE | wc -l` $EXEPATH/matlab -nojvm -nosplash -nodisplay -r -nodesktop < $RUNPATH/nmd_TMP.m

