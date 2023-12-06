function corner_plays_data = mergeCornerData(corner_plays_data_1, corner_plays_data_2)
    corner_plays_data.standard_plays      = vertcat(corner_plays_data_1.standard_plays, corner_plays_data_2.standard_plays);
    corner_plays_data.origin_corners      = vertcat(corner_plays_data_1.origin_corners, corner_plays_data_2.origin_corners);
    corner_plays_data.corner_labels       = vertcat(corner_plays_data_1.corner_labels, corner_plays_data_2.corner_labels);
    corner_plays_data.corner_source_db    = vertcat(corner_plays_data_1.corner_source_db, corner_plays_data_2.corner_source_db);
    
    extended_info                         = extendContextData(corner_plays_data_1.corner_plays_info, corner_plays_data_2.corner_plays_info);
    corner_plays_data.corner_plays_info   = extended_info;
end