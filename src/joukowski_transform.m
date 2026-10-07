function [geom, params] = joukowski_transform(chord, max_camber_ratio, max_thickness_ratio, N_points)
    % Calculates transformation parameters and generates airfoil geometry
    
    b = chord / 4;
    e = max_thickness_ratio / 1.3;
    beta = 2 * max_camber_ratio;
    a = b * (1 + e);
    x_o = -b * e;
    y_o = a * beta; 
    z_o = x_o + 1i*y_o;
    
    params = struct('b', b, 'e', e, 'beta', beta, 'a', a, 'x_o', x_o, 'y_o', y_o, 'z_o', z_o);
    
    theta = linspace(0, 2*pi, N_points);
    x_airfoil = 2 * b * cos(theta);
    y_airfoil = 2 * b * e * (1 - cos(theta)) .* sin(theta) + 2 * b * beta * sin(theta).^2;
    
    [~, le_idx] = min(x_airfoil);
    x_upper = x_airfoil(1:le_idx); 
    y_upper = y_airfoil(1:le_idx);
    
    [x_upper_sorted, sort_idx_upper] = sort(x_upper);
    
    geom = struct('x', x_airfoil, 'y', y_airfoil, 'theta', theta, 'le_idx', le_idx, ...
                  'x_upper_sorted', x_upper_sorted, 'y_upper_sorted', y_upper(sort_idx_upper), ...
                  'x_lower', x_airfoil(le_idx:end), 'y_lower', y_airfoil(le_idx:end), ...
                  'sort_idx_upper', sort_idx_upper);
end