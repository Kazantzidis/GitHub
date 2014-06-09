function [ P, Pwind ] = powerex( n )
%powerex calculates and returns power extracted by a specific wind turbine
%as well as the power available in the wind for the windspeed given in the
%input.

R = 75; % Blade radius m
rho = 1.225; % air density kg/m³
CPmax = 16/27; % maximum power coefficient
CIspeed = 3.5; % Cut-in speed, m/s 
COspeed = 26; % Cut-out speed, m/s 
GC = 6e6; % Generation capability MW
P = zeros(n,1);
x = linspace(0,35,n);

for i=1:n
    if x(i)>CIspeed && x(i)<COspeed
        P(i) = (1/2)*rho*pi*R^2*x(i).^3*CPmax; % Energy extracted
        if P(i)>GC
            P(i) = GC;
        end
    end
end
Pwind = (1/2)*rho*pi*R^2*x.^3; % Energy available in the wind
end

