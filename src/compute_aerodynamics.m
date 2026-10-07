function aero_data = compute_aerodynamics(chord, flow_data, geom)
    % Calculates aerodynamic moments and locates the stagnation point
    
    [~, max_idx] = max(flow_data.Cp_surf);
    Stag_X = geom.x(max_idx);
    Stag_Y = geom.y(max_idx);
    
    Cp_upper = flow_data.Cp_surf(1:geom.le_idx);
    Cp_lower = flow_data.Cp_surf(geom.le_idx:end);
    cp_upper_sorted = Cp_upper(geom.sort_idx_upper);
    
    x_common = linspace(-chord/2, chord/2, 200);
    cp_upper_interp = interp1(geom.x_upper_sorted, cp_upper_sorted, x_common);
    cp_lower_interp = interp1(geom.x_lower, Cp_lower, x_common);
    
    integrand_quarter = (cp_lower_interp - cp_upper_interp) .* (x_common - (-chord/4));
    integrand_half = (cp_lower_interp - cp_upper_interp) .* x_common;
    
    Cm_quarter = -(1/chord^2) * trapz(x_common, integrand_quarter);
    Cm_half = -(1/chord^2) * trapz(x_common, integrand_half);
    
    aero_data = struct('Stag_X', Stag_X, 'Stag_Y', Stag_Y, 'Cm_quarter', Cm_quarter, 'Cm_half', Cm_half);
end