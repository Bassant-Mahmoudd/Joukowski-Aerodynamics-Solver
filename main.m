% Main Execution Script for Joukowski Airfoil Flow Simulation
clear; clc; close all;
addpath('src'); % Add source folder to path

% 1. Input Parameters
V_inf = 15;                     
chord = 0.1;                    
max_camber_ratio = 0.03;        
max_thickness_ratio = 0.06;     
N_points = 401;                 
alpha_deg_range = -5:0.1:15;      
angles_for_plots = [-5, 0, 5, 10, 15]; 

% 2. Geometry Generation
[airfoil_geom, params] = joukowski_transform(chord, max_camber_ratio, max_thickness_ratio, N_points);

% 3. Pre-allocate Results
num_alphas = length(alpha_deg_range);
results = struct('Cl', zeros(1, num_alphas), 'Lift', zeros(1, num_alphas), ...
                 'Cm_quarter', zeros(1, num_alphas), 'Cm_half', zeros(1, num_alphas), ...
                 'Stag_X', zeros(1, num_alphas), 'Stag_Y', zeros(1, num_alphas));

% 4. Main Solver Loop
for i = 1:num_alphas
    alpha_deg = alpha_deg_range(i);
    
    % Core Mathematical Solvers
    flow_data = solve_potential_flow(V_inf, alpha_deg, params, airfoil_geom);
    aero_data = compute_aerodynamics(chord, flow_data, airfoil_geom);
    
    % Store Iteration Results
    results.Cl(i) = flow_data.Cl;
    results.Lift(i) = flow_data.Lift;
    results.Cm_quarter(i) = aero_data.Cm_quarter;
    results.Cm_half(i) = aero_data.Cm_half;
    results.Stag_X(i) = aero_data.Stag_X;
    results.Stag_Y(i) = aero_data.Stag_Y;
    
    % Plot Flow Dashboards for Target Angles
    if ismember(alpha_deg, angles_for_plots)
        plot_flow_dashboard(V_inf, alpha_deg, chord, params, airfoil_geom, flow_data, aero_data);
    end
end

% 5. Final Characteristic Plots
plot_aerodynamic_curves(alpha_deg_range, results, airfoil_geom);