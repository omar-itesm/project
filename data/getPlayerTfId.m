function tf_player_id = getPlayerTfId(player_id, player_data, tf_player_data)
% The function receives the player id from the Pappalardo's data set and
% retrieves the player Id from the transfermarkt data set. This tf id can
% be used to retrieve other player information from any transfermarkt data
% set. The code is based on matching the date of birth and other filters
% until we are sure that we are referring to the same player.

    % Convert the player data to a table if it is not one already. To avoid
    % making this conversion multiple times, make sure the data is passed
    % as a table.
    if ~isa(player_data, 'table')
        player_data = struct2table(player_data);
    end
    
    % Grab all the current player data
    current_player_data = player_data(player_data.wyId==player_id, :);
    
    % Grab the date of birth
    dob = current_player_data.birthDate{:};
    dob = datetime(dob, 'InputFormat', 'yyyy-MM-dd');
    
    % Match the date of birth with the date of birth in the transfermarkt
    % data set.
    matched_players = tf_player_data(tf_player_data.date_of_birth == dob, :);
    
    if ~isempty(matched_players)
        % Further filter the list based on the name of the player
        
        player_name = regexprep(strjoin([current_player_data.firstName, current_player_data.middleName, current_player_data.lastName]),'\s+',' ');
        
        name_distance   = editDistance(player_name, matched_players.pretty_name);

        matched_player  = matched_players(name_distance == min(name_distance), :);

        tf_player_id    = matched_player.player_id;
        tf_player_id    = tf_player_id(1); % In case of two matches keep the first
        
        acceptance_thresh = 15;
        if min(name_distance) > acceptance_thresh
            tf_player_id = -1;
        end
        
%         assert(min(name_distance) > 8, 'Suspicious name match in getPlayerTfId');
        
    else
        tf_player_id    = -1; % The player was not found in the database based on the dob
    end
    

    
end