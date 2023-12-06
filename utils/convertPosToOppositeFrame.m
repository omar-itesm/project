function new_pos = convertPosToOppositeFrame(pos)
% The function changes the frame of reference of the position to the point
% of view of the opponent.
    
    new_pos.y = 100 - pos.y;
    new_pos.x = 100 - pos.x;

end