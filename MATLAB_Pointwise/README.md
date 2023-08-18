
airfoilPointwise.m

	-> MATLAB-Pointwise interface script for automatically generating a single 2D
	   mesh with O-grid topology.

	-> Uses the functions in the sr_pw directory to create a Pointwise glyph script 
	   (which is a set of code instructions read by Pointwise to generate the mesh)
	   and the project file.

	-> splineAirfoil function is used to generate the outline of the airfoil.
		-> hobbysplines function is the interpolation system applied in splineAirfoil

	-> firstLayerHeight function used to estimate the wall adjacent mesh layer height.


checkMultipleAirfoils.m

	-> Plots the outlines of multiple parameterised LEI wing profiles for inspection
	   (using splineAirfoil function).


checkSingleAirfoil.m

	-> Plots the outline of a single parameterised LEI wing profile for inspection
	   (using splineAirfoil function).
