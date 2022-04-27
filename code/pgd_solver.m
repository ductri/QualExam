function [x_hat, tracking] = pgd_solver(X, varargin) 
% ----------------------------------------------------------------------
% 
% Summary of this function goes here
% Detailed explanation goes here


% Author: Tri Nguyen (nguyetr9@oregonstate.edu)

% ----------------------------------------------------------------------
    
    % Check the options structure.
    p = inputParser;
    p.addOptional('verbose', 0);
    p.addOptional('debug', 0);
    p.addOptional('lambda', 0);
    p.KeepUnmatched = true;
    p.parse(varargin{:});
    options = p.Results;

    XT = X';
    g_fn = @(C) X'*(X*C - X) + options.lambda*reg_grad(X, XT, C);

    ops = struct;
    ops.debug = false;
    ops.verbose = false;
    ops.max_iters = 1000;
    ops.f_fn = @(C)  0.5*norm(X - X*C, 'fro')^2;

    p_fn = @(x, l) proj_simplex_matrix(x);
    step_size = 1/eigs(X'*X, 1)*2;
    init_point = rand(size(X, 2));
    init_point = init_point./sum(init_point, 1);
    % [x_hat, tracking] = pgd(g_fn, p_fn, step_size, init_point, ops);

    [x_hat, tracking] = pgd_fista(g_fn, p_fn, step_size, init_point, ops);
end

function [x] = proj(x, lambda) 
    x(x<0) = 0;
end


function [G] = reg_grad(X, XT, C, varargin) 
    epsilon = 1e-6;
    L = size(C, 1);
    sumCe1 = zeros(L, 1);
    sumCe2 = zeros(L, 1);
    G = zeros(L, L);
    for k=1:L
        muRowC = C(k, :) ./ epsilon;
        maxMuRowC = max(muRowC);
        muRowC = muRowC - maxMuRowC;
        sumCe1(k) = sum(full(exp(muRowC)));
        sumCe2(k) = maxMuRowC;
    end
    for k=1:L
        ck = C(:, k);
        G(:, k) = exp(ck./epsilon - sumCe2) ./ sumCe1;
    end
end

