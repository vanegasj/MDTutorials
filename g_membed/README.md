# Gromacs- Protein in Lipid Membrane Embedding #
The procedure to perform transmemebrane protein (MscL) embedding in the lipid bilayer membrane (POPE) is done in two part process:

Part-1: Generate and equilibrate the lipid bilayer membrane. 

Part-2: Embed the protein into fully equilibrated bilayer membrane. 


PART-1

1. Use MEMGEN tool <http://memgen.uni-goettingen.de> to build a desired lipid bilayer membrane.
 
For example, to build a 200 POPE lipid bilayer. First set each leaflet number to 100. Add desired number of water molecules (max allowed is 99). The water molecules added will be stripped once the membrane pdb file is created so it does not actually matter. But in this case, the number of water molecules were set to 99. Next, set the area/lipid (Angstrom square). For POPE, the area/lipid was set to 60 (based on experimental data, Source:Thermotropic Phase Transitions of Pure Lipids in Model Membranes and Their Modifications by Membrane Proteins, Dr. John R. Silvius, Lipid-Protein Interactions, John Wiley & Sons, Inc., New York, 1982.
Lipid Thermotropic Phase Transition Database (LIPIDAT) – NIST Standard Reference Database 34).The shape of membrane was selected to be HEXAGONAL. The POPE pdb structures with slightly different configurations were uploaded (Pope1.pdb = POPEA, Pope2.pdb = POPEB, Pope3.pdb = POPEC, Pope4.pdb = POPED, Pope5.pdb = POPEE ) from the Gibbs cluster (/home/projects/bilayers/gromos-lipids). 

![Figure-1a] (snapshot1.png)
Figure 1a: Top view of hexagonal box with POPE lipid bilayer with solvent water molecules (POPE200.pdb)
![Figure-1b] (snapshot2.png)
Figure 1b: Side view of hexagonal box with POPE lipid bilayer with solvent water molecules (POPE200.pdb)

2. The lipid bilayer generated is downloaded as a pdb file (POPE200.pdb). The box dimensions are noted for further processing. 
```
CRYST1   77.460   77.460  169.770 
```
3. Water molecules are stripped either manually (linux command to delete all lines below: jDG) or using VMD or CHIMERA visualization programs.
![Figure-2] (snapshot3.png)
Figure 2: The lipid bilayer with water molecules stripped

4. The gromacs topology file (topol.top) with path to force field parameters should be updated with the number of lipid molecules added in MEMGEN. The topol.top file is shown below:

```  
#include "gromacs767-s3s.ff/forcefield.itp"
#include "gromacs767-s3s.ff/lipids_76a7-s3.itp"
#include "gromacs767-s3s.ff/spce.itp"

[system]
POPE200 Hexagonal Box

[molecules]
POPE 200
```

5. Load gromacs module before using gmx command in gibbs cluster. 

```
module load gromacs/2016.3
```

6. Use gromacs "editconf" command to modify the hexagonal box dimensions prior to solvation step:
```
gmx editconf -f POPE200.pdb -o POPE200_box.pdb -box 7.7460 7.7460 15 -angles 90 90 60
```

7. Solvate the hexagonal box with water molecules. 
NOTE: The gromacs adds solvent molecules as rectangular boxes to the exisiting hexagonal box with lipid bilayer membrane. A part of water molecules will fall outside the hexagonal box dimensions (at right angled edges). Modify the Z-box dimensions accordingly to make sure all water molecules fall within the hexagonal box (visually). Normally the box dimension along the Z-axis should be somewhere between 15-15.5 angstrom. 

```
gmx solvate -cp POPE200.pdb -o POPE200_solv.pdb -cs spc216.gro
```
The newly generated pdb file POPE200_solv.pdb is solvated with the SPCE water model available in GROMOS force field. It is critical that pdb structure is visualized in VMD/Chimera to MAKE SURE THERE ARE NO WATER MOLECULES IN THE LIPID BILAYER. If there are a few water molecules make sure to delete them from the pdb file. If there are more water molecules, change the VDW radii of lipid acyl chain carbon atoms (tails) to a higher value. In the case of 200 POPE lipid bilayer membrane, the value was set to 1.1 angstrom. Adjust the values accordingly.

8. Make sure to update the gromacs topology file (topol.top) with the number of water molecules (SOL) added in the solvation.
```
#include "gromacs767-s3s.ff/forcefield.itp"
#include "gromacs767-s3s.ff/lipids_76a7-s3.itp"
#include "gromacs767-s3s.ff/spce.itp"

[system]
POPE200 Hexagonal Box

[molecules]
POPE 200
SOL 15182
```
NOTE: The order of molecules in the topol.top has to match the one in pdb file else the gmx will throw an error.

9. Prepare to perform the energy minimization of the solvated system. The energy minimization is done in two steps:
	1. No bond constraints
	2. With all-bond constraints 

To that, one need to modify the gromacs .mdp file named here as emin.mdp. For the first step with no bond constraints, set 
	constraints = none. 
Once the unconstained minimization is done. Set to 
	constraints = all-bonds

In addition, set the temperature coupling (tcoupl) parameter in emin.mdp to the following:
	tc_grps = System
	tau_t = 1.0
	ref_t = 310

Set integrator = steep and number of steps (nsteps) to a required number. In the case of 200 POPE system, both energy minimizations were done for 5000 steps. A separate file was created for energy minimization with constraints (emin_constraints.mdp). For more detail refer to emin.mdp and emin_constraints.mdp files in the g_membed folder.  

Generate gromacs .tpr file using "grompp" command to perform energy minimization of solvated lipid membrane system (to get rid of any steric clashes and atom overlaps). The separate .tpr files were generated for each unconstrained and constrained all-bonds energy minimization using the command below:
```
gmx grompp -c POPE200_solv_adj.pdb -f emin.mdp -o emin.tpr -maxwarn 1 
gmx mdrun -s emin_contraints.tpr

gmx grompp -c confout.gro -f emin_constraints.mdp -p topol.top -o emin_constraints.tpr -maxwarn 1
gmx mdrun -s emin_contraints.tpr
```
NOTE: The input file POPE200_solv_adj.pdb was generated after adjusting the box dimensions to ensure there were no water molecules between lipid bilayer leaflets and no water molecules outside the box (visually). 

10. Perform the energy minimization sequencially using gromacs "mdrun" after "grompp" command as above. 

NOTE: confout.gro is a gromacs coordinate file that is generated after the first energy minimization run (unconstrained bonds) and is used as input for the second energy minimization run (all-bonds constrained). The other files that has information on energies, trajectories, minimization run outputs, log files are generated as well. Make sure to rename them and save for further analysis.

11. The minimization run for lipid bilayer system should yield negative potential energy and force on each atom (Fmax) value should be >10^3 (or within few limits). This parameters indicate that the system is stable, energy minimized, and ready for equilibration. 

12. A short system equilibration (NPT) is done to equilibrate solvent water molecules around lipid bilayer membrane. The grompp.mdp file contains necessary parameters to perform NPT MD run. It is important to set these parameters to the following:

	tcoupl = nose-hoover
	tc-grps = LIPIDS SOL
	tau_t = 1.0 1.0
	ref_t = 310 310

NOTE: Temperature coupling is initiated to keep the temperature uniform between lipid bilayer and solvent water.

	pcoupl = berendsen
	pcoupltype = semiisotropic 
	tau_p = 5.0
	ref_p = 1.01325 1.01325
	compressibility = 4.5e-5 4.5e-5

nsteps = 125000 and timestep (dt) = 0.002 ps (2 fs) for a total simulation time of 250 ps.

Refer: grompp.mdp in the g_membed folder for full information

13. Before equilibration is performed, it is necessary to generate a index file for the entire lipid bilayer system. This is done using the gromacs "make_ndx" command as follows:
```
gmx make_ndx -f POPE200_solv_adj.pdb -o index.ndx
```
NOTE: select system (all molecules) and then create a group constituting all lipid molecules by typing "name group number LIPIDS"when prompted then "q" to exit. A new index file for the system will be generated.

14. Use gromacs "grompp" command to generate .tpr file to perform system equilibration as follows:
```
gmx grompp -f grompp.mdp -c confout.gro -r confout.gro -p topol.top -o npt_berendsen.tpr -n index.ndx -maxwarn 1
gmx mdrun -s npt_berendsen.tpr  
```
NOTE: If number of steps is longer than few hundred nanoseconds it is preferable to submit jobs on cluster as sbatch file than on head node. 

15. The pressure equilibration and other parameters can be visualized once the NPT run is done to confirm if system reached equilibrium. The trajectories, energies, log files are generated along with the checkpoint file that can be used to continue MD run in case simulation crashes at some point. Make sure to rename and save all these files as well. 

16. A longer equilibration MD run (~100 ns) follows prior short NPT if the system shows acceptable potential energy and Fmax values (all steps are listed and detailed in the md.log file from that MD run).

17. For the longer NPT run, set nsteps in the grompp.mdp file to:
	nsteps = 50000000 (for a total simulation time of 100 ns)

18. Generate the .tpr file for longer equilibration NPT run using gromacs "grompp" as follows:
```
	gmx grompp -f grompp.mdp -c confout.gro -r confout.gro -p topol.top -o npt_berendsen.tpr -n index.ndx -maxwarn 1
```
NOTE: All short NPT equilibration files were renamed as with the suffix "_250ps_npt_berendsen.filetype". The confout.gro is output from the short NPT run. 

19. A sbatch script file (run_gromacs.sh) was created to submit long equilibration MD simulation job to cluster (gibbs).

Refer: run_gromacs.sh in the g_membed folder for more information



PART-2
   



