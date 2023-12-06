function [local_team, local_team_pids, visit_team, visit_team_pids] = getMatchPlayers(match_data)
    for f = fieldnames(match_data.teamsData)'
        side = match_data.teamsData.(f{1}).side;
        
        if strcmp(side, 'home')
            local_team      = match_data.teamsData.(f{1}).teamId;
            local_team_pids = [match_data.teamsData.(f{1}).formation.lineup.playerId];
        else
            visit_team      = match_data.teamsData.(f{1}).teamId;
            visit_team_pids = [match_data.teamsData.(f{1}).formation.lineup.playerId];
        end
    end
end