% MAIN-SINGLE_RUN.M
% MATLAB Script handles a single iteration run specified by a test ID
% Useful for development and response testing, animation export, or plot
% generation other than Monte Carlo Export

clear; clc; close all;

% Set Test Parameters
testID = 1; % Specify test ID for desired test conditions
randSeed = 1; % Specify a seed used for random number generation
randomizeInitialConditions = true; % Add Guassian noise to simulation initial conditions
displayAnimation = true; % Generating animation results in slower export
modelName = "gnc_ministack_v2"; % Select Simulink Model to be used (constant)

% Add files paths
openProject("Mini_Stack_Simulink_Project.prj");
root = matlab.project.rootProject().RootFolder;

%Add additional paths for folders
addpath(genpath(fullfile(root, "scripts")));
addpath(genpath(fullfile(root, "models")));
addpath(genpath(fullfile(root, "subsystems")));

% Load specified Simulink model simulation
model = load_system(modelName);

% Load in required Simulink Bus Parameters
loadBusTypes();

% Get Standard System Parameters
base = getSystemParameters(testID);

% Set System Initial Conditions
config = setInitialConditions(base, testID, randomizeInitialConditions, randSeed);

% Run Model
data = runModel(config, modelName, displayAnimation);

% Plot Data
plotSingleRun(data, config);

