function plays_info = extractPlaysInfo(plays, player_data, match_data, team_data, pid_to_tf_pid, tf_market_value_dictionary, fifa_attr_data, termination_reason)
    %% Preprocessing
    
    remove_all_after_shot = true; % The default config, modify as necessary
    
    if remove_all_after_shot
        plays = cellfun(@(x) removeAllAfterShot(x), plays, 'UniformOutput', false);
    end


    %% Compute play info

    %%%%%%%%%%%% TEAM info %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Compute the data
    [offensive_height, defensive_height] = getTeamHeightsForPlay(match_data, player_data, plays);
    [offensive_age   , defensive_age   ] = getAverageTeamAgeForPlays(plays, match_data, player_data);
    team_names                           = getTeamNames(team_data, plays);
    [offensive_mv    , defensive_mv    ] = getAverageTeamMarketValue(plays, match_data, pid_to_tf_pid, tf_market_value_dictionary);
    offensive_mv_discrete                = discretizeMarketValue(offensive_mv);
    defensive_mv_discrete                = discretizeMarketValue(defensive_mv);
    goalkeeper_market_value              = getGoalkeeperMarketValue(plays, match_data, player_data, pid_to_tf_pid, tf_market_value_dictionary);
       
    % Store the data
    plays_info.team_avg_offensive_height     = offensive_height;
    plays_info.team_avg_defensive_height     = defensive_height;
    plays_info.team_avg_offensive_age        = offensive_age;
    plays_info.team_avg_defensive_age        = defensive_age;
    plays_info.team_defensive_goalkeeper_mv  = goalkeeper_market_value; % Market value of the goalkeeper in the defensive team
    
    plays_info.team_avg_offensive_mv         = offensive_mv;
    plays_info.team_avg_defensive_mv         = defensive_mv;
    plays_info.team_avg_offensive_mv_range   = offensive_mv_discrete;
    plays_info.team_avg_defensive_mv_range   = defensive_mv_discrete;
    plays_info.team_names                    = team_names;


    %% PLAY
    
    % Compute the data
    avg_off_play_mv                      = getAverageOffensivePlayMarketValue(plays, match_data, pid_to_tf_pid, tf_market_value_dictionary);
    avg_off_play_height                  = getAverageOffensivePlayHeight(plays, player_data, offensive_height);
    avg_def_play_height                  = getAverageDefensivePlayHeight(plays, player_data, defensive_height);
    avg_off_play_age                     = getAverageOffensivePlayAge(plays, match_data, player_data, offensive_age);

    
    % Store the data    
    avg_off_play_mv(avg_off_play_mv == -1)   = offensive_mv(avg_off_play_mv == -1); % If the play market value is missing, assing the average value for the team
    plays_info.play_avg_off_mv               = avg_off_play_mv;
    
    plays_info.play_avg_off_mv_range         = discretizeMarketValue(avg_off_play_mv);
    
    avg_off_play_height(avg_off_play_height == -1) = offensive_height(avg_off_play_height == -1);
    plays_info.play_avg_off_height           = avg_off_play_height;
    
    avg_def_play_height(avg_def_play_height == -1) = defensive_height(avg_def_play_height == -1);
    plays_info.avg_def_play_height           = avg_def_play_height;
    
    avg_off_play_age(avg_off_play_age == -1) = offensive_age(avg_off_play_age == -1);
    plays_info.avg_off_play_age              = avg_off_play_age;
    
%%
    plays_info.play_preparation_time  = computePreparationTime(plays);
    plays_info.play_num_duels         = computeNumPlayDuels(plays);
    
    plays_info.play_has_gll_event     = hasGoalkeeperLeavingLineEvent(plays);

    plays_info.game_time_interval     = getPlaysTimeInterval(plays);
    plays_info.game_time_min          = round(getPlaysTimeMin(plays));
    
    plays_info.play_duration          = computePlayDuration(plays);

    % Extract match period without extra time info. The fact that the play
    % takes place on the last minutes of the game is encoded in the time
    % interval instead.
    match_period = string(cellfun(@(x) x(1).matchPeriod, plays, 'UniformOutput', false));
    match_period(strcmp(match_period, "E1")) = "1H";
    match_period(strcmp(match_period, "E2")) = "2H";
    plays_info.game_match_period      = match_period;
    
    [score, o_score, d_score]    = computeCurrentScore(match_data, plays);
    
    goal_advantage               = zeros(size(score));
    goal_advantage(o_score > d_score)  = 't';
    goal_advantage(o_score <= d_score) = 'f';
     
    plays_info.game_goal_advantage = goal_advantage;
    plays_info.game_goal_diff      = o_score - d_score;
    
    % The following info is only used for debugging purposes
    plays_info.has_clearance        = hasClearance(plays);
    plays_info.has_interruption     = hasInterruption(plays);
    plays_info.has_foul             = hasFoul(plays);
    plays_info.has_offside          = hasOffside(plays);
    plays_info.has_shot             = hasShot(plays);
    plays_info.has_save_attempt     = hasSaveAttempt(plays);
    plays_info.termination_reason   = termination_reason;
end

function play = removeAllAfterShot(play)
    to_be_removed = [];
    shot_found = 0;
    for event_index = 1:numel(play)
        current_event   = play(event_index);
        event_name      = current_event.eventName;

        if shot_found
            to_be_removed = [to_be_removed event_index];
        end

        if strcmp(event_name, 'Shot')
            shot_found = 1;
        end

    end

    % Remove all events after the first shot
    play(to_be_removed) = [];
end