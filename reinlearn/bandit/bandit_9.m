function bandit_9(low, high, n, alpha, var, steps)
    qmean = unifrnd(low, high, n, 1);
    reward = zeros;
    for s = 1:1000       % 每种策略做500次实验，得到普遍规律
        reward = reward + process(qmean, n, alpha, var, steps);
    end
    reward = reward/1000;
    disp(qmean);
    plot(reward, 'r'); hold on
    xlabel("steps"); ylabel("reward"); title("bandit based on gradient bandit algorithm");
    reward = zeros;
    
end
function Rba = process(qmean, n, alpha, var, steps)
    sqrtvar = sqrt(var);
    
    
    H = zeros(n, 1);
    for t = 1:steps
        Pi = evapi(H);
        A(t) = selectbypro(Pi);
        R(t) = sqrtvar * randn + qmean(A(t));
        if
        Rba(t + 1) = Rba(t) + (R(t) - Rba(t)) / t;
        H = H - alpha * (R(t) - Rba(t)) * Pi;
        H(A(t)) = H(A(t)) + alpha *  (R(t) - Rba(t));
    end
end
function at = selectbypro(Pi)
    selector = rand;
    len = length(Pi);
    for at = 1:len
        selector = selector - Pi(at);
        if selector <= 0
            break;
        end
    end
end
function Pi = evapi(H)
    Pi = exp(H);
    sumpi = sum(Pi);
    Pi = Pi/sumpi;
end