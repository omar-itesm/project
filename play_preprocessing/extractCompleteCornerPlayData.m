function [corner_plays, corner_labels, corner_source_db, corner_plays_info] = extractCompleteCornerPlayData(plays_folder, varargin)
% The file extracts the corner data from all the plays and joins them in a
% single vector.
%
% This file assumes that extractCompletePlayDataSet.m has been run and
% thus the preprocessed plays exist.

    %% Parse input
    default_min_play_len = 1;
    default_max_play_len = 100000; % Arbitrarily large number

    p = inputParser;

    addRequired(p, 'plays_folder', @(x) isa(x,'char'));
    addParameter(p, 'minLen', default_min_play_len);
    addParameter(p, 'maxLen', default_max_play_len);

    parse(p, plays_folder, varargin{:});

    MIN_PLAY_LENGTH    = p.Results.minLen;
    MAX_PLAY_LENGTH    = p.Results.maxLen;

    data_sets = ["World_Cup";
                 "European_Championship";
                 "Spain";
                 "England";
                 "France";
                 "Germany";
                 "Italy"
                 ];

    CORNER_USE_CASE    = 1;
    target_use_case    = CORNER_USE_CASE;

    % Assign a label to the plays in each data set
    corner_plays_vec = cell(1, numel(data_sets));
    labels_vec     	 = cell(1, numel(data_sets));
    source_db        = cell(1, numel(data_sets));
    plays_info_vec   = cell(1, numel(data_sets));

    %parfor
    parfor i=1:numel(data_sets)
        plays_file_name        = strcat(plays_folder, 'preprocessed_plays_', data_sets(i), '.mat');
        plays_info_file_name   = strcat(plays_folder, 'plays_info_', data_sets(i), '.mat');
        plays_labels_file_name = strcat(plays_folder, 'play_labels_', data_sets(i), '.mat');

        fprintf('Labeling file: %s\n', plays_file_name);
        plays      = load(plays_file_name); % Stored as preprocessed_plays
        plays_info = load(plays_info_file_name);
        plays_info = plays_info.plays_info;
        labels     = load(plays_labels_file_name);
        labels     = labels.labels;

        % Filter by play length
        [plays, plays_info, labels] = filterPlayDataByLength(plays.preprocessed_plays, plays_info, labels, 'minLen', MIN_PLAY_LENGTH, 'maxLen', MAX_PLAY_LENGTH);

        % Obtain corner plays only
        [filter_indexes, filtered_plays]  = filterPlaysByUseCase(plays, target_use_case);

        % Extract related plays info
        fnames = fieldnames(plays_info);
        for j = 1:numel(fnames)
            f = fnames(j);
            plays_info.(f{1}) = plays_info.(f{1})(filter_indexes);
        end

        labels = labels(filter_indexes);

        %% Remove invalid corners

        invalid_corners_mask = findInvalidCornerIndex(filtered_plays); % Returns a mask

        fprintf('A total of %d invalid corners found\r\n', sum(invalid_corners_mask));

        filtered_plays = filtered_plays(~invalid_corners_mask);

        % Remove invalid play info
        fnames = fieldnames(plays_info);
        for j = 1:numel(fnames)
            f = fnames(j);
            plays_info.(f{1})(invalid_corners_mask) = [];
        end

        labels = labels(~invalid_corners_mask);

        %% Store data set info

        % Store corner plays
        corner_plays_vec{i} = filtered_plays;

        plays_info_vec{i} = plays_info;

        % Store the source data set for the open plays
        source_db{i} = repelem(i, numel(filtered_plays));

        % Load the correct label file

        % Store labels
        labels_vec{i} = labels;
    end

    %% Concatenate the results
    full_labels      = [];
    full_corner_plays  = [];
    full_source_db   = [];
    full_plays_info  = struct();
    for j=1:numel(data_sets)
        full_labels     	= [full_labels; labels_vec{j}];
        full_corner_plays 	= [full_corner_plays; corner_plays_vec{j}];
        full_source_db  	= [full_source_db, source_db{j}];
        full_plays_info 	= concatenate_structs(full_plays_info, plays_info_vec{j});
    end

    full_source_db = full_source_db';

    %% Divide the data into classes

    FAIL_LABEL = 0;
    GOAL_LABEL = 1;
    SHOT_LABEL = 2;

    goal_plays     = full_corner_plays(full_labels == GOAL_LABEL);
    goal_labels    = full_labels(full_labels == GOAL_LABEL);
    goal_source_db = full_source_db(full_labels == GOAL_LABEL);

    shot_plays     = full_corner_plays(full_labels == SHOT_LABEL);
    shot_labels    = full_labels(full_labels == SHOT_LABEL);
    shot_source_db = full_source_db(full_labels == SHOT_LABEL);

    filter = full_labels == GOAL_LABEL | full_labels == SHOT_LABEL;

    success_plays      = full_corner_plays(full_labels == GOAL_LABEL | full_labels == SHOT_LABEL);
    success_labels     = full_labels(full_labels == GOAL_LABEL | full_labels == SHOT_LABEL);
    success_source_db  = full_source_db(full_labels == GOAL_LABEL | full_labels == SHOT_LABEL);
    success_plays_info = filter_struct_fields(full_plays_info, filter);

    fail_plays      = full_corner_plays(full_labels == FAIL_LABEL);
    fail_labels     = full_labels(full_labels == FAIL_LABEL);
    fail_source_db  = full_source_db(full_labels == FAIL_LABEL);
    fail_plays_info = filter_struct_fields(full_plays_info, full_labels == FAIL_LABEL);

    %% Create an ordered vector of corner plays

    corner_plays      = [success_plays; fail_plays];
    corner_labels     = [success_labels; fail_labels];
    corner_source_db  = [success_source_db; fail_source_db];
    corner_plays_info = concatenate_structs(success_plays_info, fail_plays_info);

end

%% Helper functions
function res = concatenate_structs(first_struct, second_struct)
    field_names = fieldnames(second_struct);
    
    if ~isempty(fieldnames(first_struct))

        for k=1:numel(field_names)
            x = field_names(k);

            a = first_struct.(x{:});
            b = second_struct.(x{:});

            c = [a;b];

            res.(x{:}) = c;
        end
    else
        res = second_struct;
    end
end

function res = filter_struct_fields(structure, filter)
    field_names = fieldnames(structure);
    
    if ~isempty(fieldnames(structure))

        for k=1:numel(field_names)
            x = field_names(k);

            a = structure.(x{:});
            a = a(filter);
            
            structure.(x{:}) = a;
 
        end
        
        res = structure;
    else
        res = structure;
    end
end

function [plays, plays_info, labels] = filterPlayDataByLength(plays, plays_info, labels, varargin)
    
    %% Parse input
    default_min_play_len = 1;
    default_max_play_len = 100000; % Arbitrarily large number
    
    p = inputParser;
    
    addRequired(p, 'plays', @(x) isa(x,'cell'));
    addRequired(p, 'plays_info', @(x) isa(x,'struct'));
    addRequired(p, 'labels', @(x) isa(x,'double'));
    addParameter(p, 'minLen', default_min_play_len);
    addParameter(p, 'maxLen', default_max_play_len);

    parse(p, plays, plays_info, labels, varargin{:});
    
    MIN_LEN    = p.Results.minLen;
    MAX_LEN    = p.Results.maxLen;


    %% Ensure same size vectors
    
    % Remove all plays of 0 events or less as they are considered irrelevant
    valid_plays = cellfun(@(x) numel(x) >= MIN_LEN & numel(x) <= MAX_LEN, plays);
    plays       = plays(valid_plays);
    
    % Remove invalid play info
    for field=fieldnames(plays_info)'
        plays_info.(field{1})(~valid_plays) = [];
    end
    
    % Trim labels vector to the correct size
    labels = labels(valid_plays);
    
end