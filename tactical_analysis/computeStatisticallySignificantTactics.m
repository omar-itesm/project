% Example:
% rules_folder   = [pwd '\output\Corner\Sequitur\grammar_rules\'];
% load(standard_plays_filename);
% computeStatisticallySignificantTactics(rules_folder, standard_plays, standard_plays_labels)

function [significant_tactics_metrics, tactics_metrics] = computeStatisticallySignificantTactics(rules_folder, plays, play_labels, varargin)

    %% Argument parsing
    valid_encodings   = {'cannonical_corner_region_5', 'cannonical_corner_region_7'};    % Supported encodings

    
    default_encoding         = 'cannonical_corner_region_5';
    
    p = inputParser;
    
    addRequired(p, 'rules_folder', @(x) isa(x, 'char'));
    addRequired(p, 'plays'       , @(x) isa(x, 'cell'));
    addRequired(p, 'play_labels' , @(x) isa(x, 'double'));
    
    addParameter(p, 'encoding'          , default_encoding        , @(x) any(validatestring(x, valid_encodings)));
    
    parse(p, rules_folder, plays, play_labels, varargin{:});
     
    encoding     = p.Results.encoding;
    
    %% Statistically significant tactics
    
    grammar_file       = [rules_folder 'All_rules.csv'];
    grammar_table      = decodeGrammarFiles(grammar_file, 'encoding', encoding);
    rule_groups        = getGrammarRuleGroups(grammar_table, 'encoding', encoding);
    
    % Prepare data
    grammar_file       = [rules_folder 'Goal_rules.csv'];
    goal_grammar_table = decodeGrammarFiles(grammar_file, rule_groups, 'encoding', encoding);

    grammar_file       = [rules_folder 'Shot_rules.csv'];
    shot_grammar_table = decodeGrammarFiles(grammar_file, rule_groups, 'encoding', encoding);

    grammar_file       = [rules_folder 'Failed_rules.csv'];
    fail_grammar_table = decodeGrammarFiles(grammar_file, rule_groups, 'encoding', encoding);

    % Extract group metrics
    grammar_structure.grammar_1.grammar_table = goal_grammar_table;
    grammar_structure.grammar_1.name          = "Goal";

    grammar_structure.grammar_2.grammar_table = shot_grammar_table;
    grammar_structure.grammar_2.name          = "Shot";

    grammar_structure.grammar_3.grammar_table = fail_grammar_table;
    grammar_structure.grammar_3.name          = "Fail";

    properties.rule_groups          = rule_groups;
    properties.success_classes      = {'Goal', 'Shot'};
    properties.total_plays          = numel(plays);
    properties.total_goal_plays     = sum(play_labels == 1); % 1 = Goal
    properties.total_shot_plays     = sum(play_labels == 2); % 2 = Shot
    properties.total_fail_plays     = sum(play_labels == 0); % 0 = Failed

    group_metrics   = extractTacticGroupMetrics(grammar_structure, properties, 'encoding', encoding);
    tactics_metrics = group_metrics;
    
    total_success_plays = properties.total_goal_plays + properties.total_shot_plays;
    
    num_tests = double(rule_groups.Count);
    
    statistically_significant_tactic_id = []; % Hold statistically significant tactics
    
    for i=1:rule_groups.Count
        p_s  = group_metrics(i,:).Freq_Success;
        np_s = total_success_plays - p_s;
        
        p_f  = group_metrics(i,:).Freq_Fail;
        np_f = properties.total_fail_plays - p_f;
        
%         [is_valid, chi_val, p_val] = computeStatisticalSignificanceYates(p_s, p_f, np_s, np_f);
        [is_valid, chi_val, p_val] = computeStatisticalSignificance(p_s, p_f, np_s, np_f);
        
        if p_val < (0.05/num_tests) && is_valid
            statistically_significant_tactic_id = [statistically_significant_tactic_id, i];
            fprintf('Tactic %d is significant. Chi: %.2f, p: %.2e\r\n', i, chi_val, p_val);
        end
    end
    
    significant_tactics_metrics = group_metrics(statistically_significant_tactic_id, :);
    
end