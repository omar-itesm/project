% The function receives a structure where each field corresponds to the
% grammar of a certain class. An example of such structure is given below:
%
% grammar_structure.grammar_1.grammar_table = grammar_table_goal;
% grammar_structure.grammar_1.name  = 'Goal';
%
% grammar_structure.grammar_2.grammar_table = grammar_table_shot;
% grammar_structure.grammar_2.name  = 'Shot';
%
% grammar_structure.Properties.Success = {'Goal', 'Shot'}; % Which classes
% represnet the success class.
%
% grammar_structure.Properties.rule_groups = rule_groups; % Contains the
% rule groups applicable throughout all the grammar tables.

function group_probabilities = extractTacticGroupMetrics(grammar_structure, properties_structure, varargin)
% The function receives a tactic set structure containing the frequency of
% the tactic sets in each class.
    %% Argument parsing
    valid_encodings   = {'cannonical_corner_region_5', 'cannonical_corner_region_7'};    % Supported encodings

    
    default_encoding         = 'cannonical_corner_region_5';
    
    p = inputParser;
    
    addRequired(p, 'grammar_structure'         , @(x) isa(x, 'struct'));
    addRequired(p, 'properties_structure'       , @(x) isa(x, 'struct'));
    
    addParameter(p, 'encoding'          , default_encoding        , @(x) any(validatestring(x, valid_encodings)));
    
    parse(p, grammar_structure, properties_structure, varargin{:});
     
    encoding     = p.Results.encoding;
    

%% Code

    % Local variables
    field_names      = fieldnames(grammar_structure);
    success_classes  = properties_structure.success_classes;
    rule_groups      = properties_structure.rule_groups;
    total_plays      = properties_structure.total_plays;
    
    % Create an empty table to hold data for all the groups
    grammar_names = cellfun(@(x) grammar_structure.(x).name, fieldnames(grammar_structure),'UniformOutput',false);
    column_names  = cellfun(@(x) {strcat('Freq_', x); strcat('P(T_x|', x, ')'); strcat('P(',x,'|T_x)'); strcat(x,'_CosineMetric')}, grammar_names, 'UniformOutput', false);
    column_names  = vertcat(column_names{:});
    
    complete_column_names  = vertcat(["Group"; "Tactic Freq"; "P(Tx)"], column_names);
    
    group_probabilities = cell2table(cell(rule_groups.Count, numel(complete_column_names)), 'VariableNames', complete_column_names);
    
    % Convert empty cells to double
    for column = group_probabilities.Properties.VariableNames
       group_probabilities.(column{:}) = zeros(height(group_probabilities), 1); 
    end
    
    % Assign the tactic group (id)
    group_probabilities.Group = [1:rule_groups.Count]';

   for group_id = 1:rule_groups.Count
       
       total_pf = 0; % Total number of plays that use any tactic (rule group)
       
       % Loop through the grammars
       for f = field_names'
          current_field = grammar_structure.(f{:});
          current_table = current_field.grammar_table;
          group_data    = current_table(current_table.Group == group_id, :);
          group_pf      = sum(group_data.PF);
          
          freq_name = strcat('Freq_', current_field.name);
          group_probabilities(group_id,:).(freq_name) = group_pf;
          
          total_pf = total_pf + group_pf;   % FIXME: There is a small bug here when two rules from the same group are used in the same play, they count double
       end
       
       group_probabilities(group_id,:).('Tactic Freq') = total_pf;
   end
    
   % Compute probability 
   group_probabilities.('P(Tx)') = group_probabilities.('Tactic Freq')./total_plays;
   
   
   % Compute conditional probabilities
   for i = 1:rule_groups.Count
       
       % Frequency for the current tactic (rule group)
       tactic_freq       = group_probabilities(i,:).('Tactic Freq');
       
       % Tactic probability
       for f = field_names'
          current_field = grammar_structure.(f{:});
          
          % Compute the conditional probability P(Tx|Class)
          freq_name  = strcat('Freq_', current_field.name);
          tactic_set_class_freq = group_probabilities(i,:).(freq_name);
          class_freq            = getTotalClassPlays(current_field.name, properties_structure);
          
          tactic_set_p_tx_class_name = strcat('P(T_x|', current_field.name, ')');
          p_tx_class = tactic_set_class_freq/class_freq;
          group_probabilities(i,:).(tactic_set_p_tx_class_name) = p_tx_class;
          
          % Compute conditional probability P(Class|Tx)
          tactic_set_p_class_tx_name = strcat('P(',current_field.name,'|T_x)');
          p_class_tx = tactic_set_class_freq/tactic_freq;
          group_probabilities(i,:).(tactic_set_p_class_tx_name) = p_class_tx;
          
          % Compute relevance as the multiplication of both probabilities
          tactic_set_relevance_name = strcat(current_field.name,'_CosineMetric');
          group_probabilities(i,:).(tactic_set_relevance_name) = sqrt(p_tx_class.*p_class_tx);
          
       end
   end
   
   
   
   % Compute the metrics for the success class (this is consider a separate
   % analysis based on what we define as success).
   success_tactic_freq  = zeros(height(group_probabilities), 1);
   success_class_freq   = 0;
   
   for f = field_names'
       current_field   = grammar_structure.(f{:});
       
       is_success_field = any(contains(success_classes, current_field.name));
       
       if is_success_field
           success_class_freq = success_class_freq + getTotalClassPlays(current_field.name, properties_structure);
       end
   end
   
   for fname = success_classes
      freq_name           = strcat('Freq_', fname);
      current_freq        = group_probabilities.(freq_name{:});
      
      success_tactic_freq = success_tactic_freq  + current_freq;
   end
   
   tactic_freq       = group_probabilities.('Tactic Freq');
   p_tx_success      = success_tactic_freq./success_class_freq;
   p_success_tx      = success_tactic_freq./tactic_freq;
   success_relevance = sqrt(p_tx_success.*p_success_tx);
   
   group_probabilities.('Freq_Success')         = success_tactic_freq;
   group_probabilities.('P(T_x|Success)')       = p_tx_success;
   group_probabilities.('P(Success|T_x)')       = p_success_tx;
   group_probabilities.('Success_CosineMetric') = success_relevance;
  
   % Add the decoded core sequence of the tactic
   decoded_core_sequence = arrayfun(@(x) join(string(getGroupCoreSequence(x, rule_groups, 'encoding', encoding)), ' -> '), 1:rule_groups.Count)';
   group_probabilities.('Tactic_string') = decoded_core_sequence;
   
end

function class_plays = getTotalClassPlays(class_name, properties)

    total_goal_plays = properties.total_goal_plays;
    total_shot_plays = properties.total_shot_plays;
    total_fail_plays = properties.total_fail_plays;

    if strcmp(class_name, 'Goal')
        class_plays = total_goal_plays;
    elseif strcmp(class_name, 'Shot')
        class_plays = total_shot_plays;
    elseif strcmp(class_name, 'Fail')
        class_plays = total_fail_plays;
    elseif strcmp(class_name, 'Success')
        class_plays = total_goal_plays + total_shot_plays;
    else
        class_plays = -1;
    end

end


