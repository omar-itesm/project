function [corner_play, origin_corner] = standarizeCornerPlay(corner_play)

    if isempty(corner_play) || numel(corner_play) < 1
       return;
    end

    % Get the origin corner before the transformation
    origin_corner = getOriginCorner(corner_play);


    %%%%%%%% Cannonical corner %%%%%%%%%%
    num_events = numel(corner_play);
    
    attacking_team = corner_play(1).teamId;

    compensate_y = false;

    for i = 1:num_events
        event_index = i;

        current_event = corner_play(i);

        team = current_event.teamId;

        is_attacking_team     = team == attacking_team;

        [init_pos, final_pos] = compensatePosition2(current_event, is_attacking_team);

        % Check if y compensation is needed
        if event_index == 1
            init_y = init_pos(2);

            if init_y < 50
               compensate_y = true; 
            end
        end

        if compensate_y
            init_pos(2) = 100 - init_pos(2);
            final_pos(2) = 100 - final_pos(2);
        end

% UPDATE: On an outside script, we will be removing all plays that have an
% invalid final position. Thus we comment the following code.
%         % Check if corner final position estimation is needed
%         if strcmp(current_event.subEventName, 'Corner')
%            if isCornerPosition(final_pos)
% 
%                % Extract the initial position of the next event and use
%                % it as the final position of the corner event.
%                % NOTE:
%                %    - We assume there is always a follow-up event after
%                %    the corner event.
%                next_event             = corner_play(event_index + 1);
%                is_attacking_team_next = next_event.teamId == attacking_team;
% 
%                [next_init_pos, ~] = compensatePosition2(next_event, is_attacking_team_next);
% 
%                 if compensate_y
%                     next_init_pos(2) = 100 - next_init_pos(2);
%                 end
% 
%                 final_pos = next_init_pos;
% 
%            end
%         end
        
        
        current_event = setEventPosition(current_event, init_pos, final_pos);
        
        corner_play(i) = current_event;
    end

end