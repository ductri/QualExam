W = rand(10, 5);
H = rand(5, 100);
H = H./sum(H);
X = W*H;

L = rand(5, 5);
L(:, 1) = ones(5, 1)/sqrt(5);
for i=2:5
    L(:, i) = L(:, i) - sum((L(:, i)'*L(:,1:i-1)).*L(:, 1:i-1), 2);
    L(:, i) = L(:, i)/norm(L(:, i), 2);
end

Q = rand(5, 5);
Q = Q./sum(Q);
What = W*Q^-1;
Hhat = Q*H;
norm(X - W*H, 'fro')
norm(X - What*Hhat, 'fro')
sum(H)
sum(Hhat)
sum(H<0, 'all')
