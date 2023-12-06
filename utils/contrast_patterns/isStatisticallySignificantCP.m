function [is_valid, is_significant, chi_val, p_val, support] = isStatisticallySignificantCP(cp, dataset_filename, varargin)
% The function determines if the contrast pattern is statistically
% significant in the input data set using a chi-square test.

    %% Parameter
    default_num_tests = 1;

    p = inputParser;

    addRequired(p, 'cp', @(x) isa(x, 'struct'));
    addRequired(p, 'dataset_filename', @(x) isa(x, 'char'));
    addOptional(p, 'num_tests', default_num_tests);

    parse(p, cp, dataset_filename, varargin{:});

    num_tests = p.Results.num_tests;

    %% Algorithm

    % Initialization
    is_significant = false;

    % Complete data set
    D = readtable(dataset_filename);

    [plays_with_pattern, plays_without_pattern] = findPlaysWithPatternFromStrategyTable(cp, D);
    np_f = sum(strcmp(plays_without_pattern.class, 'fail'));
    np_s = sum(strcmp(plays_without_pattern.class, 'success'));
    p_s  = sum(strcmp(plays_with_pattern.class, 'success'));
    p_f  = sum(strcmp(plays_with_pattern.class, 'fail'));
    
%     [is_valid, chi_val, p_val] = computeStatisticalSignificanceYates(p_s, p_f, np_s, np_f);
    [is_valid, chi_val, p_val] = computeStatisticalSignificance(p_s, p_f, np_s, np_f);
    
    % Compute the support in the data set for each class
    support.success = round(p_s/(np_s+p_s), 2);
    support.failed  = round(p_f/(np_f+p_f), 2);
    
    % Check if the test is significant only if valid
    if p_val < (0.05/num_tests) && is_valid
        is_significant = true;
    end

end


