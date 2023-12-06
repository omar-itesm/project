function origin_corner = getOriginCorner(corner_play)
% The function computes the origin corner for the input corner kick play.
% The init position of the play is converted into a standard frame of
% reference and the corner is computed from this frame.

    corner_kick_event = corner_play(1);
    is_attacking_team = true;
    
    [init_pos, ~] = compensatePosition2(corner_kick_event, is_attacking_team);
    
    init_y = init_pos(2);
    
    if init_y <= 50
        origin_corner = 'L';
    else
        origin_corner = 'R';
    end
    
end