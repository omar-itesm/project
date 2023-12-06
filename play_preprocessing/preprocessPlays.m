function plays = preprocessPlays(plays, varargin)

    switch nargin
        case 1
            opts = setDefaultPreprocessOpts();
        case 2
            opts = varargin{1};
        otherwise
            error('Invalid number of parameters for playPreprocessing');
    end

    for play_index = 1:numel(plays)
       current_play = plays{play_index,:};
       
       plays{play_index} = playPreprocessing(current_play, opts);
    end
end