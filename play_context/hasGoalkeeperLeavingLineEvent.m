function has_gll_event = hasGoalkeeperLeavingLineEvent(plays)
% The function computes the number of Duel events in all of the plays of
% the input play vector.
    num_gll_events = cellfun(@(x) sum(contains({x.eventName}, 'Goalkeeper leaving line')), plays);
    
    gll_event_present = num_gll_events > 0;
    
    has_gll_event = strings(size(num_gll_events));
    
    has_gll_event(gll_event_present) = 't';
    has_gll_event(~gll_event_present) = 'f';
end