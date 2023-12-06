function plays_duration = computePlayDuration(plays)
% The function receives a set of plays and finds the duration for all of
% the plays as the final time in the play minus the initial time. For plays
% of a single event, the duration is zero.

    plays_duration = zeros(numel(plays), 1);

    for i = 1:numel(plays)
        current_play      = plays{i};
        plays_duration(i) = round(p_duration(current_play));
    end

end

function play_duration = p_duration(play)
    first_event = play(1);
    last_event  = play(end);
    
    play_duration = last_event.eventSec - first_event.eventSec;
    
    % Sanity check
    if play_duration < 0
        play_duration = 0;
        % error('Invalid play duration')
    end
end