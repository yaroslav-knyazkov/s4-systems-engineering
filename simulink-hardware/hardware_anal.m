clc; clear; close all;
hardware_init;
load('Hm_frd3.mat', 'Hm_frd');
Hm_frd.FrequencyUnit = 'rad/s';

% Extract data
H = squeeze(Hm_frd.ResponseData);   % complex frequency response
w = Hm_frd.Frequency;               % frequency vector in rad/s

% Make sure units are rad/s (frd default; set explicitly to be safe)
Hm_frd.FrequencyUnit = 'rad/s';

% Quick check / plot in rad/s
opts = bodeoptions;
opts.FreqUnits = 'rad/s';
figure;
bodeplot(Hm_frd, 'r.', opts);
grid on
title('Measured FRF (frequency in rad/s)');

ax = findall(gcf, 'Type', 'axes');
for k = 1:numel(ax)
    yl = get(ax(k), 'YLabel');
    if contains(lower(get(yl, 'String')), 'phase')
        ylim(ax(k), [-360 360]);
        set(ax(k), 'YTick', -360:90:360);
    end
end

% --- Natural frequency from physical parameters ---
w_n = sqrt(c/I);                      % rad/s
w_c = 100;

% --- Phase at that w_n (interpolated onto measured grid) ---
ph = unwrap(angle(H)) * 180/pi;       % unwrapped phase [deg]
phase_at_wn = interp1(w, ph, w_n);    % interpolate to exact w_n
PM_at_wn = phase_at_wn + 180;
phase_at_wc = interp1(w, ph, w_c);    % interpolate to exact w_n
PM_at_wc = phase_at_wc + 180;

fprintf('w_n = %.2f rad/s\n', w_n);
fprintf('PM at w_n = %.2f deg\n', PM_at_wn);
fprintf('w_c = %.2f rad/s\n', w_c);
fprintf('PM at w_c = %.2f deg\n', PM_at_wc);

% Get the axes handles from the bode plot
ax = findall(gcf, 'Type', 'axes');   % usually ax(1)=phase, ax(2)=mag

for k = 1:numel(ax)
    xline(ax(k), w_n, '--b', 'w_n', ...
          'LineWidth', 1.2, ...
          'LabelOrientation', 'horizontal');
    xline(ax(k), w_c, '--y', 'w_c', ...
          'LineWidth', 1.2, ...
          'LabelOrientation', 'horizontal');
end

%% Controller design
zeta_goal = 0.707;
PM_goal = atand( 2*zeta_goal / sqrt( sqrt(1 + 4*zeta_goal^4) - 2*zeta_goal^2 ) );
disp("PM goal: " + PM_goal);

safety = 0;
PM_delta = PM_goal - PM_at_wc + safety;
disp("PM delta: " + PM_delta);

alpha = (1 - sind(PM_delta)) / (1 + sind(PM_delta));
tau_z = 1 / (w_c * sqrt(alpha));   % zero time constant (s)  -> corner at w_c*sqrt(alpha)
tau_p = 1 / (w_c / sqrt(alpha));   % pole time constant (s)  -> corner at w_c/sqrt(alpha)
beta = 4;
tau_i = beta * tau_z;

C_lead = tf([tau_z 1], [tau_p 1]);        % lead only, no scalar yet
C_i = tf([tau_i 1], [tau_i 0]);
L0     = Hm_frd * frd(C_lead * C_i, w, 'FrequencyUnit','rad/s');   % P*C without gain

mag_at_wc = abs(interp1(w, squeeze(L0.ResponseData), w_c));
k_p = 1 / mag_at_wc;                       % forces |P*C| = 1 (0 dB) at w_c

fprintf('alpha = %.10g;\n', alpha);
fprintf('t_z   = %.10g;\n', tau_z);
fprintf('t_p   = %.10g;\n', tau_p);
fprintf('t_i   = %.10g;\n', tau_i);
fprintf('k_p   = %.10g;\n', k_p);

C = k_p * C_lead * C_i;

%% Plant design
P_real = Hm_frd;

C_frd = frd(C, w, 'FrequencyUnit', 'rad/s');

% Open loop L = P*C  (frd * frd, same grid -> fine)
PC = P_real * C_frd;

% Bode plot: Hm_frd, P, and P*C together
opts2 = bodeoptions;
opts2.FreqUnits = 'rad/s';
opts2.Grid = 'on';

figure;
bodeplot(Hm_frd, 'r.', P_real, 'g', PC, 'b', opts2);
grid on
legend('H_m (measured)', 'P', 'P\cdotC', 'Location', 'best');
title('H_m, P, and P\cdotC (rad/s)');

ax = findall(gcf, 'Type', 'axes');
for k = 1:numel(ax)
    yl = get(ax(k), 'YLabel');
    if contains(lower(get(yl, 'String')), 'phase')
        ylim(ax(k), [-360 360]);
        set(ax(k), 'YTick', -360:90:360);
    end
end

% --- w_n and w_c marker lines on this figure too ---
ax2 = findall(gcf, 'Type', 'axes');
for k = 1:numel(ax2)
    xline(ax2(k), w_n, '--b', 'w_n', 'LineWidth', 1.2, ...
        'LabelOrientation', 'horizontal');
    xline(ax2(k), w_c, '--y', 'w_c', 'LineWidth', 1.2, ...
        'LabelOrientation', 'horizontal');
    xlim(ax(k), [0 1000]);
end

%%
