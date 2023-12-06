% Precondition: createGrammarFiles has been run

% This file reads the grammar files and applies the decoding
% folder = [pwd '\grammar_rules\'];
% filename = [folder 'simple_Failed_rules.csv'];
% encoding = 'simple';


function grammar_table = decodeGrammarFiles(grammar_filename, varargin)
    % Optional input: The rule_groups. This way we can obtain the same
    %                 groups for the different grammars.
    % Optional parameter: Encoding

    valid_encodings   = {'18Z', 'VH', '8Dir', 'simple', 'cannonical_corner_region_5', 'cannonical_corner_region_7'};    % Supported encodings
    default_encoding  = 'cannonical_corner_region_5';
    
    p = inputParser;

    addRequired(p, 'grammar_filename' , @(x) isa(x, 'char'));
    addOptional(p, 'rule_groups'      , @(x) isa(x, 'containers.Map'));
    addParameter(p, 'encoding'        , default_encoding        , @(x) any(validatestring(x, valid_encodings)));

    parse(p, grammar_filename, varargin{:});

    encoding     = p.Results.encoding;
    rule_groups  = p.Results.rule_groups;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    grammar_table = importGrammarRules(grammar_filename);

    [rows, cols] = size(grammar_table);

    decoded_column     = cell(rows, 1);
    decoded_core_seq   = cell(rows, 1);
    decoded_column_raw = cell(rows, 1);
    
    decoded_string = cell(rows, 1);
    
    for i = 1:rows
        raw      = grammar_table(i,:).Raw;
        expanded = grammar_table(i,:).Expand;

        %% Expanded column decoding
        tmp = char(expanded);
        tmp = regexp(tmp(2:end-1), ',', 'split');   % Remove the initial and ending brackets


        decoded_vector = [];
        for j = 1:numel(tmp)
            event_letter = tmp{j};
            event_letter = event_letter(isstrprop(event_letter,'alpha'));

            [decoded_event, other]  = decodeLUT2(LUT,event_letter);
            decoded_event = decoded_event + '_' + other;
            decoded_vector = [decoded_vector decoded_event];
        end

        decoded_column{i} = decoded_vector;
        
        %% Core sequence decoding
        decoded_vector = [];
        core_seq = getCoreSequence(expanded{:}, 'encoding', encoding);
        for j = 1:numel(core_seq)
            event_letter = core_seq{j};
            
            [decoded_event, other]  = decodeLUT2(LUT,event_letter);
            decoded_event = decoded_event + '_' + other;
            decoded_vector = [decoded_vector decoded_event];
        end
        
        if isempty(decoded_vector)
            decoded_core_seq{i} = "EMPTY";
        else
            decoded_core_seq{i} = strjoin(decoded_vector, " -> ");
        end
        

        %% TODO: Raw column decoding (requires different string parsing)
        % Decode the compressed play
        strrep(raw,', ',',');
        raw = strrep(raw,', ',',');
        raw = strrep(raw,'Production(','');
        raw = strrep(raw,')','');
        raw = strrep(raw,"'",'');
        raw = char(raw);
        raw = raw(2:end-1);

        split_play = regexp(raw, ',', 'split');


        decoded_vector = [];
        for j = 1:numel(split_play)
            current_event = split_play{j};

            isRule = ~isnan(str2double(current_event));

            if ~isRule
                [decoded_event, other]  = decodeLUT2(LUT,current_event);
                decoded_event = decoded_event + '_' + other;
            else
                rule = str2double(current_event);
                decoded_event = expandRule(rule, grammar_table);

                [decoded_event, other] = cellfun(@(x) decodeLUT2(LUT,x), decoded_event, 'UniformOutput', false);
                
                decoded_event = cellfun(@(x,y) strjoin([x,y],'_'), decoded_event, other);

                decoded_event = strjoin(string(decoded_event),', ');

            end
            
            
            decoded_vector = [decoded_vector decoded_event];            
        end

        decoded_column_raw{i} = decoded_vector;
        
        decoded_string{i} = strjoin(decoded_vector, " -> ");
    end

    %grammar_table.ExpandDecoded = decoded_column;
    %grammar_table.RawDecoded    = decoded_column_raw;
    grammar_table.StringDecoded = decoded_string;

    grammar_table.StringCoreSequence = decoded_core_seq;
    
    %% Assign a group to each core sequence
    
    % Rule groups variable was not provided, compute it.
    if ~isa(rule_groups, 'containers.Map')
        rule_groups     = getGrammarRuleGroups(grammar_table);
    end
    
    rule_groups     = rule_groups.values;
    
    % Create empty column for sequence group. Zero values are invalid
    % groups.
    grammar_table.Group = zeros(height(grammar_table),1);
    
    for group_id=1:numel(rule_groups)
       group_filter = ismember(grammar_table.Rule, rule_groups{group_id});
       grammar_table.Group(group_filter) = group_id;
    end
    

end

