function cp_string = contrastPattern2string(contrast_pattern)
    invalid_fields = {'length', 'support', 'Properties', 'Row', 'Variables'}; % Some of them are due to patterns sometimes being specified as tables
    
    pattern_attributes = fieldnames(contrast_pattern);
    
    cp_string = '';
    
    for attribute_name=pattern_attributes'
       
        
        is_valid_field = ~any(strcmp(attribute_name, invalid_fields)); % TODO: Improve valid definition
        
        if is_valid_field
            [attr, operator] = getOperatorFromAttributeName(attribute_name{:});
        
            attr_value = contrast_pattern.(attribute_name{:});

            operator_symbol = getOperatorSymbol(operator);

            
            if isnumeric(attr_value)
                s = sprintf('%s %s %.2f AND', attr, operator_symbol, attr_value);
            else
                s = sprintf('%s %s %s AND', attr, operator_symbol, attr_value);
            end
            
            cp_string = strcat(cp_string, [' ' s]);
        end
    end
    
    % Remove the last 'AND ' and the first ' ' 
    cp_string = cp_string(2:end-4);
    
    cp_string = string(cp_string);
end


function symbol = getOperatorSymbol(operator)
% The function receives an operator and returns its symbol
    switch operator
        case 'neq'
            symbol = '~=';
        case 'eq' 
            symbol = '=';
        case 'lt' 
            symbol = '<';
        case 'lte'
            symbol = '<=';
        case 'gt' 
            symbol = '>';
        case 'gte'
            symbol = '>=';
        otherwise
            symbol = false;
            warning('Unexpected behavior at determineClauseCompliance');
    end
end