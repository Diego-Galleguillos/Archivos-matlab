%--------------------------------------------------------------------------
% 1) Parámetros del sistema
%--------------------------------------------------------------------------
a      = 0.9;
b      = 0.5;
c      = 0.1;
d      = 0;      % retraso en la entrada u(t−d−1)
sigma  = 1;      % desviación del ruido

Ndata  = 400;    % longitud de la serie y,u,v
Nest   = 200;    % número de iteraciones de RLS

%--------------------------------------------------------------------------
% 2) Simulación de y con ruido v(t)
%--------------------------------------------------------------------------
u = sigma * randn(Ndata,1);
v = sigma * randn(Ndata,1);   % ruido independiente
y = zeros(Ndata,1);

for k = 2:Ndata
    y(k) = a*y(k-1) + b*u(k-d-1) + c*v(k);
end

%--------------------------------------------------------------------------
% 3) Inicialización RLS
%--------------------------------------------------------------------------
theta = zeros(3,1,Nest);      % estimadores [a; b; c]
phi   = zeros(3,1,Nest);      % vector de regresores
e     = zeros(Nest,1);        % error de predicción
P     = zeros(3,3,Nest);      % matriz de covarianza

P(:,:,1) = 1e6 * eye(3);       % «big‑P» inicial para dar confianza baja
lambda   = 0.9;               % factor de olvido

%--------------------------------------------------------------------------
% 4) Ciclo RLS
%--------------------------------------------------------------------------
for k = 2:Nest
    % 4.1) Forma el vector de regresores
    phi(:,1,k) = [ y(k-1); 
                   u(k-1); 
                   e(k-1) ];
               
    % 4.2) Calcula el error
    e(k) = y(k) - phi(:,1,k)' * theta(:,1,k-1);
    
    % 4.3) Ganancia de adaptación H[k]
    denom = lambda + phi(:,1,k)' * P(:,:,k-1) * phi(:,1,k);
    H     = (P(:,:,k-1) * phi(:,1,k)) / denom;
    
    % 4.4) Actualiza θ[k]
    theta(:,1,k) = theta(:,1,k-1) + H * e(k);
    
    % 4.5) Actualiza P[k]
    P(:,:,k) = (P(:,:,k-1) - H * phi(:,1,k)' * P(:,:,k-1)) / lambda;
end

%--------------------------------------------------------------------------
% 5) Resultados
%--------------------------------------------------------------------------
disp('Estimación final de [a; b; c]:')
disp(theta(:,1,end))

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
