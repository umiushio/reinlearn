function test(low, high, n, alpha, var, steps)
    qmean = unifrnd(low, high, n, 1);
    reward = zeros;
    for s = 1:1000       % 每种策略做500次实验，得到普遍规律
        reward = reward + process(qmean, n, alpha, var, steps);
    end
    reward = reward/1000;
    disp(qmean);
    plot(1:steps,reward(:,1), 'r', 1:steps,reward(:,2), 'g'); hold on
    xlabel("steps"); ylabel("reward"); title("bandit based on gradient bandit algorithm");
    reward = zeros;
    
end
function Rba = process(qmean, n, alpha, var, steps)
    sqrtvar = sqrt(var);
    
    H = zeros(n, 2);
    Rba = 0;
    for t = 1:steps
        Pi = evapi(H);
        A(t, 1) = selectbypro(Pi(:, 1));
        R(t, 1) = sqrtvar * randn + qmean(A(t, 1));
        
        
        A(t, 2) = selectbypro(Pi(:, 2));
        R(t, 2) = sqrtvar * randn + qmean(A(t, 2));
        if t == 1
            Rba(t, 1) = R(t, 1);
            Rba(t, 2) = R(t, 2);
        else
            Rba(t, 1) = Rba(t-1, 1) + (R(t, 1) - Rba(t-1, 1)) / t;
            Rba(t, 2) = Rba(t-1, 2) + (R(t-1, 2) - Rba(t-1, 2)) / (t-1);
        end
        H(:, 1) = H(:, 1) - alpha * (R(t, 1) - Rba(t, 1)) * Pi(:, 1);
        H(:, 2) = H(:, 2) - alpha * (R(t, 2) - Rba(t, 2)) * Pi(:, 2);
        H(A(t), :) = H(A(t), :) + alpha *  (R(t, :) - Rba(t, :));
    end
end
function A = selectbypro(Pi)
    len = length(Pi);
    selector = rand;
    for at = 1:len
        selector = selector - Pi(at);
        if selector <= 0
            break;
        end
    end
    A = at;
end
function Pi = evapi(H)
    Pi = exp(H);
    sumpi = sum(Pi);
    Pi = Pi./sumpi;
end