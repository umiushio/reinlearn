function bandit_4(n, var, steps)
%% 本程序模拟多臂赌博机的工作情形，并研究在sample average方法下用(esp-greedy)获得最大报酬的规律

% qem: 赌博机每臂报酬期望的最大可能值
% n: 赌博机臂数
% var: 赌博机每臂报酬变量的方差
% steps: 赌博机执行的最多次数
% qe: 赌博机每臂报酬期望的随机变量, 服从[-qem, qem]的随机分布
% exr: 在esp-greedy策略下获得的‘行动轮数-报酬’向量
    esp = 0.1;   % esp-greedy策略中的esp可能值
    rmean = zeros(1, steps);
    for s = 1:500       % 每种策略做500次实验，得到普遍规律
        rmean = rmean + process(n, var, esp, steps);
    end
    rmean = rmean/500;
    plot(rmean, 'g'); gtext("esp = 0.1");hold on
    xlabel("steps"); ylabel("reward"); title("bandit based on 'esp-greedy'");
end

function ga = greedy(qa)
%  根据已有信息采用greedy算法求最优行动；若有多个，则随机取其中一个
    [sqa, i] = sort(qa);
    [~, maxi] = max(sqa);
    ga = i(maxi + randi(length(qa) - maxi + 1) - 1);
end

function [rmean, at] = process(n, var, esp, steps)
% 模拟一次game全过程，输出报酬变化向量和行动向量
    qmean = zeros(n, 1);
    qaction = zeros(n, 1);
    rmean = zeros(n, 1);
    cnta = zeros(n, 1);
    q = 0;
    for t = 1:steps
        qmean = qmean + 0.1*randn(n, 1);
        selector = rand();
        if selector < esp
            at(t) = randi(n);
        else
            at(t) = greedy(qaction);
        end
        rv(t) = sqrt(var) * randn + qmean(at(t));
        cnta(at(t)) = cnta(at(t)) + 1;
        qaction(at(t)) =  qaction(at(t)) + (rv(t) - qaction(at(t))) / cnta(at(t));
        q = q + (rv(t) - q) / steps;
        rmean(t) = q;
    end
end