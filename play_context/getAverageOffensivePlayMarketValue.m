function avg_off_play_mv = getAverageOffensivePlayMarketValue(plays, match_data, pid_to_tf_pid, tf_market_value_dictionary)

    avg_off_play_mv  = zeros(numel(plays), 1);
    match_ids        = [match_data.wyId];

    for i=1:numel(plays)
       current_play       = plays{i};
       current_team       = current_play.teamId;
       match_id           = current_play.matchId;
       current_match_data = match_data(match_ids == match_id);
       current_match_date = datetime(current_match_data.dateutc);

       play_team_ids   = [current_play.teamId];
       play_player_ids = [current_play.playerId];
       % Some plays have events associated to no player (player id = 0)
       play_player_ids = play_player_ids(play_player_ids ~= 0);
       play_team_ids   = play_team_ids(play_player_ids ~= 0);
       
       current_team_players = unique(play_player_ids(play_team_ids == current_team));

       
       player_mvs = zeros(numel(current_team_players), 1);
       for j = 1:numel(current_team_players)
           current_id = current_team_players(j);
           player_mvs(j) = getPlayerMarketValue(current_id, pid_to_tf_pid, tf_market_value_dictionary, current_match_date);
       end
       
       
%         player_mvs(isnan(player_mvs)) = nanmean(player_mvs);
        
        avg_market_value   = round(nanmean(player_mvs));
        
        if isnan(avg_market_value)
            avg_off_play_mv(i) = avg_market_value;
        else
            avg_off_play_mv(i) = round(avg_market_value/1e6,1); % Expressed in million euros
        end
        
        
        
    end
end