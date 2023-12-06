function decoded_sequence = decodeEventSequence(event_sequence, varargin)
% The function receives an event sequence as a string with events separated
% by a single comma (no other characters are expected) and it returns the
% decoded sequence of events according to the encoding.

    default_encoding = 'cannonical_corner_region_5';
    valid_encodings  = {'8Dir','simple','cannonical_corner_region_5', 'cannonical_corner_region_7'}; % TODO: Add remaining valid encodings like Van Haaren

    p = inputParser;
    
    addRequired(p, 'event_sequence'     , @(x) isa(x, 'char'));
    
    addParameter(p, 'encoding', default_encoding, @(x) any(validatestring(x,valid_encodings)));
    
    parse(p, event_sequence, varargin{:});
    
    encoding = p.Results.encoding;
    %% Decode

    LUT = loadLUTFromEncoding(encoding);
    
    event_sequence = regexp(event_sequence, ',', 'split');
    
    decoded_sequence = cellfun(@(x) decodeEventAsString(LUT, x), event_sequence, 'UniformOutput', false);
end


function decoded_event = decodeEventAsString(LUT, event)
    [decoded_event, other]  = decodeLUT2(LUT, event);
    decoded_event = decoded_event + '_' + other;
end