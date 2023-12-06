% Example usage:
% strategy_table = convertWekaData2Table(data);
%
% pattern.('use_case_preferred_foot_eq') = 'R';
% pattern.('play_duration_lte') = 33.5;
% pattern.('play_num_duels_lte') = 6.5;
%
% plays_with_pattern = findPlaysWithPatternFromStrategyTable(pattern, strategy_table);


function [plays_with_pattern, plays_without_pattern] = findPlaysWithPatternFromStrategyTable(pattern, strategy_table)
% The function finds the set of all plays that meet the pattern. This is
% useful to compute the support at a later stage.
% NOTE: Patterns need to be specified as a structure with the same basic
% shape as the one obtained from parsing the contrast pattern text files in
% the parseContrastPatterns.m function.
    
    num_plays = height(strategy_table);
    
    with_pattern_filter = false(1, num_plays);
    
    parfor i=1:num_plays
        current_play = strategy_table(i,:);
        contains_pattern = detectPatternPresenceInPlay(pattern, current_play);
        
        with_pattern_filter(i) = contains_pattern;
    end
    
    plays_with_pattern    = strategy_table( with_pattern_filter, :);
    plays_without_pattern = strategy_table(~with_pattern_filter, :);

end

function pattern_detected = detectPatternPresenceInPlay(pattern, play)
    invalid_fields = {'length', 'support', 'Properties', 'Row', 'Variables'}; % Some of them are due to patterns sometimes being specified as tables

    pattern_detected = true; % We assume the play contains the pattern unless it is otherwise found.
    
    pattern_attributes = fieldnames(pattern);

    for attribute_name=pattern_attributes'
        
        is_valid_field = ~any(strcmp(attribute_name, invalid_fields)); % TODO: Improve valid definition
        
        if is_valid_field
        
            clause_complies = determineClauseCompliance(pattern, play, attribute_name{:});

            % A single non compliant clause is enough for the pattern to be
            % invalid for the play.
            if ~clause_complies
                pattern_detected = false;
                break;
            end
        end
    end

end


function clause_complies = determineClauseCompliance(pattern, play, attribute_name)
    pattern_attribute = pattern.(attribute_name);
    
    [attribute_name, operator] = getOperatorFromAttributeName(attribute_name);
    play_attribute             = play.(attribute_name);

    switch operator
        case 'neq' % Categorical
            clause_complies = ~strcmp(pattern_attribute, play_attribute);
        case 'eq'  % Categorical
            clause_complies = strcmp(pattern_attribute, play_attribute);
        case 'lt'  % Numeric
            clause_complies = play_attribute < pattern_attribute;
        case 'lte' % Numeric
            clause_complies = play_attribute <= pattern_attribute;
        case 'gt'  % Numeric
            clause_complies = play_attribute > pattern_attribute;
        case 'gte'  % Numeric
            clause_complies = play_attribute >= pattern_attribute;
        otherwise
            clause_complies = false;
            warning('Unexpected behavior at determineClauseCompliance');
    end
end







