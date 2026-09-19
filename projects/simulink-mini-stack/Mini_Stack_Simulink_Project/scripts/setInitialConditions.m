function [config] = setInitialConditions(config, testID, addNoise, randomSeed, mcIteration)
%SETINITIALCONDITIONS Function defines the initial conditions applied to
%the simulation for use with both single run simulations and for easy
%implementation into Monte Carlo simulations
%   INPUTS::
%       config - Configuration data structure set by getSystemParameters()
%       testID - Test number associated with desired model simulation
%       addNoise - Boolean to control if Gaussian noise is added to initial conditions
%       randomSeed - Base seed number, used to set new random seed for consistent data generation
%       mcIteration - Monte Carlo Run Iteration, used to set new random seed for consistent data generation
%   OUTPUTS::
%       config - Updated configuration data structure with initial conditions added

%Monte Carlo iteration number is an optional input
if(nargin < 5); mcIteration = 1; end

%% Set Gaussian Noise Seed
noiseSeed = randomSeed + mcIteration * 10000; %Create new semi-variable seed
rng(noiseSeed); %Set seed to get reproducable noise for simulation

%% Set Initial Conditions Based on Test ID
switch(testID)
    case {1, 2, 3, 4}
        config.sim.seed = noiseSeed; % Set noise seed for simulink noise generators
        if(nargin < 5); config.meta.mc_id = -1; else; config.meta.mc_id = mcIteration; end % Save Monte Carlo Iteration ID Number
        
        % Set estimated spacecraft inertia matrix
        config.sc.J_est = config.sc.J_true;
        
        % Set initial physical conditions
        config.ic.q_0 = [1;0;0;0];               % This initial condition helps with animation viewing consistency
        config.ic.w_0 = deg2rad([25;-45;15]);    % Set initial body rate [rad/s]
        config.ic.rw_w_0 = [0; 0; 0];            % Set reaction wheel initial rotation rate [rad/s]
        config.ic.x_0 = [0; 6878137; 0];         % Initial spacecraft position (m)
        config.ic.v_0 = [-7612.608; 0; 0];       % Initial spacecraft velocity (m/s)
        
        % Set estimator initial conditions
        config.est.q_0 = config.ic.q_0; % Set initial quaternion estimate to actual quaternion value
        config.est.bias_0 = zeros(3,1); % Set gyroscope initial random walk bias
        config.est.P_0 = diag([(deg2rad(20))^2*ones(1, 3), (deg2rad(5))^2*ones(1,3)]); % Set MEKF estimator initial assumed covariance matrix

        % Set controller initial parameters based on estimated inertial matrix (pre-error)
        config.ctrl.Kd = config.sc.J_est * (8 / config.ctrl.t_settle);                          % Derivative Gain [N*m*s/rad]
        config.ctrl.Kp = config.sc.J_est * (4 / (config.ctrl.zeta * config.ctrl.t_settle))^2;   % Proportional Gain [N*m/rad]
        
        % Set Initial Disturbances
        config.env.tau_const = [1e-5;-2e-5;1e-5];   % Constant disturbance torque (N*m)

    case 5
        config.sim.seed = noiseSeed; % Set noise seed for simulink noise generators
        if(nargin < 5); config.meta.mc_id = -1; else; config.meta.mc_id = mcIteration; end % Save Monte Carlo Iteration ID Number
        
        % Set estimated spacecraft inertia matrix
        config.sc.J_est = config.sc.J_true;
        
        % Set initial physical conditions
        config.ic.q_0 = [1;0;0;0];               % This initial condition helps with animation viewing consistency
        config.ic.w_0 = deg2rad([0;0;0]);    % Set initial body rate [rad/s]
        config.ic.rw_w_0 = [0; 0; 0];            % Set reaction wheel initial rotation rate [rad/s]
        config.ic.x_0 = [0; 6878137; 0];         % Initial spacecraft position (m)
        config.ic.v_0 = [-7612.608; 0; 0];       % Initial spacecraft velocity (m/s)
        
        % Set estimator initial conditions
        config.est.q_0 = config.ic.q_0; % Set initial quaternion estimate to actual quaternion value
        config.est.bias_0 = zeros(3,1); % Set gyroscope initial random walk bias
        config.est.P_0 = diag([(deg2rad(20))^2*ones(1, 3), (deg2rad(5))^2*ones(1,3)]); % Set MEKF estimator initial assumed covariance matrix

        % Set controller initial parameters based on estimated inertial matrix (pre-error)
        config.ctrl.Kd = config.sc.J_est * (8 / config.ctrl.t_settle);                          % Derivative Gain [N*m*s/rad]
        config.ctrl.Kp = config.sc.J_est * (4 / (config.ctrl.zeta * config.ctrl.t_settle))^2;   % Proportional Gain [N*m/rad]
        
        % Set Initial Disturbances
        config.env.tau_const = [0;0;0];   % Constant disturbance torque (N*m)

    otherwise
        error("Test conditions for input test ID: " + testID + " does not exist.");
end

%% Add Noise If Defined
if(~addNoise); return; end %Return configuration if no noise is required

% Add noise to estimated spacecraft inertia matrix
config.sc.J_est = config.sc.J_est + config.vari.J_est * diag(randn(3,1)); %Add noise to estimated inertial matrix (Keep diagonal)

% Add noise to initial physical conditions
config.ic.q_0 = add_random_attitude_error(config.ic.q_0, config.vari.q_error0);   % Add noise to initial quaternion position
config.ic.w_0 = config.ic.w_0 + config.vari.w_0 * randn(3, 1);                     % Add noise to initial angular body rate
config.ic.rw_w_0 = config.ic.rw_w_0 + config.vari.rw_w0 * randn(3, 1);             % Add noise to initial reaction wheel angular rate

% Add noise to constant torque disturbance
config.env.tau_const = config.env.tau_const + config.vari.dist * randn(3, 1); % Add noise to torque disturbance

% Add noise to estimator initial conditions
config.est.q_0 = add_random_attitude_error(config.est.q_0, config.vari.q_est_error_0);    % Add noise to estimator initial quaternion position guess
config.est.bias_0 = config.est.bias_0 + config.vari.gyro_bias0 * randn(3, 1);           % Add noise to initial estimate of gyroscope initial bias
config.est.P_0 = config.est.P_0 + diag(config.vari.P0_est .* randn(size(config.vari.P0_est)));         % Add noise to estimator initial covariance matrix guess

% Add noise to initial disturbances
config.env.tau_const = [1e-5;-2e-5;1e-5];   % Constant disturbance torque (N*m)


end

function q_out = add_random_attitude_error(q_nom, ang_in)
%ADD_RANDOM_ATTITUDE_ERROR Add random 3D attitude error to a quaternion
%   INPUTS::
%       q_nom 4x1 Scalar first unit quaternion
%       ang_in Scalar Radians

q_nom = reshape(q_nom, [4 1]); % Force appropriate format
q_nom = q_nom / max(norm(q_nom), 1e-12); % Ensure unitary

%Random unit axis
u = randn(3,1);
u = u / max(norm(u), 1e-12);

%Angle selection
theta = abs(ang_in * randn(1,1));

%Delta quaternion scalar first
dq = [cos(0.5*theta); u*sin(0.5*theta)];
dq = dq / max(norm(dq), 1e-12);

%Apply perturbation
q_out = quatmultiply_sf(q_nom, dq);
q_out = q_out / max(norm(q_out), 1e-12);

end

function q = quatmultiply_sf(a, b)
w1 = a(1); x1 = a(2); y1 = a(3); z1 = a(4);
w2 = b(1); x2 = b(2); y2 = b(3); z2 = b(4);
q = [ w1*w2 - x1*x2 - y1*y2 - z1*z2;
      w1*x2 + x1*w2 + y1*z2 - z1*y2;
      w1*y2 - x1*z2 + y1*w2 + z1*x2;
      w1*z2 + x1*y2 - y1*x2 + z1*w2 ];
end
