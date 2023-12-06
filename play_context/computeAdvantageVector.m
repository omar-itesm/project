function advantage_vector = computeAdvantageVector(match_data, real_week, team_ids, plays)

%     advantage_vector = strings(numel(plays), 1);
    advantage_vector = zeros(numel(plays), 1);

    competitions        = [match_data.competitionId];
    unique_competitions = unique(competitions);

    for tournament_id = 1:numel(unique_competitions)
        competition_matches  = match_data(competitions == unique_competitions(tournament_id));
        tournament_real_week = real_week{tournament_id};
        
        winner_team_ids  = [match_data.winner];
        wins_per_team    = computeWinsPerTeam(tournament_real_week, winner_team_ids, team_ids);

        match_ids = [competition_matches.wyId];

        last_match = -1;

        for i = 1:numel(plays)
            current_play   = plays{i};
            current_match  = current_play.matchId;
            current_team   = current_play.teamId;

            is_current_match = any(match_ids == current_match);
                
            if is_current_match
            
                if current_match ~= last_match
                    current_real_week = tournament_real_week(match_ids == current_match);

                    [team_1, team_2] = getMatchTeams(competition_matches, current_match);

                    wins_team_1 = wins_per_team.(string(team_1));
                    wins_team_2 = wins_per_team.(string(team_2));

                    current_wins_team_1 = wins_team_1(current_real_week);
                    current_wins_team_2 = wins_team_2(current_real_week);

                    % TODO: Consider creating three classes instead of only two
                    if current_wins_team_1 > current_wins_team_2
                        result = 'team_1';
                    elseif current_wins_team_2 > current_wins_team_1
                        result = 'team_2';
                    else
                        result = 'tie';
                    end
                end


                % THREE VALUE representation
                if current_team == team_1
                   if strcmp(result, 'team_1')
%                        advantage_vector(i) = 'adv';
                       advantage_vector(i) = current_wins_team_1 - current_wins_team_2; % Advantage
                   elseif strcmp(result, 'team_2')
%                        advantage_vector(i) = 'dis';
                       advantage_vector(i) = current_wins_team_1 - current_wins_team_2; % Disadvantage
                   else
%                        advantage_vector(i) = 'tie';
                       advantage_vector(i) = current_wins_team_1 - current_wins_team_2; % Tie
                   end
                else
                   if strcmp(result, 'team_1')
%                        advantage_vector(i) = 'dis';
                       advantage_vector(i) = current_wins_team_2 - current_wins_team_1; % Disadvantage
                   elseif strcmp(result, 'team_2')
%                        advantage_vector(i) = 'adv';
                       advantage_vector(i) = current_wins_team_2 - current_wins_team_1; % Advantage
                   else
%                        advantage_vector(i) = 'tie';
                       advantage_vector(i) = current_wins_team_2 - current_wins_team_1; % Tie
                   end
                end
                
            end

            % Prepare for next loop
            last_match = current_match;

        end
        
    end % tournament id
        
end

function win_count_matrix = computeWinsPerTeam(week_numbers, winner_team_ids, all_team_ids)

    % Create an empty matrix with the same number of rows as the maximum week number + 1 and the same number of columns as the number of teams
    num_weeks = max(week_numbers);
    num_teams = length(all_team_ids);
    win_count_matrix = zeros(num_weeks+1, num_teams);

    % Loop through each week number and count the number of wins for each team up to that week
    for i = 0:num_weeks
        week_mask = (week_numbers <= i);
        week_winners = winner_team_ids(week_mask);
        for j = 1:num_teams
            team_mask = (week_winners == all_team_ids(j));
            win_count_matrix(i+1,j) = sum(team_mask);
        end
    end

    win_count_matrix = array2table(win_count_matrix, 'VariableNames', string(all_team_ids));
end

function [team1, team2] = getMatchTeams(match_data, match_id)

    match_ids = [match_data.wyId];

    current_match = match_data(match_ids==match_id);
    
    teams_data = current_match.teamsData;
    
    match_teams = fieldnames(teams_data)';
    
    match_teams = cell2mat(cellfun(@(x) str2double(x(2:end)), match_teams, 'UniformOutput', false));
    
    team1 = match_teams(1);
    team2 = match_teams(2);
end



% function wins_per_team = computeWinsPerTeam(match_data, real_week, team_ids)
%     winners = [match_data.winner];
%     wins_per_team = zeros(numel(unique(real_week)) + 1, numel(team_ids));
%     
%     for j=1:numel(team_ids)
%         for i=1:numel(unique(real_week))
%             week_winners    = winners(real_week == i);
%             current_team_id = team_ids(j);
%             
%             wins_per_team(i + 1, j) = sum(week_winners == current_team_id);
%         end
%     end
%    
%     wins_per_team = array2table(wins_per_team, 'VariableNames', string(team_ids));
%     
% end