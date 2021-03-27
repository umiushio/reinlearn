function [policy, values] = carrental_1(~, ~)
    n = 20; m = 5;
    actions = -m:1:m;
    run(n+1, actions);
    
    
    
end
function [policy, values] = run(n, actions)
    values = zeros(n);
    policy = zeros(n);
    [policy, values] = improvepolicy(policy, values, n, actions);
    
end
function values = evapolicy(policy, values, n, theta)
    while 1
        delta = 0;
        for s1 = 1:n
            for s2 = 1:n
                v = values(s1, s2);
                values(s1, s2) = quality(s1, s2, policy(s1, s2), values);
                delta = max(abs(v - values(s1, s2)), delta);
            end
        end
        if delta < theta
            break;
        end
    end
end
function [policy, values] = improvepolicy(policy, values, n, actions)
    [x, y] = meshgrid(1:n, 1:n);
    cnt = 0;
    theta = 1e-6;
    figure(1);
    
    while 1
        values = evapolicy(policy, values, n, theta);
        policy_stable = 1;
        for s1 = 1:n
            for s2 = 1:n
                old_action = policy(s1, s2);
                policy(s1, s2) = argmaxaction(s1, s2, values, actions);
                if policy(s1, s2) ~= old_action
                    policy_stable = 0;
                end
            end
        end
        cnt = cnt + 1;
        subplot(3, 2, cnt);
        surf(x, y, policy);
        if policy_stable == 1
            break
        end
    end
    figure(2);
    surf(x, y, values);
end

function optaction = argmaxaction(s1, s2, values, actions)
    for i = 1:length(actions)
        q(i) = quality(s1, s2, actions(i), values);
    end
    [~, imax] = max(q);
    optaction = actions(imax);
end

function q = quality(s1, s2, action, values)
    [pro, ns, rmean] = evapro(s1, s2, action);
    gama = 0.9;
    q = rmean;
    if pro > 0
        for i = 1:length(pro);
            q = q + gama * pro(i) * values(ns(i, 1), ns(i, 2));
        end
    end
end

function [pro, ns, rmean] = evapro(s1, s2, action)
    credit = 10;
    movecost = -2 * abs(action);
    maxcars = 21;
    rent_lambda1 = 3; rent_lambda2 = 4;
    return_lambda1 = 3; return_lambda2 = 2; 
    s1 = s1 - action; s2 = s2 + action;
    
    if s1 <= 0 || s1 > maxcars || s2 <= 0 || s2 > maxcars
        pro = 0; ns = [s1, s2]; rmean = -inf;
    else
        pro_rent1 = pro_possion(rent_lambda1, s1);
        pro_rent2 = pro_possion(rent_lambda2, s2);
        pro_return1 = pro_possion(return_lambda1, maxcars);
        pro_return2 = pro_possion(return_lambda2, maxcars);
        cnt1 = 0; cnt2 = 0;     
        
        rmean = ([0:length(pro_rent1) - 1] * pro_rent1' + [0:length(pro_rent2) - 1] * pro_rent2')  * credit + movecost;
        for ns1 = 1:min(s1 + length(pro_return1) - 1, maxcars)
            p1 = 0;
            for rent1 = max(1, s1 - ns1 + 1):min(s1 - ns1 + length(pro_return1), length(pro_rent1))
                p = pro_rent1(rent1) * pro_return1(ns1 - s1 + rent1);
                p1 = p1 + p;
            end
            if  p1 >= 1e-6
                cnt1 = cnt1 + 1;
                pro1(cnt1) = p1;
            end
        end
        
        for ns2 = 1:min(s2 + length(pro_return2) - 1, maxcars)
            p2 = 0;
            for rent2 = max(1, s2 - ns2 + 1):min(s2 - ns2 + length(pro_return2), length(pro_rent2))
                p = pro_rent2(rent2)*pro_return2(ns2 - s2 + rent2);
                p2 = p2 + p;
            end
            if  p2 >= 1e-6
                cnt2 = cnt2 + 1;
                pro2(cnt2) = p2;       
            end
        end
        
        
        cnt = 0;
        for ns1 = 1:cnt1
            for ns2 = 1:cnt2
                p = pro1(ns1) * pro2(ns2);
                if p >= 1e-6
                    cnt = cnt + 1;
                    pro(cnt) = p;
                    ns(cnt, [1, 2]) = [ns1, ns2];
                end
            end
        end
    end
end

function pro = pro_possion(lambda, s)
    valid = 1;
    pro = exp(-lambda);
    for i = 1:s-1
        p = pro(i) * lambda/i;
        if p < 1e-6
            break;
        end
        valid = valid + 1;
        pro(valid) = p;
    end
end