clear
clc

% importando e tratando os dados
stock_history = readtable('PETR4.SA.csv', 'PreserveVariableNames', true);
stock_history(any(ismissing(stock_history), 2), :) = [];
stock_history(any(stock_history.('Volume') == 0, 2), :) = [];

day = table2array(stock_history(:, 1));
close = table2array(stock_history(:, 5));
data_size = size(stock_history, 1); % quantidade de dados importados
test_sz = 90; % quantidade de dados p/ teste

% gráfico com preços de fechamento da PETR4 dos últimos 90 dias
figure;
plot(day, close);
xline(day(data_size - test_sz), '--', {'Amostra','de teste'});
xlabel('Data');
ylabel('Preço de fechamento em BRL');
title('Histórico de cotação - PETR4');
grid minor;

% cálculo do expoente de Hurst
[hurst_exponent, c, R, S] = hurst(close);

% gráfico log-log da série de intervalo redimensionado
y = hurst_exponent*S + c;
figure;
plot(S, y, '-', S, R, 'o');
xlabel('log2(k)');
ylabel('log2(R/S)');
title('Gráfico log-log da série de intervalo redimensionado das cotações');
legend(sprintf('Regressão linear (H = %.4f)', hurst_exponent), 'Valores da série R/S');
grid on;

% saída da rede neural
sim = zeros(test_sz, 6);

% trainlm 10-15(tansig)-1
input_sz = 10;
neurons_R = 15;
tf_R = 'tansig';
neurons_P = 0;
tf_P = '';
output_sz = 1;
train_algorithm = 'trainlm';
sim(:,1) = train(close, day, test_sz, input_sz, output_sz, ...
                train_algorithm, neurons_R, neurons_P, tf_R, tf_P);

% trainlm 10-10(poslin)-10(poslin)-1
input_sz = 10;
neurons_R = 10;
tf_R = 'poslin';
neurons_P = 10;
tf_P = 'poslin';
output_sz = 1;
train_algorithm = 'trainlm';
sim(:,2) = train(close, day, test_sz, input_sz, output_sz, ...
                train_algorithm, neurons_R, neurons_P, tf_R, tf_P);

% trainrp 10-15(tansig)-10(tansig)-1
input_sz = 10;
neurons_R = 15;
tf_R = 'tansig';
neurons_P = 10;
tf_P = 'tansig';
output_sz = 1;
train_algorithm = 'trainrp';
sim(:,3) = train(close, day, test_sz, input_sz, output_sz, ...
                train_algorithm, neurons_R, neurons_P, tf_R, tf_P);

% traincgp 10-25(poslin)-10
input_sz = 10;
neurons_R = 25;
tf_R = 'poslin';
neurons_P = 0;
tf_P = '';
output_sz = 10;
train_algorithm = 'traincgp';
sim(:,4) = train(close, day, test_sz, input_sz, output_sz, ...
                train_algorithm, neurons_R, neurons_P, tf_R, tf_P);

% trainbr 6-25(tansig)-25(tansig)-2
input_sz = 6;
neurons_R = 25;
tf_R = 'tansig';
neurons_P = 25;
tf_P = 'tansig';
output_sz = 2;
train_algorithm = 'trainbr';
sim(:,5) = train(close, day, test_sz, input_sz, output_sz, ...
                train_algorithm, neurons_R, neurons_P, tf_R, tf_P);

% trainlm 10-20(tansig)-20(tansig)-10
input_sz = 10;
neurons_R = 20;
tf_R = 'tansig';
neurons_P = 20;
tf_P = 'tansig';
output_sz = 10;
train_algorithm = 'trainlm';
sim(:,6) = train(close, day, test_sz, input_sz, output_sz, ...
                train_algorithm, neurons_R, neurons_P, tf_R, tf_P);
