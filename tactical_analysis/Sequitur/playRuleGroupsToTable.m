function play_rule_groups_table = playRuleGroupsToTable(group_ids, play_rule_groups)
% The function converts a list of play rule groups into a tabular form where each
% row represents a play and the columns represent the groups. The value in
% each cell is a boolean indicating wether or not a given play contains a
% given group.
% Example:
% play_rule_groups = {[1], [1 2], [3 1], [2]}
%
% play_rule_groups_table:
%       rule1 rule2 rule3
% play1   T     F     F
% play2   T     T     F
% play3   T     F     T
% play4   F     T     F

    varnames = strings(1, numel(group_ids));
    
    num_plays = numel(play_rule_groups);
    num_rules = numel(group_ids);
    
    values   = zeros(num_plays, num_rules);
    for i=1:num_rules
        current_rule = group_ids(i);
        
        varnames(i) = strcat('Group_', num2str(current_rule));
        
        values(:, i) = cellfun(@(x) any(x == current_rule), play_rule_groups);
        
    end

    play_rule_groups_table = array2table(values, 'VariableNames', varnames);

end