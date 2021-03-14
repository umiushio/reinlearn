function mdt1_greedy(nstate, naction, maxstep)
% 基于贪婪算法,计算最小路径
    V = zeros(nstate, 1);
    R = evareward(nstate, naction);
  
    fnorm = 0;
    err = 1;
    esp = 1e-1;
    step = 0;

    function [ns, ba] = greedy(s, P, V)
        for a = 1:naction
            Vs(:, a) = R(s, a) + P{a} * V;
        end
        [st, ba] = max(Vs');
        ns = st';
    end
    while err >= esp
        s = 1:nstate;
        for a = 1:naction;
            P{a} = evapro(s, a, nstate);
        end
        V = greedy(s, P, V);
        disp(V);
        err = abs(norm(V) - fnorm);
        fnorm = norm(V);
        step = step + 1;
        disp(step);
        if step >= maxstep break; end
    end
end
function Rn = evareward(nstate, naction)
% 得到S*A的回报函数
    Rn = -1 * ones(nstate, naction);
    Rn(1, :) = 0; Rn(end, :) = 0;
end
function Pn = evapro(s, a, nstate)
% 得到在s状态下，经过动作a后到每个状态s'概率向量
    N = round(sqrt(nstate));
    function ni = fnp(i, a)
        N = round(sqrt(nstate));
        ni = i;
        len = length(ni);
        for j = 1:len
            if(a == 1)
                if(i(j) > N) ni(j)  = ni(j) - N; end
            elseif (a == 2)
                if(mod(i(j), N) ~= 1) ni(j) = ni(j) - 1; end
            elseif (a == 3)
                if(mod(i(j), N) ~= 0) ni(j) = ni(j) + 1; end
            elseif (a == 4)
                if(i(j) + N <= N^2) ni(j) = ni(j) + N; end
            end
        end
    end
    len = length(s);
    Pn = zeros(len, nstate);
    Pn(len*(fnp(s, a)-1)+s) = 1;
end