function is_goal_kick = isGoalKick(event)
    is_goal_kick = strcmp(event.subEventName, 'Goal kick');
end