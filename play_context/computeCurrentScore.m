function [current_score_vec, offensive_team_score, defensive_team_score] = computeCurrentScore(match_data, plays)
% The function receives a set of contiguous plays and finds the current
% score at the time of the play by counting the number of goals from either
% team during a match. The function assumes that the plays are ordered as
% they ocurred during the match. Notice that if the current play has a goal
% in it, it doesn't counts for the current score.

    GOAL_LABEL = 1;
    match_ids = [match_data.wyId];

    current_score_vec    = zeros(numel(plays), 1);
    offensive_team_score = zeros(numel(plays), 1);
    defensive_team_score = zeros(numel(plays), 1);
    
   score        = 0;
   local_team_score    = 0;
   visit_team_score    = 0;
    
    prev_match_id = -1;
    
    for i = 1:numel(plays)
        current_play  = plays{i};
        match_id      = current_play.matchId;
        
        play_label    = labelPlay(current_play, 'useOwnGoal', true);
        
        current_team  = current_play(1).teamId;
        
        if match_id ~= prev_match_id
            current_match_data   = match_data(match_ids == match_id);

            % Reset scores due to match change
            [local_team, ~, visit_team, ~] = getMatchPlayers(current_match_data);

            score        = 0;
            local_team_score    = 0;
            visit_team_score    = 0;
        else
            % Compute accumulated score
            has_goal = play_label == GOAL_LABEL;
            if has_goal
                if current_team == local_team
                    local_team_score = local_team_score + 1;
                else
                    visit_team_score = visit_team_score + 1;
                end
                
                score = score + 1;
            end
        end

       % Store the score
       if current_team == local_team
           offensive_team_score(i) = local_team_score;
           defensive_team_score(i) = visit_team_score;
       else
           offensive_team_score(i) = visit_team_score;
           defensive_team_score(i) = local_team_score;
       end
       
       current_score_vec(i) = score;
       
       prev_match_id = match_id;
       
    end

end


