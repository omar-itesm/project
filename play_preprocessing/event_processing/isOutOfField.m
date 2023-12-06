function is_out_of_field = isOutOfField(event)
    

    % Initialization
    is_out_of_field = false;
    
    subevent_name   = event.subEventName;
    
    if strcmp(subevent_name, 'Ball out of the field')
        is_out_of_field = true;
    end

end