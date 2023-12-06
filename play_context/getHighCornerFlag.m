function high_corner_flag = getHighCornerFlag(corner_plays)
% The function labels all corner plays according to the appearance of the
% HIGH label on the first event of the corner kick play.

    high_corner_flag = strings(numel(corner_plays), 1);

    first_events = cellfun(@(x) x(1), corner_plays);
    tags = {first_events.tags};
    tags = cellfun(@(x) [x.id], tags, 'UniformOutput', false);
    
    has_high_tag = cellfun(@(x) any(x==801), tags, 'UniformOutput', false);
    has_high_tag = cell2mat(has_high_tag);
    
    % Simplify the notation
    high_corner_flag(has_high_tag)  = 't';
    high_corner_flag(~has_high_tag) = 'f';
    
end