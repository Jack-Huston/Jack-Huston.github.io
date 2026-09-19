function plot_rw_rate_loop_margins(config)
% Realistic open-loop margins for a wheel-controlled rate loop.
% Loop: omega_cmd -> controller -> wheel torque dynamics -> rigid body -> omega_meas -> (-) feedback

% -----------------------------
% PLACEHOLDERS (replace from config later)
% -----------------------------
J = config.sc.J_true;                 % 3x3 inertia, assumed diagonal for loop-by-loop
Kp = diag(config.ctrl.Kp);            % using your existing gains (note: these were tuned for attitude error; see note below)
Kd = diag(config.ctrl.Kd);

tau_rw = 0.03;                        % [s] wheel torque time constant (placeholder)
Td     = 0.02;                        % [s] effective delay (placeholder, ~1 sample at 50 Hz)

% If you have controller sample time:
% Td = 0.5*config.ctrl.Ts;            % typical ZOH-equivalent delay approximation

Ji = diag(J);
s  = tf('s');

% Wheel lag and delay (Pade)
Grw = 1/(tau_rw*s + 1);
[numD, denD] = pade(Td, 1);
Gd = tf(numD, denD);

% Plant torque -> rate
% G = 1/(J*s) per axis
W = tf(zeros(1,3));

for i = 1:3
    C = Kd(i)*s + Kp(i);              % controller (PD form)
    G = 1/(Ji(i)*s);                  % rigid body rate plant
    W(i) = C * Grw * G * Gd;          % open-loop L(s)
end

% -----------------------------
% Margin plot (this is the "glance test" plot)
% -----------------------------
figure("Color","white");
marginplot(W);
grid on
legend(["L_x(s)","L_y(s)","L_z(s)"], "Location","best");
title("Rate-Loop Open-Loop Margins with Wheel Lag and Delay", "Interpreter","none");

% -----------------------------
% Numeric margins
% -----------------------------
am = allmargin(W);

axesName = ["x";"y";"z"];
GM_dB  = nan(3,1);
PM_deg = nan(3,1);
DM_s   = nan(3,1);
Wcg    = nan(3,1);
Wcp    = nan(3,1);

for i = 1:3
    % allmargin can return multiple crossings; pick the first finite one.
    if ~isempty(am(i).GainMargin)
        g = am(i).GainMargin;
        w = am(i).GainMarginFrequency;
        idx = find(isfinite(g) & g>0 & isfinite(w) & w>0, 1, 'first');
        if ~isempty(idx)
            GM_dB(i) = 20*log10(g(idx));
            Wcg(i)   = w(idx);
        end
    end

    if ~isempty(am(i).PhaseMargin)
        p = am(i).PhaseMargin;
        w = am(i).PhaseMarginFrequency;
        idx = find(isfinite(p) & isfinite(w) & w>0, 1, 'first');
        if ~isempty(idx)
            PM_deg(i) = p(idx);
            Wcp(i)    = w(idx);
        end
    end

    if ~isempty(am(i).DelayMargin)
        d = am(i).DelayMargin;
        idx = find(isfinite(d) & d>0, 1, 'first');
        if ~isempty(idx)
            DM_s(i) = d(idx);
        end
    end
end

disp(table(axesName, GM_dB, PM_deg, DM_s, Wcg, Wcp, ...
    'VariableNames', ["axis","gain_margin_dB","phase_margin_deg","delay_margin_s","w_cg_rad_s","w_cp_rad_s"]));

% -----------------------------
% Notes you should say in interview:
% - gains Kp/Kd came from attitude-error PD tuning, so for a true rate-loop controller,
%   you'd normally have different gains / structure (often PI). This is a robustness check.
% - J assumed diagonal and cross-coupling ignored.
% - wheel lag and delay are placeholders; use measured wheel/compute values when available.
% -----------------------------
end
