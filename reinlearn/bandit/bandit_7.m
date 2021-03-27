function bandit_7(n, var, alpha, steps)
%% 本程序模拟非稳态多臂赌博机的工作情形，并研究在sample/constant average方法下用策略下(esp-greedy)获得最大报酬的规律

% qem: 赌博机每臂报酬期望的最大可能值
% n: 赌博机臂数
% var: 赌博机每臂报酬变量的方差
% steps: 赌博机执行的最多次数
% qe: 赌博机每臂报酬期望的随机变量, 服从[-qem, qem]的随机分布
% exr: 在esp-greedy策略下获得的‘行动轮数-报酬’向量
    esp = 0.1;   % esp-greedy策略中的esp可能值
    rmean = zeros(steps + 1, 3);
    for s = 1:500       % 每种策略做500次实验，得到普遍规律
        rmean = rmean + process(n, var, esp, alpha, steps);
    end
    rmean = rmean/500;
    plot(rmean(:, 1), 'r'); hold on
    plot(rmean(:, 2), 'b'); hold on
    plot(rmean(:, 3), 'g'); hold on
    xlabel("steps"); ylabel("reward"); title("bandit based on 'esp-greedy'");
end

function ga = greedy(qa)
%  根据已有信息采用greedy算法求最优行动；若有多个，则随机取其中一个
    [sqa, i] = sort(qa);
    [~, maxi] = max(sqa);
    ga = i(maxi + randi(length(qa) - maxi + 1) - 1);
end

function [rmean, at] = process(n, var, esp, alpha, steps)
% 模拟一次game全过程，输出报酬变化向量和行动向量
    qmean = zeros(n, 1);
    qaction = zeros(n, 3);
    rmean = zeros(steps+1, 3);
    cnta = zeros(n, 3);
    q = zeros(1, 3);
    oba = 0;
    for t = 1:steps
        qmean = qmean + 0.1*randn(n, 1);
        
        selector = rand();
        if selector < esp
            at(t, 1) = randi(n);
        else
            at(t, 1) = greedy(qaction(:, 1));
        end
        rv(t, 1) = sqrt(var) * randn + qmean(at(t, 1));
        cnta(at(t, 1), 1) = cnta(at(t, 1), 1) + 1;
        qaction(at(t, 1), 1) =  qaction(at(t, 1), 1) + (rv(t, 1) - qaction(at(t, 1), 1)) / cnta(at(t, 1), 1);
        rmean(t + 1 , 1) = rmean(t, 1) + (rv(t, 1) - rmean(t, 1)) /t;
        
        selector = rand();
        if selector < esp
            at(t, 2) = randi(n);
        else
            at(t, 2) = greedy(qaction(:, 2));
        end
        rv(t, 2) = sqrt(var) * randn + qmean(at(t, 2));
        cnta(at(t, 2), 1) = cnta(at(t, 2), 2) + 1;
        if cnta(at(t, 2), 2) == 1
            qaction(at(t, 2), 2) = rv(t, 2);
        else
            qaction(at(t, 2), 2) =  qaction(at(t, 2), 2) + (rv(t, 2) - qaction(at(t, 2), 2)) * alpha;
        end
        rmean(t + 1 , 2) = rmean(t, 2) + (rv(t, 2) - rmean(t, 2)) * alpha;
        
        selector = rand();
        if selector < esp
            at(t, 3) = randi(n);
        else
            at(t, 3) = greedy(qaction(:, 3));
        end
        rv(t, 3) = sqrt(var) * randn + qmean(at(t, 3));
        oba = oba + alpha*(1-oba);
        beta = alpha / oba;
        cnta(at(t, 3), 3) = cnta(at(t, 3), 3) + 1;
        if cnta(at(t, 3), 3) == 1
            qaction(at(t, 3), 3) = rv(t, 3);
        else
            qaction(at(t, 3), 3) =  qaction(at(t, 3), 3) + (rv(t, 3) - qaction(at(t, 3), 3)) * beta;
        end
        rmean(t + 1 , 3) = rmean(t, 3) + (rv(t, 3) - rmean(t, 3)) * beta;
    end
end