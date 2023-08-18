
clear;
close all;
clc;



%% CHECK SINGLE 2D PROFILE SHAPE

% Author    : John Watchorn
% Version   : 1

% Use this script to check the shape of a single 2D LEI wing profile

% If the profile doesn't show in the plot it is due to one of the 
% following reasons:
%   - The canopy spline overshoots the maximum camber point, leading to a
%   bump at the front (all points must be below kappa)
%   - The condition 0.5*thickness <= kappa has been violated
%   - The condition eta >= thickness has been violated



%% INPUTS

% Non-dimensional airfoil shape parameters (w.r.t. chord length)
thickness   = 0.10;    % Non-dimensional tube diameter [-]
kappa       = 0.10;    % Maximum camber magnitude [-]
eta         = 0.20;    % Maximum camber chordwise position [-]

% Spline curve inputs
t_canopy    = 0.001;    % Amplified canopy thickness (for meshing) [-]
th_LE       = 20;       % Begin angle of tube profile [deg]
th_edge     = 60;       % End angle of tube profile [deg]
% Circular profiles discrete number of points
n_Tube      = 200;      % LE tube 
n_TE        = 20;       % Rounded TE



%% PLOT: Airfoil outline for mesh generation

% Generate discrete points of the 2D profile
[points,~] = splineAirfoil(thickness,eta,kappa,t_canopy,th_LE,th_edge,n_Tube,n_TE);

% Plot the outline of the 2D profile
figure, hold on, grid on
header = ['$t$ = ',num2str(thickness),'; \ \ $\kappa$ = ',num2str(kappa),'; \ \ $\eta$ = ',num2str(eta)];
title(header,'interpreter','latex','FontSize',20)

% If shape requirements are met, show outline
if points(2,:) <= kappa & eta >= thickness & kappa >= 0.5*thickness
    plot(points(1,:), points(2,:))
    plot(eta,kappa,'*')
end

xlabel('$x/c$ [ - ]','interpreter','latex','FontSize',18)
ylabel('$y/c$ [ - ]','interpreter','latex','FontSize',18)
xlim([-0.04 1.04])
Legend_mesh = { 'Airfoil outline', 'Max. camber: $\left(\eta,\kappa\right)$' };
legend(Legend_mesh, 'interpreter', 'latex', 'FontSize', 14, 'Location', 'Best');
axis('equal')



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Uncomment the following to visualise 2D profile components for reporting
%   --> see Chapter 5 of J.P. Watchorn's MSc thesis for example
%   visualisations and a description of the spline system

%% SPLINE CALCULATIONS: Uncomment for below plots
%{
% LE TUBE PROFILE CALCULATIONS

% Angular distribution
th_tube = linspace(pi-deg2rad(th_LE), deg2rad(th_edge)+(2*pi), n_Tube);

% Non-dimensional radius
R_tube = 0.5*thickness;

% Circular tube profile coordinates
x_tube = R_tube*cos(th_tube) + R_tube;
y_tube = R_tube*sin(th_tube);



% CANOPY SPLINE CALCULATIONS - UPPER

% Unit vector describing curve slope at canopy-tube intersection
u_LE = x_tube(1) - x_tube(2);
v_LE = y_tube(1) - y_tube(2);
l_LE = sqrt(u_LE^2 + v_LE^2);

% Canopy spline intersection points
pointsCanopy = { {[1            0]          ''      '' 1000.0},...
                 {[eta          kappa]      [-1  0]},...
                 {[x_tube(1)    y_tube(1)]  [-u_LE -v_LE]/l_LE} };

% Canopy spline
Q_canopy = hobbysplines(pointsCanopy);



% ROUNDED TE PROFILE CALCULATIONS

% TE gradient
m_TE = (Q_canopy{1}(2,2) - Q_canopy{1}(1,2))/(Q_canopy{1}(2,1) - Q_canopy{1}(1,1));

% Circular TE profile radius
R_TE = 0.5*t_canopy;
% Circular TE profile centre
xTE_c = 1 + R_TE*sin(atan(m_TE));
yTE_c =   - R_TE*cos(atan(m_TE));

% Angular distribution
th_canopyTE = atan(-1/m_TE);
th_TE       = linspace(th_canopyTE - pi, th_canopyTE, n_TE);

% Circular TE profile coordinates
x_TE = R_TE*cos(th_TE) + xTE_c;
y_TE = R_TE*sin(th_TE) + yTE_c;



% CANOPY SPLINE CALCULATIONS - LOWER (subscript 't')

% Convert cell array to ordinary array
splineCanopy = cell2mat(Q_canopy')';

% Gradients of lines between successive points
m_canopy    = (splineCanopy(2,2:end) - splineCanopy(2,1:end-1))./(splineCanopy(1,2:end) - splineCanopy(1,1:end-1));
% Angles of orthogonal lines
th_canopy   = atan(-m_canopy.^(-1));
th_canopy(100) = 0.5*pi;

% Sign control
factor = zeros(1,length(th_canopy));
factor(th_canopy > 0) = -1;
factor(th_canopy < 0) = 1;

% x- and y-coordinates of canopy pressure side (based on amplified canopy thickness)
x_canopy_t = t_canopy*factor.*cos(th_canopy) + splineCanopy(1,1:end-1);
y_canopy_t = t_canopy*factor.*sin(th_canopy) + splineCanopy(2,1:end-1);



% SMOOTH EDGE SPLINE CALCULATIONS

% Find index of discrete canopy point closest to circular tube profile end
% along x-axis (hence different y-coordinates)
[~,ind_ec] = min(abs(x_canopy_t - x_tube(end)));

% Unit vector describing curve slope at edge-canopy_t intersection
u_ec = x_canopy_t(ind_ec) - x_canopy_t(ind_ec-1);
v_ec = y_canopy_t(ind_ec) - y_canopy_t(ind_ec-1);
l_ec = sqrt(u_ec^2 + v_ec^2);

% Unit vector describing curve slope at edge-tube intersection
u_et = x_tube(end) - x_tube(end-1);
v_et = y_tube(end) - y_tube(end-1);
l_et = sqrt(u_et^2 + v_et^2);

% Smooth edge end points
pointsEdge = { {[x_tube(end)        y_tube(end)]        [u_et v_et]/l_et},...
               {[x_canopy_t(ind_ec) y_canopy_t(ind_ec)] [-u_ec -v_ec]/l_ec} };

% Smooth edge spline
Q_edge = hobbysplines(pointsEdge);
%}



%% PLOT: Visualisation of geometric components (for meshing)
%{
figure, hold on, grid on
for i = 1:length(Q_canopy)
    plot(Q_canopy{i}(:,1), Q_canopy{i}(:,2), '-')
end
plot(x_tube, y_tube, '-')
for i = 1:length(Q_edge)
    plot(Q_edge{i}(:,1), Q_edge{i}(:,2), '-', 'LineWidth', 2)
end
plot(x_canopy_t(ind_ec:-1:101), y_canopy_t(ind_ec:-1:101), '--')
plot(x_canopy_t(100:-1:1), y_canopy_t(100:-1:1), '--')
plot(x_TE, y_TE, '-', 'LineWidth', 2)
plot(eta,kappa,'*')
plot(eta,kappa-t_canopy,'s')
xlabel('$x/c$ [ - ]','interpreter','latex','FontSize',18)
ylabel('$y/c$ [ - ]','interpreter','latex','FontSize',18)
xlim([-0.02 1.02])
Legend_meshComp = { 'Canopy, rear section, suction side', 'Canopy, front section, suction side', 'Leading-edge tube',...
                    'Edge fillet', 'Canopy, front section, pressure side', 'Canopy, rear section, pressure side',...
                    'Trailing edge', '$\left(\eta,\kappa\right)$', '$\left(\eta,\kappa-t_{canopy}\right)$'};
legend(Legend_meshComp, 'interpreter', 'latex', 'FontSize', 14, 'Location', 'Best');
axis('equal')
%}



%% PLOT: Visualisation of LE tube angles (for meshing)
%{
figure, hold on, grid on
for i = 1:length(Q_canopy)
    plot(Q_canopy{i}(:,1), Q_canopy{i}(:,2), '-')
end
plot(x_tube, y_tube, '-')
for i = 1:length(Q_edge)
    plot(Q_edge{i}(:,1), Q_edge{i}(:,2), '-', 'LineWidth', 2)
end
plot(x_canopy_t(ind_ec:-1:101), y_canopy_t(ind_ec:-1:101), '--')
plot(x_canopy_t(100:-1:1), y_canopy_t(100:-1:1), '--')
plot(x_TE, y_TE, '-', 'LineWidth', 2)
plot(eta,kappa,'*')
plot(eta,kappa-t_canopy,'s')
plot([x_tube(1) 0.5*thickness], [y_tube(1) 0],'k-.')
plot([x_tube(end) 0.5*thickness], [y_tube(end) 0],'k-.')
plot([0 thickness], [0 0],'k--')
plot(0.5*thickness, 0, 'k+')
plot(0.1*thickness*cos(0:(1/360):deg2rad(th_edge))+0.5*thickness,...
     0.1*thickness*sin(0:(1/360):deg2rad(th_edge)), 'k-')
plot(0.1*thickness*cos(pi:-(1/360):pi-deg2rad(th_LE))+0.5*thickness,...
     0.1*thickness*sin(pi:-(1/360):pi-deg2rad(th_LE)), 'k-')
xlabel('$x/c$ [ - ]','interpreter','latex','FontSize',18)
ylabel('$y/c$ [ - ]','interpreter','latex','FontSize',18)
xlim([-0.02 1.02])
axis('equal')
text(0.06,0.004,'$\theta_{edge}$','interpreter','latex','FontSize',18)
text(0.015,0.004,'$\theta_{suction}$','interpreter','latex','FontSize',18)
%}



%% PLOT: Visualisation of geometry and constraints (NOT for meshing)
%{
figure, hold on, grid on
for i = 1:length(Q_canopy)
    plot(Q_canopy{i}(:,1), Q_canopy{i}(:,2))
end
plot(x_tube, y_tube)
plot(0.5*thickness,0,'+')
plot(x_tube(1),y_tube(1),'x')
plot(eta,kappa,'*')
plot(1,0,'o')
xlabel('$x/c$ [ - ]','interpreter','latex','FontSize',18)
ylabel('$y/c$ [ - ]','interpreter','latex','FontSize',18)
xlim([-0.02 1.02])
Legend_geom = { 'Canopy, rear section', 'Canopy, front section', 'Leading-edge tube',...
                'Tube centre: $\left(t/2,0\right)$', 'Tube-canopy intersection',... 
                'Max. camber point: $\left(\eta,\kappa\right)$', 'Trailing-edge point: $\left(1,0\right)$' };
legend(Legend_geom, 'interpreter', 'latex', 'FontSize', 14, 'Location', 'Best');
axis('equal')
%}



%% PLOT: Visualisation of interpolating splines and intersection points
%{
figure, hold on, grid on
plot(splineCanopy(1,:), splineCanopy(2,:), 'b')
plot(x_canopy_t(ind_ec:-1:1), y_canopy_t(ind_ec:-1:1), 'r')
plot(Q_edge{1}(:,1), Q_edge{1}(:,2), 'k', 'LineWidth', 2)
plot([x_tube(1) eta Q_edge{1}(1,1) x_canopy_t(ind_ec)],[y_tube(1) kappa Q_edge{1}(1,2) y_canopy_t(ind_ec)],'^')
plot(1,0,'diamond')
plot(x_tube, y_tube, 'y-')
plot(x_TE, y_TE, 'y-')
xlabel('$x/c$ [ - ]','interpreter','latex','FontSize',18)
ylabel('$y/c$ [ - ]','interpreter','latex','FontSize',18)
xlim([-0.02 1.02])
ylim([-0.61 0.20])
Legend_interp = { 'Canopy, suction side spline', 'Canopy, pressure side spline', 'Edge fillet spline',... 
                  'Prescribed gradient, default tension parameters', 'Default gradient, \textbf{prescribed exit tension of 1000}' };
legend(Legend_interp, 'interpreter', 'latex', 'FontSize', 14, 'Location', 'Best');
axis('equal')
%}


