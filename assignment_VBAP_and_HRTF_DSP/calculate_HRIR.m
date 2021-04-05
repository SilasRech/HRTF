function [HRIR, e] = calculate_HRIR(x, y, N, mu_0, theta, r)

    epsilon = 1e-10;
    mdist = 2;
    k_360 = length(x);
    P = size(y, 2);
    HRIR = zeros(length(theta),N,P);
    
    theta = mod(theta + 180, 360);
    start_theta = theta - 45;
    start_theta(start_theta < 0) = 0;
    
    %Calculate Start Sample
    k_start = floor((start_theta) / 360 * k_360);
    k_start(k_start < N) = N;
    
    %Calculate Stop Sample
    k_stop = floor((theta) / 360 * k_360);
    k_stop(k_stop < N) = N;
    
    for m = 1:length(theta)
        HRIR_one = zeros(N, P);
        e = zeros(k_360, P);
        for k = k_start(m) : k_stop(m) 
            x_vec = x(k : -1 : k-N+1);
            e(k,:) = y(k,:) - x_vec.' * HRIR_one;
            HRIR_one = HRIR_one + mu_0 / (x_vec.' * x_vec + epsilon) * x_vec * e(k, :);
        end
        HRIR(m, :, :) = HRIR_one;
    end
end

