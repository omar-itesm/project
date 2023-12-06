function [play_indexes, filtered_plays] = filterPlaysByUseCase(plays, use_case)
    % Supported use cases:
    %   CORNER_USE_CASE    = 1;
    %   FREE_KICK_USE_CASE = 2;
    %   GOAL_KICK_USE_CASE = 3;
    %   THROW_IN_USE_CASE  = 4;
    %   INVALID_USE_CASE   = 0;

    play_indexes = [];
    
    for i = 1:numel(plays)
        
        play = plays{i};
        
        play_use_case = getPlayUseCases(play);
        if play_use_case == use_case
            play_indexes = [play_indexes i];
        end
    end
    
    filtered_plays = cell(numel(play_indexes), 1);
    
    for i = 1:numel(play_indexes)
        play_index = play_indexes(i);
        
        filtered_plays{i} = plays{play_index};
    end
    
    
end