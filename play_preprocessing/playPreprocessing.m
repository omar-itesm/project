function play = playPreprocessing(play, varargin)
% Play pre-processing according to: 
% https://www.notion.so/Requirements-play-preprocessing-v2-5-0-b2ef5ffd0a8945e4bced96a6185f90f1

switch nargin
    case 1
        opts = setDefaultPreprocessOpts();
    case 2
        opts = varargin{1};
    otherwise
        error('Invalid number of parameters for playPreprocessing');
end

%% Options

% DUEL
join_duels   = opts.join_duels;
remove_duels = opts.remove_duels;

% PASS
join_passes = opts.join_passes;

% INTERRUPTION
include_ball_out_of_field = opts.include_ball_out_of_field;
remove_interuption        = opts.remove_interruption; % Only executed after all previous
                                                      % interruptions have
                                                      % been transformed so
                                                      % that they do not
                                                      % get removed.

% FOUL
remove_foul = opts.remove_foul;

% OFFSIDE
remove_offside = opts.remove_offside;

% SAVE ATTEMPT
remove_save_attempt = opts.remove_save_attempt;

% GOALKEEPER LEAVING LINE (GLL)
remove_gll     = opts.remove_gll;

% OTB
include_clearance     = opts.include_clearance;
include_acceleration  = opts.include_acceleration;
include_interceptions = opts.include_interceptions;
join_otb              = opts.join_otb;
remove_otb            = opts.remove_otb; % This is done after the above lines have executed.
                                         % For example, if include clearance
                                         % is set to true and remove otb is
                                         % also set to true, the clerance is
                                         % preserved and the rest of the otb
                                         % events are removed.

% FREE KICK (FK)
include_throw_in    = opts.include_throw_in;
include_corner      = opts.include_corner;
include_penalty     = opts.include_penalty;
include_goal_kick   = opts.include_goal_kick;

% Ball movement
include_ball_movement_event = opts.include_ball_movement_event;

% Corner to pass
convert_corner_to_pass = opts.convert_corner_to_pass;

% Shot
include_shot_to_goal  = opts.include_shot_to_goal;
replace_shot_to_goal  = opts.replace_shot_to_goal;
remove_all_after_shot = opts.remove_all_after_shot;
remove_shot           = opts.remove_shot;

%% DUEL

% Join consecutive duels
if join_duels
    prev_event_name = '';
    to_be_removed = [];
    for event_index = 1:numel(play)
        current_event = play(event_index);
        event_name = current_event.eventName;
        
        if strcmp(event_name, 'Duel') && strcmp(prev_event_name, 'Duel')
            to_be_removed = [to_be_removed event_index];
        end
        prev_event_name = event_name;
    end
    
    % Remove the extra duels (keep the last one)
    play(to_be_removed - 1) = [];
    
end

% Remove duels
if remove_duels
    to_be_removed = [];
    for event_index = 1:numel(play)
        current_event = play(event_index);
        event_name = current_event.eventName;
        
        if strcmp(event_name, 'Duel')
            to_be_removed = [to_be_removed event_index];
        end
    end
    
    % Remove the extra duels (keep the last one)
    play(to_be_removed) = [];
end


%% INTERRUPTION

if include_ball_out_of_field
    for event_index = 1:numel(play)
        current_event   = play(event_index);
        
        if isOutOfField(current_event)
            play(event_index).eventName = 'Out of field';
        end
    end
end

if remove_interuption
    to_be_removed = [];
    for event_index = 1:numel(play)
        current_event = play(event_index);
        event_name = current_event.eventName;
        
        if strcmp(event_name, 'Interruption')
            to_be_removed = [to_be_removed event_index];
        end
    end
    
    % Remove the extra duels (keep the last one)
    play(to_be_removed) = [];
end

%% FOUL
if remove_foul
    to_be_removed = [];
    for event_index = 1:numel(play)
        current_event = play(event_index);
        event_name = current_event.eventName;
        
        if strcmp(event_name, 'Foul')
            to_be_removed = [to_be_removed event_index];
        end
    end
    
    % Remove the extra duels (keep the last one)
    play(to_be_removed) = [];
end

%% OFFSIDE
if remove_offside
    to_be_removed = [];
    for event_index = 1:numel(play)
        current_event = play(event_index);
        event_name = current_event.eventName;
        
        if strcmp(event_name, 'Offside')
            to_be_removed = [to_be_removed event_index];
        end
    end
    
    % Remove the extra duels (keep the last one)
    play(to_be_removed) = [];
end

%% GOALKEEPER LEAVING LINE (GLL)
if remove_gll
    to_be_removed = [];
    for event_index = 1:numel(play)
        current_event = play(event_index);
        event_name = current_event.eventName;
        
        if strcmp(event_name, 'Goalkeeper leaving line')
            to_be_removed = [to_be_removed event_index];
        end
    end
    
    % Remove the extra duels (keep the last one)
    play(to_be_removed) = [];
end

%% SAVE ATTEMPT
if remove_save_attempt
    to_be_removed = [];
    for event_index = 1:numel(play)
        current_event = play(event_index);
        event_name = current_event.eventName;
        
        if strcmp(event_name, 'Save attempt')
            to_be_removed = [to_be_removed event_index];
        end
    end
    
    % Remove the extra duels (keep the last one)
    play(to_be_removed) = [];
end

%% OTHERS ON THE BALL


if include_acceleration
    for event_index = 1:numel(play)
        current_event   = play(event_index);
        
        if isAcceleration(current_event)
            play(event_index).eventName = 'Acceleration';
        end
    end
end

if include_clearance
    for event_index = 1:numel(play)
        current_event   = play(event_index);
        event_name      = current_event.eventName;
        subevent_name   = current_event.subEventName;
        
        if strcmp(event_name, 'Others on the ball') && strcmp(subevent_name, 'Clearance')
            play(event_index).eventName = 'Clearance';
        end
    end
end

if include_interceptions
    for event_index = 1:numel(play)
        current_event   = play(event_index);
        
        if isInterception(current_event)
            play(event_index).eventName = 'Interception';
        end
        
    end
end

% Join consecutive others on the ball
if join_otb
    prev_event_name = '';
    to_be_removed = [];
    for event_index = 1:numel(play)
        current_event = play(event_index);
        event_name = current_event.eventName;
        
        if strcmp(event_name, 'Others on the ball') && strcmp(prev_event_name, 'Others on the ball')
            to_be_removed = [to_be_removed event_index];
        end
        prev_event_name = event_name;
    end
    
    % Remove the extra duels
    play(to_be_removed) = [];
    
end


if remove_otb
    to_be_removed = [];
    for event_index = 1:numel(play)
        current_event = play(event_index);
        event_name = current_event.eventName;
        
        if strcmp(event_name, 'Others on the ball')
            to_be_removed = [to_be_removed event_index];
        end
    end
    
    % Remove the extra duels (keep the last one)
    play(to_be_removed) = [];
end

%% FREE KICK

if include_throw_in
    for event_index = 1:numel(play)
        current_event   = play(event_index);
        event_name      = current_event.eventName;
        subevent_name   = current_event.subEventName;
        
        if strcmp(event_name, 'Free Kick') && strcmp(subevent_name, 'Throw in')
            play(event_index).eventName = 'Throw in';
        end
    end
end

if include_corner
    for event_index = 1:numel(play)
        current_event   = play(event_index);
        event_name      = current_event.eventName;
        subevent_name   = current_event.subEventName;
        
        if strcmp(event_name, 'Free Kick') && strcmp(subevent_name, 'Corner')
            % TODO: Perhaps add the direction here!
            play(event_index).eventName = 'Corner';
        end
    end
end

if include_penalty
    for event_index = 1:numel(play)
        current_event   = play(event_index);
        event_name      = current_event.eventName;
        subevent_name   = current_event.subEventName;
        
        if strcmp(event_name, 'Free Kick') && strcmp(subevent_name, 'Penalty')
            play(event_index).eventName = 'Penalty';
        end
    end
end

if include_goal_kick
    for event_index = 1:numel(play)
        current_event   = play(event_index);
        event_name      = current_event.eventName;
        subevent_name   = current_event.subEventName;
        
        if strcmp(event_name, 'Free Kick') && strcmp(subevent_name, 'Goal kick')
            play(event_index).eventName = 'Goal Kick';
        end
    end
end

%% PASS

% Join passes into long and short sequences
if join_passes
    prev_event_name = '';
    to_be_removed = [];
    num_consecutive_passes = 1;
    pass_chain = [];
    
    for event_index = 1:numel(play)
        current_event = play(event_index);
        event_name = current_event.eventName;
        
        if strcmp(event_name, 'Pass') && strcmp(prev_event_name, 'Pass')
            to_be_removed = [to_be_removed event_index];
            pass_chain    = [pass_chain event_index];
            num_consecutive_passes = num_consecutive_passes + 1;
        else
            % Compute the number of passes and the index of the first pass
            if num_consecutive_passes > 1
                first_pass_index = pass_chain(1) - 1;
            end

            % Change the event name of the first pass event
            if num_consecutive_passes > 3
                play(first_pass_index).eventName = 'Pass chain (long)';
            elseif num_consecutive_passes > 1
                play(first_pass_index).eventName = 'Pass chain (short)';
            end
            pass_chain = [];
            num_consecutive_passes = 1;
        end
        prev_event_name = event_name;
    end
    
    % Compute the number of passes and the index of the first pass
    if num_consecutive_passes > 1
        first_pass_index = pass_chain(1) - 1;
    end

    % Change the event name of the first pass event
    if num_consecutive_passes > 3
        play(first_pass_index).eventName = 'Pass chain (long)';
    elseif num_consecutive_passes > 1
        play(first_pass_index).eventName = 'Pass chain (short)';
    end
    pass_chain = [];
    num_consecutive_passes = 1;
    
    play(to_be_removed) = [];
    
end

%% Add ball movement event

if include_ball_movement_event
    play = addBallMovementEvent2Play(play);
end


%% Corner to pass

% This code relies on the assumption that no other function has changed the
% subevent information.

if convert_corner_to_pass
    for event_index = 1:numel(play)
        current_event   = play(event_index);
        event_name      = current_event.eventName;
        subevent_name   = current_event.subEventName;
        
        if strcmp(subevent_name, 'Corner')
            play(event_index).eventName = 'Pass';
        end
    end
end

%% Shot
if include_shot_to_goal
   if numel(play) > 0
       prev_event = play(1);
   end

   to_be_removed = [];
   for event_index = 1:numel(play)
      current_event = play(event_index);

      if strcmp(prev_event.eventName,'Shot')
          if strcmp(current_event.eventName, 'Save attempt')
              play(event_index - 1).eventName = 'Shot to goal';
              
              to_be_removed = [to_be_removed event_index];
          end
      end
      
      prev_event = current_event;
   end
   
    % Remove the extra duels
    play(to_be_removed) = [];
   
end


if replace_shot_to_goal
    for event_index = 1:numel(play)
        current_event   = play(event_index);
        event_name      = current_event.eventName;
        
        if strcmp(event_name, 'Shot to goal')
            play(event_index).eventName = 'Shot';
        end
    end
end

% Remove all events after shot
% NOTE: Technically we have a bug here, because there may be plays that
% scored after the second shot. So if we remove the second shot, we won't
% label them correctly as plays with goal. However, since success is either
% shot or goal they will still be marked as successful, just not derived
% from the fact that it had a goal. Be careful if the analysis is around
% the goal label.
shot_found = 0;
if remove_all_after_shot
    to_be_removed = [];
    for event_index = 1:numel(play)
        current_event   = play(event_index);
        event_name      = current_event.eventName;
        
        if shot_found
            to_be_removed = [to_be_removed event_index];
        end
        
        if strcmp(event_name, 'Shot')
            shot_found = 1;
        end
        
    end
    
    % Remove all events after the first shot
    play(to_be_removed) = [];
end

% Remove shot
if remove_shot
    to_be_removed = [];
    for event_index = 1:numel(play)
        current_event = play(event_index);
        event_name = current_event.eventName;
        
        if strcmp(event_name, 'Shot')
            to_be_removed = [to_be_removed event_index];
        end
    end
    
    % Remove the extra duels (keep the last one)
    play(to_be_removed) = [];
end

end

% play(event_index) = [];