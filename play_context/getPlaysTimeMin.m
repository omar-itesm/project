function init_times_min = getPlaysTimeMin(plays)

    init_time_sec  = cellfun(@(x) x(1).eventSec, plays);
    init_time_sec  = seconds(init_time_sec);
    init_times_min = minutes(init_time_sec);
    
end
