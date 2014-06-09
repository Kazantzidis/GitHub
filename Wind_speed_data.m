clear
clc
allSpeeds = csvread('wind_data.csv', 1, 0); % read wind speeds from .csv file
someSpeeds = allSpeeds(1:100); % Pick out only first 100 elements
wind_speed = kron(someSpeeds, ones(2000,1)); % keep every windspeed fixed for 60 samples

t = [1:200000]';
save Vi.mat wind_speed t
% t = 1:100;
% 
P = zeros(200000,1);
for i=1:200000
    [Vo, P1] = turbineOutput(wind_speed(i), 1/3); 
    [V, P2] = turbineOutput(Vo, 1/3); 
    P(i) = P1+P2;
end
% sys = ar(P,1);
% 
% bode(sys)
% grid on

%% For constant factor
constants = 10^(-7)*[1/10 0.2 0.7 1 1.5 2 3 4 5 6 7]';
K = kron(constants, ones(5000,1));
t = [1:55000]';