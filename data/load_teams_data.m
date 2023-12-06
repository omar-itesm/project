function teams_data = load_teams_data()
    teams_file = 'teams.json';
    filename   = fullfile(teams_file);
    filetext   = fileread(filename);
    teams_data = jsondecode(filetext);
end