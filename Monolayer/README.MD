

![Monolayer](https://github.com/vanegasj/MDTutorials/blob/master/guz_images/monolayer.png)





NOTE:  The star “*” stands for the name of any file.


# GROMACS basics


There are a lot of types of simulations that could be done with GROMACS. Two of the main ones include Atomistic simulations and Coarse Grain (CG) simulations.
## Atomistic simulations: 
They model every atom of every molecule and predict the behavior of the system. These simulations are more accurate and reliable than coarse grain simulations, but are very computationally expensive and take more time to generate.
## Course Grain simulations:
They have a larger "unit" of simulation. Instead of 1 individual atom being the building block of the simulation, the CG model utilizes a carefully picked number of molecules/atoms as the building block of the simulation.
Hence, the course grain model does not calculate/predict the interactions between individual molecule/atoms in the unit and only calculates/predicts  the interactions between units.For example, in the simple case of water molecule, the CG model uses 3 water molecules as the unit. The size units have been optimized such that the loss of accuracy and the computational burden are minimized.
### One of the famous CG models used is the martini model. We will utilize this model throughout this series of tutorials.


# CHARMMGUI input generator.

One of the most convenient ways to generate the needed input files is to generate them with an input generator. In this part I cover how you can use CHARMMGUI to generate the input files needed for a successful run. Note that you could use other generators or use your own files.

After visiting the website ( http://www.charmm-gui.org/ ), click on "input generator" on the left side. Afterwards, click martini maker. Click bilayer out of the options. Choose "membrane only' and subsequently choose matini 22 ( If you needed polarizability of water [e.g. if you had ions/polar proteins in the solution], use martini 22p).
go to the next step and choose the number and type of lipids you would want in each layer. Usually, to simplify simulations, DPPC phospholipids are used. Choose equal numbers of DPPC lipids for both sides of the bilayer ( you can find this lipid under  PC (phosphatidylcholine) Lipids ).

click "show the system info" after choosing the lipids and go to the next step.

unmark the "include ions" option and go to the next step.

proceed and do not change anything.

finally, there will be a .tgz file generated. Downlaod the file.
in the Gromacs folder inside  the file, all required files for your simulation can be found.

 



# monolayer pdb file generation:


The basics of the monolayer simulation is the same as the normal bilayer simulations. The only difference is that the bilayer PDB file has to be first inverted, and then half of the molecules (the water molecules and the phospholipid molecules) have to be deleted from the PDB file using a text editor. Moreover, an index file has to be made from the new PDB file, and the TOP (topology) file has to be edited using a text editor for the number of molecules/atoms  to match the new number of molecules. 
The following commands have to be executed:

For an inverted bilayer, the pdb file has to be shifted upwards exactly half the total height of the box (this information can be found in the first line of the pdb file). 

gmx editconf -f *.pdb -o *.pdb -translate 0 0 N

p.s. N is half of the height of the box of the original pdb file.

Then, half of the molecules have to be deleted through the “vim” command or the editor of the midnight commander.

The resulting PDB has to be used to generate the index.ndx file.



gmx make_ndx -f *.pdb -o index.ndx

Finally the Topology file has to be edited for so that the number of molecules correspond to the new number of molecules ( after deleting half of the PDB molecules).



# Running the program:


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

