clc; clear; close all;

t_s = .0005;
t_f = 300;

% Ident
V_max = 6.4512;

w_0 = 1;
w_f = 1e3;
N_p = 5;

t_fs = t_f/N_p;

k_enc = 4096;
r_enc = -43.704;
c2t = 1 / (k_enc * r_enc);

% Estimated plant
c = 24.334;
I = 210000 * 1e-9;

% PID
t_z   = 0.00816092033;
t_p   = 0.01225351994;
t_i   = 0.03264368132;
k_p   = 157.4840453;

% 1
s = tf('s');
C_cont = k_p * (t_z*s + 1)/(t_p*s + 1) * (t_i*s + 1)/(t_i*s);

Cpid = pid(c2d(C_cont, t_s, 'tustin'), ...
           'IFormula','Trapezoidal', 'DFormula','Trapezoidal');

P  = Cpid.Kp; 
I_ = Cpid.Ki;
D  = Cpid.Kd;
N  = 1/Cpid.Tf;     % Simulink "N" = 1/Tf

% 2
k_p_ = k_p*(1 + t_z/t_i);
k_i = k_p / t_i;
k_d = k_p * t_z;