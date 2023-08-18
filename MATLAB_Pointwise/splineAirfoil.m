% Function used to generate the outline of a parameterised 2D LEI wing profile
%       Author          : John Watchorn
%       Version         : 1
% Inputs:
%       thickness       -> Non-dimensional tube diameter (relative to chord length)
%       eta             -> Max. camber chordwise position (relative to chord length)
%       kappa           -> Max. camber magnitude (relative to chord length)
%       t_canopy        -> Amplified canopy thickness (relative to chord length)
%       th_suction      -> Angular position of edge-tube intersection point 
%                          (relative to LE tube centre) [deg]
%       th_edge         -> Angular position of tube-canopy intersection point 
%                          (relative to LE tube centre) [deg]
%       n_Tube          -> Discrete number of points of circular LE tube profile
%       n_TE            -> Discrete number of points of circular TE profile
% Outputs:
%       points          -> Discrete points of parameterised 2D LEI wing profile
%       ind_ec          -> Index of discrete canopy point closest to tube-canopy 
%                          intersection along x-axis
function [points,ind_ec] = splineAirfoil(thickness,eta,kappa,t_canopy,th_suction,th_edge,n_Tube,n_TE)

%% LE TUBE PROFILE CALCULATIONS

% Angular distribution
th_tube = linspace(pi-deg2rad(th_suction), deg2rad(th_edge)+(2*pi), n_Tube);

% Non-dimensional radius
R = 0.5*thickness;

% Circular tube profile coordinates
x_tube = R*cos(th_tube) + R;
y_tube = R*sin(th_tube);



%% CANOPY SPLINE CALCULATIONS - SUCTION SIDE

% Unit vector describing curve slope at canopy-tube intersection
u_LE = x_tube(1) - x_tube(2);
v_LE = y_tube(1) - y_tube(2);
l_LE = sqrt(u_LE^2 + v_LE^2);

% Canopy spline intersection points
pointsCanopy = { {[1          0]            ''      '' 1000.0},...
                 {[eta        kappa]        [-1  0]},...
                 {[x_tube(1)  y_tube(1)]    [-u_LE -v_LE]/l_LE} };

% Canopy spline
Q_canopy = hobbysplines(pointsCanopy);

% Remove last rows to avoid dual points (leads to problems when meshing)
for i = 1:length(Q_canopy)
    Q_canopy{i}(end,:) = [];
end

% Convert cell array to ordinary array
splineCanopy = cell2mat(Q_canopy')';



%% CANOPY SPLINE CALCULATIONS - PRESSURE SIDE (subscript 't')

% Gradients of lines between successive points
m_canopy    = (splineCanopy(2,2:end) - splineCanopy(2,1:end-1))./(splineCanopy(1,2:end) - splineCanopy(1,1:end-1));
% Angles of orthogonal lines
th_canopy   = atan(-m_canopy.^(-1));

% Sign control
factor = zeros(1,length(th_canopy));
factor(th_canopy > 0) = -1;
factor(th_canopy < 0) = 1;

% x- and y-coordinates of canopy pressure side (based on amplified canopy thickness)
x_canopy_t = t_canopy*factor.*cos(th_canopy) + splineCanopy(1,1:end-1);
y_canopy_t = t_canopy*factor.*sin(th_canopy) + splineCanopy(2,1:end-1);



%% SMOOTH EDGE SPLINE CALCULATIONS

% Find index of discrete canopy point closest to tube-canopy intersection
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

% Remove last row to avoid dual points (leads to problems when meshing)
Q_edge{1}(end,:) = [];

% Convert cell arrays to ordinary arrays
splineEdge = cell2mat(Q_edge')';



%% ROUNDED TE PROFILE CALCULATIONS

% Circular TE profile radius
R_TE = 0.5*t_canopy;
% Circular TE profile centre
xTE_c = 1 + R_TE*sin(atan(m_canopy(1)));
yTE_c =   - R_TE*cos(atan(m_canopy(1)));

% Angular distribution
th_TE = linspace(th_canopy(1) - pi, th_canopy(1), n_TE);

% Circular TE profile coordinates
x_TE = R_TE*cos(th_TE) + xTE_c;
y_TE = R_TE*sin(th_TE) + yTE_c;



%% OUTPUTS

% Assemble coordinates into vector
points = [  [splineCanopy(1,:)          ; splineCanopy(2,:)]...
            [x_tube(1:end-1)            ; y_tube(1:end-1)]...
            [splineEdge(1,:)            ; splineEdge(2,:)]...
            [flip(x_canopy_t(1:ind_ec)) ; flip(y_canopy_t(1:ind_ec))]...
            [x_TE(2:end)                ; y_TE(2:end)]  ];

end