% y(t)=ay(t-1)+bu(t-d-1)+cv(t), en que a=0,9 ; b=0,5; c=0,1; d=0.

a = 0.9;
b= 0.5;
c = 0.1;
d = 0

% Define the standard deviation of the Gaussian noise
sigma = 1;

y = zeros(400, 1);
u = sigma * randn(size(y));

for i = 2:400

    y(i) = a*y(i-1) + b*u(i-d-1)

end

N = 100


theta = zeros(2,1,200);

for i = 1:200
    Q = zeros(2,2);

    for j = 2:N
        Q = Q + [y(j-1); u(j-d-1)]*[y(j-1), u(j-d-1)];
    end

    R = zeros(2,1);

    for j = 2:N
        R = R + [y(j-1); u(j-d-1)]*[y(j)];
    end

    theta(:,:,i) = inv(Q)*R;

end

a_estimado = mean(theta(1,:,:))
b_estimado = mean(theta(2,:,:))

y2 = zeros(400, 1);
for i = 200:400

    y2(i) = a_estimado*y2(i-1) + b_estimado*u(i-d-1);

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


figure;
plot(squeeze(theta(1,1,:)))
hold on
yline(a, '--r', 'True a')
title('Evolución de a estimado')
xlabel('Iteración')
ylabel('a estimado')
grid on

figure;
plot(squeeze(theta(2,1,:)))
hold on
yline(b, '--r', 'True b')
title('Evolución de b estimado')
xlabel('Iteración')
ylabel('b estimado')
grid on




