function preparation_time = computePreparationTime(plays)
% The function receives a set of contiguous plays and finds the preparation
% time (the time between the end of the first play and the end of the
% second play).

    preparation_time = zeros(numel(plays), 1);
    
    % At least one play with at least one event is assumed to exist
    last_play  = plays{1};
    
    last_match  = '';
    last_period = '';

    for i = 1:numel(plays)
        
        current_play   = plays{i};
        current_match  = current_play(1).matchId;
        current_period = current_play(1).matchPeriod;
        
        is_same_match  = current_match == last_match;
        is_same_period = strcmp(current_period, last_period);
        
        is_valid_preparation_time = is_same_match & is_same_period;
        
        if is_valid_preparation_time
            preparation_time(i) = round(findTimeDelta(current_play, last_play));
        else
            preparation_time(i) = NaN; % First event in the match has no preparation time
        end
        
        last_play   = current_play;
        last_match  = current_match;
        last_period = current_period;
        
    end


end


function time_delta = findTimeDelta(current_play, last_play)
    end_time   = last_play(end).eventSec;
    start_time = current_play(1).eventSec;
    
    time_delta = start_time - end_time;
    
    % Sanity check
    if time_delta < 0
        error('Invalid time delta')
    end
end