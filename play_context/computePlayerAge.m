function age = computePlayerAge(player_id, target_date, player_data)
% The function computes the age of a player in years from their date of
% birth until the target date.

    % Convert the player data to a table if it is not one already. To avoid
    % making this conversion multiple times, make sure the data is passed
    % as a table.
    if ~isa(player_data, 'table')
        player_data = struct2table(player_data);
    end
    
    % Grab all the current player data
    idx = find(player_data.wyId==player_id);
    current_player_data = player_data(idx, :);

    % Grab the date of birth
    dob = current_player_data.birthDate{:};
    dob = datetime(dob, 'InputFormat', 'yyyy-MM-dd');

    target_date = datetime(target_date);
    
    age = years(target_date - dob);
    
    age = round(age);

end