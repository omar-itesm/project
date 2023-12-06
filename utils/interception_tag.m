tags     = {first_half.tags};

interception_indexes = false(1,numel(tags));
for event_index = 1:numel(tags)
    current_tags = tags{event_index};
    
    if ~isempty(current_tags)
        current_tags = [current_tags.id];
    end
    
    if any(current_tags==1401)
        % Interception 
        interception_indexes(event_index) = true;
    else
        interception_indexes(event_index) = false;
    end
    
end

interceptions = first_half(interception_indexes)';