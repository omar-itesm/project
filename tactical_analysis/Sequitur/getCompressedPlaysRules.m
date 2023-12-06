function rules_per_play = getCompressedPlaysRules(compressed_plays_file)
    rules_per_play = {}; % FIXME
    
    fid = fopen(compressed_plays_file);
    
    play_index = 1;
    
    try
        compressed_play = fgetl(fid);
        while ischar(compressed_play)
            % Decode the compressed play
            strrep(compressed_play,', ',',');
            compressed_play = strrep(compressed_play,', ',',');
            compressed_play = strrep(compressed_play,'Production(','');
            compressed_play = strrep(compressed_play,')','');
            compressed_play = strrep(compressed_play,"'",'');
            compressed_play = char(compressed_play);
            compressed_play = compressed_play(2:end-1);

            split_play = regexp(compressed_play, ',', 'split');
            
            
            play_rules = [];
            for event_index = 1:numel(split_play)
                current_event = split_play{event_index};

                isRule = ~isnan(str2double(current_event));
                
                if isRule
                    rule       = str2double(current_event);
                    play_rules = [play_rules rule];
                end
                
            end
            
            rules_per_play{play_index} = play_rules;
            
            % Prepare for next cycle
            compressed_play = fgetl(fid);
            play_index = play_index + 1;
        end
    catch e
        fclose(fid);
        throw(e);
    end

end