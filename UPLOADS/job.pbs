#!/bin/bash
#PBS -j oe
#PBS -o log.mylog.${PBS_JOBID}
#PBS -N OF_job
#PBS -q fpt-small
#PBS -l walltime=20:00:00
#PBS -l nodes=1:ppn=20:typei
#PBS -m abe
#PBS -M J.P.Watchorn@student.tudelft.nl



##################
# HPC12 commands #
##################

# Shows date and time of job execution and on which node it is running
echo " "
echo Job executed on `uname -n` on `date`
echo " "

# Loads relevant HPC12 modules
module load mpi/openmpi-4.1.2
module load openfoam/v2006
echo "Open MPI v4.1.2 and OpenFOAM v2006 modules loaded"

# Changes directory to the current working directory of the qsub (submit job) command
cd $PBS_O_WORKDIR
echo "Working directory:" $PBS_O_WORKDIR
echo " "



#####################
# OpenFOAM Commands #
#####################

#
# Every loop goes through all AoA sub-directories in each 2D profile sub-directory
#

# Renumbers the cell list of each mesh in order to reduce the bandwidth
# 	--> Creates time directory '1'
for profile_alpha in ./*/*/
do
	
	renumberMesh -case $profile_alpha > $profile_alpha/log.renumberMesh &
	
done
wait
echo "All cases renumbered"

# Checks the validity of each mesh at Time = 0 and Time = 1 (before and after cell renumbering respectively)
for profile_alpha in ./*/*/
do
	
	checkMesh -case $profile_alpha > $profile_alpha/log.checkMesh &
	
done
wait
echo "All numerical grids checked at Time = 0 and Time = 1"

echo "Executing serial simpleFoam simulations simultaneously"

# Runs simpleFoam in serial simultaneously
#	--> The resources of the assigned number of cores are shared
for profile_alpha in ./*/*/
do
	
	simpleFoam -case $profile_alpha > $profile_alpha/log.simpleFoam &
	
	# Creates .foam dummy file for post-processing and visualisation in ParaView
	touch $profile_alpha/foam.foam &
	
done
wait
echo "All simulations complete"
echo " "

# Shows date and time of job termination
echo "Job terminated on " $(date)
