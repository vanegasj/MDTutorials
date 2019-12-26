
![3by3](https://github.com/vanegasj/MDTutorials/blob/master/guz_images/3by3.png)

NOTE:  The star “*” stands for the name of any file.


# GROMACS basics


There are a lot of types of simulations that could be done with GROMACS. Two of the main ones include Atomistic simulations and Coarse Grain (CG) simulations.
## Atomistic simulations model every atom of every molecule and predict the behavior of the system. These simulations are more accurate and reliable than coarse grain simulations, but are very computationally expensive and take more time to generate.
## course grain simulations have a larger "unit" of simulation. Instead of 1 individual atom being the building block of the simulation, the CG model utilizes a carefully picked number of molecules/atoms as the building block of the simulation.
Hence, the course grain model does not calculate/predict the interactions between individual molecule/atoms in the unit and only calculates/predicts  the interactions between units.For example, in the simple case of water molecule, the CG model uses 3 water molecules as the unit. The size units have been optimized such that the loss of accuracy and the computational burden are minimized.
### One of the famoud CG models used is the martini model. We will utilize this model throughout this series of tutorials.


# CHARMMGUI input generator.

## One of the most convinient ways to generate the needed input files is to generate them with an input generator. In this part I cover how you can use CHARMMGUI to generate the input files needed for a successful run. Note that you could use other generators or use your own files.

### After visiting the website ( http://www.charmm-gui.org/ ), click on "input generator" on the left side. Afterwards, click martini maker. Click bilayer out of the options. Choose "membrane only' and subsequently choose matini 22 ( If you needed polarizability of water [e.g. if you had ions/polar proteins in the solution], use martini 22p).
### go to the next step and choose the number and type of lipids you would want in each layer. Usually, to simplify simulations, DPPC phospholipids are used. Choose equal numbers of DPPC lipids for both sides of the bilayer ( you can find this lipid under  PC (phosphatidylcholine) Lipids ).
### click "show the system info" after choosing the lipids and go to the next step.
### unmark the "include ions" option and go to the next step.
### proceed and do not change anything.
### finally, there will be a .tgz file generated. Downlaod the file.
### in the Gromacs folder inside  the file, all required files for your simulation can be found.


To expand the size of a pdb file ( in this case the monolayer pdb file) the following command has to be used:


gmx editconf -f *.pdb -o *.pdb -translate X Y Z

In this command, the variables X Y and Z are the numbers indicating the factor to which  the pdb file is expanded in the x y and z direction respectively. For instance, the command -translate 4 4 1 would expand our monolayer to a square 16 fold are ( with vertices multiplied by 4) but would keep the height of the monolayer constant.


The rest of the process is similar to previous cases as we have to make a new index file, modify the topology file to make sure the numbers of atoms/molecules correspond to the newly modified pdb file and run the two step energy minimization and equilibration.

To make a new index file we use the following command:
module load gromacs

gmx make_ndx -f *.pdb -o index.ndx

Finally the Topology file has to be edited for so that the number of molecules correspond to the new number of molecules.

The rest of the process is similar to the normal bilayer:

there are two separate steps that have to be taken, energy minimization and the mdrun. The necessary files (pdb, top, itp) used in these steps have to be generated through an engine such as CHARMGUI or should be designated from the server (in the case of the itp files). These commands of these steps should be incorporated in a “sh” file ( which is a file containing the commands and the designated computing core )and submitted to the central computing system using the following command:
qsub *.sh 
You can track the progress of the simulation either through the following command
qstat
which gives you information on the recent runs on the central system, or through the error file which is a file named after the “sh” file in the folder of operation and contains information about the current status of the simulation. (NOTE:The first error in the error file is usually the source of the problems of the simulation and is therefore the first thing that has to be addressed). 
In the case that there are unnecessary warnings, you can add a “ -maxwarn N” to the end of the command lines, N being a number.
The index file which will be used in the two steps can be made through the following command from the pdb file:

gmx make-ndx -f *.pdb -o *.ndx

The two steps include the following commands:

Step #1: energy minimization
gmx grompp -f *.mdp -c *.pdb -n *.ndx -o *.tpr
gmx mdrun -c *.pdb -s *.tpr   deffnm emin   -tabel *.xvg

Step #2: mdrun 
gmx grompp -f *.mdp -c *.pdb -n *.ndx -o *.tpr
gmx mdrun -c *.pdb -s *.tpr   deffnm mdrun -tabel *.xvg

The xvg and tpr files generated from the second step can be used to observe the trajectory through programs such as UCSF CHIMERA.
