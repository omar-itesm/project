function [offensive_height, defensive_height] = getTeamHeightsForPlay(match_data, player_data, plays)
% The function computes the average offensive and defensive team heights
% for for a given play. NOTE: Only the original lineup is considered but it
% might be a good idea to fix this to include the substitutions in the
% computation.

    match_ids = [match_data.wyId];
    
    offensive_height  = zeros(numel(plays), 1);
    defensive_height  = zeros(numel(plays), 1);
    
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
           [local_team, ~, visit_team, ~] = getMatchPlayers(current_match_data);
           
           % Get all possible team formations for the local and visit team
           
           [local_team_formations, local_time_thresh] = getPossibleTeamFormations(current_match_data, local_team);
           [visit_team_formations, visit_time_thresh] = getPossibleTeamFormations(current_match_data, visit_team);
           
           % Compute the height for all possible team configurations based
           % on the substitutions.
           local_team_heights_vec = cellfun(@(x) getPlayerHeights(x, player_data), local_team_formations, 'UniformOutput', false);
           visit_team_heights_vec = cellfun(@(x) getPlayerHeights(x, player_data), visit_team_formations, 'UniformOutput', false);
       end
       
       % Select the right formation of the current time
       local_time_select = find(play_initial_time_min <= local_time_thresh);
       local_time_select = local_time_select(1);
       current_local_team_height_vec = local_team_heights_vec{local_time_select};
       
       visit_time_select = find(play_initial_time_min <= visit_time_thresh);
       visit_time_select = visit_time_select(1);
       current_visit_team_height_vec = visit_team_heights_vec{visit_time_select};
       
       local_team_avg_height = round(mean(current_local_team_height_vec));
       visit_team_avg_height = round(mean(current_visit_team_height_vec));
       
       if current_team == local_team
           offensive_height(i) = local_team_avg_height;
           defensive_height(i) = visit_team_avg_height;
       else
           offensive_height(i) = visit_team_avg_height;
           defensive_height(i) = local_team_avg_height;
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

function player_heights = getPlayerHeights(player_ids, player_data)
    player_heights = zeros(numel(player_ids), 1);
    
    invalid_player_id = 0;
    
    for i = 1:numel(player_ids)
        current_player_id   = player_ids(i);
        if current_player_id ~= invalid_player_id
            current_player_data = player_data(player_data.wyId == current_player_id, :);
            current_height      = current_player_data.height;
        else
            current_height      = NaN;
        end


        player_heights(i)   = current_height;
    end
    
    non_zero_filter = player_heights ~= 0;
    non_nan_filter  = ~isnan(player_heights);
    
    player_heights = player_heights(non_zero_filter & non_nan_filter);

    player_heights = round(mean(player_heights));
end
