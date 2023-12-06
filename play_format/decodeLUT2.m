function [event_name, other] = decodeLUT2(LUT, character)
    % other represents either the position (pos) or the direction (dir)
    % associated to the event.
    %
    % This function is used whenever we want to decode an event that was 
    % encoded using a character instead of a numeric code. This is the case 
    % for the encoding targeted for Sequitur.

    code_index = LUT.letters == character;
    
    % Check for the existance of specific fields
    dir_exists    = any(strcmp('dir'     , LUT.Properties.VariableNames));
    pos_exists    = any(strcmp('position', LUT.Properties.VariableNames));
    zone_exists   = any(strcmp('zones'    , LUT.Properties.VariableNames));
    region_exists = any(strcmp('regions' , LUT.Properties.VariableNames));
    
    if dir_exists
        other       = LUT(code_index, :).dir;
    elseif pos_exists
        other       = LUT(code_index, :).position;
    elseif zone_exists
        other       = LUT(code_index, :).zones;
    elseif region_exists
        other       = LUT(code_index, :).regions;
    else
        other       = ''; % Simple encoding has no other field
    end
    
    event_name  = LUT(code_index, :).eventName;
end