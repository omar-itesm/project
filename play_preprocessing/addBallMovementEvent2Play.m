function new_play = addBallMovementEvent2Play(play)
% The function receives a play and adds a BALL MOVEMENT event if
% applicable.
    
    DISTANCE_THRESH = 10;
    
    add_ball_movement_flag = false;

    % Take the corner play to its standard form
    standard_play = standarizeCornerPlay(play);   

    num_ball_movement_added          = 0;
    adjacent_event_of_interest_index = 0;
    
    for event_index = 1:(numel(standard_play) - 1)
        
        attacking_team     = standard_play(1).teamId;
        current_event      = standard_play(event_index);
        raw_current_event  = play(event_index);
        current_event_name = current_event.eventName;
        
        if event_index < adjacent_event_of_interest_index
            new_play_index           = event_index + num_ball_movement_added;
            new_play(new_play_index) = raw_current_event;
            continue;
        end
        
        if add_ball_movement_flag
            ip = get_event_init_pos(new_event);
            fp = get_event_final_pos(new_event);
            
            new_play_index = event_index + num_ball_movement_added;
                        
            if isCornerPosition(ip) || isCornerPosition(fp)
                % Avoid adding the 'Ball movement' event if the movement is
                % from one of the corners to the final position. This
                % doesn't makes sense.
                % Also avoids adding the ball movement event if adjacent
                % events are not of the Pass type. See experiment 8 in
                % Notion for details.
                new_play(new_play_index) = raw_current_event;
            else
                % Add the 'Ball movement' event
                new_play(new_play_index)     = new_event;
                new_play(new_play_index + 1) = raw_current_event;

                num_ball_movement_added = num_ball_movement_added + 1;
            end
            
            add_ball_movement_flag = false;
        end

        [adjacent_event_of_interest, idx] = findFirstEventOfInterest(standard_play(event_index+1:end));
        adjacent_event_of_interest_index  = event_index + idx;
        
        raw_adjacent_event = play(adjacent_event_of_interest_index);
           
        final_pos   = get_event_final_pos(current_event);
        init_pos    = get_event_init_pos(adjacent_event_of_interest);
        
        distance    = norm(final_pos - init_pos);
        
        if distance >= DISTANCE_THRESH
            
            current_team        = current_event.teamId;
            next_team           = adjacent_event_of_interest.teamId;
            
            is_attacking_team_current = current_team == attacking_team;
            is_attacking_team_next    = next_team == attacking_team;
            
            new_event = createBallMovementEvent(raw_current_event, raw_adjacent_event, is_attacking_team_current, is_attacking_team_next);

            valid_adjacent_index = idx > 0;
            if valid_adjacent_index
                add_ball_movement_flag = true;
            end
        end
        
        new_play_index           = event_index + num_ball_movement_added;
        new_play(new_play_index) = raw_current_event;
    end
    
    event_index = event_index + 1;
    if add_ball_movement_flag
        current_event      = standard_play(event_index);
        raw_current_event  = play(event_index);
        
        ip = get_event_init_pos(new_event);
        fp = get_event_final_pos(new_event);

        new_play_index = event_index + num_ball_movement_added;

        if isCornerPosition(ip) || isCornerPosition(fp)
            % Avoid adding the 'Ball movement' event if the movement is
            % from one of the corners to the final position. This
            % doesn't makes sense.
            % Also avoids adding the ball movement event if adjacent
            % events are not of the Pass type. See experiment 8 in
            % Notion for details.
            new_play(new_play_index) = raw_current_event;
        else
            % Add the 'Ball movement' event
            new_play(new_play_index)     = new_event;
            new_play(new_play_index + 1) = raw_current_event;

            num_ball_movement_added = num_ball_movement_added + 1;
        end

        add_ball_movement_flag = false;
    else
        % Add the last event
        if isempty(event_index)
            event_index = 1;
        end

        if ~isempty(play)
            new_play_index = event_index + num_ball_movement_added;
            new_play(new_play_index) = play(end);
        else
            new_play = play;
        end
    end

end

function [adjacent_event_of_interest, idx] = findFirstEventOfInterest(play)
    % Finds the first event of interest in the play
    
    for i=1:numel(play)
        current_event = play(i);
        current_event_name = current_event.eventName;
        
        if strcmp(current_event_name,'Pass') || strcmp(current_event_name,'Shot') || strcmp(current_event_name,'Clearance') || strcmp(current_event_name,'Foul') || strcmp(current_event_name,'Offside')
            adjacent_event_of_interest = current_event;
            idx = i;
            return;
        end
        
    end
    
    % By default return the first element
    adjacent_event_of_interest = play(1);
    idx = 0; % Invalid index
end


%%

%     DISTANCE_THRESH = 10;
%     
%     num_ball_movement_added = 0;
%     compensate_y      = false;
%     
%     for event_index = 1:(numel(play) - 1)
%         attacking_team    = play(1).teamId; % May be outside the for loop. However, we need an additional check if empty.
%         
%         current_event = play(event_index);
%         next_event    = play(event_index + 1);
% 
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         % Obtain normalized position
%         
%         current_team        = current_event.teamId;
%         next_team           = next_event.teamId;
%         
%         is_attacking_team_current   = current_team == attacking_team;
%         [~, final_pos]      = compensatePosition2(current_event, is_attacking_team_current);
%         
%         is_attacking_team_next   = next_team == attacking_team;
%         [init_pos, ~]       = compensatePosition2(next_event, is_attacking_team_next);
% 
%         % Check if y compensation is needed
%         if event_index == 1
%             init_y = init_pos(2);
% 
%             if init_y < 50
%                compensate_y = true; 
%             end
%         end
% 
%         if compensate_y
%             init_pos(2)  = 100 - init_pos(2);
%             final_pos(2) = 100 - final_pos(2);
%         end
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         
%         % Compute euclidean distance between final pos of current event and
%         % initial pos of next event.
%         distance = norm(final_pos - init_pos);
%         
%         if distance >= DISTANCE_THRESH
%             
%             new_event = createBallMovementEvent(current_event, next_event, is_attacking_team_current, is_attacking_team_next);
%             
%             new_play_index = event_index + num_ball_movement_added;
%             
%             ip = get_event_init_pos(new_event);
%             fp = get_event_final_pos(new_event);
%             
%             isPassSequence = strcmp(current_event.eventName, 'Pass') && strcmp(next_event.eventName, 'Pass');
%             
%             if isCornerPosition(ip) || isCornerPosition(fp) || ~isPassSequence
%                 % Avoid adding the 'Ball movement' event if the movement is
%                 % from one of the corners to the final position. This
%                 % doesn't makes sense.
%                 % Also avoids adding the ball movement event if adjacent
%                 % events are not of the Pass type. See experiment 8 in
%                 % Notion for details.
%                 new_play(new_play_index) = current_event;
%             else
%                 % Add the 'Ball movement' event
%                 new_play(new_play_index)     = current_event;
%                 new_play(new_play_index + 1) = new_event;
% 
%                 num_ball_movement_added = num_ball_movement_added + 1;
%             end
%             
% 
%         else
%             new_play_index = event_index + num_ball_movement_added;
%             new_play(new_play_index) = current_event;
%         end
%     end
%     
%     % Add the last event
%     
%     if isempty(event_index)
%         event_index = 0;
%     end
%     
%     if ~isempty(play)
%         new_play_index = event_index + num_ball_movement_added + 1;
%         new_play(new_play_index) = play(end);
%     else
%         new_play = play;
%     end
%     