function [play_groups, play_groups_metadata] = encodeForSequiturPerClass(output_folder, plays, plays_metadata, labels, varargin)
% ENCODEFORSEQUITURPERCLASS The function receives a set of plays and its
% labels and creates a text file where each row represents a play encoded
% in a format that is friendly to the Sequitur algorithm. The plays are
% divided into multiple text files depending on their class label.

%% Parse arguments
valid_encodings   = {'18Z', 'VH', '8Dir', 'simple', 'cannonical_corner_region_5', 'cannonical_corner_region_7'};    % Supported encodings

default_encoding  = '18Z';

p = inputParser;

addRequired(p, 'outputFolder'     , @(x) isa(x, 'char'));
addRequired(p, 'plays'            , @(x) isa(x, 'cell'));
addRequired(p, 'plays_metadata'   , @(x) isa(x, 'cell'));
addRequired(p, 'labels'           , @(x) isa(x, 'double'));

addParameter(p, 'encoding'        , default_encoding        , @(x) any(validatestring(x, valid_encodings)));

parse(p, output_folder, plays, plays_metadata, labels, varargin{:});

encoding     = p.Results.encoding;

%% Parameter data
print_header_enable  = false;
algorithm            = 'sequitur';

%% Load label descriptions
load LUT_play_label LUT_play_label;

%% Check the output folder exists
if not(isfolder(output_folder))
    mkdir(output_folder)
end

%% Create a text file for each group of plays
num_groups  = 7;    % Corresponds to the possible labels

play_groups          = cell(1, num_groups);
play_groups_metadata = cell(1, num_groups);

for i=0:4
    label_name = getPlayLabelDescription(LUT_play_label, i);
    label_name = label_name{1};
    
    plays_filename   = [output_folder, encoding, '_', label_name, '_plays.txt'];
    
    play_groups{i + 1}          = plays(labels == i);
    play_groups_metadata{i + 1} = plays_metadata(labels == i);
    
    formatPlays(plays_filename, play_groups{i + 1}, 'encoding', encoding, 'includeMetadata', print_header_enable, 'algorithm', algorithm);
end

% Create a text file for all of the success plays
plays_filename   = [output_folder, encoding, '_Success_plays.txt'];
success_index    = 6;

play_groups{success_index}          = plays(labels > 0);
play_groups_metadata{success_index} = plays_metadata(labels > 0);

formatPlays(plays_filename, play_groups{success_index}, 'encoding', encoding, 'includeMetadata', print_header_enable, 'algorithm', algorithm);

% Create a text file for all the plays
plays_filename   = [output_folder, encoding, '_All_plays.txt'];
all_index        = 7;

play_groups{all_index}          = plays;
play_groups_metadata{all_index} = plays_metadata;

formatPlays(plays_filename, play_groups{all_index} , 'encoding', encoding, 'includeMetadata', print_header_enable, 'algorithm', algorithm);

end