% The function extracts the plays from all the available data sets and
% stores them into .mat files.
clear; close all; clc;

%%

player_data          = struct2table(load_player_data());
match_data           = load_match_data();
team_data            = load_teams_data();
% tf_market_value_data = load_tf_market_value_data();
fifa_attr_data       = load_fifa_attribute_data();
% load player_relational_db.mat

tf_market_value_dictionary = load('tf_market_value_dictionary.mat').tf_market_value_dictionary;
pid_to_tf_pid = load('pid_to_tf_pid.mat').pid_to_tf_pid;


%%

data_sets = ["World_Cup";
             "European_Championship";
             "Spain";
             "England";
             "France";
             "Germany";
             "Italy"
             ];

json_files_folder = 'data/';
plays_folder      = 'data/plays/';
offset            = 0; % Initialize variable

if ~exist(plays_folder, 'dir')
   mkdir(plays_folder)
end

source_db = []; % Array to store the source db of the complete plays in order
plays_source_db_file_name = strcat(plays_folder, 'plays_source_db.mat');

for i=1:numel(data_sets)
    event_db_filename               = strcat(json_files_folder, 'events_', data_sets(i), '.json');
    out_plays_file_name             = strcat(plays_folder, 'plays_', data_sets(i), '.mat');
    out_plays_termination_file_name = strcat(plays_folder, 'plays_termination_', data_sets(i), '.mat');
    out_pre_plays_file_name         = strcat(plays_folder, 'preprocessed_plays_', data_sets(i), '.mat');
    out_plays_info_file_name        = strcat(plays_folder, 'plays_info_', data_sets(i), '.mat');
    out_plays_labels_file_name      = strcat(plays_folder, 'play_labels_', data_sets(i), '.mat');
    
    fprintf('Converting file: %s\n', event_db_filename);
    
    if ~isfile(out_plays_file_name)
        % Read json into table
        filename = fullfile(event_db_filename);
        filetext = fileread(filename);
        json    = jsondecode(filetext);

        % Extract all plays
        [play_indexes, termination_reason] = findPlays(json);
        plays   	 = playSeparation(json, play_indexes, offset);
        
        offset       = offset + numel(plays);

        % Save plays to a matlab file
        save(out_plays_file_name, 'plays');
        save(out_plays_termination_file_name, 'termination_reason');
    else
        load(out_plays_file_name);
        load(out_plays_termination_file_name);
    end
    
    if ~isfile(out_plays_info_file_name)
        % Extract plays info
        plays_info         = extractPlaysInfo(plays, player_data, match_data, team_data, pid_to_tf_pid, tf_market_value_dictionary, fifa_attr_data, termination_reason);
        
        save(out_plays_info_file_name, 'plays_info');
    else
        load(out_plays_info_file_name);
    end
    
    if ~isfile(out_plays_labels_file_name)
        % Create the labels
        labels    = cellfun(@(x) labelPlay(x), plays);
        labels(labels >= 3) = 0;	% 0 = Failed, 1 = Goal, 2 = Shot, 3 = Pass to goal, 4 = Definition sector
        
        save(out_plays_labels_file_name, 'labels');
    else
        load(out_plays_labels_file_name);
    end
    
    if ~isfile(out_pre_plays_file_name)
        % Set the preprocessing options
        opts               = setDefaultPreprocessOpts();
        
        preprocessed_plays = preprocessPlays(plays, opts);  % Preprocessing
        
        % Save plays to a matlab file
        save(out_pre_plays_file_name, 'preprocessed_plays');
    else
        load(out_pre_plays_file_name);
    end
    
    % Store the source db
    source_db = [source_db, repelem(i, numel(plays))];
    
end

if ~isfile(plays_source_db_file_name)
    % Save plays to a matlab file
    save(plays_source_db_file_name, 'source_db');
else
    load(plays_source_db_file_name);
end

%% Create corner kick play vectors

% Extract corner kick plays
MIN_PLAY_LENGTH    = 2;

plays_file_name      = strcat(plays_folder, 'corner_plays_full.mat');
labels_file_name     = strcat(plays_folder, 'corner_labels_full.mat');
source_db_file_name  = strcat(plays_folder, 'corner_source_db_full.mat');
plays_info_file_name = strcat(plays_folder, 'corner_plays_info_full.mat');

all_files_exist = isfile(plays_file_name) & isfile(labels_file_name) & isfile(source_db_file_name) & isfile(plays_info_file_name);

if ~all_files_exist
    [corner_plays, corner_labels, corner_source_db, corner_plays_info] = extractCompleteCornerPlayData(plays_folder, 'minLen', MIN_PLAY_LENGTH);

    % Save to file
    save(plays_file_name     , 'corner_plays');
    save(labels_file_name    , 'corner_labels');
    save(source_db_file_name , 'corner_source_db');
    save(plays_info_file_name, 'corner_plays_info');
else
    corner_plays = load(plays_file_name);
    corner_plays = corner_plays.corner_plays;
end

% Standarize play coordinates to the same frame of reference
standard_plays_filename             = strcat(plays_folder, 'standard_corner_plays_full.mat');
standard_plays_orig_corner_filename = strcat(plays_folder, 'standard_corner_plays_orig_corner_full.mat');

if ~isfile(standard_plays_filename)
    % Extract the standard play
    [standard_plays, origin_corners] = cellfun(@(x) standarizeCornerPlay(x), corner_plays, 'UniformOutput', false);
         
    % Save plays to a matlab file
    save(standard_plays_filename            , 'standard_plays');
    save(standard_plays_orig_corner_filename, 'origin_corners');
end

%% Extract corner plays with exactly one event

% Extract corner kick plays
MIN_PLAY_LENGTH    = 1;
MAX_PLAY_LENGTH    = 1;

plays_file_name      = strcat(plays_folder, 'corner_1_plays_full.mat');
labels_file_name     = strcat(plays_folder, 'corner_1_labels_full.mat');
source_db_file_name  = strcat(plays_folder, 'corner_1_source_db_full.mat');
plays_info_file_name = strcat(plays_folder, 'corner_1_plays_info_full.mat');

all_files_exist = isfile(plays_file_name) & isfile(labels_file_name) & isfile(source_db_file_name) & isfile(plays_info_file_name);

if ~all_files_exist
    [corner_plays, corner_labels, corner_source_db, corner_plays_info] = extractCompleteCornerPlayData(plays_folder, 'minLen', MIN_PLAY_LENGTH, 'maxLen', MAX_PLAY_LENGTH);

    % Save to file
    save(plays_file_name     , 'corner_plays');
    save(labels_file_name    , 'corner_labels');
    save(source_db_file_name , 'corner_source_db');
    save(plays_info_file_name, 'corner_plays_info');
else
    corner_plays = load(plays_file_name);
    corner_plays = corner_plays.corner_plays;
end

% Standarize play coordinates to the same frame of reference
standard_plays_filename             = strcat(plays_folder, 'standard_corner_1_plays_full.mat');
standard_plays_orig_corner_filename = strcat(plays_folder, 'standard_corner_1_plays_orig_corner_full.mat');

if ~isfile(standard_plays_filename)
    % Extract the standard play
    [standard_plays, origin_corners] = cellfun(@(x) standarizeCornerPlay(x), corner_plays, 'UniformOutput', false);
         
    % Save plays to a matlab file
    save(standard_plays_filename            , 'standard_plays');
    save(standard_plays_orig_corner_filename, 'origin_corners');
end
