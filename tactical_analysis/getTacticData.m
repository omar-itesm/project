function tactic_data = getTacticData(data, tactic)
    tactic_str  = strcat('Tactic_', num2str(tactic));


    % Build the reduced data
    tactic_data = struct();
    tactic_data.(tactic_str) = data.(tactic_str);

    for f=fieldnames(data)'
      is_tactic = contains(f, 'Tactic');

      if ~is_tactic
         tactic_data.(f{1}) = data.(f{1});
      end
    end

    % Remove plays_info for plays that have use no tactics
    zero_row_idx = tactic_data.(tactic_str).data == "f";

    for f=fieldnames(tactic_data)'
        tactic_data.(f{1}).data(zero_row_idx) = [];
    end
    
%     % Get all the tactics used in conjuction with the current tactic.
%     complete_tactics = arrayfun(@(x) str2double(split(x, '-'))', tactic_data.play_rule_groups.data, 'UniformOutput', false);
%     unique_tactics   = unique([complete_tactics{:}]);
%     extra_tactics    = unique_tactics(unique_tactics~=tactic);
%     
%     num_plays = numel(tactic_data.class.data);
%     
%     temp_vector = [];
%     for i=1:numel(extra_tactics)
%         extra_tactic = extra_tactics(i);
%         
%        
%        for j=1:num_plays
%            
%            if any(ismember(complete_tactics{j}, extra_tactic))
%                contains_extra_tactic = 1;
%            else
%                contains_extra_tactic = 0;
%            end
%            
%            temp_vector = [temp_vector contains_extra_tactic];
%        end
%        
%        tactic_str  = strcat('Tactic_', num2str(extra_tactic));
%        
%        temp_vector_string = strings(size(temp_vector));
%        temp_vector_string(temp_vector == 0) = 'f';
%        temp_vector_string(temp_vector == 1) = 't';
%        
%        tactic_data.(tactic_str) = createFieldForWeka(tactic_str, temp_vector_string(:));
%        
%        temp_vector = [];
%     end
    
    
end

function field = createFieldForWeka(name, data, varargin)

    % TODO: Add support for non-numeric fields

    field.name = name;
    field.data = data;
    
    if isa(data, 'string') 
        field.type = 'nominal';
        field.nominalspec = strjoin(unique(data),',');
    elseif isa(data, 'double')
        field.type = 'real';
    else
        disp('TODO');
    end

end