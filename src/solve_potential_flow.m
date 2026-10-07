function flow_data = solve_potential_flow(V_inf, alpha_deg, params, geom)
    % Computes surface velocity, pressure distributions, and theoretical lift
    
    alpha_rad = deg2rad(alpha_deg);
    b = params.b; e = params.e; beta = params.beta; a = params.a; z_o = params.z_o;
    
    r_surf = b .* (1 + e .* (1 - cos(geom.theta)) + beta .* sin(geom.theta));
    z_surf = (r_surf .* cos(geom.theta)) + 1i*(r_surf .* sin(geom.theta));
    
    z_prime_surf = z_surf - z_o;
    [theta_prime_surf, ~] = cart2pol(real(z_prime_surf), imag(z_prime_surf));
    
    v_theta_prime_surf = -2 * V_inf * (sin(theta_prime_surf - alpha_rad) + sin(alpha_rad + beta));
    denominator = 1 + (b./r_surf).^4 - 2*(b./r_surf).^2 .* cos(2*geom.theta);
    
    V1_surf = sqrt((v_theta_prime_surf.^2) ./ denominator); 
    V1_surf(1) = V_inf * cos(alpha_rad + beta); 
    V1_surf(end) = V_inf * cos(alpha_rad + beta); 
    
    Cp_surf = 1 - (V1_surf / V_inf).^2;
    Cl = 2 * pi * (1 + e) * sin(alpha_rad + beta);
    Lift = 4 * pi * V_inf^2 * a * sin(alpha_rad + beta);
    
    flow_data = struct('V1_surf', V1_surf, 'Cp_surf', Cp_surf, 'Cl', Cl, 'Lift', Lift);
end