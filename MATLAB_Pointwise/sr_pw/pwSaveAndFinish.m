% This function aims to save the mesh in a Pointwise file and close the 
% Pointwise application
%       Author      : Gabriel Buendia
%       Version     : 1
% Inputs:
%       path        -> String that specifies the path for the file to be saved
%       name        -> String that specifies the name of the file to be saved
% Outputs:
%       saveandfinishCommand -> String containing the command to save and
%                               close Pointwise
function saveandfinishCommand = pwSaveAndFinish(path,name)
string = append('{',path,'/',name,'.pw}\n');
saveandfinishCommand = append(['pw::Application save ',string ...
                        'pw::Application exit\n']);
end
