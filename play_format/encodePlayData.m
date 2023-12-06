function [play_f] = encodePlayData(play, LUT, encoding, algorithm)
    num_events = numel(play);
    
    % Preallocate memory for the coded play according to the datatype used
    % by the algorithm.
    if strcmp(algorithm, 'tks')
        play_f     = zeros(num_events, 1);
    elseif strcmp(algorithm, 'sequitur')
        play_f     = strings(num_events, 1); 
    else
        error('Invalid algorithm type');
    end

    try
        switch(encoding)
            case 'simple'
                %%%%%%%% SIMPLE ENCODING %%%%%%%%%%%%%%
                for i = 1:num_events
                    current_event = play(i);
                    play_f(i)     = applySimpleEncoding(LUT, current_event, algorithm);
                end
            case 'VH'
                %%%%%%%% VAN HAAREN ENCODING %%%%%%%%%%
                for i = 1:num_events
                    current_event = play(i);
                    play_f(i)     = applyVanHaarenEncoding(LUT, current_event, algorithm);
                end
            case '18Z'
                %%%%%%%% 18 zones encoding %%%%%%%%%%
                for i = 1:num_events
                    current_event = play(i);
                    play_f(i)     = applyEighteenEncoding(LUT, current_event, algorithm);
                end
            case '8Dir'
                %%%%%%%% 8 directions of movement encoding %%%%%%%%%%
                for i = 1:num_events
                    current_event = play(i);
                    play_f(i)     = applyEightDirEncoding(LUT, current_event, algorithm);
                end
            case 'cannonical_corner_region_5'
                for i = 1:num_events
                    current_event = play(i);
                    final_pos     = get_event_final_pos(current_event);
                    play_f(i)     = applyCannonicalCornerEncoding(LUT, current_event, final_pos, algorithm, 'encoding', encoding); 
                end
            case 'cannonical_corner_region_7'
                for i = 1:num_events
                    current_event = play(i);
                    final_pos     = get_event_final_pos(current_event);
                    play_f(i)     = applyCannonicalCornerEncoding(LUT, current_event, final_pos, algorithm, 'encoding', encoding); 
                end
            otherwise
                warning('Invalid algorithm type');
        end
    catch e
       disp(e);
    end
    
end