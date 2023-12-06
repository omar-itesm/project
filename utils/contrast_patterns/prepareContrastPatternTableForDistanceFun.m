function contrast_pattern_table = prepareContrastPatternTableForDistanceFun(contrast_pattern_table, varargin)
% The function standarizes numerical variables and performs one hot
% encoding on non numerical variables. The function expects the contrast
% pattern table as computed by: createContrastPatternTable.m

    % Parameters
    default_normalize_data = false;
    
    p = inputParser;
    
    addRequired(p , 'contrast_pattern_table', @(x) isa(x, 'table'));
    addParameter(p, 'normalize'             , default_normalize_data, @(x) isa(x, 'logical'));
    
    parse(p, contrast_pattern_table, varargin{:});
    
    normalize_data = p.Results.normalize;
    
    %% Implementation

    % Remove attributes not used for distance function
    contrast_pattern_table.length  = [];
    contrast_pattern_table.support = [];

    var_names = contrast_pattern_table.Properties.VariableNames;
    
    numeric_vars_filter = ~contains(var_names, {'_neq','_eq'});


    if normalize_data
        numeric_vars           = var_names(numeric_vars_filter);
        contrast_pattern_table = normalize(contrast_pattern_table,'norm','DataVariables', numeric_vars);
    end
    
    % Convert categorical columns using the categorical function and
    % onehotencoding
    contrast_pattern_table.Key = (1:height(contrast_pattern_table))';
    
    categorical_vars    = var_names(~numeric_vars_filter);
    for i=1:numel(categorical_vars)
        current_var  = categorical_vars{i};
        current_data = contrast_pattern_table.(current_var);
        current_data = categorical(current_data);
        
        current_data = onehotencode(table(current_data));   % FIXME: The zero values must be converted to NaN to avoid fake values in the data
        
        current_data.Properties.VariableNames = cellfun(@(x) [current_var, '_', x], current_data.Properties.VariableNames, 'UniformOutput', false);
        current_data.Key = (1:height(current_data))';
        
        contrast_pattern_table.(current_var) = [];
        contrast_pattern_table = innerjoin(contrast_pattern_table, current_data, 'Keys', 'Key');
    end
    
    contrast_pattern_table.Key = [];
    
end