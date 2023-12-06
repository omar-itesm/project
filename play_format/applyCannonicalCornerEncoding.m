function encoded_event = applyCannonicalCornerEncoding(LUT, event, final_pos, algorithm, varargin)
    %% Argument parsing
    valid_encodings   = {'cannonical_corner_region_5', 'cannonical_corner_region_7'};    % Supported encodings

    
    default_encoding         = 'cannonical_corner_region_5';
    
    p = inputParser;
    
    addRequired(p, 'LUT'         , @(x) isa(x, 'table'));
    addRequired(p, 'event'       , @(x) isa(x, 'struct'));
    addRequired(p, 'final_pos'   , @(x) isa(x, 'double'));
    addRequired(p, 'algorithm'   , @(x) isa(x, 'char'));
    
    addParameter(p, 'encoding'          , default_encoding        , @(x) any(validatestring(x, valid_encodings)));
    
    parse(p, LUT, event, final_pos, algorithm, varargin{:});
     
    encoding     = p.Results.encoding;
    
    %% Encoding
    event_name = event.eventName;
    if strcmp(event_name, "Pass") || strcmp(event_name, "Corner") || strcmp(event_name, "Free Kick") || strcmp(event_name, "Throw in") || strcmp(event_name, "Goal Kick")
        if strcmp(encoding, 'cannonical_corner_region_5')
            region = assignCustom5RegionEventPos(final_pos);
        elseif strcmp(encoding, 'cannonical_corner_region_7')
            region = assignCustom7RegionEventPos(final_pos);
        else
            disp('Invalid encoding at applyCannonicalCornerEncoding()');
        end
    else
        region = "NA";
    end
    
    eventTypeIndexes   = LUT.eventName == event_name;
    eventRegionIndexes = LUT.regions    == region;
    
    switch algorithm
        case 'tks'
            encoded_event = LUT(eventTypeIndexes & eventRegionIndexes, :).code;
        case 'sequitur'
            encoded_event = LUT(eventTypeIndexes & eventRegionIndexes, :).letters;
        otherwise
            error('Invalid algorithm type');
    end

end