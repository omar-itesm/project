function isCorner = isCornerPosition(pos)
% The function checks if the input pos is located exactly at one of the
% corners of the field.
    isCorner = false;
    
    if isequal(pos, [0 0]) || isequal(pos, [100 100]) || isequal(pos, [100 0]) || isequal(pos, [0 100])
        isCorner = true;
    end
end