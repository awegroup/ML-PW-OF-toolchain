% This function generates a connector with nodes on a curve (1D mesh).
%       Original author : Gabriel Buendia
%       Editor          : John Watchorn
%       Version         : 2
% Inputs:
%       ID              -> Allocated ID of connector output
%       dim_len         -> Allocated number of connector nodes or spacing
%       ID_DB           -> Input ID of the database curve
%       spacing         -> 'dimension'  : Nodes are created specifying a 
%                                         dimension
%                          'separation' : Nodes are created specifying an 
%                                         average spacing
%       distribution    -> Connector grid point distribution function is
%                          specified : 'MRQS' | 'Tanh'
%       beginSpacing    -> Spacing at beginning of connector
%       endSpacing      -> Spacing at end of connector
%       N.B. For equally spaced connector let beginSpacing = endSpacing = 0
% Outputs:
%       connectorCommand -> String containing the command to write the
%                           connector
function connectorCommand = pwConnector(ID,dim_len,ID_DB,spacing,distribution,beginSpacing,endSpacing)
switch spacing
    case 'dimension'
        dimension = append('pw::Connector setDefault Dimension ',num2str(dim_len),'\n  ');
    case 'separation'
        dimension = append('pw::Connector setDefault Dimension 0\n  ');
end

connectorCommand = append([dimension, ...
                           'set _CN(',num2str(ID),') [pw::Connector createOnDatabase $_DB(',num2str(ID_DB),')]\n', ...
                           '$_CN(',num2str(ID),') replaceDistribution 1 [pw::DistributionTanh create]\n']);
if isequal(spacing,'dimension')
    distributionCommand = append(['set _TMP(mode_1) [pw::Application begin Modify [list $_CN(',num2str(ID),')]]\n', ...
                                  '  pw::Connector swapDistribution ',distribution,' [list [list $_CN(',num2str(ID),') 1]]\n', ...
                                  '  [[$_CN(',num2str(ID),') getDistribution 1] getEndSpacing] setValue ',num2str(endSpacing),'\n', ...
                                  '  [[$_CN(',num2str(ID),') getDistribution 1] getBeginSpacing] setValue ',num2str(beginSpacing),'\n', ...
                                  '$_TMP(mode_1) end\n', ...
                                  'unset _TMP(mode_1)\n']);
    connectorCommand = append(connectorCommand,distributionCommand);
elseif isequal(spacing,'separation')
    distributionCommand = append(['$_CN(',num2str(ID),') setDimensionFromSpacing -resetDistribution ',num2str(dim_len),'\n', ...
                                  'pw::CutPlane refresh\n', ...
                                  'pw::Application markUndoLevel Dimension\n']);
    connectorCommand = append(connectorCommand,distributionCommand);
end
end