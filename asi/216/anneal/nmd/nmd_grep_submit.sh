#!/bin/sh

qsub -l walltime=4:00:00,nodes=1,mem=2gb nmd_grep.sh
