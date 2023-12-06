function [label] = labelPlay(play, varargin)
% LABELPLAY The function labels the play according to the criteria in:
% https://www.notion.so/Criteria-to-label-successful-offensive-plays-SW-v1-0-dd075017451544a5bf4ad5cfcc244e1a
%
% It assigns one of the five possible levels of success as the label.
% The label is assigned hierarchically, that is, first we attempt to assign
% the highest level of success. The five levels of success are:
%   0 = Failed offensive
%   1 = Play ending in a goal
%   2 = Sequences with a shot at goal
%   3 = Sequences with a pass to the goal area
%   4 = Sequences ending in the definition sector
%
% NOTE:
%   - The definition and goal sectors are TBD.

    %% Parse arguments
    
    default_use_own_goal = false;
    
    p = inputParser;
    
    addRequired(p, 'play', @(x) isa(x, 'struct'));
    
    addParameter(p, 'useOwnGoal', default_use_own_goal, @(x) isa(x, 'logical'));

    parse(p, play, varargin{:});
    
    use_own_goal = p.Results.useOwnGoal;


    %% Initialization
    
    
    % MACROS
    GOAL_TAG     = 101;
    OWN_GOAL_TAG = 102;

    % Local variables
    goal_detected               = false;
    shot_detected               = false;
    pass_to_goal_detected       = false;
    definition_sector_detected  = false;
    label                       = 0;    % Default
    
    
    tags = {play.tags};
    
    non_empty_tags_filter = cellfun(@(x) ~isempty(x), tags);
    non_empty_tags        = tags(non_empty_tags_filter);
    tags_vector           = cellfun(@(x) x.id, non_empty_tags);
    
    %% Detect goals

    if use_own_goal
        goal_detected = any(ismember([GOAL_TAG, OWN_GOAL_TAG], tags_vector));
    else
        goal_detected = any(ismember([GOAL_TAG], tags_vector));
    end
        
    
    %% Detect shots at goal
    shot_detected = ismember('Shot', {play.eventName});
    
    %% Labeling
    
    if goal_detected
        label = 1;
    elseif shot_detected
        label = 2;
    elseif pass_to_goal_detected
        label = 3;
    elseif definition_sector_detected
        label = 4;
    else
        label = 0;
    end
    
    %% Detect an offside in the play
    % An offside immediately makes the play invalid and thus failed.
    
    offside_detected = ismember('Offside', {play.eventName});
    if offside_detected
       label = 0; 
    end
    
end