function [init_pos, final_pos] = get_event_position(event)
% GETEVENTPOSITION grabs position data from the event and corrects dummy 
% position values when appropiate. For instance, it seems like the final 
% position for all shot events is just a dummy value. This values cause 
% problems for example when producing visualizations and in other use cases.

    init_pos    = get_event_init_pos(event);
    final_pos   = get_event_final_pos(event);
    
    is_corner       = strcmp('Corner', event.subEventName);
    is_goal_kick    = strcmp('Goal kick', event.subEventName);
    is_save_attempt = strcmp('Save attempt', event.eventName);
    is_goalkeeper_leaving_line = strcmp('Goalkeeper leaving line', event.eventName);
    
    % The function corrects dummy positions if needed
    
    if ~(is_corner || is_goal_kick || is_save_attempt)
        if isequal(init_pos, [0 0]) || isequal(init_pos, [100 100]) || isequal(init_pos, [100 0]) || isequal(init_pos, [0 100])
            init_pos  = final_pos; % Assuming final_pos is fine
            warning('Dummy position (init_pos) corrected');
        elseif isequal(final_pos, [0 0]) || isequal(final_pos, [100 100]) || isequal(final_pos, [100 0])|| isequal(final_pos, [0 100])
            final_pos = init_pos;  % Assuming init_pos is fine
            warning('Dummy position (final_pos) corrected');
        end
    elseif is_goal_kick
        
        % We assume it is impossible for a Goal Kick to start at 0,0
        if isequal(init_pos, [0 0]) || isequal(init_pos, [0, 100])
            init_pos = [0, 50]; % We just assume it was taken in the middle of the field
        elseif isequal(init_pos, [100 100]) || isequal(init_pos, [100, 0])
            init_pos = [0, 50];  % WARNING: We are assuming the initial position is always 0 in X since
                                 %          a goal kick is the start of an
                                 %          offensive. This assumption
                                 %          needs to be validated!!!
        end
        
    elseif is_save_attempt
        % We assume it is impossible for a Save Attempt to start at an edge
        % of the field. We can't assume save attempts always happen in the
        % opposite side of the field. As there may be the case of goals in
        % our own goal.
        if isequal(init_pos, [0 0]) || isequal(init_pos, [0, 100])
            init_pos = [100, 50];
        elseif isequal(init_pos, [100 100]) || isequal(init_pos, [100, 0])
            init_pos = [100, 50];
        end
        
        % NOTE: I guess I could add a condition that if the save attempt is
        % from the 'defending' team then we hardcode the position to
        % (100,50). This way we avoid errors for goals in our own goal. For
        % now I will just hard-code assuming the save attempt is ALWAYS in
        % the opponents goal.
        
    elseif is_goalkeeper_leaving_line
        if isequal(init_pos, [0 0]) || isequal(init_pos, [0, 100])
            %init_pos = [0, 50];    % It seems as if this should be the
                                    % correct value but somehow it is not.
                                    % At least for some data I've reviewed.
                                    % It needs more in-depth study.
            init_pos = [100, 50];
        elseif isequal(init_pos, [100 100]) || isequal(init_pos, [100, 0])
            %init_pos = [100, 50];
            init_pos = [0, 50];
        end
    end
end