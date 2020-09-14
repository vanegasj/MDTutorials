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
The newly generated pdb file POPE200_solv.pdb is solvated with the SPCE water model available in the GROMOS force field. It is critical that pdb structure is visualized in VMD/Chimera to MAKE SURE THERE ARE NO WATER MOLECULES IN THE LIPID BILAYER. If there are a few water molecules make sure to delete them from the pdb file. If there are more water molecules, change the VDW radii of lipid acyl chain carbon atoms (tails) to a higher value (One can try 0.6-1.2 Angstrom range). In the case of 200 POPE lipid bilayer membrane, the value was set to 1.1 Angstrom. Adjust the values accordingly.

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
NOTE: The order of molecules in the topol.top has to match the one in pdb file else the gmx will throw residues don't match error.

9. Prepare to perform the energy minimization of the solvated system. The energy minimization is done in two steps:
	1. No bond constraints
	2. With all-bond constraints 

To that, one need to modify the gromacs .mdp file named here as emin.mdp. For the first step with no bond constraints, set 
	define = -DFLEXIBLE
	constraints = none
 
Once the unconstained minimization is done. Set to 
	define = -DPOSRES
	constraints = all-bonds

NOTE: The define flag (-DFLEXIBLE = no constraints (SETTLE algorithm) on water molecules while -DPOSRES = constraints on all system molecules)

In addition, set the temperature coupling (tcoupl) parameter in emin.mdp to the following:
	tc_grps = System
	tau_t = 1.0
	ref_t = 310

Also set integrator = steep. In the case of 200 POPE system, both energy minimizations were done for 5000 steps. A separate file was created for energy minimization with constraints (emin_constraints.mdp). For more detail refer to emin.mdp and emin_constraints.mdp files in the g_membed folder.  

Generate gromacs .tpr file using "grompp" command to perform energy minimization of solvated lipid membrane system (to get rid of any steric clashes and atom overlaps). The separate .tpr files were generated for each unconstrained and constrained all-bonds energy minimization using the command below:
```
gmx grompp -c POPE200_solv_adj.pdb -f emin.mdp -o emin.tpr -maxwarn 1 
gmx mdrun -s emin_contraints.tpr

gmx grompp -c confout.gro -f emin_constraints.mdp -p topol.top -o emin_constraints.tpr -maxwarn 1
gmx mdrun -s emin_contraints.tpr
```
NOTE: The input file POPE200_solv_adj.pdb was generated after adjusting the box dimensions to ensure there were no water molecules between lipid bilayer leaflets and no water molecules outside the box (visually). 

10. Perform the energy minimization sequentially using gromacs "mdrun" after "grompp" command as above. 

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
```
	gmx mdrun -deffnm npt_berendsen -c pope200_npt_berendsen_100ns.pdb
```
NOTE: The -deffnm flag looks for any file with prefix npt_berendsen. In our case the .tpr files is generated using the grompp was named npt_berendsen.tpr. The deffnm flag also helps generate MD simulation output files with prefix "npt_berendsen". The -c flag generate pdb file at the end of the MD simulation for easy visualization.

Refer: run_gromacs.sh in the g_membed folder for more information



PART-2
   
1. Once the equilibrated lipid membrane bilayer is generated the next step is to perform embedding of transmembrane protein into the membrane. The embedding is done using the high lateral pressure (HLP) method (Universal Method for Embedding Proteins into Complex Lipid Bilayers for Molecular Dynamics Simulations - Matti Javanainen, JCTC, 2014 <https://pubs.acs.org/doi/10.1021/ct500046e>). This method is independent of type of lipid membrane, Force field specifications, or any softwares. The protein is inserted into the hosr lipid membrane by applying a large lateral pressure to the system followed by a quick relaxation simulation. Thus, there is no need to delete any lipid and water molecules from the system. 

NOTE: Adjust the box size prior to embedding process to make sure there is atleast 15 Angstrom distance from the molecules heads to box edge on Z-dimension. Use gmx editconf for box dimensions modification. 

2. The first step to perform protein embedding is to prepare the .mdp file. In our case, the .mdp file was named as grompp_hlp_membed.dat. The following changes are to be made in the .mdp file.

```
define = -DPOSRES -DZPOSRES
nsteps = 500000 
refcoord_scaling = com     
tau_p = 20.0
ref_p = 1000 1.0
```
NOTE: A simulation of 1 ns was run (with dt = 2 fs) with position constraints on all-atoms and on water molecules along Z-axis so as to allow free rotation along X-Y axis for it to equilibrate around the protein molecule. The refcoord_scaling set to the Center-Of-Mass (COM) scales the system to COM instead of all atom coordinates which eases the volume transformation during equilibration process. The pressure coupling (tau_p) was set to 20 ps and reference pressure (ref_p) was set to 1000 bar (lateral pressure) in the membrane plane during protein insertion, whereas a value of 1 bar was set to during relaxation simulation (post protein insertion into the membrane). 

3. The heavy atoms (non-hydrogen) of proteins were restrained in all three dimensions. The force contant was changed from 1000 to 10000 kJ/mol nm/squared for all the protein chains (of MscL protein complex) in the .itp files. The files that were modified were as follows:
	1. posre_Protein_chain_A.itp
        2. posre_Protein_chain_B.itp
	3. posre_Protein_chain_C.itp
	4. posre_Protein_chain_D.itp
	5. posre_Protein_chain_E.itp

For example, the first few lines of the modified posre_Protein_chain_A.itp file is given below:
```
; In this topology include file, you will find position restraint
; entries for all the heavy atoms in your original pdb file.
; This means that all the protons which were added by pdb2gmx are
; not restrained.

[ position_restraints ]
; atom  type      fx      fy      fz
     1     1  10000  10000  10000
     5     1  10000  10000  10000
     6     1  10000  10000  10000
     7     1  10000  10000  10000
     8     1  10000  10000  10000
     9     1  10000  10000  10000
    10     1  10000  10000  10000
```
5. For the lipids, the following modifications were made to the lipids_76a7-s3.itp file:
	The following lines were added after the definition of the POPE lipid -
```
#ifdef ZPOSRES
[ position_restraints ]
8   1   0   0   10000
33  1   0   0   10000
52  1   0   0   10000
#endif
```

6. For the water molecules, the following changes were made to the spce.itp file:

```
#ifdef ZPOSRES
[ position_restraints ]
1   1   0   0   10000
#endif
``` 

7. Once the file modifications are done. The next step is to generate the .tpr file using gromacs grompp command.
```
gmx grompp -f pope200_npt_berendsen_100ns.pdb -r pope200_npt_berendsen_100ns.pdb -o 2oar_pope200_1ns_npt_berendsen_embedding.pdb -s membed.tpr -maxwarn 1
```

8. The .tpr file generated is used to perfom NPT MD simulation. The script file is run_gromacs.sh:
```
gmx mdrun -deffnm membed -c 2oar_pope200_embedded_HLP.pdb
```
8. The pdb file generated after embedding/relaxation is visually to make sure it looks fine. The protein should now be centered in the lipid membrane bilayer. It should also roughly tell us the number of lipid layers around the protein. 

9. Next, strip the water molecules from the pdb file either manually or using visualization program. Adjust the box size, if necessary, to make sure there is atleast 15 A distance between the molecules head and box edge along Z-dimension.

The pdb file is renamed as 2oar_pope200_postmembed_dry.pdb.

10. Resolvate the system using gmx solvate command as follows:
```
gmx solvate -cp 2oar_pope200_postmembed_dry.pdb -o 2oar_pope200_postmembed_solv.pdb -cs spc216.gro
```

11. A three step energy minimization is performed following resolvation as before: 
	1. No bond constraints on entire system
	2. No bond constraints on water molecules with bond constraints on non-solvents
	3. All bond constraints  
		
NOTE: Separate .mdp files were constructured for each energy minimization step and .tpr file generated for MD run. 
For the first energy minimization - no bond constaints. The .mdp, .tpr and outputted files (.edr, .trr, .log) are all labeled with the suffix 
```
_noconstraints
```
Similarly for the second and third minimizations the suffixes are 
```
_waterflexible_allconstraints

and 

_allconstraints
```
The confout.gro files that are outputted at the ened of each minimization are named accordingly. Only the last minimization output files (.edr, .trr, .lod) were saved and renamed with the suffix: 
```
ener_emin.edr
traj_emin.trr
md_emin.log
```
NOTE: The all files can be found in g_membed folder.

12. The equilibration run is performed following the last energy minimization. Before equilibration is performed a index file has to be generated with LIPIDS_Protein as a group using gmx make_ndx command as below:
```
gmx make_ndx -f 2oar_pope200_postmembed_solv.pdb -o index.ndx
```
At prompt select -> NONSOL 
(NONSOL = number of protein atoms + number of lipid atoms)
create the new group -> name "groupnumber" lIPIDS_Protein
-> q
 
13. The .mdp file is constructed (grompp_equil.mdp) and .tpr file generated as before. The MD simulation was run with gmx mdrun command in run_gromacs.sh script file:
```
gmx mdrun -deffnm equil -c 2oar_pope200_postmembed_100ns_npt_berendsen.pdb 
```

14. 

 


	
	







































