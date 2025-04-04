clc; clear; close all;

% Parámetros del modelo
GB = 100; IB = 1.5; VL = 120;
p2 = 20e-3; p3 = 13e-6; p4 = 5/54;

% Matrices del sistema en lazo abierto
A = [0  -GB   0;
      0   -p2  p3;
      0    0  -p4];

B =   [  1;
          0;
          0];

C = [1 0 0];  % Observamos solo la glucosa
D = [0];  % No hay ganancia directa

sys_open = ss(A, B, C, D);  % Sistema sin control

% Definir tiempo y condiciones iniciales
tspan = 0:0.05:100;
CI = [120; 0.1; 1];  % Estado inicial

% Generación de perturbaciones estocásticas controladas
rng(42); % Fijar semilla para reproducibilidad
insulina = zeros(size(tspan));  % Insulina aleatoria, siempre positiva
ingesta_glucosa = abs(randn(size(tspan)) * 7);  % Ingesta aleatoria, siempre positiva

u = [ingesta_glucosa]; % Señales de entrada

% Simulación de la respuesta sin ruido
[y, t, x] = lsim(sys_open, u, tspan, CI);

% Agregar ruido a la medición
R = 5;  % Varianza del ruido de medición
ruido_medicion = sqrt(R) * randn(size(y)); % Ruido gaussiano
y_noisy = y + ruido_medicion; % Señal medida con ruido

% Graficar resultados
figure;
plot(t, y, 'b', 'LineWidth', 1.5);
hold on;
plot(t, y_noisy, 'r', 'LineWidth', 1);
xlabel('Tiempo (min)');
ylabel('Glucosa (mg/dL)');
title('Respuesta del sistema con ruido en la medición');
legend('Salida real', 'Salida con ruido');
grid on;

% Filtro de Kalman
Q = 1;  % Covarianza del ruido del proceso
[kalmf, L, P] = kalman(sys_open, Q, R);

% Simulación con el filtro de Kalman usando la salida con ruido
[y_est, t, x_est] = lsim(kalmf, y_noisy, tspan, CI);

figure;
plot(t, y_est, 'g', 'LineWidth', 1.5);
xlabel('Tiempo (min)');
ylabel('Glucosa (mg/dL)');
title('Estimación de glucosa con el filtro de Kalman');
grid on;