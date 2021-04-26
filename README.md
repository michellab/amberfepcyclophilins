# amberfepcyclophilins
Masters Project for RBFE calculations for cyclophilins A, B, D
Using Amber20.


## An explanation of the scripts
Objective 1 and 2 used the same protocol.  
The order of the used steps, script adjustments and things to note are outlined below.  
note: folder locations in scripts will probably need to be adjusted  

### Ligands
pdb files for the used ligands, templates to generate the parameter files and bashscript (prep_compounds) to execute all are in /molecules.  
Atoms are numbered in such a way that each is unique and common atoms between ligands share the same number.  

### Proteins
#### PDBs that were used:
cypA - 6GJN (A4A already docked)  
cypB - 31CH  
cypD (obj1) - 6R8L  
cypD (obj2) - 6R80  
H++ was used to predict protonation states (this might not have been ideal, future runs should check X-rays as well to see likely HIS protonation states).  
Flare was used to dock A4A to cypB and cypD and G1G to cypD.  
PDB of proteins in /MD are for after this docking and residue protonation state changes took place. Crystallographic waters were kept.  

### MD runs for protein to get starting coordinates
Templates and starting pdb files in /MD. A4A or chosen ligand parameters are according to their preparation in /molecules. A link to these needs to be created / they need to be copied over.  
The leap.in file is only a template and needs to be adjusted for the different proteins.  
note: charges in leap script will need to be adjusted so overall zero, depending on which protonation states are used  
note: addIonsRand will need to be adjusted according to box volume to keep a conc of 150 mM  
note: all of the protein / ligand names in the leap script need to be adjusted according to which run the MD is for  
note: min1.in, press.in and heat.in restraint mask needs to be adjusted depending on residue number for the protein  

Final snapshot of the MD runs was used as the starting coordinates for the common atoms for RBFE (setup and free energy).  
For the next steps, deleted the ligand from a copy of the final snapshot and protein, kept all water within 10 Angstrom of the protein, and saved this as cypX.pdb (X = B/D) so it is compatible with the other scripts.  
cypA.pdb (ligand already removed) for obj1 ready to use for next step as no MD was run as it was from Xray.  
cypD.pdb (ligand already removed) for obj2 ready to use for next step (G2G starting transformations) as no MD was run as it was from Xray.  
cypB_A4A.pdb, cypD_A4A.pdb and cypD_G1g.pdb require MD simulations to be run.  

### RBFE
#### To setup the setup and the free energy
A shared pdb file with the ligands for the transformation is required. Copy coordinates (from final snapshot of MD run) so the common atoms have the same coordinates.   Non-common atoms can be deleted, the molecule parameter files will fill in the missing unique atoms.  
The setup_transformation bash script in templates/setup needs parameters adjusted at top for that transformation (which ligands and what the unique atoms are).  
Number of windows also needs to be adjusted. Can adjust which GPU is used.  
note: charges in leap script will need to be adjusted so overall zero, depending on which protein  
note: addIonsRand will need to be adjusted according to box volume to keep a conc of 150 mM (can run just leap, see volume, and adjust)  
A transformation folder should be made.  
Once the setup_transformation is executed, it will substitute the templates as required and make folders.  
#### Running the perturbation
Finally, to run the setup and the free energy and repeats:  
Execute using the execute.sh which will have been made in the transformation folder.  
