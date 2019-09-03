#!/bin/bash

#SBATCH -p interactive
#SBATCH --ntasks 20
#SBATCH --time 70:00:00


module load gromacs

#gmx grompp -f mdrun.mdp -c step7_production.gro -t step7_production.trr -n index.ndx -o mdrun.tpr -maxwarn 6
gmx grompp -f emin.mdp -c 200DPPC_POLARmartini_1-1ratio.pdb -n index.ndx -o emin.tpr -maxwarn 6
gmx mdrun -s emin.tpr -nt 1 -c 200DPPC_POLARmartini_1-1ratio_Emin.pdb -maxh 70 -deffnm emin

gmx grompp -f mdrun.mdp -c 200DPPC_POLARmartini_1-1ratio_Emin.pdb -n index.ndx -o mdrun.tpr -maxwarn 6
gmx mdrun -s mdrun.tpr -nt 20 -c 200DPPC_POLARmartini_1-1ratio_1ns.pdb -maxh 70 -deffnm mdrun
