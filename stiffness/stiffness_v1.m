%% Stiffness and natural frequency analysis with spring-thickness sweep
clear; clc; close all;

%% Fixed parameters
block_width   = 12.5e-3;
block_range_1   = 2:5;
block_range_2   = 1:5;
structure_I   = [180900 359900 663300 995800] * 1e-9;      % moment of inertia, correlates with r_1
r_5           = 20e-3;
spring_width  = block_width;
spring_E      = 200e9;

% Geometry vectors (r_1 and r_3 both scale with block_range)
r_1_values    = block_width * block_range_1;   % r_1 per block count
r_3_values    = block_width * block_range_2;   % r_3 per curve
r_3_blocks    = block_range_2;

% Spring thicknesses to iterate over (m)
spring_thickness_set = (0.2:0.1:1.0) * 1e-3;

%% ---- helper for stiffness ----
% c as a function of scalar r_1, scalar r_3, scalar spring_thickness
compute_c = @(r_1, r_3, t, EI) ...
    2 * EI ./ (r_1 + r_3 + t).^3 .* ...
    ( 4*(r_1 + r_3 + t).^2 ...
    + 12*(r_1 + t/2).^2 ...
    + 12*(r_1 + t/2).*(r_1 + r_3 + t) );

%% =====================================================================
%  FIGURE 1: Stiffness c vs block count  (one representative thickness)
%  FIGURE 2: Natural frequency w_n vs block count
%  (uses the nominal thickness 0.4e-3, matching your original script)
%% =====================================================================
spring_thickness = 0.4e-3;
springs_I  = spring_width * spring_thickness^3 / 12;
spring_EI  = spring_E * springs_I;

colors = lines(numel(r_3_values));

% ---------- Figure 1: stiffness ----------
figure; hold on;
for idx = 1:numel(r_3_values)
    r_3 = r_3_values(idx);
    c   = compute_c(r_1_values, r_3, spring_thickness, spring_EI);

    plot(block_range_1, c, '-', 'LineWidth', 1.5, 'Color', colors(idx,:), ...
        'DisplayName', sprintf('%d blocks (r_3)', r_3_blocks(idx)));

    threshold = 132.285714286 * (r_1_values + spring_thickness + r_5);
    passed    = c <= threshold;

    scatter(block_range_1(~passed), c(~passed), 50, 'r', 'filled', 'HandleVisibility','off');
    scatter(block_range_1( passed), c( passed), 50, 'g', 'filled', 'HandleVisibility','off');
end
xlabel('Number of blocks (r_1 direction)');
ylabel('Stiffness c');
title('Stiffness vs block count  (case r_1=r_2, r_3=r_4)');
legend('show','Location','best'); grid on; xticks(block_range_1); hold off;

% ---------- Figure 2: natural frequency ----------
figure; hold on;
for idx = 1:numel(r_3_values)
    r_3 = r_3_values(idx);
    c   = compute_c(r_1_values, r_3, spring_thickness, spring_EI);

    w_n = sqrt(c ./ structure_I);     % structure_I correlates with r_1 index

    plot(block_range_1, w_n, '-', 'LineWidth', 1.5, 'Color', colors(idx,:), ...
        'DisplayName', sprintf('%d blocks (r_3)', r_3_blocks(idx)));

    % carry the same pass/fail test through to w_n points
    threshold = 132.285714286 * (r_1_values + spring_thickness/2 + r_5);
    passed    = c <= threshold;

    scatter(block_range_1(~passed), w_n(~passed), 50, 'r', 'filled', 'HandleVisibility','off');
    scatter(block_range_1( passed), w_n( passed), 50, 'g', 'filled', 'HandleVisibility','off');
end
xlabel('Number of blocks (r_1 direction)');
ylabel('Natural frequency \omega_n = sqrt(c/I)');
title('Natural frequency vs block count  (case r_1=r_2, r_3=r_4)');
legend('show','Location','best'); grid on; xticks(block_range_1); hold off;

%% =====================================================================
%  SWEEP: iterate over r_1, r_3 and spring_thickness
%  Keep only configs that PASS the threshold (c <= 132.28...*(r_1+t+r_5))
%  Result: ranked table (high -> low w_n) of r_1, r_3, spring_thickness, c, w_n
%% =====================================================================
rows = [];   % [r_1, n1, r_3, n3, t, c, c_max, w_n]  (only passing configs)

for ti = 1:numel(spring_thickness_set)
    t          = spring_thickness_set(ti);
    springs_I  = spring_width * t^3 / 12;
    spring_EI  = spring_E * springs_I;

    for i1 = 1:numel(block_range_1)        % index into r_1 (and structure_I)
        r_1 = r_1_values(i1);
        n1  = block_range_1(i1);           % number of blocks in r_1 direction
        I   = structure_I(i1);

        for i3 = 1:numel(block_range_1)    % index into r_3
            r_3 = r_3_values(i3);
            n3  = block_range_1(i3);       % number of blocks in r_3 direction

            c   = compute_c(r_1, r_3, t, spring_EI);
            w_n = sqrt(c / I);

            % must pass the same threshold test as the plots
            c_max = 132.285714286 * 2 * (r_1 + t/2 + r_5);
            if c <= c_max
                rows(end+1, :) = [r_1, n1, r_3, n3, t, c, c_max, w_n]; %#ok<SAGROW>
            end
        end
    end
end

if isempty(rows)
    error('No configuration passed the threshold test.');
end

% Sort passing configs by w_n descending (w_n is column 8)
[~, order] = sort(rows(:,8), 'descend');
rows = rows(order, :);

% Build table with block counts shown in parentheses alongside r values
r_1_label = arrayfun(@(v,n) sprintf('%.4g (%d)', v, n), rows(:,1), rows(:,2), 'UniformOutput', false);
r_3_label = arrayfun(@(v,n) sprintf('%.4g (%d)', v, n), rows(:,3), rows(:,4), 'UniformOutput', false);

results = table(r_1_label, r_3_label, rows(:,5), rows(:,6), rows(:,7), rows(:,8), ...
    'VariableNames', {'r_1_blocks','r_3_blocks','spring_thickness','c','c_max','w_n'});

disp('Passing configurations ranked by natural frequency (high -> low):');
disp(results);

best = results(1,:);
fprintf('\nHighest w_n configuration that passes the threshold:\n');
fprintf('  r_1 (blocks)     = %s m\n', best.r_1_blocks{1});
fprintf('  r_3 (blocks)     = %s m\n', best.r_3_blocks{1});
fprintf('  spring_thickness = %.4g m\n', best.spring_thickness);
fprintf('  c                = %.6g\n',   best.c);
fprintf('  c_max            = %.6g\n',   best.c_max);
fprintf('  w_n              = %.6g\n',   best.w_n);

% Optional: save full ranking to CSV
writetable(results, fullfile(fileparts(mfilename('fullpath')), 'wn-ranking.csv'));