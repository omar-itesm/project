function [plays] = playSeparation(database, play_indexes, varargin)

    %% Parser
    default_index_offset = 0;
    
    p = inputParser;
    
    addRequired(p, 'database'     , @(x) isa(x,'struct'));
    addRequired(p, 'play_indexes' , @(x) isa(x,'double'));
    addOptional(p, 'index_offset' , default_index_offset);

    parse(p, database, play_indexes, varargin{:});
    
    offset      = p.Results.index_offset;

    %% Play separation
    size_play_indexes = size(play_indexes);
    num_plays         = size_play_indexes(1);
    
    plays = cell(num_plays, 1);
    
    for play_index=1:num_plays
        current_play_indexes = play_indexes(play_index,:);
        
        init_play_index      = current_play_indexes(1);
        final_play_index     = current_play_indexes(2);
        
        current_play         = database(init_play_index:final_play_index);
        
        current_play         = addPlayId(current_play, play_index + offset);
        
        plays{play_index} = current_play;
    end
end

function play = addPlayId(play, play_id)
% The function add an identifier to all events of the input play.
    for event_index = 1:numel(play)
        play(event_index).play_id = play_id;
    end
end