function plays_info = extractPlaysInfo2(origin_corners, corner_plays, play_rules, play_rule_groups, player_data, match_data, team_data, player_relational_db, tf_market_value_data, fifa_attr_data)

    %%%%%%%%%%%% Play info     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    play_ids = cellfun(@(x) x(1).play_id, corner_plays);

    %%%%%%%%%%%% USE CASE info %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Grab the origin corner for the play
    origin_corner  = string(origin_corners);

    % Grab the preferred foot of the player taking the corner

    preferred_foot = getPreferredFoot(player_data, corner_plays);
    
    % Grab a flag to indicate if the corner kick was taken high
    high_corner_flag = getHighCornerFlag(corner_plays);

    %%%%%%%%%%%% Tournament info %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [tournament_progress, real_week]     = computeTournamentProgress(match_data, corner_plays);

    team_ids                             = getTeamsFromMatchData(match_data);
    advantage_vector                     = computeAdvantageVector(match_data, real_week, team_ids, corner_plays);
    
    %% Aggregate data
    
    plays_info.play_length            = computePlayLength(corner_plays); % Length in number of passes and ball movements
    
    
    plays_info.use_case_origin_corner        = origin_corner;
    plays_info.use_case_preferred_foot       = preferred_foot;
    plays_info.use_case_is_high_corner       = high_corner_flag;
    plays_info.tournament_progress           = tournament_progress;
    plays_info.tournament_advantage          = advantage_vector;
    plays_info.play_ids                      = play_ids;

end