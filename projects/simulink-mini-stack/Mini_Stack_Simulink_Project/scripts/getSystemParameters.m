function config = getSystemParameters(testID)
%GETSYSTEMPARAMETERS Function defines the testID constant parameters that
%describe the cubesat model system
%   INPUTS::
%       testID - Unique ID for each desired test configuration
%       randSeed - Random number generator seed used to generate random variables
%       displayAnimation - Boolean controlling animation display (slower)
%   OUTPUTS::
%       congif - System variable structure holding parameters of interest

%% Set TestID Agnostic Parameters
% Configure metadata information
config.meta = struct();
config.meta.timestamp = string(datetime("now")); % Timestamp of config creation
config.meta.version = "B"; % System parameter generation version identifier

% Configure Simulation Parameters
config.sim = struct();
config.sim.Ts_base = 0.01; % Base simulation time step rate [seconds]
config.sim.Ts_gyro = 0.01; % Gyroscope sensor measurement sample rate [seconds]
config.sim.Ts_star = 0.2;  % Star tracker measurement sample rate [seconds]

% Configure Initial Condition Variance Parameters
config.vari = struct();
config.vari.J_est = 0.0001; % Spacecraft estimated inertia matrix standard deviation [kg * m^2]
config.vari.q_error0 = deg2rad(90); % Initial spacecraft attitude angular standard deviation [rad]
config.vari.w_0 = deg2rad(5); % Initial spacecraft angular velocity standard deviation [rad/s]
config.vari.q_est_error_0 = deg2rad(20); % Estimator initial quaternion estimate error standard deviation [rad]
config.vari.P0_est = [(deg2rad(2))^2*ones(1, 3), (deg2rad(0.5))^2*ones(1, 3)]; % Estimator initial measurement covariance estimate standard deviation
config.vari.dist = 1e-6; %Constant environmental disturbance torques standard deviation applied to all axes [N*m]
config.vari.nom_thrust = 0.0001; % Thruster nominal force standard deviation [N]
config.vari.rw_w0 = deg2rad(50); % Reaction wheel initial angular rate standard deviation [rad/s]
config.vari.gyro_bias0 = deg2rad(0.001); % Gyroscope random walk initial bias standard deviation

% Configure Spacecraft Inertial Properties
config.sc = struct();
config.sc.J_true = diag([0.02, 0.03, 0.04]); % Spacecraft true inertia matrix [kg * m^2]

% Configure Reaction Wheel Properties
config.rw = struct();
config.rw.tau_max = 0.01;                   % Maximum reaction wheel torque [N*m]
config.rw.omega_max = 650;                  % Maximum reaction wheel speed [rad/s]
config.rw.J_wheel = 2e-4*ones(3,1);         % Reaction wheel moment of inertia about spin axis [kg * m^2]
config.rw.fric_visc = 5e-4 * ones(3, 1);    % Reaction wheel viscous friction about spin axis [N*m*s]
config.rw.fric_coul = 1e-5 * ones(3, 1);    % Reaction wheel coulomb friction about spin axis [N*m]

% Configure Thruster Properties
config.thr.force = 0.05;        % Nominal Thruster Force [N]
config.thr.min_pulse = 0.02;    % Minimum thurster on time [seconds]
config.thr.unit_torque = [ 0.00, +0.10, +0.05;... % Thruster torques for 1 N forcing aligned by thruster index
                          -0.10,  0.00, -0.05;...
                          -0.10,  0.00, +0.05;...
                           0.00, -0.10, -0.05;...
                           0.00, -0.10, +0.05;...
                          +0.10,  0.00, -0.05;...
                          +0.10,  0.00, +0.05;...
                           0.00, +0.10, -0.05];

% Configure Gyroscope / Star Tracker Sensor Properties
config.sens = struct();
config.sens.gyro.sigma = deg2rad(0.02); % Gyroscope Gaussian noise standard deviation [rad/s]
config.sens.gyro.bias_rw = deg2rad(0.0002); % Gyroscope bias random walk [rad/s]

config.sens.star.sigma = deg2rad(0.01); % Star Tracker Gaussian noise standard deviation [rad/s]
config.sens.star.dropout_prob = 0.002;  % Star Tracker dropout probability
config.sens.star.dropout_duration = 2;  % Star tracker dropout duration [seconds]

% Configure Multiplicative Extended Kalman Filter Properties
config.est = struct();
config.est.star_sigma    = 1*config.sens.star.sigma;       % Estimator star tracker noise [rad]
config.est.gyro_sigma    = 2*config.sens.gyro.sigma;       % Estimator gyro noise [rad/s]
config.est.gyro_bias_rw  = 1*config.sens.gyro.bias_rw;     % Estimator gyro bias random walk [rad/s]

% Configure Proportional / Derivative Controller Properties
config.ctrl = struct();
config.ctrl.t_settle = 4; % Approximate controller 2% settling time [seconds]
config.ctrl.zeta = 1; % Approximate controller damping ratio

%% Set Model Parameters Unique to Test ID
switch (testID)
    case 1 %Settling to vertical orientation with no body rates
        config.instruct.runTime = 30; % Simulation run time [seconds]
        config.instruct.q_cmd = [0, 1, 0, 0, 0]; % [time, scalar-first quaternion]
        config.instruct.w_cmd = [0, 0, 0, 0];      % [time, X/Y/Z body rates] [rad/s]
        config.instruct.ctrl_enable = [0, 1];   % [time, enable]
        config.instruct.gyro_enable = [0, 1];   % [time, enable]
        config.instruct.star_enable = [0, 1];   % [time, enable]
        config.instruct.dist_enable = [0, 1];   % [time, enable]
        config.instruct.thrust_enable = [0, 1]; % [time, enable]
        config.instruct.desat_enable = [0, 1];  % [time, enable]

    case 2 %Settle to vertical orientation, then 180 rotate about X axis and back
        config.instruct.runTime = 60; % Simulation run time [seconds]
        config.instruct.q_cmd = [ 0, 1, 0, 0, 0;... % [time, scalar-first quaternion]
                                30, 0, 1, 0, 0;...
                                45, 1, 0, 0, 0]; 
        config.instruct.w_cmd = [0, 0, 0, 0];      % [time, X/Y/Z body rates] [rad/s]
        config.instruct.ctrl_enable = [0, 1];   % [time, enable]
        config.instruct.gyro_enable = [0, 1];   % [time, enable]
        config.instruct.star_enable = [0, 1];   % [time, enable]
        config.instruct.dist_enable = [0, 1];   % [time, enable]
        config.instruct.thrust_enable = [0, 1]; % [time, enable]
        config.instruct.desat_enable = [0, 1];  % [time, enable]

    case 3 %Settle to vertical orientation, then 180 rotate about X axis and back
        config.instruct.runTime = 60; % Simulation run time [seconds]
        config.instruct.q_cmd = [ 0, 1, 0, 0, 0;... % [time, scalar-first quaternion]
                                30, 0, 0, 1, 0;...
                                45, 1, 0, 0, 0]; 
        config.instruct.w_cmd = [0, 0, 0, 0];      % [time, X/Y/Z body rates] [rad/s]
        config.instruct.ctrl_enable = [0, 1];   % [time, enable]
        config.instruct.gyro_enable = [0, 1];   % [time, enable]
        config.instruct.star_enable = [0, 1];   % [time, enable]
        config.instruct.dist_enable = [0, 1];   % [time, enable]
        config.instruct.thrust_enable = [0, 1]; % [time, enable]
        config.instruct.desat_enable = [0, 1];  % [time, enable]

    case 4 %Settle to vertical orientation, then 180 rotate about X axis and back
        config.instruct.runTime = 60; % Simulation run time [seconds]
        config.instruct.q_cmd = [ 0, 1, 0, 0, 0;... % [time, scalar-first quaternion]
                                30, 0, 0, 0, 1;...
                                45, 1, 0, 0, 0]; 
        config.instruct.w_cmd = [0, 0, 0, 0];      % [time, X/Y/Z body rates] [rad/s]
        config.instruct.ctrl_enable = [0, 1];   % [time, enable]
        config.instruct.gyro_enable = [0, 1];   % [time, enable]
        config.instruct.star_enable = [0, 1];   % [time, enable]
        config.instruct.dist_enable = [0, 1];   % [time, enable]
        config.instruct.thrust_enable = [0, 1]; % [time, enable]
        config.instruct.desat_enable = [0, 1];  % [time, enable]
    case 5
        config.instruct.runTime = 60; % Simulation run time [seconds]
        config.instruct.q_cmd = [ 0, 1, 0, 0, 0];... % [time, scalar-first quaternion]
        config.instruct.w_cmd = [0, 0, 0, 0];      % [time, X/Y/Z body rates] [rad/s]
        config.instruct.ctrl_enable = [0, 1];   % [time, enable]
        config.instruct.gyro_enable = [0, 1];   % [time, enable]
        config.instruct.star_enable = [0, 1];   % [time, enable]
        config.instruct.dist_enable = [0, 1];   % [time, enable]
        config.instruct.thrust_enable = [0, 1]; % [time, enable]
        config.instruct.desat_enable = [0, 1];  % [time, enable]


    otherwise
        error("Test conditions for input test ID: " + testID + " does not exist.");
end

end