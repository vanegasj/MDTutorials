![Inverted Bilayer](https://github.com/vanegasj/MDTutorials/blob/master/guz_images/inverted%20bilayer_.png)





NOTE:  The star “*” stands for the name of any file.

For an inverted bilayer, the pdb file has to be shifted upwards exactly half the total height of the box (this information can be found in the first line of the pdb file). 

gmx editconf -f *.pdb -o *.pdb -translate 0 0 N

p.s. N is half of the height of the box of the original pdb file.


The rest is similar to a normal bilayer as there are two separate steps that need to be taken, energy minimization and the mdrun. The necessary files (pdb, top, itp)  have to be generated through an engine such as CHARMGUI or should be designated from the server ( in the case of the itp files). There is an additional table command in the second line of command of each step if the simulation requires one. In the case that there are unnecessary warnings, you can add a “ -maxwarn N” to the end of the command lines, N being a number.
The index file can be made through the following command:

gmx make-ndx -f *.pdb -o *.ndx

Module load gromacs
Step #1: energy minimization
gmx grompp -f *.mdp -c *.pdb -n *.ndx -o *.tpr
gmx mdrun -c *.pdb -s *.tpr   deffnm emin   -tabel *.xvg

Step #2: mdrun 
gmx grompp -f *.mdp -c *.pdb -n *.ndx -o *.tpr
gmx mdrun -c *.pdb -s *.tpr   deffnm emin   -tabel *.xvg

These steps could be incorporated in a “sh” file and submitted to the central computing system using the following command:
qsub *.sh '
#### Or if you are using an unmodified version of bash:
bash *.sh

You can track the progress of the simulation either through the following command: 

qstat

#### Or if you are using an unmodified version of bash:

top
