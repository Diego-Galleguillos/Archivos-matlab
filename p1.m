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

figure;
plot(y)

figure;
plot(u)