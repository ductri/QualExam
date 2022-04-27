%% Clear all things
clc; clear; close all; path(pathdef);
addpath('~/code/matlab/common/prob_tools')
addpath('~/code/matlab/sdmmv_clean/')
addpath('~/code/matlab/sdmmv_clean/fw_core')
addpath('~/code/matlab/common/prox_ops')
addpath('~/code/matlab/common/PGD')


M=40; N=50; K=10; snr=35;
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
% X = Y;
indices = randperm(N);
X = X(:, indices);
H = H(:, indices);
r_pure_pixel_set = [];
pure_pixel_set = 1:K;
for ii=1:numel(pure_pixel_set)
    r_pure_pixel_set(end+1) = find(indices == pure_pixel_set(ii));
end
pure_pixel_set = r_pure_pixel_set;

% [C_hat_pgd, pgd_tracking] = pgd_solver(X);
% fprintf('PGD Obj: %e\n', norm(X - X*C_hat_pgd, 'fro')^2);
% figure();
% semilogy(pgd_tracking.obj);

% ==============================
% FRANK-WOLFE
fw_tic = tic;
options = struct;
options.maxIters = 100;
options.verbose = 0;
options.lambda = 0;
options.debug = 0;
options.N = K;
options.backend = 'matlab';
options.dualGapThreshold=0;
options.epsilon = 1e-5;
[C_hat, fw_tracking] = fw(X, options);
[~, Lambda_hat] = maxk(vecnorm(C_hat, Inf, 2), K, 1);
fprintf('FW Obj: %e\n', norm(X - X*C_hat, 'fro')^2);


figure();
scatter([1:N],vecnorm(C_hat, 'inf', 2))
vecnormC = vecnorm(C_hat, 'inf', 2);
vecnormC = vecnormC(:);
hold on
xline(pure_pixel_set, '--r');
title('FW')

path_to_file = sprintf('demo2_%d_C.dat', snr);
data = [[1:size(C_hat, 1)]' vecnorm(C_hat, 'inf', 2)];
data = array2table(data);
data.Properties.VariableNames(1:2) = {'index', 'norm'};
writetable(data, path_to_file, 'Delimiter',  ' ');

path_to_file = sprintf('demo2_%d_pure_pixel.dat', snr);
data = [pure_pixel_set(:) vecnormC(pure_pixel_set)];
data = array2table(data);
data.Properties.VariableNames(1:2) = {'index', 'norm'};
writetable(data, path_to_file, 'Delimiter',  ' ');

% path_to_file = 'pgd_C.dat';
% data = [[1:size(C_hat_pgd, 1)]' vecnorm(C_hat_pgd, 'inf', 2)];
% data = array2table(data);
% data.Properties.VariableNames(1:2) = {'index', 'norm'};
% writetable(data, path_to_file, 'Delimiter',  ' ');

% path_to_file = 'pgd_C_pure_pixel.dat';
% data = [pure_pixel_set(:) vecnormC(pure_pixel_set)];
% data = array2table(data);
% data.Properties.VariableNames(1:2) = {'index', 'norm'};
% writetable(data, path_to_file, 'Delimiter',  ' ');

