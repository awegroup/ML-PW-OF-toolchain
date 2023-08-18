
clear;
close all;
clc;



%% OpenFOAM POST-PROCESSING

% Author    : John Watchorn
% Version   : 1

% Use this script to post process all log.simpleFoam files.
%   - Exports convergence plots for residuals and aerodynamic
%     coefficients.
%   - Creates Excel spreadsheet with final Cl, Cd, Cm and max. yPlus (in
%     this column order) from log.simpleFoam file.



%% INPUTS

% Path to OpenFOAM directories containing simulation data
importPath  = 'D:\THESIS\OF_DATA\DATA_2\';

% Name of export directory for processed results
resultsDir = 'RESULTS_2';



%% PROCESS OpenFOAM DATA - MULTIPLE CASES

% Create directory for post-processed results plots and processed results
exportPath = append('C:\Users\jwatc\Desktop\OF_RESULTS\',resultsDir,'\');
mkdir(exportPath);

% Create new directory for convergence plots
convPlotsPath = append(exportPath,'convergence_plots\');
mkdir(convPlotsPath);

% Find and list sub-directory paths
subDir          = dir([importPath,'*\*.']);                         % Find all profile and AoA sub-directories
isub            = [subDir(:).isdir];                                % Return logical vector of directories
profilePaths    = {subDir(isub).folder};                            % Create cell array with profile sub-directory paths
alphaNames      = {subDir(isub).name};                              % Create cell array with names AoA sub-directories
alphaPaths      = append(profilePaths,'\',alphaNames);              % Create cell array with AoA sub-directory paths
alphaPaths(ismember(alphaPaths,append(profilePaths,'\.')))  = [];   % Remove paths of sub-directories .
alphaPaths(ismember(alphaPaths,append(profilePaths,'\..'))) = [];   % Remove paths of sub-directories ..

% List paths of simpleFoam log files
filesSimpleLog = append(alphaPaths,'\log.simpleFoam');

% Initiliase cell array for storing values calculated at final time step
finalValues = cell(length(filesSimpleLog),6);

% Loop through each listed path
for j = 1:length(filesSimpleLog)
    
    % Open, scan and close simpleFoam log file
    fileID         = fopen(filesSimpleLog{j},'r');
    string_full    = fscanf(fileID,'%c');
    fclose(fileID);
    
    % sub-strings: time, residuals, aerodynamic coefficients and y+
    time_s      = [newline 'Time = '];
    Ux_s        = 'Ux, Initial residual = ';
    Uy_s        = 'Uy, Initial residual = ';
    p_s         = 'p, Initial residual = ';
    omega_s     = 'omega, Initial residual = ';
    k_s         = 'k, Initial residual = ';
    Cd_s        = 'Cd       : ';
    Cl_s        = 'Cl       : ';
    Cm_s        = 'CmPitch       : ';
    yPlus_s     = 'y+ : ';
    
    % Extract values in sub-string format and convert to double
    time_val    = str2double(extractBetween(string_full,time_s,newline));
    Ux_val      = str2double(extractBetween(string_full,Ux_s,char(44)));
    Uy_val      = str2double(extractBetween(string_full,Uy_s,char(44)));
    p_val       = str2double(extractBetween(string_full,p_s,char(44)));
    omega_val   = str2double(extractBetween(string_full,omega_s,char(44)));
    k_val       = str2double(extractBetween(string_full,k_s,char(44)));
    Cd_val      = str2double(extractBetween(string_full,Cd_s,char(40)));
    Cl_val      = str2double(extractBetween(string_full,Cl_s,char(40)));
    Cm_val      = str2double(extractBetween(string_full,Cm_s,char(40)));
    
    % Extract all maximum y+ values
    yPlus_string    = extractBetween(string_full,yPlus_s,'average');
    yPlus_val       = str2double(extractBetween(yPlus_string,'max = ',char(44)));
    
    % Values at final time-step
    yPlus_final     = yPlus_val(end);
    Cd_final        = Cd_val(end);
    Cl_final        = Cl_val(end);
    Cm_final        = Cm_val(end);
    
    
    
    %% CONVERGENCE MONITOR PLOTS
    
    % String containing profile name and AoA
    profileAlphaName = strrep(erase(alphaPaths{j},importPath),'\','_');
    
    % Time range of plots
    time_range = time_val(1:end);

    % Plot residuals vs. time steps
    f_residual = figure('visible', 'off'); hold on, grid on
    plot(time_range,Ux_val,'Linewidth',2)
    plot(time_range,Uy_val,'Linewidth',2)
    plot(time_range,p_val,'Linewidth',2)
    plot(time_range,k_val,'Linewidth',2)
    plot(time_range,omega_val,'Linewidth',2)
    hold off
    set(gca,'FontSize',14,'yscale','log')
    xlabel('Iteration step [ - ]','interpreter','latex','FontSize',18)
    ylabel('Residual value [ - ]','interpreter','latex','FontSize',18)
    xlim([time_val(1) time_val(end)])
    LegendResidual = {'$U_{x}$','$U_{y}$','$p$','$k$','$\omega$'};
    legend(LegendResidual,'interpreter','latex','FontSize',14,'NumColumns',2);

    % Plot force coefficients vs. time steps
    f_coeff = figure('visible', 'off'); hold on, grid on
    plot(time_range,abs(Cl_val),'Linewidth',2)
    plot(time_range,abs(Cd_val),'Linewidth',2)
    plot(time_range,abs(Cm_val),'Linewidth',2)
    hold off
    set(gca,'FontSize',14,'yscale','log')
    xlabel('Iteration step [ - ]','interpreter','latex','FontSize',18)
    ylabel('Absolute coefficient value [ - ]','interpreter','latex','FontSize',18)
    xlim([time_val(1) time_val(end)])
    LegendCoeff = {'$\left|C_{l}\right|$','$\left|C_{d}\right|$','$\left|C_{m}\right|$'};
    legend(LegendCoeff,'interpreter','latex','FontSize',14);

    % Export plots in .png format
    exportgraphics(f_residual,append(convPlotsPath,profileAlphaName,'_RESIDUALS.png'));
    exportgraphics(f_coeff,append(convPlotsPath,profileAlphaName,'_COEFFS.png'));
    
    
    
    %% FINAL VALUES CELL ARRAY
    
    % Store values calculated at final time step in cell array
    finalValues{j,1} = profileAlphaName;
    finalValues{j,2} = Cl_final;
    finalValues{j,3} = Cd_final;
    finalValues{j,4} = Cm_final;
    finalValues{j,5} = yPlus_final;
    
    % Check for violations of y+ < 1 condition
    if yPlus_final < 1
        finalValues{j,6} = '';
    else
        finalValues{j,6} = 'FAIL';
    end
    
end

% Export final Cl, Cd, Cm and max. yPlus (in this column order) for each 
% OpenFOAM case to an Excel file
writecell(finalValues,append(exportPath,'final_values_',resultsDir,'.xlsx'));




