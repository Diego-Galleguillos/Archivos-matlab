
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


N = 100


theta = zeros(3,1,200);

for i = 1:200
    Q = zeros(3,3);

    for j = 2:N
        Q = Q + [y(j-1); u(j-d-1); v(j)]*[y(j-1), u(j-d-1), v(j)];
    end

    R = zeros(3,1);

    for j = 2:N
        R = R + [y(j-1); u(j-d-1); v(j)]*[y(j)];
    end

    theta(:,:,i) = inv(Q)*R;

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
