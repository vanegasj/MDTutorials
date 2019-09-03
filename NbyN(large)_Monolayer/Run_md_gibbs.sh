#!/bin/bash

#SBATCH -p gpu
#SBATCH -n 1
#SBATCH --ntasks-per-node 20 
#SBATCH --time 70:00:00


module load gromacs

#gmx grompp -f mdrun.mdp -c step7_production.gro -t step7_production.trr -n index.ndx -o mdrun.tpr -maxwarn 6
gmx grompp -f bmw_membrane_emin.mdp -c 200PROTEINS_01.pdb -n index.ndx -o emin.tpr -maxwarn 6
gmx mdrun -s emin.tpr -nt 1 -c 200DPPC_BMWmartini_1-1ratio_1SPF_Emin.pdb -maxh 70 -deffnm emin -table table.xvg

gmx grompp -f bmw_membrane_mdrun.mdp -c 200DPPC_BMWmartini_1-1ratio_1SPF_Emin.pdb -n index.ndx -o mdrun_1000ns.tpr -maxwarn 6
gmx mdrun -s mdrun_1000ns.tpr -nt 20 -c 200DPPC_BMWmartini_1-1ratio_1SPF_200ns.pdb -maxh 70 -deffnm mdrun -table table.xvg
