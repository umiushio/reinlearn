function bandit_2(qem, n, var, steps)
%% 本程序模拟多臂赌博机的工作情形，并研究在sample average方法下用不同策略下(esp-greedy)获得最大报酬的规律

% qem: 赌博机每臂报酬期望的最大可能值
% n: 赌博机臂数
% var: 赌博机每臂报酬变量的方差
% steps: 赌博机执行的最多次数
% qe: 赌博机每臂报酬期望的随机变量, 服从[-qem, qem]的随机分布
% exr: 在esp-greedy策略下获得的‘行动轮数-报酬’向量

    qe = unifrnd(-qem, qem, n, 1);
    esp = [0, 0.01, 0.1];   % esp-greedy策略中的esp可能值
    for i = 1:3
        exr{i} = zeros(1, steps);
        for s = 1:500       % 每种策略做500次实验，得到普遍规律
            exr{i} = exr{i} + process(qe, n, var, esp(i), steps);
        end
        exr{i} = exr{i}/500;
    end
    disp(qe);
    plot(exr{1}, 'r'); gtext("greedy");  hold on
    plot(exr{2}, 'b'); gtext("esp = 0.01"); hold on
    plot(exr{3}, 'g'); gtext("esp = 0.1");hold on
    xlabel("steps"); ylabel("reward"); title("bandit based on 'esp-greedy'");
end

function ga = greedy(qa)
%  根据已有信息采用greedy算法求最优行动；若有多个，则随机取其中一个
    [sqa, i] = sort(qa);
    [~, maxi] = max(sqa);
    ga = i(maxi + randi(length(qa) - maxi + 1) - 1);
end

function [exr, at] = process(qe, n, var, esp, steps)
% 模拟一次game全过程，输出报酬变化向量和行动向量
    qa = zeros(n, 1);
    suma = zeros(n, 1);
    cnta = zeros(n, 1);
    sumr = 0;
    for t = 1:steps
        selector = rand();
        if selector < esp
            at(t) = randi(n);
        else
            at(t) = greedy(qa);
        end
        rv(t) = sqrt(var)*randn + qe(at(t));
        suma(at(t)) = suma(at(t)) + rv(t);
        cnta(at(t)) = cnta(at(t)) + 1;
        qa(at(t)) = suma(at(t)) / cnta(at(t));
        sumr = sumr + rv(t);
        exr(t) = sumr / t;
    end
end