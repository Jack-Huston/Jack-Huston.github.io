function plotSingleRun(data, config)
%PLOTSINGLERUN Create evaluation plots for a single simulation run.

%Pull out time data
time = data.time';

%% --- Create Response Plots ---
trueQ = squeeze(data.q_true); % Squeeze singleton dimension
estQ  = squeeze(data.q_hat);  % Squeeze singleton dimension
cmdQ  = squeeze(data.q_cmd);  % Squeeze singleton dimension

figure("Color", "white");
tiles = tiledlayout('flow', 'TileSpacing', 'compact', 'Padding', 'compact');
colors = orderedcolors("gem");

%--Angular State--
nexttile;
% Plot True State Values
h(1) = plot(time, trueQ(1, :), ':', 'Color', colors(1, :)); hold on
        plot(time, trueQ(2, :), ':', 'Color', colors(2, :));
        plot(time, trueQ(3, :), ':', 'Color', colors(3, :));
        plot(time, trueQ(4, :), ':', 'Color', colors(4, :));

% Plot Estimated State Values
indexL = (size(time, 2) - size(estQ, 2)) + 1;
indexR = size(time, 2);
h(2) = plot(time(indexL:indexR), estQ(1, :), '-', 'Color', colors(1, :));
        plot(time(indexL:indexR), estQ(2, :), '-', 'Color', colors(2, :));
        plot(time(indexL:indexR), estQ(3, :), '-', 'Color', colors(3, :));
        plot(time(indexL:indexR), estQ(4, :), '-', 'Color', colors(4, :));

% Plot Commanded State Values
h(3) = plot(time, cmdQ(1, :), '--', 'Color', colors(1, :));
        plot(time, cmdQ(2, :), '--', 'Color', colors(2, :));
        plot(time, cmdQ(3, :), '--', 'Color', colors(3, :));
        plot(time, cmdQ(4, :), '--', 'Color', colors(4, :));

grid on
xlabel("Time [seconds]", 'interpreter', 'latex', 'fontSize', 18);
ylabel("Quaternion Value", 'interpreter', 'latex', 'fontSize', 18);
title("Attitude State", 'interpreter','latex', 'fontSize', 20);
ylim([-1.1, 1.1]);

legend(h, ["True Angular Position", "Estimated Angular Position", "Commanded Angular Position"]);

%--Angular Velocity--
nexttile;
% Plot True Angular Velocity Values
h(1) = plot(time, squeeze(data.w_true(1, :)), ':', 'Color', colors(1, :)); hold on
        plot(time, squeeze(data.w_true(2, :)), ':', 'Color', colors(2, :));
        plot(time, squeeze(data.w_true(3, :)), ':', 'Color', colors(3, :));

% Plot Estimated Angular Velocity Values
h(2) = plot(time(indexL:indexR), squeeze(data.w_hat(1, :)), '-', 'Color', colors(1, :));
        plot(time(indexL:indexR), squeeze(data.w_hat(2, :)), '-', 'Color', colors(2, :));
        plot(time(indexL:indexR), squeeze(data.w_hat(3, :)), '-', 'Color', colors(3, :));

% Plot Commanded Angular Velocity Values
h(3) = plot(time, squeeze(data.w_cmd(1, :)), '--', 'Color', colors(1, :));
        plot(time, squeeze(data.w_cmd(2, :)), '--', 'Color', colors(2, :));
        plot(time, squeeze(data.w_cmd(3, :)), '--', 'Color', colors(3, :));

grid on
xlabel("Time [seconds]", 'Interpreter', 'latex', 'fontSize', 18);
ylabel("Angular Velocity [rad/s]", 'Interpreter', 'latex', 'fontSize', 18);
title("Angular Velocity", 'Interpreter','latex', 'fontSize', 20);

legend(h, ["True Angular Velocity", "Estimated Angular Velocity", "Commanded Angular Velocity"]);

title(tiles, "Spacecraft Response to Commanded Input", 'Interpreter', 'latex', 'fontSize', 24);

%% --- Commanded State Error ---
% Calculate the error between the true and commanded quaternion
d = abs(dot(trueQ, cmdQ, 1));          % handle q and -q equivalence
d = min(1, max(-1, d));                % numerical safety
errorQ = rad2deg(2*acos(d));           % 0..180 deg

% Plot Commanded State Error
figure("Color", "white");
tiles = tiledlayout('flow', 'TileSpacing', 'compact', 'Padding', 'compact');
nexttile;
plot(time, errorQ, '-', 'Color', colors(1, :));
grid on
xlabel("Time [seconds]", 'Interpreter', 'latex', 'fontSize', 18);
ylabel("Quaternion Error [degrees]", 'Interpreter', 'latex', 'fontSize', 18);
title("Quaternion Error", 'Interpreter','latex', 'fontSize', 20);

% Calculate the error between the true and commanded angular velocity
errorW = rad2deg(data.w_true - data.w_cmd); % Calculate error in degrees

% Plot Commanded Angular Velocity Error
nexttile;
plot(time, errorW(1, :), '-', 'Color', colors(1, :)); hold on
plot(time, errorW(2, :), '-', 'Color', colors(2, :));
plot(time, errorW(3, :), '-', 'Color', colors(3, :));
grid on
xlabel("Time [seconds]", 'Interpreter', 'latex', 'fontSize', 18);
ylabel("Angular Velocity Error [degrees]", 'Interpreter', 'latex', 'fontSize', 18);
title("Angular Velocity Error", 'Interpreter','latex', 'fontSize', 20);

legend(["Angular Velocity Error 1", "Angular Velocity Error 2", "Angular Velocity Error 3"]);

title(tiles, "Commanded State and Angular Velocity Errors", 'Interpreter', 'latex', 'fontSize', 24);


%% --- Estimated State Error ---
gyro_sigma = config.sens.gyro.sigma; % Gyro white noise std (rad/s)

% Calculate the attitude estimation error (true vs estimated quaternion)
d = abs(dot(trueQ(:,indexL:indexR), estQ, 1));          % handle q and -q equivalence
d = min(1, max(-1, d));                                % numerical safety

% Pull covariance data (P_diag = [alpha(1:3); bias(1:3)] on MEKF time base)
Pdiag = squeeze(data.P_diag);                          % 6 x N_est
sigmaAlpha = sqrt(max(Pdiag(1:3, :), 0));              % 3 x N_est, rad
sigmaBias  = sqrt(max(Pdiag(4:6, :), 0));              % 3 x N_est, rad/s

% Calculate the angular velocity estimation error (true vs estimated)
estErrorW = rad2deg(squeeze(data.w_true(:,indexL:indexR)) - squeeze(data.w_hat)); % 3 x N_est, deg/s

% Rate error covariance approximation: Cov(w_hat - w_true) ≈ P_bias + gyro_sigma^2 * I
rateSig2Deg = rad2deg(2*sqrt(max(sigmaBias.^2 + gyro_sigma^2, 0)));              % 3 x N_est, deg/s (2-sigma)

% Compute attitude error rotvec components (small-angle) for component-wise consistency check
q_true = trueQ(:,indexL:indexR);
q_hat  = estQ;
q_true = q_true ./ max(vecnorm(q_true,2,1), 1e-12);
q_hat  = q_hat  ./ max(vecnorm(q_hat,2,1), 1e-12);
q_true_inv = [q_true(1,:); -q_true(2:4,:)];
q_e = quatmultiply_series(q_true_inv, q_hat);
q_e = q_e ./ max(vecnorm(q_e,2,1), 1e-12);
flip = (q_e(1,:) < 0);
q_e(:,flip) = -q_e(:,flip);
alpha_err = quatlog_series(q_e);                        % 3 x N_est, rad
alphaErrDeg = rad2deg(alpha_err);                       % 3 x N_est, deg
alphaSig2Deg = rad2deg(2*sigmaAlpha);                   % 3 x N_est, deg (2-sigma per component)

% Plot Estimated State Errors with statistically consistent bounds
figure("Color", "white");
tiles = tiledlayout('flow', 'TileSpacing', 'compact', 'Padding', 'compact');

%--Attitude Error Components--
nexttile;
h(1) =  plot(time(indexL:indexR), alphaErrDeg(1,:), '-', 'Color', colors(1, :)); hold on
h(2) =  plot(time(indexL:indexR), alphaErrDeg(2,:), '-', 'Color', colors(2, :));
h(3) =  plot(time(indexL:indexR), alphaErrDeg(3,:), '-', 'Color', colors(3, :));
        plot(time(indexL:indexR),  alphaSig2Deg(1,:), '--', 'Color', colors(1, :));
h(4) =  plot(time(indexL:indexR), -alphaSig2Deg(1,:), '--', 'Color', colors(1, :));
grid on
xlabel("Time [seconds]", 'Interpreter', 'latex', 'fontSize', 18);
ylabel("$\alpha$ Error [degrees]", 'Interpreter', 'latex', 'fontSize', 18);
title("Attitude Error Components with $\pm 2\sigma$ Bounds", 'Interpreter','latex', 'fontSize', 20);
legend(h, ["$\alpha_x$ error", "$\alpha_y$ error", "$\alpha_z$ error", "2-Sigma Standard Deviation"], 'Interpreter', 'latex');
ylim([-1, 1]);

%--Angular Velocity Estimation Error--
nexttile;
h(1) =  plot(time(indexL:indexR), estErrorW(1, :), '-', 'Color', colors(1, :)); hold on
h(2) =  plot(time(indexL:indexR), estErrorW(2, :), '-', 'Color', colors(2, :));
h(3) =  plot(time(indexL:indexR), estErrorW(3, :), '-', 'Color', colors(3, :));
h(4) =  plot(time(indexL:indexR),  rateSig2Deg(1,:), '--', 'Color', colors(1, :));
        plot(time(indexL:indexR), -rateSig2Deg(1,:), '--', 'Color', colors(1, :));
grid on
xlabel("Time [seconds]", 'Interpreter', 'latex', 'fontSize', 18);
ylabel("Angular Velocity Error [deg/s]", 'Interpreter', 'latex', 'fontSize', 18);
title("Estimated Angular Velocity Error with $\pm 2\sigma$ Bounds", 'Interpreter','latex', 'fontSize', 20);
legend(h, ["$\omega_x$ error", "$\omega_y$ error", "$\omega_z$ error", "2-Sigma Standard Deviation"], 'Interpreter', 'latex');

title(tiles, "Estimated State Errors", 'Interpreter', 'latex', 'fontSize', 24);
ylim([-0.4 0.4]);

%% --- NIS Consistency Check ---
nis = squeeze(data.nis);                % NIS (scalar)
nis = nis(:)';                          % force row
t_nis = time(end-numel(nis)+1:end);     % align to estimator timeline

% Optional: overlay star_valid and dropout flags (if present)
sv = squeeze(data.star_valid);          % 0/1
sv = sv(:)';                            
sv = sv(end-numel(nis)+1:end);

%Set nis where there is not a star update to NaN
nis_redact = nis(sv == 1);
t_redact = t_nis(sv == 1);

% Chi-square bounds for NIS with 3 DOF (attitude measurement is 3D)
try
    nis_lo = chi2inv(0.005, 3);
    nis_hi = chi2inv(0.995, 3);
catch
    nis_lo = 0.1148;                    % fallback
    nis_hi = 12.838;                    % fallback
end

figure;
scatter(t_redact, nis_redact, 25, colors(1, :), 'filled'); hold on
yline(nis_lo, '--', 'Color', colors(2, :));
yline(nis_hi, '--', 'Color', colors(2, :));

grid on
xlabel("Time [seconds]", 'Interpreter', 'latex', 'fontSize', 18);
ylabel("NIS", 'Interpreter', 'latex', 'fontSize', 18);
title("Estimator Consistency: Normalized Innovation Squared", 'Interpreter','latex', 'fontSize', 20);
legend(["NIS", "99\% bounds"], 'Interpreter', 'latex');


function q = quatmultiply_series(a, b)
w1=a(1,:); x1=a(2,:); y1=a(3,:); z1=a(4,:);
w2=b(1,:); x2=b(2,:); y2=b(3,:); z2=b(4,:);
q = [ w1.*w2 - x1.*x2 - y1.*y2 - z1.*z2;
      w1.*x2 + x1.*w2 + y1.*z2 - z1.*y2;
      w1.*y2 - x1.*z2 + y1.*w2 + z1.*x2;
      w1.*z2 + x1.*y2 - y1.*x2 + z1.*w2 ];
end

function r = quatlog_series(q)
q0 = max(-1, min(1, q(1,:)));
v  = q(2:4,:);
nv = vecnorm(v,2,1);
r  = zeros(3, size(q,2));
small = nv < 1e-8;
r(:,small) = 2*v(:,small);
ns = ~small;
ang = 2*atan2(nv(ns), q0(ns));
r(:,ns) = v(:,ns) .* (ang./nv(ns));
end

end