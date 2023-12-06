function encoded_event_name = getEncodedEventName(event, varargin)
% The function receives an event and an encoding and returns the encoded
% name. The function ignores events where position information is not
% relevant. Note: The function encodes the final position.
% Note: The function expects the play to be in its standard form.

    %% Argument parsing
    valid_encodings   = {'none', '18Z', 'VH', '8Dir', 'simple', 'cannonical_corner_region_5', 'cannonical_corner_region_7'};    % Supported encodings
    default_encoding  = 'cannonical_corner_region_5';
    
    p = inputParser;

    addRequired(p, 'event'      , @(x) isa(x, 'struct'));
    addParameter(p, 'encoding'  , default_encoding        , @(x) any(validatestring(x, valid_encodings)));

    parse(p, event, varargin{:});

    encoding     = p.Results.encoding;
    
    %% Code
    event_name    = event.eventName;
    final_pos     = get_event_final_pos(event); % FIXME: Make it configurable to choose initial or final pos

    if strcmp(event_name, "Pass") || strcmp(event_name, "Corner") || strcmp(event_name, "Free Kick") || strcmp(event_name, "Throw in") || strcmp(event_name, "Goal Kick")
        region = assignRegionBasedOnEncoding(final_pos, encoding);
    else
        region = 'NA';
    end
    
    encoded_event_name = strjoin([string(event_name), string(region)],'_');
    
end

