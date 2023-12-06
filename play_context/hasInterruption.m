function has_interruption = hasInterruption(plays)
% The function computes the number of Duel events in all of the plays of
% the input play vector.
    interruption_cnt = cellfun(@(x) sum(contains({x.eventName}, 'Interruption')), plays);
    
    has_interruption = strings(size(interruption_cnt));
    
    has_interruption(interruption_cnt > 0) = 't';
    has_interruption(interruption_cnt <= 0) = 'f';
end