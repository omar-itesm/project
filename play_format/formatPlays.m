function formatPlays(output_filename, plays, varargin)
% FORMATPLAYS creates a text file with the plays encoded in a specific
% format and targeted to be run with a specific algorithm. For instance,
% the plays can be encoded based on their event type and location on the
% field. However, depending on the algorithm that we plan to run, we need
% to prepare the data slightly different (as each algorithm expects a
% different input format). This function handles all the work such that the
% user only needs to specify the encoding and target algorithm and the
% correct file is generated.

    %% Parse arguments
    valid_algorithms  = {'tks', 'sequitur'};                % Supported algorithms
    valid_encodings   = {'18Z', 'VH', '8Dir', 'simple', 'cannonical_corner_region_5', 'cannonical_corner_region_7'};    % Supported encodings
    
    default_algorithm        = 'tks';
    default_encoding         = '18Z';
    default_include_metadata = false;
    
    p = inputParser;
    
    addRequired(p, 'outputFilename'     , @(x) isa(x, 'char'));
    addRequired(p, 'plays'              , @(x) isa(x, 'cell'));
    
    addParameter(p, 'encoding'          , default_encoding        , @(x) any(validatestring(x, valid_encodings)));
    addParameter(p, 'algorithm'         , default_algorithm       , @(x) any(validatestring(x, valid_algorithms)));
    addParameter(p, 'includeMetadata'   , default_include_metadata, @(x) isa(x, 'logical'));
    
    parse(p, output_filename, plays, varargin{:});
    
    print_header = p.Results.includeMetadata;
    algorithm    = p.Results.algorithm;
    encoding     = p.Results.encoding;

    %% Preprocessing

    % Local variables
    size_play_indexes = size(plays);
    num_plays         = size_play_indexes(1);
    
    % Choose variables w.r.t algorithm selection
    if strcmp(encoding, 'VH')
        load LUT_VH LUT_VH;
        LUT = LUT_VH;
        clear LUT_VH;
    elseif strcmp(encoding, '18Z')
        load LUT_18 LUT_18;
        LUT = LUT_18;
        clear LUT_18;
    elseif strcmp(encoding, '8Dir')
        load LUT_8Dir LUT_8Dir;
        LUT = LUT_8Dir;
        clear LUT_8Dir;
    elseif strcmp(encoding, 'simple')
        load LUT_Simple LUT_Simple;
        LUT = LUT_Simple;
        clear LUT_Simple;
    elseif strcmp(encoding, 'cannonical_corner_region_5')
        load LUT_CustomRegions5 LUT_CustomRegions5;
        LUT = LUT_CustomRegions5;
        clear LUT_CustomRegions5;
    elseif strcmp(encoding, 'cannonical_corner_region_7')
        load LUT_CustomRegions7 LUT_CustomRegions7;
        LUT = LUT_CustomRegions7;
        clear LUT_CustomRegions7;
    end
    
    
    %% Write header
    if print_header
        writePlaysHeader(output_filename, LUT, encoding);
        fileID = fopen(output_filename, 'a');    % Open in append mode
    else
        fileID = fopen(output_filename, 'w');    % Open in write mode
    end    
    
    %% Format play data
    for i=1:num_plays
        current_play = plays{i};
        
        % Encode play
        encoded_play = encodePlayData(current_play, LUT, encoding, algorithm);
        
        % Format string
        reps = numel(encoded_play);
        switch algorithm
            case 'tks'
                fmt  = [repmat('%d -1 ',1, reps) '-2 \r\n'];
            case 'sequitur'
                fmt  = [repmat('%s ',1, reps) '\r\n'];
            otherwise
                error('Invalid algorithm type');
        end
        
        % Write to file
        fprintf(fileID, fmt, encoded_play);
    end
    
    %% Close file
    fclose(fileID);
end