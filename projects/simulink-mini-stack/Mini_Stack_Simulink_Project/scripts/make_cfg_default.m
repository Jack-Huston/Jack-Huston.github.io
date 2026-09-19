function cfg = make_cfg_default()
% Configuration structure for simulation parameters
cfg.sim = struct();
cfg.sim.Ts_base = 0.01; % Base sample time (s)
cfg.sim.Ts_gyro = 0.01; % Gyroscope sample time (s)
cfg.sim.Ts_star = 0.2;   % Star tracker sample time (s)
cfg.sim.t_end   = 120;   % Simulation end time (s)
cfg.sim.seed    = 1;     % Random seed for reproducibility
cfg.sim.mc_run_id = 0;   % Monte Carlo run identifier
cfg.sim.scenario_id = "detumble"; % Scenario identifier

% Configuration structure for enabling/disabling features
cfg.en = struct();
cfg.en.controller    = true;  % Enable controller
cfg.en.estimator     = true;  % Enable estimator
cfg.en.gyro          = true;  % Enable gyroscope
cfg.en.star_tracker  = true;  % Enable star tracker
cfg.en.disturbances  = true;  % Enable disturbances
cfg.en.friction      = false; % Enable friction
cfg.en.thrusters     = false; % Enable thrusters
cfg.en.wheel_speed_limit = true; % Enable wheel speed limit
cfg.en.nis_gating    = true;  % Enable NIS gating
cfg.en.desat_mode    = false; % Enable desaturation mode

% Configuration structure for spacecraft inertia properties
cfg.sc = struct();
cfg.sc.J_true = diag([0.02,0.02,0.01]); % True inertia matrix (kg*m^2)
cfg.sc.J_est  = cfg.sc.J_true;          % Estimated inertia matrix

% Initial conditions for the simulation
cfg.ic = struct();
cfg.ic.q0 = [1;0;0;0];                  % Initial quaternion (unitless)
cfg.ic.w0 = deg2rad([10;15;5]);         % Initial angular velocity (rad/s)
cfg.ic.Omega_wheel0 = zeros(3,1);       % Initial wheel angular velocity (rad/s)

cfg.ic.q_hat0 = cfg.ic.q0;               % Initial estimated quaternion
cfg.ic.b_hat0 = zeros(3,1);              % Initial estimated bias (rad/s)
cfg.ic.P0_diag = [ (deg2rad(5))^2*ones(3,1); (deg2rad(0.5))^2*ones(3,1) ]; % Initial covariance (rad^2)

cfg.ic.pos0 = [0; 6878137; 0]; % Initial spacecraft position (m)
cfg.ic.vel0 = [-7612.608; 0; 0]; % Initial spacecraft velocity (m/s)

% Configuration structure for reaction wheel properties
cfg.rw = struct();
cfg.rw.tau_max = 0.01;                   % Maximum torque (N*m)
cfg.rw.J_wheel = 2e-4*ones(3,1);        % Wheel inertia (kg*m^2)
cfg.rw.Omega_max = 6000*(2*pi/60);      % Maximum wheel speed (rad/s)
cfg.rw.tau_slew_max = inf;               % Maximum slew rate (N*m/s)

cfg.rw.fric_visc = 5e-4 * ones(3,1);           % Viscous friction (N*m*s)
cfg.rw.fric_coul = 1e-5 * ones(3,1);           % Coulomb friction (N*m)
cfg.rw.fric_deadband = 0;                 % Deadband for friction (N*m)

% Configuration structure for torque_rods properties
cfg.thr = struct();
cfg.thr.F_max = 0.05; % Max thrust per thruster (N)
cfg.thr.F_min = 0.00; % Min thrust per thruster (N)
cfg.thr.min_pulse = 0.02; % Minimium on-time (s)
cfg.thr.unit_torque = [ 0.00, +0.10, +0.05;... % Thruster torques for 1 N forcing aligned by thruster index
                       -0.10,  0.00, -0.05;...
                       -0.10,  0.00, +0.05;...
                        0.00, -0.10, -0.05;...
                        0.00, -0.10, +0.05;...
                       +0.10,  0.00, -0.05;...
                       +0.10,  0.00, +0.05;...
                        0.00, +0.10, -0.05];

% Configuration structure for environmental disturbances
cfg.env = struct();
cfg.env.tau_const = [1e-5;-2e-5;1e-5];   % Constant disturbance torque (N*m)
cfg.env.tau_sine_amp = zeros(3,1);       % Sine wave disturbance amplitude (N*m)
cfg.env.tau_sine_freq = 0.05;            % Sine wave frequency (Hz)

% Configuration structure for sensor properties
cfg.sens = struct();
cfg.sens.gyro.sigma = deg2rad(0.02);     % Gyro noise standard deviation (rad)
cfg.sens.gyro.bias_rw = deg2rad(0.0002); % Gyro bias random walk (rad/s)
cfg.sens.gyro.bias0 = zeros(3,1);        % Initial gyro bias (rad/s)

cfg.sens.star.sigma = deg2rad(0.01);     % Star tracker noise standard deviation (rad)
cfg.sens.star.dropout_prob = 0.002;      % Dropout probability (unitless)
cfg.sens.star.dropout_duration = 2;      % Dropout duration (s)

% Configuration structure for estimator properties
cfg.est = struct();
cfg.est.star_sigma = cfg.sens.star.sigma; % Star tracker noise (rad)
cfg.est.gyro_sigma = cfg.sens.gyro.sigma; % Gyro noise (rad)
cfg.est.gyro_bias_rw = cfg.sens.gyro.bias_rw; % Gyro bias random walk (rad/s)
cfg.est.nis_gate = 7.815;                 % NIS gating threshold (chi-square, unitless)

% Configuration structure for controller properties
cfg.ctrl = struct();
cfg.t_settle = 4; % Approximate 2% settling time (sec)
cfg.zeta = 1;   % System damping ratio (unitless)
cfg.ctrl.Kd = cfg.sc.J_est * (8 / cfg.t_settle);                % Derivative gain (N*m*s/rad)
cfg.ctrl.Kp = cfg.sc.J_est * (4 / (cfg.zeta * cfg.t_settle))^2; % Proportional gain (N*m/rad)
cfg.ctrl.tr_enable_limit = 0.8;  %Wheel speed percentage of maximum before enabling torque rods
cfg.ctrl.tr_disable_limit = 0.4; %Wheel speed percentage of maximum before disabling torque rods

% Configuration structure for command properties
cfg.cmd = struct();
cfg.cmd.q_hold = [1;0;0;0];               % Hold quaternion (unitless)

% Metadata for the configuration
cfg.meta = struct();
cfg.meta.timestamp = string(datetime("now")); % Timestamp of configuration creation
cfg.meta.version = "A";                      % Version identifier

end

% config.sim.seed 
% config.meta.mc_id
% config.sc.J_est
% initial quaternion
% initial angular velocity
% initial RW angular velocity
% initial estimated quaternion
% initial estimated bias
% initial estimator covariance
% initial spacecraft position
% initial spacecraft velocity
% environmental disturbances torque
%config.sens.gyro.bias0
%Kd and Kp calculations