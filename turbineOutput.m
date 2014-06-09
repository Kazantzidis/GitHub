function [ Vo, P] = turbineOutput( Vi, a )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

CI = 3.5;   % Cut-in speed
CO = 26;    % Cut-out speed

if Vi < CI
    Vo = Vi;
    P = 0;
elseif  Vi > CO
    Vo = Vi;
    P = 0;
else
    R = 75; % Blade radius m
    rho = 1.225; % Air density kg/m³
    Prated = 6e6; % Generation capability MW
    d = 500; % Distance in m between this turbine and the next. d is both the
    % (yu-yd) and (xu-xd) which is the distance between upstream and
    % downstream turbines (used for the gamma OF overlap factor
    
    %% Calculate power output
    Pwind = (1/2)*rho*pi*R.^2*Vi.^3;
    Cp = 4*a.*(1-a).^2;
    P = min(Pwind*Cp, Prated);
    
    %% Calculate wind output
    Dc = 0.075; % Wake-decay constant. Determined empirically;
    gammaOF = (2*R+d*Dc)/R; % Overlap factor   2R+Dcd
    Ct = 4*a.*(1-a); % Turbine's thrust coefficient
    dV = Vi*(1-sqrt(1-Ct))*((2*R)/(2*R+2*Dc*d)).^2*gammaOF; % Velocity deficit
    Vo = Vi-dV;
    if Vi-dV <0
        Vo = 0;
    end
end
end