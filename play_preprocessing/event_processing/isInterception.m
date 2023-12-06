function is_interception = isInterception(event)
% The function determines if an event is an interception.
% FIXME: Currently only the OTB event is considered but this may be
% extended to also consider other events.

    % Initialization
    is_interception = false;

    interception_tag = 1401;
    
    event_name      = event.eventName;
    subevent_name   = event.subEventName;
    current_tags    = event.tags;
    
    if ~isempty(current_tags)
        current_tags = [current_tags.id];
    end
    
    if strcmp(event_name, 'Others on the ball') && strcmp(subevent_name, 'Touch') && any(current_tags == interception_tag)
        is_interception = true;
    end
end