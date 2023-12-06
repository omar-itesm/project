function out_table = createContrastPatternTable(contrast_patterns)

    var_names        = cellfun(@(x) fieldnames(x), contrast_patterns, 'UniformOutput', false);
    unique_var_names = unique(vertcat(var_names{:}));
    
    out_table = cell2table(cell(0,numel(unique_var_names)), 'VariableNames', unique_var_names);

    for i=1:numel(contrast_patterns)
        
        c_cp = contrast_patterns{i};
        
        row = cell(1,numel(unique_var_names));
        for j=1:numel(unique_var_names)        
            current_var = unique_var_names{j};
            
            if isfield(c_cp, current_var)
                value = c_cp.(current_var);
                row{j} = value;
            else
                var_type = getVariableType(current_var);
                if strcmp(var_type, 'categorical') || strcmp(current_var, 'support')
                    row{j} = '';
                elseif strcmp(var_type, 'numerical')
                    row{j} = NaN;
                end
            end  
            
        end
        
        out_table = [out_table; row];
    end
end

function var_type = getVariableType(variable_name)
    if contains(variable_name, {'_neq', '_eq'})
        var_type = 'categorical';
    elseif contains(variable_name, {'_lt','_lte','_gt','_gte'})
        var_type = 'numerical';
    else
        var_type = 'other';
    end
    
    
end