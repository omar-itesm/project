function match_data = load_match_data()
data_sets = ["World_Cup";
             "European_Championship";
             "Spain";
             "England";
             "France";
             "Germany";
             "Italy"
             ];
         
   json_files_folder = '';

    matches_file = strcat(json_files_folder, 'matches_', data_sets(1), '.json');
    filename     = fullfile(matches_file);
    filetext     = fileread(filename);
    match_data   = jsondecode(filetext);
    if isfield(match_data, 'groupName')
        match_data = rmfield(match_data, 'groupName');
    end
   
    for i=2:numel(data_sets)
        matches_file       = strcat(json_files_folder, 'matches_', data_sets(i), '.json');
        filename           = fullfile(matches_file);
        filetext           = fileread(filename);
        current_match_data = jsondecode(filetext);
        
        if isfield(current_match_data, 'groupName')
            current_match_data = rmfield(current_match_data, 'groupName');
        end
        
        match_data         = vertcat(match_data, current_match_data);
    end
end