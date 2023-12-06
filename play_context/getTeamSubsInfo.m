function team_subs_info = getTeamSubsInfo(match_data, team_extended_id)
    % team_extended_id corresponds to the team id as specified in the match
    % data. Example: x9598.
    %% Local variables
    team_player_in   = [];
    team_player_out  = [];
    team_subs_minute = [];
    
    %% Compute the variables
    team_subs_info_raw   = match_data.teamsData.(team_extended_id).formation.substitutions;

    if ~isempty(team_subs_info_raw) && ~strcmp(team_subs_info_raw, 'null')
        team_player_in   = [team_subs_info_raw.playerIn];
        team_player_out  = [team_subs_info_raw.playerOut];
        team_subs_minute = [team_subs_info_raw.minute];
        
    else
        % disp('No substitutions found');
        % Do nothing...
    end
    
    team_subs_info.team_player_in    = team_player_in;
    team_subs_info.team_player_out   = team_player_out;
    team_subs_info.team_subs_minute  = team_subs_minute;
end