function [offensive_mv, defensive_mv] = getAverageTeamMarketValue(plays, match_data, pid_to_tf_pid, tf_market_value_dictionary)
% The function computes the market value for the offensive and defensive
% team in each play.

    match_ids = [match_data.wyId];
    
    offensive_mv  = zeros(numel(plays), 1);
    defensive_mv  = zeros(numel(plays), 1);
    
    prev_match_id = -1;

    for i=1:numel(plays)
       current_play       = plays{i};
       current_team       = current_play.teamId;
       match_id           = current_play.matchId;
       
       play_match_period     = current_play(1).matchPeriod;
       play_initial_time_sec = current_play(1).eventSec;
       play_initial_time_min = convertEventSecToMin(play_initial_time_sec,play_match_period);
       
       if match_id ~= prev_match_id
           current_match_data   = match_data(match_ids == match_id);
           current_match_date = datetime(current_match_data.dateutc);
           [local_team, ~, visit_team, ~] = getMatchPlayers(current_match_data);
           
           % Get all possible team formations for the local and visit team
           [local_team_formations, local_time_thresh] = getPossibleTeamFormations(current_match_data, local_team);
           [visit_team_formations, visit_time_thresh] = getPossibleTeamFormations(current_match_data, visit_team);
           
           % Compute the mv for all possible team configurations based
           % on the substitutions.
           local_team_mv_vec = cellfun(@(x) getPlayerMarketValues(x, pid_to_tf_pid, tf_market_value_dictionary, current_match_date), local_team_formations, 'UniformOutput', false);
           visit_team_mv_vec = cellfun(@(x) getPlayerMarketValues(x, pid_to_tf_pid, tf_market_value_dictionary, current_match_date), visit_team_formations, 'UniformOutput', false);
       end
       
       % Select the right formation of the current time
       local_time_select = find(play_initial_time_min <= local_time_thresh);
       local_time_select = local_time_select(1);
       current_local_team_mv_vec = local_team_mv_vec{local_time_select};
       
       visit_time_select = find(play_initial_time_min <= visit_time_thresh);
       visit_time_select = visit_time_select(1);
       current_visit_team_mv_vec = visit_team_mv_vec{visit_time_select};
       
       local_team_avg_mv = round(nanmean(current_local_team_mv_vec));
       local_team_avg_mv = round(local_team_avg_mv/1e6,1); % Expressed in million euros
       
       visit_team_avg_mv = round(nanmean(current_visit_team_mv_vec));
       visit_team_avg_mv = round(visit_team_avg_mv/1e6,1);
       
       if current_team == local_team
           offensive_mv(i) = local_team_avg_mv;
           defensive_mv(i) = visit_team_avg_mv;
       else
           offensive_mv(i) = visit_team_avg_mv;
           defensive_mv(i) = local_team_avg_mv;
       end
       
       prev_match_id = match_id;
       
    end
end

function time_min = convertEventSecToMin(event_sec, match_period)
    switch(match_period)
        case "1H"
            time_min = event_sec / 60;
        case "E1"
            time_min = 45;
        case "2H"
            time_min = 45 + (event_sec / 60);
        case "E2"
            time_min = 90;
        case "P"
            time_min = 90;
        otherwise
            time_min = NaN;
    end
end

function player_mvs = getPlayerMarketValues(player_ids, pid_to_tf_pid, tf_market_value_dictionary, match_date)
    player_mvs = zeros(numel(player_ids), 1);
    
    for i = 1:numel(player_ids)
        current_player_id   = player_ids(i);
        
        player_mvs(i)      = getPlayerMarketValue(current_player_id, pid_to_tf_pid, tf_market_value_dictionary, match_date);
    end
end