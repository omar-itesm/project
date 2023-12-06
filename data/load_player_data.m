function player_data = load_player_data()
    players_file = 'players.json';
    filename     = fullfile(players_file);
    filetext     = fileread(filename);
    player_data  = jsondecode(filetext);
end