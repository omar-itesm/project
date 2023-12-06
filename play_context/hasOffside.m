function has_offside = hasOffside(plays)
% The function computes the number of Duel events in all of the plays of
% the input play vector.
    offside_cnt = cellfun(@(x) sum(contains({x.eventName}, 'Offside')), plays);
    
    has_offside = strings(size(offside_cnt));
    
    has_offside(offside_cnt > 0) = 't';
    has_offside(offside_cnt <= 0) = 'f';
end