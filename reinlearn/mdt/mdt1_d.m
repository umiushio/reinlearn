function mdt1_d(nstate, naction)
% 基于贪婪算法,计算最小路径
        s = 1:nstate;
        for a = 1:naction;
            P{a} = evapro(s, a, nstate);
        end
        disp(P);
end

function Pn = evapro(s, a, nstate)
% 得到在s状态下，经过动作a后到每个状态s'概率向量
    N = round(sqrt(nstate));
    function ni = fnp(i, a)
        ni = i;
        if(a == 1)
            if(i > N) ni  = ni - N; end
        elseif (a == 2)
            if(mod(i, N) ~= 1) ni = ni - 1; end
        elseif (a == 3)
            if(mod(i, N) ~= 0) ni = ni + 1; end
        elseif (a == 4)
            if(i + N <= N^2) ni = ni + N; end
        end
    end
    len = length(s);
    Pn = zeros(len, nstate);
    Pn(len*(fnp(s, a)-1)+s) = 1;
end