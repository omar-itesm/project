function num_play_duels = computeNumPlayDuels(plays)
% The function computes the number of Duel events in all of the plays of
% the input play vector.
    num_play_duels = cellfun(@(x) sum(contains({x.eventName}, 'Duel')), plays);
end