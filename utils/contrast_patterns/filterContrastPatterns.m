function [contrast_patterns, pattern_info] = filterContrastPatterns(contrast_patterns, complete_strategy_table_file, tactic_file)
% The function performs a filter of contrast patterns based on the
% following criteria:
% - Filter patterns whose length is X or more (heuristic for poorly
%   interpretable patterns).
% - Filter patterns whose support difference is above a threshold.
% - Filter repeated patterns.*
% - Filter patterns that are a super set of other patterns.*
% - Filter non statistically significant patterns (chi-squared test).
% * Useful if the internal filtering option for PBC4cip is not used.
%
% Note:
% The function receives the complete_strategy_table_file which is a .csv file
% with the play attribute information for all plays, incluiding which
% tactic the play is using. This is used for statistically significance
% testing.

    %% Parameter data
    LENGTH_THRESH       = 4; % This number or less clauses. Notice that the clause for the tactic name counts.
    SUPPORT_DIFF_THRESH = 0.1;
    
    
    %% Initialization
    pattern_info = struct();
    pattern_info.input_lengths = [];
    pattern_info.input_num_patterns = 0;
    pattern_info.input_num_success_patterns = 0;
    pattern_info.input_num_failed_patterns = 0;
    
    pattern_info.filter_1_lengths = [];
    pattern_info.filter_1_num_patterns = 0;
    pattern_info.filter_1_num_success_patterns = 0;
    pattern_info.filter_1_num_failed_patterns = 0;
    
    pattern_info.filter_2_lengths = [];
    pattern_info.filter_2_num_patterns = 0;
    pattern_info.filter_2_num_success_patterns = 0;
    pattern_info.filter_2_num_failed_patterns = 0;
    
    pattern_info.filter_3_lengths = [];
    pattern_info.filter_3_num_patterns = 0;
    pattern_info.filter_3_num_success_patterns = 0;
    pattern_info.filter_3_num_failed_patterns = 0;
    
    pattern_info.filter_4_lengths = [];
    pattern_info.filter_4_num_patterns = 0;
    pattern_info.filter_4_num_success_patterns = 0;
    pattern_info.filter_4_num_failed_patterns = 0;
    
    pattern_info.filter_5_lengths = [];
    pattern_info.filter_5_num_patterns = 0;
    pattern_info.filter_5_num_success_patterns = 0;
    pattern_info.filter_5_num_failed_patterns = 0;
    
    pattern_info.filter_6_lengths = [];
    pattern_info.filter_6_num_patterns = 0;
    pattern_info.filter_6_num_success_patterns = 0;
    pattern_info.filter_6_num_failed_patterns = 0;
    
    %% Input description
    pattern_info.input_lengths      = cellfun(@(x) x.length, contrast_patterns);
    pattern_info.input_num_patterns = numel(contrast_patterns);
    support_diff = cellfun(@(x) computePatternSupportDiff(x.support, 'output_type', 'signed'), contrast_patterns);
    pattern_info.input_num_success_patterns = sum(support_diff > 0);
    pattern_info.input_num_failed_patterns  = sum(support_diff < 0);
    
    
%     %% Length filter (Filter 1)
%     if isempty(contrast_patterns)
%         return
%     end
%     contrast_patterns = contrast_patterns(pattern_info.input_lengths <= LENGTH_THRESH);
%     
%     % Pattern info
%     pattern_info.filter_1_lengths      = cellfun(@(x) x.length, contrast_patterns);
%     pattern_info.filter_1_num_patterns = numel(contrast_patterns);
%     support_diff = cellfun(@(x) computePatternSupportDiff(x.support, 'output_type', 'signed'), contrast_patterns);
%     pattern_info.filter_1_num_success_patterns = sum(support_diff > 0);
%     pattern_info.filter_1_num_failed_patterns  = sum(support_diff < 0);
    
%     %% Support difference filter (Filter 2)
%     if isempty(contrast_patterns)
%         return
%     end
%     support_differences = cellfun(@(x) computePatternSupportDiff(x.support), contrast_patterns);
%     contrast_patterns   = contrast_patterns(support_differences >= SUPPORT_DIFF_THRESH);
%     
%     % Pattern info
%     pattern_info.filter_2_lengths      = cellfun(@(x) x.length, contrast_patterns);
%     pattern_info.filter_2_num_patterns = numel(contrast_patterns);
%     support_diff = cellfun(@(x) computePatternSupportDiff(x.support, 'output_type', 'signed'), contrast_patterns);
%     pattern_info.filter_2_num_success_patterns = sum(support_diff > 0);
%     pattern_info.filter_2_num_failed_patterns  = sum(support_diff < 0);
    
%     %% Repeated pattern filter (Filter 3)
%     if isempty(contrast_patterns)
%         return
%     end
%     contrast_patterns   = removeRepeatedContrastPatterns(contrast_patterns);
%     
%     % Pattern info
%     pattern_info.filter_3_lengths      = cellfun(@(x) x.length, contrast_patterns);
%     pattern_info.filter_3_num_patterns = numel(contrast_patterns);
%     support_diff = cellfun(@(x) computePatternSupportDiff(x.support, 'output_type', 'signed'), contrast_patterns);
%     pattern_info.filter_3_num_success_patterns = sum(support_diff > 0);
%     pattern_info.filter_3_num_failed_patterns  = sum(support_diff < 0);
    
    %% Remove redundant contrast patterns (Filter 4)
    if isempty(contrast_patterns)
        return
    end
    contrast_patterns = removeRedundantPatterns(contrast_patterns);
    
    % Pattern info
    pattern_info.filter_4_lengths      = cellfun(@(x) x.length, contrast_patterns);
    pattern_info.filter_4_num_patterns = numel(contrast_patterns);
    support_diff = cellfun(@(x) computePatternSupportDiff(x.support, 'output_type', 'signed'), contrast_patterns);
    pattern_info.filter_4_num_success_patterns = sum(support_diff > 0);
    pattern_info.filter_4_num_failed_patterns  = sum(support_diff < 0);
    
    %% Superset pattern filter (Filter 5)
    if isempty(contrast_patterns)
        return
    end
    contrast_patterns   = removeSuperSetContrastPatterns(contrast_patterns);

    % Pattern info
    pattern_info.filter_5_lengths      = cellfun(@(x) x.length, contrast_patterns);
    pattern_info.filter_5_num_patterns = numel(contrast_patterns);
    support_diff = cellfun(@(x) computePatternSupportDiff(x.support, 'output_type', 'signed'), contrast_patterns);
    pattern_info.filter_5_num_success_patterns = sum(support_diff > 0);
    pattern_info.filter_5_num_failed_patterns  = sum(support_diff < 0);
    
    %% Statistical significance filter (Filter 6)
    
    if isempty(contrast_patterns)
        return
    end
    [contrast_patterns, ~] = removeStatisticallyInsignificantContrastPatterns(contrast_patterns, tactic_file, numel(contrast_patterns));
    
    % Pattern info
    pattern_info.filter_6_lengths      = cellfun(@(x) x.length, contrast_patterns);
    pattern_info.filter_6_num_patterns = numel(contrast_patterns);
    support_diff = cellfun(@(x) computePatternSupportDiff(x.support, 'output_type', 'signed'), contrast_patterns);
    pattern_info.filter_6_num_success_patterns = sum(support_diff > 0);
    pattern_info.filter_6_num_failed_patterns  = sum(support_diff < 0);
    
%    fprintf('Output contrast pattern size: %d\r\n', numel(contrast_patterns)); 
end

function contrast_patterns = removeRepeatedContrastPatterns(contrast_patterns)
    isUnique = true(size(contrast_patterns));
    parfor ii = 1:length(contrast_patterns)-1
        for jj = ii+1:length(contrast_patterns)
            if isequal(contrast_patterns(ii),contrast_patterns(jj))
                isUnique(ii) = false;
                break;
            end
        end
    end
    contrast_patterns(~isUnique) = [];
end

function contrast_patterns = removeSuperSetContrastPatterns(contrast_patterns)
    contrast_patterns_table   = createContrastPatternTable(contrast_patterns);
    normalized_patterns_table = prepareContrastPatternTableForDistanceFun(contrast_patterns_table);

    [super_set_indexes, ~]    = findContrastPatternsSupersets(normalized_patterns_table);

    contrast_patterns(super_set_indexes) = [];
end

function [contrast_patterns, support_vec] = removeStatisticallyInsignificantContrastPatterns(contrast_patterns, filename, varargin)
    %% Parameter
    default_num_tests = 1;

    p = inputParser;

    addRequired(p, 'contrast_patterns', @(x) isa(x, 'cell'));
    addRequired(p, 'filename', @(x) isa(x, 'char'));
    addOptional(p, 'num_tests', default_num_tests);

    parse(p, contrast_patterns, filename, varargin{:});

    num_tests = p.Results.num_tests;
    
    %% Algorithm
    % Finds if the contrast patterns are statistically significant on the
    % input data set given by the filename parameter. Statistically
    % insignificant parameters get removed.
    
    is_significant_vec = false(size(contrast_patterns));
    support_vec        = cell(1, numel(contrast_patterns));
    
%     parfor i = 1:numel(contrast_patterns)
    for i = 1:numel(contrast_patterns)
        current_pattern = contrast_patterns{i};
        
        [is_valid, is_significant, chi_val, p_val, support] = isStatisticallySignificantCP(current_pattern, filename, num_tests);
        
        is_significant_vec(i) = is_significant;
        support_vec{i}        = support;
    end
    
    contrast_patterns(~is_significant_vec) = [];
    support_vec(~is_significant_vec)       = [];
end

function contrast_patterns = removeRedundantPatterns(contrast_patterns)

    same_clauses_groups = containers.Map('KeyType','double', 'ValueType','any');
    complete_same_clause_indexes     = [];
    
    group_id = 1;

    % Find which patterns have the same clauses
    for i = 1:numel(contrast_patterns) - 1
        
        visited_index = any(complete_same_clause_indexes==i);
        
        % Skip indexes where we have already found redundant patterns
        if visited_index
           continue; 
        end
        
        current_pattern = contrast_patterns{i};
        
        same_clauses_indexes = findSameClausesIndexes(current_pattern, contrast_patterns(i+1:end));
        
        % Apply offset
        same_clauses_indexes = same_clauses_indexes + i;
        
        % Add current index
        same_clauses_indexes = [same_clauses_indexes, i];
                
        % Create group of same clause indexes
        if numel(same_clauses_indexes) > 1
            % Keep track of indexes where same clauses have been found
            complete_same_clause_indexes = [complete_same_clause_indexes, same_clauses_indexes];
            
            same_clauses_groups(group_id) = same_clauses_indexes;
            group_id = group_id + 1;
        end
        
    end
    
    % Replace the same clause patterns with a single summarizing pattern
    non_redundant_patterns = contrast_patterns;
    non_redundant_patterns(complete_same_clause_indexes) = [];
    
    val = values(same_clauses_groups) ;
    for i = 1:numel(val)
        
        related_patterns_index = val{i};
        
        related_patterns = contrast_patterns(related_patterns_index);
        
        summarizing_contrast_pattern = summarizeRelatedPatterns(related_patterns);
        
        non_redundant_patterns = [non_redundant_patterns, summarizing_contrast_pattern];
    end
    
    contrast_patterns = non_redundant_patterns;
end

function contrast_pattern = summarizeRelatedPatterns(related_patterns)
    fnames = fieldnames(related_patterns{1});
    
    % Remove never repeated fields
    fnames = fnames(~contains(fnames,'Tactic'));
    fnames = fnames(~contains(fnames,'length'));
    fnames = fnames(~contains(fnames,'support'));
    
    problematic_fields = {};
    
    for i=1:numel(fnames)
        
        current_field = fnames{i};
        
        if ~contains(current_field, '_lt') && ~contains(current_field, '_gt')
            continue;
        end
        
        values = cellfun(@(x) x.(current_field), related_patterns);
       
        % Detect fields with more than one possible value
        if numel(unique(values)) ~= 1
            problematic_fields = [problematic_fields, current_field];
        end
    end
    
    % The assumption is that the input related patterns always have
    % problematic fields
%     if isempty(problematic_fields)
%        return 
%     end
    
    % Greater than fields
    gt_fields_filter = cellfun(@(x) contains(x,'_gt'), problematic_fields);
    lt_fields_filter = cellfun(@(x) contains(x,'_lt'), problematic_fields);

    gt_fields = problematic_fields(gt_fields_filter);
    lt_fields = problematic_fields(lt_fields_filter);
    
    min_votes = zeros(1, numel(related_patterns)); % Count which pattern gets the most min votes for all fields
    max_votes = zeros(1, numel(related_patterns)); % Count which pattern gets the most max votes for all fields
    
    for i=1:numel(gt_fields)
        current_field = gt_fields{i};
        
        values = cellfun(@(x) x.(current_field), related_patterns);
        
        min_val = min(values);
        
        
        min_votes = min_votes + double(values==min_val);
    end
    
    for i=1:numel(lt_fields)
        current_field = lt_fields{i};
        
        values = cellfun(@(x) x.(current_field), related_patterns);
        max_val = max(values);
        
        max_votes = max_votes + double(values==max_val);
    end
    
    total_votes = min_votes + max_votes;
    
    max_total_votes = max(total_votes);
    
    
    num_best_patterns = sum(total_votes == max_total_votes);
    
    % If more than one pattern is the best candidate decide based on
    % support difference
    
    if num_best_patterns > 1
        max_support_diff = 0;
        max_diff_index = 1;
        
        % Compute support difference
        support_diff = cellfun(@(x) computePatternSupportDiff(x.support, 'output_type', 'unsigned'), related_patterns, 'UniformOutput', false);
        
        candidate_indexes = total_votes == max_total_votes;
        
        for i=1:numel(candidate_indexes)
            current_support_diff = support_diff{i};
            
            if current_support_diff > max_support_diff
                max_support_diff = current_support_diff;
                max_diff_index = i;
            end
        end
        
        
        contrast_pattern = related_patterns(max_diff_index);
    else
        contrast_pattern = related_patterns(total_votes == max_total_votes);
    end
end

function same_clauses_indexes = findSameClausesIndexes(contrast_pattern, contrast_pattern_list)
% The function receives a contrast pattern and searches all contrast
% patterns with the same clauses in the input contrast pattern list.
% Finally, the indexes of all the contrast patterns with the same clauses
% are returned.
    same_clauses_indexes = [];
    
    for i = 1:numel(contrast_pattern_list)
        current_pattern = contrast_pattern_list{i};
        
        has_same_clauses = checkSameClauses(contrast_pattern, current_pattern);
        
        if has_same_clauses
            same_clauses_indexes = [same_clauses_indexes, i];
        end
        
    end
end

function has_same_clauses = checkSameClauses(pattern_1, pattern_2)
% The function checks if the two contrast patterns have the exact same
% clauses.

    % Default value
    has_same_clauses = true;

    names_1 = fieldnames(pattern_1);
    names_2 = fieldnames(pattern_2);
    
    % Check if both patterns have the same number of clauses
    if numel(names_1) ~= numel(names_2)
        has_same_clauses = false;
        return;
    end
    
    % Check that pattern 2 has all the same fields as pattern 1
    for i=1:numel(names_1)
        if ~isfield(pattern_2, names_1{i})
            has_same_clauses = false;
            return;
        end
    end
    
    % return default value (true)
end


%%
function contrast_patterns = removeRepeatedFields(contrast_patterns)
    % Check for patterns with duplicate fields and see if we can simplify the
    % pattern.
    for i = 1:numel(contrast_patterns)
        current_pattern = contrast_patterns{i};

        has_repeated_fields = checkRepeatedFields(current_pattern);

        if has_repeated_fields
           % TODO: Handle the repeated fields case
           disp('Implementation pending');
        end

    end
end

function has_repeated_fields = checkRepeatedFields(contrast_pattern)
    fnames = fieldnames(contrast_pattern);
    
    % Remove never repeated fields
    fnames = fnames(~contains(fnames,'Tactic'));
    fnames = fnames(~contains(fnames,'length'));
    fnames = fnames(~contains(fnames,'support'));
    
    names = cellfun(@(x) regexprep(x, '\d+(?:_(?=\d))?', ''), fnames, 'UniformOutput', false);
    
    counts = sum(cellfun(@(x) countRepeatedFields(contrast_pattern, x), names));
    
    if counts == numel(fnames)
        has_repeated_fields = false;
    else
        has_repeated_fields = true;
    end
    
end
