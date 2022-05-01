function [C] = cvx_solver(X, lambda, K) 
    N = size(X, 2);
    cvx_precision('low')
    cvx_begin
        variable C(N, N)
        minimize(obj(X, lambda, C))
    cvx_end
end

function [out] = obj(X, lambda, C) 
    out = 0.5*square_pos(norm(X - X*C, 'fro')) + lambda*sum(norms(C, Inf, 1));
end

