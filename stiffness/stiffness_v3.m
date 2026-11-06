clc; clc; close;

%% Init
% Helper functions
compute_c_max = @(r) 264.5714 * r;
compute_stress = @(t, r) t <= r/17.5;
compute_retarded = @(i, j, n, m) ismember(i+n, [2 3]) & ismember(j+m, [2 3]);

compute_I = @(w, t) w * (t)^3 / 12;

% Assumption: spring thickness and width are equal
compute_c = @(r_1, r_3, t, EI) ...
    EI ./ (r_1 + r_3 + t).^3 .* ...
    ( 4*(r_1 + r_3 + t).^2 ...
    + 12*(r_1 + t/2).^2 ...
    + 12*(r_1 + t/2).*(r_1 + r_3 + t) );

% Variables
block_width = 12.5e-3;

block_range_r_1 = 2:5;
block_range_r_2 = 2:5;
block_range_r_3 = 0:5;
block_range_r_4 = 0:5;
r_5 = 5 * block_width;

structure_Is = [ 11e9 12e9 13e9 14e9 15e9;...
                 21e9 217000 246800 345600 425500;...
                 31e9 349700 425500 52000 602600;...
                 41e9 462000 537600 698200 799300;...
                 51e9 658200 764300 954200 1065000] * 1e-9; 

spring_E = 200e9;
spring_width = block_width;
spring_thicknesses = 1 : 6 * 1e-4;

%% Automatic

rows = numel(block_range_r_1) * numel(block_range_r_2) * numel(block_range_r_3) * numel(block_range_r_4);
% [i, j, n, m, t, c, c_max, I, w_n]
passed = NaN(rows, 9);
idx = 1;

spring_thickness = .4e-3;
spring_EI = compute_I(spring_width, spring_thickness) * spring_E;

for i = block_range_r_1
    r_1 = block_width * i;
    for j = block_range_r_2
        r_2 = block_width * j;
        for n = block_range_r_3
            r_3 = block_width * n;
            for m = block_range_r_4
                r_4 = block_width * m;

                c_1 = compute_c(r_1, r_3, spring_thickness, spring_EI);
                c_2 = compute_c(r_2, r_4, spring_thickness, spring_EI);

                c = c_1 + c_2;
                structure_I = structure_Is(i, j); % may be wrong order
    
                w_n = sqrt(c/structure_I);

                c_max = compute_c_max(r_2 + spring_thickness/2 + r_5);
                stiffness = c <= c_max;
                stress = true;
                retarded = compute_retarded(i, j, n, m);
                pass = (c <= c_max) && retarded;

                if (pass)
                    row = [i j n m spring_thickness c c_max structure_I w_n];
                    
                    passed(idx, :) = row;
                    idx = idx + 1;
                end
            end
        end
    end
end

passed = passed(1:idx-1, :);
[~, order] = sort(passed(:,9), 'descend');
passed = passed(order, :);

% Build table with block counts shown in parentheses
i_label = arrayfun(@(n) sprintf('%.4g (%d)', block_width*n, n), passed(:,1), 'UniformOutput', false);
j_label = arrayfun(@(n) sprintf('%.4g (%d)', block_width*n, n), passed(:,2), 'UniformOutput', false);
n_label = arrayfun(@(n) sprintf('%.4g (%d)', block_width*n, n), passed(:,3), 'UniformOutput', false);
m_label = arrayfun(@(n) sprintf('%.4g (%d)', block_width*n, n), passed(:,4), 'UniformOutput', false);

results = table(passed(:,1), passed(:,2), passed(:,3), passed(:,4), ...
    passed(:,5), passed(:,6), passed(:,7), passed(:,8), passed(:,9), ...
    'VariableNames', {'r_1','r_2','r_3','r_4','spring_thickness','c','c_max','structure_I','w_n'});

% results = table(i_label, j_label, n_label, m_label, ...
%     passed(:,5), passed(:,6), passed(:,7), passed(:,8), passed(:,9), ...
%     'VariableNames', {'r_1','r_2','r_3','r_4','spring_thickness','c','c_max','structure_I','w_n'});

disp('Passing configurations ranked by natural frequency (high -> low):');
disp(results);