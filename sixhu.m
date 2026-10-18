clear; clc; close all;

M = [
    5     1.539962597  1.540412522  1.540739294  1.54093051
    5.5   1.5401314    1.540466027  1.540696322  1.54084748
    6     1.540251454  1.540502034  1.540666974  1.540786871
    6.5   1.540335248  1.54052648   1.540646269  1.540741017
    7     1.540393577  1.540543175  1.54063124   1.540705187
];

if any(~isfinite(M(:)))
    error('M 矩阵中有无效数据，请检查输入。');
end

d_um = M(:,1);
n_sorted = sort(M(:,2:5), 2, 'descend');
n1 = n_sorted(:,1);
n3 = n_sorted(:,2);
n2 = n_sorted(:,3);
n4 = n_sorted(:,4);

lambda0_um = 0.700;
k_vac = 2*pi/lambda0_um;   % 真空波矢，单位 um-1

beta_mm = 1000*(k_vac/4).*(n1 + n2 + n3 + n4);   % 自耦合系数
j   = 1000*(k_vac/4).*(n1 - n2 - n3 + n4);
c1_mm   = 1000*(k_vac/4).*(n1 + n2 - n3 - n4);
c2_mm   = 1000*(k_vac/4).*(n1 - n2 + n3 - n4);


if any(c1_mm <= 0) || any(c2_mm <= 0)
    warning('c1 或 c2 存在非正值，请检查 n1~n4 顺序或数据。');
end

fprintf('beta 范围: %.4f ~ %.4f mm^-1\n', min(beta_mm), max(beta_mm));
fprintf('beta 变化量: %.4f mm^-1\n', max(beta_mm) - min(beta_mm));

C = [c1_mm, c2_mm];
names = {'c1','c2'};
colors = lines(2);

fit_result = struct();
for j = 1:2
    y = C(:,j);
    use = d_um >= 5 & d_um <= 7 & y > 0 & isfinite(y);

    if nnz(use) < 2
        error('%s：有效数据少于两点，无法拟合。', names{j});
    end

    p = polyfit(d_um(use), log(y(use)), 1);
    kappa = -p(1);
    K = exp(p(2));

    z = log(y(use));
    zfit = polyval(p, d_um(use));
    R2_log = 1 - sum((z - zfit).^2) / sum((z - mean(z)).^2);

    fprintf('%s: K = %.8g mm^-1, kappa = %.8g um^-1, R2_log = %.4f\n', ...
        names{j}, K, kappa, R2_log);

    fit_result(j).use = use;
    fit_result(j).K = K;
    fit_result(j).kappa = kappa;
end


K0_paper     = 387;     % mm^-1
kappa0_paper = 1.17;    % um^-1

d_ref = linspace(5, 7, 200);
c0_paper = K0_paper * exp(-kappa0_paper * d_ref);

figure;
hold on;

yyaxis left

plot(d_ref, c0_paper, '--', 'Color', [0 0.45 0.74], 'LineWidth', 1.5, ...
    'DisplayName', 'c_0 论文参考 (K_0=387, \kappa_0=1.17)');

% 画 c1、c2 数据点和拟合
for j = 1:2
    y = C(:,j);
    use = fit_result(j).use;
    K = fit_result(j).K;
    kappa = fit_result(j).kappa;

    xfit = linspace(min(d_um(use)), max(d_um(use)), 200);
    yfit = K .* exp(-kappa .* xfit);

    plot(d_um(use), y(use), 'o', ...
        'Color', colors(j,:), 'MarkerFaceColor', colors(j,:), ...
        'LineStyle', 'none', 'DisplayName', [names{j} ' 计算值']);
    plot(xfit, yfit, '-', 'Color', colors(j,:), 'LineWidth', 1.5, ...
        'DisplayName', [names{j} ' 指数拟合']);
end

ylabel('c_0, c_1, c_2 (mm^{-1})');


yyaxis right
plot(d_um, beta_mm, 's-', 'Color', [0.85 0.33 0.10], ...
    'MarkerFaceColor', [0.85 0.33 0.10], 'LineWidth', 1.5, ...
    'DisplayName', '\beta (自耦合系数)');
ylabel('\beta (mm^{-1})');

xlabel('d (\mum)');
title('c_0、c_1、c_2 与 \beta 随间距 d 的变化（双 y 轴）');
legend('Location','best');
grid on;
hold off;