function data = runModel(config, model, displayAnimation)
%RUNMODEL Function takes in the appropriate data files needed to run the
%associated simulink model, collects output data and pre-processes to save
%only data of iterest and returns to main loop
%   INPUTS::
%       config - Simulation configuration file with I.C.s defined
%       model - Simulink file model name
%       displayAnimation - Boolean for if animation window should play (slower)
%   OUTPUTS::
%       data - Simulink pre-processed model output data


% Enable / Disable Animation Windows
spacecraftAnimBlock = model + "/Animation_Spacecraft";
spacecraftAnimConfig = model + "/Animation_Configuration";

if(displayAnimation)
    set_param(spacecraftAnimBlock, 'commented', 'off');
    set_param(spacecraftAnimConfig, 'commented', 'off');
else
    set_param(spacecraftAnimBlock, 'commented', 'on');
    set_param(spacecraftAnimConfig, 'commented', 'on');
end

% Run Model
paramstruct.StopTime = string(config.instruct.runTime);
raw_data = sim(model, paramstruct);
metrics = raw_data.logsout{1}.Values;

% Copy over simulation metadata
data.mc_run = config.meta.mc_id;
data.configData = config;

%Copy over data to output variable
data.time           = raw_data.tout(:);

data.q_cmd          = metrics.q_cmd.Data;
data.w_cmd          = metrics.w_cmd.Data;
data.ctrl_enable    = metrics.ctrl_enable.Data;
data.gyro_enable    = metrics.gyro_enable.Data;
data.star_enable    = metrics.star_enable.Data;
data.dist_enable    = metrics.dist_enable.Data;
data.thrust_enable  = metrics.thrust_enable.Data;
data.desat_enable   = metrics.desat_enable.Data;

data.q_true         = metrics.q_true.Data;
data.w_true         = metrics.w_true.Data;
data.q_hat          = metrics.q_hat.Data;
data.w_hat          = metrics.w_hat.Data;

data.dropout_active = metrics.dropout_active.Data;
data.star_valid     = metrics.star_valid.Data;

data.w_gyro         = metrics.w_gyro.Data;
data.q_star         = metrics.q_star.Data;

data.b_hat          = metrics.b_hat.Data;
data.P_diag         = metrics.P_diag.Data;
data.innov          = metrics.innov.Data;
data.nis            = metrics.nis.Data;

data.tau_applied    = metrics.tau_applied.Data;
data.tau_fric       = metrics.tau_fric.Data;

data.RW_speed       = metrics.RW_speed.Data;
data.RW_sat_flag    = metrics.RW_sat_flag.Data;

end