function LUT = loadLUTFromEncoding(encoding)
    % Choose variables w.r.t algorithm selection
    if strcmp(encoding, 'VH')
        load LUT_VH LUT_VH;
        LUT = LUT_VH;
    elseif strcmp(encoding, '18Z')
        load LUT_18 LUT_18;
        LUT = LUT_18;
    elseif strcmp(encoding, '8Dir')
        load LUT_8Dir LUT_8Dir;
        LUT = LUT_8Dir;
    elseif strcmp(encoding, 'simple')
        load LUT_Simple LUT_Simple;
        LUT = LUT_Simple;
    elseif strcmp(encoding, 'cannonical_corner_region_5')
        load LUT_CustomRegions5 LUT_CustomRegions5;
        LUT = LUT_CustomRegions5;
        clear LUT_CustomRegions5;
    elseif strcmp(encoding, 'cannonical_corner_region_7')
        load LUT_CustomRegions7 LUT_CustomRegions7;
        LUT = LUT_CustomRegions7;
        clear LUT_CustomRegions7;
    end

end