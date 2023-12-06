function plays_info = extendContextData(plays_info1, plays_info2)
    % get fieldnames of structs A and B
    fieldnamesA = fieldnames(plays_info1);
    fieldnamesB = fieldnames(plays_info2);

    % check that the fieldnames are the same in both structs
    if ~isequal(fieldnamesA, fieldnamesB)
        error('Fieldnames do not match');
    end

    % create a new struct with concatenated vectors
    plays_info = struct();
    for i = 1:numel(fieldnamesA)
        fieldname = fieldnamesA{i};
        plays_info.(fieldname) = [plays_info1.(fieldname); plays_info2.(fieldname)];
    end
end