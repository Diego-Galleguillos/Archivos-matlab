function modelo_original()
    % Parámetros del modelo
    p1 = 0.03;  % Tasa de eliminación basal de glucosa
    p2 = 0.02;  % Tasa de eliminación de la acción de la insulina
    p3 = 0.0005; % Sensibilidad de la glucosa a la insulina
    n = 0.14;   % Tasa de eliminación de la insulina
    VL = 10;    % Volumen de distribución de la insulina
    IB = 10;    % Nivel basal de insulina
    GB = 90;    % Nivel basal de glucosa

    % Condiciones iniciales: Dos escenarios diferentes
    CI1 = [100; 0.5; 12];  % [G, X, I] (mayor glucosa inicial)
    CI2 = [80; 0.3; 8];    % [G, X, I] (menor glucosa inicial)

    % Tiempo de simulación
    tspan = [0 200];

    % Definir perturbaciones y variables manipuladas
    h1 = @(t) 10 * (t > 50 & t < 100);  % Ingesta de glucosa (perturbación)
    h2 = @(t) 5 * (t > 100 & t < 150);
    
    i1 = @(t) 1 * (t > 50);  % Infusión de insulina (variable manipulada)
    i2 = @(t) 2 * (t > 100);

    % Simulación para ambas condiciones
    [t1, y1] = ode45(@(t, y) modelo(t, y, p1, p2, p3, n, VL, IB, h1, i1), tspan, CI1);
    [t2, y2] = ode45(@(t, y) modelo(t, y, p1, p2, p3, n, VL, IB, h2, i2), tspan, CI2);

    % Crear un conjunto común de puntos de tiempo
    t_common = linspace(0, 200, 500); % 500 puntos equidistantes en el tiempo
    
    % Interpolar los resultados en los mismos puntos de tiempo
    y1_interp = interp1(t1, y1, t_common, 'linear');
    y2_interp = interp1(t2, y2, t_common, 'linear');

    % Graficar resultados
    figure;
    subplot(2,1,1);
    plot(t_common, y1_interp(:,1), 'b', t_common, y2_interp(:,1), 'r');
    xlabel('Tiempo (min)'); ylabel('Glucosa (mg/dL)');
    legend('Condición 1', 'Condición 2'); title('Evolución de la Glucosa');

    subplot(2,1,2);
    plot(t_common, y1_interp(:,3), 'b', t_common, y2_interp(:,3), 'r');
    xlabel('Tiempo (min)'); ylabel('Insulina (mU/dL)');
    legend('Condición 1', 'Condición 2'); title('Evolución de la Insulina');

end

function dydt = modelo(t, y, p1, p2, p3, n, VL, IB, h, i)
    G = y(1);
    X = y(2);
    I = y(3);
    
    % Evaluar las funciones de perturbación e insulina
    h_t = h(t);
    i_t = i(t);
    
    dGdt = -p1 * G - X * G + h_t;
    dXdt = -p2 * X + p3 * (I - IB);
    dIdt = -n * (I - IB) + i_t / VL;
    
    dydt = [dGdt; dXdt; dIdt];
end
