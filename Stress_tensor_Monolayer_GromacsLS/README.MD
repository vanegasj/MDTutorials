 
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

# Stress tensor graphing

To graph the stress tensor of a monolayer/bilayer, we need to use a modified version of gromacs called gromacs_LS.


Fristly, we need to run the normal version of the simulation ( the specifics of this part can be found in other tutorials depending on the type of simulation[bilyaer vs monolayre, constant pressure vs constant volume] that is being run).

qsub Run_md_gibbs.sh


Secondly, now that we have generated a complete trajectory, we have to center the system so that we have consistent frames across the bilayer/monolayer.



qsub center_traj.sh


Now, the gromacs_LS module has to be used to create an alternative tpr file ( preferably called rerun.tpr). Loading the command works in different ways on different clusters. The cluster the simulations run on uses the following command:



gmx_LS grompp -f *.mdp -c *.pdb -n index.ndx -o rerun.tpr


(IMPORTANT NOTE: The mdp file for this operation is different from the mdp of other operations and the gmx_LS command will only work with the appropriate mdp file)



Finally, the centered frames and the rerun.tpr file  have to be used to generate a final xvg file that illustrates the stress across teh monolayer/bilayer in  the form of a graph.


qsub run_locals.sh


You have to then compile are .dat files into one .xvg file:


tensortools -f *.dat0 --prof z -o localstress.xvg


After this phase, you can plot the resulting xvg file and observe a graph of the stress tensor of your simulation. you can use the plot command outside of the cluster if you have it on your system, if not, ask your instructor and install it on your system a convinient way to visualize graphs.

# Visualization of the output file (.xvg)

To visualize the output file, a wide array of programs can be used.





![Stress Tensor](https://github.com/vanegasj/MDTutorials/blob/master/guz_images/stress.png)
