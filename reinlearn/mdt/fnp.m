function ni = fnp(i, a, nstate)
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