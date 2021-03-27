function bandit_1(qem, n, esp, steps)
    qe = unifrnd(-qem, qem, n, 1);
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
        rv(t) = randn+qe(at(t));
        suma(at(t)) = suma(at(t)) + rv(t);
        cnta(at(t)) = cnta(at(t)) + 1;
        qa(at(t)) = suma(at(t)) / cnta(at(t));
        sumr = sumr + rv(t);
        exr(t) = sumr / t;
    end
    plot(exr, 'r');
end
function ga = greedy(qa)
    [sqa, i] = sort(qa);
    [~, maxi] = max(sqa);
    ga = i(maxi + randi(length(qa) - maxi + 1) - 1);
end