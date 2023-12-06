function avg_off_age = getAverageOffensivePlayAge(plays, match_data, player_data, avg_off_team_age)
% The function computes the average height of the offensive players
% participating in each input play.
    
    match_ids    = [match_data.wyId];
    avg_off_age  = zeros(numel(plays), 1);

    for i=1:numel(plays)
        
        current_play       = plays{i};
        current_team       = current_play(1).teamId;
        match_id           = current_play(1).matchId;

        current_match_data = match_data(match_ids == match_id);
        match_date         = datetime(current_match_data.dateutc);
        
        % Do not consider the height of the player taking the corner
        avg_player_age = getAverageOffensiveTeamAge(current_play, player_data, current_team, match_date);
        
        if isnan(avg_player_age)
            avg_player_age = avg_off_team_age(i);
        end
        
        if isnan(avg_player_age)
            avg_player_age = -1;
        end
        
        avg_off_age(i) = avg_player_age;
        
    end


end

function avg_player_age = getAverageOffensiveTeamAge(play, player_data, current_team, match_date)
    
    play_team_ids   = [play.teamId];
    play_player_ids = [play.playerId];
    
    % Some plays have events associated to no player (player id = 0)
    valid_play_player_ids = play_player_ids(play_player_ids ~= 0);
    valid_play_team_ids   = play_team_ids(play_player_ids ~= 0);

    current_team_players = unique(valid_play_player_ids(valid_play_team_ids == current_team));

    player_age = getPlayerAges(current_team_players, player_data, match_date);

    non_zero_filter = player_age ~= 0;
    non_nan_filter  = ~isnan(player_age);
    
    player_age = player_age(non_zero_filter & non_nan_filter);

    avg_player_age   = round(mean(player_age));
end

function player_ages = getPlayerAges(player_ids, player_data, match_date)
    player_ages = zeros(numel(player_ids), 1);
    
    for i = 1:numel(player_ids)
        current_player_id   = player_ids(i);
        
        player_ages(i)      = computePlayerAge(current_player_id, match_date, player_data);
    end
    
    % Some players have no information. Substitute with the mean
    % value for the team.
    player_ages(player_ages == 0) = nanmean(player_ages);
end