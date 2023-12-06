function [corner_plays_data_1, corner_plays_data_2] = loadCornerPlays()
    % TODO: Add the possibility to change the folder where plays are taken
    % or the data sets that we want to use.

    %% Plays with one event only

    files_struct.corner_plays       = 'standard_corner_1_plays_full.mat';
    files_struct.corner_origins     = 'standard_corner_1_plays_orig_corner_full.mat';
    files_struct.corner_labels      = 'corner_1_labels_full.mat';
    files_struct.corner_orig_db     = 'corner_1_source_db_full.mat';
    files_struct.corner_plays_info  = 'corner_1_plays_info_full.mat'; % Consider changing to standard_corner_1_plays_info_full
    files_struct.saved_plays_folder = [pwd '\data\plays\'];
    files_struct.output_folder      = [pwd '\output\Corner_simple\'];

    corner_plays_file_name      = strcat(files_struct.saved_plays_folder, files_struct.corner_plays);
    corner_plays_orig_file_name = strcat(files_struct.saved_plays_folder, files_struct.corner_origins);
    corner_labels_file_name     = strcat(files_struct.saved_plays_folder, files_struct.corner_labels);
    corner_source_db_file_name  = strcat(files_struct.saved_plays_folder, files_struct.corner_orig_db);
    corner_plays_info_file_name = strcat(files_struct.saved_plays_folder, files_struct.corner_plays_info);

    standard_plays = load(corner_plays_file_name);
    standard_plays = standard_plays.standard_plays;

    origin_corners = load(corner_plays_orig_file_name);
    origin_corners = origin_corners.origin_corners;

    corner_labels = load(corner_labels_file_name);
    corner_labels = corner_labels.corner_labels;

    corner_source_db = load(corner_source_db_file_name);
    corner_source_db = corner_source_db.corner_source_db;

    corner_plays_info = load(corner_plays_info_file_name);
    corner_plays_info = corner_plays_info.corner_plays_info;
%     corner_plays_info = corner_plays_info.plays_info;
    
    % Store the data in a struct
    corner_plays_data_1.standard_plays      = standard_plays;
    corner_plays_data_1.origin_corners      = origin_corners;
    corner_plays_data_1.corner_labels       = corner_labels;
    corner_plays_data_1.corner_source_db    = corner_source_db;
    corner_plays_data_1.corner_plays_info   = corner_plays_info;

    %% Plays with two or more events
    files_struct.corner_plays       = 'standard_corner_plays_full.mat';
    files_struct.corner_origins     = 'standard_corner_plays_orig_corner_full.mat';
    files_struct.corner_labels      = 'corner_labels_full.mat';
    files_struct.corner_orig_db     = 'corner_source_db_full.mat';
    files_struct.corner_plays_info  = 'corner_plays_info_full.mat'; % Consider changing to standard_corner_plays_info_full
    files_struct.saved_plays_folder = [pwd '\data\plays\'];
    files_struct.output_folder      = [pwd '\output\Corner\'];

    corner_plays_file_name      = strcat(files_struct.saved_plays_folder, files_struct.corner_plays);
    corner_plays_orig_file_name = strcat(files_struct.saved_plays_folder, files_struct.corner_origins);
    corner_labels_file_name     = strcat(files_struct.saved_plays_folder, files_struct.corner_labels);
    corner_source_db_file_name  = strcat(files_struct.saved_plays_folder, files_struct.corner_orig_db);
    corner_plays_info_file_name = strcat(files_struct.saved_plays_folder, files_struct.corner_plays_info);

    standard_plays = load(corner_plays_file_name);
    standard_plays = standard_plays.standard_plays;

    origin_corners = load(corner_plays_orig_file_name);
    origin_corners = origin_corners.origin_corners;

    corner_labels = load(corner_labels_file_name);
    corner_labels = corner_labels.corner_labels;

    corner_source_db = load(corner_source_db_file_name);
    corner_source_db = corner_source_db.corner_source_db;

    corner_plays_info = load(corner_plays_info_file_name);
    corner_plays_info = corner_plays_info.corner_plays_info;
%     corner_plays_info = corner_plays_info.plays_info;
    
    % Store the data in a struct
    corner_plays_data_2.standard_plays      = standard_plays;
    corner_plays_data_2.origin_corners      = origin_corners;
    corner_plays_data_2.corner_labels       = corner_labels;
    corner_plays_data_2.corner_source_db    = corner_source_db;
    corner_plays_data_2.corner_plays_info   = corner_plays_info;

end