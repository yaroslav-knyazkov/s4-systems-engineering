clc; clear; close;

t_s = .5e-3;

k_enc = 4096;
r_enc = -43.704;
c2t = 1 / (k_enc * r_enc);

V_max = 6.4512;
t_p = 10;
N = 10;

V_p = 2 * V_max / N;

t_f = t_p * N;