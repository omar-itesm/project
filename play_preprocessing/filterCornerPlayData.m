function corner_plays_data = filterCornerPlayData(corner_plays_data, filter)
    corner_plays_data.standard_plays        = corner_plays_data.standard_plays(filter);
    corner_plays_data.origin_corners        = corner_plays_data.origin_corners(filter);
    corner_plays_data.corner_labels         = corner_plays_data.corner_labels(filter);
    corner_plays_data.corner_source_db      = corner_plays_data.corner_source_db(filter);
    
%     corner_plays_data.corner_plays_info     = filterStruct(corner_plays_data.corner_plays_info, filter);
    corner_plays_data.corner_plays_info     = filterStruct(corner_plays_data.corner_plays_info, filter);
end