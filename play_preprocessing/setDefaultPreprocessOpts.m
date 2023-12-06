function opts = setDefaultPreprocessOpts()


%% Alternate configuration: Focus on ball movement

opts = struct();

% DUELS
opts.('join_duels')          = false;
opts.('remove_duels')        = true ;

% PASS
opts.('join_passes')         = false; % Join long pass sequences into a single event

% INTERRUPTION
opts.('include_ball_out_of_field') = false;
opts.('remove_interruption')       = true;

% FOUL
opts.('remove_foul')           = true;

% OFFSIDE
opts.('remove_offside')        = true;

% GOALKEEPER LEAVING LINE (GLL)
opts.('remove_gll')            = true;

% SAVE ATTEMPT
opts.('remove_save_attempt')   = true;

% OTB
opts.('include_clearance')     = false;
opts.('include_acceleration')  = false;
opts.('include_interceptions') = false;
opts.('join_otb')              = false; % Join others on the ball events
opts.('remove_otb')            = true;

% FREE KICK
opts.('include_throw_in')    = true;
opts.('include_corner')      = true;
opts.('include_penalty')     = true;
opts.('include_goal_kick')   = true;

% Ball movement
opts.('include_ball_movement_event') = true;

% Corner to pass
opts.('convert_corner_to_pass')      = true; % The raw data considers corner a FK

% SHOT
opts.('include_shot_to_goal') = false;
opts.('replace_shot_to_goal') = false; % Replaces shot to goal with a regular shot event
opts.('remove_all_after_shot')= true;  % Removes all events after the first shot event
opts.('remove_shot')          = true;  % Remove all remaining shot events

end


%% Baseline options:

% opts = struct();
% 
% % DUELS
% opts.('join_duels')          = false;
% opts.('remove_duels')        = true ;
% 
% % PASS
% opts.('join_passes')         = false; % Join long pass sequences into a single event
% 
% % INTERRUPTION
% opts.('include_ball_out_of_field') = true;
% opts.('remove_interruption')       = false;
% 
% % FOUL
% opts.('remove_foul')           = false;
% 
% % OFFSIDE
% opts.('remove_offside')        = false;
% 
% % GOALKEEPER LEAVING LINE (GLL)
% opts.('remove_gll')            = false;
% 
% % SAVE ATTEMPT
% opts.('remove_save_attempt')   = false;
% 
% % OTB
% opts.('include_clearance')     = true;
% opts.('include_acceleration')  = false;
% opts.('include_interceptions') = true;
% opts.('join_otb')              = true; % Join others on the ball events
% opts.('remove_otb')            = true;
% 
% % FREE KICK
% opts.('include_throw_in')    = true;
% opts.('include_corner')      = true;
% opts.('include_penalty')     = true;
% opts.('include_goal_kick')   = true;
% 
% % Ball movement
% opts.('include_ball_movement_event') = true;
% 
% % Corner to pass
% opts.('convert_corner_to_pass')      = true; % The raw data considers corner a FK
% 
% % SHOT
% opts.('include_shot_to_goal') = true;
% opts.('replace_shot_to_goal') = true;  % Replaces shot to goal with a regular shot event
% opts.('remove_all_after_shot')= true;  % Removes all events after the first shot event
% opts.('remove_shot')          = false; % Remove all remaining shot events

%% Alternate configuration: Focus on ball movement

% opts = struct();
% 
% % DUELS
% opts.('join_duels')          = false;
% opts.('remove_duels')        = true ;
% 
% % PASS
% opts.('join_passes')         = false; % Join long pass sequences into a single event
% 
% % INTERRUPTION
% opts.('include_ball_out_of_field') = false;
% opts.('remove_interruption')       = true;
% 
% % FOUL
% opts.('remove_foul')           = true;
% 
% % OFFSIDE
% opts.('remove_offside')        = true;
% 
% % GOALKEEPER LEAVING LINE (GLL)
% opts.('remove_gll')            = true;
% 
% % SAVE ATTEMPT
% opts.('remove_save_attempt')   = true;
% 
% % OTB
% opts.('include_clearance')     = false;
% opts.('include_acceleration')  = false;
% opts.('include_interceptions') = false;
% opts.('join_otb')              = false; % Join others on the ball events
% opts.('remove_otb')            = true;
% 
% % FREE KICK
% opts.('include_throw_in')    = true;
% opts.('include_corner')      = true;
% opts.('include_penalty')     = true;
% opts.('include_goal_kick')   = true;
% 
% % Ball movement
% opts.('include_ball_movement_event') = true;
% 
% % Corner to pass
% opts.('convert_corner_to_pass')      = true; % The raw data considers corner a FK
% 
% % SHOT
% opts.('include_shot_to_goal') = false;
% opts.('replace_shot_to_goal') = false; % Replaces shot to goal with a regular shot event
% opts.('remove_all_after_shot')= true;  % Removes all events after the first shot event
% opts.('remove_shot')          = true;  % Remove all remaining shot events