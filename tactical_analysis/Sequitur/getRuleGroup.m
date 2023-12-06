function rule_group = getRuleGroup(rule, rule_groups)
% The function receives the rule_groups as computed by
% getGrammarRuleGroups.m and a rule number and it returns the group to
% which the rule belongs. The rule refers to the rule identifier in the
% grammar table computed by decodeGrammarFiles.m
    rule_group = find(cell2mat(cellfun(@(x) any(x==rule), rule_groups.values, 'UniformOutput', false)));
end