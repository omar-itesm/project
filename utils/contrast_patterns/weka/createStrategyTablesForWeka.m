function createStrategyTablesForWeka(data, out_folder)
% The function receives play data and separates it based on the plays that
% use a specific tactic to create one file per tactic.

    num_tactics = sum(contains(fieldnames(data), 'Tactic'));
    
    % Make sure the out folder exists
    if ~exist(out_folder, 'dir')
       mkdir(out_folder)
    end
    
    for i=1:num_tactics
        
        tactic_data = getTacticData(data, i);

        % TODO: Search for other tactics appearing in the same plays

        current_file = [out_folder '\Tactic_' num2str(i)];
        
        % Remove the tactic attribute right before creating the file
        tactic_data = removeTacticFieldFromStruct(tactic_data);

        createFileForWeka(tactic_data, [current_file '.arff']);
        
        T = convertWekaData2Table(tactic_data);
        writetable(T, [current_file '.csv']);
        
    end
    

end

function myStruct = removeTacticFieldFromStruct(myStruct)
    fieldsToRemove = {}; % create an empty cell array to store the fields to remove
    fieldNames = fieldnames(myStruct); % get the field names of the structure

    for i = 1:length(fieldNames)
        if strncmp(fieldNames{i}, 'Tactic_', 7) % check if the field name starts with 'Tactic_'
            fieldsToRemove{end+1} = fieldNames{i}; % add the field name to the list of fields to remove
        end
    end

    myStruct = rmfield(myStruct, fieldsToRemove); % remove the fields from the structure
end
