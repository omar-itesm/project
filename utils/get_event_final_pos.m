function [final_pos] = get_event_final_pos(event)
    positions = event.positions;
    final_pos  = positions(end);
    final_pos  = [final_pos.x final_pos.y];
end