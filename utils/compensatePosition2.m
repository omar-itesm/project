function [init_pos, final_pos] = compensatePosition2(event, is_attacking_team)
    % Puts all plays in the same frame of reference
    
    
    % Extract positions
    [init_pos, final_pos] = get_event_position3(event, is_attacking_team);
    
    event_name = event.eventName;
    
    % Mirror positions to the same side of the field unless we have a save
    % attempt event. This is because the position is hard coded in this
    % case.
    if ~(strcmp(event_name, 'Save attempt'))
        init_pos    = compensate_local_pos_2(init_pos, is_attacking_team);
        final_pos   = compensate_local_pos_2(final_pos, is_attacking_team);
    end

end