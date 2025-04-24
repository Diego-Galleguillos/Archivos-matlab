% y(t)=ay(t-1)+bu(t-d-1)+cv(t), en que a=0,9 ; b=0,5; c=0,1; d=0.

a = 0.9;
b= 0.5;
c = 0.1;
d = 0;

% Define the standard deviation of the Gaussian noise
sigma = 1;

y = zeros(400, 1);
u = sigma * randn(size(y));
v = sigma * randn(400,1);
for i = 2:400

    y(i) = a*y(i-1) + b*u(i-d-1)+c*v(i);

end

% ϕT[k] = (y[k −1],u[k −1], ˆ e[k − 1])
%  e[k] = y[k] −ϕT[k]θ[k]
theta = zeros(3,1,200);
phi = zeros(3,1,200);
e = zeros(200);

P = zeros(3,3,200);
P(:,:,1) = 1e6 * eye(3); 
lambda = 0.9; %cambiar lambda aca

for i = 2:200
    phi(:,1,i) = [y(i-1); u(i-1); e(i-1)];
    e(i) = y(i) - phi(:,1,i)'*theta(:,1,i-1);

    P(:,:,i) = (1/lambda)*(P(:,:,i-1) - (P(:,:,i-1)*phi(:,1,i)*phi(:,1,i)'*P(:,:,i-1))/(lambda + phi(:,1,i)'*P(:,:,i-1)*phi(:,1,i)));

    H_k = (P(:,:,i-1)*phi(:,1,i)/(lambda+phi(:,1,i)'*P(:,:,i-1)*phi(:,1,i)));

    theta(:,1,i) = theta(:,1,i-1) + H_k*(y(i) -phi(:,1,i)'*theta(:,1,i-1));
end

% Gráficas de convergencia
figure;
plot(squeeze(theta(1,1,:)))
hold on; yline(a,'--r','a real');
title('Evolución de a estimado')
xlabel('Iteración'); ylabel('a'); grid on;

figure;
plot(squeeze(theta(2,1,:)))
hold on; yline(b,'--r','b real');
title('Evolución de b estimado')
xlabel('Iteración'); ylabel('b'); grid on;

figure;
plot(squeeze(theta(3,1,:)))
hold on; yline(c,'--r','c real');
title('Evolución de c (ganancia de ruido) estimado')
xlabel('Iteración'); ylabel('c'); grid on;

a_estimado = mean(theta(1,:,:))
b_estimado = mean(theta(2,:,:))
c_estimado = mean(theta(3,:,:))


y2 = zeros(400, 1);
for i = 200:400

    y2(i) = a_estimado*y2(i-1) + b_estimado*u(i-d-1)+c_estimado*v(i);

end

figure;
plot(y, 'b', 'DisplayName', 'y1 (original)');
hold on;
plot(y2, 'r', 'DisplayName', 'y2 (estimada)');
legend;
title('y1 vs y2 (estimada)');
xlabel('Iteration');
ylabel('Value');
grid on;
hold off;
