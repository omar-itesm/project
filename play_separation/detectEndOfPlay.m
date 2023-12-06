function [final_index, reason] = detectEndOfPlay(event_log, initial_index)
    % Detect the end of corner kick plays.
    
    % Initialization
    final_index             = NaN;
    
    reason = "NA";
    
    %% Loop through the remaining log until we find the end of the play
    log_size  = numel(event_log);
    last_time = event_log(initial_index).eventSec;
    initial_team = event_log(initial_index).teamId;
    
    for current_event_idx = initial_index:log_size
        
        % Extract the current event
        current_event = event_log(current_event_idx);
        
        % Check for a terminal event
        [is_terminal_event, reason] = isTerminalEvent(current_event);
        
        if is_terminal_event
            final_index = current_event_idx;
            break;
        end
        
        % Check if it is the last event in the log
        if current_event_idx == log_size
            reason = "Other";
            final_index = current_event_idx;
            break; % Avoid problems when checking the remaining conditions
        end
        
        % Check for a large time delta between contiguous events
        current_time = current_event.eventSec;
        [is_large_time_delta, reason] = isLargeTimeDelta(current_time, last_time);
        last_time = current_time;
        
        if is_large_time_delta
           final_index = current_event_idx - 1;
           break; 
        end
        
        % Check if the ball left the field
        if isFreeKick(current_event) && current_event_idx ~= initial_index
            if isThrowIn(current_event) || isCorner(current_event) || isGoalKick(current_event) 
                reason = "Out of field";
            else
                reason = "Other";
            end
            final_index  = current_event_idx - 1;
            break;
        end
        
        % Check for a change in possession
        current_team = current_event.teamId;
    
        if isPass(current_event) || isAcceleration(current_event)
            if initial_team ~= current_team
                final_index  = current_event_idx - 1;
                reason       = "Possession change";
                break;
            end
        end
        
    end
  
end

%% Helper functions

function [is_terminal_event, reason] = isTerminalEvent(event)    
    is_terminal_event = false;
    reason = "NA";
        
    if isFoul(event)
        is_terminal_event = true;
        reason = "Foul";
    elseif isClearance(event)
        is_terminal_event = true;
        reason = "Clearance";
    elseif isInterruption(event)
        is_terminal_event = true;
        if isOutOfField(event)
            reason = "Out of field";
        else
            reason = "Interruption";
        end
    elseif isOffside(event)
        is_terminal_event = true;
        reason = "Offside";
    end
end

function [is_large_time_deta, reason] = isLargeTimeDelta(current_time, last_time)
    % Local variables
    time_delta_thresh = 10;
    is_large_time_deta      = false;
    reason            = "NA";
    
    time_delta  = abs(current_time - last_time);
    
    if time_delta > time_delta_thresh
        is_large_time_deta = true;
        reason = "Time delta";
    end
end
    
    