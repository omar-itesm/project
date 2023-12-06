function [match_play_indexes, end_of_play_reason] = findMatchCornerKickPlays(match_data)
% FINDMATCHPLAYS finds the initial and final index for all the plays inside
% the match_data input dataset. It compensates the indexes using
% init_index.
% Inputs:
%     match_data  - Event log for a single match
%     init_index  - Compensation factor for the indexes of the play
% Outputs:
%     match_plays - List of tuples where each tuple contains a play's
%                   initial and final indexes w.r.t. the match_data and
%                   using an offset of init_index.

% Local variables
num_events         = numel(match_data);

% Variable size
match_play_indexes   = [];
end_of_play_reason   = [];

% Detect the indexes of all corner kick executions
for event_index=1:num_events
    current_event                       = match_data(event_index);
    if isCorner(current_event)
        initial_index         = event_index;
        [final_index, reason] = detectEndOfPlay(match_data, initial_index);
        
        play_indexes       = [initial_index, final_index];
        match_play_indexes = [match_play_indexes; play_indexes];
        end_of_play_reason = [end_of_play_reason; reason];
    end
end

end