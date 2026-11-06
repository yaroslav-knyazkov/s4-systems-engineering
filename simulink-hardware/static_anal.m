simout = out.simout;

t = simout.time;
u = simout.signals.values(:,1);   % input voltage
y = simout.signals.values(:,2);   % theta

% Sample each step near the end of its hold interval (transientless)
frac = 0.95;                       % sample at 95% into each plateau
V_ss    = zeros(N,1);
theta_ss = zeros(N,1);

for i = 1:N
    t_sample = (i-1)*t_p + frac*t_p;
    idx = find(t <= t_sample, 1, 'last');
    V_ss(i)     = u(idx);
    theta_ss(i) = y(idx);
end

% Linear fit: theta = m*V + b  (static gain m)
p = polyfit(V_ss, theta_ss, 1);
m = p(1);   % static gain [theta/V]
b = p(2);

fprintf('Static gain (theta/V): %.6g\n', m);
fprintf('Offset: %.6g\n', b);

% Plot transientless theta(V)
figure;
plot(V_ss, theta_ss, 'o', 'MarkerFaceColor','b'); hold on;
plot(V_ss, polyval(p, V_ss), 'r-', 'LineWidth', 1.2);
grid on;
xlabel('Voltage V (V)');
ylabel('\theta (rad)');
title('Transientless static response \theta(V)');
legend('Steady-state samples', ...
       sprintf('Fit: \\theta = %.4g V + %.4g', m, b), ...
       'Location','best');