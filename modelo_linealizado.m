function modelo_linealizado()
    % Parámetros del modelo linealizado
    p1 = 0.03;
    p2 = 0.02;
    p3 = 0.0005;
    n = 0.14;
    VL = 10;
    IB = 10;
    GB = 90;

    % Matrices del sistema linealizado
    A = [-p1, -GB, 0; 0, -p2, p3; 0, 0, -n];
    B = [0; 0; 1/VL];
    H = [1; 0; 0];  % Afecta solo la glucosa
    C = [1, 0, 0];  % Medimos solo la glucosa

    % Condiciones iniciales
    x0_1 = [10; 0.1; 2];  % Primera condición inicial
    x0_2 = [-10; -0.1; -2];  % Segunda condición inicial

    % Tiempo de simulación
    tspan = [0 200];

    % Simulación de la respuesta con perturbaciones e insulina
    [t, x1] = ode45(@(t, x) sistema_lineal(t, x, A, B, H, IB), tspan, x0_1);
    [t, x2] = ode45(@(t, x) sistema_lineal(t, x, A, B, H, IB), tspan, x0_2);

    % Graficar resultados
    figure;
    subplot(2,1,1);
    plot(t, x1(:,1) + GB, 'b', t, x2(:,1) + GB, 'r');
    xlabel('Tiempo (min)'); ylabel('Glucosa (mg/dL)');
    legend('Condición 1', 'Condición 2'); title('Evolución de la Glucosa (Modelo Linealizado)');

    subplot(2,1,2);
    plot(t, x1(:,3) + IB, 'b', t, x2(:,3) + IB, 'r');
    xlabel('Tiempo (min)'); ylabel('Insulina (mU/dL)');
    legend('Condición 1', 'Condición 2'); title('Evolución de la Insulina (Modelo Linealizado)');

end

function dxdt = sistema_lineal(t, x, A, B, H, IB)
    u = 1 * (t > 50);  % Infusión de insulina como un escalón
    d = 10 * (t > 100);  % Ingesta de glucosa como perturbación

    dxdt = A * x + B * u + H * d;
end
