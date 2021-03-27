function gambler()
    goal = 100;
    S = 1:goal-1;
    V = zeros(goal-1, 1);
    theta = 1e-6;
    figure(2);
    subplot(2, 1, 1);
    [V, policy] = valueIteration(S, V, goal, theta);
    subplot(2, 1, 2);
    plot(policy);
    
end
function [V, policy] = valueIteration(S, V, goal, theta)

    while 1
        delta = 0;
        for s = 1:goal-1
            v = V(s);
            V(s) = maxvalue(S(s), goal, V);
            delta = max(delta, abs(v - V(s)));
        end
        
        plot(V); hold on
        if delta < theta
            break;
        end
    end
    policy = zeros(goal-1, 1);
    for s = 1:goal-1
        policy(s) = argmaxvalue(S(s), goal, V);
    end
end
function vmax = maxvalue(state, goal, V)
    vmax = 0;
    for action = 1:min(state, goal - state)
        v = evavalue(state, action, goal, V);
        if v > vmax
            vmax = v;
        end
    end
end
function optaction = argmaxvalue(state, goal, V)
    for action = 1:min(state, goal - state)
        v(action) = evavalue(state, action, goal, V);
    end
    [~, optaction] = max(v);
end
function value = evavalue(state, action, goal, V)
    ph = 0.55;
    reward = 1;
    if action + state == goal
        value1 = ph * reward;
    else
        value1 = ph * V(state + action);
    end
    if action == state
        value2 = 0;
    else
        value2 = (1 - ph) * V(state - action);
    end
    value = value1 + value2;
end
