function is_acceleration = isAcceleration(event)

    % Initialization
    is_acceleration = false;

    event_name      = event.eventName;
    subevent_name   = event.subEventName;
    
    if strcmp(event_name, 'Others on the ball') && strcmp(subevent_name, 'Acceleration')
        is_acceleration = true;
    end
end