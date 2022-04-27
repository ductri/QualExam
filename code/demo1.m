%% Clear all things
clc; clear; close all; path(pathdef);
addpath('~/code/matlab/common/prob_tools')
addpath('~/code/matlab/sdmmv_clean/')
addpath('~/code/matlab/sdmmv_clean/fw_core')
addpath('~/code/matlab/common/prox_ops')
addpath('~/code/matlab/common/PGD')


M=10; N=50; K=3;
alpha = 0.5*ones(K, 1);


W = rand(M, K);
H = zeros(K, N);
H(:, 1:K) = eye(K);
H(:, K+1:end) = dirichlet_rnd(alpha, N-K);
Y = W*H;
X = Y;
indices = randperm(N);
X = X(:, indices);
H = H(:, indices);
r_pure_pixel_set = [];
pure_pixel_set = 1:K;
for ii=1:numel(pure_pixel_set)
    r_pure_pixel_set(end+1) = find(indices == pure_pixel_set(ii));
end
pure_pixel_set = r_pure_pixel_set;

[C_hat_pgd, pgd_tracking] = pgd_solver(X);
fprintf('PGD Obj: %e\n', norm(X - X*C_hat_pgd, 'fro')^2);
% figure();
% semilogy(pgd_tracking.obj);

% ==============================
% FRANK-WOLFE
fw_tic = tic;
options = struct;
options.maxIters = 1000;
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
plot(fw_tracking.InnerTracking.nnz, 'DisplayName',  'FW')
hold on
plot(pgd_tracking.nnz, 'DisplayName',  'Projected GD')
legend
xlabel('Iters')
ylabel('nnz($\textbf{C}$)', 'Interpreter',  'latex')

path_to_file = 'nnz_fw_pgd.dat';
data = [[1:numel(pgd_tracking.nnz)]' pgd_tracking.nnz(:) fw_tracking.InnerTracking.nnz(:)];
data = array2table(data);
data.Properties.VariableNames(1:3) = {'iter', 'PGD', 'FW'};
writetable(data, path_to_file, 'Delimiter',  ' ');


figure();
scatter([1:N],vecnorm(C_hat, 'inf', 2))
vecnormC = vecnorm(C_hat, 'inf', 2);
vecnormC = vecnormC(:);
hold on
xline(pure_pixel_set, '--r');
title('FW')

path_to_file = 'fw_C.dat';
data = [[1:size(C_hat, 1)]' vecnorm(C_hat, 'inf', 2)];
data = array2table(data);
data.Properties.VariableNames(1:2) = {'index', 'norm'};
writetable(data, path_to_file, 'Delimiter',  ' ');

path_to_file = 'fw_C_pure_pixel.dat';
data = [pure_pixel_set(:) vecnormC(pure_pixel_set)];
data = array2table(data);
data.Properties.VariableNames(1:2) = {'index', 'norm'};
writetable(data, path_to_file, 'Delimiter',  ' ');

figure();
scatter([1:N],vecnorm(C_hat_pgd, 'inf', 2))
vecnormC = vecnorm(C_hat_pgd, 'inf', 2);
vecnormC = vecnormC(:);
hold on
xline(pure_pixel_set, '--r');
title('PGD')

path_to_file = 'pgd_C.dat';
data = [[1:size(C_hat_pgd, 1)]' vecnorm(C_hat_pgd, 'inf', 2)];
data = array2table(data);
data.Properties.VariableNames(1:2) = {'index', 'norm'};
writetable(data, path_to_file, 'Delimiter',  ' ');

path_to_file = 'pgd_C_pure_pixel.dat';
data = [pure_pixel_set(:) vecnormC(pure_pixel_set)];
data = array2table(data);
data.Properties.VariableNames(1:2) = {'index', 'norm'};
writetable(data, path_to_file, 'Delimiter',  ' ');

