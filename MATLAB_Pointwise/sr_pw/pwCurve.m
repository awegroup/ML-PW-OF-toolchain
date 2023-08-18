% This function aims to generate single curve from a list of points
% for Pointwise language
%       Author      : Gabriel Buendia
%       Version     : 1
% Inputs:
%       ID          -> Allocated ID of database curve output
%       list        -> List of point IDs that belong to the curve
%       options     -> NaN : Simple curve joining points
%                      1   : Spline using Catmull-Rom algorithm
%                      2   : Spline using Akima algorithm
% Outputs:
%       curveCommand -> String containing the command to write the curve
function curveCommand = pwCurve(ID,list,options)
size = length(list);
string = '';
for i = 1:size
    auxstr = strcat('  $_TMP(PW_1) addPoint [list 0 0 $_DB(', ...
        num2str(list(i)),')]\n'); 
    string = append(string,auxstr);
end
if nargin < 3
    options = '';
else
    switch options
        case 1
            options = '  $_TMP(PW_1) setSlope CatmullRom\n';
        case 2
            options = '  $_TMP(PW_1) setSlope Akima\n';
    end
end
curveCommand = append(['set _TMP(mode_1) [pw::Application begin Create]\n  ' ...
    'set _TMP(PW_1) [pw::SegmentSpline create]\n'], ...
    string, ...
    options, ...
    '  set _DB(',num2str(ID),[') [pw::Curve create]\n' ...
    '  $_DB(',num2str(ID),') addSegment $_TMP(PW_1)\n' ...
    '  unset _TMP(PW_1)\n$_TMP(mode_1) end\n' ...
    'unset _TMP(mode_1)\n']);
end