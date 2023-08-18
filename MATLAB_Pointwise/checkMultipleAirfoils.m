
clear;
close all;
clc;



%% CHECK MULTIPLE 2D PROFILE SHAPES

% Author    : John Watchorn
% Version   : 1

% Use this script to check the shapes of multiple 2D LEI wing profiles

% If a profile doesn't show in a tile (i.e. sub-plot) it is due to one of the 
% following reasons:
%   - The canopy spline overshoots the maximum camber point, leading to a
%   bump at the front (all points must be below kappa)
%   - The condition 0.5*thickness <= kappa has been violated
%   - The condition eta >= thickness has been violated

% ALREADY SIMULATED 2D PROFILES
%   - The following combinations of shape parameters have been used to
%   generate profiles that have already been meshed and simulated
%
% UPLOADS 1: 
%   thickness   = [0.05 0.10 0.15];
%   kappa       = [0.20 0.25 0.30];
%   eta         = [0.30 0.35 0.40];
%
% UPLOADS 2:
%   thickness   = [0.06 0.08 0.12 0.14];
%   kappa       = [0.14 0.16 0.18 0.20];
%   eta         = [0.22 0.24 0.26 0.28];



%% INPUTS

% Non-dimensional airfoil shape parameters (w.r.t. chord length)
%   - The for loops are dynamic, so larger or smaller vectors are possible
thickness   = [0.06 0.08 0.12 0.14];
kappa       = [0.14 0.16 0.18 0.20];
eta         = [0.22 0.24 0.26 0.28];

% Spline curve inputs
t_canopy    = 0.001;    % Amplified canopy thickness (for meshing) [-]
th_LE       = 20;       % Begin angle of tube profile [deg]
th_edge     = 60;       % End angle of tube profile [deg]
% Circular profiles discrete number of points
n_Tube      = 200;      % LE tube 
n_TE        = 20;       % Rounded TE



%% 2D PROFILE PLOTS

% Initiliases cell array
points = cell(length(thickness),length(kappa),length(eta));

% Loops over thickness vector
for i = 1:length(thickness)
    
    % Creates figure with tiled layout for sub-plots
    figure(i)
    tcl = tiledlayout(length(kappa),length(eta));
    
    % Loops over kappa vector
    for j = 1:length(kappa)
        
        % Loops over eta vector
        for k = 1:length(eta)
            
            % Generates discrete points of a single 2D profile
            points{i,j,k} = splineAirfoil(thickness(i),eta(k),kappa(j),t_canopy,th_LE,th_edge,n_Tube,n_TE);
            
            % Moves to next tile (i.e. sub-plot)
            nexttile
            hold on, grid on

            % If shape requirements are met, shows 2D profile outline
            if points{i,j,k}(2,:) <= kappa(j) & eta(k) >= thickness(i) & kappa(j) >= 0.5*thickness(i)
                plot(points{i,j,k}(1,:), points{i,j,k}(2,:))
                plot(eta(k),kappa(j),'o')
            end

            hold off
            title(['$\eta$ = ',num2str(eta(k)),'; \ \ $\kappa$ = ',num2str(kappa(j))],'interpreter','latex')
            xlim([-0.02 1.02])
            axis('equal')
            
        end
        
    end
    
    % Generate plot for single thickness with tiles of all combinations
    % of eta and kappa
    title(tcl,['$t$ = ',num2str(thickness(i))],'interpreter','latex','FontSize',16)
    xlabel(tcl,'$x/c$ [ - ]','interpreter','latex','FontSize',14)
    ylabel(tcl,'$y/c$ [ - ]','interpreter','latex','FontSize',14)

end


