function [is_super_set, super_set_of] = findContrastPatternsSupersets(pattern_data)
% The function receives all the features describing a set of contrast
% patterns (as computed by the function: prepareContrastPatternTableForDistanceFun.m), 
% and uses it to compute the euclidean distance between all the contrast patterns.

    [num_data_points, ~] = size(pattern_data);
    
    is_super_set = false(1, num_data_points);
    
    super_set_of = zeros(1, num_data_points);

    parfor ss_candidate_row = 1:num_data_points
        for base_row = 1:num_data_points
            
            % Skip ed for the same pattern
            if base_row == ss_candidate_row
                continue
            end
            
            
            base         = table2array(pattern_data(base_row, :));
            ss_candidate = table2array(pattern_data(ss_candidate_row, :));
            
            current_is_super_set = isSuperSet(base, ss_candidate);
            
            if current_is_super_set
                is_super_set(ss_candidate_row) = true;
                super_set_of(ss_candidate_row) = base_row;
                break; % Once a super set, it doesn't needs to be compared anymore
            end
            
        end
    end

end


function is_super_set = isSuperSet(base_pattern, super_set_candidate_pattern)
    is_super_set = true;

    for i = 1:numel(base_pattern)
       base_val         =  base_pattern(i);
       ss_candidate_val = super_set_candidate_pattern(i);
       
       is_valid = isValidSuperSetClause(base_val, ss_candidate_val);
       
       if ~is_valid
           is_super_set = false;
           return; % Early termination
       end
       
    end
end


function is_valid = isValidSuperSetClause(base_clause, super_set_candidate_clause)
% The function determines if the super_set_candidate_clause is a valid
% clause for a super set of the base clause.
    
    is_valid = true;

    base_clause_is_nan = isnan(base_clause);
    ss_clause_is_nan   = isnan(super_set_candidate_clause);

    
    if ~(base_clause_is_nan) && ss_clause_is_nan
        % Base clause is not in the super set candidate, it can't be a ss.
        is_valid = false;
    elseif ~(base_clause_is_nan) && ~(ss_clause_is_nan)
        is_different_value = base_clause ~= super_set_candidate_clause;
       
        % They have the same clause but with different value --> Can't be
        % a super set.
        if is_different_value
            is_valid = false;
        end
    end
    
    
end