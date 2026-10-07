function plot_aerodynamic_curves(alpha_deg_range, results, geom)
    % Plots final lift, moment, and stagnation trajectories
    
    chord_approx = max(geom.x) - min(geom.x);
    
    % --- 1. Plot Cl vs. Alpha ---
    figure('Position', [100, 100, 600, 500]); 
    plot(alpha_deg_range, results.Cl, 'ko', 'LineWidth', 1, 'MarkerSize', 3, 'MarkerFaceColor', 'w');
    grid on; axis square; 
    title('\textbf{Lift Coefficient ($C_l$) vs. $\alpha$}', 'Interpreter', 'latex', 'FontSize', 15);
    xlabel('Angle of Attack $\alpha$ [degrees]', 'Interpreter', 'latex');
    ylabel('Lift Coefficient ($C_l$)', 'Interpreter', 'latex');
    exportgraphics(gcf, 'cl.png', 'Resolution', 300);

    % --- 2. Plot Cm vs. Alpha ---
    figure('Position', [100, 100, 600, 500]); hold on;
    plot(alpha_deg_range, results.Cm_quarter, 'k-', 'LineWidth', 2, 'DisplayName', '$C_{m_{c/4}}$ (Quarter Chord)');
    plot(alpha_deg_range, results.Cm_half, 'ko', 'LineWidth', 1, 'MarkerSize', 3, 'MarkerFaceColor', 'w', 'DisplayName', '$C_{m_{c/2}}$ (Half Chord)');
    grid on; set(gca, 'GridAlpha', 0.3); axis square; 
    title('\textbf{Variation of Moment Coefficient ($C_m$) vs. $\alpha$}', 'Interpreter', 'latex', 'FontSize', 15);
    xlabel('Angle of Attack $\alpha$ [degrees]', 'Interpreter', 'latex', 'FontSize', 13);
    ylabel('Moment Coefficient ($C_m$)', 'Interpreter', 'latex', 'FontSize', 13);
    legend('Interpreter', 'latex', 'Location', 'best', 'FontSize', 12);
    exportgraphics(gcf, 'cm.png', 'Resolution', 300);
    hold off;

    % --- 3. Stagnation Point Analysis ---
    figure('Name', 'Stagnation Point Analysis', 'Position', [100, 100, 1200, 500]); 
    
    % Left side: Trajectory over x/c
    subplot(1,2,1); 
    Stag_X_smooth = smoothdata(results.Stag_X, 'gaussian', 10); 
    plot(alpha_deg_range, Stag_X_smooth ./ chord_approx, 'b-', 'LineWidth', 2);
    grid on; axis square; 
    title('\textbf{Stagnation Point Movement vs. $\alpha$}', 'Interpreter', 'latex', 'FontSize', 15);
    xlabel('Angle of Attack \alpha [deg]', 'FontSize', 11);
    ylabel('X Location (x/c)', 'FontSize', 11);
    
    % Right side: Visual Trajectory on Nose
    subplot(1,2,2); hold on; 
    fill(geom.x, geom.y, [0.8 0.8 0.8], 'EdgeColor', 'k', 'LineWidth', 1.5);
    scatter(results.Stag_X, results.Stag_Y, 30, alpha_deg_range, 'filled');
    c = colorbar; c.Label.String = '\alpha [deg]'; colormap(jet);
    grid on; axis equal;

    zoom_center_x = min(geom.x);
    zoom_width = 0.05; 
    xlim([zoom_center_x - 0.015, zoom_center_x + zoom_width]); 
    ylim([-zoom_width/1.5, zoom_width/1.5]); 
    title('\textbf{Visual Trajectory on Nose}', 'Interpreter', 'latex', 'FontSize', 15);
    xlabel('x [m]', 'FontSize', 11); ylabel('y [m]', 'FontSize', 11);
    exportgraphics(gcf, 'stag.png', 'Resolution', 300);
    hold off;
end