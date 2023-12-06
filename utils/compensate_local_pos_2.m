function position = compensate_local_pos_2(pos, is_attacking_team)
    x     = pos(1);
    y     = pos(2);
    
    if is_attacking_team
        new_x = x;
        new_y = 100 - y;
    else
        new_x = 100 - x;
        new_y = y;
    end
    
    position = [new_x new_y];    
end