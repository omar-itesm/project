function [dataset_plays, end_of_play_reason] = findPlays(dataset)
% FINDPLAYS receives a dataset and creates a list of tuples (plays) where 
% each tuple contains a play's initial and final index.
% Inputs:
%     dataset   - Structure containing the result of decoding the raw json
%                 dataset.
% Outputs:
%     plays     - List of tuples with the initial and final index of all
%                 plays.

    % BEGIN: Optimize
    match_ids     = unique([dataset.matchId]);
    total_matches = numel(match_ids);
    % END: Optimize
    
    % Variable array
    dataset_plays       = [];
    end_of_play_reason  = [];
    
    for i=1:total_matches
        
        current_match_id     = match_ids(i);
        current_match_filter = [dataset.matchId] == current_match_id;
        current_match_data   = dataset(current_match_filter);
        
        init_index    = find(current_match_filter, 1, 'first');
        
        [match_plays, reason] = findMatchCornerKickPlays(current_match_data);
        match_plays   = compensatePlayIndexes(match_plays, init_index);
        
        dataset_plays       = [dataset_plays; match_plays];
        end_of_play_reason  = [end_of_play_reason; reason];
    end
end