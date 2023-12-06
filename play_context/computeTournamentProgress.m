function [tournament_progress, real_week] = computeTournamentProgress(match_data, plays)

    tournament_progress = zeros(numel(plays),1);
        
    competitions        = [match_data.competitionId];
    unique_competitions = unique(competitions);
    
    real_week           = cell(1, numel(unique_competitions));
    
    for j=1:numel(unique_competitions)
        competition_matches = match_data(competitions == unique_competitions(j));
        competition_rounds  = [competition_matches.roundId];
        unique_rounds       = unique(competition_rounds);
        
        last_week = computeNumWeeks(competition_matches(competition_rounds == unique_rounds(1)));
        
        current_real_week = zeros(numel(competition_matches), 1);
        current_real_week(competition_rounds == unique_rounds(1)) = [competition_matches(competition_rounds == unique_rounds(1)).gameweek];
        
        % Compute incremental week information
        for i=2:numel(unique_rounds)
            round_match_data = competition_matches(competition_rounds == unique_rounds(i));
            last_week        = last_week + computeNumWeeks(round_match_data);


            current_real_week(competition_rounds == unique_rounds(i)) = last_week;
        end
        
        real_week{j} = current_real_week;

        match_progress = current_real_week./max(current_real_week);

        match_ids     = [competition_matches.wyId];
        for i=1:numel(plays)
            current_play  = plays{i};
            current_match = current_play.matchId;

            is_current_match = any(match_ids == current_match);
            
            if is_current_match
                current_progress = match_progress(match_ids == current_match);
                tournament_progress(i) =  round(current_progress,1);
            end
        end
    end
        
end

function num_weeks = computeNumWeeks(round_data)
    num_weeks = numel(unique([round_data.gameweek]));
end