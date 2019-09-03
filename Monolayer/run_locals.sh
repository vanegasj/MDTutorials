#!/bin/bash

#SBATCH --nodes=1                  # Number of nodes 
#SBATCH --time=96:00:00             # Wall clock time
#SBATCH --ntasks-per-node=20

module load intel-mpi

module load gromacs-ls/2016.3-gcc
scratch=scratch_LP
mkdir $scratch

for i in `seq 0 19`
do
    #hostnr=$[$i/20]
    #hostID=`scontrol show 'hostname' | awk NR==$[$hostnr+1]`
    #echo scontrol show 'hostname' > test
    #echo $hostID >> test
    #mpiexec --np 1 --host $hostID gmx_LS mdrun -lscont all -lsfd ccfd -s rerun.tpr -rerun ./frame/frame$i.trr -o $scratch/$i.trr -e $scratch/$i.edr -g $scratch/$i.log -c $scratch/$i.pdb -localsgrid 0.1 -lsgridx 1 -lsgridy 1 -ols st1d$i.dat &
    mpiexec --np 1 gmx_LS mdrun -lscont all -lsfd ccfd -s rerun.tpr -rerun ./frame/frame$i.trr -o $scratch/$i.trr -e $scratch/$i.edr -g $scratch/$i.log -c $scratch/$i.pdb -localsgrid 0.1 -lsgridx 1 -lsgridy 1 -ols secondtry/st1d$i.dat &
done
wait
rm -rf $scratch
