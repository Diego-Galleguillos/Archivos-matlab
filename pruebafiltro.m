clc; clear; close all;

% Parámetros del modelo
GB = 100; IB = 1.5; VL = 120;
p2 = 20e-3; p3 = 13e-6; p4 = 5/54;

% Matrices del sistema en lazo abierto
A = [0  -GB   0;
      0   -p2  p3;
      0    0  -p4];

B =   [  0;
          0;
          1];

C = [1 0 0];  % Observamos solo la glucosa
D = [0];  % No hay ganancia directa

sys_open = ss(A, B, C, D);  % Sistema sin control

% Definir tiempo y condiciones iniciales
tspan = 0:0.05:100;
CI = [500; 0; 0];  % Estado inicial

% Generación de perturbaciones estocásticas controladas
rng(42); % Fijar semilla para reproducibilidad
insulina = zeros(size(tspan));  % Insulina aleatoria, siempre positiva


insulina = (randn(size(tspan)) * 60); 

u = [insulina]; % Señales de entrada

% Simulación de la respuesta sin ruido
[y, t, x] = lsim(sys_open, u, tspan, CI);


R = 5;  % Varianza 
ruido_medicion = sqrt(R) * randn(size(y)); 
y_noisy = y + ruido_medicion; 

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
Q = 400;  % Covarianza del ruido del proceso
[kalmf, L, P] = kalman(sys_open, Q,R);

% Simulación con el filtro de Kalman usando la salida con ruido
[y_est, t, x_est] = lsim(kalmf, y_noisy, tspan, CI);

figure;
plot(t,x_est , 'b', 'LineWidth', 1.5);
hold on;
plot(t, x, 'g', 'LineWidth', 1.5);
xlabel('Tiempo (min)');
ylabel('Glucosa (mg/dL)');
title('Estimación de glucosa con el filtro de Kalman');
grid on;

C = [1 0 0];  % Observamos solo la glucosa
D = 0;

% Definimos la penalización del LQR
Q = diag([100, 1, 10]);  % Penaliza el error de las variables de estado
R = 10000;               % Penaliza la insulina exógena (variable manipulada)

% Calculamos la ganancia LQR
K = lqr(A, B, Q, R);



%% Sistema en lazo cerrado con LQR y estimación por Kalman

% Creamos el sistema de compensador: estimación con Kalman y realimentación con LQR
% El compensador usa: u = -K * x_est

% Ampliamos el sistema para simular el lazo cerrado completo
% Sistema estimador de estados + realimentación

A_cl = [(A - B*K),        B*K;
         zeros(size(A)),  (A - L*C)];

B_cl = [B; zeros(size(B))];
C_cl = [C, zeros(size(C))];
D_cl = 0;

% Sistema en espacio de estados cerrado
sys_cl = ss(A_cl, B_cl, C_cl, D_cl);

% Nueva condición inicial: estados reales y estados estimados
CI_ext = [CI; zeros(size(CI))];  % x0 real + x0 estimado

% Simulación del sistema en lazo cerrado
[y_cl, t, x_cl] = lsim(sys_cl, u, tspan, CI_ext);

% Extraemos las trayectorias reales y estimadas por separado (opcional)
x_real = x_cl(:, 1:3);
x_est  = x_cl(:, 4:6);

% Graficar salida del sistema en lazo cerrado
figure;
plot(t, y_cl, 'b', 'LineWidth', 1.5);
xlabel('Tiempo (min)');
ylabel('Glucosa (mg/dL)');
title('Respuesta del sistema con control LQR y estimación por Kalman');
grid on;


size(K)
size(x_cl)


% Calculamos las variables manipuladas
u1 = K * x_est';
% Graficamos las variables manipuladas
figure;
plot(t, u1(1,:), 'LineWidth', 1.5);
xlabel('Tiempo (min)');
ylabel('Insulina exógena (U/min)');
title('Evolución de la variable manipulada con LQR');
grid on;