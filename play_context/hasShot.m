function has_shot = hasShot(plays)
% The function computes the number of Duel events in all of the plays of
% the input play vector.
    shot_cnt = cellfun(@(x) sum(contains({x.eventName}, 'Shot')), plays);
    
    has_shot = strings(size(shot_cnt));
    
    has_shot(shot_cnt > 0) = 't';
    has_shot(shot_cnt <= 0) = 'f';
end