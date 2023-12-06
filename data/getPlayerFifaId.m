function fifa_player_id = getPlayerFifaId(player_id, player_data, fifa_player_data)

    load country_relational_db.mat

    % Convert the player data to a table if it is not one already. To avoid
    % making this conversion multiple times, make sure the data is passed
    % as a table.
    if ~isa(player_data, 'table')
        player_data = struct2table(player_data);
    end
    
    % Grab all the current player data
    current_player_data = player_data(player_data.wyId==player_id, :);
    
%     % Grab the date of birth
%     dob = current_player_data.birthDate{:};
%     dob = datetime(dob, 'InputFormat', 'yyyy-MM-dd');

    % Grab nationality
    nationality = current_player_data.birthArea.name;
    
    fifa_nationality = country_relational_db.fifa_nationality(strcmp(nationality, country_relational_db.nationality));
    
    % Match the date of birth with the date of birth in the transfermarkt
    % data set.
    matched_players = fifa_player_data(strcmp(fifa_player_data.Nationality, fifa_nationality), :);
    
    if ~isempty(matched_players)
        % Further filter the list based on the name of the player
        
        %player_name = regexprep(strjoin([current_player_data.firstName, current_player_data.middleName, current_player_data.lastName]),'\s+',' ');
        player_name = current_player_data.shortName;
        
        name_distance   = editDistance(player_name, matched_players.Name);

        matched_player  = matched_players(name_distance == min(name_distance), :);

        fifa_player_id    = matched_player.ID;
        fifa_player_id    = fifa_player_id(1); % In case of two matches keep the first
        
        acceptance_thresh = 15;
        if min(name_distance) > acceptance_thresh
            fifa_player_id = -1;
        end
        
%         assert(min(name_distance) > 8, 'Suspicious name match in getPlayerTfId');
        
    else
        fifa_player_id    = -1; % The player was not found in the database based on the dob
    end
    


end