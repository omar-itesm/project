function [possible_formations, time_thresh] = getPossibleTeamFormations(match_data, team_id)
    
    % Get the substitution info for the target team
    for f = fieldnames(match_data.teamsData)'
        
        extended_team_id = f{1};
        current_team_id  = match_data.teamsData.(extended_team_id).teamId;
        
        if current_team_id == team_id
            team_subs_info      = getTeamSubsInfo(match_data, extended_team_id);
        end
    end
    
    % Get the possible team formations
    num_subs = numel(team_subs_info.team_subs_minute);
    
    
    possible_formations = cell(1, num_subs + 1);  % One formation per substitution + original formation
    time_thresh         = zeros(1, num_subs + 1); % The maximum time where the formation is valid
    
    initial_time = 0;
    possible_formations{1} = getTeamPlayersFromTime(match_data, team_id, initial_time);
    
    for j = 2:num_subs + 1

        current_subs_time = team_subs_info.team_subs_minute(j - 1);

        possible_formations{j} = getTeamPlayersFromTime(match_data, team_id, current_subs_time);
        time_thresh(j-1)         = current_subs_time; % TODO: Verify
    end
    
    time_thresh(end) = 200; % Dummy value to capture that the last formation is valid the rest of the game
end