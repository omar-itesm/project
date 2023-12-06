function time_intervals = getPlaysTimeInterval(plays)

    time_intervals = strings(numel(plays),1);

    init_times_min  = getPlaysInitTimeMinutes(plays);
    
    for i = 1:numel(plays)
        play_init_time    = init_times_min(i);
        time_intervals(i) = getTimeInterval(play_init_time);
    end
    
end

function init_time_min = getPlaysInitTimeMinutes(plays)
    init_time_sec = cellfun(@(x) x(1).eventSec, plays);
    init_time_sec = seconds(init_time_sec);
    init_time_min = minutes(init_time_sec);
end

function time_int = getTimeInterval(time_min)
    if time_min >= 0 && time_min < 15
        time_int = 'T15';
    elseif time_min >= 15 && time_min < 40
        time_int = 'T40';
    elseif time_min >= 40
        time_int = 'T45';
    else
        error('Invalid time interval');
    end

end