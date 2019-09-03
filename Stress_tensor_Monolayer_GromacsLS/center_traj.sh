#!/bin/bash

#SBATCH --ntasks=1                  # Number of nodes 
#SBATCH --time=02:00:00             # Wall clock time
#SBATCH -p interactive

module load gromacs
mkdir frame
echo System System | gmx trjconv -n -s mdrun.tpr -f mdrun.trr -split 5000 -center -o frame.trr

