function relational_db = buildDatabaseRelationship()
    % Initialization
    vnames        = {'pid', 'tf_pid', 'fifa_pid'};
    relational_db = array2table(zeros(0,3), 'VariableNames', vnames);
    
    
    % Load player data

    player_data      = struct2table(load_player_data());
    tf_player_data   = load_tf_player_data();
    fifa_player_data = load_fifa_player_data();
    
    pids = player_data.wyId;
    
    for i=1:numel(pids)
        current_pid = pids(i);
        
        tf_pid   = getPlayerTfId(current_pid, player_data, tf_player_data);
        fifa_pid = getPlayerFifaId(current_pid, player_data, fifa_player_data);
        
        row    = {current_pid, tf_pid, fifa_pid};
        
        relational_db(i, :) = row;
    end
end