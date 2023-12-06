function invalid_corner_idx = findInvalidCornerIndex(corner_plays)
% The function searches for corner kicks where the final position of the
% corner event is invalid.

    invalid_corner_idx = false(1,numel(corner_plays));

    for i=1:numel(corner_plays)
        current_play = corner_plays{i};
        
        corner_event = current_play(1);

        init_pos    = get_event_init_pos(corner_event);
        final_pos   = get_event_final_pos(corner_event);
        
        if isCornerPosition(final_pos)
            % A corner kick whose final position is one of the corners is
            % invalid for our purposes.
            invalid_corner_idx(i) = true;
        end
        
        
    end

end