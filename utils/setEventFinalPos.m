function event = setEventFinalPos(event, final_pos)
    event.positions(2).x = final_pos(1);
    event.positions(2).y = final_pos(2);
end