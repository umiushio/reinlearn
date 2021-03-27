function bandit_11(n, alpha, var, steps)
    esp = 1/32;
    reward = zeros(8, 1);
    for i = 1:8
    for s = 1:200       % 每种策略做1000次实验，得到普遍规律
        reward(i) = reward(i) + process(n, alpha, esp, var, steps);
    end
    esp = esp * 2;
    end
    reward = reward/200;
    plot(logspace(1/32, 4, 8), reward, 'r');
    xlabel("steps"); ylabel("reward"); title("bandit based on gradient bandit algorithm");
    reward = zeros;
    
end
function Rba = process(n, esp, alpha, var, steps)
    qmean = zeros(n, 1);
    sqrtvar = sqrt(var);
    halfsteps = round(steps/2);
    Qa = zeros(n, 1);
    Ca = zeros(n, 1);
    Rba = 0;
    for t = 1:steps
        qmean = qmean + 0.1*randn(n, 1);
        selector = rand();
        if selector < esp
            A(t) = randi(n);
        else
            A(t) = greedy(Qa);
        end
        R(t) = sqrtvar * randn + qmean(A(t));
        Ca(A(t)) = Ca(A(t)) + 1;
        if Ca(A(t)) == 1
            Qa(A(t)) = R(t);
        else
            Qa(A(t)) =  Qa(A(t)) + (R(t) - Qa(A(t))) * alpha;
        end
        if t > halfsteps
            Rba = Rba + (R(t - halfsteps) - Rba) / (t - halfsteps);
        end
    end
end
function opta = greedy(Qa)
%  根据已有信息采用greedy算法求最优行动；若有多个，则随机取其中一个
    [sqa, i] = sort(Qa);
    [~, maxi] = max(sqa);
    opta = i(maxi + randi(length(Qa) - maxi + 1) - 1);
end