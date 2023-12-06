function teamIds = getTeamsFromMatchData(match_data)
% The function returns a list of all the unique teams in the tournament
% using the match data set.

    teams_data = {match_data.teamsData};
    teams_data = cellfun(@(x) fieldnames(x)', teams_data, 'UniformOutput', false);
    teams_data = horzcat(teams_data{:});
    
    unique_teams = string(unique(teams_data));
    teamIds      = cell2mat(cellfun(@(x) str2double(x(2:end)), unique_teams, 'UniformOutput', false));

end