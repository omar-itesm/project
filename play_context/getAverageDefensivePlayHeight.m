function avg_def_height = getAverageDefensivePlayHeight(plays, player_data, avg_def_team_height)
% The function computes the average height of the offensive players
% participating in each input play.
% TODO: It might be a good idea to discard the height of the player taking
% the corner kick. However, this may require some changes because I need to
% study if the failed corner kicks have defensive team heights because the
% player won't get a chance to shoot so is he even registered in the play
% data set?

    avg_def_height  = zeros(numel(plays), 1);

    for i=1:numel(plays)
        
        current_play       = plays{i};
        
        teams           = unique([current_play.teamId]);
        offensive_team  = current_play(1).teamId;
        
        defensive_team = teams(~(teams==offensive_team));
        
        if isempty(defensive_team)
            avg_player_height = NaN;
        else
            avg_player_height = getAverageDefensiveTeamHeight(current_play, player_data, defensive_team);
        end
        
        if isnan(avg_player_height)
%             avg_player_height = avg_def_team_height(i);
            avg_player_height = NaN; % Keep it as a NaN because it is very 
                                     % likely that the defensive team height 
                                     % is not present in the play. We don't
                                     % want to invent that much data.
        end
        
        if isnan(avg_player_height)
            avg_player_height = -1;
        end
        
        avg_def_height(i) = avg_player_height;
        
    end


end

function avg_player_height = getAverageDefensiveTeamHeight(play, player_data, current_team)
    
    play_team_ids   = [play.teamId];
    play_player_ids = [play.playerId];
    
    % Some plays have events associated to no player (player id = 0)
    valid_play_player_ids = play_player_ids(play_player_ids ~= 0);
    valid_play_team_ids   = play_team_ids(play_player_ids ~= 0);

    current_team_players = unique(valid_play_player_ids(valid_play_team_ids == current_team));

    player_height = zeros(numel(current_team_players), 1);
    for j = 1:numel(current_team_players)
       current_id = current_team_players(j);
       player_height(j) = getPlayerHeight(current_id, player_data);
    end

    non_zero_filter = player_height ~= 0;
    non_nan_filter  = ~isnan(player_height);
    
    player_height = player_height(non_zero_filter & non_nan_filter);

    avg_player_height   = round(mean(player_height));
end

function player_height = getPlayerHeight(player_id, player_data)
    current_player_data = player_data(player_data.wyId == player_id, :);
    player_height       = current_player_data.height;
end