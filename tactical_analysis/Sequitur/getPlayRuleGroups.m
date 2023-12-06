function play_rule_groups = getPlayRuleGroups(play_rules, rule_groups)
% The function receives a list of rules used by a play and the set of rule
% groups and it returns the set of rule groups used by the play.
    play_rule_groups = [];

    for i = 1:numel(play_rules)
       rule       = play_rules(i); 
       rule_group = getRuleGroup(rule, rule_groups);
       
       play_rule_groups = [play_rule_groups rule_group];
    end
    
    play_rule_groups = unique(play_rule_groups); % Gives us the set
    
end