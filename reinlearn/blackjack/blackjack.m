function blackjack()
    [V, N] = experiment(10000);
    subplot(2, 2, 1);
    surf(12:21, 1:10, V(1:10, 12:21, 1));
    subplot(2, 2, 3);
    surf(12:21, 1:10, V(1:10, 12:21, 2));
    [V, N] = experiment(5000000);
    subplot(2, 2, 2);
    surf(12:21, 1:10, V(1:10, 12:21, 1));
    subplot(2, 2, 4);
    surf(12:21, 1:10, V(1:10, 12:21, 2));
end
function [V, N] = experiment(num)
    [V, N, policy] = setup();
    for i = 1:num
        [V, N] = learn(V, N, policy);
    end
end
function outcome = getoutcome(dc_show, pc, cnt)
    dc_hidden = card();
    aceuse = 0;
    aceusable = 0;
    if dc_show == 1 || dc_hidden == 1
        aceuse = 1;
        aceusable = 1;
    end
    dc = dc_show + dc_hidden + 10 * aceusable;
    if cnt == 1
        if dc == 21
            outcome = -1;
        else
            outcome = 1;
        end
    else
        while 1
            if dc >= 21 
                if aceusable == 0
                    outcome = 1;
                    break;
                else
                    dc = dc - 10;
                    aceusable = 0;
                end
            end
            if dc >= 17
                outcome = sign(pc - dc);
                break;
            else
                dcard = card();
                if dcard == 1 && aceuse == 0
                    dcard = 11;
                    aceuse = 1;
                    aceusable = 1;
                end
                dc = dc + dcard;
            end
        end
    end
        
end
function [V, N] = learn(V, N, policy)
    [dc_show, pc, aceuse, outcome] = episode(policy);
    len = length(pc);
    pcappear = zeros(21, 1);
    for s = 1:len
        if pcappear(pc(s)) == 0
            N(dc_show, pc(s), aceuse) = N(dc_show, pc(s), aceuse) + 1;
            V(dc_show, pc(s), aceuse) = V(dc_show, pc(s), aceuse) + (outcome - V(dc_show, pc(s), aceuse)) / N(dc_show, pc(s), aceuse);
            pcappear(pc(s)) = 1;
        end
    end
end
function [dc_show, pc, aceuse, outcome] = episode(policy)
    dc_show = card();
    pcard1 = card();
    pcard2 = card();
    aceuse = 2;
    aceusable = 0;
    
    if pcard1 == 1 || pcard2 == 1
        aceuse = 1;
        aceusable = 1;
    end
    
    
    pc(1) = pcard1 + pcard2 + 10 * aceusable;
    cnt = 1;
    while 1
        if pc(cnt) > 21 
            if aceusable == 0
                outcome = -1;
                pc = pc(1:cnt - 1);
                break;
            else
                pc(cnt) = pc(cnt) - 10;
                aceusable = 0;
            end
        end
        t = policy(dc_show, pc(cnt), aceuse);
        if t == 0
            outcome = getoutcome(dc_show, pc(cnt), cnt);
            break;
        else
            pcard = card();
            if pcard == 1 && aceuse == 2
                pcard = 11;
                aceuse = 1;
                aceusable = 1;
            end
                
            pc(cnt + 1) = pc(cnt) + pcard;
            cnt = cnt + 1;
        end
    end
    
end
function [V, N, policy] = setup()
    V = zeros(10, 21, 2);
    N = zeros(10, 21, 2);
    policy = ones(10, 21, 2);
    policy(:, [20, 21], :) = 0;
end
function count = card()
    count = min(10, randi(13));
end
