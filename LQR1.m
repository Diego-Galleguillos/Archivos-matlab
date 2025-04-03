clc; clear; close all;

% Parámetros del modelo
GB = 100; IB = 1.5; VL = 120;
p2 = 20e-3; p3 = 13e-6; p4 = 5/54;

% Matrices del sistema linealizado
A = [0  -GB   0;
      0   -p2  p3;
      0    0  -p4];

B =   [0   1;
        0  0;
        1/VL  0];

C = [1 0 0];  % Observamos solo la glucosa
D = 0;

% Definimos la penalización del LQR
Q = diag([100, 1, 1]);  % Penaliza el error de las variables de estado
R = 100;               % Penaliza la insulina exógena (variable manipulada)

% Calculamos la ganancia LQR
K = lqr(A, B, Q, R);

% Simulación con dos condiciones iniciales
tspan = [0 200];
CI1 = [500; 0.1; 3];  % Estado inicial 1
CI2 = [100; 0; 2];  % Estado inicial 2


Ac = A - B * K;
Bc = B; % Sin perturbaciones
Cc = C;
Dc = D;

sys_cl = ss(Ac, Bc, Cc, Dc);

% Simulación de la respuesta
[t1, y1] = initial(sys_cl, CI1, tspan);
[t2, y2] = initial(sys_cl, CI2, tspan);

% Graficar los resultados
figure;
plot(y1, t1, 'b', y2, t2, 'r--', 'LineWidth', 1.5);
xlabel('Tiempo (min)');
ylabel('Glucosa (mg/dL)');
legend('Condición 1', 'Condición 2');
title('Respuesta del sistema con LQR');
grid on;