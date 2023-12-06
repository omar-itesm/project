function final_dest = computePlayFinalDestination(play, varargin)
% The function receives a play and an encoding to determine which was the
% last region where the ball was sent.

%% Argument parsing
valid_encodings   = {'18Z', 'VH', '8Dir', 'simple', 'cannonical_corner_region_5', 'cannonical_corner_region_7'};    % Supported encodings
default_encoding  = 'cannonical_corner_region_5';

p = inputParser;

addRequired(p, 'play'      , @(x) isa(x, 'struct'));
addParameter(p, 'encoding'  , default_encoding        , @(x) any(validatestring(x, valid_encodings)));

parse(p, play, varargin{:});

encoding     = p.Results.encoding;

%% Implementation

% Find the last event of interest (pass or ball movement) in the play

target_events = {'Pass', 'Ball movement'}; % TODO: This can be passed as a parameter

event_names   = {play.eventName};

% Find the last event of interest
last_index              = find(ismember(event_names, target_events), 1, 'last');

if ~isempty(last_index)
    last_event_of_interest  = play(last_index);

    % Get the final position of the last event of interest
    final_pos   = get_event_final_pos(last_event_of_interest);

    % Assign a region according to the current encoding
    final_dest  = assignRegionBasedOnEncoding(final_pos, encoding);
else
    error('The play does not contain an event of interest');
end

final_dest = char(final_dest);

end