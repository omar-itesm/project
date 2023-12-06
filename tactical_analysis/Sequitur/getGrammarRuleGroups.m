function rule_groups = getGrammarRuleGroups(grammar_table, varargin)
% The function gets all the groups of rules in the grammar by first
% removing all the extra events in the grammar rules and leaving only the
% core sequences. Unique core sequences become a unique groups.

    %% Argument parsing
    valid_encodings   = {'cannonical_corner_region_5', 'cannonical_corner_region_7'};    % Supported encodings

    
    default_encoding         = 'cannonical_corner_region_5';
    
    p = inputParser;
    
    addRequired(p, 'grammar_table' , @(x) isa(x, 'table'));
    
    addParameter(p, 'encoding'          , default_encoding        , @(x) any(validatestring(x, valid_encodings)));
    
    parse(p, grammar_table, varargin{:});
     
    encoding     = p.Results.encoding;
    
    %% Grammar rule groups

    expanded_rules = grammar_table.Expand;
    rule_numbers   = grammar_table.Rule;
    
    rule_groups    = containers.Map(); % dictionary for groups of rules
    
    for i = 1:numel(expanded_rules)
       expanded_rule   = char(expanded_rules(i));
       rule_number     = rule_numbers(i);
       
       core_sequence           = getCoreSequence(expanded_rule, 'encoding', encoding);
       sequence_key            = strjoin(core_sequence, ',');
       core_sequence_in_groups = isKey(rule_groups, strjoin(core_sequence,','));
       
       if ~core_sequence_in_groups
           rule_groups(sequence_key) = rule_number;
       else
           rule_groups(sequence_key) = [rule_groups(sequence_key)  rule_number];
       end
       
    end

    % Remove groups whose key is empty. We don't care about such groups as
    % they represent tactics of 'extra events' only.
    remove(rule_groups, '');
    
end