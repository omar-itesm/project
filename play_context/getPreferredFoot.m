function preferred_foot = getPreferredFoot(player_data, corner_plays)
% The function receives a set of corner plays and a list of player data to
% extract the preferred foot from the player data for each corner kick in
% the plays.

    player_ids = [player_data.wyId];
    
    preferred_foot = strings(numel(corner_plays), 1);
    
    
    for i=1:numel(corner_plays)
        current_play      = corner_plays{i};
        corner_kick_event = current_play(1);
        
        % Sanity check
        if ~is_valid_corner_kick_event(corner_kick_event)
            error('Invalid corner kick event');
        end
            
        kicker            = corner_kick_event.playerId;
        if kicker ~= 0
            preferred_foot(i) = player_data(player_ids == kicker,:).foot{:};
        else
            % The player is not found, assign Weka's NaN string
            preferred_foot(i) = '?';
        end
        
    end
    
    % Simplify the notation
    preferred_foot(preferred_foot=='left') = 'L';
    preferred_foot(preferred_foot=='right') = 'R';
    
end

function is_valid = is_valid_corner_kick_event(corner_kick_event)
    if strcmp(corner_kick_event.subEventName, 'Corner')
        is_valid = true;
    else
        is_valid = false;
    end
end