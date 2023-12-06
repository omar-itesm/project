function team_names = getTeamNames(team_data, plays)
    team_names = strings(numel(plays),1);
    team_ids   = [team_data.wyId];
    
    for i=1:numel(plays)
       current_play = plays{i};
       current_team = current_play.teamId;
       
       current_team_data = team_data(team_ids == current_team);
       
       team_names(i) = current_team_data.name;
        
        
    end

    team_names = erase(team_names, " ");
    
end