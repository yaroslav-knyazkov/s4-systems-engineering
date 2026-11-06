%% Stiffness and natural frequency analysis with spring-thickness sweep
clear; clc; close all;

%% Fixed parameters
block_width   = 12.5e-3;
spring_width  = block_width;
spring_E      = 200e9;

r_1           = 1 * block_width;
r_2           = 1 * block_width;
spring_thickness = .4e-3;
springs_I  = spring_width * spring_thickness^3 / 12;
spring_EI  = spring_E * springs_I;

r_3 = 1 * block_width;

compute_c = @(r_1, r_3, t, EI) ...
    EI ./ (r_1 + r_3 + t).^3 .* ...
    ( 4*(r_1 + r_3 + t).^2 ...
    + 12*(r_1 + t/2).^2 ...
    + 12*(r_1 + t/2).*(r_1 + r_3 + t) );

c_1 = compute_c(r_1, r_3, spring_thickness, spring_EI);
c_2 = compute_c(r_2, r_3, spring_thickness, spring_EI);

c = c_1 + c_2;

disp("c_1: " + c_1);
disp("c_2: " + c_2);
disp("c: " + c);

structure_I = 1;
w_n = sqrt(c/structure_I);

disp("w_n: " + w_n);