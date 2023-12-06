function region = assignRegionBasedOnEncoding(position, encoding)
% The function receives a position in the field and assigns a region based
% on the given encoding.
% The function assumes that the position is specified in the correct
% format. For example, for the cannonical corner encoding, it is expected
% that the position is expressed in the 'standard' frame of reference.
    switch encoding
        case 'cannonical_corner_region_5'
            region = assignCustom5RegionEventPos(position);
        case 'cannonical_corner_region_7'
            region = assignCustom7RegionEventPos(position);
        otherwise
            warning('Invalid encoding in assignRegionBasedOnEncoding()');
            region = '';
    end

end