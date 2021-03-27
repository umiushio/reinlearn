function mdt1_3(N, maxstep)
% 基于贪婪算法,计算最小路径
    V = zeros(N * N, 1);
    R = -1 * ones(N*N, N);
    R(1, :) = 0; R(end, :) = 0;
    
    fnorm = 0;
    err = 1;
    esp = 1e-1;
    step = 0;
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
    function Pn = evapro(s, a)
        len = length(s);
        Pn = zeros(len, N*N);
        Pn(len*(fnp(s, a) - 1) + s) = 1;
    end 
    function [ns, ba] = greedy(s, V)
        for a = 1:4
            Vs(:, a) = R(s, a) + evapro(s, a) * V;
        end
        [ns, ba] = max(Vs');
    end
    while err >= esp
        V = greedy(1:N*N, V)';

        Vn = reshape(V, N, N);
        disp(Vn);
        err = abs(norm(Vn) - fnorm);
        fnorm = norm(Vn);
        step = step + 1;
        disp(step);
        if step >= maxstep break; end
    end
end