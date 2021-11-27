function Y = train(close, day, test_sz, input_sz, output_sz, ...
                   train_algorithm, neurons_R, neurons_P, ...
                   transfer_func_R, transfer_func_P)
    
    data_sz = length(close);
    ini_idx = data_sz - test_sz;
    
    test_date = day(ini_idx + 1:data_sz);
    test_close = close(ini_idx + 1:data_sz);
    
    matrix_sz = data_sz - test_sz - output_sz - input_sz + 1;
    P = zeros(input_sz, matrix_sz);
    T = zeros(output_sz, matrix_sz);
    for i = 1:matrix_sz
        P(:, i) = close(i:i + input_sz - 1);
        T(:, i) = close(i + input_sz:i + input_sz - 1 + output_sz);
    end

    if neurons_P == 0
        net = feedforwardnet(neurons_R);
    else
        net = feedforwardnet([neurons_R, neurons_P]);
    end
    net = configure(net, P, T);
    net = init(net);
    net.layers{1}.transferFcn = transfer_func_R;
    if neurons_P == 0
        net.layers{2}.transferFcn = 'purelin'; 
    else
        net.layers{2}.transferFcn = transfer_func_P;
        net.layers{3}.transferFcn = 'purelin';   
    end
    net.trainFcn = train_algorithm;                           
    [net, ~] = train(net, P, T);

    Y = zeros(output_sz, test_sz);
    X = zeros(input_sz, test_sz);
    
    for i = 1:input_sz
        x_l = T(size(T,1), i - input_sz + size(T,2):size(T,2));
        X(:, i) = [x_l zeros(1, i - 1)];
    end

    for i = 1:test_sz
        Y(:, i) = net(X(:, i));
        for j = 1:input_sz
            if i + j <= test_sz
                X(size(X,1) - j + 1, i + j) = test_close(i, 1);
            end
        end
    end
    
    if neurons_P == 0
        plot_title = sprintf('%s %d-%d(%s)-%d', train_algorithm, ...
            input_sz, neurons_R, transfer_func_R, output_sz);
    else
        plot_title = sprintf('%s %d-%d(%s)-%d(%s)-%d', train_algorithm, ...
            input_sz, neurons_R, transfer_func_R, neurons_P, ...
            transfer_func_P, output_sz);
    end
    
    Y = Y(1,:);
    plot_simulation(test_date, test_close, Y, plot_title);
end

function plot_simulation(test_date, test_close, sim_close, plot_title)
    figure
    hold on;
    plot(test_date, test_close);
    plot(test_date, sim_close);
    title(plot_title);
    xlabel('Data');
    ylabel('Preço de fechamento em BRL');
    legend('Teste', 'Modelo');
    grid on;
end
