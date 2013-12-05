#!/bin/bash
cd $PBS_O_WORKDIR
module load openmpi-psm-gcc

RUNPATH=~/dsf/asi/4320/
EXEPATH=/opt/mcgaugheygroup/lammps-19Feb13/src

mpirun -np `cat $PBS_NODEFILE | wc -l` $EXEPATH/lmp_generic < $RUNPATH/lmp.in.sed.6 
