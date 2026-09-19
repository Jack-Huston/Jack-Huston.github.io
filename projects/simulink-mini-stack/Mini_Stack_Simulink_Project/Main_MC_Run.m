% MAIN-MONTE_CARLO.M
% MATLAB Script runs a Monte Carlo campaign for a selected test case and
% produces aggregate performance plots.

clear; clc; close all;

% Set Test Parameters
testID = 1;                                % Specify test ID for desired test conditions
nMC = 50;                                  % Number of Monte Carlo runs
randSeed = 1;                              % Base seed for random number generation
randomizeInitialConditions = true;         % Randomize initial conditions per run (predictable via mcIter)
displayAnimation = false;                  % Keep false for Monte Carlo speed
modelName = "gnc_ministack_v2";            % Select Simulink Model to be used (constant)

% Add files paths
openProject("Mini_Stack_Simulink_Project.prj");
root = matlab.project.rootProject().RootFolder;

% Add additional paths for folders
addpath(genpath(fullfile(root, "scripts")));
addpath(genpath(fullfile(root, "models")));
addpath(genpath(fullfile(root, "subsystems")));

% Load specified Simulink model simulation
model = load_system(modelName);

% Load in required Simulink Bus Parameters
loadBusTypes();

% Get Standard System Parameters
base = getSystemParameters(testID);

% Run Monte Carlo
mc = struct();
mc.testID = testID;
mc.nMC = nMC;
mc.randSeed = randSeed;
mc.modelName = modelName;
mc.run = repmat(struct("data", [], "config", [], "mcIter", 0), 1, nMC);

for k = 1:nMC
    mcIter = k;                                                % MC iteration index (predictable randomization)
    config = setInitialConditions(base, testID, randomizeInitialConditions, randSeed, mcIter);
    
    % Run to this point for the demonstration, then run the plot section if needed.
    
    data = runModel(config, modelName, displayAnimation);
   

    disp("Running iteration " + k);
    mc.run(k).data = data;
    mc.run(k).config = config;
    mc.run(k).mcIter = mcIter;
end

%% Plot aggregate Monte Carlo results
%load("dataExport.mat");
plotMCRun(mc, config);
