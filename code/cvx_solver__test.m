%% Clear all things
% clc; clear; close all; path(pathdef);
addpath('~/code/matlab/common/prob_tools')
addpath('~/code/matlab/sdmmv_clean/')
addpath('~/code/matlab/sdmmv_clean/fw_core')
addpath('~/code/matlab/common/prox_ops')
addpath('~/code/matlab/common/PGD')

% M=10; N=50; K=3;
alpha = 0.5*ones(K, 1);

W = rand(M, K);
H = zeros(K, N);
H(:, 1:K) = eye(K);
H(:, K+1:end) = dirichlet_rnd(alpha, N-K);
Y = W*H;
SNR = 10^(snr/10);
noise = randn(size(Y)); 
sigma2 = sum(vecnorm(Y, 2, 1).^2) / M / N / SNR;
noise = sqrt(sigma2)*noise;
X = Y + noise;
indices = randperm(N);
X = X(:, indices);
H = H(:, indices);
r_pure_pixel_set = [];
pure_pixel_set = 1:K;
for ii=1:numel(pure_pixel_set)
    r_pure_pixel_set(end+1) = find(indices == pure_pixel_set(ii));
end
pure_pixel_set = r_pure_pixel_set;

C_hat_cvx = cvx_solver(X, 0.5, K);
fprintf('CVX Obj: %e\n', norm(X - X*C_hat_cvx, 'fro')^2);

