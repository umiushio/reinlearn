function [policy, values] = carrental_2(~, ~)
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
                values(s1, s2) = evaquality(s1, s2, policy(s1, s2), values);
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
        q(i) = evaquality(s1, s2, actions(i), values);
    end
    [~, imax] = max(q);
    optaction = actions(imax);
end


function quality = evaquality(s1, s2, action, values)
    gama = 0.9;
    credit = 10;
    movecost = -2 * abs(action);
    maxcars = 21;
    rent_lambda1 = 3; rent_lambda2 = 4;
    return_lambda1 = 3; return_lambda2 = 2; 
    s1 = s1 - action; s2 = s2 + action;
    
    if s1 <= 0 || s1 > maxcars || s2 <= 0 || s2 > maxcars
        quality = -inf;
    else
        pro_rent1 = pro_possion(rent_lambda1, s1);
        pro_rent2 = pro_possion(rent_lambda2, s2);
        pro_return1 = pro_possion(return_lambda1, maxcars);
        pro_return2 = pro_possion(return_lambda2, maxcars);          
        
        for ns1 = 1:maxcars
            p1(ns1) = 0;
            for rent1 = 1:s1
                if ns1 == maxcars
                    p1(ns1) = p1(ns1) + sum(pro_rent1(rent1) * pro_return1([ns1 - s1 + rent1 : maxcars]), 'all');
                else
                    if ns1 - s1 + rent1 > 0 && ns1 - s1 + rent1 <= maxcars
                        p1(ns1) = p1(ns1) + pro_rent1(rent1) * pro_return1(ns1 - s1 + rent1);
                    end
                end
            end
            if p1(ns1) < 1e-6
                p1(ns1) = 0;
            end
        end       
        
        for ns2 = 1:maxcars
            p2(ns2) = 0;
            for rent2 = 1:s2
                if ns2 == maxcars
                    p2(ns1) = p2(ns2) + sum(pro_rent2(rent2) * pro_return1([ns2 - s2 + rent2 : maxcars]), 'all');
                else
                    if ns2 - s2 + rent2 > 0 && ns2 - s2 + rent2 <= maxcars
                        p2(ns2) = p2(ns2) + pro_rent2(rent2) * pro_return2(ns2 - s2 + rent2);
                    end
                end
            end
            if p2(ns2) < 1e-6
                p1(ns2) = 0;
            end
        end
        
        v = 0;
        for ns1 = 1:maxcars
            for ns2 = 1:maxcars
                p = p1(ns1) * p2(ns2);
                if p >= 1e-6
                    v = v + p * values(ns1, ns2) ;
                end
            end
        end
        pro_rent1(end) = pro_rent1(end) + 1 - sum(pro_rent1, 'all');
        pro_rent2(end) = pro_rent2(end) + 1 - sum(pro_rent2, 'all');
        reward = ([0:length(pro_rent1) - 1] * pro_rent1' + [0:length(pro_rent2) - 1] * pro_rent2')  * credit;
        quality = reward + gama * v + movecost;
    end
end

function [pro, valid] = pro_possion(lambda, s)
    valid = 1;
    pro = exp(-lambda);
    for i = 1:s-1
        pro(i+1) = pro(i) * lambda/i;
        if pro(i+1) >= 1e-6
            valid = valid + 1;
        else
            pro(i+1) = 0;
        end
    end
end