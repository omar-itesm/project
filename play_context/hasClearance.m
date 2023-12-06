function has_clearance = hasClearance(plays)
% The function computes the number of Duel events in all of the plays of
% the input play vector.
    clearance_cnt = cellfun(@(x) sum(contains({x.subEventName}, 'Clearance')), plays);
    
    has_clearance = strings(size(clearance_cnt));
    
    has_clearance(clearance_cnt > 0) = 't';
    has_clearance(clearance_cnt <= 0) = 'f';
end