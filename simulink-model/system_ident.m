system_init;
out = sim('system_ident_model');

simout = out.simout;
%%
% Extraction
t = simout.time; 
u = simout.signals.values(:,1); 
y = simout.signals.values(:,2);
t = t(2:end); u = u(2:end); y = y(2:end); 

% Period split
n = round(t_fs/t_s);
Nr = floor(length(u)/n);
u = u(end+1-Nr*n:end);
y = y(end+1-Nr*n:end);

Nrt = floor(length(u)/n)*n;
u = u(end-Nrt+1:end);
y = y(end-Nrt+1:end);
ur = reshape(u,n,[]);
yr = reshape(y,n,[]);

f(1).s = figure;
subplot(2,1,1)
plot(t(1:n),ur');
ylabel('Input')
subplot(2,1,2)
plot(t(1:n),yr');
legend(cellstr([repmat('Period ', Nr, 1),num2str([1:Nr]')])) 
title('The input and output profile for different periods')          
xlabel('Time [s]'), ylabel('Output')

% Choice of periods
chosenPeriods = 2:N_p;
ur = mean(ur(:,chosenPeriods),2);
yr = mean(yr(:,chosenPeriods),2);

% Fourier transform

uf = fft(ur);  
yf = fft(yr);

% Define frequency range
fResolution = 1/t_fs;
fEnd = 1/(2*t_s);
fgrid = 0:fResolution:fEnd;
Nf = length(fgrid);

uf = uf(1:Nf);
yf = yf(1:Nf);

f(2).s = figure;
subplot(1,2,1)
loglog(fgrid,abs(uf));
xlabel('Frequency [Hz]'); ylabel('|U|');
title('Fourier transform of the input')
subplot(1,2,2)
loglog(fgrid,abs(yf));
xlabel('Frequency [Hz]'); ylabel('|Y|');
title('Fourier transform of the output')

ind = find(abs(uf)>(0.01*max(abs(uf))+0));

% Bode plot
Hm = yf./uf;                                        
Hm_frd = frd(Hm(ind),2*pi*fgrid(ind));

save Hm_frd4 Hm_frd
%%
% Plot the bode diagram and the FRF of the measurements
f(4).s = figure;  hold on
opts = bodeoptions;
opts.XLim = [fgrid(2) fgrid(end)];
opts.FreqUnits = 'Hz';
h1 = bodeplot(Hm_frd,'r.',opts);
grid on
legend('measured response', 'modelled response')
%%
% Change positions of the figures
for k = 1:4
    f(k).s.Units = 'normalized';
end
f(1).s.OuterPosition = [0 0+0.04 0.5 0.5-0.04];   % Bottom left
f(4).s.OuterPosition = [0.5 0+0.04 0.5 0.5-0.04]; % Bottom right
f(2).s.OuterPosition = [0 0.5 0.5 0.5];           % Top left
f(3).s.OuterPosition = [0.5 0.5 0.5 0.5];         % Top right