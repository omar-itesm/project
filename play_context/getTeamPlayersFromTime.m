function current_team_players = getTeamPlayersFromTime(match_data, team_id, time)
    % Local variables
    team_subs_info = struct();

    % Extract the original team formation
    [local_team, local_team_pids, visit_team, visit_team_pids] = getMatchPlayers(match_data);
    
    % Get the substitutions from the time
    for f = fieldnames(match_data.teamsData)'
        
        extended_team_id = f{1};
        current_team_id  = match_data.teamsData.(extended_team_id).teamId;
        
        if current_team_id == team_id
            team_subs_info      = getTeamSubsInfo(match_data, extended_team_id);
        end
    end
    
    % Grab the players corresponding to the input query
    if local_team == team_id
        players_of_interest = local_team_pids;
    else
        players_of_interest = visit_team_pids;
    end
    
    % Get the team formation at the time of the event
    current_team_players = getCurrentPlayersFromTime(players_of_interest, team_subs_info, time);
    
end
%% Helper functions

function current_team_players = getCurrentPlayersFromTime(base_players, team_subs_info, time)

    % Intialize output
    current_team_players = base_players;

    % If no substitutions were made return the same vector
    if isempty(team_subs_info)
        return;
    end
    
    % Check for substitutions made at the current time
    active_substitution_filter = team_subs_info.team_subs_minute <= time;
    active_in_players          = team_subs_info.team_player_in(active_substitution_filter);
    active_out_players         = team_subs_info.team_player_out(active_substitution_filter);
    
    if any(active_substitution_filter)
        current_team_players = performSubstitutions(base_players, active_in_players, active_out_players);
    end
    
end

function team_players = performSubstitutions(base_players, in_players, out_players)
    for i = 1:numel(out_players)
        current_out = out_players(i);
        current_in  = in_players(i);
        base_players(base_players == current_out) = current_in;
    end
    
    team_players = base_players;
end