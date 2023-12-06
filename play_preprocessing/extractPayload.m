function [play_metadata, play_payload] = extractPayload(play, label, use_case, source_db)
% At the moment, the function only detects the payload of corner plays that
% ended in goal. NOTE: This function may change significantly for
% automatically discovered use_cases.

% TODO: Attempt removing this funciton as it seems outdated.

    % Labels
    GOAL = 1;
    
    % Local variables
    CORNER_USE_CASE    = 1;
    FREE_KICK_USE_CASE = 2;
    GOAL_KICK_USE_CASE = 3;
    THROW_IN_USE_CASE  = 4;
    INVALID_USE_CASE   = 0;
    
    use_prefix = false;
    use_suffix = true;

    % Initialize data
    play_metadata.prefix = '';
    play_metadata.suffix = '';
    play_metadata.class  = '100'; % INVALID
    
    %% PREFIX
    % Remove the first event if applicable
    applicable_use_cases = [CORNER_USE_CASE, FREE_KICK_USE_CASE, GOAL_KICK_USE_CASE, THROW_IN_USE_CASE];
%     applicable_use_cases = [CORNER_USE_CASE];
    is_applicable        = any(applicable_use_cases == use_case);
    
    if is_applicable && use_prefix
        
        play_metadata.prefix = play(1); % FIXME: Make sure the play is non empty
        play(1) = [];
    end

    %% SUFFIX
	% TODO: Look for all adjacent events of these types and use that as the suffix
    % Remove the last event if applicable
    applicable_last_events = ["Save attempt", "Interception", "Foul", "Clearance", "Offside"];
%     applicable_last_events = ["Save attempt"];
    last_event             = play(end).eventName;
    is_applicable          = any(applicable_last_events == last_event);
    
    if is_applicable && use_suffix
        
        % Store the metadata
        play_metadata.suffix = play(end);

        % Remove the save attempt event
        play(end) = [];
        
    end
    
    %% PAYLOAD
    
    % The modified play is the payload
    play_payload = play;
    
    
    %% METADATA
    % Assign the label class metadata
    play_metadata.class = label;

    % Assign the source database
    play_metadata.source_db = source_db;
    
end