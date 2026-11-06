clc; clear; close;

% Motor
R = 10.24;
L = 2.82e-3;
k_e = 7.35;
k_f = 7.35;

V_max = 60;
I_max = 4;

% Mechanical
r = 0.1004;
I = 0.0002468;
c = 24.334;

% Encoder
K = 1;
k_enc = 4096 / (2 * pi);
r_2 = r;

% Plant
nom = r*k_f;
denom = [I*L I*R (L*c + k_f*k_e*r^2)  R*c];

% Sampling
t_s = 0.0005;
t_f = 100;
N_p = 5;

% PID
t_z   = 0.003301745405;
t_p   = 0.001767050128;
t_i   = 0.01320698162;
k_p   = 268.2357211;

s = tf('s');
C_cont = k_p * (t_z*s + 1)/(t_p*s + 1) * (t_i*s + 1)/(t_i*s);

Cpid = pid(c2d(C_cont, t_s, 'tustin'), ...
           'IFormula','Trapezoidal', 'DFormula','Trapezoidal');

P  = Cpid.Kp;
I_ = Cpid.Ki;
D  = Cpid.Kd;
N  = 1/Cpid.Tf;     % Simulink "N" = 1/Tf

% Ident
w_0 = 1e-3;
w_f = 1e3;
t_fs = t_f/N_p;