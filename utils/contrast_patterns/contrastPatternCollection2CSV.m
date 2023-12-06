function contrastPatternCollection2CSV(contrast_pattern_collection, out_filename)
    num_collection_elems = numel(contrast_pattern_collection);
    
    total_patterns = sum(cellfun(@(x) numel(x.patterns), contrast_pattern_collection));
    
    cp_strings             = strings(total_patterns, 1);
    source_tactic          = strings(total_patterns, 1);
    tactic_support.success = zeros(total_patterns, 1);
    tactic_support.fail    = zeros(total_patterns, 1);
    real_support.success   = zeros(total_patterns, 1);
    real_support.fail      = zeros(total_patterns, 1);
    
    index = 1;
    for i = 1:num_collection_elems
        current_collection       = contrast_pattern_collection{i};
        patterns                 = current_collection.patterns;
        current_filename         = current_collection.filename;
        
        for j = 1:numel(patterns)
            current_pattern          = patterns{j};
            current_tactic_support   = current_pattern.support;
            
            % Source
            source_tactic(index)     = string(current_filename(1:end-4));
            
            % Contrast pattern string
            cp_strings(index) = contrastPattern2string(current_pattern);
            
            % Tactic support
            [tactic_support_s, tactic_support_f] = supportString2double(current_tactic_support);
            tactic_support.success(index) = tactic_support_s;
            tactic_support.fail(index)    = tactic_support_f;
            
            index = index + 1; 
        end
        
    end
    
    T = table();
    
    T.('Contrast Pattern')      = cp_strings;
    T.('Tactic S support')      = tactic_support.success;
    T.('Tactic F support')      = tactic_support.fail;
    T.('Tactic support diff')   = abs(tactic_support.success - tactic_support.fail);
    T.('Source tactic')         = source_tactic;
    
    writetable(T, out_filename);
end