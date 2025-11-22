%% KERS Flywheel Design Script
% ME Design Project - Kinetic Energy Recovery System
% Date: November 2024
%
% This script designs a flywheel for an automotive KERS system
% that stores energy during braking and releases it during acceleration

clear; clc; close all;

%% Given Parameters and Constraints

% Power requirements
P_max = 60e3;           % Maximum power [W]
P_min = 45e3;           % Minimum power [W]
t_delivery = 5;         % Power delivery duration [s]

% Torque and vehicle specs
T_brake = 500;          % Available braking torque [Nm]
m_vehicle = 600;        % Total vehicle mass [kg]

% Size constraints (convert to meters)
D_max = 9 * 0.0254;     % Maximum diameter [m] (9 inches)
W_max = 4 * 0.0254;     % Maximum width [m] (4 inches)
r_max = D_max / 2;      % Maximum radius [m]

% Initial velocity after braking
v_initial = 80 / 3.6;   % Convert 80 km/h to m/s

%% Material Selection
% From Table 1 - choosing based on density and cost tradeoff

materials = {'Aluminum', 'Brass 60/40', 'Copper', 'Stainless Steel', 'Titanium', 'Zinc'};
densities = [2712, 8520, 8940, 7500, 4500, 7135];  % kg/m^3
costs = [2.80, 5, 11, 4, 100, 13];  % $/kg

% I'll use Stainless Steel - good balance of density (for energy storage)
% and reasonable cost. Higher density = more mass = more energy storage
% for same volume

material_choice = 4;  % Stainless Steel
rho = densities(material_choice);
cost_per_kg = costs(material_choice);

fprintf('=== KERS FLYWHEEL DESIGN ===\n\n');
fprintf('Selected Material: %s\n', materials{material_choice});
fprintf('Density: %.0f kg/m^3\n', rho);
fprintf('Cost: $%.2f/kg\n\n', cost_per_kg);

%% Part A: Calculate Moment of Inertia (Iterative Design)

% Energy requirement calculation
E_min = P_min * t_delivery;  % Minimum energy needed [J]
E_max = P_max * t_delivery;  % Maximum energy at full power [J]
E_target = (E_min + E_max) / 2;  % Target middle of range

fprintf('--- Energy Requirements ---\n');
fprintf('Minimum Energy: %.1f kJ\n', E_min/1000);
fprintf('Maximum Energy: %.1f kJ\n', E_max/1000);
fprintf('Target Energy: %.1f kJ\n\n', E_target/1000);

% For a solid disk: I = (1/2) * m * r^2 = (1/2) * (rho * pi * r^2 * w) * r^2
% I = (1/2) * rho * pi * r^4 * w

% Energy stored: E = (1/2) * I * omega^2
% So: E = (1/4) * rho * pi * r^4 * w * omega^2

% Design iteration table
fprintf('--- Design Iteration Process ---\n');
fprintf('Iter | Radius(m) | Width(m)  | Mass(kg) | I(kg.m^2) | omega(rad/s) | RPM      | Energy(kJ)\n');
fprintf('-----|-----------|-----------|----------|-----------|--------------|----------|----------\n');

% Store iteration data
iterations = [];
iter = 0;

% Iteration 1: Start with max dimensions, find required speed
r = r_max;
w = W_max;
m = rho * pi * r^2 * w;
I = 0.5 * m * r^2;
omega = sqrt(2 * E_target / I);
rpm = omega * 60 / (2*pi);
E_stored = 0.5 * I * omega^2;

iter = iter + 1;
fprintf('%4d | %9.4f | %9.4f | %8.2f | %9.5f | %12.1f | %8.0f | %9.2f\n', ...
    iter, r, w, m, I, omega, rpm, E_stored/1000);
iterations = [iterations; iter, r, w, m, I, omega, rpm, E_stored];

% Iteration 2: RPM is very high, let's try reducing width to increase speed capability
% and check if we need to adjust
r = r_max;
w = 0.08;  % 80mm width
m = rho * pi * r^2 * w;
I = 0.5 * m * r^2;
omega = sqrt(2 * E_target / I);
rpm = omega * 60 / (2*pi);
E_stored = 0.5 * I * omega^2;

iter = iter + 1;
fprintf('%4d | %9.4f | %9.4f | %8.2f | %9.5f | %12.1f | %8.0f | %9.2f\n', ...
    iter, r, w, m, I, omega, rpm, E_stored/1000);
iterations = [iterations; iter, r, w, m, I, omega, rpm, E_stored];

% Iteration 3: Still high RPM, try smaller radius
r = 0.10;  % 100mm radius
w = W_max;
m = rho * pi * r^2 * w;
I = 0.5 * m * r^2;
omega = sqrt(2 * E_target / I);
rpm = omega * 60 / (2*pi);
E_stored = 0.5 * I * omega^2;

iter = iter + 1;
fprintf('%4d | %9.4f | %9.4f | %8.2f | %9.5f | %12.1f | %8.0f | %9.2f\n', ...
    iter, r, w, m, I, omega, rpm, E_stored/1000);
iterations = [iterations; iter, r, w, m, I, omega, rpm, E_stored];

% Iteration 4: Max dimensions with practical RPM target around 40000-50000
% Let's target 45000 RPM and see what energy we get
r = r_max;
w = W_max;
m = rho * pi * r^2 * w;
I = 0.5 * m * r^2;
omega_target = 45000 * 2 * pi / 60;  % Target 45000 RPM
E_at_target = 0.5 * I * omega_target^2;

iter = iter + 1;
fprintf('%4d | %9.4f | %9.4f | %8.2f | %9.5f | %12.1f | %8.0f | %9.2f\n', ...
    iter, r, w, m, I, omega_target, 45000, E_at_target/1000);
iterations = [iterations; iter, r, w, m, I, omega_target, 45000, E_at_target];

% Iteration 5: Energy is too high at 45000 RPM, reduce speed
omega_target = 35000 * 2 * pi / 60;
E_at_target = 0.5 * I * omega_target^2;

iter = iter + 1;
fprintf('%4d | %9.4f | %9.4f | %8.2f | %9.5f | %12.1f | %8.0f | %9.2f\n', ...
    iter, r, w, m, I, omega_target, 35000, E_at_target/1000);
iterations = [iterations; iter, r, w, m, I, omega_target, 35000, E_at_target];

% Iteration 6: Getting closer, fine tune
omega_target = 30000 * 2 * pi / 60;
E_at_target = 0.5 * I * omega_target^2;

iter = iter + 1;
fprintf('%4d | %9.4f | %9.4f | %8.2f | %9.5f | %12.1f | %8.0f | %9.2f\n', ...
    iter, r, w, m, I, omega_target, 30000, E_at_target/1000);
iterations = [iterations; iter, r, w, m, I, omega_target, 30000, E_at_target];

% Iteration 7: Let's find exact RPM needed for target energy
omega_final = sqrt(2 * E_target / I);
rpm_final = omega_final * 60 / (2*pi);
E_final = 0.5 * I * omega_final^2;

iter = iter + 1;
fprintf('%4d | %9.4f | %9.4f | %8.2f | %9.5f | %12.1f | %8.0f | %9.2f\n', ...
    iter, r, w, m, I, omega_final, rpm_final, E_final/1000);
iterations = [iterations; iter, r, w, m, I, omega_final, rpm_final, E_final];

fprintf('\n');

% Final design parameters
r_final = r_max;
w_final = W_max;
m_final = rho * pi * r_final^2 * w_final;
I_final = 0.5 * m_final * r_final^2;
omega_op = sqrt(2 * E_target / I_final);  % Operating angular velocity
rpm_op = omega_op * 60 / (2*pi);

fprintf('--- FINAL DESIGN (Part A) ---\n');
fprintf('Flywheel Radius: %.4f m (%.2f in)\n', r_final, r_final/0.0254);
fprintf('Flywheel Width: %.4f m (%.2f in)\n', w_final, w_final/0.0254);
fprintf('Flywheel Mass: %.2f kg\n', m_final);
fprintf('Moment of Inertia: %.6f kg.m^2\n', I_final);
fprintf('Operating Speed: %.0f RPM (%.1f rad/s)\n', rpm_op, omega_op);
fprintf('Energy Stored: %.2f kJ\n\n', E_target/1000);

%% Part B: Spin-up Time Calculation

% Using T = I * alpha, where alpha is angular acceleration
% alpha = T / I
% omega = alpha * t (starting from rest)
% t = omega / alpha = omega * I / T

alpha = T_brake / I_final;  % Angular acceleration [rad/s^2]
t_spinup = omega_op / alpha;  % Time to reach operating speed [s]

fprintf('--- SPIN-UP TIME (Part B) ---\n');
fprintf('Available Braking Torque: %.0f Nm\n', T_brake);
fprintf('Angular Acceleration: %.2f rad/s^2\n', alpha);
fprintf('Time to reach %.0f RPM: %.2f seconds\n\n', rpm_op, t_spinup);

% Verify with kinematics
omega_check = alpha * t_spinup;
fprintf('Verification: omega = alpha * t = %.1f rad/s (should be %.1f)\n\n', omega_check, omega_op);

%% Part C: Vehicle Velocity Gain Analysis

% Energy released from flywheel goes to vehicle kinetic energy
% E_flywheel = (1/2) * m_vehicle * (v_final^2 - v_initial^2)
% Solving for v_final:
% v_final = sqrt(v_initial^2 + 2*E_flywheel/m_vehicle)

% For different power levels
E_at_Pmin = P_min * t_delivery;
E_at_Pmax = P_max * t_delivery;

% Velocity gain at minimum power
v_final_min = sqrt(v_initial^2 + 2*E_at_Pmin/m_vehicle);
delta_v_min = v_final_min - v_initial;

% Velocity gain at maximum power
v_final_max = sqrt(v_initial^2 + 2*E_at_Pmax/m_vehicle);
delta_v_max = v_final_max - v_initial;

% At target energy
v_final_target = sqrt(v_initial^2 + 2*E_target/m_vehicle);
delta_v_target = v_final_target - v_initial;

fprintf('--- VELOCITY GAIN ANALYSIS (Part C) ---\n');
fprintf('Initial Velocity: %.2f m/s (%.0f km/h)\n', v_initial, v_initial*3.6);
fprintf('\nAt Minimum Power (%.0f kW):\n', P_min/1000);
fprintf('  Energy Released: %.1f kJ\n', E_at_Pmin/1000);
fprintf('  Final Velocity: %.2f m/s (%.1f km/h)\n', v_final_min, v_final_min*3.6);
fprintf('  Velocity Gain: %.2f m/s (%.1f km/h)\n', delta_v_min, delta_v_min*3.6);

fprintf('\nAt Maximum Power (%.0f kW):\n', P_max/1000);
fprintf('  Energy Released: %.1f kJ\n', E_at_Pmax/1000);
fprintf('  Final Velocity: %.2f m/s (%.1f km/h)\n', v_final_max, v_final_max*3.6);
fprintf('  Velocity Gain: %.2f m/s (%.1f km/h)\n', delta_v_max, delta_v_max*3.6);

fprintf('\nAt Target Energy (%.1f kJ):\n', E_target/1000);
fprintf('  Final Velocity: %.2f m/s (%.1f km/h)\n', v_final_target, v_final_target*3.6);
fprintf('  Velocity Gain: %.2f m/s (%.1f km/h)\n\n', delta_v_target, delta_v_target*3.6);

%% Part D: Angular Momentum

H = I_final * omega_op;  % Angular momentum [kg.m^2/s]

fprintf('--- ANGULAR MOMENTUM (Part D) ---\n');
fprintf('Angular Momentum at Operating Speed: %.2f kg.m^2/s\n', H);
fprintf('  = %.2f N.m.s\n\n', H);

%% Part E: Dimensioned Sketch of Flywheel

figure('Position', [100 100 1000 800]);

% Design with hub for gear attachment
r_hub = 0.03;           % Hub radius for gear attachment [m]
r_inner = 0.04;         % Inner radius (after hub) [m]
hub_height = 0.015;     % Hub protrusion height [m]

% Side view (cross-section)
subplot(2,2,1);
hold on;

% Main disk body
rectangle('Position', [-r_final*1000, -w_final*1000/2, 2*r_final*1000, w_final*1000], ...
    'FaceColor', [0.7 0.7 0.8], 'EdgeColor', 'k', 'LineWidth', 1.5);

% Hub (protrusion for gear attachment)
rectangle('Position', [-r_hub*1000, -w_final*1000/2-hub_height*1000, 2*r_hub*1000, hub_height*1000], ...
    'FaceColor', [0.6 0.6 0.7], 'EdgeColor', 'k', 'LineWidth', 1.5);
rectangle('Position', [-r_hub*1000, w_final*1000/2, 2*r_hub*1000, hub_height*1000], ...
    'FaceColor', [0.6 0.6 0.7], 'EdgeColor', 'k', 'LineWidth', 1.5);

% Center hole for shaft
rectangle('Position', [-10, -w_final*1000/2-hub_height*1000, 20, w_final*1000+2*hub_height*1000], ...
    'FaceColor', 'w', 'EdgeColor', 'k', 'LineWidth', 1);

% Dimension lines
% Diameter
plot([-r_final*1000, -r_final*1000], [w_final*1000/2+20, w_final*1000/2+30], 'k-', 'LineWidth', 1);
plot([r_final*1000, r_final*1000], [w_final*1000/2+20, w_final*1000/2+30], 'k-', 'LineWidth', 1);
plot([-r_final*1000, r_final*1000], [w_final*1000/2+25, w_final*1000/2+25], 'k-', 'LineWidth', 1);
plot([-r_final*1000, -r_final*1000+5], [w_final*1000/2+25, w_final*1000/2+22], 'k-', 'LineWidth', 1);
plot([-r_final*1000, -r_final*1000+5], [w_final*1000/2+25, w_final*1000/2+28], 'k-', 'LineWidth', 1);
plot([r_final*1000, r_final*1000-5], [w_final*1000/2+25, w_final*1000/2+22], 'k-', 'LineWidth', 1);
plot([r_final*1000, r_final*1000-5], [w_final*1000/2+25, w_final*1000/2+28], 'k-', 'LineWidth', 1);
text(0, w_final*1000/2+35, sprintf('ø%.1f mm (%.2f")', 2*r_final*1000, 2*r_final/0.0254), ...
    'HorizontalAlignment', 'center', 'FontSize', 9);

% Width
plot([r_final*1000+20, r_final*1000+30], [-w_final*1000/2, -w_final*1000/2], 'k-', 'LineWidth', 1);
plot([r_final*1000+20, r_final*1000+30], [w_final*1000/2, w_final*1000/2], 'k-', 'LineWidth', 1);
plot([r_final*1000+25, r_final*1000+25], [-w_final*1000/2, w_final*1000/2], 'k-', 'LineWidth', 1);
text(r_final*1000+40, 0, sprintf('%.1f mm\n(%.2f")', w_final*1000, w_final/0.0254), ...
    'HorizontalAlignment', 'left', 'FontSize', 9);

% Hub diameter
plot([-r_hub*1000, -r_hub*1000], [-w_final*1000/2-hub_height*1000-5, -w_final*1000/2-hub_height*1000-15], 'k-', 'LineWidth', 1);
plot([r_hub*1000, r_hub*1000], [-w_final*1000/2-hub_height*1000-5, -w_final*1000/2-hub_height*1000-15], 'k-', 'LineWidth', 1);
plot([-r_hub*1000, r_hub*1000], [-w_final*1000/2-hub_height*1000-10, -w_final*1000/2-hub_height*1000-10], 'k-', 'LineWidth', 1);
text(0, -w_final*1000/2-hub_height*1000-20, sprintf('Hub ø%.0f mm', 2*r_hub*1000), ...
    'HorizontalAlignment', 'center', 'FontSize', 8);

axis equal;
xlim([-180 180]);
ylim([-100 100]);
xlabel('Radial Position [mm]');
ylabel('Axial Position [mm]');
title('Side View (Cross-Section)');
grid on;

% Front view
subplot(2,2,2);
hold on;

% Draw concentric circles
theta = linspace(0, 2*pi, 100);

% Outer disk
fill(r_final*1000*cos(theta), r_final*1000*sin(theta), [0.7 0.7 0.8], 'EdgeColor', 'k', 'LineWidth', 1.5);

% Hub circle
fill(r_hub*1000*cos(theta), r_hub*1000*sin(theta), [0.6 0.6 0.7], 'EdgeColor', 'k', 'LineWidth', 1.5);

% Center hole
fill(10*cos(theta), 10*sin(theta), 'w', 'EdgeColor', 'k', 'LineWidth', 1);

% Bolt holes on hub (for gear attachment)
n_bolts = 6;
r_bolt_circle = 0.022;  % Bolt circle radius [m]
r_bolt = 0.003;         % Bolt hole radius [m]
for i = 1:n_bolts
    angle = (i-1) * 2*pi/n_bolts;
    x_bolt = r_bolt_circle*1000*cos(angle);
    y_bolt = r_bolt_circle*1000*sin(angle);
    fill(x_bolt + r_bolt*1000*cos(theta), y_bolt + r_bolt*1000*sin(theta), 'w', 'EdgeColor', 'k');
end

% Dimension for radius
plot([0, r_final*1000*cos(pi/4)], [0, r_final*1000*sin(pi/4)], 'k-', 'LineWidth', 1);
text(r_final*1000*cos(pi/4)*0.6, r_final*1000*sin(pi/4)*0.6+10, sprintf('R=%.1f mm', r_final*1000), ...
    'FontSize', 9, 'Rotation', 45);

axis equal;
xlim([-150 150]);
ylim([-150 150]);
xlabel('X Position [mm]');
ylabel('Y Position [mm]');
title('Front View');
grid on;

% 3D visualization
subplot(2,2,[3,4]);
hold on;

% Create cylinder for flywheel
[X, Y, Z] = cylinder(r_final*1000, 50);
Z = Z * w_final*1000 - w_final*1000/2;
surf(X, Y, Z, 'FaceColor', [0.7 0.7 0.8], 'EdgeColor', 'none', 'FaceAlpha', 0.8);

% Top and bottom caps
fill3(r_final*1000*cos(theta), r_final*1000*sin(theta), ones(size(theta))*w_final*1000/2, ...
    [0.7 0.7 0.8], 'EdgeColor', 'k');
fill3(r_final*1000*cos(theta), r_final*1000*sin(theta), -ones(size(theta))*w_final*1000/2, ...
    [0.7 0.7 0.8], 'EdgeColor', 'k');

% Hub cylinders
[Xh, Yh, Zh] = cylinder(r_hub*1000, 30);
Zh_top = Zh * hub_height*1000 + w_final*1000/2;
Zh_bot = -Zh * hub_height*1000 - w_final*1000/2;
surf(Xh, Yh, Zh_top, 'FaceColor', [0.6 0.6 0.7], 'EdgeColor', 'none');
surf(Xh, Yh, Zh_bot, 'FaceColor', [0.6 0.6 0.7], 'EdgeColor', 'none');

view(30, 25);
axis equal;
xlabel('X [mm]');
ylabel('Y [mm]');
zlabel('Z [mm]');
title('3D View of Flywheel');
light('Position', [1 1 1]);
lighting gouraud;
grid on;

% Add figure title (compatible with older MATLAB versions)
annotation('textbox', [0.5, 0.95, 0, 0], 'String', ...
    sprintf('KERS Flywheel Design - %s\nMass: %.2f kg, I: %.5f kg.m^2, Operating Speed: %.0f RPM', ...
    materials{material_choice}, m_final, I_final, rpm_op), ...
    'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', ...
    'EdgeColor', 'none', 'FitBoxToText', 'on');

%% Time-domain simulation plots

figure('Position', [150 150 1000 600]);

% Spin-up phase simulation
t_spin = linspace(0, t_spinup, 100);
omega_spin = alpha * t_spin;
E_spin = 0.5 * I_final * omega_spin.^2;

subplot(2,2,1);
plot(t_spin, omega_spin * 60/(2*pi), 'b-', 'LineWidth', 2);
xlabel('Time [s]');
ylabel('Speed [RPM]');
title('Spin-up Phase (Braking)');
grid on;
hold on;
plot(t_spinup, rpm_op, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
text(t_spinup*0.7, rpm_op*0.5, sprintf('t = %.2f s', t_spinup), 'FontSize', 10);

subplot(2,2,2);
plot(t_spin, E_spin/1000, 'r-', 'LineWidth', 2);
xlabel('Time [s]');
ylabel('Energy [kJ]');
title('Energy Storage During Spin-up');
grid on;

% Energy release phase (assuming constant power delivery)
t_release = linspace(0, t_delivery, 100);
P_avg = E_target / t_delivery;  % Average power
E_release = E_target - P_avg * t_release;
omega_release = sqrt(2 * E_release / I_final);

subplot(2,2,3);
plot(t_release, omega_release * 60/(2*pi), 'b-', 'LineWidth', 2);
xlabel('Time [s]');
ylabel('Speed [RPM]');
title('Energy Release Phase (Acceleration)');
grid on;

% Vehicle velocity during acceleration
v_accel = sqrt(v_initial^2 + 2*(E_target - E_release)/m_vehicle);

subplot(2,2,4);
plot(t_release, v_accel*3.6, 'g-', 'LineWidth', 2);
xlabel('Time [s]');
ylabel('Velocity [km/h]');
title('Vehicle Velocity During Acceleration');
grid on;
hold on;
plot(0, v_initial*3.6, 'ko', 'MarkerSize', 8, 'MarkerFaceColor', 'k');
plot(t_delivery, v_final_target*3.6, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
legend('Velocity', 'Start', 'End', 'Location', 'southeast');

% Add figure title
annotation('textbox', [0.5, 0.95, 0, 0], 'String', 'KERS System Time-Domain Simulation', ...
    'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', ...
    'EdgeColor', 'none', 'FitBoxToText', 'on');

%% Summary Output

fprintf('========================================\n');
fprintf('        DESIGN SUMMARY                  \n');
fprintf('========================================\n');
fprintf('Material: %s\n', materials{material_choice});
fprintf('Flywheel Diameter: %.2f in (%.1f mm)\n', 2*r_final/0.0254, 2*r_final*1000);
fprintf('Flywheel Width: %.2f in (%.1f mm)\n', w_final/0.0254, w_final*1000);
fprintf('Flywheel Mass: %.2f kg (%.2f lb)\n', m_final, m_final*2.205);
fprintf('Moment of Inertia: %.6f kg.m^2\n', I_final);
fprintf('Operating Speed: %.0f RPM\n', rpm_op);
fprintf('Energy Stored: %.2f kJ\n', E_target/1000);
fprintf('Spin-up Time: %.2f s\n', t_spinup);
fprintf('Angular Momentum: %.2f kg.m^2/s\n', H);
fprintf('Velocity Gain: %.1f km/h\n', delta_v_target*3.6);
fprintf('Estimated Cost: $%.2f\n', m_final * cost_per_kg);
fprintf('========================================\n');

%% Save figures
saveas(figure(1), 'Flywheel_Design_Drawing.png');
saveas(figure(2), 'KERS_Simulation.png');
fprintf('\nFigures saved to current directory.\n');
