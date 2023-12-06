function use_case = getPlayUseCases(play)
    % At the moment, the function only detects corner kicks
    % none    = 0
    % corner  = 1;
    % penalty = 2;
    % etc.
    
    % Local variables
    CORNER_USE_CASE    = 1;
    FREE_KICK_USE_CASE = 2;
    GOAL_KICK_USE_CASE = 3;
    THROW_IN_USE_CASE  = 4;
    INVALID_USE_CASE   = 0;
    
    % Check if the play STARTS with a given subEvent
	% NOTE:
	% - By looking at the subevent we ensure that we get the right filter
	%   even if the original event has been modified.
    first_event = play(1).subEventName;
    
    switch(first_event)
        case "Corner"
            use_case = CORNER_USE_CASE;
        case "Free Kick"
            use_case = FREE_KICK_USE_CASE;
        case "Goal Kick"
            use_case = GOAL_KICK_USE_CASE;
        case "Throw in"
            use_case = THROW_IN_USE_CASE;
        otherwise
            use_case = INVALID_USE_CASE;
    end
    
end