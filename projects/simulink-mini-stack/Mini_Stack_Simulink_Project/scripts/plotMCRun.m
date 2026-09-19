function plotMCRun(mc, config)
%PLOTMCRUN Create Monte Carlo summary plots that are comparable across runs.

gyro_sigma = config.sens.gyro.sigma;                          % gyro white noise std (rad/s)
colors = orderedcolors("gem");

nMC = mc.nMC;
nT  = min(arrayfun(@(r) numel(r.data.time), mc.run));         % common length across runs
time = mc.run(1).data.time(1:nT)';                            % common time vector (assumed uniform)

errCmdDeg      = nan(nMC, nT);                                % commanded tracking attitude error (deg)
errEstDeg      = nan(nMC, nT);                                % estimator attitude error (deg), on main time base
rateErrMag     = nan(nMC, nT);                                % estimator rate error magnitude (deg/s), on main time base
nis_all        = [];                                          % all NIS samples at update times

% NEW: attitude small-angle component errors (deg), on main time base
alphaErrDeg    = nan(nMC, 3, nT);                             % [run x axis x time], deg

dt_main = median(diff(time));                                 % main step (s)

for k = 1:nMC
    data = mc.run(k).data;

    t      = data.time(:)';                                   % time base for logged "truth/command"
    t      = t(1:nT);                                         % crop to common length
    q_true = squeeze(data.q_true(:,1:nT));                     % 4 x nT
    q_cmd  = squeeze(data.q_cmd(:,1:nT));                      % 4 x nT
    w_true = squeeze(data.w_true(:,1:nT));                     % 3 x nT

    q_hat  = squeeze(data.q_hat);                              % 4 x nEst (estimator log length)
    w_hat  = squeeze(data.w_hat);                              % 3 x nEst
    Pdiag  = squeeze(data.P_diag);                             % 6 x nEst
    nis    = squeeze(data.nis);                                % 1 x nEst (or nEst x 1)
    sv     = squeeze(data.star_valid);                         % 1 x nT or 1 x nEst

    % Normalize quaternions (protects dot/acos from non-unit drift)
    q_true = q_true ./ max(vecnorm(q_true,2,1), 1e-12);
    q_cmd  = q_cmd  ./ max(vecnorm(q_cmd,2,1), 1e-12);
    q_hat  = q_hat  ./ max(vecnorm(q_hat,2,1), 1e-12);

    % Command tracking attitude error (true vs commanded), 0..180 deg
    d = abs(dot(q_true, q_cmd, 1));
    d = min(1, max(-1, d));
    errCmdDeg(k,:) = rad2deg(2*acos(d));

    % Map estimator samples onto the MAIN time grid
    nEst = size(q_hat, 2);
    if nEst == nT
        idx = 1:nT;                                           % already on main grid
    else
        % Best-guess timestamp for estimator samples: assume last nEst samples align to end time
        t_est = t(end-nEst+1:end);                             % 1 x nEst (assumes same dt and "right-aligned")
        idx = round((t_est - t(1))/dt_main) + 1;               % nearest main indices
        idx = max(1, min(nT, idx));                            % clamp
    end

    % Estimator attitude error (true vs estimated), 0..180 deg (kept for scalar plot)
    d = abs(dot(q_true(:,idx), q_hat, 1));
    d = min(1, max(-1, d));
    errEstDeg(k,idx) = rad2deg(2*acos(d));

    % NEW: attitude error rotvec components using the SAME method as plotSingleRun
    q_true_est = q_true(:,idx);
    q_hat_est  = q_hat;

    q_true_est = q_true_est ./ max(vecnorm(q_true_est,2,1), 1e-12);
    q_hat_est  = q_hat_est  ./ max(vecnorm(q_hat_est,2,1), 1e-12);

    q_true_inv = [q_true_est(1,:); -q_true_est(2:4,:)];
    q_e = quatmultiply_series(q_true_inv, q_hat_est);
    q_e = q_e ./ max(vecnorm(q_e,2,1), 1e-12);
    flip = (q_e(1,:) < 0);
    q_e(:,flip) = -q_e(:,flip);

    alpha_err = quatlog_series(q_e);                           % 3 x nEst, rad
    alphaErrDeg(k,:,idx) = reshape(rad2deg(alpha_err), [1 3 nEst]);

    % Rate estimation error magnitude
    wErr = w_true(:,idx) - w_hat;                              % 3 x nEst, rad/s
    rateErrMag(k,idx) = rad2deg(vecnorm(wErr, 2, 1));          % 1 x nEst, deg/s

    % NIS samples (keep only at star updates)
    nis = nis(:)';                                             % row
    if numel(sv) == numel(nis)
        sv_nis = sv(:)';                                       % already on estimator length
    else
        sv_nis = sv(end-numel(nis)+1:end);                     % right-align if logged at main rate
        sv_nis = sv_nis(:)';
    end
    mask = (sv_nis ~= 0) & isfinite(nis);
    nis_all = [nis_all, nis(mask)];
end

% Column-wise percentiles that ignore NaNs (works on older MATLAB)
p05  = colPrctile(errCmdDeg, 5);
p50  = colPrctile(errCmdDeg, 50);
p95  = colPrctile(errCmdDeg, 95);

p05e = colPrctile(errEstDeg, 5);
p50e = colPrctile(errEstDeg, 50);
p95e = colPrctile(errEstDeg, 95);

p05r = colPrctile(rateErrMag, 5);
p50r = colPrctile(rateErrMag, 50);
p95r = colPrctile(rateErrMag, 95);

% NEW: component-wise percentiles for alpha error (deg)
p05ax = colPrctile(squeeze(alphaErrDeg(:,1,:)), 5);
p50ax = colPrctile(squeeze(alphaErrDeg(:,1,:)), 50);
p95ax = colPrctile(squeeze(alphaErrDeg(:,1,:)), 95);

p05ay = colPrctile(squeeze(alphaErrDeg(:,2,:)), 5);
p50ay = colPrctile(squeeze(alphaErrDeg(:,2,:)), 50);
p95ay = colPrctile(squeeze(alphaErrDeg(:,2,:)), 95);

p05az = colPrctile(squeeze(alphaErrDeg(:,3,:)), 5);
p50az = colPrctile(squeeze(alphaErrDeg(:,3,:)), 50);
p95az = colPrctile(squeeze(alphaErrDeg(:,3,:)), 95);

% Command tracking / estimator scalar summaries
figure("Color","white");
tiles = tiledlayout('flow', 'TileSpacing','compact', 'Padding','compact');

nexttile;
mask = isfinite(p05) & isfinite(p95);
tUse = time(mask);
fill([tUse fliplr(tUse)], [p05(mask) fliplr(p95(mask))], colors(1,:), 'FaceAlpha',0.15, 'EdgeColor','none'); hold on
plot(time(isfinite(p50)), p50(isfinite(p50)), '-', 'Color', colors(1,:), 'LineWidth',1.5);
grid on
xlabel("Time [seconds]", 'Interpreter','latex', 'fontSize',18);
ylabel("Attitude Tracking Error [deg]", 'Interpreter','latex', 'fontSize',18);
title("Command Tracking Error (MC: 5/50/95\%)", 'Interpreter','latex', 'fontSize',20);
legend(["5-95\% band","median"], 'Interpreter','latex');

nexttile;
mask = isfinite(p05e) & isfinite(p95e);
tUse = time(mask);
fill([tUse fliplr(tUse)], [p05e(mask) fliplr(p95e(mask))], colors(2,:), 'FaceAlpha',0.15, 'EdgeColor','none'); hold on
plot(time(isfinite(p50e)), p50e(isfinite(p50e)), '-', 'Color', colors(2,:), 'LineWidth',1.5);
grid on
xlabel("Time [seconds]", 'Interpreter','latex', 'fontSize',18);
ylabel("Attitude Estimation Error [deg]", 'Interpreter','latex', 'fontSize',18);
title("Estimator Attitude Error (MC: 5/50/95\%)", 'Interpreter','latex', 'fontSize',20);
legend(["5-95\% band","median"], 'Interpreter','latex');
ylim([0, inf]);

nexttile;
mask = isfinite(p05r) & isfinite(p95r);
tUse = time(mask);
fill([tUse fliplr(tUse)], [p05r(mask) fliplr(p95r(mask))], colors(4,:), 'FaceAlpha',0.15, 'EdgeColor','none'); hold on
plot(time(isfinite(p50r)), p50r(isfinite(p50r)), '-', 'Color', colors(4,:), 'LineWidth',1.5);
grid on
xlabel("Time [seconds]", 'Interpreter','latex', 'fontSize',18);
ylabel("Rate Estimation Error Magnitude [deg/s]", 'Interpreter','latex', 'fontSize',18);
title("Estimator Rate Error Magnitude (MC: 5/50/95\%)", 'Interpreter','latex', 'fontSize',20);
legend(["5-95\% band","median"], 'Interpreter','latex');
ylim([0, inf]);

title(tiles, "Monte Carlo Summary", 'Interpreter','latex', 'fontSize',24);

% NEW: alpha component error percentiles (three plots, same method as single-run)
figure("Color","white");
tiles = tiledlayout(3,1, 'TileSpacing','compact', 'Padding','compact');

nexttile;
mask = isfinite(p05ax) & isfinite(p95ax);
tUse = time(mask);
fill([tUse fliplr(tUse)], [p05ax(mask) fliplr(p95ax(mask))], colors(1,:), 'FaceAlpha',0.15, 'EdgeColor','none'); hold on
plot(time(isfinite(p50ax)), p50ax(isfinite(p50ax)), '-', 'Color', colors(1,:), 'LineWidth',1.5);
grid on
xlabel("Time [seconds]", 'Interpreter','latex', 'fontSize',18);
ylabel("$\alpha_x$ [deg]", 'Interpreter','latex', 'fontSize',18);
title("$\alpha_x$ Error (MC: 5/50/95\%)", 'Interpreter','latex', 'fontSize',20);
legend(["5-95\% band","median"], 'Interpreter','latex');

nexttile;
mask = isfinite(p05ay) & isfinite(p95ay);
tUse = time(mask);
fill([tUse fliplr(tUse)], [p05ay(mask) fliplr(p95ay(mask))], colors(2,:), 'FaceAlpha',0.15, 'EdgeColor','none'); hold on
plot(time(isfinite(p50ay)), p50ay(isfinite(p50ay)), '-', 'Color', colors(2,:), 'LineWidth',1.5);
grid on
xlabel("Time [seconds]", 'Interpreter','latex', 'fontSize',18);
ylabel("$\alpha_y$ [deg]", 'Interpreter','latex', 'fontSize',18);
title("$\alpha_y$ Error (MC: 5/50/95\%)", 'Interpreter','latex', 'fontSize',20);
legend(["5-95\% band","median"], 'Interpreter','latex');

nexttile;
mask = isfinite(p05az) & isfinite(p95az);
tUse = time(mask);
fill([tUse fliplr(tUse)], [p05az(mask) fliplr(p95az(mask))], colors(3,:), 'FaceAlpha',0.15, 'EdgeColor','none'); hold on
plot(time(isfinite(p50az)), p50az(isfinite(p50az)), '-', 'Color', colors(3,:), 'LineWidth',1.5);
grid on
xlabel("Time [seconds]", 'Interpreter','latex', 'fontSize',18);
ylabel("$\alpha_z$ [deg]", 'Interpreter','latex', 'fontSize',18);
title("$\alpha_z$ Error (MC: 5/50/95\%)", 'Interpreter','latex', 'fontSize',20);
legend(["5-95\% band","median"], 'Interpreter','latex');

title(tiles, "Attitude Error Components from $\log(q_{true}^{-1}\otimes \hat{q})$", 'Interpreter','latex', 'fontSize',24);

% NIS distribution summary (updates only)
figure("Color","white");
nis_lo = chi2inv(0.005, 3);
nis_hi = chi2inv(0.995, 3);
histogram(nis_all, 80, 'FaceColor', colors(1,:), 'FaceAlpha',0.35, 'EdgeColor','none'); hold on
xline(nis_lo, '--', 'Color', colors(2,:), 'LineWidth',1.5);
xline(nis_hi, '--', 'Color', colors(2,:), 'LineWidth',1.5);
grid on
xlabel("NIS", 'Interpreter','latex', 'fontSize',18);
ylabel("Count", 'Interpreter','latex', 'fontSize',18);
title("NIS Distribution (Star Updates Only)", 'Interpreter','latex', 'fontSize',20);
legend(["NIS","99\% bounds"], 'Interpreter','latex');

end

function p = colPrctile(X, pct)
%COLPRCTILE Percentile per column ignoring NaNs (older MATLAB compatible)
nT = size(X,2);
p = nan(1,nT);
for j = 1:nT
    v = X(:,j);
    v = v(isfinite(v));
    if ~isempty(v)
        p(j) = prctile(v, pct);
    end
end
end

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
