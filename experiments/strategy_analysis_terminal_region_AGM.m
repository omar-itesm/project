%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Strategy analysis for plays ending in region AGM
% 
% Author: Omar Muñoz
% Date: February 16, 2023
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all; close all; fclose all; clc;

configurePythonEnv();

%% Local variables

encoding = 'cannonical_corner_region_5';
contrast_type = 'shot_goal_vs_rest'; % Valid options: [shot_goal_vs_rest, goal_vs_shot]

[direct_corner_file_struct, indirect_corner_file_struct] = createCornerKickAnalysisOutputFileStructure();

%% Load corner plays
[corner_plays_data_1, corner_plays_data_2] = loadCornerPlays(); % Plays with one event and plays with two or more

complete_plays_data = mergeCornerData(corner_plays_data_1, corner_plays_data_2);

saved_plays_folder  = [pwd '\data\plays\'];

%% Load context data
context_data.player_data          = struct2table(load_player_data());
context_data.match_data           = load_match_data();
context_data.team_data            = load_teams_data();
context_data.tf_player_data       = load_tf_player_data();
context_data.tf_market_value_data = load_tf_market_value_data();
context_data.fifa_attr_data       = load_fifa_attribute_data();
load player_relational_db.mat;
context_data.player_relational_db = player_relational_db;

%% Extract final dest vector
final_dest_vec_1  = cellfun(@(x) computePlayFinalDestination(x), corner_plays_data_1.standard_plays, 'UniformOutput', false);
final_dest_vec_2  = cellfun(@(x) computePlayFinalDestination(x), corner_plays_data_2.standard_plays, 'UniformOutput', false);

%% Extract plays where the final destination is AGM

region_filter_1  = strcmp(final_dest_vec_1, 'AGM');
region_plays_1   = filterCornerPlayData(corner_plays_data_1, region_filter_1);

region_filter_2  = strcmp(final_dest_vec_2, 'AGM');
region_plays_2   = filterCornerPlayData(corner_plays_data_2, region_filter_2);

%% Run the tactical analysis for plays with two or more events (indirect corner kicks)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%   Standard play info
standard_plays          = region_plays_2.standard_plays;
standard_plays_labels   = region_plays_2.corner_labels;
standard_plays_info1    = region_plays_2.corner_plays_info;
standard_source_db      = region_plays_2.corner_source_db;
origin_corners          = region_plays_2.origin_corners;

% Extract folder names
encoded_plays_folder                = indirect_corner_file_struct.encoded_plays_folder;
rules_folder                        = indirect_corner_file_struct.rules_folder;
strategy_tables_folder              = indirect_corner_file_struct.strategy_tables_folder;
strategy_tables_complete_folder     = indirect_corner_file_struct.strategy_tables_complete_folder;
tactic_plots_folder                 = indirect_corner_file_struct.tactic_plots_folder;
contrast_patterns_folder            = indirect_corner_file_struct.contrast_patterns_folder;
contrast_patterns_complete_folder   = indirect_corner_file_struct.contrast_patterns_complete_folder;
contrast_patterns_variables_folder  = indirect_corner_file_struct.contrast_patterns_variables_folder;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find meta data
use_cases = cellfun(@(x) getPlayUseCases(x), standard_plays);
[standard_plays_metadata, ~] = cellfun(@(w,x,y,z) extractPayload(w, x, y, z), standard_plays, num2cell(standard_plays_labels), num2cell(use_cases), num2cell(standard_source_db), 'UniformOutput', false);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Encode play data for Sequitur

%   Write the corner play labels to a file
labels_filename = [encoded_plays_folder encoding '_play_labels.txt'];
fileID          = fopen(labels_filename, 'w');
fmt             = [repmat('%.0f', 1, size(standard_plays_labels, 2)) '\r\n'];

fprintf(fileID, fmt, standard_plays_labels);
fclose(fileID);

%   Create the encoded plays
[play_groups, play_groups_metadata]  = encodeForSequiturPerClass(encoded_plays_folder, standard_plays, standard_plays_metadata, standard_plays_labels, 'encoding', encoding);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find grammar rules and write them to a CSV file

plays_filename = [encoded_plays_folder encoding '_All_plays.txt'];

grammar_summary_filename = strcat(rules_folder, 'GrammarSummary.xlsx');

if ~isfile(grammar_summary_filename)
    createGrammarIntraClassSupportForPlays(plays_filename, labels_filename, rules_folder, 'encoding', encoding);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Decode grammar and rule groups

grammar_file       = [rules_folder 'All_rules.csv'];
grammar_table      = decodeGrammarFiles(grammar_file, 'encoding', encoding);
rule_groups        = getGrammarRuleGroups(grammar_table, 'encoding', encoding);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute probabilities

tactic_probs_filename             = strcat(rules_folder, 'Tactic_probabilities_two_or_more.csv');
tactic_probs_significant_filename = strcat(rules_folder, 'Tactic_probabilities_significant_two_or_more.csv');

tactic_files_exist = isfile(tactic_probs_filename) & isfile(tactic_probs_significant_filename);

if ~tactic_files_exist
    [significant_groups_metrics, group_metrics] = computeStatisticallySignificantTactics(rules_folder, standard_plays, standard_plays_labels, 'encoding', encoding);

    group_metrics_file = [rules_folder 'Tactic_probabilities_two_or_more.csv'];
    writetable(group_metrics, group_metrics_file);

    significant_group_metrics_file = [rules_folder 'Tactic_probabilities_significant_two_or_more.csv'];
    writetable(significant_groups_metrics, significant_group_metrics_file);
end

%% Run the strategy analysis for plays with two or more events (indirect corner kicks)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extract rule groups per play
compressed_plays_file = [rules_folder 'All_compressedPlays.txt'];
play_rules            = getCompressedPlaysRules(compressed_plays_file);

play_rule_groups      = cellfun(@(x) getPlayRuleGroups(x, rule_groups), play_rules, 'UniformOutput', false);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Aggregate play info
plays_info_filename = strcat(saved_plays_folder, 'standard_corner_plays_info_full.mat');

if ~isfile(plays_info_filename)
    % Extract the complete plays info
    plays_info2 = extractPlaysInfo2(origin_corners, standard_plays, play_rules, play_rule_groups, context_data.player_data, context_data.match_data, ...
                                    context_data.team_data, context_data.player_relational_db, context_data.tf_market_value_data, context_data.fifa_attr_data);
    plays_info  = aggregateContextData(standard_plays_info1, plays_info2);

    % Save plays to a matlab file
    save(plays_info_filename, 'plays_info');
else
    load(plays_info_filename);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create data for weka (per tactic)
shuffled_labels      = standard_plays_labels;

rule_groups_ids      = 1:rule_groups.Count;

play_rule_groups_table = playRuleGroupsToTable(rule_groups_ids, play_rule_groups);

% Remove rows full of zeros (no tactics are used for the play thus we
% discard them).
zero_row_idx = find(all(table2array(play_rule_groups_table)==0, 2));
play_rule_groups_table(zero_row_idx,:) = [];
shuffled_labels(zero_row_idx)          = [];

% Remove plays_info for plays that use no tactics
for f=fieldnames(plays_info)'
    zero_row_plays = ismember(1:numel(standard_plays), zero_row_idx);
    plays_info.(f{1})(zero_row_plays) = [];
end

data  = createDataForWeka(rule_groups_ids, play_rule_groups_table{:,:}, plays_info, shuffled_labels, 'contrast_type', contrast_type);

data_cpy = data;

unwanted_fields = {'team_names', 'play_rules', 'play_rule_groups', ...
                   'play_ids', 'has_clearance', 'has_interruption', 'has_foul', 'has_shot', 'has_save_attempt',...
                   'team_avg_offensive_rating', 'team_avg_defensive_rating', 'play_avg_off_rating',...
                   'team_avg_offensive_mv_range', 'team_avg_defensive_mv_range', 'play_avg_off_mv_range',...
                   'termination_reason', 'avg_def_play_height', 'game_goal_advantage', 'game_time_interval'};
for k=1:numel(unwanted_fields)
   if isfield(data_cpy, unwanted_fields{k})
       data_cpy = rmfield(data_cpy, unwanted_fields{k});
   end
end

createStrategyTablesForWeka(data_cpy, strategy_tables_folder);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create data for weka (for all plays in the region)

complete_arff_filename = [strategy_tables_complete_folder, 'complete_weka.arff'];
complete_csv_filename  = [strategy_tables_complete_folder, 'complete_weka.csv'];

data_cpy2 = data_cpy;

% Remove all fields with the word Tactic to leave only context factors
for f=fieldnames(data_cpy2)'
  is_tactic = contains(f, 'Tactic');

  if ~is_tactic
     clean_data.(f{1}) = data_cpy2.(f{1});
  end
end

createFileForWeka(clean_data, complete_arff_filename);
T = convertWekaData2Table(clean_data);
writetable(T, complete_csv_filename);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot plays per tactic
% % rule_groups_ids       = 1:rule_groups.Count;
% % 
% % play_rule_groups_table = playRuleGroupsToTable(rule_groups_ids, play_rule_groups);
% % 
% % plotPlaysPerTactic(standard_plays, play_rule_groups_table, tactic_plots_folder, 'encoding', encoding);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Run PBC4cip (per tactic)

% Grab all files in the folder (.arff extension)
strategy_tables       = dir([strategy_tables_folder '*.csv']); % read all .arff files in the strategy tables folder

for i = 1:length(strategy_tables)
    current_file = strategy_tables(i).name;
    current_table = readtable([strategy_tables_folder current_file]);

    % Count the number of plays that have the tactic
    num_success_plays_with_tactic = sum(strcmp(current_table.class, 'success'));
    num_failed_plays_with_tactic = sum(strcmp(current_table.class, 'fail'));

    % Skip only the files where no contrasts can be made
    if num_success_plays_with_tactic == 0 || num_failed_plays_with_tactic == 0
        continue;
    end

    % Grab the corresponding .arff file
    input_f  = string([strategy_tables_folder current_file(1:end-4) '.arff']);
    output_f = string([contrast_patterns_folder current_file(1:end-4) '.txt']);

    fprintf('Generating contrast pattern file for %s\r\n', current_file);
    max_depth = 4; % Corresponds to three clauses at most
    split_metric = 'Quinlan'; % 'Quinlan', 'Hellinger'
    PBC4cip_wrapper(input_f, output_f, 'filtering', 'true', 'max_depth', max_depth, 'num_trees', 300, 'node_split_measure', split_metric);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parse the contrast patterns (per tactic)
contrast_pattern_files = dir([contrast_patterns_folder '*.txt']);

contrast_pattern_collection = cell(1, length(contrast_pattern_files));

pattern_info_array = cell(1, numel(contrast_pattern_files)); % Contrast pattern length at different stages of the filtering process

%% Parse the strategy analysis results

parfor i = 1:numel(contrast_pattern_files)
    cp_filename      = contrast_pattern_files(i).name;
    cp_filename_full = [contrast_patterns_folder cp_filename];

    strategy_filename_full = [strategy_tables_folder cp_filename(1:end-4) '.csv'];

    contrast_patterns = parseContrastPatternsPBC4cip(cp_filename_full);

    % Filter contrast patterns
    [contrast_patterns, pattern_info] = filterContrastPatterns(contrast_patterns, complete_csv_filename, strategy_filename_full);

    pattern_info_array{i} = pattern_info;

    cp_info = struct();
    cp_info.patterns            = contrast_patterns;
    cp_info.filename            = cp_filename;

    contrast_pattern_collection{i} = cp_info;
     fprintf('Done with %d\r\n', i);
end

cp_table_filename = [contrast_patterns_folder 'PBC4cip_filtered_cp_table.csv'];
contrastPatternCollection2CSV(contrast_pattern_collection, cp_table_filename)

complete_pattern_list = cellfun(@(x) x.patterns, contrast_pattern_collection, 'UniformOutput', false);
complete_pattern_list = horzcat(complete_pattern_list{:});

% Store intermediate data to memory
filename = strcat(contrast_patterns_variables_folder, 'complete_pattern_list.mat');
save(filename, 'complete_pattern_list');

filename = strcat(contrast_patterns_variables_folder, 'contrast_pattern_collection.mat');
save(filename, 'contrast_pattern_collection');

filename = strcat(contrast_patterns_variables_folder, 'pattern_info_array.mat');
save(filename, 'pattern_info_array');

%% Tactical analysis of single event plays (direct corner kicks)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Standard play info
standard_plays          = region_plays_1.standard_plays;
standard_plays_labels   = region_plays_1.corner_labels;
standard_plays_info1    = region_plays_1.corner_plays_info;
standard_source_db      = region_plays_1.corner_source_db;
origin_corners          = region_plays_1.origin_corners;

% Extract folder names
tactic_stats_folder                 = direct_corner_file_struct.tactic_stats_folder;
strategy_tables_folder              = direct_corner_file_struct.strategy_tables_folder;
strategy_tables_complete_folder     = direct_corner_file_struct.strategy_tables_complete_folder;
tactic_plots_folder                 = direct_corner_file_struct.tactic_plots_folder;
contrast_patterns_folder            = direct_corner_file_struct.contrast_patterns_folder;
contrast_patterns_complete_folder   = direct_corner_file_struct.contrast_patterns_complete_folder;
contrast_patterns_variables_folder  = direct_corner_file_struct.contrast_patterns_variables_folder;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Determine the statistics for the region
group_probabilities = createSinglePassStatisticsTable(standard_plays, standard_plays_labels, 'encoding', encoding);

group_metrics_file = [tactic_stats_folder 'Tactic_probabilites.csv'];
writetable(group_probabilities, group_metrics_file);

%% Run the strategy analysis for single event plays (direct corner kicks)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Aggregate play info
plays_info_filename = strcat(saved_plays_folder, 'standard_corner_1_plays_info_full.mat');

if ~isfile(plays_info_filename)
    % Extract the complete plays info
    plays_info2 = extractPlaysInfo2(origin_corners, standard_plays, '', '', context_data.player_data, context_data.match_data, ...
                                    context_data.team_data, context_data.player_relational_db, context_data.tf_market_value_data, context_data.fifa_attr_data);
    plays_info  = aggregateContextData(standard_plays_info1, plays_info2);

    % Save plays to a matlab file
    save(plays_info_filename, 'plays_info');
else
    plays_info = load(plays_info_filename);
    plays_info = plays_info.plays_info;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create data for weka
shuffled_labels  = standard_plays_labels;
num_tactics      = 1; % The only tactic is the direct corner kick
tactic_ids       = 1:num_tactics;

% terminal_region = getEncodedEventName(standard_plays{1});
% pass_regions    = repmat(terminal_region, [numel(standard_plays), 1]);

% Assign the same tactic ID to all direct corner kicks
play_tactic_id = repmat(1, [numel(standard_plays), 1]);

play_rule_groups_table = playRuleGroupsToTable(tactic_ids, num2cell(play_tactic_id));

% Create data for weka
data  = createDataForWeka(tactic_ids, play_rule_groups_table{:,:}, plays_info, shuffled_labels, 'contrast_type', contrast_type);
               
unwanted_fields = {'team_names', 'play_rules', 'play_rule_groups', ...
                   'play_ids', 'has_clearance', 'has_interruption', 'has_foul', 'has_shot', 'has_save_attempt',...
                   'team_avg_offensive_rating', 'team_avg_defensive_rating', 'play_avg_off_rating',...
                   'team_avg_offensive_mv_range', 'team_avg_defensive_mv_range', 'play_avg_off_mv_range',...
                   'termination_reason', 'avg_def_play_height', 'game_goal_advantage', 'game_time_interval'};

for k=1:numel(unwanted_fields)
   if isfield(data, unwanted_fields{k})
       data = rmfield(data, unwanted_fields{k});
   end
end


createStrategyTablesForWeka(data, strategy_tables_folder);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Run PBC4cip

% Grab all files in the folder (.arff extension)
strategy_tables       = dir([strategy_tables_folder '*.csv']); % read all .arff files in the strategy tables folder

for i = 1:length(strategy_tables)
    current_file = strategy_tables(i).name;
    current_table = readtable([strategy_tables_folder current_file]);

    % Count the number of plays that have the tactic
    num_success_plays_with_tactic = sum(strcmp(current_table.class, 'success'));
    num_failed_plays_with_tactic = sum(strcmp(current_table.class, 'fail'));

    % Skip only the files where no contrasts can be made
    if num_success_plays_with_tactic == 0 || num_failed_plays_with_tactic == 0
        continue;
    end

    % Grab the corresponding .arff file
    input_f  = string([strategy_tables_folder current_file(1:end-4) '.arff']);
    output_f = string([contrast_patterns_folder current_file(1:end-4) '.txt']);

    fprintf('Generating contrast pattern file for %s\r\n', current_file);
    max_depth = 4; % Corresponds to three clauses at most
    split_metric = 'Quinlan'; % 'Quinlan', 'Hellinger'
    PBC4cip_wrapper(input_f, output_f, 'filtering', 'true', 'max_depth', max_depth, 'num_trees', 300, 'node_split_measure', split_metric);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parse the contrast patterns
contrast_pattern_files = dir([contrast_patterns_folder '*.txt']);

contrast_pattern_collection = cell(1, length(contrast_pattern_files));

pattern_info_array = cell(1, numel(contrast_pattern_files)); % Contrast pattern length at different stages of the filtering process

parfor i = 1:numel(contrast_pattern_files)
    cp_filename      = contrast_pattern_files(i).name;
    cp_filename_full = [contrast_patterns_folder cp_filename];

    strategy_filename_full = [strategy_tables_folder cp_filename(1:end-4) '.csv'];

    contrast_patterns = parseContrastPatternsPBC4cip(cp_filename_full);

    % Filter contrast patterns
    [contrast_patterns, pattern_info] = filterContrastPatterns(contrast_patterns, 'dummy', strategy_filename_full);

    pattern_info_array{i} = pattern_info;

    cp_info = struct();
    cp_info.patterns            = contrast_patterns;
    cp_info.filename            = cp_filename;

    contrast_pattern_collection{i} = cp_info;
     fprintf('Done with %d\r\n', i);
end

cp_table_filename = [contrast_patterns_folder 'PBC4cip_filtered_cp_table.csv'];
contrastPatternCollection2CSV(contrast_pattern_collection, cp_table_filename)

complete_pattern_list = cellfun(@(x) x.patterns, contrast_pattern_collection, 'UniformOutput', false);
complete_pattern_list = horzcat(complete_pattern_list{:});

% Store intermediate data to memory
filename = strcat(contrast_patterns_variables_folder, 'complete_pattern_list.mat');
save(filename, 'complete_pattern_list');

filename = strcat(contrast_patterns_variables_folder, 'contrast_pattern_collection.mat');
save(filename, 'contrast_pattern_collection');

filename = strcat(contrast_patterns_variables_folder, 'pattern_info_array.mat');
save(filename, 'pattern_info_array');

%% Helper functions

function corner_plays_data = filterCornerPlayData(corner_plays_data, filter)
    corner_plays_data.standard_plays        = corner_plays_data.standard_plays(filter);
    corner_plays_data.origin_corners        = corner_plays_data.origin_corners(filter);
    corner_plays_data.corner_labels         = corner_plays_data.corner_labels(filter);
    corner_plays_data.corner_source_db      = corner_plays_data.corner_source_db(filter);
    
    corner_plays_data.corner_plays_info     = filterStruct(corner_plays_data.corner_plays_info, filter);
end

function newStruct = filterStruct(myStruct, boolVec)

    % Initialize new struct
    newStruct = struct();

    % Loop through each field of the original struct
    fields = fieldnames(myStruct);
    for i = 1:length(fields)
        % Use logical indexing to select the elements where boolVec is true
        newStruct.(fields{i}) = myStruct.(fields{i})(boolVec);
    end

end

function corner_plays_data = mergeCornerData(corner_plays_data_1, corner_plays_data_2)
    corner_plays_data.standard_plays      = vertcat(corner_plays_data_1.standard_plays, corner_plays_data_2.standard_plays);
    corner_plays_data.origin_corners      = vertcat(corner_plays_data_1.origin_corners, corner_plays_data_2.origin_corners);
    corner_plays_data.corner_labels       = vertcat(corner_plays_data_1.corner_labels, corner_plays_data_2.corner_labels);
    corner_plays_data.corner_source_db    = vertcat(corner_plays_data_1.corner_source_db, corner_plays_data_2.corner_source_db);
    
    extended_info                         = extendContextData(corner_plays_data_1.corner_plays_info, corner_plays_data_2.corner_plays_info);
    corner_plays_data.corner_plays_info   = extended_info;
end