function has_save_attempt = hasSaveAttempt(plays)
% The function computes the number of Duel events in all of the plays of
% the input play vector.
    save_attempt_cnt = cellfun(@(x) sum(contains({x.eventName}, 'Save attempt')), plays);
    
    has_save_attempt = strings(size(save_attempt_cnt));
    
    has_save_attempt(save_attempt_cnt > 0) = 't';
    has_save_attempt(save_attempt_cnt <= 0) = 'f';
end