
clear;
close all;
clc;



%% MATLAB-Pointwise interface

% Author    : John Watchorn
% Version   : 1

% Use this script to generate a single 2D mesh with O-grid topology in Pointwise
%   - Opens Pointwise, generates mesh then closes Pointwise automatically 
%   - MATLAB functions are in the sr_pw directory
%   - Creates OpenFOAM directories (based on OF_ref) in UPLOADS ready for simulation



%% INPUTS

% Name of UPLOADS directory in which 2D profile directories are stored
uploadsName = 'UPLOADS_3';

% Non-dimensional airfoil shape parameters (w.r.t. chord length) of parameterised LEI wing profile
thickness   = 0.14;     % Non-dimensional tube diameter [-]
kappa       = 0.20;     % Maximum camber magnitude [-]
eta         = 0.28;     % Maximum camber chordwise position [-]

% Chord-based Reynolds number [-]
Re = 5e6;

% Spline curve inputs
t_canopy    = 0.001;    % Amplified canopy thickness (w.r.t. chord length, for meshing) [-]
th_suction  = 20;       % Angular position of edge-tube intersection point (relative to LE tube centre) [deg]
th_edge     = 60;       % Angular position of tube-canopy intersection point (relative to LE tube centre) [deg]
% Circular profiles discrete number of points
n_Tube      = 200;      % LE tube
n_TE        = 20;       % Rounded TE

% Pointwise normal mesh extrusion
initStep        = firstLayerHeight(Re); % Initial mesh layer height [m] (based on Re and y+ = 1)
growthFactor    = 1.1;                  % Growth factor (between 1.1 and 1.2)
dimTotal        = 575;                  % Total number of airfoil surface grid points (on the wall)
numLayers       = 200;                  % Number of mesh layers (away from the wall)
% Hyperbolic smoothing parameters
explSmooth      = 5.0;                  % Explicit smoothing:    Default is 0.5; between 0 and 10
implSmooth      = 2*explSmooth;         % Implicit smoothing:    Default is 1.0; between 0 and infity but double explicit smoothing
kbSmooth        = 5.0;                  % Kinsey Barth:          Default is 0.0; greater than 3 if mesh front includes severe concavities
volSmooth       = 0.5;                  % Volume smoothing:      Default is 0.5; between 0 and 1



%% CREATE STORAGE DIRECTORY

% Path of directory in which profile directories are stored
uploadsPath = append('C:\Users\jwatc\Desktop\UPLOADS\',uploadsName,'\');

% Create directory for 2D profile
profileName     = append('t',num2str(thickness*100),'_kappa',num2str(kappa*100),'_eta',num2str(eta*100));
profilePath     = append(uploadsPath,profileName,'\');
mkdir(profilePath);

% Copy OpenFOAM reference directories (for each AoA)
refPath = 'C:\Users\jwatc\Desktop\OF_ref\';
copyfile(refPath,profilePath);



%% Pointwise COMMANDS

% Create and open new Pointwise glyph file
glyphName = append(profileName,'.glf');
fileName = fopen(append(profilePath,glyphName),'w');
fprintf(fileName,'package require PWI_Glyph 5.18.5\n');
path = 'C:\Users\jwatc\Desktop\MATLAB_Pointwise\sr_pw\';
addpath(path)

% Generate airfoil spline points
[points,ind_ec] = splineAirfoil(thickness,eta,kappa,t_canopy,th_suction,th_edge,n_Tube,n_TE);

% Generate point database from MATLAB splines
for i = 1:length(points)
    pointsSplines = pwPoints(i,points(1,i),points(2,i),0);
    fprintf(fileName,pointsSplines);
end


% Indices of connector break points
indCamber   = 100;
indTube     = 199;
indTube_t   = indTube + n_Tube - 1;
indEdge     = indTube_t + 99;
indTE_t     = length(points) - n_TE + 1;
indCamber_t = indTE_t - 99;

% Pointwise dimensions
dimTube     = round(eta*dimTotal);
dimTE       = 10;
dimCanopy   = round(0.5*(dimTotal - dimTube - dimTE + 3));

% Check total dimension consistency
dimCheck = dimTube + dimTE + 2*dimCanopy - 3;

% Adjust LE tube dimension if necessary
if dimCheck == dimTotal + 1
    dimTube = dimTube - 1;
elseif dimCheck == dimTotal - 1
    dimTube = dimTube + 1;
end


% Connector break point and dimension distribution
list    = [1 ind_ec indEdge indTE_t length(points)];
dim_len = [dimCanopy dimTube dimCanopy dimTE];

% Generate curves and connectors
for j = 1:length(list)-1
    
    % Generate database curves
    curves = pwCurve(j+1000,list(j):list(j+1));
    fprintf(fileName,curves);
    
    % Generate equally spaced connectors
    connectors = pwConnector(j+1000,dim_len(j),j+1000,'dimension','Tanh',0.0,0.0);
    fprintf(fileName,connectors);
    
end

% Copy spacings from equally spaced connectors and paste to beginning or
% end of adjacent connector for tanh node distribution.  
%   --> This way there are no abrupt changes in cell size between two
%   adjacent connectors. 
copyPaste = pwCopyPaste(1004,1001,'begin');
fprintf(fileName,copyPaste);
copyPaste = pwCopyPaste(1004,1003,'end');
fprintf(fileName,copyPaste);
copyPaste = pwCopyPaste(1002,1001,'end');
fprintf(fileName,copyPaste);
copyPaste = pwCopyPaste(1002,1003,'begin');
fprintf(fileName,copyPaste);


% Extrude mesh in the wall-normal direction
%   --> Outcome is a fully structured mesh with O-grid topology
ID_CN = 1001:1000+length(list)-1;
extrudeCommand = pwExtrude(10001,ID_CN,initStep,growthFactor,numLayers,...
                           explSmooth,implSmooth,kbSmooth,volSmooth);
fprintf(fileName,extrudeCommand);


% Save directory
savePath = append('C:/Users/jwatc/Desktop/UPLOADS/',uploadsName,'/',profileName);

% Export boundary conditions and volume mesh to dummy polyMesh directory
dummyPath = append(savePath,'/polyMesh/');
mkdir(dummyPath);
exportCommand = pwExportOPF2D(ID_CN,dummyPath);
fprintf(fileName,exportCommand);


% Create and save Pointwise file
saveandfinishCommand = pwSaveAndFinish(savePath,profileName);
fprintf(fileName,saveandfinishCommand);

% Open Pointwise and save file
pathPointwise = '''C:\Program Files\Cadence\FidelityPointwise2022.2\win64\bin''';
launchApplication = append('powershell -command "cd ',pathPointwise,'"; powershell -command .\Pointwise.exe ',profilePath,glyphName);
system(launchApplication);
while ~exist(append(savePath,'/',profileName,'.pw'))
    fprintf('...\n')
end
fprintf(append('Meshing completed and saved in ',savePath,'/',profileName,'.pw\n'));

% Close Pointwise
fclose(fileName);


% Coppy and paste dummy polyMesh directory, then delete dummy
copyfile(dummyPath,append(savePath,'/AoA_0/constant/polyMesh/'));
copyfile(dummyPath,append(savePath,'/AoA_5/constant/polyMesh/'));
copyfile(dummyPath,append(savePath,'/AoA_10/constant/polyMesh/'));
copyfile(dummyPath,append(savePath,'/AoA_15/constant/polyMesh/'));
rmdir(dummyPath, 's');


