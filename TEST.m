%clear
%clc
%% Description of wind farm
R = 75;             % Blade radius m
rho = 1.225;        % Air density kg/m³
Prated = 6e6;       % Generation capability MW
                    % NOTE: This means that the rated wind speed at is    
                    % 9.779999812412862 m/s

VRegion2 = (Prated/((16/27)*0.5*rho*pi*R^2))^(1/3); % Region 2 wind speed
CI = 3.5;                                           % Cut-in speed
CO = 26;                                            % Cut-out speed

%% Wind speed and power
n = 400;                    % Dimension of vectors and matrices
Vi = 14;                     % Wind speed
a3 = 1/3;                   % Maximum power extraction from last turbine
a = linspace(0,0.5, n);     % Axial induction factors
Vo1 = zeros(n,1);           % Wind output from turbine 1
Vo2 = zeros(n,n);           % Wind output from turbine 2
P1 = zeros(n,1);            % Power output from turbine 1
P2 = zeros(n,n);            % Power output from turbine 2
P3 = zeros(n,n);            % Power output from turbine 3
%% Calculation of actual power extraction
for i = 1:n
    [Vo1(i), P1(i)] = turbineOutput(Vi, a(i));
end
P1 = kron(ones(1,n), P1);   % For dimensiont to agree
for i = 1:n
    for j = 1:n
        [Vo2(i,j), P2(i,j)] = turbineOutput(Vo1(i), a(j));
        [~, P3(j,i)] = turbineOutput(Vo2(i,j), a3);
    end
end

Ptotal = (P1+P2+P3)/1e6;                            % Scale to MW
epsilon = 0.0000000000001;              
[r, c] = find(Ptotal > max(max(Ptotal)) - epsilon); % Index of optimal a
PESC = Ptest.Data/1e6;                              % Ptotal from ESC
a11 = a1test.Data;                                  % a1 from ESC
a22 = a2test.Data;                                  % a2 from ESC


%% Calculation of theoretical Greedy Approach power extraction and gain
if Vi < VRegion2        % Maximum power extration per Betz's limit if the 
                        % free wind speed is less than the rated wind speed
    [VGo1,PG1] = turbineOutput( Vi, 1/3);
    [VGo2,PG2] = turbineOutput( VGo1, 1/3);
    [~,PG3] = turbineOutput( VGo2, 1/3);
    PG = (PG1+PG2+PG3)/1e6;
    aG1 = 1/3;
    aG2 = 1/3;
else
    VGo1 = zeros(n,1);  % Wind output from turbine 1
    VGo2 = zeros(n,n);  % Wind output from turbine 2
    PG1 = zeros(n,1);   % Power output from turbine 1
    PG2 = zeros(n,n);   % Power output from turbine 2
    PG3 = zeros(n,n);   % Power output from turbine 3
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
    [rG, cG] = find(Ptotal > max(max(PG)) - epsilon);   % Find index of optimal a
    aG1 = a(cG);
    aG2 = a(rG);
end

Gain = max(max(Ptotal))/max(max(PG))-1;

%% Systems measures of a1 and a2 vs. wind speed
figure(1)
hold on
contourf(a,a,Ptotal, 20, 'linewidth', 0.01)
h1 = plot(a(c), a(r), '.g', 'MarkerSize', 20); % Optimal a1 and a2
h2 = plot(aG1, aG2, '.b', 'MarkerSize', 20); % Greedy approach
h3 = plot(a22, a11, 'c', 'linewidth', 4); % Simulated a1 and a2
%h3 = plot(a22, a11, 'm', 'linewidth', 4);
h4 = plot(a22(end), a11(end), '.m', 'MarkerSize', 20); % Simulation end

colorbar;
xlabel('a_1')
ylabel('a_2')
ylabel(colorbar, 'MW')
legend([h1 h2 h3 h4], 'Calculated optimal point', 'Greedy approach', 'Extremum Seeking of a', 'Point of convergence with ESC')

%% Plotting surf
figure(2)
hold on
grid on
h1 = plot3(a(c), a(r), Ptotal(r,c), '.g', 'MarkerSize', 20);
h3 = plot3(a22, a11, PESC, 'c', 'linewidth', 3);
h4 = plot3(a22(end), a11(end), PESC(end), '.m', 'MarkerSize', 30);
surf(a, a, Ptotal)
shading interp
colorbar
xlabel('a_1')
ylabel('a_2')
zlabel('P / MW')
if Vi < VRegion2
    h2 = plot3(aG1, aG2, PG, '.b', 'MarkerSize', 30);
    legend([h1 h2 h3 h4], 'Calculated optimal point', 'Greedy approach', 'Extremum Seeking measurements', 'Point of convergence')
else
    Gpm = max(max(PESC));  % Maximum power extraction
    [rG, cG] = find(Ptotal > Gpm - epsilon);   % Find index of optimal a
    h2 = plot3(aG1, aG2, Gpm, '.b', 'MarkerSize', 30);
    legend([h1(1) h2(1) h3 h4], 'Calculated optimal point', 'Greedy approach', 'Extremum Seeking measurements', 'Point of convergence')
end

