function simplified_rule = getCoreSequence(expanded_rule, varargin)
% The function receives the string of a rule expansion and removes all of
% the extra events.

    %% Argument parsing

    valid_encodings   = {'cannonical_corner_region_5', 'cannonical_corner_region_7'};    % Supported encodings

    
    default_encoding         = 'cannonical_corner_region_5';
    
    p = inputParser;
    
    addRequired(p, 'expanded_rule' , @(x) isa(x, 'char'));
    addParameter(p, 'encoding'     , default_encoding        , @(x) any(validatestring(x, valid_encodings)));
    
    parse(p, expanded_rule, varargin{:});
     
    encoding     = p.Results.encoding;
    
    %% Core sequence
    
    LUT = loadLUTFromEncoding(encoding);

    extra_events = {'Shot', 'Clearance', 'Interception', 'Foul', 'Goalkeeper leaving line', 'Interruption', 'Save attempt', 'Offside', 'Out of field'}; % FIXME: Add other events that may apply. E.g. Save attempt

    encoded_extra_events = LUT(ismember(LUT.eventName, extra_events),:).letters;

    expanded_rule = expanded_rule(2:end-1);
    
    event_list = regexp(expanded_rule, ', ', 'split');
    event_list = cellfun(@(x) x(2:end-1), event_list, 'UniformOutput', false);
    
    extra_events_index = ismember(event_list, encoded_extra_events);
    
    simplified_rule = event_list(~extra_events_index);
    
end