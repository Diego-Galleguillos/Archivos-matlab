function modelo_original()
    % Parámetros del modelo ajustados
    GB = 100;       % Nivel basal de glucosa (mg/dl)
    IB = 1.5;       % Nivel basal de insulina (mU/dl)
    VL = 120;       % Volumen de distribución de la insulina (dl)
    p2 = 20e-3;     % Tasa de eliminación de la acción de la insulina (1/min)
    p3 = 13e-6;     % Sensibilidad de la glucosa a la insulina (1/min)
    p4 = 5/54;      % Parámetro p4 (1/min)
    p1 = 0.03
    n = 0.14; 


    CI1 = [100; 0; 1.5];  % [G, X, I] 
    CI2 = [200; 0.1; 3];    % [G, X, I] 

    % Tiempo de simulación
    tspan = [0 200];


    h1 = @(t) 0;  % Ingesta de glucosa (perturbación)
    h2 = @(t) 5 * (t > 100);
    
    i1 = @(t) p4*IB*VL * (t > 50);  % Infusión de insulina (variable manipulada)
    i2 = @(t)  p4*IB*VL *2 * (t > 50);

    % Simulación para ambas condiciones
    [t1, y1] = ode45(@(t, y) modelo(t, y, p4, p2, p3, n, VL, IB, h1, i1), tspan, CI1);
    [t2, y2] = ode45(@(t, y) modelo(t, y, p4, p2, p3, n, VL, IB, h2, i2), tspan, CI2);

    % Crear un conjunto común de puntos de tiempo
    t_common = linspace(0, 200, 500); % 500 puntos equidistantes en el tiempo
    
    % Interpolar los resultados en los mismos puntos de tiempo
    y1_interp = interp1(t1, y1, t_common, 'linear');
    y2_interp = interp1(t2, y2, t_common, 'linear');

    % Graficar resultados
    figure;
    subplot(3,1,1);
    plot(t_common, y1_interp(:,1), 'b', t_common, y2_interp(:,1), 'r');
    xlabel('Tiempo (min)'); ylabel('Glucosa (mg/dL)');
    legend('Condición 1', 'Condición 2'); title('Evolución de la Glucosa');

    subplot(3,1,2);
    plot(t_common, y1_interp(:,2), 'b', t_common, y2_interp(:,2), 'r');
    xlabel('Tiempo (min)'); ylabel('Insulina (mU/dL)');
    legend('Condición 1', 'Condición 2'); title('concentración intersticial de insulina');
   
    subplot(3,1,3);
    plot(t_common, y1_interp(:,3), 'b', t_common, y2_interp(:,3), 'r');
    xlabel('Tiempo (min)'); ylabel('Insulina (mU/dL)');
    legend('Condición 1', 'Condición 2'); title('Evolución de la Insulina');

end

function dydt = modelo(t, y, p4, p2, p3, n, VL, IB, h, i)
    G = y(1);
    X = y(2);
    I = y(3);
    
    % Evaluar las funciones de perturbación e insulina
    h_t = h(t);
    i_t = i(t);
    
    dGdt = -G * X + h_t;
    dXdt = -p2 * X + p3 * (I - IB);
    dIdt = -p4*I + i_t / VL;
    
    dydt = [dGdt; dXdt; dIdt];
end


