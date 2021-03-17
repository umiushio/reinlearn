function bandit_8(qem, n, var, steps)
%% 本程序模拟多臂赌博机的工作情形，并研究在sample average方法下用不同策略下(esp-greedy)最优策略采用率的规律

% qem: 赌博机每臂报酬期望的最大可能值
% n: 赌博机臂数
% var: 赌博机每臂报酬变量的方差
% steps: 赌博机执行的最多次数
% qe: 赌博机每臂报酬期望的随机变量, 服从[-qem, qem]的随机分布
% exr: 在esp-greedy策略下获得的‘行动轮数-报酬’向量

    qmean = unifrnd(-qem, qem, n, 1);
    esp = [0, 0.01, 0.1];   % esp-greedy策略中的esp可能值
    rmean = zeros(steps+1, 2);
    for s = 1:500       % 每种策略做500次实验，得到普遍规律
        rmean = rmean + process(qmean, n, var, steps);
    end
    rmean = rmean/500;
    disp(qmean);
    plot(rmean);
    xlabel("steps"); ylabel("per opt"); title("bandit based on 'ucb'");
    
    subplot(2, 1, 1);
    
end

function opta = ucb(qa, cnta, t, c)
%  根据已有信息采用greedy算法求最优行动；若有多个，则随机取其中一个
    [vmin, imin] = min(cnta);
    if vmin == 0
        opta = imin;
    else
        ucbq = qa + c*sqrt(log(t)./cnta);
        [sqa, i] = sort(ucbq);
        [~, maxi] = max(sqa);
        opta = i(maxi + randi(length(qa) - maxi + 1) - 1);
    end
end

function [rmean, at, peropt] = process(qmean, n, var, steps)
% 模拟一次game全过程，输出报酬变化向量和行动向量
    qaction = zeros(n, 2);
    rmean = zeros(steps+1, 2);
    cnta = zeros(n, 2);
    sqrvar = sqrt(var);
    for t = 1:steps
        
        selector = rand();
        if selector < 0.1
            at(t, 1) = randi(n);
        else
            at(t, 1) = greedy(qaction(:, 1));
        end
        rv(t, 1) = sqrvar * randn + qmean(at(t, 1));
        cnta(at(t, 1), 1) = cnta(at(t, 1), 1) + 1;
        qaction(at(t, 1), 1) = qaction(at(t, 1), 1) + (rv(t, 1) - qaction(at(t, 1), 1)) / cnta(at(t, 1), 1);
        rmean(t + 1 , 1) = rmean(t, 1) + (rv(t, 1) - rmean(t, 1)) /t;
        
        at(t, 2) = ucb(qaction(:, 2), cnta(:, 2), t, 2);
        rv(t, 2) = sqrvar * randn + qmean(at(t, 2));
        cnta(at(t, 2), 2) = cnta(at(t, 2), 2) + 1;
        qaction(at(t, 2), 2) = qaction(at(t, 2), 2) + (rv(t, 2) - qaction(at(t, 2), 2)) / cnta(at(t, 2), 2);
        rmean(t + 1, 2) = rmean(t, 2) + (rv(t, 2) - rmean(t, 2)) /t;
    end
    [~, imax] = max(qmean);
    peropt = cnta(imax) / steps;
end

function ga = greedy(qa)
%  根据已有信息采用greedy算法求最优行动；若有多个，则随机取其中一个
    [sqa, i] = sort(qa);
    [~, maxi] = max(sqa);
    ga = i(maxi + randi(length(qa) - maxi + 1) - 1);
end