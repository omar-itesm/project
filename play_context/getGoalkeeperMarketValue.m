function goalkeeper_mv = getGoalkeeperMarketValue(plays, match_data, player_data, pid_to_tf_pid, tf_market_value_dictionary)
% The function computes the market value of the defensive team goalkeeper,
% it does not considers substitutions (fixme...).


    match_ids = [match_data.wyId];
    
    goalkeeper_mv  = zeros(numel(plays), 1);
    
    prev_match_id = -1;

    for i=1:numel(plays)
       current_play       = plays{i};
	   current_team       = current_play(1).teamId;
       match_id           = current_play.matchId;
       
       if match_id ~= prev_match_id
           current_match_data = match_data(match_ids == match_id);
           current_match_date = datetime(current_match_data.dateutc);

           [local_team, local_team_pids, visit_team, visit_team_pids] = getMatchPlayers(current_match_data);
           
           local_team_gk_id   = getGkPlayerId(local_team_pids, player_data);
           visit_team_gk_id   = getGkPlayerId(visit_team_pids, player_data);
           
           local_team_gk_mv    = getPlayerMarketValue(local_team_gk_id, pid_to_tf_pid, tf_market_value_dictionary, current_match_date);
           visit_team_gk_mv    = getPlayerMarketValue(visit_team_gk_id, pid_to_tf_pid, tf_market_value_dictionary, current_match_date);
       end
       
       if current_team == local_team
           goalkeeper_mv(i) = visit_team_gk_mv; % Defensive team goalkeeper value
       else
           goalkeeper_mv(i) = local_team_gk_mv; % Defensive team goalkeeper value
       end
       
       % Express market value in million Euros
       goalkeeper_mv(i) = round(goalkeeper_mv(i)/1e6,2);
       
       prev_match_id = match_id;
       
    end
end

function gk_player_id = getGkPlayerId(team_ids, player_data)
    % The function returns the id of the goalkeeper from the ids of a given
    % team formation.
    team_data  = player_data(any(player_data.wyId == team_ids,2), :);
    team_roles = team_data(:,:).role;
    team_roles = {team_roles.name};
    
    is_gk = strcmp(team_roles, 'Goalkeeper');
    
    gk_player_id = team_data.wyId(is_gk);
    
    if isempty(gk_player_id)
        gk_player_id = -1;
        warning('Impossible to detect goalkeeper from team ids');
    end
end
