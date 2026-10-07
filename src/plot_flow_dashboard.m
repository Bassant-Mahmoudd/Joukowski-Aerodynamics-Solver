function plot_flow_dashboard(V_inf, alpha_deg, chord, params, geom, flow_data, aero_data)
    % Extracts grid mesh, computes inverse mapping, and plots the dashboard
    
    % 1. Extract necessary variables
    b = params.b; a = params.a; z_o = params.z_o; beta = params.beta;
    alpha_rad = deg2rad(alpha_deg);
    sin_beta_prime = sin(alpha_rad + beta);
    
    % 2. Generate Flow Field Grid
    grid_points = 400;
    x_start = -1.5*chord; x_end = 1.5*chord;
    y_start = -1.5*chord; y_end = 1.5*chord;
    x_grid = linspace(x_start, x_end, grid_points);
    y_grid = linspace(y_start, y_end, grid_points);
    [X1_grid, Y1_grid] = meshgrid(x_grid, y_grid); 
    U1_grid = zeros(size(X1_grid));
    V1_grid = zeros(size(Y1_grid)); 
    
    % 3. Inverse Joukowski Mapping & Velocity Field Calculation
    for m = 1:grid_points
        for j = 1:grid_points
            Z1 = X1_grid(m,j) + 1i*Y1_grid(m,j);
            sqrt_term = sqrt(Z1^2 - 4*b^2);
            z_sol1 = (Z1 + sqrt_term) / 2;
            z_sol2 = (Z1 - sqrt_term) / 2;
            
            if abs(z_sol1) > abs(z_sol2)
                z = z_sol1;
            else
                z = z_sol2;  
            end
            
            [theta, r] = cart2pol(real(z), imag(z));   
            z_prime = z - z_o;
            [theta_prime, r_prime] = cart2pol(real(z_prime), imag(z_prime));  
            
            v_r_prime = V_inf * (1 - (a/r_prime)^2) * cos(theta_prime - alpha_rad);
            v_theta_prime = -V_inf * (1 + (a/r_prime)^2) * sin(theta_prime - alpha_rad) ...
                            - (V_inf * 2 * a * sin_beta_prime) / r_prime; 
            
            A = v_r_prime * cos(theta_prime) - v_theta_prime * sin(theta_prime);
            B = -(v_r_prime * sin(theta_prime) + v_theta_prime * cos(theta_prime));
            C = 1 - (b/r)^2 * cos(2*theta);
            D = (b/r)^2 * sin(2*theta);
            
            complex_velocity = (A + 1i*B) / (C + 1i*D);
            U1_grid(m,j) = real(complex_velocity);  
            V1_grid(m,j) = -imag(complex_velocity); 
        end
    end 
    
    % 4. Mask the inside of the airfoil
    in = inpolygon(X1_grid, Y1_grid, geom.x, geom.y);
    U1_grid(in) = NaN;
    V1_grid(in) = NaN;
    
    V_mag_grid = sqrt(U1_grid.^2 + V1_grid.^2);
    Cp_grid = 1 - (V_mag_grid / V_inf).^2;
    
    % 5. Separate Upper/Lower Surface Data for Plotting
    Cp_upper = flow_data.Cp_surf(1:geom.le_idx);
    Cp_lower = flow_data.Cp_surf(geom.le_idx:end);
    cp_upper_sorted = Cp_upper(geom.sort_idx_upper);
    
    V1_upper = flow_data.V1_surf(1:geom.le_idx);
    V1_lower = flow_data.V1_surf(geom.le_idx:end);
    V1_upper_sorted = V1_upper(geom.sort_idx_upper);
    
    % 6. Create Dashboard Figure
    figure('Name', ['Simulation Dashboard: Alpha = ' num2str(alpha_deg)], ...
           'Units', 'normalized', 'Position', [0.1 0.1 0.8 0.8]); 
    col_upper = [0 0.4470 0.7410]; 
    col_lower = [0.8500 0.3250 0.0980]; 
    
    % Subplot 1: Cp Distribution
    subplot(2,3,1); hold on;
    plot(geom.x_upper_sorted, cp_upper_sorted, 'Color', col_upper, 'LineWidth', 2);
    plot(geom.x_lower, Cp_lower, 'Color', col_lower, 'LineWidth', 2);
    set(gca, 'YDir','reverse'); grid on; set(gca, 'GridAlpha', 0.3);
    xlabel('x [m]', 'FontWeight', 'bold'); ylabel('C_p', 'FontWeight', 'bold'); 
    title('Surface C_p Distribution'); legend('Upper Surface', 'Lower Surface', 'Location', 'best');
    
    % Subplot 2: Velocity Distribution 
    subplot(2,3,2); hold on;
    plot(geom.x_upper_sorted, V1_upper_sorted/V_inf, 'Color', col_upper, 'LineWidth', 2);
    plot(geom.x_lower, V1_lower/V_inf, 'Color', col_lower, 'LineWidth', 2);
    grid on; set(gca, 'GridAlpha', 0.3);
    xlabel('x [m]', 'FontWeight', 'bold'); ylabel('V/V_{\infty}', 'FontWeight', 'bold'); 
    title('Surface Velocity Distribution');
    
    % Subplot 3: Streamlines
    subplot(2,3,3);
    streamslice(X1_grid, Y1_grid, U1_grid, V1_grid, 2); 
    hold on; fill(geom.x, geom.y, 'k'); hold off;
    axis equal; axis([x_start x_end y_start y_end]); title('Flow Streamlines');
    
    % Subplot 4: Pressure Contours
    subplot(2,3,4);
    contourf(X1_grid, Y1_grid, Cp_grid, 100, 'LineColor', 'none');
    hold on; fill(geom.x, geom.y, 'k'); hold off;
    axis equal; axis([x_start x_end y_start y_end]);
    colormap(gca, jet); c = colorbar; c.Label.String = 'C_p'; title('Pressure Field (C_p)');

    % Subplot 5: Velocity Contours
    subplot(2,3,5);
    contourf(X1_grid, Y1_grid, V_mag_grid, 100, 'LineColor', 'none');
    hold on; fill(geom.x, geom.y, 'k'); hold off;
    axis equal; axis([x_start x_end y_start y_end]);
    colormap(gca, jet); c = colorbar; c.Label.String = 'V'; title('Velocity Magnitude Field');

    % Subplot 6: Simulation Info Box 
    subplot(2,3,6); axis off; 
    text(0, 0.7, sprintf('\\textbf{Angle of Attack:} $\\alpha = %.1f^\\circ$', alpha_deg), 'Interpreter', 'latex', 'FontSize', 16);
    text(0, 0.5, sprintf('\\textbf{Lift Coeff} ($C_l$): %.3f', flow_data.Cl), 'Interpreter', 'latex', 'FontSize', 14);
    text(0, 0.35, sprintf('\\textbf{Moment Coeff} ($C_{m_{c/4}}$): %.3f', aero_data.Cm_quarter), 'Interpreter', 'latex', 'FontSize', 14);
    text(0, 0.2, sprintf('\\textbf{Max Velocity:} %.2f $\\times V_{\\infty}$', max(V_mag_grid(:))/V_inf), 'Interpreter', 'latex', 'FontSize', 14);

    sgtitle(['Flow Simulation Results for \alpha = ' num2str(alpha_deg) '^{\circ}'], 'FontSize', 16, 'FontWeight', 'bold');
    exportgraphics(gcf, ['dash' num2str(alpha_deg) '.png'], 'Resolution', 300);
end