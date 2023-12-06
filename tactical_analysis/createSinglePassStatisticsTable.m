function group_probabilities = createSinglePassStatisticsTable(single_pass_plays, play_labels, varargin)
% The function receives a set of single pass plays and computes the
% statistics for them. Notice that plays need to be in the standard form so
% that the region encoding works correctly.


    %% Argument parsing
    valid_encodings   = {'cannonical_corner_region_5', 'cannonical_corner_region_7'};    % Supported encodings

    
    default_encoding         = 'cannonical_corner_region_5';
    
    p = inputParser;
    
    addRequired(p, 'single_pass_plays', @(x) isa(x, 'cell'));
    addRequired(p, 'play_labels'      , @(x) isa(x, 'double'));
    
    addParameter(p, 'encoding'          , default_encoding        , @(x) any(validatestring(x, valid_encodings)));
    
    parse(p, single_pass_plays, play_labels, varargin{:});
     
    encoding     = p.Results.encoding;
    
    %% Count the number of plays for each region and class
    
    % Find the name of the pass event according to the current encoding
    pass_regions = cellfun(@(x) getEncodedEventName(x, 'encoding', encoding), single_pass_plays);
    
    % Find the total number of plays for each region
    [unique_pass_regions,~,idx] = unique(pass_regions);
    counts = histcounts(idx);
    
    pass_regions_total_counts = containers.Map(unique_pass_regions, counts);
    
    % Find the total number of failed plays for each region
    FAIL_LABEL = 0;
    
    failed_pass_regions = pass_regions(play_labels == FAIL_LABEL);
    [unique_pass_regions_for_class,~,idx] = unique(failed_pass_regions);
    counts = histcounts(idx);
    
    pass_regions_failed_counts = containers.Map(unique_pass_regions_for_class, counts);
    pass_regions_failed_counts = fillMissingKeysWithZero(pass_regions_total_counts, pass_regions_failed_counts);
    
    % Find the total number of goal plays for each region
    GOAL_LABEL = 1;
    
    goal_pass_regions = pass_regions(play_labels == GOAL_LABEL);
    [unique_pass_regions_for_class,~,idx] = unique(goal_pass_regions);
    counts = histcounts(idx);
    
    pass_regions_goal_counts = containers.Map(unique_pass_regions_for_class, counts);
    pass_regions_goal_counts = fillMissingKeysWithZero(pass_regions_total_counts, pass_regions_goal_counts);
    
    % Find the total number of shot plays for each region
    SHOT_LABEL = 2;
    
    shot_pass_regions = pass_regions(play_labels == SHOT_LABEL);
    [unique_pass_regions_for_class,~,idx] = unique(shot_pass_regions);
    counts = histcounts(idx);
    
    pass_regions_shot_counts = containers.Map(unique_pass_regions_for_class, counts);
    pass_regions_shot_counts = fillMissingKeysWithZero(pass_regions_total_counts, pass_regions_shot_counts);
    
    % Find the total number of success plays for each region
    success_pass_regions = pass_regions(play_labels == GOAL_LABEL | play_labels == SHOT_LABEL);
    [unique_pass_regions_for_class,~,idx] = unique(success_pass_regions);
    counts = histcounts(idx);
    
    pass_regions_success_counts = containers.Map(unique_pass_regions_for_class, counts);
    pass_regions_success_counts = fillMissingKeysWithZero(pass_regions_total_counts, pass_regions_success_counts);
    
    %% Compute probabilities
    tactic_probabilities = cell2mat(values(pass_regions_total_counts))/numel(single_pass_plays);
    pass_regions_prob    = containers.Map(unique_pass_regions, tactic_probabilities);
    
    % Fail class
    
    num_plays_in_class = sum(cell2mat(pass_regions_failed_counts.values));
    
    p_tactic_given_class = cell2mat(values(pass_regions_failed_counts))./num_plays_in_class;
    p_class_given_tactic = cell2mat(values(pass_regions_failed_counts))./cell2mat(values(pass_regions_total_counts));
    
    cosine_metric        = sqrt(p_tactic_given_class.*p_class_given_tactic);
    
    pass_regions_prob_tactic_given_fail    = containers.Map(unique_pass_regions, p_tactic_given_class);
    pass_regions_prob_fail_given_tactic    = containers.Map(unique_pass_regions, p_class_given_tactic);
    pass_regions_fail_cosine_metric        = containers.Map(unique_pass_regions, cosine_metric);
    
    % Goal class
    
    num_plays_in_class = sum(cell2mat(pass_regions_goal_counts.values));
    
    p_tactic_given_class = cell2mat(values(pass_regions_goal_counts))./num_plays_in_class;
    p_class_given_tactic = cell2mat(values(pass_regions_goal_counts))./cell2mat(values(pass_regions_total_counts));
    
    cosine_metric        = sqrt(p_tactic_given_class.*p_class_given_tactic);
    
    pass_regions_prob_tactic_given_goal    = containers.Map(unique_pass_regions, p_tactic_given_class);
    pass_regions_prob_goal_given_tactic    = containers.Map(unique_pass_regions, p_class_given_tactic);
    pass_regions_goal_cosine_metric        = containers.Map(unique_pass_regions, cosine_metric);
    
    % Shot class
    
    num_plays_in_class = sum(cell2mat(pass_regions_shot_counts.values));
    
    p_tactic_given_class = cell2mat(values(pass_regions_shot_counts))./num_plays_in_class;
    p_class_given_tactic = cell2mat(values(pass_regions_shot_counts))./cell2mat(values(pass_regions_total_counts));
    
    cosine_metric        = sqrt(p_tactic_given_class.*p_class_given_tactic);
    
    pass_regions_prob_tactic_given_shot    = containers.Map(unique_pass_regions, p_tactic_given_class);
    pass_regions_prob_shot_given_tactic    = containers.Map(unique_pass_regions, p_class_given_tactic);
    pass_regions_shot_cosine_metric        = containers.Map(unique_pass_regions, cosine_metric);
    
    % Success class
    
    num_plays_in_class = sum(cell2mat(pass_regions_success_counts.values));
    
    p_tactic_given_class = cell2mat(values(pass_regions_success_counts))./num_plays_in_class;
    p_class_given_tactic = cell2mat(values(pass_regions_success_counts))./cell2mat(values(pass_regions_total_counts));
    
    cosine_metric        = sqrt(p_tactic_given_class.*p_class_given_tactic);
    
    pass_regions_prob_tactic_given_success    = containers.Map(unique_pass_regions, p_tactic_given_class);
    pass_regions_prob_success_given_tactic    = containers.Map(unique_pass_regions, p_class_given_tactic);
    pass_regions_success_cosine_metric        = containers.Map(unique_pass_regions, cosine_metric);
    
    %% Create a table with the extracted information
    
    class_names   = ["Goal", "Shot", "Fail", "Success"];
    column_names  = arrayfun(@(x) {strcat('Freq_', x); strcat('P(T_x|', x, ')'); strcat('P(',x,'|T_x)'); strcat(x,'_CosineMetric')}, class_names, 'UniformOutput', false);
    column_names  = vertcat(column_names{:});
    
    complete_column_names  = vertcat(["Group"; "Tactic Freq"; "P(Tx)"], column_names);
    
    group_probabilities = cell2table(cell(numel(unique_pass_regions), numel(complete_column_names)), 'VariableNames', complete_column_names);
    group_probabilities.('Tactic_string') = unique_pass_regions;
    
    % Compute frequencies for each tactic

    group_probabilities.('Group')                  = double([1:pass_regions_total_counts.Count]');
    group_probabilities.('Tactic Freq')            = cell2mat(pass_regions_total_counts.values)';
    group_probabilities.('P(Tx)')                  = cell2mat(pass_regions_prob.values)';

    group_probabilities.('Freq_Fail')              = cell2mat(pass_regions_failed_counts.values)';
    group_probabilities.('P(T_x|Fail)')            = cell2mat(pass_regions_prob_tactic_given_fail.values)';
    group_probabilities.('P(Fail|T_x)')            = cell2mat(pass_regions_prob_fail_given_tactic.values)';
    group_probabilities.('Fail_CosineMetric')      = cell2mat(pass_regions_fail_cosine_metric.values)';

    group_probabilities.('Freq_Goal')              = cell2mat(pass_regions_goal_counts.values)';
    group_probabilities.('P(T_x|Goal)')            = cell2mat(pass_regions_prob_tactic_given_goal.values)';
    group_probabilities.('P(Goal|T_x)')            = cell2mat(pass_regions_prob_goal_given_tactic.values)';
    group_probabilities.('Goal_CosineMetric')      = cell2mat(pass_regions_goal_cosine_metric.values)';

    group_probabilities.('Freq_Shot')              = cell2mat(pass_regions_shot_counts.values)';
    group_probabilities.('P(T_x|Shot)')            = cell2mat(pass_regions_prob_tactic_given_shot.values)';
    group_probabilities.('P(Shot|T_x)')            = cell2mat(pass_regions_prob_shot_given_tactic.values)';
    group_probabilities.('Shot_CosineMetric')      = cell2mat(pass_regions_shot_cosine_metric.values)';

    group_probabilities.('Freq_Success')           = cell2mat(pass_regions_success_counts.values)';
    group_probabilities.('P(T_x|Success)')         = cell2mat(pass_regions_prob_tactic_given_success.values)';
    group_probabilities.('P(Success|T_x)')         = cell2mat(pass_regions_prob_success_given_tactic.values)';
    group_probabilities.('Success_CosineMetric')   = cell2mat(pass_regions_success_cosine_metric.values)';

    group_probabilities.('Tactic_string')          = unique_pass_regions;
    
end

function map_container_B = fillMissingKeysWithZero(map_container_A, map_container_B)
% The function takes two map containers A and B and it uses all the keys
% that exist in the first map but not in the second to create the missing
% key in the second map with a default value of zero.

    keys_A = keys(map_container_A);
    for i = 1:length(keys_A)
        key = keys_A{i};
        if ~isKey(map_container_B, key)
            map_container_B(key) = 0;
        end
    end
end