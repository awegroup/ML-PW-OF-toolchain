
All airfoil directories with OpenFOAM cases ready for simulation are automatically 
placed in this directory after running airfoilPointwise.m

If simulations are conducted on the HPC, upload this directory and execute 
the 'qsub job' command. 

The PBS job script is dynamic and accounts for multiple profile directories and multiple
OpenFOAM cases in those directories (see job script comments).

Remember to change the email address in the job script to your own one.
