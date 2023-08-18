# MATLAB-Pointwise-OpenFOAM toolchain

The toolchain automatically meshes parametrized 2D airfoils and creates the required directory infrastructure for subsequent CFD simulations. It was developed during a graduation project [[1]](#References) as a derivative of an earlier toolchain for 3D wings [[2]](#References).

The 2D meshes are generated in Pointwise with O-grid topology. The directory infrastructure is setup for OpenFOAM cases with different Angle of Attack. The scripts are tailored to the parameterized Leading-Edge Inflatable (LEI) wing profiles investigated in [[1]](#References), but the functions should work with any 2D shape if the airfoil outline is changed in the main script.

The CFD simulations were performed on the High Performance Computer (HPC) of the faculty of Aerospace Engineering of TU Delft.

For more information visit the subdirectories in this repository and have a look at the README.md files.

## Prerequisites

1. MATLAB
1. Pointwise
2. OpenFOAM

## Step 1:

Use MATLAB_Pointwise/airfoilPointwise.m script to generate a single 2D structured mesh with O-grid topology in Pointwise.

Pointwise is automatically opened, the mesh is generated, then Pointwise is automatically closed with the file saved.

The volume conditions are also automatically translated from Pointwise to OpenFOAM format and exported to the constant/polyMesh sub-directory of each OpenFOAM case for the grid.

Given the O-grid topology, no remeshing is required when changing the angle-of-attack (AoA). Instead, the direction of the inlet velocity vector orthogonal to the far-field boundary is adjusted.

Reference OpenFOAM cases that consider different AoAs are copied from the OF_ref directory, then pasted in a directory named after the parameterised airfoil which is then placed in the UPLOADS directory ready for simulation.

## Step 2:

Upload the UPLOADS directory, containing all the airfoil sub-directories, to the HPC with the given PBS job script (remember to change the email address in the job script).

Otherwise, run the simulations on your local machine if they're not too computationally expensive. For this you will need to install Ubuntu.

## Step 3:

If uploaded to the HPC and once complete (you will receive an email whenever a job has finished or been terminated prematurely), download the raw data to the 		OF_DATA directory.

## Step 4:

Use the processOFdata.m script to process the raw data from each log.simpleFoam	file in OF_DATA and export results to the OF_RESULTS directory.

This generates and saves the residual and aerodynamic coefficient convergence plots of each simulated OpenFOAM case.

This also creates an Excel spreadsheet with the final Cl, Cd, Cm and max. yPlus (in this column order) for each OpenFOAM case.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

## References

[1] J. Watchorn: Aerodynamic Load Modelling for Leading Edge Inflatable Kites. MSc Thesis, Delft University of Technology, 2023. [http://resolver.tudelft.nl/uuid:42f611a2-ef79-4540-a43c-0ea827700388](http://resolver.tudelft.nl/uuid:42f611a2-ef79-4540-a43c-0ea827700388)

[2] G. Buendía Vela: Low and High Fidelity Aerodynamic Simulations for Airborne Wind Energy Box Wings. MSc Thesis, Delft University of Technology, 2022. [http://resolver.tudelft.nl/uuid:cb622969-16bf-4da8-aa7e-9e8109b935dd](http://resolver.tudelft.nl/uuid:cb622969-16bf-4da8-aa7e-9e8109b935dd)
