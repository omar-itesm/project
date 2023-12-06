function [possession_change] = detectPossessionChange(event)
    % Persistent variables
    persistent last_team_event_of_interest;
    persistent prev_event;
    
    % Initialization
    if isempty(last_team_event_of_interest)
        last_team_event_of_interest = event.teamId;
        prev_event = event;
    end

    % Local variables
    possession_change  = false;

    events_of_interest    = {'Pass', 'Free Kick'};
    subevents_of_interest = {'Clearance'};
    
    % Algorithm
    if (ismember(event.eventName, events_of_interest) || ...
       ismember(event.subEventName, subevents_of_interest) || ...
       isInterception(event) || isAcceleration(event))
   
        team = event.teamId;
        if last_team_event_of_interest ~= team
           possession_change = true;
           last_team_event_of_interest = team;
        end
    end
    
    %% Commenting this out as it doesn't seems to have an effect in the output...
    % I leave it for future reference
%     % If previous subevent is a touch then there is not a change in
%     % possession.
%     prev_subevent = prev_event.subEventName;
%     if possession_change && strcmp(prev_subevent, 'Touch')
%         possession_change = false;
%     end
end