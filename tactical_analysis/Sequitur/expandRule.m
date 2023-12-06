function [expanded] = expandRule(rule, grammar_table)
    expanded = grammar_table(grammar_table.Rule == rule,:).Expand;
    expanded = strrep(expanded,' ','');
    expanded = strrep(expanded,"'",'');
    expanded = char(expanded);
    expanded = expanded(2:end-1);
    expanded = regexp(expanded, ',', 'split');  % Cell array
end