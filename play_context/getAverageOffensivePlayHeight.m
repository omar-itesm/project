function avg_off_height = getAverageOffensivePlayHeight(plays, player_data, avg_off_team_height)
% The function computes the average height of the offensive players
% participating in each input play.

    avg_off_height  = zeros(numel(plays), 1);

    for i=1:numel(plays)
        
        current_play       = plays{i};
        current_team       = current_play(1).teamId;

        num_events = numel(current_play);
        
        if num_events > 1
            % Do not consider the height of the player taking the corner
            avg_player_height = getAverageOffensiveTeamHeight(current_play(2:end), player_data, current_team);
        else
            % The height of a play with only one player is irrelevant
            avg_player_height = NaN;
        end
        
        if isnan(avg_player_height)
            avg_player_height = avg_off_team_height(i);
        end
        
        if isnan(avg_player_height)
            avg_player_height = -1;
        end
        
        avg_off_height(i) = avg_player_height;
        
    end


end

function avg_player_height = getAverageOffensiveTeamHeight(play, player_data, current_team)
    
    play_team_ids   = [play.teamId];
    play_player_ids = [play.playerId];
    
    % Some plays have events associated to no player (player id = 0)
    valid_play_player_ids = play_player_ids(play_player_ids ~= 0);
    valid_play_team_ids   = play_team_ids(play_player_ids ~= 0);

    current_team_players = unique(valid_play_player_ids(valid_play_team_ids == current_team));

    player_height = zeros(numel(current_team_players), 1);
    for j = 1:numel(current_team_players)
       current_id = current_team_players(j);
       player_height(j) = getPlayerHeight(current_id, player_data);
    end

    non_zero_filter = player_height ~= 0;
    non_nan_filter  = ~isnan(player_height);
    
    player_height = player_height(non_zero_filter & non_nan_filter);

    avg_player_height   = round(mean(player_height));
end

function player_height = getPlayerHeight(player_id, player_data)
    current_player_data = player_data(player_data.wyId == player_id, :);
    player_height       = current_player_data.height;
end