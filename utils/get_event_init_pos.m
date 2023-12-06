function [init_pos] = get_event_init_pos(event)
    positions = event.positions;
    init_pos  = positions(1);
    init_pos  = [init_pos.x init_pos.y];
end