%clear
%clc
%% Description of wind farm
R = 75; % Blade radius m
rho = 1.225; % Air density kg/m³
Prated = 6e6; % Generation capability MW
% NOTE: This means that the speed at which we enter region 2 is
% 9.779999812412862 m/s!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
VRegion2 = (Prated/((16/27)*0.5*rho*pi*R^2))^(1/3); % Region 2 wind speed
CI = 3.5; % Cut-in speed
CO = 26; % Cut-out speed
% d = n is the distance in m between this turbine and the next (check
% function)
%% Wind speed and declaration of wind speeds and powers
n = 100; % Dimension of vectors and matrices in Matlab code
Vi = 9.5;
a3 = 1/3; % Since we want to get as much power as possible from the last turbine.
a = linspace(0,0.5, n);  % Trying combinations of (a1,a2) between 0 and 0.5
Vo1 = zeros(n,1);  % Wind output from turbine 1
Vo2 = zeros(n,n); % Wind output from turbine 2
P1 = zeros(n,1);   % Power output from turbine 1
P2 = zeros(n,n);  % Power output from turbine 2
P3 = zeros(n,n);  % Power output from turbine 3
%% Calculation of theoretical ESC power extraction
for i = 1:n
    [Vo1(i), P1(i)] = turbineOutput(Vi, a(i));
end
P1 = kron(ones(1,n), P1);
for i = 1:n
    for j = 1:n
        [Vo2(i,j), P2(i,j)] = turbineOutput(Vo1(i), a(j));
        [~, P3(j,i)] = turbineOutput(Vo2(i,j), a3);
    end
end
Ptotal = (P1+P2+P3)/1e6;
pm = max(max(Ptotal));  % Maximum power extraction
epsilon = 0.00000000001;
[r, c] = find(Ptotal > pm - epsilon);   % Find index of optimal a

%% Calculation of theoretical Greedy Approach power extraction and gain
if Vi < VRegion2
    [VGo1,PG1] = turbineOutput( Vi, 1/3);
    [VGo2,PG2] = turbineOutput( VGo1, 1/3);
    [~,PG3] = turbineOutput( VGo2, 1/3);
    PG = (PG1+PG2+PG3)/1e6;
    aG1 = 1/3;
    aG2 = 1/3;
else
    VGo1 = zeros(n,1);  % Wind output from turbine 1
    VGo2 = zeros(n,n); % Wind output from turbine 2
    PG1 = zeros(n,1);   % Power output from turbine 1
    PG2 = zeros(n,n);  % Power output from turbine 2
    PG3 = zeros(n,n);  % Power output from turbine 3
    for i = 1:n
        [VGo1(i), PG1(i)] = turbineOutput(Vi, a(i));
    end
    PG1 = kron(ones(1,n), PG1);
    for i = 1:n
        for j = 1:n
            if VGo1 < VRegion2
                [VGo2(i,j), PG2(i,j)] = turbineOutput(VGo1(i), 1/3);
            else
                [VGo2(i,j), PG2(i,j)] = turbineOutput(VGo1(i), a(j));
            end
            [~, PG3(j,i)] = turbineOutput(VGo2(i,j), a3);
        end
    end
    PG = (PG1+PG2+PG3)/1e6; % Greedy approach
    pm = max(max(PG));  % Maximum power extraction
    epsilon = 0.00000000001;
    [aG1, aG2] = find(Ptotal > pm - epsilon);   % Find index of optimal a
end

Gain = max(max(Ptotal))/max(max(PG))-1;

%% Surf plot of ESC vs. Greedy Approach
figure(1)
hold on
grid on
h1 = plot3(a(c), a(r), Ptotal(r,c), '.g', 'MarkerSize', 25);
if Vi < VRegion2
    h2 = plot3(aG1, aG2, PG, '.b', 'MarkerSize', 25);
else
    h2 = plot3(aG1, aG2, PG(aG1, aG2), '.b', 'MarkerSize', 25);
end
surf(a, a, Ptotal)
shading interp
colorbar
xlabel('a_1')
ylabel('a_2')
zlabel('P / MW')
legend([h1 h2], 'Optimal axial induction factors', 'Greedy approach')

%% Contour plot of ESC vs. Greedy Approach
figure(2)
hold on
contourf(a,a,Ptotal, 20, 'linewidth', 0.01)
h1 = plot(a(c), a(r), '.g', 'MarkerSize', 20);
if Vi < VRegion2
h2 = plot(aG1, aG2, '.b', 'MarkerSize', 20);
else
h2 = plot(aG1, aG2, PG(aG1, aG2), '.b', 'MarkerSize', 20);
end
colorbar;
xlabel('a_1')
ylabel('a_2')
ylabel(colorbar, 'MW')
%legend([h1 h2 h3], 'Extremum Seeking of a', 'Point of convergence', 'Calculated optimal point')
legend([h1 h2], 'Optimal axial induction factors', 'Greedy approach')

%% Plot of regions
n = 1000;
[P, ~] = powerex(n);
figure(3)
hold on
grid on
title('Power as function of wind speed')
xlabel('Wind speed / m/s')
ylabel('P / MW')
ylim([-1 7])
x = linspace(0, 35, n);
plot(x,P/1e6, 'r') % Power curve captured
%%%%% distinction lines for the different regions
plot([3.5,3.5],[0,7], 'b--')
plot([9.78,9.78],[0,7], 'b--')
plot([26,26],[0,7], 'b--')

%% Plot of gains
G = gain();
figure(4)
Speed = [3.5:0.1:9.7]';
plot(Speed, G*100)
grid on
xlabel('Wind speed  m/s')
ylabel('Gain  %')