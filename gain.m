function [ G ] = gain( )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

Vi = [3.5:0.1:9.7]';
G = zeros(size(Vi,1),1);
for h = 1:size(Vi,1)
    %% Wind speed and declaration of wind speeds and powers
    n = 100; % Dimension of vectors and matrices in Matlab code
    a3 = 1/3; % Since we want to get as much power as possible from the last turbine.
    a = linspace(0,0.5, n);  % Trying combinations of (a1,a2) between 0 and 0.5
    Vo1 = zeros(n,1);  % Wind output from turbine 1
    Vo2 = zeros(n,n); % Wind output from turbine 2
    P1 = zeros(n,1);   % Power output from turbine 1
    P2 = zeros(n,n);  % Power output from turbine 2
    P3 = zeros(n,n);  % Power output from turbine 3
    
    %% Calculation of power extraction
    for i = 1:n
        [Vo1(i), P1(i)] = turbineOutput(Vi(h), a(i));
    end
    P1 = kron(ones(1,n), P1);
    for i = 1:n
        for j = 1:n
            [Vo2(i,j), P2(i,j)] = turbineOutput(Vo1(i), a(j));
            [~, P3(j,i)] = turbineOutput(Vo2(i,j), a3);
        end
    end
    Ptotal = (P1+P2+P3)/1e6;
    
    [VGo1,PG1] = turbineOutput( Vi(h), 1/3);
    [VGo2,PG2] = turbineOutput( VGo1, 1/3);
    [~,PG3] = turbineOutput( VGo2, 1/3);
    PG = (PG1+PG2+PG3)/1e6;
    
    G(h) = max(max(Ptotal))/max(max(PG))-1;
    
end
end

