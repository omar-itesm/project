function event = createBallMovementEvent(prev_event, next_event, is_attacking_team_prev, is_attacking_team_next)
    event.eventId       = 10000;
    event.subEventName  = 'Ball movement';
    event.tags          = [];
    event.playerId      = next_event.playerId;  % Assumption that needs to be verified
    
    try
        % Position compensation is needed when the rev and next team are not
        % the same. This is because one position comes from one team and the
        % other form the opponent team.
        if is_attacking_team_prev == 1 && is_attacking_team_next == 0

            % INITIAL POSITION
            [~, prev_event_final_pos]  = get_event_position3(prev_event);

            final_pos.x           = prev_event_final_pos(1);
            final_pos.y           = prev_event_final_pos(2);

            compensated_init_pos  = convertPosToOppositeFrame(final_pos);
            event.positions(1,:)  = compensated_init_pos;       % Init position is compensated final position of prev

            % FINAL POSITION
            [next_event_init_pos,~]   = get_event_position3(next_event);

            init_pos.y            = next_event_init_pos(2);
            init_pos.x            = next_event_init_pos(1);

            event.positions(2,:)  = init_pos;                   % Final position is initial position of next
        elseif is_attacking_team_prev == 0 && is_attacking_team_next == 1

            % INITIAL POSITION
            [~, prev_event_final_pos]  = get_event_position3(prev_event);

            final_pos.y           = prev_event_final_pos(2);
            final_pos.x           = prev_event_final_pos(1);
            event.positions(1,:)  = final_pos;                  % Initial position is final position of prev

            % FINAL POSITION
            [next_event_init_pos, ~]   = get_event_position3(next_event);
            init_pos.x            = next_event_init_pos(1);
            init_pos.y            = next_event_init_pos(2);

            compensated_final_pos = convertPosToOppositeFrame(init_pos);
            event.positions(2,:)  = compensated_final_pos;      % Final position is compensated init pos of next
        else
            [~, prev_event_final_pos]  = get_event_position3(prev_event);

            final_pos.y           = prev_event_final_pos(2);
            final_pos.x           = prev_event_final_pos(1);

            [next_event_init_pos,~]   = get_event_position3(next_event);

            init_pos.y            = next_event_init_pos(2);
            init_pos.x            = next_event_init_pos(1);

            event.positions(1,:)  = final_pos; % Initial position is final position of prev
            event.positions(2,:)  = init_pos; % Final position is initial position of next
        end
    catch
       disp('Error'); 
    end
    
    event.matchId       = next_event.matchId;
    event.eventName     = 'Ball movement';
    event.teamId        = next_event.teamId;    % Assumption that needs to be verified
    event.matchPeriod   = next_event.matchPeriod;
    event.eventSec      = mean([prev_event.eventSec, next_event.eventSec]);
    event.subEventId    = 10000;
    event.id            = NaN;
    event.play_id       = next_event.play_id;
end