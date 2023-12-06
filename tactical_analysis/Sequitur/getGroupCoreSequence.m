function core_sequence = getGroupCoreSequence(group, rule_groups, varargin)
% The function receives a group number and outputs the core sequence for
% the group.

    %% Argument parsing
    valid_encodings   = {'cannonical_corner_region_5', 'cannonical_corner_region_7'};    % Supported encodings

    
    default_encoding         = 'cannonical_corner_region_5';
    
    p = inputParser;
    
    addRequired(p, 'group'         , @(x) isa(x, 'uint64'));
    addRequired(p, 'rule_groups'   , @(x) isa(x, 'containers.Map'));
    
    addParameter(p, 'encoding'          , default_encoding        , @(x) any(validatestring(x, valid_encodings)));
    
    parse(p, group, rule_groups, varargin{:});
     
    encoding     = p.Results.encoding;

    %% Group core sequence

    keys      = rule_groups.keys;
    group_key = keys{group};
    
    core_sequence = decodeEventSequence(group_key, 'encoding', encoding);
end