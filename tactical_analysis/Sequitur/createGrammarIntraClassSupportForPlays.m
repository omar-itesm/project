function createGrammarIntraClassSupportForPlays(plays_filename, play_labels_filename, report_folder, varargin)
% CREATEGRAMMARINTRACLASSSUPPORTFORPLAYS
% The function reads a plays file encoded for Sequitur, creates a grammar
% file and finds the subgrammar that corresponds to each of the classes of
% plays. The grammar and subgrammars are summarized in a single CSV file.

    default_encoding = '8Dir';
    valid_encodings  = {'18Z', 'VH', '8Dir', 'simple', 'cannonical_corner_region_5', 'cannonical_corner_region_7'}; % TODO: Add remaining valid encodings like Van Haaren

    p = inputParser;
    
    addRequired(p, 'playsfilename'     , @(x) isa(x, 'char'));
    addRequired(p, 'playlabelsfilename', @(x) isa(x, 'char'));
    addRequired(p, 'reportfolder'      , @(x) isa(x, 'char'));
    
    addParameter(p, 'encoding', default_encoding, @(x) any(validatestring(x,valid_encodings)));
    
    parse(p, plays_filename, play_labels_filename, report_folder, varargin{:});
    
    encoding = p.Results.encoding;
    
    % Clear old CSV files
    S = dir(fullfile(report_folder,'*.CSV'));
    for k = 1:numel(S)
        baseFileName = S(k).name;
        fullFileName = fullfile(report_folder, baseFileName);
        fprintf(1, 'Now deleting %s\n', fullFileName);
        delete(fullFileName);
    end

    % Create grammar files
    py.sequitur_utils.createGrammarIntraClassReportForPlays2(plays_filename, play_labels_filename, report_folder);

    % Create summary report
    output_file = [report_folder, 'GrammarSummary.xlsx'];
    
    % Delete preexisting summary files
    S = dir(fullfile(report_folder,'*.xlsx'));
    for k = 1:numel(S)
        baseFileName = S(k).name;
        fullFileName = fullfile(report_folder, baseFileName);
        fprintf(1, 'Now deleting %s\n', fullFileName);
        delete(fullFileName);
    end
    
    % Write the new summary report
    S = dir(fullfile(report_folder,'*rules.CSV')); % We assume the first file is the file with 'All'
    for k = 1:numel(S)
        grammar_file  = [S(k).folder, '\', S(k).name];
        
        if contains(S(k).name, 'All')
            grammar_table = decodeGrammarFiles(grammar_file, 'encoding', encoding);
            rule_groups = getGrammarRuleGroups(grammar_table, 'encoding', encoding);
        else
            grammar_table = decodeGrammarFiles(grammar_file, rule_groups, 'encoding', encoding);
        end
        
        writetable(grammar_table, output_file, 'Sheet', S(k).name(1:end-4));
    end

end