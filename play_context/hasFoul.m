function has_foul = hasFoul(plays)
% The function computes the number of Duel events in all of the plays of
% the input play vector.
    foul_cnt = cellfun(@(x) sum(contains({x.eventName}, 'Foul')), plays);
    
    has_foul = strings(size(foul_cnt));
    
    has_foul(foul_cnt > 0) = 't';
    has_foul(foul_cnt <= 0) = 'f';
end