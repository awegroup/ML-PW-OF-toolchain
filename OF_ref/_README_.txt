
This directory contains reference sub-directories which are individual OpenFOAM cases. 

Each case considers a different angle-of-attack (AoA). The remaining flow conditions
and simulation set-up are the same. 

The reference sub-directories are copied after running airfoilPointwise.m in a directory
named after the parameterised airfoil, which is then placed in the UPLOADS directory 
ready for simulation.
	
	--> e.g. if t = 0.06, kappa = 0.14 and eta = 0.22 then the directory name is t6_kappa14_eta22
	--> Each airfoil directory also contains the Pointwise glyph script and project file 
		(the latter shows the actual mesh in Pointwise).
	
To the change the flow conditions of an OpenFOAM case, proceed to system/includeDict

