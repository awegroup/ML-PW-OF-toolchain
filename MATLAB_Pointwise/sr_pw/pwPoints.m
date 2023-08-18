% This function aims to generate single point for Pointwise language
%       Author      : Gabriel Buendia
%       Version     : 1
% Inputs:
%       ID          -> Allocated ID of database point output
%       x           -> x coordinate of the point
%       y           -> y coordinate of the point
%       z           -> z coordinate of the point
% Outputs:
%       pointCommand -> String containing the command to write the point
%       in Pointwise
function pointCommand = pwPoints(ID,x,y,z)
pointCommand = append('set _DB(', num2str(ID),[') [pw::Point create]\n' ...
    '$_DB(',num2str(ID),') setPoint {'],num2str(x,'%.6f'),' ', ...
    num2str(y,'%.6f'),' ',num2str(z,'%.6f'),'}\n');
end