function loadBusTypes() 
% LOADBUSTYPES initializes a set of bus objects in the MATLAB base workspace 

% Bus object: commandBus 
clear elems;
elems(1) = Simulink.BusElement;
elems(1).Name = 'q_cmd';
elems(1).Dimensions = [4 1];
elems(1).DimensionsMode = 'Fixed';
elems(1).DataType = 'double';
elems(1).Complexity = 'real';
elems(1).Min = [];
elems(1).Max = [];
elems(1).DocUnits = '';
elems(1).Description = '';

elems(2) = Simulink.BusElement;
elems(2).Name = 'w_cmd';
elems(2).Dimensions = [3 1];
elems(2).DimensionsMode = 'Fixed';
elems(2).DataType = 'double';
elems(2).Complexity = 'real';
elems(2).Min = [];
elems(2).Max = [];
elems(2).DocUnits = '';
elems(2).Description = '';

elems(3) = Simulink.BusElement;
elems(3).Name = 'ctrl_enable';
elems(3).Dimensions = 1;
elems(3).DimensionsMode = 'Fixed';
elems(3).DataType = 'double';
elems(3).Complexity = 'real';
elems(3).Min = [];
elems(3).Max = [];
elems(3).DocUnits = '';
elems(3).Description = '';

elems(4) = Simulink.BusElement;
elems(4).Name = 'gyro_enable';
elems(4).Dimensions = 1;
elems(4).DimensionsMode = 'Fixed';
elems(4).DataType = 'double';
elems(4).Complexity = 'real';
elems(4).Min = [];
elems(4).Max = [];
elems(4).DocUnits = '';
elems(4).Description = '';

elems(5) = Simulink.BusElement;
elems(5).Name = 'star_enable';
elems(5).Dimensions = 1;
elems(5).DimensionsMode = 'Fixed';
elems(5).DataType = 'double';
elems(5).Complexity = 'real';
elems(5).Min = [];
elems(5).Max = [];
elems(5).DocUnits = '';
elems(5).Description = '';

elems(6) = Simulink.BusElement;
elems(6).Name = 'dist_enable';
elems(6).Dimensions = 1;
elems(6).DimensionsMode = 'Fixed';
elems(6).DataType = 'double';
elems(6).Complexity = 'real';
elems(6).Min = [];
elems(6).Max = [];
elems(6).DocUnits = '';
elems(6).Description = '';

elems(7) = Simulink.BusElement;
elems(7).Name = 'thrust_enable';
elems(7).Dimensions = 1;
elems(7).DimensionsMode = 'Fixed';
elems(7).DataType = 'double';
elems(7).Complexity = 'real';
elems(7).Min = [];
elems(7).Max = [];
elems(7).DocUnits = '';
elems(7).Description = '';

elems(8) = Simulink.BusElement;
elems(8).Name = 'desat_enable';
elems(8).Dimensions = 1;
elems(8).DimensionsMode = 'Fixed';
elems(8).DataType = 'double';
elems(8).Complexity = 'real';
elems(8).Min = [];
elems(8).Max = [];
elems(8).DocUnits = '';
elems(8).Description = '';

commandBus = Simulink.Bus;
commandBus.HeaderFile = '';
commandBus.Description = '';
commandBus.DataScope = 'Auto';
commandBus.Alignment = -1;
commandBus.PreserveElementDimensions = 0;
commandBus.Elements = elems;
clear elems;
assignin('base','commandBus', commandBus);

% Bus object: estimatedStateBus 
clear elems;
elems(1) = Simulink.BusElement;
elems(1).Name = 'q_hat';
elems(1).Dimensions = [4 1];
elems(1).DimensionsMode = 'Fixed';
elems(1).DataType = 'double';
elems(1).Complexity = 'real';
elems(1).Min = [];
elems(1).Max = [];
elems(1).DocUnits = '';
elems(1).Description = '';

elems(2) = Simulink.BusElement;
elems(2).Name = 'w_hat';
elems(2).Dimensions = [3 1];
elems(2).DimensionsMode = 'Fixed';
elems(2).DataType = 'double';
elems(2).Complexity = 'real';
elems(2).Min = [];
elems(2).Max = [];
elems(2).DocUnits = '';
elems(2).Description = '';

estimatedStateBus = Simulink.Bus;
estimatedStateBus.HeaderFile = '';
estimatedStateBus.Description = '';
estimatedStateBus.DataScope = 'Auto';
estimatedStateBus.Alignment = -1;
estimatedStateBus.PreserveElementDimensions = 0;
estimatedStateBus.Elements = elems;
clear elems;
assignin('base','estimatedStateBus', estimatedStateBus);

% Bus object: measurementBus 
clear elems;
elems(1) = Simulink.BusElement;
elems(1).Name = 'q_star';
elems(1).Dimensions = [4 1];
elems(1).DimensionsMode = 'Fixed';
elems(1).DataType = 'double';
elems(1).Complexity = 'real';
elems(1).Min = [];
elems(1).Max = [];
elems(1).DocUnits = '';
elems(1).Description = '';

elems(2) = Simulink.BusElement;
elems(2).Name = 'w_gyro';
elems(2).Dimensions = [3 1];
elems(2).DimensionsMode = 'Fixed';
elems(2).DataType = 'double';
elems(2).Complexity = 'real';
elems(2).Min = [];
elems(2).Max = [];
elems(2).DocUnits = '';
elems(2).Description = '';

elems(3) = Simulink.BusElement;
elems(3).Name = 'star_valid';
elems(3).Dimensions = 1;
elems(3).DimensionsMode = 'Fixed';
elems(3).DataType = 'double';
elems(3).Complexity = 'real';
elems(3).Min = [];
elems(3).Max = [];
elems(3).DocUnits = '';
elems(3).Description = '';

elems(4) = Simulink.BusElement;
elems(4).Name = 'dropout_active';
elems(4).Dimensions = 1;
elems(4).DimensionsMode = 'Fixed';
elems(4).DataType = 'double';
elems(4).Complexity = 'real';
elems(4).Min = [];
elems(4).Max = [];
elems(4).DocUnits = '';
elems(4).Description = '';

measurementBus = Simulink.Bus;
measurementBus.HeaderFile = '';
measurementBus.Description = '';
measurementBus.DataScope = 'Auto';
measurementBus.Alignment = -1;
measurementBus.PreserveElementDimensions = 0;
measurementBus.Elements = elems;
clear elems;
assignin('base','measurementBus', measurementBus);

% Bus object: mekf_diagnostics 
clear elems;
elems(1) = Simulink.BusElement;
elems(1).Name = 'b_hat';
elems(1).Dimensions = [3 1];
elems(1).DimensionsMode = 'Fixed';
elems(1).DataType = 'double';
elems(1).Complexity = 'real';
elems(1).Min = [];
elems(1).Max = [];
elems(1).DocUnits = '';
elems(1).Description = '';

elems(2) = Simulink.BusElement;
elems(2).Name = 'P_diag';
elems(2).Dimensions = [6 1];
elems(2).DimensionsMode = 'Fixed';
elems(2).DataType = 'double';
elems(2).Complexity = 'real';
elems(2).Min = [];
elems(2).Max = [];
elems(2).DocUnits = '';
elems(2).Description = '';

elems(3) = Simulink.BusElement;
elems(3).Name = 'innov';
elems(3).Dimensions = [3 1];
elems(3).DimensionsMode = 'Fixed';
elems(3).DataType = 'double';
elems(3).Complexity = 'real';
elems(3).Min = [];
elems(3).Max = [];
elems(3).DocUnits = '';
elems(3).Description = '';

elems(4) = Simulink.BusElement;
elems(4).Name = 'nis';
elems(4).Dimensions = 1;
elems(4).DimensionsMode = 'Fixed';
elems(4).DataType = 'double';
elems(4).Complexity = 'real';
elems(4).Min = [];
elems(4).Max = [];
elems(4).DocUnits = '';
elems(4).Description = '';

mekf_diagnostics = Simulink.Bus;
mekf_diagnostics.HeaderFile = '';
mekf_diagnostics.Description = '';
mekf_diagnostics.DataScope = 'Auto';
mekf_diagnostics.Alignment = -1;
mekf_diagnostics.PreserveElementDimensions = 0;
mekf_diagnostics.Elements = elems;
clear elems;
assignin('base','mekf_diagnostics', mekf_diagnostics);

% Bus object: metricLog 
clear elems;
metricLog = Simulink.Bus;
metricLog.HeaderFile = '';
metricLog.Description = '';
metricLog.DataScope = 'Auto';
metricLog.Alignment = -1;
metricLog.PreserveElementDimensions = 0;
assignin('base','metricLog', metricLog);

% Bus object: reactionWheelBus 
clear elems;
elems(1) = Simulink.BusElement;
elems(1).Name = 'tau_applied';
elems(1).Dimensions = [3 1];
elems(1).DimensionsMode = 'Fixed';
elems(1).DataType = 'double';
elems(1).Complexity = 'real';
elems(1).Min = [];
elems(1).Max = [];
elems(1).DocUnits = '';
elems(1).Description = '';

elems(2) = Simulink.BusElement;
elems(2).Name = 'tau_fric';
elems(2).Dimensions = [3 1];
elems(2).DimensionsMode = 'Fixed';
elems(2).DataType = 'double';
elems(2).Complexity = 'real';
elems(2).Min = [];
elems(2).Max = [];
elems(2).DocUnits = '';
elems(2).Description = '';

elems(3) = Simulink.BusElement;
elems(3).Name = 'RW_speed';
elems(3).Dimensions = [3 1];
elems(3).DimensionsMode = 'Fixed';
elems(3).DataType = 'double';
elems(3).Complexity = 'real';
elems(3).Min = [];
elems(3).Max = [];
elems(3).DocUnits = '';
elems(3).Description = '';

elems(4) = Simulink.BusElement;
elems(4).Name = 'RW_sat_flag';
elems(4).Dimensions = [3 1];
elems(4).DimensionsMode = 'Fixed';
elems(4).DataType = 'double';
elems(4).Complexity = 'real';
elems(4).Min = [];
elems(4).Max = [];
elems(4).DocUnits = '';
elems(4).Description = '';

reactionWheelBus = Simulink.Bus;
reactionWheelBus.HeaderFile = '';
reactionWheelBus.Description = '';
reactionWheelBus.DataScope = 'Auto';
reactionWheelBus.Alignment = -1;
reactionWheelBus.PreserveElementDimensions = 0;
reactionWheelBus.Elements = elems;
clear elems;
assignin('base','reactionWheelBus', reactionWheelBus);

% Bus object: sc_stateBus 
clear elems;
elems(1) = Simulink.BusElement;
elems(1).Name = 'q_true';
elems(1).Dimensions = [4 1];
elems(1).DimensionsMode = 'Fixed';
elems(1).DataType = 'double';
elems(1).Complexity = 'real';
elems(1).Min = [];
elems(1).Max = [];
elems(1).DocUnits = '';
elems(1).Description = '';

elems(2) = Simulink.BusElement;
elems(2).Name = 'w_true';
elems(2).Dimensions = [3 1];
elems(2).DimensionsMode = 'Fixed';
elems(2).DataType = 'double';
elems(2).Complexity = 'real';
elems(2).Min = [];
elems(2).Max = [];
elems(2).DocUnits = '';
elems(2).Description = '';

sc_stateBus = Simulink.Bus;
sc_stateBus.HeaderFile = '';
sc_stateBus.Description = '';
sc_stateBus.DataScope = 'Auto';
sc_stateBus.Alignment = -1;
sc_stateBus.PreserveElementDimensions = 0;
sc_stateBus.Elements = elems;
clear elems;
assignin('base','sc_stateBus', sc_stateBus);

% Bus object: metrics 
clear elems;
elems(1) = Simulink.BusElement;
elems(1).Name = 'q_cmd';
elems(1).Dimensions = [4 1];
elems(1).DimensionsMode = 'Fixed';
elems(1).DataType = 'double';
elems(1).Complexity = 'real';
elems(1).Min = [];
elems(1).Max = [];
elems(1).DocUnits = '';
elems(1).Description = '';

elems(2) = Simulink.BusElement;
elems(2).Name = 'w_cmd';
elems(2).Dimensions = [3 1];
elems(2).DimensionsMode = 'Fixed';
elems(2).DataType = 'double';
elems(2).Complexity = 'real';
elems(2).Min = [];
elems(2).Max = [];
elems(2).DocUnits = '';
elems(2).Description = '';

elems(3) = Simulink.BusElement;
elems(3).Name = 'ctrl_enable';
elems(3).Dimensions = 1;
elems(3).DimensionsMode = 'Fixed';
elems(3).DataType = 'double';
elems(3).Complexity = 'real';
elems(3).Min = [];
elems(3).Max = [];
elems(3).DocUnits = '';
elems(3).Description = '';

elems(4) = Simulink.BusElement;
elems(4).Name = 'gyro_enable';
elems(4).Dimensions = 1;
elems(4).DimensionsMode = 'Fixed';
elems(4).DataType = 'double';
elems(4).Complexity = 'real';
elems(4).Min = [];
elems(4).Max = [];
elems(4).DocUnits = '';
elems(4).Description = '';

elems(5) = Simulink.BusElement;
elems(5).Name = 'star_enable';
elems(5).Dimensions = 1;
elems(5).DimensionsMode = 'Fixed';
elems(5).DataType = 'double';
elems(5).Complexity = 'real';
elems(5).Min = [];
elems(5).Max = [];
elems(5).DocUnits = '';
elems(5).Description = '';

elems(6) = Simulink.BusElement;
elems(6).Name = 'dist_enable';
elems(6).Dimensions = 1;
elems(6).DimensionsMode = 'Fixed';
elems(6).DataType = 'double';
elems(6).Complexity = 'real';
elems(6).Min = [];
elems(6).Max = [];
elems(6).DocUnits = '';
elems(6).Description = '';

elems(7) = Simulink.BusElement;
elems(7).Name = 'thrust_enable';
elems(7).Dimensions = 1;
elems(7).DimensionsMode = 'Fixed';
elems(7).DataType = 'double';
elems(7).Complexity = 'real';
elems(7).Min = [];
elems(7).Max = [];
elems(7).DocUnits = '';
elems(7).Description = '';

elems(8) = Simulink.BusElement;
elems(8).Name = 'desat_enable';
elems(8).Dimensions = 1;
elems(8).DimensionsMode = 'Fixed';
elems(8).DataType = 'double';
elems(8).Complexity = 'real';
elems(8).Min = [];
elems(8).Max = [];
elems(8).DocUnits = '';
elems(8).Description = '';

elems(9) = Simulink.BusElement;
elems(9).Name = 'q_true';
elems(9).Dimensions = [4 1];
elems(9).DimensionsMode = 'Fixed';
elems(9).DataType = 'double';
elems(9).Complexity = 'real';
elems(9).Min = [];
elems(9).Max = [];
elems(9).DocUnits = '';
elems(9).Description = '';

elems(10) = Simulink.BusElement;
elems(10).Name = 'w_true';
elems(10).Dimensions = [3 1];
elems(10).DimensionsMode = 'Fixed';
elems(10).DataType = 'double';
elems(10).Complexity = 'real';
elems(10).Min = [];
elems(10).Max = [];
elems(10).DocUnits = '';
elems(10).Description = '';

elems(11) = Simulink.BusElement;
elems(11).Name = 'q_hat';
elems(11).Dimensions = [4 1];
elems(11).DimensionsMode = 'Fixed';
elems(11).DataType = 'double';
elems(11).Complexity = 'real';
elems(11).Min = [];
elems(11).Max = [];
elems(11).DocUnits = '';
elems(11).Description = '';

elems(12) = Simulink.BusElement;
elems(12).Name = 'w_hat';
elems(12).Dimensions = [3 1];
elems(12).DimensionsMode = 'Fixed';
elems(12).DataType = 'double';
elems(12).Complexity = 'real';
elems(12).Min = [];
elems(12).Max = [];
elems(12).DocUnits = '';
elems(12).Description = '';

elems(13) = Simulink.BusElement;
elems(13).Name = 'dropout_active';
elems(13).Dimensions = 1;
elems(13).DimensionsMode = 'Fixed';
elems(13).DataType = 'double';
elems(13).Complexity = 'real';
elems(13).Min = [];
elems(13).Max = [];
elems(13).DocUnits = '';
elems(13).Description = '';

elems(14) = Simulink.BusElement;
elems(14).Name = 'star_valid';
elems(14).Dimensions = 1;
elems(14).DimensionsMode = 'Fixed';
elems(14).DataType = 'double';
elems(14).Complexity = 'real';
elems(14).Min = [];
elems(14).Max = [];
elems(14).DocUnits = '';
elems(14).Description = '';

elems(15) = Simulink.BusElement;
elems(15).Name = 'w_gyro';
elems(15).Dimensions = [3 1];
elems(15).DimensionsMode = 'Fixed';
elems(15).DataType = 'double';
elems(15).Complexity = 'real';
elems(15).Min = [];
elems(15).Max = [];
elems(15).DocUnits = '';
elems(15).Description = '';

elems(16) = Simulink.BusElement;
elems(16).Name = 'q_star';
elems(16).Dimensions = [4 1];
elems(16).DimensionsMode = 'Fixed';
elems(16).DataType = 'double';
elems(16).Complexity = 'real';
elems(16).Min = [];
elems(16).Max = [];
elems(16).DocUnits = '';
elems(16).Description = '';

elems(17) = Simulink.BusElement;
elems(17).Name = 'b_hat';
elems(17).Dimensions = [3 1];
elems(17).DimensionsMode = 'Fixed';
elems(17).DataType = 'double';
elems(17).Complexity = 'real';
elems(17).Min = [];
elems(17).Max = [];
elems(17).DocUnits = '';
elems(17).Description = '';

elems(18) = Simulink.BusElement;
elems(18).Name = 'P_diag';
elems(18).Dimensions = [6 1];
elems(18).DimensionsMode = 'Fixed';
elems(18).DataType = 'double';
elems(18).Complexity = 'real';
elems(18).Min = [];
elems(18).Max = [];
elems(18).DocUnits = '';
elems(18).Description = '';

elems(19) = Simulink.BusElement;
elems(19).Name = 'innov';
elems(19).Dimensions = [3 1];
elems(19).DimensionsMode = 'Fixed';
elems(19).DataType = 'double';
elems(19).Complexity = 'real';
elems(19).Min = [];
elems(19).Max = [];
elems(19).DocUnits = '';
elems(19).Description = '';

elems(20) = Simulink.BusElement;
elems(20).Name = 'nis';
elems(20).Dimensions = 1;
elems(20).DimensionsMode = 'Fixed';
elems(20).DataType = 'double';
elems(20).Complexity = 'real';
elems(20).Min = [];
elems(20).Max = [];
elems(20).DocUnits = '';
elems(20).Description = '';

elems(21) = Simulink.BusElement;
elems(21).Name = 'tau_applied';
elems(21).Dimensions = [3 1];
elems(21).DimensionsMode = 'Fixed';
elems(21).DataType = 'double';
elems(21).Complexity = 'real';
elems(21).Min = [];
elems(21).Max = [];
elems(21).DocUnits = '';
elems(21).Description = '';

elems(22) = Simulink.BusElement;
elems(22).Name = 'tau_fric';
elems(22).Dimensions = [3 1];
elems(22).DimensionsMode = 'Fixed';
elems(22).DataType = 'double';
elems(22).Complexity = 'real';
elems(22).Min = [];
elems(22).Max = [];
elems(22).DocUnits = '';
elems(22).Description = '';

elems(23) = Simulink.BusElement;
elems(23).Name = 'RW_speed';
elems(23).Dimensions = [3 1];
elems(23).DimensionsMode = 'Fixed';
elems(23).DataType = 'double';
elems(23).Complexity = 'real';
elems(23).Min = [];
elems(23).Max = [];
elems(23).DocUnits = '';
elems(23).Description = '';

elems(24) = Simulink.BusElement;
elems(24).Name = 'RW_sat_flag';
elems(24).Dimensions = [3 1];
elems(24).DimensionsMode = 'Fixed';
elems(24).DataType = 'double';
elems(24).Complexity = 'real';
elems(24).Min = [];
elems(24).Max = [];
elems(24).DocUnits = '';
elems(24).Description = '';

metrics = Simulink.Bus;
metrics.HeaderFile = '';
metrics.Description = '';
metrics.DataScope = 'Auto';
metrics.Alignment = -1;
metrics.PreserveElementDimensions = 0;
metrics.Elements = elems;
clear elems;
assignin('base','metrics', metrics);

