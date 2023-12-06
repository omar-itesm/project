function market_value = getPlayerMarketValue(player_id, pid_to_tf_pid, tf_market_value_dictionary, target_date)
% The function grabs the palyer market value up to a certain date from the
% transfermarkt data set.

    tf_player_id       = pid_to_tf_pid(player_id);
    
    if isKey(tf_market_value_dictionary, tf_player_id)
        player_mv_data      = tf_market_value_dictionary(tf_player_id);
        match_year          = year(target_date);
        market_value        = player_mv_data(match_year);
    else
        market_value = NaN;
    end
    
    % No MV data for the given target date available
    if market_value == -1
        market_value = NaN;
    end

end