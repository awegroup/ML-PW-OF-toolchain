% Function used to calculate the initial mesh layer height [m] based on the 
% Reynolds number and y+ = 1
%       Author          : John Watchorn
%       Version         : 1
% Input:
%       Re              -> Chord-based Reynolds number
% Output:
%       delta_s         -> Wall-adjacent mesh layer height (Pointwise input)
function delta_s = firstLayerHeight(Re)

%% FLOW CONDITIONS

% y+ value [-]
y_plus = 1.;

% Air density [kg/m^3]
rho = 1.;

% Free-stream velocity [m/s]
U_inf = 1.;

% Chord length [m]
c = 1.;



%% CALCULATE GRID SPACING

% Dynamic viscosity [kg/m/s]
mu = (rho*U_inf*c)/Re;

% Flat plate skin friction coefficient [-]
c_f = 0.027*Re^(-1/7);

% Wall shear stress [kg/m/s^2]
tau_w = 0.5*c_f*rho*U_inf*U_inf;

% Friction velocity [m/s]
u_tau = sqrt(tau_w/rho);

% First cell layer height [m]
y = (y_plus*mu)/(u_tau*rho);

% Round y to nearest significant figure [m]
%   --> Value used in Pointwise mesh
delta_s = round(y,1,'significant');

end